import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { ArrowLeft, ChevronLeft, ChevronRight } from 'lucide-react';

export default function ContentPageNav({ currentCourseId, maxCourseId = 100 }) {
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
        <div className="flex justify-between items-center mb-8">
            <Link to="/" className="text-sm text-zinc-500 hover:text-zinc-900 flex items-center font-medium transition-colors py-2 px-3 rounded-lg hover:bg-zinc-100 -ml-3 no-underline">
                <ArrowLeft className="w-4 h-4 mr-2" />
                Back to Overview
            </Link>

            <div className="flex space-x-2">
                {courseIdNum > 1 ? (
                    <Link to={`/courses/${prevChapterId}`} className="w-9 h-9 flex items-center justify-center rounded-lg text-zinc-600 hover:bg-zinc-100 transition-colors">
                        <ChevronLeft className="w-5 h-5" />
                    </Link>
                ) : (
                    <span className="w-9 h-9 flex items-center justify-center rounded-lg text-zinc-300">
                        <ChevronLeft className="w-5 h-5" />
                    </span>
                )}

                {courseIdNum <= maxCourseId ? (
                    <Link to={`/courses/${nextChapterId}`} className="w-9 h-9 flex items-center justify-center rounded-lg text-zinc-600 hover:bg-zinc-100 transition-colors">
                        <ChevronRight className="w-5 h-5" />
                    </Link>
                ) : (
                    <span className="w-9 h-9 flex items-center justify-center rounded-lg text-zinc-300">
                        <ChevronRight className="w-5 h-5" />
                    </span>
                )}
            </div>
        </div>
    );
}