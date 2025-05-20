import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { fetchUserOrders, fetchOrderDetails, initiateRefund } from '../api/purchase';
import useAuth from './useAuth';

export function useUserOrders() {
  const { isLoggedIn } = useAuth();
  return useQuery({
    queryKey: ['userOrders'],
    queryFn: fetchUserOrders,
    enabled: isLoggedIn,
    staleTime: 5 * 60 * 1000,
  });
}

export function useOrderDetailsData(orderId) {
    const { isLoggedIn } = useAuth();
    return useQuery({
      queryKey: ['orderDetails', orderId],
      queryFn: () => fetchOrderDetails(orderId), 
      enabled: !!orderId && isLoggedIn,
      staleTime: 5 * 60 * 1000,
    });
  }

export function useRefundOrder() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (orderId) => initiateRefund(orderId),
    onSuccess: (data, orderId) => {
      queryClient.invalidateQueries({ queryKey: ['userOrders'] });
      queryClient.invalidateQueries({ queryKey: ['orderDetails', orderId] });
    },
  });
}