import { useQuery } from '@tanstack/react-query';
import { fetchCourses } from '../api/courses';

export default function useCourses() {
  return useQuery({
    queryKey: ['courses'],
    queryFn: fetchCourses,
  });
}