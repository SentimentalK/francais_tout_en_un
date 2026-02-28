import React from 'react';

const PageSpinner = ({ message }) => <div className="mt-12 text-center text-slate-500 text-lg">{message || 'Processing...'}</div>;

const PaymentResultDisplay = ({ status, message, onRetryWithSuccess, onNavigateHome, onNavigateToCheckout, isProcessing }) => {
    if (status === 'processing') {
        return <PageSpinner message={message} />;
    }

    if (status === 'success') {
        return (
            <div className="bg-green-50 text-green-800 border border-green-200 p-8 rounded-xl mt-8 max-w-2xl w-full flex flex-col items-center mx-auto text-center shadow-sm">
                <h3 className="text-2xl font-bold mb-4">Payment Successful!</h3>
                <p className="text-lg text-green-700 mb-2">{message}</p>
                <button
                    onClick={onNavigateHome}
                    className="bg-blue-600 hover:bg-blue-700 text-white font-medium mt-8 py-3 px-8 rounded-md transition-colors"
                >
                    Go to Homepage
                </button>
            </div>
        );
    }

    if (status === 'failure') {
        return (
            <div className="bg-red-50 text-red-800 border border-red-200 p-8 rounded-xl mt-8 max-w-2xl w-full mx-auto text-center shadow-sm">
                <h3 className="text-2xl font-bold mb-4">Payment Failed</h3>
                <p className="text-lg text-red-700 mb-2">{message}</p>
                <p className="text-red-500 mb-8 font-medium">This was a simulated failure. You can try again.</p>
                <div className="flex flex-col sm:flex-row justify-center gap-4 items-center">
                    <button
                        onClick={onRetryWithSuccess}
                        className="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-8 rounded-md transition-colors focus:ring-4 focus:ring-blue-500/20 disabled:opacity-50"
                        disabled={isProcessing}
                    >
                        Retry with Success
                    </button>
                    <button
                        onClick={onNavigateToCheckout}
                        className="w-full sm:w-auto bg-slate-500 hover:bg-slate-600 text-white font-medium py-3 px-8 rounded-md transition-colors focus:ring-4 focus:ring-slate-500/20"
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