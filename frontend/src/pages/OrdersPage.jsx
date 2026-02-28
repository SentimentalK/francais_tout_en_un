import React from 'react';
import { Link } from 'react-router-dom';
import OrderListItem from '../components/OrderListItem';
import { useUserOrders } from '../hooks/useOrders';
import NavBar from '../components/NavBar';
import { ShoppingBag } from 'lucide-react';

const PageSpinner = ({ message }) => <div className="text-center text-zinc-500 text-lg py-12">{message || 'Fetching your orders...'}</div>;

const OrdersPage = () => {
    const { data: orders, isLoading, isError, error } = useUserOrders();

    return (
        <div className="min-h-screen bg-zinc-50 flex flex-col font-sans">
            <NavBar />

            <main className="max-w-4xl mx-auto w-full px-6 py-12 flex flex-col flex-grow">
                <div className="mb-10 text-center flex flex-col items-center">
                    <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center mb-6 shadow-sm ring-1 ring-zinc-900/5">
                        <ShoppingBag className="w-8 h-8 text-zinc-800" />
                    </div>
                    <Link to="/" className="text-zinc-900 hover:text-zinc-600 transition-colors no-underline">
                        <h1 className="text-4xl font-extrabold m-0 tracking-tight text-center">Order History</h1>
                    </Link>
                    <p className="text-zinc-500 mt-2 text-lg">Review your past purchases and access course content.</p>
                </div>

                {isLoading && <PageSpinner />}

                {isError && (
                    <div className="text-center p-4 bg-red-50 border border-red-200 text-red-600 rounded-xl mx-auto max-w-2xl my-4 font-medium">
                        Error fetching orders: {error?.message || 'Unknown error'}
                    </div>
                )}

                {!isLoading && !isError && orders && orders.length === 0 ? (
                    <div className="bg-white rounded-3xl p-12 shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-zinc-900/5 text-center">
                        <p className="text-xl text-zinc-400 font-medium">You have no orders yet.</p>
                    </div>
                ) : (!isLoading && !isError && (
                    <div className="bg-white rounded-3xl p-6 md:p-8 shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-zinc-900/5 grow border border-zinc-100 flex flex-col space-y-4">
                        {orders?.map(order => (
                            <OrderListItem key={order.order_id} order={order} />
                        ))}
                    </div>
                ))}
            </main>
        </div>
    );
};

export default OrdersPage;