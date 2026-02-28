import { useState, useEffect } from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import useAuth from '../hooks/useAuth';
import FormField from '../components/FormField';
import { Sparkles, ArrowLeft } from 'lucide-react';

const validationRules = {
  login: {
    username: value => value.trim().length >= 3 || 'Username must be at least 3 characters',
    // password: value => value.length >= 6 || 'Password must be at least 6 characters'
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

  const location = useLocation();

  useEffect(() => {
    if (location.state?.message) {
      setMessageFromRedirect(location.state.message);
      navigate(location.pathname, { replace: true, state: {} });
    }
  }, [location, navigate]);

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
    <div className="min-h-screen bg-zinc-50 flex flex-col justify-center px-4 py-12 sm:px-6 lg:px-8 font-sans relative">
      <Link to="/" className="absolute top-8 left-8 text-sm text-zinc-500 hover:text-zinc-900 flex items-center font-medium transition-colors py-2 px-3 rounded-lg hover:bg-zinc-100 no-underline cursor-pointer z-10 w-max">
        <ArrowLeft className="w-4 h-4 mr-2" />
        Back to site
      </Link>

      <div className="sm:mx-auto sm:w-full sm:max-w-md mb-8 flex flex-col items-center">
        <div className="w-12 h-12 bg-zinc-900 text-white rounded-xl flex items-center justify-center mb-4 shadow-md ring-1 ring-zinc-900/10">
          <Sparkles className="w-6 h-6" />
        </div>
        <h2 className="text-center text-3xl font-extrabold text-zinc-900 tracking-tight">
          Account Access
        </h2>
        <p className="mt-2 text-center text-sm text-zinc-500">
          Sign in or create an account to start your journey
        </p>
      </div>

      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-10 px-8 shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-zinc-900/5 sm:rounded-3xl">

          {messageFromRedirect && (
            <div className="bg-blue-50 border border-blue-200 text-blue-700 px-4 py-3 rounded-xl mb-6 text-sm">
              {messageFromRedirect}
            </div>
          )}

          {globalError && (
            <div className="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-xl mb-6 text-sm text-center font-medium">
              {globalError}
            </div>
          )}

          <div className="flex p-1 bg-zinc-100/80 rounded-xl mb-8">
            <button
              type="button"
              className={`flex-1 py-2.5 text-sm font-semibold rounded-lg transition-all duration-200 ${activeTab === 'login' ? 'bg-white text-zinc-900 shadow-sm ring-1 ring-zinc-900/5' : 'text-zinc-500 hover:text-zinc-700'}`}
              onClick={() => switchTab('login')}
            >
              Sign In
            </button>
            <button
              type="button"
              className={`flex-1 py-2.5 text-sm font-semibold rounded-lg transition-all duration-200 ${activeTab === 'register' ? 'bg-white text-zinc-900 shadow-sm ring-1 ring-zinc-900/5' : 'text-zinc-500 hover:text-zinc-700'}`}
              onClick={() => switchTab('register')}
            >
              Create Account
            </button>
          </div>

          <form onSubmit={handleSubmit} className="space-y-5">
            <FormField
              label="Username"
              type="text"
              name="username"
              value={formData.username}
              onChange={handleInputChange}
              error={errors.username}
              placeholder="Enter your username"
            />

            {activeTab === 'login' && (
              <FormField
                label="Password"
                type="password"
                name="password"
                value={formData.password}
                onChange={handleInputChange}
                error={errors.password}
                placeholder="Enter your password"
              />
            )}

            {activeTab === 'register' && (
              <>
                <FormField
                  label="Email Address"
                  type="email"
                  name="email"
                  value={formData.email}
                  onChange={handleInputChange}
                  error={errors.email}
                  placeholder="you@example.com"
                />
                <FormField
                  label="Create Password"
                  type="password"
                  name="password"
                  value={formData.password}
                  onChange={handleInputChange}
                  error={errors.password}
                  placeholder="At least 6 characters"
                />
                <FormField
                  label="Confirm Password"
                  type="password"
                  name="confirm_password"
                  value={formData.confirm_password}
                  onChange={handleInputChange}
                  error={errors.confirm_password}
                  placeholder="Repeat your password"
                />
                <div className="pt-2">
                  <label className="flex items-start group cursor-pointer">
                    <div className="flex items-center h-5">
                      <input
                        type="checkbox"
                        name="terms"
                        checked={formData.terms}
                        onChange={handleInputChange}
                        className="w-4 h-4 rounded text-zinc-900 bg-zinc-50 border-zinc-300 focus:ring-zinc-900 focus:ring-offset-0 transition-colors cursor-pointer"
                      />
                    </div>
                    <div className="ml-3 text-sm">
                      <span className="text-zinc-500 group-hover:text-zinc-700 transition-colors">
                        I agree to the <a href="#" className="font-medium text-zinc-900 underline underline-offset-2 hover:text-zinc-700 transition-colors">Terms of Service</a> and <a href="#" className="font-medium text-zinc-900 underline underline-offset-2 hover:text-zinc-700 transition-colors">Privacy Policy</a>
                      </span>
                    </div>
                  </label>
                  {errors.terms && (
                    <p className="mt-2 text-sm text-red-500">{errors.terms}</p>
                  )}
                </div>
              </>
            )}

            <button
              type="submit"
              disabled={isLoading || isSubmitting}
              className="w-full flex justify-center py-3 px-4 border border-transparent rounded-xl shadow-sm text-sm font-semibold text-white bg-zinc-900 hover:bg-zinc-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-zinc-900 transition-all disabled:opacity-50 disabled:cursor-not-allowed mt-4 hover:-translate-y-0.5 hover:shadow-md"
            >
              {isLoading || isSubmitting ? 'Processing...' : (activeTab === 'login' ? 'Sign In' : 'Create Account')}
            </button>
          </form>

        </div>
      </div>
    </div>
  );
}