import React from 'react';
import { Link } from 'react-router-dom';
import usePayment from '../hooks/usePayment';
import OrderSummary from '../components/OrderSummary';
import PaymentActionButtons from '../components/PaymentActionButtons';
import PaymentResultDisplay from '../components/PaymentResultDisplay';
import '../assets/content.css';
import '../assets/payment.css';

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
        <div className="course-container payment-page__container">
            <div className='nav-container'
                style={{
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    marginBottom: '0px'
                }}><Link to="/"><h1 style={{ margin: '0px' }}>Simulated Payment</h1></Link>
            </div>
            <p className="payment-page__simulation-notice">
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