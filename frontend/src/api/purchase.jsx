import apiClient from './service';

export const createOrder = async (courseIds) => {
  try {
    const res = await apiClient.post('/purchase/create', { course_ids: courseIds });
    return res.data;
  } catch (error) {
    console.error("Error creating order: ", error.config?.url, error.message);
    throw error;
  }
};

export const PaymentCallback = async ({ orderId, outcome }) => {
  const url = `/purchase/${orderId}/callback`;
  try {
    const { data } = await apiClient.post(url, { outcome: outcome });
    return data;
  } catch (error) {
    console.error("Error during paying the order: ", error.config?.url, error.message);
    throw error;
  }
};

export const fetchUserOrders = async () => {
  try {
    const res = await apiClient.get('/purchase/');
    if (Array.isArray(res.data)) {
        res.data.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
    }
    return res.data;
  } catch (error) {
    console.error("Error fetching user orders: ", error.config?.url, error.message);
    throw error;
  }
};

export const fetchOrderDetails = async (orderId) => {
  const url = `/purchase/${orderId}`;
  try {
    const res = await apiClient.get(url);
    return res.data;
  } catch (error) {
    console.error(`Error fetching order details for ${orderId}: `, error.config?.url, error.message);
    throw error;
  }
};

export const initiateRefund = async (orderId) => {
  const url = `/purchase/${orderId}/refund`;
  try {
    const res = await apiClient.post(url);
    return res.data;
  } catch (error) {
    console.error(`Error initiating refund for ${orderId}: `, error.config?.url, error.message);
    throw error;
  }
};