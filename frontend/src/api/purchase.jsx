import apiClient from './service';

export const createOrder = async (courseIds) => {
    try {
        const res = await apiClient.post('/purchase/create', { course_ids: courseIds });
        return res.data;
      } catch (error) {
        console.error("Error create order: ",error.config?.url, error.message);
        throw error;
      }
};