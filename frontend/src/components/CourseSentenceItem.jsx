import React from 'react';

export default function CourseSentenceItem({ sentence, courseId }) {
  const displaySeq = sentence.seq;

  return (
    <div className="verse" >
      <span className="verse-id" >
        §{displaySeq}
      </span>
      <div className="text-container" >
        <span className="french-text" >
          {sentence.french}
        </span>
        <span className="english-text" >
          {sentence.english}
        </span>
      </div>
    </div>
  );
}