import './NavBar.css';

export default function NavBar({ isLoggedIn, onLogout }) {
    return (
        <div className="nav-bar">
            <button
                className="auth-button"
                onClick={isLoggedIn ? onLogout : () => window.location.href = '/login'}
            >
                {isLoggedIn ? 'Logout' : 'Login'}
            </button>
        </div>
    )
}