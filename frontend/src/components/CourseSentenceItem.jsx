import React, { useState } from 'react';

export default function CourseSentenceItem({ sentence, courseId, activeNote, setActiveNote, onNoteClick }) {
  const [expanded, setExpanded] = useState(false);
  const displaySeq = sentence.seq;

  const toggleExpanded = () => setExpanded(prev => !prev);

  // Check if any note in this sentence is active
  const hasActiveNote = () => {
    if (activeNote === null) return false;
    const regex = /\^\^(.*?)\^\^/g;
    let match;
    while ((match = regex.exec(sentence.french)) !== null) {
      if (parseInt(match[1], 10) === activeNote) return true;
    }
    while ((match = regex.exec(sentence.english)) !== null) {
      if (parseInt(match[1], 10) === activeNote) return true;
    }
    return false;
  };

  const isSentenceActive = hasActiveNote();

  const renderWithNotes = (text) => {
    if (!text) return null;
    const parts = text.split(/\^\^(.*?)\^\^/g);
    return parts.map((part, index) => {
      // split puts matched groups at odd indices
      if (index % 2 === 1) {
        const noteId = parseInt(part, 10);
        return (
          <sup
            key={index}
            onClick={(e) => {
              e.stopPropagation(); // prevent toggling expanded state
              if (onNoteClick) onNoteClick(noteId);
            }}
            className={`text-[0.55em] font-bold align-super leading-none mx-[0.15em] select-none cursor-pointer hover:underline px-1 py-0.5 rounded transition-colors ${activeNote === noteId ? 'bg-red-100 text-red-700' : 'text-[#c92a2a]'}`}
          >
            {part}
          </sup>
        );
      }
      return part;
    });
  };

  return (
    <div
      onClick={toggleExpanded}
      className={`group rounded-2xl p-5 md:p-6 transition-all duration-300 flex flex-col sm:flex-row gap-4 md:gap-6 items-start sm:items-center cursor-pointer ${isSentenceActive
          ? 'bg-red-50/30 border-red-300 shadow-md ring-1 ring-red-100'
          : 'bg-white shadow-sm ring-1 ring-zinc-900/5 hover:shadow-[0_12px_30px_rgb(0,0,0,0.06)] hover:ring-zinc-900/10'
        }`}
    >
      {/* Hide sequence number on mobile (sm breakpoint) */}
      <div className="hidden sm:flex w-10 h-10 shrink-0 rounded-full bg-white shadow-sm ring-1 ring-zinc-900/5 items-center justify-center text-zinc-400 font-mono text-xs">
        {displaySeq}
      </div>
      <div className="flex-1 w-full">
        <p className={`text-lg md:text-xl font-bold tracking-tight transition-colors m-0 leading-relaxed whitespace-pre-wrap ${expanded ? 'text-indigo-950' : 'text-zinc-900 group-hover:text-indigo-950'}`}>{renderWithNotes(sentence.french)}</p>
        <div className={`grid transition-all duration-300 ease-in-out mt-0 ${expanded ? 'grid-rows-[1fr] opacity-100 mt-2' : 'grid-rows-[0fr] opacity-0 group-hover:grid-rows-[1fr] group-hover:opacity-100 group-hover:mt-2'}`}>
          <p className="text-sm md:text-base font-medium text-zinc-500 overflow-hidden m-0 leading-relaxed whitespace-pre-wrap">{renderWithNotes(sentence.english)}</p>
        </div>
      </div>
    </div>
  );
}