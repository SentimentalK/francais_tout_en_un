import { useEffect, useState, useRef } from 'react';
import { useQuery } from '@tanstack/react-query';
import { fetchCourseSentences, fetchCourseAudioBlob } from '../api/courses';

export default function useCourseData(numericCourseId, shouldRequestContent) {

    const [audioPlayerState, setAudioPlayerState] = useState({
        src: null,
        isPlaying: false,
    });
    const [audioUserError, setAudioUserError] = useState(null);
    const audioRef = useRef(null);
    const prevNumericCourseIdRef = useRef();

    const {
        data: sentences,
        isLoading: isLoadingSentences,
        isError: isSentenceFetchError,
        error: sentenceFetchErrorData,
    } = useQuery({
        queryKey: ['courseSentences', numericCourseId],
        queryFn: () => fetchCourseSentences(numericCourseId),
        enabled: !!numericCourseId && shouldRequestContent,
        retry: (failureCount, error) => error?.status === 403 ? false : failureCount < 3,
    });

    const {
        data: audioBlob,
        isLoading: isLoadingAudio,
        isError: isAudioFetchError,
        error: audioFetchErrorData,
    } = useQuery({
        queryKey: ['courseAudio', numericCourseId],
        queryFn: () => fetchCourseAudioBlob(numericCourseId),
        enabled: !!numericCourseId && shouldRequestContent,
        staleTime: Infinity,
        cacheTime: Infinity,
        retry: (failureCount, error) => error?.status === 403 ? false : failureCount < 3,
    });

    // Effect 1: When numericCourseId change, reset audio player
    useEffect(() => {
        const currentId = numericCourseId;

        // Only when numericCourseId change trigger this effect
        if (prevNumericCourseIdRef.current !== currentId) {
            console.log(`Hook: ID changed from ${prevNumericCourseIdRef.current} to ${currentId}. Resetting audio player.`);
            if (audioRef.current) {
                audioRef.current.pause();
            }
            setAudioPlayerState(prev => {
                if (prev.src && typeof prev.src === 'string' && prev.src.startsWith('blob:')) {
                    console.log(`Hook: ID changed, revoking old src: ${prev.src}`);
                    URL.revokeObjectURL(prev.src);
                }
                return { src: null, isPlaying: false };
            });
            setAudioUserError(null);
            prevNumericCourseIdRef.current = currentId;
        }
    }, [numericCourseId]);

    // Effect 2: When audioBlob changes, create/update Object URL and set src
    useEffect(() => {
        console.log(`Hook: audioBlob changed for ID ${numericCourseId}. Blob:`, audioBlob);
        let objectUrlThisRun = null;
        if (audioBlob && audioBlob instanceof Blob && audioBlob.size > 0) {
            try {
                objectUrlThisRun = URL.createObjectURL(audioBlob);
                console.log(`Hook: Created new objectUrl: ${objectUrlThisRun} for ID ${numericCourseId}`);
                setAudioPlayerState(prev => {
                    if (prev.src && prev.src !== objectUrlThisRun && typeof prev.src === 'string' && prev.src.startsWith('blob:')) {
                        console.log(`Hook: Revoking different previous src: ${prev.src} before setting new: ${objectUrlThisRun}`);
                        URL.revokeObjectURL(prev.src);
                    }
                    return { ...prev, src: objectUrlThisRun, isPlaying: false };
                });
            } catch (e) {
                console.error("Hook: Error creating object URL or setting state:", e);
                setAudioPlayerState(prev => {
                    if (prev.src && typeof prev.src === 'string' && prev.src.startsWith('blob:')) {
                        URL.revokeObjectURL(prev.src);
                    }
                    return { ...prev, src: null, isPlaying: false };
                });
                setAudioUserError("Error preparing audio.");
            }
        }

        return () => {
            if (objectUrlThisRun && typeof objectUrlThisRun === 'string' && objectUrlThisRun.startsWith('blob:')) {
                console.log(`Hook: Cleanup for Effect 2 (audioBlob), revoking: ${objectUrlThisRun} for ID ${numericCourseId}`);
                URL.revokeObjectURL(objectUrlThisRun);
            }
        };
    }, [audioBlob]);

    const backendDeniedAccess = sentenceFetchErrorData?.status === 403 || audioFetchErrorData?.status === 403;

    return {
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
    };
}