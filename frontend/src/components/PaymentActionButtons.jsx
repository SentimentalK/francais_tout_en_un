import React from 'react';

const PaymentActionButtons = ({ onSimulateSuccess, onSimulateFailure, isProcessing }) => {
    return (
        <>
            <p>Please choose the outcome for this simulated payment:</p>
            <div className="payment-actions__button-group">
                <button
                    onClick={onSimulateSuccess}
                    className="purchase-btn payment-actions__btn--success"
                    disabled={isProcessing}
                >
                    Simulate Successful Payment
                </button>
                <button
                    onClick={onSimulateFailure}
                    className="purchase-btn payment-actions__btn--failure"
                    disabled={isProcessing}
                >
                    Simulate Failed Payment
                </button>
            </div>
        </>
    );
};

export default PaymentActionButtons;