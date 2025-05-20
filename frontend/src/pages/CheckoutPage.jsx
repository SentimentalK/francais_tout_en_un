import React from 'react';
import { useNavigate, Link } from 'react-router-dom';
import useCheckout from '../hooks/useCheckout';
import CheckoutCourseItem from '../components/CheckoutCourseItem';
import '../assets/content.css';
import '../assets/checkout.css';

const PageSpinner = ({ message }) => <div className="checkout-page__spinner">{message || 'Loading...'}</div>;
const ErrorDisplay = ({ message }) => <div className="checkout-page__error-display">{message || 'An error occurred.'}</div>;

const CheckoutPage = () => {
    const {
        allCourses,
        isLoading,
        isError,
        error,
        selectedCourseIds,
        totalAmount,
        purchasableCoursesCount,
        toggleCourseSelection,
        selectAllPurchasable,
        deselectAll,
        handleSubmitOrder,
        isCreatingOrder,
        createOrderError,
    } = useCheckout();

    const navigate = useNavigate();

    const handleCancelAndGoHome = () => {
        navigate('/');
    };

    const noCoursesSelected = selectedCourseIds.size === 0;

    if (isLoading) {
        return <PageSpinner message="Loading courses and your purchase information..." />;
    }

    if (isError) {
        return <ErrorDisplay message={`Failed to load information: ${error?.message || 'Unknown error'}`} />;
    }

    return (
        <div className="course-container checkout-page-container">

            <div className='nav-container'
                style={{
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    margin: '0px'
                }}><Link to="/" >
                    <h1 style={{ margin: '0px' }}>Select Courses to Purchase</h1>
                </Link>
            </div>
            {allCourses.length === 0 && !isLoading && (
                <p className="checkout-page__no-courses">No courses available for purchase at the moment.</p>
            )}

            <div className="chapter checkout-page__course-list-container">
                {allCourses.map(course => (
                    <CheckoutCourseItem
                        key={course.course_id}
                        course={course}
                        onToggleSelect={toggleCourseSelection}
                    />
                ))}
            </div>

            <div className="checkout-page__actions-footer">
                <div className="checkout-page__selection-toggles">
                    {purchasableCoursesCount > 0 && (
                        <>
                            <button
                                onClick={selectAllPurchasable}
                                className="checkout-page__link-button"
                            >
                                Select All
                            </button>
                            <button
                                onClick={deselectAll}
                                className="checkout-page__link-button"
                            >
                                Deselect All
                            </button>
                        </>
                    )}
                </div>

                <div className="checkout-page__summary-and-action">
                    {!noCoursesSelected && (
                        <h2 className="checkout-page__total-amount-text">
                            Total: <span className="checkout-page__total-amount-value">${totalAmount.toFixed(2)}</span>
                        </h2>
                    )}
                    <button
                        onClick={noCoursesSelected ? handleCancelAndGoHome : handleSubmitOrder}
                        disabled={!noCoursesSelected && isCreatingOrder}
                        className={`purchase-btn ${noCoursesSelected ? 'checkout-page__cancel-btn' : 'checkout-page__proceed-btn'}`}
                    >
                        {noCoursesSelected
                            ? "Cancel"
                            : (isCreatingOrder ? 'Creating Order...' : "Proceed to Payment")
                        }
                    </button>
                </div>
            </div>

            {createOrderError && (
                <ErrorDisplay message={`Error creating order: ${createOrderError.message || 'Please try again later'}`} />
            )}
        </div>
    );
};

export default CheckoutPage;