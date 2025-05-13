import { useEffect, useState } from 'react';
import useAuth from '../hooks/useAuth';
import NavBar from '../components/NavBar';
import SearchInput from '../components/SearchInput';
import CourseList from '../components/CourseList';
import { fetchCourses } from '../api/courses';
import '../assets/global.css';

export default function HomePage() {
  const { isLoggedIn, handleLogout } = useAuth();
  const [courses, setCourses] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const loadData = async () => {
      try {
        const data = await fetchCourses();
        if (!data || data.length === 0) {
          throw new Error('No courses available');
        }
        setCourses(data);
      } catch (err) {
        setError(err.message || 'Failed to load courses'); // 确保有默认错误信息
      } finally {
        setLoading(false);
      }
    };
    loadData();
  }, []);

  const filteredCourses = courses.filter(course => {
    const searchContent = `assimil french chapter ${course.lesson} ${course.free ? 'free' : ''}`.toLowerCase();
    return searchContent.includes(searchTerm.toLowerCase());
  });

  return (
    <div className="container">
      <NavBar isLoggedIn={isLoggedIn} onLogout={handleLogout} />
      <h1>Assimil French Course</h1>

      <div className="course-container">
        <SearchInput
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          placeholder="Search Courses (e.g. 'free', 'chapter 1')"
        />

        {loading ? (
          <div className="message">Loading courses...</div>
        ) : error ? (
          <p className="message">⚠️ Course loading failed</p>
        ) : (
          <CourseList courses={filteredCourses} />
        )}
      </div>
    </div>
  );
}