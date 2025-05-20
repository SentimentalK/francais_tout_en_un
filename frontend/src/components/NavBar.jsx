import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import useAuth from '../hooks/useAuth';
import '../assets/NavBar.css';

export default function UserActionsMenu() {
  const { isLoggedIn, user, handleLogout } = useAuth();
  const navigate = useNavigate();

  if (!isLoggedIn) {
    return (
      <div className="user-actions-container logged-out">
        <button 
          onClick={() => navigate('/login')} 
          className="user-actions-trigger-button"
        >
          Login
        </button>
      </div>
    );
  }

  const triggerText = user?.username || user?.email || '账户';

  return (
    <div className="user-actions-container logged-in">
      <button className="user-actions-trigger-button">
        {triggerText}
      </button>
      <div className="user-actions-dropdown-menu">
        <Link to="/orders" className="user-actions-dropdown-item">
          My Orders
        </Link>
        <Link to="/checkout" className="user-actions-dropdown-item">
          Purchase
        </Link>
        <button onClick={handleLogout} className="user-actions-dropdown-item">
          Logout
        </button>
      </div>
    </div>
  );
}