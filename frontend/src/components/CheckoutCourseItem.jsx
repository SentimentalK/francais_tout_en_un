import React from 'react';

const CheckoutCourseItem = ({ course, onToggleSelect }) => {
    const { course_id, name, price, isOwned, isSelectable, isSelected } = course;

    const displayStatus = isOwned
        ? (price === 0.00 ? "Free" : "Purchased")
        : `$${price.toFixed(2)}`;

    let itemClassName = "flex items-center justify-between p-5 my-4 rounded-2xl transition-all duration-300 relative overflow-hidden group ";
    let checkboxClass = "mr-4 w-5 h-5 cursor-pointer accent-zinc-900 rounded text-zinc-900 focus:ring-zinc-900 focus:ring-offset-0 ";

    if (!isSelectable) {
        itemClassName += " bg-zinc-50 ring-1 ring-zinc-200/50 opacity-60 cursor-not-allowed";
        checkboxClass += " opacity-50";
    } else if (isSelected) {
        itemClassName += " bg-zinc-50/50 ring-2 ring-zinc-900 shadow-sm hover:shadow-md cursor-pointer hover:-translate-y-0.5";
    } else {
        itemClassName += " bg-white ring-1 ring-zinc-200 hover:-translate-y-0.5 hover:shadow-md hover:ring-zinc-300 cursor-pointer shadow-sm";
    }

    let statusTagClass = "font-bold min-w-[100px] text-right shrink-0 ";
    if (isOwned && price !== 0.00) {
        statusTagClass += "text-xs font-semibold py-1.5 px-3 rounded-full text-zinc-700 bg-zinc-100 ring-1 ring-zinc-900/5 z-10 relative bg-white/80 backdrop-blur-sm";
    } else if (price === 0.00) {
        statusTagClass += "text-xs font-semibold py-1.5 px-3 rounded-full text-emerald-700 bg-emerald-50 ring-1 ring-emerald-900/5 z-10 relative";
    } else {
        statusTagClass += "text-zinc-900 font-semibold tracking-tight text-lg z-10 relative";
    }

    return (
        <div
            className={itemClassName}
            onClick={!isSelectable ? undefined : () => onToggleSelect(course_id)}
            role={isSelectable ? "button" : undefined}
            tabIndex={isSelectable ? 0 : undefined}
            onKeyDown={isSelectable ? (e) => { if (e.key === 'Enter' || e.key === ' ') onToggleSelect(course_id); } : undefined}
        >
            <div className="flex items-center grow px-1 md:px-2 z-10 relative">
                {isSelectable && (
                    <input
                        type="checkbox"
                        checked={isSelected}
                        onChange={() => onToggleSelect(course_id)}
                        onClick={(e) => e.stopPropagation()}
                        className={checkboxClass}
                        aria-label={`Select Course ${name || `ID ${course_id}`}`}
                        aria-checked={isSelected}
                    />
                )}
                <div>
                    <span className="block font-mono text-xs text-zinc-400 mb-0.5 uppercase tracking-wider">Course {course_id}</span>
                    <span className="block font-semibold text-zinc-900 tracking-tight text-lg">{name || `Assimil French Chapter  ${course_id}`}</span>
                </div>
            </div>
            <span className={statusTagClass}>
                {displayStatus}
            </span>
        </div>
    );
};

export default CheckoutCourseItem;