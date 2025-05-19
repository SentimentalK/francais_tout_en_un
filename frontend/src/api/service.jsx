import axios from 'axios';

const apiClient = axios.create({
  baseURL: '/api', 
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  }
});

export const configureAxiosInterceptors = (navigate) => {
  apiClient.interceptors.request.use(
    (config) => {
      const token = localStorage.getItem('access_token');
      if (token) {
        config.headers['Authorization'] = `Bearer ${token}`;
      }
      return config;
    },
    (error) => {
      return Promise.reject(error);
    }
  );

  apiClient.interceptors.response.use(
    (response) => {
      return response;
    },
    (error) => {
      console.error('API Error:', error.config?.url, error.response?.status, error.response?.data);

      if (error.response) {
        const { status, data } = error.response;

        if (status === 401) {
          localStorage.removeItem('access_token');

          if (window.location.pathname !== '/login' && navigate) {
            navigate('/login', {
              state: {
                message: data?.message || 'Token expired, please log in again.',
                from: window.location.pathname,
              },
              replace: true
            });
          }
        }
      } else if (error.request) {
        console.error('Network Error or No Response:', error.request);
      } else {
        console.error('Error setting up request:', error.message);
      }
      return Promise.reject(error);
    }
  );
};

export default apiClient;