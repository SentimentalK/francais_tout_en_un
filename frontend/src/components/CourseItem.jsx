import { Link } from 'react-router-dom';
import './CourseItem.css';

export default function CourseItem({ course_id, isFree, purchased }) {
  return (
    <li className="course-item">
      <Link
        to={`/courses/${course_id}/`}
        state={{
          isFree: isFree,
          isPurchased: purchased
        }}
        className="course-link"
      >
        <span className="course-title"> {`Assimil French Chapter ${course_id}`} </span>
        {isFree && <span className="tag free-tag">FREE</span>}
        {!isFree && purchased && (
          <span className="tag purchased-tag">PURCHASED</span>
        )}
      </Link>
    </li>
  );
}