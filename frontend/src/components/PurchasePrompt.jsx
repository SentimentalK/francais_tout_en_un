import React from 'react';
import { Link } from 'react-router-dom';
import { Lock } from 'lucide-react';

export default function PurchasePrompt({ courseId, isLoggedIn }) {
    const purchasePath = isLoggedIn ? `/checkout?course=${courseId}` : `/login?redirect=/courses/${courseId}/content`;
    const buttonText = isLoggedIn ? 'Purchase Now!' : 'Login to Purchase';

    return (
        <div className="text-center py-12 px-6 bg-zinc-50 rounded-2xl border border-zinc-100 mt-8">
            <div className="w-14 h-14 bg-white rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-sm ring-1 ring-zinc-900/5">
                <Lock className="w-6 h-6 text-zinc-400" />
            </div>
            <h3 className="text-2xl font-extrabold mb-3 text-zinc-900 tracking-tight">This course needs to be purchased</h3>
            <p className="text-zinc-500 mb-8 max-w-md mx-auto">You have not purchased or do not have access to the premium content of Chapter {courseId}.</p>
            <Link
                to={purchasePath}
                className="inline-flex items-center justify-center bg-zinc-900 text-white px-8 py-3 rounded-xl text-sm font-medium transition-all hover:bg-zinc-800 hover:shadow-md hover:-translate-y-0.5"
            >
                {buttonText}
            </Link>
        </div>
    );
}