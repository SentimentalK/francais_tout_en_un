import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import HomePage from './pages/HomePage'
// import LoginPage from './pages/LoginPage'
// import CoursePage from './pages/CoursePage'

export default function App() {
  return (
    <Router>
      <div className="min-h-screen bg-gray-50">
        <Routes>
          <Route path="/" element={<HomePage />} />
          {/* <Route path="/login" element={<LoginPage />} /> */}
          {/* <Route path="/content/:lessonId" element={<CoursePage />} /> */}
          <Route path="*" element={<NotFound />} />
        </Routes>
      </div>
    </Router>
  )
}

function NotFound() {
  return (
    <div className="max-w-3xl mx-auto p-8 text-center">
      <h2 className="text-2xl font-semibold mb-4">404 - Page Not Found</h2>
      <p className="text-gray-600">The page you're looking for doesn't exist.</p>
    </div>
  )
}