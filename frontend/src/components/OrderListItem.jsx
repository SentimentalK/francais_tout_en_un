import React from 'react';
import { useNavigate } from 'react-router-dom';

const OrderListItem = ({ order }) => {
    const navigate = useNavigate();
    const { order_id, amount, status, currency, refunded_at } = order;

    const handleItemClick = () => {
        navigate(`/orders/${order_id}`, { state: { order: order } });
    };

    let statusText = status ? status.charAt(0).toUpperCase() + status.slice(1).toLowerCase() : "Unknown";
    if (refunded_at) {
        statusText = "Refunded";
    }

    let itemClassName = "flex flex-col sm:flex-row sm:items-center justify-between p-4 my-3 bg-white border border-slate-200 rounded-lg transition-all duration-300 shadow-sm cursor-pointer hover:-translate-y-0.5 hover:shadow-md hover:border-blue-300";

    let statusClass = "font-medium text-sm px-3 py-1 rounded-md text-slate-600 bg-slate-100";

    if (refunded_at || status === 'REFUNDED') {
        itemClassName = "flex flex-col sm:flex-row sm:items-center justify-between p-4 my-3 bg-slate-50 border border-slate-200 rounded-lg opacity-80 cursor-pointer hover:bg-slate-100 transition-colors";
        statusClass = "font-medium text-sm px-3 py-1 rounded-md text-red-700 bg-red-100";
    } else if (status === 'PAID') {
        statusClass = "font-medium text-sm px-3 py-1 rounded-md text-green-700 bg-green-100";
    }

    return (
        <div
            className={itemClassName}
            onClick={handleItemClick}
            role="button"
            tabIndex={0}
            onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') handleItemClick(); }}
        >
            <div className="flex items-center mb-3 sm:mb-0">
                <span className="font-mono text-sm text-slate-500 w-48 sm:w-56 truncate mr-4">
                    Order ID: {order_id}
                </span>
            </div>
            <div className="flex items-center justify-between sm:justify-end gap-4 shrink-0 border-t sm:border-t-0 border-slate-100 pt-3 sm:pt-0 mt-1 sm:mt-0">
                <span className={statusClass}>
                    {statusText}
                </span>
                <span className="font-bold text-slate-800 min-w-[90px] text-right">
                    {currency || 'USD'} ${parseFloat(amount).toFixed(2)}
                </span>
            </div>
        </div>
    );
};

export default OrderListItem;