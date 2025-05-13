import CourseItem from './CourseItem'
import './CourseList.css';

export default function CourseList({ courses }) {
  return (
    <div className='course-list-container'>
      <ul className='course-list'>
        {courses.map(course => (
          <CourseItem
            key={course.lesson}
            lesson={course.lesson}
            isFree={course.free}
          />
        ))}
      </ul></div>
  )
}