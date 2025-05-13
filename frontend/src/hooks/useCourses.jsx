import { useQuery } from '@tanstack/react-query';
import { fetchCourses } from '../api/courses';
export function useCourses() {
  return useQuery({
    queryKey: ['courses'],
    queryFn: fetchCourses
  });
}