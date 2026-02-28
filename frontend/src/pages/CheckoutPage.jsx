import React from 'react';
import { useNavigate, Link } from 'react-router-dom';
import useCheckout from '../hooks/useCheckout';
import CheckoutCourseItem from '../components/CheckoutCourseItem';
import { ShoppingCart, ArrowLeft, ArrowRight } from 'lucide-react';
import NavBar from '../components/NavBar';

const PageSpinner = ({ message }) => <div className="text-center text-zinc-500 text-lg py-12">{message || 'Loading courses and your purchase information...'}</div>;
const ErrorDisplay = ({ message }) => <div className="text-center p-4 bg-red-50 border border-red-200 text-red-600 rounded-xl mx-auto max-w-2xl my-4 font-medium">{message || 'An error occurred.'}</div>;

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

    return (
        <div className="min-h-screen bg-zinc-50 flex flex-col font-sans">
            <NavBar />

            <main className="max-w-4xl mx-auto w-full px-6 py-12 flex-grow">
                <div className="mb-10 text-center flex flex-col items-center">
                    <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center mb-6 shadow-sm ring-1 ring-zinc-900/5">
                        <ShoppingCart className="w-8 h-8 text-zinc-800" />
                    </div>
                    <h1 className="text-4xl font-extrabold m-0 tracking-tight text-zinc-900">Select Courses</h1>
                    <p className="text-zinc-500 mt-2 text-lg">Choose the materials you wish to add to your library.</p>
                </div>

                {isLoading && <PageSpinner />}
                {isError && <ErrorDisplay message={`Failed to load information: ${error?.message || 'Unknown error'}`} />}

                {!isLoading && !isError && (
                    <div className="bg-white rounded-3xl p-8 shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-zinc-900/5">

                        {allCourses.length === 0 ? (
                            <p className="text-center text-lg py-16 text-zinc-400">No courses available for purchase at the moment.</p>
                        ) : (
                            <div className="space-y-4">
                                {allCourses.map(course => (
                                    <CheckoutCourseItem
                                        key={course.course_id}
                                        course={course}
                                        onToggleSelect={toggleCourseSelection}
                                    />
                                ))}
                            </div>
                        )}

                        <div className="flex flex-col md:flex-row justify-between items-center mt-12 pt-8 border-t border-zinc-100 gap-6">
                            <div className="flex gap-4 w-full justify-center md:justify-start">
                                {purchasableCoursesCount > 0 && (
                                    <>
                                        <button
                                            onClick={selectAllPurchasable}
                                            className="px-4 py-2 rounded-xl text-sm font-semibold text-zinc-600 bg-zinc-100 hover:bg-zinc-200 hover:text-zinc-900 transition-colors"
                                        >
                                            Select All
                                        </button>
                                        <button
                                            onClick={deselectAll}
                                            className="px-4 py-2 rounded-xl text-sm font-semibold text-zinc-500 hover:text-zinc-800 transition-colors"
                                        >
                                            Clear All
                                        </button>
                                    </>
                                )}
                            </div>

                            <div className="flex flex-col md:flex-row items-center gap-6 w-full justify-end">
                                {!noCoursesSelected && (
                                    <div className="text-right">
                                        <p className="text-sm font-medium text-zinc-500 uppercase tracking-widest mb-1 m-0">Order Total</p>
                                        <h2 className="text-3xl text-zinc-900 font-extrabold m-0 tracking-tight">
                                            ${totalAmount.toFixed(2)}
                                        </h2>
                                    </div>
                                )}
                                <button
                                    onClick={noCoursesSelected ? handleCancelAndGoHome : handleSubmitOrder}
                                    disabled={!noCoursesSelected && isCreatingOrder}
                                    className={noCoursesSelected ?
                                        "w-full md:w-auto flex items-center justify-center bg-white ring-1 ring-zinc-200 text-zinc-600 py-3.5 px-8 rounded-xl font-semibold hover:bg-zinc-50 hover:text-zinc-900 transition-all cursor-pointer shadow-sm" :
                                        "w-full md:w-auto flex items-center justify-center bg-zinc-900 text-white py-3.5 px-8 rounded-xl font-semibold hover:bg-zinc-800 hover:-translate-y-0.5 hover:shadow-lg transition-all focus:ring-4 focus:ring-zinc-900/20 disabled:opacity-50"}
                                >
                                    {noCoursesSelected
                                        ? <>Cancel returning</>
                                        : (isCreatingOrder ? 'Processing...' : <>Proceed checkout <ArrowRight className="ml-2 w-4 h-4" /></>)
                                    }
                                </button>
                            </div>
                        </div>

                        {createOrderError && (
                            <ErrorDisplay message={`Error creating order: ${createOrderError.message || 'Please try again later'}`} />
                        )}
                    </div>
                )}
            </main>
        </div>
    );
};

export default CheckoutPage;