import React from 'react';

const CheckoutCourseItem = ({ course, onToggleSelect }) => {
    const { course_id, name, price, isOwned, isSelectable, isSelected } = course;

    const displayStatus = isOwned 
        ? (price === 0.00 ? "Free" : "Purchased") 
        : `$${price.toFixed(2)}`;

    let itemClassName = "checkout-item";
    if (!isSelectable) {
        itemClassName += " checkout-item--disabled";
    } else if (isSelected) {
        itemClassName += " checkout-item--selected";
    }

    return (
        <div
            className={itemClassName}
            onClick={!isSelectable ? undefined : () => onToggleSelect(course_id)}
            role={isSelectable ? "button" : undefined}
            tabIndex={isSelectable ? 0 : undefined}
            onKeyDown={isSelectable ? (e) => { if (e.key === 'Enter' || e.key === ' ') onToggleSelect(course_id); } : undefined}
        >
            <div className="checkout-item__details">
                {isSelectable && (
                    <input
                        type="checkbox"
                        checked={isSelected}
                        onChange={() => onToggleSelect(course_id)}
                        onClick={(e) => e.stopPropagation()}
                        className="checkout-item__checkbox"
                        aria-label={`Select Course ${name || `ID ${course_id}`}`}
                        aria-checked={isSelected}
                    />
                )}
                <span className="verse-id checkout-item__course-id">Course {course_id}</span>
                <span className="checkout-item__name">{name || `Assimil French Chapter  ${course_id}`}</span>
            </div>
            <span
                className={`${isOwned && price !== 0.00 ? 'purchase-tag' : (price === 0.00 ? 'free-tag' : '')}`}
            >
                {displayStatus}
            </span>
        </div>
    );
};

export default CheckoutCourseItem;