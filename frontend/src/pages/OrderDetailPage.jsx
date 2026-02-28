import React, { useMemo } from 'react';
import { useParams, useNavigate, useLocation, Link } from 'react-router-dom';
import OrderSummary from '../components/OrderSummary';
import { useOrderDetailsData, useRefundOrder } from '../hooks/useOrders';
import useCourses from '../hooks/useCourses';
import NavBar from '../components/NavBar';
import { FileText, ArrowLeft } from 'lucide-react';

const PageSpinner = ({ message }) => <div className="mt-12 text-center text-zinc-500 text-lg w-full">{message || 'Loading...'}</div>;

const ResultDisplay = ({ status, title, message }) => (
    <div className={`p-8 rounded-3xl mt-8 max-w-2xl w-full mx-auto text-center shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ${status === 'success' ? 'bg-emerald-50/50 text-emerald-800 ring-emerald-900/5' : 'bg-rose-50/50 text-rose-800 ring-rose-900/5'}`}>
        <h3 className="text-xl font-extrabold mb-3 tracking-tight">{title}</h3>
        <p className={`text-lg m-0 font-medium ${status === 'success' ? 'text-emerald-700' : 'text-rose-700'}`}>{message}</p>
    </div>
);

const OrderDetailPage = () => {
    const { orderId } = useParams();
    const navigate = useNavigate();
    const location = useLocation();

    const initialOrderDataFromState = location.state?.order;

    const {
        data: orderData,
        isLoading: isLoadingOrder,
        isError: isOrderError,
        error: orderErrorData,
    } = useOrderDetailsData(orderId);

    const {
        data: allCoursesData,
        isLoading: isLoadingAllCourses,
        isError: isAllCoursesError,
        error: allCoursesError,
    } = useCourses();

    const refundMutation = useRefundOrder();

    const coursesForSummary = useMemo(() => {
        const currentOrder = orderData || initialOrderDataFromState;
        if (!currentOrder?.course_ids || !allCoursesData) {
            return [];
        }
        const coursesMap = new Map(allCoursesData.map(course => [course.course_id, course]));

        return currentOrder.course_ids.map(id => {
            const courseDetail = coursesMap.get(id);
            return {
                course_id: id,
                name: courseDetail?.name || `Course ${id}`,
                price: courseDetail?.price !== undefined ? parseFloat(courseDetail.price).toFixed(2) : "N/A",

            };
        }).filter(Boolean);
    }, [orderData, initialOrderDataFromState, allCoursesData]);

    const displayOrder = orderData || initialOrderDataFromState;
    const isLoading = (isLoadingOrder && !initialOrderDataFromState) || isLoadingAllCourses;

    let errorMessage = null;
    if (isOrderError) errorMessage = orderErrorData?.message || "Failed to load order details.";
    if (isAllCoursesError) errorMessage = (errorMessage ? errorMessage + " " : "") + (allCoursesError?.message || "Failed to load course data.");

    if (isLoading) {
        return (
            <div className="min-h-screen bg-zinc-50 flex flex-col font-sans">
                <NavBar />
                <main className="max-w-4xl mx-auto w-full px-6 py-12 flex flex-col items-center flex-grow">
                    <PageSpinner message="Loading order receipt..." />
                </main>
            </div>
        );
    }

    if (errorMessage) {
        return (
            <div className="min-h-screen bg-zinc-50 flex flex-col font-sans">
                <NavBar />
                <main className="max-w-4xl mx-auto w-full px-6 py-12 flex flex-col items-center flex-grow">
                    <div className="text-center p-6 bg-rose-50 ring-1 ring-rose-200 text-rose-600 rounded-2xl my-4 font-semibold w-full shadow-sm">Error: {errorMessage}</div>
                </main>
            </div>
        );
    }

    if (!displayOrder && !isLoading) {
        return (
            <div className="min-h-screen bg-zinc-50 flex flex-col font-sans">
                <NavBar />
                <main className="max-w-4xl mx-auto w-full px-6 py-12 flex flex-col items-center flex-grow">
                    <div className="text-center p-6 bg-rose-50 ring-1 ring-rose-200 text-rose-600 rounded-2xl my-4 font-semibold w-full shadow-sm">Order details not found.</div>
                </main>
            </div>
        );
    }

    const finalOrderData = displayOrder;

    if (!finalOrderData) {
        return <PageSpinner message="Loading order details..." />;
    }

    const canRefund = finalOrderData.status === 'PAID' && !finalOrderData.refunded_at;
    const isProcessingRefund = refundMutation.isLoading;
    const refundSucceeded = refundMutation.isSuccess;
    const refundFailed = refundMutation.isError;
    const refundError = refundMutation.error;

    const handleRefund = () => {
        if (!finalOrderData || finalOrderData.status !== 'PAID' || finalOrderData.refunded_at) {
            alert('This order cannot be refunded or is already being processed.');
            return;
        }
        refundMutation.mutate(orderId, {
            onError: (err) => console.error("Refund failed on mutate call:", err),
        });
    };


    return (
        <div className="min-h-screen bg-zinc-50 flex flex-col font-sans">
            <NavBar />

            <main className="max-w-4xl mx-auto w-full px-6 py-12 flex flex-col items-center flex-grow">
                <div className="mb-6 text-center flex flex-col items-center w-full relative">
                    <button
                        onClick={() => navigate('/orders')}
                        className="absolute left-0 top-1/2 -translate-y-1/2 text-zinc-500 hover:text-zinc-900 transition-colors flex items-center gap-2 font-medium"
                    >
                        <ArrowLeft className="w-4 h-4" /> Back
                    </button>
                    <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center mb-6 shadow-sm ring-1 ring-zinc-900/5">
                        <FileText className="w-8 h-8 text-zinc-800" />
                    </div>
                    <h1 className="text-4xl font-extrabold m-0 tracking-tight text-center text-zinc-900">Receipt Details</h1>
                </div>

                <OrderSummary
                    orderId={finalOrderData.order_id}
                    amount={finalOrderData.amount}
                    courses={coursesForSummary}
                />

                {refundSucceeded && (
                    <ResultDisplay
                        status="success"
                        title="Refund Processed"
                        message={refundMutation.data?.message || "Your refund request has been processed successfully. The order status is updated."}
                    />
                )}
                {refundFailed && (
                    <ResultDisplay
                        status="failure"
                        title="Refund Failed"
                        message={refundError?.response?.data?.message || refundError?.message || "An error occurred while processing your refund."}
                    />
                )}

                {!isProcessingRefund && !refundSucceeded && !refundFailed && (
                    <div className="w-full flex justify-center mt-4">
                        {finalOrderData.refunded_at && (
                            <ResultDisplay
                                status="success"
                                title="Order Refunded"
                                message={`This order was refunded on ${new Date(finalOrderData.refunded_at).toLocaleDateString()}.`}
                            />
                        )}
                        {!finalOrderData.refunded_at && finalOrderData.status !== 'PAID' && (
                            <ResultDisplay
                                status="failure"
                                title="Cannot Refund"
                                message={`This order is in '${finalOrderData.status}' status and cannot be refunded.`}
                            />
                        )}
                        {canRefund && (
                            <div className="mt-8 text-center w-full max-w-2xl px-4">
                                <p className="text-zinc-500 mb-6 text-sm">If you are unsatisfied with your selection, you may request a refund.</p>
                                <button
                                    onClick={handleRefund}
                                    className="w-full sm:w-auto min-w-[240px] bg-white ring-1 ring-rose-200 text-rose-600 hover:bg-rose-50 font-semibold py-3.5 px-8 rounded-xl transition-all shadow-sm hover:shadow-md hover:-translate-y-0.5 focus:ring-4 focus:ring-rose-500/20 disabled:opacity-50"
                                    disabled={isProcessingRefund}
                                >
                                    {isProcessingRefund ? 'Processing...' : 'Request Refund'}
                                </button>
                            </div>
                        )}
                    </div>
                )}
            </main>
        </div>
    );
};

export default OrderDetailPage;