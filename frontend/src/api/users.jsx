export async function fetchUserInfo(token) {
  const res = await fetch('/api/user/info', {
    headers: { 'Authorization': `Bearer ${token}`}
  });

  if (!res.ok) {
    if (res.status === 401 || res.status === 403) {
      const error = new Error('Authentication failed or forbidden.');
      error.status = res.status;
      throw error;
    }
    throw new Error('Failed to fetch user info.');
  }
  return res.json();
}

export async function loginUser(credentials) {
  const response = await fetch('/api/user/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(credentials),
  });
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.detail || 'Login failed. Please check your credentials.');
  }
  if (!data.access_token) {
    throw new Error('Login successful, but no access token received.');
  }
  return data.access_token;
}

export async function registerUser(userData) {
  const { confirm_password, terms, ...payload } = userData;
  const response = await fetch('/api/user/register', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.detail || 'Registration failed. Please try again.');
  }
  if (!data.access_token) {
    throw new Error('Registration successful, but no access token received.');
  }
  return data.access_token;
}