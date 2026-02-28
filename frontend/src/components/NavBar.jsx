import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import useAuth from '../hooks/useAuth';
import { Sparkles, LayoutDashboard, Settings, LogOut } from 'lucide-react';

export default function NavBar({ activeCategory, onCategoryChange }) {
  const { isLoggedIn, user, handleLogout } = useAuth();
  const navigate = useNavigate();

  return (
    <nav className="sticky top-0 z-30 bg-white/80 backdrop-blur-md border-b border-zinc-200/50 transition-all w-full">
      <div className="max-w-6xl mx-auto px-6 flex justify-between items-center h-16">

        {/* Logo & Main Nav */}
        <div className="flex items-center space-x-10 h-full">
          <Link to="/" className="font-extrabold text-xl tracking-tight text-zinc-900 flex items-center no-underline">
            <div className="w-8 h-8 bg-zinc-900 text-white rounded-lg flex items-center justify-center mr-2 shadow-md">
              <Sparkles className="w-4 h-4" />
            </div>
            Français Tout-en-Un
          </Link>

          {onCategoryChange && (
            <div className="hidden md:flex space-x-8 h-full">
              <button
                onClick={() => onCategoryChange('course')}
                className={`nav-btn relative h-full text-sm transition-colors duration-200 ${activeCategory === 'course' ? 'active' : 'text-zinc-500 hover:text-zinc-900'}`}
              >
                Discover Courses
              </button>
              <button
                onClick={() => onCategoryChange('quiz')}
                className={`nav-btn relative h-full text-sm transition-colors duration-200 ${activeCategory === 'quiz' ? 'active' : 'text-zinc-500 hover:text-zinc-900'}`}
              >
                Special Quizzes
              </button>
              <button
                onClick={() => onCategoryChange('book')}
                className={`nav-btn relative h-full text-sm transition-colors duration-200 ${activeCategory === 'book' ? 'active' : 'text-zinc-500 hover:text-zinc-900'}`}
              >
                Ext. Readings
              </button>
            </div>
          )}
        </div>

        {/* Right User Menu */}
        <div className="flex items-center h-full relative group cursor-pointer">
          {!isLoggedIn ? (
            <button
              onClick={() => navigate('/login')}
              className="bg-zinc-900 hover:bg-zinc-800 text-white font-medium py-1.5 px-5 rounded-full text-sm transition-colors shadow-sm"
            >
              Login
            </button>
          ) : (
            <>
              {/* Profile Avatar Trigger */}
              <div className="flex items-center space-x-3 bg-white px-3 py-1.5 rounded-full shadow-sm ring-1 ring-zinc-900/5 hover:shadow-md transition-all">
                <div className="w-7 h-7 bg-zinc-900 text-white rounded-full flex items-center justify-center font-bold text-xs">
                  {user?.username ? user.username.charAt(0).toUpperCase() : (user?.email ? user.email.charAt(0).toUpperCase() : 'M')}
                </div>
                <span className="text-sm font-medium text-zinc-700">{user?.username || user?.email?.split('@')[0]}</span>
              </div>

              {/* Dropdown Menu */}
              <div className="absolute right-0 top-14 w-56 bg-white rounded-2xl shadow-[0_8px_30px_rgb(0,0,0,0.08)] ring-1 ring-zinc-900/5 hidden group-hover:block transition-all pt-1 pb-2 z-50">
                <div className="px-4 py-3 border-b border-zinc-100 mb-1">
                  <p className="text-sm font-medium text-zinc-900 truncate">{user?.username || 'User'}</p>
                  <p className="text-xs text-zinc-500 truncate">{user?.email}</p>
                </div>
                <Link to="/orders" className="flex items-center px-4 py-2.5 text-sm text-zinc-600 hover:bg-zinc-50 hover:text-zinc-900 transition-colors no-underline">
                  <LayoutDashboard className="w-4 h-4 mr-3 text-zinc-400" /> My Orders
                </Link>
                <Link to="/checkout" className="flex items-center px-4 py-2.5 text-sm text-zinc-600 hover:bg-zinc-50 hover:text-zinc-900 transition-colors no-underline">
                  <Settings className="w-4 h-4 mr-3 text-zinc-400" /> Purchase Courses
                </Link>
                <div className="border-t border-zinc-100 my-1"></div>
                <button onClick={handleLogout} className="w-full text-left flex items-center px-4 py-2.5 text-sm text-red-600 hover:bg-red-50 transition-colors">
                  <LogOut className="w-4 h-4 mr-3 text-red-400" /> Logout
                </button>
              </div>
            </>
          )}
        </div>

      </div>
    </nav>
  );
}