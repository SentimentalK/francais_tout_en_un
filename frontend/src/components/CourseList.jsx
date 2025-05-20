import CourseItem from './CourseItem';
import '../assets/CourseList.css';

export default function CourseList({ courses }) {
  if (!courses || courses.length === 0) {
    return null;
  }

  return (
    <div className='course-list-container'>
      <ul className='course-list'>
        {courses.map(course => (
          <CourseItem
            key={course.course_id}
            course_id={course.course_id}
            isFree={course.free}
            purchased={course.purchased}
          />
        ))}
      </ul>
    </div>
  );
}