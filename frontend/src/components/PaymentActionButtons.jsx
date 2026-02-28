import React from 'react';

const PaymentActionButtons = ({ onSimulateSuccess, onSimulateFailure, isProcessing }) => {
    return (
        <div className="w-full max-w-2xl px-2 mt-4">
            <p className="text-zinc-500 mb-8 font-medium text-center text-lg">Choose a simulated outcome to proceed:</p>
            <div className="flex flex-col sm:flex-row justify-center gap-4 items-center">
                <button
                    onClick={onSimulateSuccess}
                    className="w-full sm:w-auto min-w-full sm:min-w-[240px] bg-zinc-900 text-white py-3.5 px-6 rounded-xl font-semibold hover:bg-zinc-800 hover:-translate-y-0.5 hover:shadow-lg transition-all focus:ring-4 focus:ring-zinc-900/20 disabled:opacity-50"
                    disabled={isProcessing}
                >
                    Simulate Successful Payment
                </button>
                <button
                    onClick={onSimulateFailure}
                    className="w-full sm:w-auto min-w-full sm:min-w-[220px] bg-white ring-1 ring-rose-200 text-rose-600 py-3.5 px-6 rounded-xl font-semibold hover:bg-rose-50 hover:-translate-y-0.5 hover:shadow-sm transition-all focus:ring-4 focus:ring-rose-500/20 disabled:opacity-50"
                    disabled={isProcessing}
                >
                    Simulate Failed Payment
                </button>
            </div>
        </div>
    );
};

export default PaymentActionButtons;