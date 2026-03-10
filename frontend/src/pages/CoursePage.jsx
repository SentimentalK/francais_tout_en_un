import React, { useEffect, useState, useRef, useMemo } from 'react';
import { useLocation, useParams, useNavigate } from 'react-router-dom';
import useAuth from '../hooks/useAuth';
import useCourseData from '../hooks/useCourseData';
import useCourses from '../hooks/useCourses';
import useEntitlements from '../hooks/useEntitlements';
import useLoopPlayback from '../hooks/useLoopPlayback';
import { useCourseNotes } from '../hooks/useCourseNotes';
import PurchasePrompt from '../components/PurchasePrompt';
import ContentPageNav from '../components/ContentPageNav';
import CourseSentenceItem from '../components/CourseSentenceItem';
import NavBar from '../components/NavBar';
import CourseNotesSidebar from '../components/CourseNotesSidebar';
import { Layers, Play, Pause, AlertCircle, Repeat } from 'lucide-react';

const PageSpinner = ({ message }) => <div className="text-center text-zinc-500 my-12 text-lg">{message || 'Loading...'}</div>;
const ErrorDisplay = ({ message }) => <div className="text-center p-4 bg-rose-50 ring-1 ring-rose-200 text-rose-600 rounded-2xl max-w-2xl mx-auto my-10 font-medium flex flex-col items-center gap-2"><AlertCircle className="w-6 h-6" /> {message || 'An error occurred.'}</div>;

const CourseContentPage = () => {

  const { courseId } = useParams();
  const { token, isLoggedIn } = useAuth();
  const navigate = useNavigate();
  const numericCourseId = Number(courseId);
  const displayCourseTitle = `Chapitre ${numericCourseId}`;

  // ── Fetch courses & entitlements to compute max accessible course ──
  const { data: coursesData } = useCourses();
  const { data: entitlementsData } = useEntitlements(token);

  const maxAccessibleCourseId = useMemo(() => {
    const courses = Array.isArray(coursesData) ? coursesData : [];
    if (courses.length === 0) return numericCourseId;

    // Free courses are accessible to everyone
    const freeCourseIds = courses
      .filter((c) => parseFloat(c.price) === 0)
      .map((c) => c.course_id);

    // Purchased courses (logged-in users)
    const purchasedIds = (isLoggedIn && Array.isArray(entitlementsData))
      ? entitlementsData.map((e) => e.course_id)
      : [];

    const allAccessible = [...freeCourseIds, ...purchasedIds];
    return allAccessible.length > 0 ? Math.max(...allAccessible) : numericCourseId;
  }, [coursesData, entitlementsData, isLoggedIn, numericCourseId]);

  // ── Loop playback hook ──
  const {
    rangeStart,
    rangeEnd,
    setRangeStart,
    setRangeEnd,
    loopEnabled,
    setLoopEnabled,
    getNextCourseId,
    validIds,
  } = useLoopPlayback(numericCourseId, maxAccessibleCourseId);

  const location = useLocation();
  const routeState = location.state;
  const [isNotesOpen, setIsNotesOpen] = useState(false);
  const [activeNote, setActiveNote] = useState(null);

  let shouldRequestContent = true;
  if (routeState && ('isFree' in routeState || 'isPurchased' in routeState)) {
    const {
      isFree: isCourseFreeFromState,
      isPurchased: isCoursePurchasedFromState
    } = routeState;
    shouldRequestContent = (isCoursePurchasedFromState || isCourseFreeFromState);
  }

  const {
    sentences,
    audioPlayerState,
    setAudioPlayerState,
    audioRef,

    audioUserError,
    setAudioUserError,

    isLoadingSentences,
    isSentenceFetchError,
    sentenceFetchErrorData,

    isLoadingAudio,
    isAudioFetchError,
    audioFetchErrorData,

    backendDeniedAccess,
  } = useCourseData(numericCourseId, shouldRequestContent);

  const { notes } = useCourseNotes(numericCourseId, shouldRequestContent);

  // ── Auto-play flag for loop navigation ──
  const pendingAutoPlay = useRef(!!routeState?.autoPlay);
  useEffect(() => {
    pendingAutoPlay.current = !!routeState?.autoPlay;
  }, [numericCourseId]);


  const handlePlayButtonClick = () => {
    setAudioUserError(null);
    if (isAudioFetchError) {
      alert(`Cannot play audio: ${audioFetchErrorData?.message || 'Failed to load audio.'}`);
      return;
    }
    if (isLoadingAudio && !audioPlayerState.src) {
      alert("Audio is still loading, please wait.");
      return;
    }
    if (audioPlayerState.src && audioRef.current) {
      if (audioPlayerState.isPlaying) {
        audioRef.current.pause();
      } else {
        audioRef.current.play().catch(e => {
          setAudioUserError("Could not play audio. Browser might have blocked it.");
        });
      }
    } else if (!isLoadingAudio) {
      alert("Audio not available, src missing.");
    }
  };

  if ((routeState && !shouldRequestContent) || backendDeniedAccess) {
    return (
      <div className="min-h-screen bg-zinc-50 flex flex-col font-sans">
        <NavBar />
        <main className="max-w-4xl mx-auto px-6 py-10 w-full flex-grow">
          <ContentPageNav currentCourseId={numericCourseId} />
          <div className="bg-white rounded-3xl p-6 md:p-8 shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-zinc-900/5 mb-8 flex flex-col items-center">
            <div className="w-16 h-16 bg-zinc-50 rounded-2xl flex items-center justify-center mb-6 ring-1 ring-zinc-100">
              <Layers className="w-8 h-8 text-zinc-800" />
            </div>
            <h2 className="text-3xl font-extrabold text-zinc-900 mb-3 tracking-tight">{displayCourseTitle}</h2>
            <PurchasePrompt courseId={numericCourseId} isLoggedIn={isLoggedIn} />
          </div>
        </main>
      </div>
    );
  }

  if (isLoadingSentences) {
    return (
      <div className="min-h-screen bg-zinc-50 flex flex-col font-sans">
        <NavBar />
        <main className="max-w-4xl mx-auto px-6 py-10 w-full flex-grow">
          <ContentPageNav currentCourseId={numericCourseId} />
          <PageSpinner message={`Loading content for ${displayCourseTitle}...`} />
        </main>
      </div>
    );
  }

  if (isSentenceFetchError) {
    return (
      <div className="min-h-screen bg-zinc-50 flex flex-col font-sans">
        <NavBar />
        <main className="max-w-4xl mx-auto px-6 py-10 w-full flex-grow">
          <ContentPageNav currentCourseId={numericCourseId} />
          <ErrorDisplay message={sentenceFetchErrorData?.message || `Error loading sentences for ${displayCourseTitle}.`} />
        </main>
      </div>
    );
  }

  if (sentences) {
    return (
      <div className="min-h-screen bg-zinc-50 flex flex-col font-sans">
        <NavBar />
        <main
          className={`mx-auto px-6 py-10 w-full flex-grow relative transition-all duration-300 ease-in-out ${isNotesOpen ? 'max-w-4xl mr-[50vw] md:mr-[45vw] lg:mr-[40vw] xl:mr-[33.333333%]' : 'max-w-4xl'}`}
        >
          <ContentPageNav
            currentCourseId={numericCourseId}
            onNotesClick={() => setIsNotesOpen(!isNotesOpen)}
            hasNotes={!!(notes && notes.length > 0)}
            isNotesOpen={isNotesOpen}
          />

          {/* 全局播控卡片 */}
          <div className="bg-white rounded-3xl p-6 md:p-8 shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-zinc-900/5 mb-8">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">

              {/* 左侧：播放与标题 */}
              <div className="flex items-center gap-5">
                <button
                  id={`play-${numericCourseId}`}
                  onClick={handlePlayButtonClick}
                  disabled={isLoadingAudio && !audioPlayerState.src}
                  className="w-14 h-14 shrink-0 rounded-full bg-zinc-900 flex items-center justify-center text-white hover:bg-zinc-800 shadow-md transition-transform hover:scale-105 disabled:opacity-50 disabled:scale-100 disabled:cursor-not-allowed"
                  aria-label={audioPlayerState.isPlaying ? `Pause audio for ${displayCourseTitle}` : `Play audio for ${displayCourseTitle}`}
                >
                  {audioPlayerState.isPlaying ? (
                    <Pause className="w-6 h-6 fill-current" />
                  ) : (
                    <Play className="w-6 h-6 ml-1 fill-current" />
                  )}
                </button>
                <div>
                  <span id="lesson-index-badge" className="text-sm text-zinc-400 font-mono font-medium block mb-0.5">Leçon {numericCourseId} / 100</span>
                  <h2 id="detail-title" className="text-2xl font-extrabold text-zinc-900 tracking-tight leading-none m-0">{displayCourseTitle}</h2>
                </div>
              </div>

              {/* 右侧：控件区 */}
              <div className="flex items-center justify-between md:justify-end w-full md:w-auto">
                {/* 联播区间选择器 */}
                <div className="flex items-center bg-zinc-100 shadow-[inset_0_2px_4px_0_rgba(0,0,0,0.05)] border border-black/5 rounded-xl px-4 py-2">
                  <select
                    id="range-start"
                    className="appearance-none bg-transparent text-center cursor-pointer focus:outline-none text-xl font-bold text-zinc-800 hover:text-zinc-500 transition-colors w-8"
                    value={rangeStart}
                    onChange={(e) => setRangeStart(Number(e.target.value))}
                  >
                    {validIds.map((id) => (
                      <option key={id} value={id}>{id}</option>
                    ))}
                  </select>
                  <span className="text-zinc-300 mx-2 font-mono">-</span>
                  <select
                    id="range-end"
                    className="appearance-none bg-transparent text-center cursor-pointer focus:outline-none text-xl font-bold text-zinc-800 hover:text-zinc-500 transition-colors w-8"
                    value={rangeEnd}
                    onChange={(e) => setRangeEnd(Number(e.target.value))}
                  >
                    {validIds.map((id) => (
                      <option key={id} value={id}>{id}</option>
                    ))}
                  </select>
                </div>

                {/* 竖线分割 */}
                <div className="w-px h-8 bg-zinc-200 mx-5 sm:mx-6"></div>

                {/* 循环播放按钮 */}
                <button
                  className={`transition-colors flex items-center gap-2 pr-2 ${loopEnabled
                    ? 'text-zinc-900 bg-zinc-200/60 rounded-lg px-2 py-1.5'
                    : 'text-zinc-400 hover:text-zinc-900'
                    }`}
                  title={loopEnabled ? '关闭循环播放' : '开启循环播放'}
                  onClick={() => setLoopEnabled((prev) => !prev)}
                >
                  <Repeat className="w-6 h-6" />
                </button>
              </div>
            </div>
          </div>

          {isAudioFetchError && <p className="text-red-500 my-4 text-center">{audioFetchErrorData?.message || "Failed to load audio."}</p>}
          {audioUserError && <p className="text-red-500 my-4 text-center">{audioUserError}</p>}

          <div id="lesson-sentences" className="space-y-4">
            {sentences.map((sentence) => (
              <CourseSentenceItem
                key={sentence.seq}
                sentence={sentence}
                courseId={numericCourseId}
                activeNote={activeNote}
                setActiveNote={setActiveNote}
                onNoteClick={(noteId) => {
                  setActiveNote(noteId);
                  if (!isNotesOpen) setIsNotesOpen(true);
                }}
              />
            ))}
          </div>

          <audio
            ref={audioRef}
            src={audioPlayerState.src}
            onCanPlay={() => {
              if (pendingAutoPlay.current && audioRef.current && !audioPlayerState.isPlaying) {
                pendingAutoPlay.current = false;
                audioRef.current.play().catch(() => { });
              }
            }}
            onPlay={() => setAudioPlayerState(prev => ({ ...prev, isPlaying: true }))}
            onPause={() => setAudioPlayerState(prev => ({ ...prev, isPlaying: false }))}
            onEnded={() => {
              setAudioPlayerState(prev => ({ ...prev, isPlaying: false }));
              if (loopEnabled) {
                const nextId = getNextCourseId(numericCourseId);
                if (nextId !== numericCourseId) {
                  navigate(`/courses/${nextId}`, { state: { autoPlay: true } });
                } else {
                  // Only one course in range – replay it
                  if (audioRef.current) {
                    audioRef.current.currentTime = 0;
                    audioRef.current.play().catch(() => { });
                  }
                }
              }
            }}
            onError={(e) => {
              setAudioUserError(`Audio playback error: ${e.target.error?.message || 'Unknown issue'}`);
              setAudioPlayerState(prev => ({ ...prev, isPlaying: false }));
            }}
            style={{ display: 'none' }}
            preload="auto"
          />

          {/* Notes 侧边栏 */}
          <CourseNotesSidebar
            isOpen={isNotesOpen}
            onClose={() => setIsNotesOpen(false)}
            courseId={numericCourseId}
            shouldRequestContent={shouldRequestContent}
            activeNote={activeNote}
            setActiveNote={setActiveNote}
          />
        </main>
      </div>
    );
  }
  return null;
};

export default CourseContentPage;