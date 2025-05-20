import apiClient from './service';

export const createOrder = async (courseIds) => {
  try {
    const res = await apiClient.post('/purchase/create', { course_ids: courseIds });
    return res.data;
  } catch (error) {
    console.error("Error create order: ", error.config?.url, error.message);
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