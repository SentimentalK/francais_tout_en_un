import React, { useEffect, useState, useRef } from 'react';
import { useLocation, useParams } from 'react-router-dom';
import useAuth from '../hooks/useAuth';
import useCourseData from '../hooks/useCourseData';
import PurchasePrompt from '../components/PurchasePrompt';
import ContentPageNav from '../components/ContentPageNav';
import CourseSentenceItem from '../components/CourseSentenceItem';
import { Layers, Play, Pause, AlertCircle } from 'lucide-react';

const PageSpinner = ({ message }) => <div className="text-center text-zinc-500 my-12 text-lg">{message || 'Loading...'}</div>;
const ErrorDisplay = ({ message }) => <div className="text-center p-4 bg-red-50 border border-red-200 text-red-600 rounded-xl max-w-2xl mx-auto my-10 font-medium flex flex-col items-center gap-2"><AlertCircle className="w-6 h-6" /> {message || 'An error occurred.'}</div>;

const CourseContentPage = () => {

  const { courseId } = useParams();
  const { token, isLoggedIn } = useAuth();
  const numericCourseId = Number(courseId);
  const displayCourseTitle = `Chapitre ${numericCourseId}`;

  const location = useLocation();
  const routeState = location.state;
  let shouldRequestContent = true;
  if (routeState) {
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
      <div className="max-w-6xl mx-auto px-6 py-10 w-full font-sans">
        <ContentPageNav currentCourseId={numericCourseId} />
        <div className="bg-white p-8 md:p-14 rounded-3xl shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-zinc-900/5 max-w-4xl mx-auto">
          <div className="w-16 h-16 bg-zinc-50 rounded-2xl flex items-center justify-center mb-6 ring-1 ring-zinc-100">
            <Layers className="w-8 h-8 text-zinc-800" />
          </div>
          <h2 className="text-3xl font-extrabold text-zinc-900 mb-3 tracking-tight">{displayCourseTitle}</h2>
          <PurchasePrompt courseId={numericCourseId} isLoggedIn={isLoggedIn} />
        </div>
      </div>
    );
  }

  if (isLoadingSentences) {
    return (
      <div className="max-w-6xl mx-auto px-6 py-10 w-full font-sans">
        <ContentPageNav currentCourseId={numericCourseId} />
        <PageSpinner message={`Loading content for ${displayCourseTitle}...`} />
      </div>
    );
  }

  if (isSentenceFetchError) {
    return (
      <div className="max-w-6xl mx-auto px-6 py-10 w-full font-sans">
        <ContentPageNav currentCourseId={numericCourseId} />
        <ErrorDisplay message={sentenceFetchErrorData?.message || `Error loading sentences for ${displayCourseTitle}.`} />
      </div>
    );
  }

  if (sentences) {
    return (
      <div className="max-w-6xl mx-auto px-6 py-10 w-full flex flex-col min-h-screen font-sans">
        <ContentPageNav currentCourseId={numericCourseId} />

        <div className="bg-white p-8 md:p-14 rounded-3xl shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-zinc-900/5 max-w-4xl mx-auto w-full">
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 mb-10 pb-6 border-b border-zinc-100">
            <div>
              <div className="w-16 h-16 bg-zinc-50 rounded-2xl flex items-center justify-center mb-6 ring-1 ring-zinc-100">
                <Layers className="w-8 h-8 text-zinc-800" />
              </div>
              <h2 className="text-3xl font-extrabold text-zinc-900 tracking-tight m-0 mb-2">{displayCourseTitle}</h2>
              <p className="text-zinc-500 text-lg m-0">Intensive listening to dialogues to develop language sense.</p>
            </div>

            {/* Play Button */}
            <button
              id={`play-${numericCourseId}`}
              className={`w-14 h-14 shrink-0 flex items-center justify-center rounded-full text-white transition-all duration-300 shadow-md focus:outline-none focus:ring-4 focus:ring-zinc-900/20 ${isLoadingAudio && !audioPlayerState.src ? 'bg-zinc-300 cursor-not-allowed text-zinc-500 shadow-none hover:scale-100' : 'bg-zinc-900 hover:bg-zinc-800 hover:scale-105 hover:-translate-y-1 hover:shadow-lg'}`}
              onClick={handlePlayButtonClick}
              disabled={isLoadingAudio && !audioPlayerState.src}
              aria-label={audioPlayerState.isPlaying ? `Pause audio for ${displayCourseTitle}` : `Play audio for ${displayCourseTitle}`}
            >
              {audioPlayerState.isPlaying ? (
                <Pause className="w-6 h-6 fill-current" />
              ) : (
                <Play className="w-6 h-6 ml-1 fill-current" />
              )}
            </button>
          </div>

          {isAudioFetchError && <p className="text-red-500 my-4 text-center">{audioFetchErrorData?.message || "Failed to load audio."}</p>}
          {audioUserError && <p className="text-red-500 my-4 text-center">{audioUserError}</p>}

          <div id="content-body" className="space-y-4">
            {sentences.map((sentence) => (
              <CourseSentenceItem key={sentence.seq} sentence={sentence} courseId={numericCourseId} />
            ))}
          </div>
        </div>

        <audio
          ref={audioRef}
          src={audioPlayerState.src}
          onPlay={() => setAudioPlayerState(prev => ({ ...prev, isPlaying: true }))}
          onPause={() => setAudioPlayerState(prev => ({ ...prev, isPlaying: false }))}
          onEnded={() => setAudioPlayerState(prev => ({ ...prev, isPlaying: false }))}
          onError={(e) => {
            setAudioUserError(`Audio playback error: ${e.target.error?.message || 'Unknown issue'}`);
            setAudioPlayerState(prev => ({ ...prev, isPlaying: false }));
          }}
          style={{ display: 'none' }}
          preload="auto"
        />
      </div>
    );
  }
};

export default CourseContentPage;