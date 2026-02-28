import React from 'react';
import { useNavigate, Link } from 'react-router-dom';
import useCheckout from '../hooks/useCheckout';
import CheckoutCourseItem from '../components/CheckoutCourseItem';

const PageSpinner = ({ message }) => <div className="text-center text-slate-500 text-lg py-12">{message || 'Loading...'}</div>;
const ErrorDisplay = ({ message }) => <div className="text-center p-4 bg-red-50 border border-red-200 text-red-600 rounded-md mx-auto max-w-2xl my-4 font-medium">{message || 'An error occurred.'}</div>;

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
        <div className="max-w-4xl mx-auto w-full px-4 md:px-8 py-8 min-h-screen flex flex-col">

            <div className='flex flex-col items-center mb-8'>
                <Link to="/" className="text-slate-800 hover:text-blue-600 transition-colors no-underline">
                    <h1 className="text-3xl font-bold m-0 text-center">Select Courses to Purchase</h1>
                </Link>
            </div>
            {allCourses.length === 0 && !isLoading && (
                <p className="text-center text-lg py-8 text-slate-500">No courses available for purchase at the moment.</p>
            )}

            <div className="bg-white rounded-xl p-6 md:p-8 shadow-sm grow border border-slate-100">
                {allCourses.map(course => (
                    <CheckoutCourseItem
                        key={course.course_id}
                        course={course}
                        onToggleSelect={toggleCourseSelection}
                    />
                ))}
            </div>

            <div className="flex flex-col sm:flex-row justify-between items-center mt-8 md:mt-10 pt-6 border-t border-slate-200">
                <div className="flex gap-6 mb-6 sm:mb-0 w-full sm:w-auto justify-center sm:justify-start">
                    {purchasableCoursesCount > 0 && (
                        <>
                            <button
                                onClick={selectAllPurchasable}
                                className="text-blue-600 hover:text-blue-800 font-medium transition-colors"
                            >
                                Select All
                            </button>
                            <button
                                onClick={deselectAll}
                                className="text-slate-500 hover:text-slate-800 transition-colors"
                            >
                                Deselect All
                            </button>
                        </>
                    )}
                </div>

                <div className="flex flex-col sm:flex-row items-center gap-4 w-full sm:w-auto justify-end">
                    {!noCoursesSelected && (
                        <h2 className="text-xl text-slate-700 m-0">
                            Total: <span className="text-blue-600 font-bold ml-2">${totalAmount.toFixed(2)}</span>
                        </h2>
                    )}
                    <button
                        onClick={noCoursesSelected ? handleCancelAndGoHome : handleSubmitOrder}
                        disabled={!noCoursesSelected && isCreatingOrder}
                        className={noCoursesSelected ?
                            "min-w-full sm:min-w-[120px] bg-slate-500 text-white py-3 px-6 rounded-md font-medium hover:bg-slate-600 transition-colors" :
                            "min-w-full sm:min-w-[200px] bg-blue-600 text-white py-3 px-6 rounded-md font-medium hover:bg-blue-700 transition-colors focus:ring-4 focus:ring-blue-500/20 disabled:opacity-50"}
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