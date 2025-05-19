import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { fetchUserInfo, loginUser as apiLoginUser, registerUser as apiRegisterUser } from '../api/users';

const TOKEN_KEY = 'access_token';

export default function useAuth() {
  const [user, setUser] = useState(null);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [token, setToken] = useState(() => localStorage.getItem(TOKEN_KEY));
  const navigate = useNavigate();

  const authenticateAndFetchUser = useCallback(async (receivedToken) => {
    const tokenToUse = receivedToken || localStorage.getItem(TOKEN_KEY);
    if (!tokenToUse) {
      setUser(null);
      setIsLoggedIn(false);
      setToken(null);
      return;
    }
    localStorage.setItem(TOKEN_KEY, tokenToUse);
    setToken(tokenToUse);
    try {
      const userInfo = await fetchUserInfo();
      setUser(userInfo);
      setIsLoggedIn(true);
    } catch (error) {
      localStorage.removeItem(TOKEN_KEY);
      setToken(null);
      setUser(null);
      setIsLoggedIn(false);
      throw error;
    }
  }, [navigate]);
  
  useEffect(() => {
    authenticateAndFetchUser();
  }, [authenticateAndFetchUser]);

  const handleLogout = useCallback(() => {
    localStorage.removeItem(TOKEN_KEY);
    setToken(null);
    setUser(null);
    setIsLoggedIn(false);
    navigate('/');
  }, [navigate]);

  const login = useCallback(async (credentials) => {
    const newToken = await apiLoginUser(credentials);
    await authenticateAndFetchUser(newToken);
  }, [authenticateAndFetchUser]);

  const register = useCallback(async (userData) => {
    const newToken = await apiRegisterUser(userData);
    await authenticateAndFetchUser(newToken);
  }, [authenticateAndFetchUser]);

  return { user, isLoggedIn, token, register, login, handleLogout };
}