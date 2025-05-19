import React from 'react';
import { Link } from 'react-router-dom';

export default function PurchasePrompt({ courseId, isLoggedIn }) {
    const purchasePath = isLoggedIn ? `/checkout?course=${courseId}` : `/login?redirect=/courses/${courseId}/content`;
    const buttonText = isLoggedIn ? 'Purchase Now!' : 'Login to Purchase';

    return (
        <div id="purchase-prompt" >
            <h3 >This course needs to be purchased before viewing</h3>
            <p>You have not purchased or do not have access to the content of Chapter {courseId}.</p>
            <Link
                to={purchasePath}
                className="purchase-btn"
            >
                {buttonText}
            </Link>
        </div>
    );
}