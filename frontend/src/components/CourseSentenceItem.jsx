import React from 'react';

export default function CourseSentenceItem({ sentence, courseId }) {
  const displaySeq = sentence.seq;

  return (
    <div className="p-4 md:p-5 rounded-2xl bg-zinc-50 border border-zinc-100 flex items-start gap-4 group hover:bg-white hover:shadow-sm hover:-translate-y-0.5 transition-all duration-300 relative overflow-hidden cursor-pointer">
      <div className="w-10 h-10 shrink-0 rounded-full bg-white shadow-sm ring-1 ring-zinc-900/5 flex items-center justify-center text-zinc-400 font-mono text-xs mt-0.5 relative z-20">
        {displaySeq}
      </div>
      <div className="pt-2 relative grow h-full min-h-[1.5rem]">
        {/* French Text (Original) */}
        <p className="font-medium text-zinc-900 whitespace-pre-wrap leading-relaxed m-0 text-base md:text-lg tracking-tight transition-opacity duration-300 group-hover:opacity-10 relative z-10 w-full block">
          {sentence.french}
        </p>

        {/* English Translation (Hover Reveal) */}
        <div className="absolute top-2 left-0 w-full h-full opacity-0 group-hover:opacity-100 transition-opacity duration-300 z-20 flex items-start mt-0">
          <p className="text-zinc-600 font-medium whitespace-pre-wrap leading-relaxed m-0 text-base md:text-lg tracking-tight bg-white/95 backdrop-blur-sm px-2 -mx-2 rounded-lg py-1 shadow-sm border border-zinc-100/50">
            {sentence.english}
          </p>
        </div>
      </div>
    </div>
  );
}