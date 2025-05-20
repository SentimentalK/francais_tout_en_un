import React from 'react';
import { Link } from 'react-router-dom'; 
import OrderListItem from '../components/OrderListItem';
import { useUserOrders } from '../hooks/useOrders';

const PageSpinner = ({ message }) => <div className="checkout-page__spinner">{message || 'Loading...'}</div>;

const OrdersPage = () => {
    const { data: orders, isLoading, isError, error } = useUserOrders();

    if (isLoading) {
        return <PageSpinner message="Fetching your orders..." />;
    }

    if (isError) {
        return <div className="checkout-page__error-display">Error fetching orders: {error?.message || 'Unknown error'}</div>;
    }

    return (
        <div className="course-container payment-page__container">
            <div className='nav-container'
                style={{
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    marginBottom: '0px'
                }}><Link to="/"><h1 style={{ margin: '0px' }}>My Orders</h1></Link>
            </div>
            {orders && orders.length === 0 ? (
                <p className="checkout-page__no-courses" style={{ textAlign: 'center', margin: '2rem 0' }}>You have no orders yet.</p>
            ) : (
                <div className="chapter checkout-page__course-list-container">
                    {orders?.map(order => (
                        <OrderListItem key={order.order_id} order={order} />
                    ))}
                </div>
            )}
        </div>
    );
};

export default OrdersPage;