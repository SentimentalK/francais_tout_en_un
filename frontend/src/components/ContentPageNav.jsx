import React from 'react';
import { Link, useNavigate } from 'react-router-dom';

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
        <div className="nav-container" >
            {courseIdNum > 1 ? (
                <Link to={`/courses/${prevChapterId}`} >&lt;&lt;</Link>
            ) : (
                <span >&lt;&lt;</span>
            )}
            <Link to="/" > <h1> Assimil French Home </h1></Link>
            {courseIdNum <= maxCourseId ? (
                <Link to={`/courses/${nextChapterId}`} >&gt;&gt;</Link>
            ) : (
                <span >&gt;&gt;</span>
            )}
        </div>
    );
}