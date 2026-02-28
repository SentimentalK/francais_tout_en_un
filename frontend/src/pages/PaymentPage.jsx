import React from 'react';
import { Link } from 'react-router-dom';
import usePayment from '../hooks/usePayment';
import OrderSummary from '../components/OrderSummary';
import PaymentActionButtons from '../components/PaymentActionButtons';
import PaymentResultDisplay from '../components/PaymentResultDisplay';


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
        <div className="max-w-4xl mx-auto w-full px-4 md:px-8 py-10 md:py-12 min-h-screen flex flex-col items-center">
            <div className='flex flex-col items-center mb-0'>
                <Link to="/" className="text-slate-800 hover:text-blue-600 transition-colors no-underline">
                    <h1 className="text-3xl font-bold m-0 text-center">Simulated Payment</h1>
                </Link>
            </div>
            <p className="text-sm text-slate-500 mb-8 mt-2 text-center">
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
        </div>
    );
};

export default PaymentPage;