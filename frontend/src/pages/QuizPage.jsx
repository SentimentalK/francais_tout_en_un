import React, { useEffect, useState, useRef, useMemo, useCallback } from 'react';
import { useParams, Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { fetchQuizContent } from '../api/courses';
import NavBar from '../components/NavBar';
import { ArrowLeft, Trophy, Clock, CheckCircle2, Type } from 'lucide-react';

/* ── helpers ── */
const normalize = (s) => s.trim().toLowerCase().replace(/\s+/g, ' ');

function formatTime(seconds) {
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    return `${m}:${s.toString().padStart(2, '0')}`;
}

const MAX_ITEMS_PER_COLUMN = 12;

/* ── page ── */
export default function QuizPage() {
    const { quizId } = useParams();
    const numericId = Number(quizId);

    const { data: quiz, isLoading, isError, error } = useQuery({
        queryKey: ['quizContent', numericId],
        queryFn: () => fetchQuizContent(numericId),
        enabled: !!numericId,
    });

    // Parse content_json once
    const groups = useMemo(() => {
        if (!quiz?.content_json) return [];
        try { return JSON.parse(quiz.content_json); }
        catch { return []; }
    }, [quiz]);

    // Build flat answer index
    const { totalItems, answerMap } = useMemo(() => {
        const map = new Map(); // normalized answer → { groupIdx, itemIdx }
        let total = 0;
        groups.forEach((g, gi) => {
            g.items.forEach((item, ii) => {
                map.set(normalize(item.answer), { groupIdx: gi, itemIdx: ii });
                total++;
            });
        });
        return { totalItems: total, answerMap: map };
    }, [groups]);

    // Build display columns: split large groups into chunks for multi-column layout
    const displayColumns = useMemo(() => {
        const cols = [];
        groups.forEach((group, gi) => {
            if (group.items.length <= MAX_ITEMS_PER_COLUMN) {
                cols.push({ group, gi, items: group.items, startIdx: 0, isChunk: false });
            } else {
                for (let i = 0; i < group.items.length; i += MAX_ITEMS_PER_COLUMN) {
                    const chunk = group.items.slice(i, i + MAX_ITEMS_PER_COLUMN);
                    cols.push({ group, gi, items: chunk, startIdx: i, isChunk: true, chunkLabel: `${i + 1}–${i + chunk.length}` });
                }
            }
        });
        return cols;
    }, [groups]);

    // State: set of found keys "gi-ii"
    const [found, setFound] = useState(new Set());
    const [inputValue, setInputValue] = useState('');
    const [elapsed, setElapsed] = useState(0);
    const [isRunning, setIsRunning] = useState(false);
    const [justFound, setJustFound] = useState(null); // "gi-ii" to flash
    const inputRef = useRef(null);
    const timerRef = useRef(null);

    // Reset state when quiz changes
    useEffect(() => {
        setFound(new Set());
        setInputValue('');
        setElapsed(0);
        setIsRunning(false);
        setJustFound(null);
        if (timerRef.current) clearInterval(timerRef.current);
    }, [numericId, groups.length]);

    // Timer
    useEffect(() => {
        if (isRunning) {
            timerRef.current = setInterval(() => setElapsed(e => e + 1), 1000);
        }
        return () => { if (timerRef.current) clearInterval(timerRef.current); };
    }, [isRunning]);

    // Auto-focus input
    useEffect(() => {
        if (groups.length > 0) inputRef.current?.focus();
    }, [groups]);

    // Stop timer when all found
    const isComplete = found.size === totalItems && totalItems > 0;
    useEffect(() => {
        if (isComplete && timerRef.current) {
            clearInterval(timerRef.current);
            setIsRunning(false);
        }
    }, [isComplete]);

    // Input handler
    const handleInput = useCallback((e) => {
        const val = e.target.value;
        setInputValue(val);

        // Start timer on first keystroke
        if (!isRunning && !isComplete) setIsRunning(true);

        const norm = normalize(val);
        if (!norm) return;

        const match = answerMap.get(norm);
        if (match) {
            const key = `${match.groupIdx}-${match.itemIdx}`;
            if (!found.has(key)) {
                setFound(prev => new Set(prev).add(key));
                setJustFound(key);
                setTimeout(() => setJustFound(null), 600);
            }
            setInputValue('');
        }
    }, [answerMap, found, isRunning, isComplete]);

    // ── Render states ──

    if (isLoading) {
        return (
            <div className="min-h-screen bg-zinc-50 flex flex-col font-sans">
                <NavBar />
                <main className="max-w-4xl mx-auto px-6 py-10 w-full flex-grow flex items-center justify-center">
                    <p className="text-zinc-400 text-lg">Loading quiz…</p>
                </main>
            </div>
        );
    }

    if (isError || !quiz) {
        return (
            <div className="min-h-screen bg-zinc-50 flex flex-col font-sans">
                <NavBar />
                <main className="max-w-4xl mx-auto px-6 py-10 w-full flex-grow flex items-center justify-center">
                    <p className="text-rose-500 text-lg">⚠️ {error?.message || 'Quiz not found.'}</p>
                </main>
            </div>
        );
    }

    const progress = found.size;

    return (
        <div className="min-h-screen bg-zinc-50 flex flex-col font-sans">
            <NavBar />
            <main className="max-w-7xl mx-auto px-4 sm:px-6 py-8 w-full flex-grow">

                {/* ── Back link ── */}
                <Link to="/" state={{ activeCategory: 'quiz' }} className="inline-flex items-center gap-2 text-sm text-zinc-400 hover:text-zinc-900 transition-colors mb-6 no-underline">
                    <ArrowLeft className="w-4 h-4" /> Back to Quizzes
                </Link>

                {/* ── Header card ── */}
                <div className="bg-white rounded-3xl p-6 md:p-8 shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-zinc-900/5 mb-6">
                    <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">

                        {/* Left: title + meta */}
                        <div>
                            <span className="text-[11px] font-bold px-3 py-1.5 rounded-full bg-zinc-100 text-zinc-500 tracking-wider uppercase">
                                {quiz.tag || 'Quiz'}
                            </span>
                            <h1 className="text-2xl md:text-3xl font-extrabold text-zinc-900 tracking-tight mt-3 mb-1">{quiz.title}</h1>
                            <p className="text-zinc-500 text-sm">{quiz.description}</p>
                        </div>

                        {/* Right: stats */}
                        <div className="flex items-center gap-6 shrink-0">
                            {/* Timer */}
                            <div className="flex items-center gap-2 text-zinc-500">
                                <Clock className="w-5 h-5" />
                                <span className="font-mono text-lg font-bold text-zinc-800">{formatTime(elapsed)}</span>
                            </div>
                            {/* Progress */}
                            <div className="flex items-center gap-2 text-zinc-500">
                                <CheckCircle2 className="w-5 h-5" />
                                <span className="font-mono text-lg font-bold text-zinc-800">{progress}<span className="text-zinc-400 font-normal">/{totalItems}</span></span>
                            </div>
                        </div>
                    </div>

                    {/* ── Input ── */}
                    <div className="mt-6 relative">
                        <Type className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-zinc-300" />
                        <input
                            ref={inputRef}
                            type="text"
                            value={inputValue}
                            onChange={handleInput}
                            disabled={isComplete}
                            placeholder={isComplete ? 'All answers found! 🎉' : 'Start typing your answer…'}
                            autoComplete="off"
                            autoCapitalize="off"
                            spellCheck="false"
                            className="w-full pl-12 pr-4 py-4 bg-zinc-50 border-0 ring-1 ring-zinc-200 rounded-2xl text-lg focus:outline-none focus:ring-2 focus:ring-zinc-900 focus:bg-white transition-all placeholder:text-zinc-300 disabled:opacity-60"
                        />
                    </div>
                </div>

                {/* ── Completion banner ── */}
                {isComplete && (
                    <div className="bg-emerald-50 rounded-3xl p-6 md:p-8 ring-1 ring-emerald-200 mb-6 flex items-center gap-5 animate-[fadeIn_0.4s_ease-out]">
                        <div className="w-14 h-14 rounded-2xl bg-emerald-100 flex items-center justify-center shrink-0">
                            <Trophy className="w-7 h-7 text-emerald-600" />
                        </div>
                        <div>
                            <h2 className="text-xl font-extrabold text-emerald-900 tracking-tight">Quiz Complete!</h2>
                            <p className="text-emerald-700 text-sm mt-1">
                                You found all <strong>{totalItems}</strong> answers in <strong>{formatTime(elapsed)}</strong>
                            </p>
                        </div>
                    </div>
                )}

                {/* ── Progress bar ── */}
                <div className="mb-8">
                    <div className="h-1.5 bg-zinc-100 rounded-full overflow-hidden">
                        <div
                            className="h-full bg-zinc-900 rounded-full transition-all duration-500 ease-out"
                            style={{ width: `${totalItems ? (progress / totalItems) * 100 : 0}%` }}
                        />
                    </div>
                </div>

                {/* ── Groups grid ── */}
                <div className={`grid gap-4 ${displayColumns.length === 1 ? 'grid-cols-1' : displayColumns.length === 2 ? 'grid-cols-1 md:grid-cols-2' : 'grid-cols-1 md:grid-cols-2 xl:grid-cols-3'}`}>
                    {displayColumns.map((col, ci) => {
                        const { group, gi, items, startIdx, isChunk, chunkLabel } = col;
                        const colItemKeys = items.map((_, localIdx) => `${gi}-${startIdx + localIdx}`);
                        const colComplete = colItemKeys.every(k => found.has(k));
                        const colFound = colItemKeys.filter(k => found.has(k)).length;
                        const headerLabel = isChunk ? `${group.group_name} (${chunkLabel})` : group.group_name;

                        return (
                            <div
                                key={`${gi}-${startIdx}`}
                                className={`bg-white rounded-2xl shadow-[0_4px_20px_rgb(0,0,0,0.03)] ring-1 transition-all duration-300 ${colComplete ? 'ring-emerald-200 bg-emerald-50/30' : 'ring-zinc-900/5'}`}
                            >
                                {/* Column header */}
                                <div className="px-4 py-3 border-b border-zinc-100/80 flex items-center justify-between">
                                    <div className="flex items-center gap-2 min-w-0">
                                        {colComplete && <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" />}
                                        <h3 className={`font-bold text-sm tracking-tight truncate ${colComplete ? 'text-emerald-800' : 'text-zinc-900'}`}>
                                            {headerLabel}
                                        </h3>
                                    </div>
                                    <span className="text-xs font-medium text-zinc-400 shrink-0 ml-2">
                                        {colFound}/{items.length}
                                    </span>
                                </div>

                                {/* Items */}
                                <div className="divide-y divide-zinc-50">
                                    {items.map((item, localIdx) => {
                                        const realIdx = startIdx + localIdx;
                                        const key = `${gi}-${realIdx}`;
                                        const isFound = found.has(key);
                                        const isFlashing = justFound === key;

                                        return (
                                            <div
                                                key={realIdx}
                                                className={`flex items-center px-4 py-2.5 transition-all duration-300 ${isFlashing
                                                    ? 'bg-emerald-100 scale-[1.01]'
                                                    : isFound
                                                        ? 'bg-emerald-50/50'
                                                        : 'hover:bg-zinc-50/50'
                                                    }`}
                                            >
                                                <span className="text-[13px] text-zinc-500 w-2/5 shrink-0">{item.hint}</span>
                                                <span className={`text-[13px] font-medium flex-1 transition-all duration-300 ${isFound ? 'text-emerald-700' : 'text-transparent select-none'}`}>
                                                    {isFound ? item.answer : '•'.repeat(item.answer.length)}
                                                </span>
                                                <span className={`w-5 h-5 rounded-full flex items-center justify-center shrink-0 transition-all duration-300 ${isFlashing
                                                    ? 'bg-emerald-500 text-white scale-110'
                                                    : isFound
                                                        ? 'bg-emerald-100 text-emerald-600'
                                                        : 'bg-zinc-100'
                                                    }`}>
                                                    {isFound && <CheckCircle2 className="w-3 h-3" />}
                                                </span>
                                            </div>
                                        );
                                    })}
                                </div>
                            </div>
                        );
                    })}
                </div>
            </main>

            {/* Keyframe animation for completion banner */}
            <style>{`
        @keyframes fadeIn {
          from { opacity: 0; transform: translateY(-8px); }
          to { opacity: 1; transform: translateY(0); }
        }
      `}</style>
        </div>
    );
}
