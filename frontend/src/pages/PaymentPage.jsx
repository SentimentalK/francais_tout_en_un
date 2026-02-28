import React from 'react';
import { Link } from 'react-router-dom';
import usePayment from '../hooks/usePayment';
import OrderSummary from '../components/OrderSummary';
import PaymentActionButtons from '../components/PaymentActionButtons';
import PaymentResultDisplay from '../components/PaymentResultDisplay';
import NavBar from '../components/NavBar';
import { CreditCard } from 'lucide-react';

const PaymentPage = () => {
    const {
        orderId,
        orderDetails,
        paymentStatus,
        serverMessage,
        handlePaymentAttempt,
        isLoadingPayment,
        navigate,
    } = usePayment();

    return (
        <div className="min-h-screen bg-zinc-50 flex flex-col font-sans">
            <NavBar />

            <main className="max-w-4xl mx-auto w-full px-6 py-12 flex flex-col items-center flex-grow">
                <div className="mb-6 text-center flex flex-col items-center">
                    <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center mb-6 shadow-sm ring-1 ring-zinc-900/5">
                        <CreditCard className="w-8 h-8 text-zinc-800" />
                    </div>
                    <Link to="/" className="text-zinc-900 hover:text-zinc-600 transition-colors no-underline">
                        <h1 className="text-4xl font-extrabold m-0 tracking-tight text-center">Secure Payment</h1>
                    </Link>
                </div>
                <p className="text-base text-zinc-500 mb-8 mt-2 text-center max-w-lg">
                    This is a payment simulation environment. No real currency will be processed.
                </p>

                <OrderSummary
                    orderId={orderId}
                    amount={orderDetails.amount}
                    courses={orderDetails.courses}
                />

                {paymentStatus === 'pending' && (
                    <PaymentActionButtons
                        onSimulateSuccess={() => handlePaymentAttempt('success')}
                        onSimulateFailure={() => handlePaymentAttempt('failure')}
                        isProcessing={isLoadingPayment}
                    />
                )}

                <PaymentResultDisplay
                    status={paymentStatus}
                    message={serverMessage}
                    onRetryWithSuccess={() => handlePaymentAttempt('success')}
                    onNavigateHome={() => navigate('/')}
                    onNavigateToCheckout={() => navigate('/checkout')}
                    isProcessing={isLoadingPayment}
                />
            </main>
        </div>
    );
};

export default PaymentPage;