import { useEffect, useState, useRef } from 'react';
import { useQuery } from '@tanstack/react-query';
import { fetchCourseSentences, fetchCourseAudioBlob } from '../api/courses';

export default function useCourseData(numericCourseId, token, shouldRequestContent) {

    const [audioPlayerState, setAudioPlayerState] = useState({
        src: null,
        isPlaying: false,
    });
    const [audioUserError, setAudioUserError] = useState(null);

    const {
        data: sentences,
        isLoading: isLoadingSentences,
        isError: isSentenceFetchError,
        error: sentenceFetchErrorData,
    } = useQuery({
        queryKey: ['courseSentences', numericCourseId, token],
        queryFn: () => fetchCourseSentences(numericCourseId, token),
        enabled: shouldRequestContent,
        retry: (failureCount, error) => error?.status === 403 ? false : failureCount < 3,
    });

    const {
        data: audioBlob,
        isLoading: isLoadingAudio,
        isError: isAudioFetchError,
        error: audioFetchErrorData,
    } = useQuery({
        queryKey: ['courseAudio', numericCourseId, token],
        queryFn: () => fetchCourseAudioBlob(numericCourseId, token),
        enabled: shouldRequestContent,
        staleTime: Infinity,
        cacheTime: Infinity,
        retry: (failureCount, error) => error?.status === 403 ? false : failureCount < 3,
    });

    useEffect(() => {
        let objectUrl = null;
        if (audioBlob) {
            objectUrl = URL.createObjectURL(audioBlob);
            setAudioPlayerState(prev => {
                return { ...prev, src: objectUrl, isPlaying: false };
            });
        }
        return () => {
            if (objectUrl) { URL.revokeObjectURL(objectUrl); }
        };
    }, [audioBlob]);

    useEffect(() => {
        if (audioRef.current) {
            audioRef.current.pause();
        }
        setAudioPlayerState({ src: null, isPlaying: false });
        setAudioUserError(null);
    }, [numericCourseId])

    useEffect(() => {
        const currentSrc = audioPlayerState.src;
        return () => {
            if (currentSrc && currentSrc.startsWith('blob:')) {
                URL.revokeObjectURL(currentSrc);
            }
        };
    }, [audioPlayerState.src]);

    const audioRef = useRef(null);
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