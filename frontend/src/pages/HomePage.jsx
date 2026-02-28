import { useMemo, useState } from 'react';
import useEntitlements from '../hooks/useEntitlements';
import useAuth from '../hooks/useAuth';
import useCourses from '../hooks/useCourses';
import NavBar from '../components/NavBar';
import CourseList from '../components/CourseList';
import { Search } from 'lucide-react';

const mockDatabase = [
  { id: 3, type: 'quiz', tag: 'Vocabulary', title: 'Jetpunk Core 100 Words', desc: '5-minute timed unordered dictation to challenge muscle memory.', icon: 'BrainCircuit', bgColor: 'bg-rose-50', iconColor: 'text-rose-600' },
  { id: 4, type: 'quiz', tag: 'Conjugations', title: 'Group 1 Regular Verbs', desc: 'Present tense specialized training to accurately target conjugation blind spots.', icon: 'PenTool', bgColor: 'bg-purple-50', iconColor: 'text-purple-600' },
  { id: 5, type: 'book', tag: 'Ext. Reading', title: 'Le Petit Prince', desc: 'Bilingual French-English text with professional narration.', icon: 'Library', bgColor: 'bg-amber-50', iconColor: 'text-amber-600' },
  { id: 6, type: 'book', tag: 'Ext. Reading', title: 'L\'Étranger', desc: 'Camus\' The Stranger beginner intensive reading edition with vocabulary annotations.', icon: 'BookMarked', bgColor: 'bg-blue-50', iconColor: 'text-blue-600' },
];

const headers = {
  'course': { title: 'Discover Courses', sub: 'Systematic learning, steady progress.' },
  'quiz': { title: 'Special Quizzes', sub: 'Find and fill gaps, build muscle memory.' },
  'book': { title: 'Extended Readings', sub: 'Contextual reading to improve language sense.' }
};

export default function HomePage() {
  const [searchTerm, setSearchTerm] = useState('');
  const [activeCategory, setActiveCategory] = useState('course');
  const { user, isLoggedIn, token } = useAuth();

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

    // Map DB courses to the visual card model
    return baseCourses.map(course => {
      const priceAsNumber = parseFloat(course.price);
      return {
        ...course,
        type: 'course',
        tag: `Unité ${course.course_id}`,
        title: `Chapitre ${course.course_id}`,
        desc: `Level: A1. ${priceAsNumber === 0 ? 'Free Content' : 'Premium Content'}`,
        icon: 'BookOpen',
        bgColor: priceAsNumber === 0 ? 'bg-emerald-50' : 'bg-indigo-50',
        iconColor: priceAsNumber === 0 ? 'text-emerald-600' : 'text-indigo-600',
        price: priceAsNumber,
        purchased: purchasedCourseIds.has(course.course_id),
        free: priceAsNumber === 0,
      };
    });
  }, [coursesData, entitlementsData, isLoggedIn]);

  const filteredItems = useMemo(() => {
    let sourceData = activeCategory === 'course' ? enrichedCourses : mockDatabase.filter(item => item.type === activeCategory);
    if (!sourceData) return [];

    return sourceData.filter(meta => {
      const searchContent = `${meta.title} ${meta.desc} ${meta.tag}`.toLowerCase();
      return searchContent.includes(searchTerm.toLowerCase());
    });
  }, [enrichedCourses, activeCategory, searchTerm]);


  let displayErrorMessage = null;
  if (isErrorCourses && activeCategory === 'course') {
    displayErrorMessage = (errorCoursesMsg instanceof Error ? errorCoursesMsg.message : String(errorCoursesMsg)) || 'Failed to load courses.';
  } else if (isLoggedIn && isErrorEntitlements && activeCategory === 'course') {
    displayErrorMessage = (errorEntitlementsMsg instanceof Error ? errorEntitlementsMsg.message : String(errorEntitlementsMsg)) || 'Failed to load your entitlements.';
  }

  return (
    <div className="min-h-screen flex flex-col bg-zinc-50 font-sans">
      <NavBar activeCategory={activeCategory} onCategoryChange={setActiveCategory} />

      <main className="max-w-6xl mx-auto px-6 py-10 w-full flex-grow">
        <section className="view-section active">

          <div className="mb-10 flex flex-col md:flex-row md:justify-between md:items-end gap-4">
            <div>
              <h2 className="text-3xl font-extrabold text-zinc-900 tracking-tight">{headers[activeCategory].title}</h2>
              <p className="text-zinc-500 mt-2 text-sm">{headers[activeCategory].sub}</p>
            </div>
            <div className="relative group">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-zinc-400 group-focus-within:text-zinc-900 transition-colors" />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Search content..."
                className="w-full md:w-72 pl-10 pr-4 py-2.5 bg-white border-0 ring-1 ring-zinc-900/5 rounded-xl shadow-sm focus:outline-none focus:ring-2 focus:ring-zinc-900 focus:shadow-md transition-all text-sm"
              />
            </div>
          </div>

          {displayErrorMessage ? (
            <p className="text-center text-red-500 my-8 py-10">⚠️ {displayErrorMessage}</p>
          ) : (isLoadingCourses || (isLoggedIn && isLoadingEntitlements)) && activeCategory === 'course' ? (
            <div className="text-center text-zinc-500 my-8 py-10">Loading...</div>
          ) : (
            <CourseList items={filteredItems} category={activeCategory} />
          )}

        </section>
      </main>
    </div>
  );
}