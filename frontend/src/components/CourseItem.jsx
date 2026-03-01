import { Link } from 'react-router-dom';
import { BookOpen, BrainCircuit, PenTool, Library, BookMarked, ArrowRight } from 'lucide-react';

const iconMap = {
  BookOpen: BookOpen,
  BrainCircuit: BrainCircuit,
  PenTool: PenTool,
  Library: Library,
  BookMarked: BookMarked,
};

export default function CourseItem({ item }) {
  const IconComponent = iconMap[item.icon] || BookOpen;
  const isCourseLink = item.type === 'course';
  const isQuizLink = item.type === 'quiz';

  const linkTo = isCourseLink
    ? `/courses/${item.course_id}/`
    : isQuizLink
      ? `/quizzes/${item.quiz_id}`
      : '#';
  const linkState = isCourseLink
    ? { isFree: item.free, isPurchased: item.purchased }
    : {};

  return (
    <Link
      to={linkTo}
      state={linkState}
      className="bg-white rounded-3xl p-6 md:p-8 shadow-sm ring-1 ring-zinc-900/5 hover:shadow-[0_20px_40px_rgb(0,0,0,0.08)] hover:-translate-y-1 hover:ring-zinc-900/10 transition-all duration-300 cursor-pointer group flex flex-col justify-between h-full relative overflow-hidden no-underline"
    >
      {/* Minimalist decorative corner */}
      <div className={`absolute -right-6 -top-6 w-24 h-24 rounded-full ${item.bgColor} opacity-50 group-hover:scale-150 transition-transform duration-500 ease-out`}></div>

      <div className="relative z-10">
        <div className="flex justify-between items-start mb-6">
          <div className={`w-12 h-12 rounded-2xl ${item.bgColor} ${item.iconColor} flex items-center justify-center ring-1 ring-black/5`}>
            <IconComponent className="w-6 h-6" />
          </div>
          <span className="text-[11px] font-bold px-3 py-1.5 rounded-full bg-zinc-100 text-zinc-500 tracking-wider uppercase">
            {item.tag}
          </span>
        </div>
        <h3 className="text-xl font-bold text-zinc-900 group-hover:text-zinc-700 transition-colors tracking-tight leading-tight m-0">
          {item.title}
        </h3>
        <p className="text-sm text-zinc-500 mt-3 leading-relaxed line-clamp-2 m-0">
          {item.desc}
        </p>
      </div>

      <div className="relative z-10 mt-8 flex items-center justify-between">
        <div className="flex -space-x-2">
          <div className="w-7 h-7 rounded-full bg-zinc-100 ring-2 ring-white flex items-center justify-center text-[10px] text-zinc-400 font-medium z-20">A1</div>
          {item.free && <div className="h-7 px-2 rounded-full bg-zinc-100 ring-2 ring-white flex items-center justify-center text-[10px] text-zinc-400 font-medium z-10 w-max truncate">Preview</div>}
          {!item.free && item.purchased && <div className="h-7 px-2 rounded-full bg-zinc-100 ring-2 ring-white flex items-center justify-center text-[10px] text-fuchsia-600 font-medium z-10 w-max truncate">Purchased</div>}

        </div>
        <div className="w-8 h-8 rounded-full bg-zinc-50 flex items-center justify-center group-hover:bg-zinc-900 group-hover:text-white text-zinc-400 transition-colors shadow-sm">
          <ArrowRight className="w-4 h-4" />
        </div>
      </div>
    </Link>
  );
}