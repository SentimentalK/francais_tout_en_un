import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { fetchUserInfo, loginUser as apiLoginUser, registerUser as apiRegisterUser } from '../api/users';

const TOKEN_KEY = 'access_token';

export default function useAuth() {
  const [user, setUser] = useState(null);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [isLoadingAuth, setIsLoadingAuth] = useState(true);
  const [token, setToken] = useState(() => localStorage.getItem(TOKEN_KEY));
  const navigate = useNavigate();

  const processTokenAndFetchUser = useCallback(async (receivedToken) => {
    localStorage.setItem(TOKEN_KEY, receivedToken);
    setToken(receivedToken);
    setIsLoadingAuth(true);
    try {
      const userInfo = await fetchUserInfo(receivedToken);
      setUser(userInfo);
      setIsLoggedIn(true);
      navigate('/');
    } catch (error) {
      console.error("处理Token并获取用户信息失败:", error);
      localStorage.removeItem(TOKEN_KEY);
      setToken(null);
      setUser(null);
      setIsLoggedIn(false);
      throw error;
    } finally {
      setIsLoadingAuth(false);
    }
  }, [navigate]);
  
  const attemptLoginWithToken = useCallback(async () => {
    const currentToken = localStorage.getItem(TOKEN_KEY);
    setToken(currentToken);
    if (currentToken) {
      try {
        const userInfo = await fetchUserInfo(currentToken);
        setUser(userInfo);
        setIsLoggedIn(true);
      } catch (error) {
        localStorage.removeItem(TOKEN_KEY);
        setToken(null);
        setUser(null);
        setIsLoggedIn(false);
      }
    } else {
      setUser(null);
      setIsLoggedIn(false);
    }
    setIsLoadingAuth(false);
  }, [navigate]);

  useEffect(() => {
    attemptLoginWithToken();
  }, [attemptLoginWithToken]);

  const handleLoginSuccess = useCallback(async (newToken) => {
    localStorage.setItem(TOKEN_KEY, newToken);
    setToken(newToken);
    setIsLoadingAuth(true);
    await attemptLoginWithToken();
    navigate('/');
  }, [attemptLoginWithToken]);

  const handleLogout = useCallback(() => {
    localStorage.removeItem(TOKEN_KEY);
    setToken(null);
    setUser(null);
    setIsLoggedIn(false);
  }, [navigate]);

  const login = useCallback(async (credentials) => {
    const newToken = await apiLoginUser(credentials);
    await processTokenAndFetchUser(newToken);
  }, [processTokenAndFetchUser]);

  const register = useCallback(async (userData) => {
    const newToken = await apiRegisterUser(userData);
    await processTokenAndFetchUser(newToken);
  }, [processTokenAndFetchUser]);

  return { user, isLoggedIn, isLoadingAuth, token,register, login, handleLoginSuccess, handleLogout, attemptLoginWithToken };
}