import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { ArrowLeft, ChevronLeft, ChevronRight } from 'lucide-react';

export default function ContentPageNav({ currentCourseId, maxCourseId = 100, onNotesClick, hasNotes = false, isNotesOpen = false }) {
    const navigate = useNavigate();
    const courseIdNum = parseInt(currentCourseId, 10);

    const getPrevChapter = (id) => {
        let prev = id - 1;
        if (prev > 0 && prev % 7 === 0) prev--;
        return prev > 0 ? prev : 1;
    };

    const getNextChapter = (id) => {
        let next = id + 1;
        if (next < maxCourseId && next % 7 === 0) next++;
        return next <= maxCourseId ? next : maxCourseId;
    };

    const prevChapterId = getPrevChapter(courseIdNum);
    const nextChapterId = getNextChapter(courseIdNum);

    return (
        <div className="flex items-center justify-between mb-8 text-zinc-500 text-sm font-medium">
            <Link to="/" className="flex items-center gap-2 hover:text-zinc-900 transition-colors no-underline">
                <ArrowLeft className="w-4 h-4" />
                Back to Overview
            </Link>

            <div className="flex items-center gap-2">
                {/* Notes 按钮 */}
                <button
                    onClick={onNotesClick}
                    disabled={!hasNotes}
                    className={`mr-4 flex items-center gap-2 px-4 py-2 rounded-full transition-colors font-semibold ${!hasNotes
                            ? 'bg-zinc-100 text-zinc-400 cursor-not-allowed'
                            : isNotesOpen
                                ? 'bg-red-50 text-red-600'
                                : 'bg-white border border-gray-200 text-gray-700 hover:bg-gray-100'
                        }`}
                >
                    <i className="ph-fill ph-book-open-text text-lg"></i>
                    Notes
                </button>

                {/* 左翻页 */}
                {courseIdNum > 1 ? (
                    <Link to={`/courses/${prevChapterId}`} className="w-8 h-8 rounded-full border border-zinc-200 flex items-center justify-center hover:bg-zinc-50 transition-colors text-zinc-400 hover:text-zinc-900">
                        <ChevronLeft className="w-4 h-4" />
                    </Link>
                ) : (
                    <span className="w-8 h-8 rounded-full border border-zinc-200 flex items-center justify-center text-zinc-200 cursor-not-allowed opacity-50">
                        <ChevronLeft className="w-4 h-4" />
                    </span>
                )}

                {/* 右翻页 */}
                {courseIdNum < maxCourseId ? (
                    <Link to={`/courses/${nextChapterId}`} className="w-8 h-8 rounded-full border border-zinc-200 flex items-center justify-center hover:bg-zinc-50 transition-colors text-zinc-400 hover:text-zinc-900">
                        <ChevronRight className="w-4 h-4" />
                    </Link>
                ) : (
                    <span className="w-8 h-8 rounded-full border border-zinc-200 flex items-center justify-center text-zinc-200 cursor-not-allowed opacity-50">
                        <ChevronRight className="w-4 h-4" />
                    </span>
                )}
            </div>
        </div>
    );
}