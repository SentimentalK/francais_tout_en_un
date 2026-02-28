import React from 'react';
import { Link } from 'react-router-dom';
import OrderListItem from '../components/OrderListItem';
import { useUserOrders } from '../hooks/useOrders';

const PageSpinner = ({ message }) => <div className="text-center text-slate-500 text-lg py-12">{message || 'Loading...'}</div>;

const OrdersPage = () => {
    const { data: orders, isLoading, isError, error } = useUserOrders();

    if (isLoading) {
        return <PageSpinner message="Fetching your orders..." />;
    }

    if (isError) {
        return <div className="text-center p-4 bg-red-50 border border-red-200 text-red-600 rounded-md mx-auto max-w-2xl my-4 font-medium">Error fetching orders: {error?.message || 'Unknown error'}</div>;
    }

    return (
        <div className="max-w-4xl mx-auto w-full px-4 md:px-8 py-8 min-h-screen flex flex-col">
            <div className='flex flex-col items-center mb-8'>
                <Link to="/" className="text-slate-800 hover:text-blue-600 transition-colors no-underline">
                    <h1 className="text-3xl font-bold m-0 text-center">My Orders</h1>
                </Link>
            </div>
            {orders && orders.length === 0 ? (
                <p className="text-center text-lg py-8 text-slate-500">You have no orders yet.</p>
            ) : (
                <div className="bg-white rounded-xl p-6 md:p-8 shadow-sm grow border border-slate-100">
                    {orders?.map(order => (
                        <OrderListItem key={order.order_id} order={order} />
                    ))}
                </div>
            )}
        </div>
    );
};

export default OrdersPage;