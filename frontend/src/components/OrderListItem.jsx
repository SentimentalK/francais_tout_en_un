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

    let itemClassName = "flex flex-col sm:flex-row sm:items-center justify-between p-5 bg-white ring-1 ring-zinc-200 rounded-2xl transition-all duration-300 shadow-sm cursor-pointer hover:-translate-y-0.5 hover:shadow-md hover:ring-zinc-300";

    let statusClass = "font-semibold tracking-wide text-xs px-3 py-1.5 rounded-full text-zinc-700 bg-zinc-100 ring-1 ring-zinc-900/5";

    if (refunded_at || status === 'REFUNDED') {
        itemClassName = "flex flex-col sm:flex-row sm:items-center justify-between p-5 bg-zinc-50 ring-1 ring-zinc-200/60 rounded-2xl opacity-80 cursor-pointer hover:bg-zinc-100 transition-colors";
        statusClass = "font-semibold tracking-wide text-xs px-3 py-1.5 rounded-full text-rose-700 bg-rose-50 ring-1 ring-rose-900/5";
    } else if (status === 'PAID') {
        statusClass = "font-semibold tracking-wide text-xs px-3 py-1.5 rounded-full text-emerald-700 bg-emerald-50 ring-1 ring-emerald-900/5";
    }

    return (
        <div
            className={itemClassName}
            onClick={handleItemClick}
            role="button"
            tabIndex={0}
            onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') handleItemClick(); }}
        >
            <div className="flex flex-col mb-4 sm:mb-0">
                <span className="text-xs font-semibold text-zinc-400 uppercase tracking-widest mb-1">
                    Order Ref
                </span>
                <span className="font-mono text-sm text-zinc-900 w-48 sm:w-auto truncate mr-4 font-medium">
                    {order_id}
                </span>
            </div>
            <div className="flex items-center justify-between sm:justify-end gap-6 shrink-0 border-t sm:border-t-0 border-zinc-100 pt-4 sm:pt-0">
                <span className={statusClass}>
                    {statusText}
                </span>
                <span className="font-extrabold text-lg text-zinc-900 tracking-tight min-w-[90px] text-right">
                    ${parseFloat(amount).toFixed(2)} {(currency || 'USD')}
                </span>
            </div>
        </div>
    );
};

export default OrderListItem;