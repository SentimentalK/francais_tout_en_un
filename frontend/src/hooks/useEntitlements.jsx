import { useQuery } from '@tanstack/react-query';
import { fetchEntitlements } from '../api/courses';

export default function useEntitlements(token) {
  return useQuery({
    queryKey: ['entitlements'],
    queryFn: () => fetchEntitlements(token),
    enabled: !!token,
    staleTime: 5 * 60 * 1000,
    cacheTime: 15 * 60 * 1000,
  });
}