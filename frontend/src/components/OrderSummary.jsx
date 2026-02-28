import React from 'react';

const OrderSummary = ({ orderId, amount, courses }) => {
    return (
        <div className="w-full max-w-2xl bg-white rounded-3xl p-8 md:p-10 shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-zinc-900/5 my-8 text-left">
            <h3 className="text-xl font-bold mb-6 text-zinc-900 border-b border-zinc-100 pb-4 m-0 tracking-tight">Order Summary</h3>
            <div className="space-y-4">
                <div className="flex justify-between items-center bg-zinc-50/50 p-4 rounded-xl ring-1 ring-zinc-100">
                    <span className="font-medium text-zinc-500 text-sm uppercase tracking-wider">Order Reference</span>
                    <span className="font-mono text-zinc-900 bg-white px-3 py-1 rounded-md ring-1 ring-zinc-900/5 shadow-sm text-sm">{orderId || "Pending"}</span>
                </div>

                <div className="flex justify-between items-center bg-zinc-50/50 p-4 rounded-xl ring-1 ring-zinc-100">
                    <span className="font-medium text-zinc-500 text-sm uppercase tracking-wider">Total Amount</span>
                    <span className="font-extrabold text-zinc-900 text-xl tracking-tight">${parseFloat(amount || 0).toFixed(2)}</span>
                </div>
            </div>

            <h4 className="mt-8 mb-4 font-semibold text-zinc-900 tracking-tight">Items in this order</h4>
            {courses && courses.length > 0 ? (
                <ul className="list-none p-0 m-0 border-t border-zinc-100 pt-4 space-y-3">
                    {courses.map(course => (
                        <li key={course.course_id} className="flex justify-between items-center py-2">
                            <span className="text-zinc-700 font-medium">{course.name || `Assimil French Course - Chapter ${course.course_id}`}</span>
                            <span className="text-zinc-500 font-mono">${parseFloat(course.price).toFixed(2)}</span>
                        </li>
                    ))}
                </ul>
            ) : (
                <p className="text-zinc-400 italic mt-4">Course details not available.</p>
            )}
        </div>
    );
};

export default OrderSummary;