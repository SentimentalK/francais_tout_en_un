import React from 'react';

const CheckoutCourseItem = ({ course, onToggleSelect }) => {
    const { course_id, name, price, isOwned, isSelectable, isSelected } = course;

    const displayStatus = isOwned
        ? (price === 0.00 ? "Free" : "Purchased")
        : `$${price.toFixed(2)}`;

    let itemClassName = "flex items-center justify-between p-4 my-3 rounded-md transition-all duration-300 border-l-4";
    if (!isSelectable) {
        itemClassName += " bg-slate-50 border-slate-300 opacity-60 cursor-not-allowed";
    } else if (isSelected) {
        itemClassName += " border-fuchsia-500 bg-fuchsia-50 hover:bg-fuchsia-100 hover:-translate-y-0.5 hover:shadow-md cursor-pointer";
    } else {
        itemClassName += " bg-white border-blue-500 hover:-translate-y-0.5 hover:shadow-md hover:bg-slate-50 cursor-pointer shadow-sm";
    }

    let statusTagClass = "font-bold min-w-[100px] text-right shrink-0 ";
    if (isOwned && price !== 0.00) {
        statusTagClass += "text-sm font-medium py-1 px-3 rounded-md text-fuchsia-800 bg-fuchsia-800/10";
    } else if (price === 0.00) {
        statusTagClass += "text-sm font-medium py-1 px-3 rounded-md text-green-600 bg-green-500/10";
    } else {
        statusTagClass += "text-slate-700";
    }

    return (
        <div
            className={itemClassName}
            onClick={!isSelectable ? undefined : () => onToggleSelect(course_id)}
            role={isSelectable ? "button" : undefined}
            tabIndex={isSelectable ? 0 : undefined}
            onKeyDown={isSelectable ? (e) => { if (e.key === 'Enter' || e.key === ' ') onToggleSelect(course_id); } : undefined}
        >
            <div className="flex items-center grow px-2 md:px-4">
                {isSelectable && (
                    <input
                        type="checkbox"
                        checked={isSelected}
                        onChange={() => onToggleSelect(course_id)}
                        onClick={(e) => e.stopPropagation()}
                        className="mr-3 md:mr-6 w-5 h-5 cursor-pointer accent-blue-600 rounded text-blue-600 focus:ring-blue-500"
                        aria-label={`Select Course ${name || `ID ${course_id}`}`}
                        aria-checked={isSelected}
                    />
                )}
                <span className="min-w-[70px] font-mono text-sm text-slate-500">Course {course_id}</span>
                <span className="ml-2 md:ml-4 grow font-medium text-slate-800">{name || `Assimil French Chapter  ${course_id}`}</span>
            </div>
            <span className={statusTagClass}>
                {displayStatus}
            </span>
        </div>
    );
};

export default CheckoutCourseItem;