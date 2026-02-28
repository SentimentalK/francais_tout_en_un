import React from 'react';
import { CheckCircle2, XCircle } from 'lucide-react';

const PageSpinner = ({ message }) => <div className="mt-12 text-center text-zinc-500 text-lg">{message || 'Processing...'}</div>;

const PaymentResultDisplay = ({ status, message, onRetryWithSuccess, onNavigateHome, onNavigateToCheckout, isProcessing }) => {
    if (status === 'processing') {
        return <PageSpinner message={message} />;
    }

    if (status === 'success') {
        return (
            <div className="bg-white border border-emerald-100 p-10 rounded-3xl mt-8 max-w-2xl w-full flex flex-col items-center mx-auto text-center shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-zinc-900/5">
                <div className="w-16 h-16 bg-emerald-50 rounded-2xl flex items-center justify-center mb-6 text-emerald-600">
                    <CheckCircle2 className="w-8 h-8" />
                </div>
                <h3 className="text-3xl font-extrabold mb-4 text-zinc-900 tracking-tight">Payment Successful!</h3>
                <p className="text-lg text-emerald-700 mb-2 font-medium">{message}</p>
                <button
                    onClick={onNavigateHome}
                    className="bg-zinc-900 hover:bg-zinc-800 hover:-translate-y-0.5 hover:shadow-lg text-white font-semibold mt-8 py-3.5 px-8 rounded-xl transition-all"
                >
                    Return to Homepage
                </button>
            </div>
        );
    }

    if (status === 'failure') {
        return (
            <div className="bg-white border border-rose-100 p-10 rounded-3xl mt-8 max-w-2xl w-full mx-auto text-center shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-zinc-900/5 flex flex-col items-center">
                <div className="w-16 h-16 bg-rose-50 rounded-2xl flex items-center justify-center mb-6 text-rose-600">
                    <XCircle className="w-8 h-8" />
                </div>
                <h3 className="text-3xl font-extrabold mb-4 text-zinc-900 tracking-tight">Payment Failed</h3>
                <p className="text-lg text-rose-700 mb-2 font-medium">{message}</p>
                <p className="text-zinc-500 mb-8 mt-2">This was a simulated failure. You can securely try again.</p>

                <div className="flex flex-col sm:flex-row justify-center gap-4 w-full px-4">
                    <button
                        onClick={onRetryWithSuccess}
                        className="w-full sm:w-auto flex-1 bg-zinc-900 hover:bg-zinc-800 hover:-translate-y-0.5 hover:shadow-lg text-white font-semibold py-3.5 px-6 rounded-xl transition-all disabled:opacity-50"
                        disabled={isProcessing}
                    >
                        Retry Successfully
                    </button>
                    <button
                        onClick={onNavigateToCheckout}
                        className="w-full sm:w-auto flex-1 bg-white ring-1 ring-zinc-200 text-zinc-700 hover:bg-zinc-50 hover-text-zinc-900 hover:-translate-y-0.5 hover:shadow-sm font-semibold py-3.5 px-6 rounded-xl transition-all"
                    >
                        Review Order
                    </button>
                </div>
            </div>
        );
    }
    return null;
};

export default PaymentResultDisplay;