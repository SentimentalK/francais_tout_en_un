import React from 'react';

export default function CourseSentenceItem({ sentence, courseId }) {
  const displaySeq = sentence.seq;

  return (
    <div className="group bg-white rounded-2xl p-5 md:p-6 shadow-sm ring-1 ring-zinc-900/5 hover:shadow-[0_12px_30px_rgb(0,0,0,0.06)] hover:ring-zinc-900/10 transition-all duration-300 flex flex-col sm:flex-row gap-4 md:gap-6 items-start sm:items-center cursor-pointer">
      <div className="w-10 h-10 shrink-0 rounded-full bg-white shadow-sm ring-1 ring-zinc-900/5 flex items-center justify-center text-zinc-400 font-mono text-xs">
        {displaySeq}
      </div>
      <div className="flex-1 w-full">
        <p className="text-lg md:text-xl font-bold text-zinc-900 tracking-tight group-hover:text-indigo-950 transition-colors m-0 leading-relaxed whitespace-pre-wrap">{sentence.french}</p>
        <div className="grid grid-rows-[0fr] opacity-0 group-hover:grid-rows-[1fr] group-hover:opacity-100 transition-all duration-300 ease-in-out mt-0 group-hover:mt-2">
          <p className="text-sm md:text-base font-medium text-zinc-500 overflow-hidden m-0 leading-relaxed whitespace-pre-wrap">{sentence.english}</p>
        </div>
      </div>
    </div>
  );
}