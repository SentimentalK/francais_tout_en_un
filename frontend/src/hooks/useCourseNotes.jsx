import { useQuery } from '@tanstack/react-query';
import { fetchCourseNotes } from '../api/courses';

export function useCourseNotes(courseId, shouldRequestContent = true) {
    const { data: notes, isLoading, isError, error } = useQuery({
        queryKey: ['courseNotes', courseId],
        queryFn: () => fetchCourseNotes(courseId),
        enabled: !!courseId && shouldRequestContent,
        retry: 1,
    });

    return {
        notes,
        isLoading,
        isError,
        error,
    };
}
