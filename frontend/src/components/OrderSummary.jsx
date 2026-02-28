import React from 'react';

const OrderSummary = ({ orderId, amount, courses }) => {
    return (
        <div className="w-full max-w-2xl bg-white rounded-xl p-6 shadow-sm border border-slate-100 my-8 text-left">
            <h3 className="text-xl font-bold mb-6 text-slate-800 border-b border-slate-100 pb-4 m-0">Order Summary</h3>
            <p className="mb-3 text-slate-700 flex justify-between">
                <span className="font-medium text-slate-500">Order ID:</span>
                <span className="font-mono">{orderId || "N/A"}</span>
            </p>
            <p className="mb-3 text-slate-700 flex justify-between text-lg">
                <span className="font-medium text-slate-500">Total Amount:</span>
                <span className="font-bold text-blue-600">${parseFloat(amount || 0).toFixed(2)}</span>
            </p>
            <h4 className="mt-8 mb-4 font-semibold text-slate-700">Courses in this order:</h4>
            {courses && courses.length > 0 ? (
                <ul className="list-none p-0 m-0 border-t border-slate-100 pt-4">
                    {courses.map(course => (
                        <li key={course.course_id} className="mb-2 text-slate-600 flex justify-between">
                            <span>{course.name || `Course ${course.course_id}`}</span>
                            <span>${parseFloat(course.price).toFixed(2)}</span>
                        </li>
                    ))}
                </ul>
            ) : (
                <p className="text-slate-500 italic">Course details not available.</p>
            )}
        </div>
    );
};

export default OrderSummary;