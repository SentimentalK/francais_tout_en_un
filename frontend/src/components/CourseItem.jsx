import './CourseItem.css';

export default function CourseItem({ course, isFree }) {
  return (
    <li className="course-item">
      <a href={`/content/${course}`} className="course-link">
        <span className="course-title">Assimil French Chapter {course}</span>
        
        {isFree ? (
          <span className="tag free-tag">FREE</span>
        ) : (
          <span className="tag purchased-tag">PURCHASED</span>
        )}
        
      </a>
    </li>
  )
}