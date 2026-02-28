import React, { useMemo } from 'react';
import { useParams, useNavigate, useLocation, Link } from 'react-router-dom';
import OrderSummary from '../components/OrderSummary';
import { useOrderDetailsData, useRefundOrder } from '../hooks/useOrders';
import useCourses from '../hooks/useCourses';

const PageSpinner = ({ message }) => <div className="mt-12 text-center text-slate-500 text-lg w-full">{message || 'Loading...'}</div>;

const ResultDisplay = ({ status, title, message }) => (
    <div className={`p-6 rounded-lg mt-8 max-w-2xl w-full mx-auto text-center border shadow-sm ${status === 'success' ? 'bg-green-50 text-green-800 border-green-200' : 'bg-red-50 text-red-800 border-red-200'}`}>
        <h3 className="text-xl font-bold mb-3">{title}</h3>
        <p className={`text-lg m-0 ${status === 'success' ? 'text-green-700' : 'text-red-700'}`}>{message}</p>
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
            <div className="max-w-4xl mx-auto w-full px-4 py-10 flex flex-col items-center">
                <PageSpinner message="Loading order details..." />
            </div>
        );
    }

    if (errorMessage) {
        return (
            <div className="max-w-4xl mx-auto w-full px-4 py-10 flex flex-col items-center">
                <div className="text-center p-4 bg-red-50 border border-red-200 text-red-600 rounded-md my-4 font-medium w-full">Error: {errorMessage}</div>
            </div>
        );
    }

    if (!displayOrder && !isLoading) {
        return (
            <div className="max-w-4xl mx-auto w-full px-4 py-10 flex flex-col items-center">
                <div className="text-center p-4 bg-red-50 border border-red-200 text-red-600 rounded-md my-4 font-medium w-full">Order details not found.</div>
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
        <div className="max-w-4xl mx-auto w-full px-4 md:px-8 py-10 md:py-12 min-h-screen flex flex-col items-center">
            <h1 className="text-3xl font-bold text-slate-800 mb-8 m-0">Order Details</h1>

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
                <div className="w-full flex justify-center mt-2">
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
                        <div className="mt-8 text-center w-full">
                            <button
                                onClick={handleRefund}
                                className="w-full sm:w-auto min-w-[240px] bg-red-500 hover:bg-red-600 text-white font-medium py-3 px-8 rounded-md transition-colors focus:ring-4 focus:ring-red-500/20 disabled:opacity-50"
                                disabled={isProcessingRefund}
                            >
                                {isProcessingRefund ? 'Processing Refund...' : 'Request Refund'}
                            </button>
                        </div>
                    )}
                </div>
            )}

            <button
                onClick={() => navigate('/orders')}
                className="w-full sm:max-w-xs bg-slate-500 hover:bg-slate-600 text-white font-medium py-3 px-8 rounded-md transition-colors mt-12 block mx-auto focus:ring-4 focus:ring-slate-500/20"
                disabled={isProcessingRefund}
            >
                Back to My Orders
            </button>
        </div>
    );
};

export default OrderDetailPage;