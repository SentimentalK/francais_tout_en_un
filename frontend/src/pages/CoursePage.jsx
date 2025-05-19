import React, { useEffect, useState, useRef } from 'react';
import { useLocation, useParams } from 'react-router-dom';
import useAuth from '../hooks/useAuth';
import useCourseData from '../hooks/useCourseData';
import PurchasePrompt from '../components/PurchasePrompt';
import ContentPageNav from '../components/ContentPageNav';
import CourseSentenceItem from '../components/CourseSentenceItem';
import '../assets/content.css';

const PageSpinner = ({ message }) => <div className="loading-message">{message || 'Loading...'}</div>;
const ErrorDisplay = ({ message }) => <div className="error-message">⚠️ {message || 'An error occurred.'}</div>;

const CourseContentPage = () => {

  const { courseId } = useParams();
  const { token, isLoggedIn } = useAuth();
  const numericCourseId = Number(courseId);
  const displayCourseTitle = `Chapter ${numericCourseId}`;

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
      <div id="content-container" className="page-container">
        <ContentPageNav currentCourseId={numericCourseId} />
        <div className="chapter">
          <div className="chapter-header"><h2>{displayCourseTitle}</h2></div>
          <PurchasePrompt courseId={numericCourseId} isLoggedIn={isLoggedIn} />
        </div>
      </div>
    );
  }

  if (isLoadingSentences) {
    return (
      <div id="content-container" className="page-container">
        <ContentPageNav currentCourseId={numericCourseId} />
        <PageSpinner message={`Loading content for ${displayCourseTitle}...`} />
      </div>
    );
  }

  if (isSentenceFetchError) {
    return (
      <div id="content-container" className="page-container">
        <ContentPageNav currentCourseId={numericCourseId} />
        <ErrorDisplay message={sentenceFetchErrorData?.message || `Error loading sentences for ${displayCourseTitle}.`} />
      </div>
    );
  }

  if (sentences) {
    return (
      <div id="content-container" className="page-container">
        <ContentPageNav currentCourseId={numericCourseId} />
        <div className="chapter">
          <div className="chapter-header">
            <h2>{displayCourseTitle}</h2>
            <button
              id={`play-${numericCourseId}`}
              className={`play-btn ${audioPlayerState.isPlaying ? 'playing' : ''} ${isLoadingAudio && !audioPlayerState.src ? 'loading' : ''}`}
              onClick={handlePlayButtonClick}
              disabled={isLoadingAudio && !audioPlayerState.src}
              aria-label={audioPlayerState.isPlaying ? `Pause audio for ${displayCourseTitle}` : `Play audio for ${displayCourseTitle}`}
            >
            </button>
          </div>

          {isAudioFetchError && <p className="error-message show">{audioFetchErrorData?.message || "Failed to load audio."}</p>}
          {audioUserError && <p className="error-message show">{audioUserError}</p>}
          <div id="content-body">
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