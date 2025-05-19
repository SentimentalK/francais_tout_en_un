import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import useAuth from '../hooks/useAuth';
import FormField from '../components/FormField';
import '../assets/global.css';
import '../assets/login.css';

const validationRules = {
  login: {
    username: value => value.trim().length >= 3 || 'Username must be at least 3 characters',
    password: value => value.length >= 6 || 'Password must be at least 6 characters'
  },
  register: {
    username: value => {
      if (value.trim().length < 3) return 'Username must be at least 3 characters';
      if (!/^[a-zA-Z0-9_]+$/.test(value)) return 'Username can only contain letters, numbers and underscores';
      return true;
    },
    email: value => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value) || 'Invalid email address',
    password: value => value.length >= 6 || 'Password must be at least 6 characters',
    confirm_password: (value, data) =>
      value === data.password || 'Passwords do not match',
    terms: checked => checked || 'You must agree to the terms'
  }
};

export default function LoginPage() {
  const [activeTab, setActiveTab] = useState('login');
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    confirm_password: '',
    terms: false
  });
  const [errors, setErrors] = useState({});
  const [globalError, setGlobalError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const navigate = useNavigate();

  const { login, register } = useAuth();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [messageFromRedirect, setMessageFromRedirect] = useState('');

  useEffect(() => {
    if (location.state?.message) {
      setMessageFromRedirect(location.state.message);
      navigate(location.pathname, { replace: true, state: {} });
    }
  }, [location.state]);

  const handleInputChange = (e) => {
    const { name, value, type, checked } = e.target;
    const inputValue = type === 'checkbox' ? checked : value;

    setFormData(prev => ({
      ...prev,
      [name]: inputValue
    }));
    setGlobalError('');

    if (activeTab in validationRules && name in validationRules[activeTab]) {
      const rule = validationRules[activeTab][name];
      const result = rule(inputValue, formData);
      setErrors(prev => ({
        ...prev,
        [name]: result === true ? '' : result
      }));
    }
  };

  const validateForm = () => {
    const currentValidationRules = validationRules[activeTab];
    const newErrors = {};
    let isValid = true;

    Object.keys(currentValidationRules).forEach(field => {
      const value = formData[field];
      const rule = currentValidationRules[field];
      const result = rule(value, formData);

      if (result !== true) {
        newErrors[field] = result;
        isValid = false;
      } else {
        newErrors[field] = '';
      }
    });

    setErrors(newErrors);
    return isValid;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setGlobalError('');
    if (!validateForm()) return;

    setIsSubmitting(true);

    try {
      if (activeTab === 'login') {
        const credentials = {
          username: formData.username,
          password: formData.password
        };
        await login(credentials);
        const from = location.state?.from || '/';
        navigate(from, { replace: true });
      } else {
        await register(formData);
        navigate('/')
      }
    } catch (error) {
      console.error(`${activeTab} error:`, error);
      setGlobalError(error.message || `An unknown ${activeTab} error occurred.`);
    } finally {
      setIsSubmitting(false);
    }
  };

  const switchTab = (tabName) => {
    setActiveTab(tabName);
    setErrors({});
    setGlobalError('');
    setFormData({
      username: '', email: '', password: '', confirm_password: '', terms: false
    });
  };


  return (
    <div className="auth-container">
      <div className="close-btn" onClick={() => navigate('/')}>×</div>

      {globalError && (
        <div className="validation-message global-error-message">{globalError}</div>
      )}

      <div className="tab-controls">
        <button
          className={activeTab === 'login' ? 'active' : ''}
          onClick={() => switchTab('login')}
        >
          Login
        </button>
        <button
          className={activeTab === 'register' ? 'active' : ''}
          onClick={() => switchTab('register')}
        >
          Register
        </button>
      </div>

      <form onSubmit={handleSubmit}>
        <FormField
          label="Username:"
          type="text"
          name="username"
          value={formData.username}
          onChange={handleInputChange}
          error={errors.username}
        />

        {activeTab === 'login' && (
          <FormField
            label="Password:"
            type="password"
            name="password"
            value={formData.password}
            onChange={handleInputChange}
            error={errors.password}
          />
        )}

        {activeTab === 'register' && (
          <>
            <FormField
              label="Email:"
              type="email"
              name="email"
              value={formData.email}
              onChange={handleInputChange}
              error={errors.email}
            />
            <FormField
              label="Password:"
              type="password"
              name="password"
              value={formData.password}
              onChange={handleInputChange}
              error={errors.password}
            />
            <FormField
              label="Confirm password:"
              type="password"
              name="confirm_password"
              value={formData.confirm_password}
              onChange={handleInputChange}
              error={errors.confirm_password}
            />
            <div className="terms-group form-group">
              <label style={{ display: 'flex', alignItems: 'center', cursor: 'pointer' }}>
                <input
                  type="checkbox"
                  name="terms"
                  checked={formData.terms}
                  onChange={handleInputChange}
                  style={{ marginRight: '8px' }}
                />
                I agree to the Terms
              </label>
              {errors.terms && (
                <div className="error-message show" style={{ marginLeft: '0' }}>{errors.terms}</div>
              )}
            </div>
          </>
        )}
        <button type="submit" disabled={isLoading} className="submit-btn">
          {isLoading ? 'Processing...' : (activeTab === 'login' ? 'Login' : 'Register')}
        </button>
      </form>
    </div>
  );
}