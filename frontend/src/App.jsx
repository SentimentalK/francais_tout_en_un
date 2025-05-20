import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { useEffect } from 'react';
import HomePage from './pages/HomePage'
import LoginPage from './pages/LoginPage'
import CoursePage from './pages/CoursePage'
import CheckoutPage from './pages/CheckoutPage'
import PaymentPage from './pages/PaymentPage';
import OrdersPage from './pages/OrdersPage';
import OrderDetailPage from './pages/OrderDetailPage';
import { configureAxiosInterceptors } from './api/service';
import { useNavigate } from 'react-router-dom';

const AxiosInterceptorSetup = () => {
  const navigate = useNavigate();
  useEffect(() => {
    configureAxiosInterceptors(navigate);
  }, [navigate]);
  return null;
};

export default function App() {
  return (
    <Router>
      <AxiosInterceptorSetup />
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/courses/:courseId" element={<CoursePage />} />
        <Route path="/checkout" element={<CheckoutPage />} />
        <Route path="/payment/:orderId" element={<PaymentPage />} />
        <Route path="/orders" element={<OrdersPage />} />
        <Route path="/orders/:orderId" element={<OrderDetailPage />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </Router>
  )
}

function NotFound() {
  return (
    <div>
      <h2>404 - Page Not Found</h2>
      <p>The page you're looking for doesn't exist.</p>
    </div>
  )
}