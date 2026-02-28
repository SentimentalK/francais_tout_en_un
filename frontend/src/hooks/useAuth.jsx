import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQueryClient } from '@tanstack/react-query';
import { fetchUserInfo, loginUser as apiLoginUser, registerUser as apiRegisterUser } from '../api/users';

const TOKEN_KEY = 'access_token';

export default function useAuth() {
  const [user, setUser] = useState(null);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [token, setToken] = useState(() => localStorage.getItem(TOKEN_KEY));
  const navigate = useNavigate();
  const queryClient = useQueryClient();

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
  }, []);

  useEffect(() => {
    authenticateAndFetchUser();
  }, [authenticateAndFetchUser]);

  const handleLogout = useCallback(() => {
    localStorage.removeItem(TOKEN_KEY);
    setToken(null);
    setUser(null);
    setIsLoggedIn(false);
    queryClient.invalidateQueries({ queryKey: ['entitlements'] });
    queryClient.invalidateQueries({ queryKey: ['courses'] });
    queryClient.invalidateQueries({ queryKey: ['orders'] });
    navigate('/');
  }, [navigate, queryClient]);

  const login = useCallback(async (credentials) => {
    const newToken = await apiLoginUser(credentials);
    await authenticateAndFetchUser(newToken);
    queryClient.invalidateQueries({ queryKey: ['entitlements'] });
    queryClient.invalidateQueries({ queryKey: ['courses'] });
    queryClient.invalidateQueries({ queryKey: ['orders'] });
  }, [authenticateAndFetchUser, queryClient]);

  const register = useCallback(async (userData) => {
    const newToken = await apiRegisterUser(userData);
    await authenticateAndFetchUser(newToken);
    queryClient.invalidateQueries({ queryKey: ['entitlements'] });
    queryClient.invalidateQueries({ queryKey: ['courses'] });
    queryClient.invalidateQueries({ queryKey: ['orders'] });
  }, [authenticateAndFetchUser, queryClient]);

  return { user, isLoggedIn, token, register, login, handleLogout };
}