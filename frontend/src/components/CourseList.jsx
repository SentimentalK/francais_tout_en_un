import CourseItem from './CourseItem';

export default function CourseList({ items }) {
  if (!items || items.length === 0) {
    return (
      <div className="w-full text-center py-12 text-zinc-400">
        No content available
      </div>
    );
  }

  return (
    <div id="generic-grid" className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 xl:gap-8 pb-10">
      {items.map(item => (
        <CourseItem
          key={item.id || item.course_id}
          item={item}
        />
      ))}
    </div>
  );
}