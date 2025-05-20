import React from 'react';

const PageSpinner = ({ message }) => <div className="checkout-page__spinner">{message || 'Processing...'}</div>;
const PaymentResultDisplay = ({ status, message, onRetryWithSuccess, onNavigateHome, onNavigateToCheckout, isProcessing }) => {
    if (status === 'processing') {
        return <div className="payment-result__spinner-container"><PageSpinner message={message} /></div>;
    }

    if (status === 'success') {
        return (
            <div className="payment-result__box payment-result__box--success">
                <h3>Payment Successful!</h3>
                <p>{message}</p>
                <button 
                    onClick={onNavigateHome} 
                    className="purchase-btn payment-result__btn--home"
                >
                    Go to Homepage
                </button>
            </div>
        );
    }

    if (status === 'failure') {
        return (
            <div className="payment-result__box payment-result__box--failure">
                <h3>Payment Failed</h3>
                <p>{message}</p>
                <p>This was a simulated failure. You can try again.</p>
                <div className="payment-result__actions">
                   <button
                        onClick={onRetryWithSuccess}
                        className="purchase-btn payment-result__btn--retry-success"
                        disabled={isProcessing}
                    >
                        Retry with Success
                    </button>
                     <button
                        onClick={onNavigateToCheckout}
                        className="purchase-btn payment-result__btn--to-checkout"
                    >
                        Back to Checkout
                    </button>
                </div>
            </div>
        );
    }
    return null; 
};

export default PaymentResultDisplay;