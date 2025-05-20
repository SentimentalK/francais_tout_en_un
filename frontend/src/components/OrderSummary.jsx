import React from 'react';

const OrderSummary = ({ orderId, amount, courses }) => {
    return (
        <div className="chapter order-summary__card"> 
            <h3>Order Summary</h3>
            <p className="order-summary__list-item"><strong>Order ID:</strong> {orderId || "N/A"}</p>
            <p className="order-summary__list-item"><strong>Total Amount:</strong> ${parseFloat(amount || 0).toFixed(2)}</p>
            <h4>Courses in this order:</h4>
            {courses && courses.length > 0 ? (
                <ul className="order-summary__list">
                    {courses.map(course => (
                        <li key={course.course_id} className="order-summary__list-item">
                            {course.name || `Course ${course.course_id}`} (${parseFloat(course.price).toFixed(2)})
                        </li>
                    ))}
                </ul>
            ) : (
                <p>Course details not available.</p>
            )}
        </div>
    );
};

export default OrderSummary;