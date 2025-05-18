import { useMemo, useState } from 'react';
import useEntitlements from '../hooks/useEntitlements';
import useAuth from '../hooks/useAuth';
import useCourses from '../hooks/useCourses';
import NavBar from '../components/NavBar';
import SearchInput from '../components/SearchInput';
import CourseList from '../components/CourseList';
import '../assets/global.css';

export default function HomePage() {
  const [searchTerm, setSearchTerm] = useState('');
  const { user, isLoggedIn, token, handleLogout } = useAuth();

  const {
    data: coursesData,
    isLoading: isLoadingCourses,
    isError: isErrorCourses,
    error: errorCoursesMsg,
  } = useCourses();

  const {
    data: entitlementsData,
    isLoading: isLoadingEntitlements,
    isError: isErrorEntitlements,
    error: errorEntitlementsMsg,
  } = useEntitlements(token);

  const enrichedCourses = useMemo(() => {
    const baseCourses = Array.isArray(coursesData) ? coursesData : [];
    
    let purchasedCourseIds = new Set();
    if (isLoggedIn && Array.isArray(entitlementsData)) {
      entitlementsData.forEach(entitlement => {
        purchasedCourseIds.add(entitlement.course_id);
      });
    }

    return baseCourses.map(course => ({
      ...course, 
      purchased: purchasedCourseIds.has(course.course),
    }));
  }, [coursesData, entitlementsData, isLoggedIn]);

  const filteredCourses = useMemo(() => {
    if (!enrichedCourses) return [];
    return enrichedCourses.filter(meta => {
      const searchContent = `assimil french chapter ${meta.course} ${meta.free ? 'free' : ''} ${meta.purchased ? 'purchased' : ''}`.toLowerCase();
      return searchContent.includes(searchTerm.toLowerCase());
    });
  }, [enrichedCourses, searchTerm]);

  if (!coursesData) {
    return <div className="container message">Loading courses...</div>;
  }

  let displayErrorMessage = null;
  if (isErrorCourses) {
    displayErrorMessage = (errorCoursesMsg instanceof Error ? errorCoursesMsg.message : String(errorCoursesMsg)) || 'Failed to load courses.';
  } else if (isLoggedIn && isErrorEntitlements) {
    displayErrorMessage = (errorEntitlementsMsg instanceof Error ? errorEntitlementsMsg.message : String(errorEntitlementsMsg)) || 'Failed to load your entitlements.';
  }

  return (
    <div className="container">
      <NavBar user={user} isLoggedIn={isLoggedIn} onLogout={handleLogout} />
      <h1>Assimil French Course</h1>

      <div className="course-container">
        <SearchInput
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          placeholder="Search Courses (e.g. 'free', 'chapter 1')"
        />

        {displayErrorMessage ? (
          <p className="message">⚠️ {displayErrorMessage}</p>
        ) : (isLoadingCourses && !coursesData) || (isLoggedIn && isLoadingEntitlements && !entitlementsData) ? (
          <div className="message">Loading content...</div>
        ) : (
          <CourseList courses={filteredCourses} />
        )}
      </div>
    </div>
  );
}