import React, { useState } from 'react';

export default function CourseSentenceItem({ sentence, courseId }) {
  const [expanded, setExpanded] = useState(false);
  const displaySeq = sentence.seq;

  const toggleExpanded = () => setExpanded(prev => !prev);

  const renderWithNotes = (text) => {
    if (!text) return null;
    const parts = text.split(/\^\^(.*?)\^\^/g);
    return parts.map((part, index) => {
      // split puts matched groups at odd indices
      if (index % 2 === 1) {
        return (
          <sup
            key={index}
            className="text-[#c92a2a] text-[0.55em] font-bold align-super leading-none mx-[0.15em] select-none cursor-pointer hover:underline"
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
      className="group bg-white rounded-2xl p-5 md:p-6 shadow-sm ring-1 ring-zinc-900/5 hover:shadow-[0_12px_30px_rgb(0,0,0,0.06)] hover:ring-zinc-900/10 transition-all duration-300 flex flex-col sm:flex-row gap-4 md:gap-6 items-start sm:items-center cursor-pointer"
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