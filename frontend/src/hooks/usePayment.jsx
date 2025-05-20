import { useState, useEffect, useMemo } from 'react';
import { useParams, useLocation, useNavigate } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { PaymentCallback } from '../api/purchase';

export default function usePaymentSimulation() {
    const { orderId } = useParams();
    const location = useLocation();
    const navigate = useNavigate();
    const queryClient = useQueryClient();

    const initialOrderDetails = useMemo(() => {
        return location.state || { amount: 0, courses: [], orderIdFromState: null };
    }, [location.state]);

    const [paymentStatus, setPaymentStatus] = useState('pending');
    const [serverMessage, setServerMessage] = useState('');

    useEffect(() => {
        if (!initialOrderDetails.orderIdFromState && orderId) {
            console.warn(`PaymentPage: Order details (amount, courses) missing from location state for orderId: ${orderId}. Display might be incomplete.`);
        }
    }, [initialOrderDetails, orderId]);

    const paymentMutation = useMutation({
        mutationFn: PaymentCallback,
        onSuccess: (data, variables) => {
            setPaymentStatus(variables.outcome);
            setServerMessage(data.message || (variables.outcome === 'success' ? 'Payment processed successfully!' : 'Payment process encountered an issue.'));
            
            if (variables.outcome === 'success') {
                queryClient.invalidateQueries({ queryKey: ['entitlements'] });
                queryClient.invalidateQueries({ queryKey: ['myEntitlements'] });
                queryClient.invalidateQueries({ queryKey: ['courses'] });
                queryClient.invalidateQueries({ queryKey: ['allCoursesWithPrice'] });
            }
        },
        onError: (error, variables) => {
            console.error("Payment simulation callback error:", error);
            setPaymentStatus('failure');
            setServerMessage(error.response?.data?.message || error.message || `An error occurred while simulating payment outcome: ${variables.outcome}.`);
        },
        onMutate: (variables) => {
            setPaymentStatus('processing');
            setServerMessage(`Processing simulated ${variables.outcome} payment...`);
        }
    });

    const handlePaymentAttempt = (outcome) => {
        if (!orderId) {
            setServerMessage("Order ID is missing. Cannot simulate payment.");
            setPaymentStatus('failure');
            return;
        }
        paymentMutation.mutate({ orderId, outcome });
    };

    return {
        orderId,
        orderDetails: initialOrderDetails,
        paymentStatus,
        serverMessage,
        handlePaymentAttempt,
        isLoadingPayment: paymentMutation.isLoading,
        navigate,
    };
}