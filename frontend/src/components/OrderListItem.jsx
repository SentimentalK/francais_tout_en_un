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

    let itemClassName = "checkout-item"; 
    if (refunded_at || status === 'REFUNDED') {
        itemClassName += " checkout-item--disabled"; 
    }

    return (
        <div
            className={itemClassName}
            onClick={handleItemClick}
            role="button"
            tabIndex={0}
            onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') handleItemClick(); }}
            style={{ cursor: 'pointer' }}
        >
            <div className="checkout-item__details">
                <span 
                    className="verse-id checkout-item__course-id" 
                    style={{ 
                        minWidth: '200px', 
                        overflow: 'hidden', 
                        textOverflow: 'ellipsis', 
                        whiteSpace: 'nowrap',
                        marginRight: '1rem' 
                    }}
                >
                    Order ID: {order_id}
                </span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', flexShrink: 0 }}>
                <span 
                    className="checkout-item__status" 
                    style={{ minWidth: '80px', marginRight: '1rem', textTransform: 'capitalize', textAlign: 'right' }}
                >
                    {statusText}
                </span>
                <span 
                    className="checkout-item__status" 
                    style={{ fontWeight: 'bold', minWidth: '90px', textAlign: 'right' }}
                >
                    {currency || 'USD'} ${parseFloat(amount).toFixed(2)}
                </span>
            </div>
        </div>
    );
};

export default OrderListItem;