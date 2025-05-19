import apiClient from './service'

export async function fetchUserInfo() {
  try {
    const res = await apiClient.get('/user/info');
    return res.data;
  } catch (error) {
    console.error("Error fetching user_info: ",error.config?.url, error.message);
    throw error;
  }
}

export async function loginUser(credentials) {
  const url = '/user/login';
  try {
    const res = await apiClient.post(url, JSON.stringify(credentials));
    return res.data.access_token;
  } catch (error) {
    console.error("Error Login failed: ",error.config?.url, error.message);
    throw error;
  }
}

export async function registerUser(userData) {
  const url = '/user/register';
  const { confirm_password, terms, ...payload } = userData;
  try {
    const res = await apiClient.post(url, JSON.stringify(payload));
    return res.data.access_token;
  } catch (error) {
    console.error("Error Register failed: ",error.config?.url, error.message);
    throw error;
  }
}