import { useQuery } from '@tanstack/react-query';
import { fetchQuizzes } from '../api/courses';

export default function useQuizzes() {
    return useQuery({
        queryKey: ['quizzes'],
        queryFn: fetchQuizzes,
    });
}
