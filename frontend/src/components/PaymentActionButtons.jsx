import React from 'react';

const PaymentActionButtons = ({ onSimulateSuccess, onSimulateFailure, isProcessing }) => {
    return (
        <div className="w-full max-w-2xl px-4">
            <p className="text-slate-600 mb-6 font-medium">Please choose the outcome for this simulated payment:</p>
            <div className="flex flex-col sm:flex-row justify-center gap-4 items-center">
                <button
                    onClick={onSimulateSuccess}
                    className="w-full sm:w-auto min-w-full sm:min-w-[240px] bg-blue-600 text-white py-3 px-6 rounded-md font-medium hover:bg-blue-700 transition-colors focus:ring-4 focus:ring-blue-500/20 disabled:opacity-50"
                    disabled={isProcessing}
                >
                    Simulate Successful Payment
                </button>
                <button
                    onClick={onSimulateFailure}
                    className="w-full sm:w-auto min-w-full sm:min-w-[220px] bg-red-500 text-white py-3 px-6 rounded-md font-medium hover:bg-red-600 transition-colors focus:ring-4 focus:ring-red-500/20 disabled:opacity-50"
                    disabled={isProcessing}
                >
                    Simulate Failed Payment
                </button>
            </div>
        </div>
    );
};

export default PaymentActionButtons;