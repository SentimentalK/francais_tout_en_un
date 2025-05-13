import './CourseItem.css';

export default function CourseItem({ lesson, isFree }) {
  return (
    <li className="course-item">
      <a href={`/content/${lesson}`} className="course-link">
        <span className="course-title">Assimil French Chapter {lesson}</span>
        
        {isFree ? (
          <span className="tag free-tag">FREE</span>
        ) : (
          <span className="tag purchased-tag">PURCHASED</span>
        )}
        
      </a>
    </li>
  )
}