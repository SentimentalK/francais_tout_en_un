import { useEffect, useState, useRef } from 'react';
import { marked } from 'marked';
import { X } from 'lucide-react';
import { useCourseNotes } from '../hooks/useCourseNotes';

export default function CourseNotesSidebar({
    isOpen,
    onClose,
    courseId,
    shouldRequestContent,
    activeNote,
    setActiveNote
}) {
    const [htmlNotes, setHtmlNotes] = useState([]);
    const { notes, isLoading, isError } = useCourseNotes(courseId, shouldRequestContent);
    const noteRefs = useRef({});

    // Scroll to active note when it changes
    useEffect(() => {
        if (isOpen && activeNote !== null && noteRefs.current[activeNote]) {
            // Small timeout to ensure DOM is ready and transition is happening
            setTimeout(() => {
                noteRefs.current[activeNote]?.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }, 100);
        }
    }, [isOpen, activeNote]);

    // Keyboard shortcut to close
    useEffect(() => {
        const handleKeyDown = (e) => {
            if (e.key === 'Escape' && isOpen) {
                onClose();
            }
        };
        document.addEventListener('keydown', handleKeyDown);
        return () => document.removeEventListener('keydown', handleKeyDown);
    }, [isOpen, onClose]);

    // Parse markdown
    useEffect(() => {
        if (notes && notes.length > 0) {
            const parsed = notes.map(note => ({
                ...note,
                htmlContent: marked.parse(note.content, { async: false })
            }));
            setHtmlNotes(parsed);
        } else {
            setHtmlNotes([]);
        }
    }, [notes]);

    return (
        <>

            {/* Sidebar Panel */}
            <aside
                className={`fixed top-16 right-0 h-[calc(100vh-64px)] w-full sm:w-1/2 md:w-[45vw] lg:w-[40vw] xl:w-1/3 min-w-[320px] bg-white shadow-[-10px_0_15px_-3px_rgba(0,0,0,0.03)] z-30 transform transition-transform duration-300 ease-in-out flex flex-col border-l border-gray-100 ${isOpen ? 'translate-x-0' : 'translate-x-full'
                    }`}
            >
                {/* Header */}
                <div className="px-8 py-6 border-b border-gray-100 flex justify-between items-center bg-white z-10 shrink-0">
                    <div className="flex items-center gap-3 text-red-600">
                        <i className="ph-fill ph-notebook text-2xl"></i>
                        <h2 className="text-xl font-semibold tracking-tight">Notes</h2>
                    </div>
                    <button
                        onClick={onClose}
                        className="w-8 h-8 rounded-full bg-gray-100 text-gray-500 hover:bg-gray-200 hover:text-gray-900 flex items-center justify-center transition-colors shrink-0"
                        aria-label="Close notes"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>

                {/* Scrollable Content */}
                <div className="flex-1 overflow-y-auto px-6 py-6 space-y-4 bg-white sidebar-scroll relative">

                    {isLoading && (
                        <div className="flex justify-center py-10">
                            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-red-600"></div>
                        </div>
                    )}

                    {isError && (
                        <div className="text-center py-10 text-gray-500">
                            Failed to load notes or you do not have permission.
                        </div>
                    )}

                    {!isLoading && !isError && htmlNotes.length === 0 && (
                        <div className="text-center py-10 text-gray-500 text-sm">
                            No notes available for this lesson yet.
                        </div>
                    )}

                    {htmlNotes.map(note => (
                        <div
                            key={note.note_seq}
                            ref={(el) => (noteRefs.current[note.note_seq] = el)}
                            className={`flex gap-4 p-4 rounded-xl transition-colors duration-300 ${activeNote === note.note_seq ? 'bg-red-50' : 'hover:bg-gray-50'}`}
                            onMouseEnter={() => setActiveNote && setActiveNote(note.note_seq)}
                            onMouseLeave={() => setActiveNote && setActiveNote(null)}
                        >
                            <div className="text-red-600 font-bold text-lg pt-0.5 shrink-0 w-6">
                                {note.note_seq}
                            </div>
                            {/* prose container for Tailwind Typography to style Markdown tags correctly */}
                            <div
                                className="text-gray-700 leading-relaxed text-base md:text-lg prose prose-base md:prose-lg prose-gray max-w-none prose-p:my-0 prose-strong:text-gray-900 prose-em:italic"
                                dangerouslySetInnerHTML={{ __html: note.htmlContent }}
                            />
                        </div>
                    ))}

                </div>
            </aside>
        </>
    );
}
