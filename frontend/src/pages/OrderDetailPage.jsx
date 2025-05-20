import React, { useMemo } from 'react';
import { useParams, useNavigate, useLocation, Link } from 'react-router-dom';
import OrderSummary from '../components/OrderSummary';
import { useOrderDetailsData, useRefundOrder } from '../hooks/useOrders';
import useCourses from '../hooks/useCourses';

const PageSpinner = ({ message }) => <div className="checkout-page__spinner">{message || 'Loading...'}</div>;

const ResultDisplay = ({ status, title, message }) => (
    <div className={`payment-result__box payment-result__box--${status === 'success' ? 'success' : 'failure'}`} style={{ marginTop: '1.5rem' }}>
        <h3>{title}</h3>
        <p>{message}</p>
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
        return <PageSpinner message="Loading order details..." />;
    }
    
    if (errorMessage) {
        return <div className="checkout-page__error-display">Error: {errorMessage}</div>;
    }

    if (!displayOrder && !isLoading) {
      return <div className="checkout-page__error-display">Order details not found.</div>;
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
        <div className="course-container payment-page__container">
            <h1>Order Details</h1>
            
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
                    onNavigateLabel="Back to Orders"
                    onNavigateAction={() => navigate('/orders')}
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
                <>
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
                        <div style={{ marginTop: '2rem', textAlign: 'center' }}>
                            <button
                                onClick={handleRefund}
                                className="purchase-btn payment-actions__btn--failure"
                                disabled={isProcessingRefund}
                                style={{minWidth: '200px'}}
                            >
                                {isProcessingRefund ? 'Processing Refund...' : 'Request Refund'}
                            </button>
                        </div>
                    )}
                </>
            )}
             <button 
                onClick={() => navigate('/orders')} 
                className="purchase-btn" 
                style={{backgroundColor: '#7f8c8d', marginTop: '1rem', display: 'block', marginLeft: 'auto', marginRight: 'auto'}}
                disabled={isProcessingRefund}
            >
                Back to My Orders
            </button>
        </div>
    );
};

export default OrderDetailPage;