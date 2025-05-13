import React, { createContext, useState, useEffect } from 'react';
export const AuthContext = createContext();
export function AuthProvider({ children }) {
    const [token, setToken] = useState(null);
    useEffect(() => {
        const saved = localStorage.getItem('token');
        if (saved) setToken(saved);
    }, []);
    const login = newToken => {
        localStorage.setItem('token', newToken);
        setToken(newToken);
    };
    const logout = () => {
        localStorage.removeItem('token');
        setToken(null);
    };
    return <AuthContext.Provider value={{ token, login, logout }}>{children}</AuthContext.Provider>;
}