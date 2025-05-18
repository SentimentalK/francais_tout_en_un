import CourseItem from './CourseItem';
import './CourseList.css';

export default function CourseList({ courses }) {
  if (!courses || courses.length === 0) {
    return null;
  }

  return (
    <div className='course-list-container'>
      <ul className='course-list'>
        {courses.map(course => (
          <CourseItem
            key={course.course}
            course_id={course.course}
            isFree={course.free}
            purchased={course.purchased}
          />
        ))}
      </ul>
    </div>
  );
}