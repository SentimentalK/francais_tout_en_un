export async function fetchCourses() {
  try {
    const res = await fetch('/api/courses/');
    if (!res.ok) {
      const errorData = await res.text();
      throw new Error(`/api/courses/ failed with status ${res.status}: ${errorData}`);
    }
    return res.json();
  } catch (error) {
    if (import.meta.env.DEV) {
      console.warn('fetchCourses failed in dev, using mock data');
      return [{ "course": 1, "free": true }, { "course": 2, "free": false },];
    } else {
      throw error;
    }
  }
}

export async function fetchEntitlements(token) {
  if (!token) {
    return Promise.resolve([]);
  }
  const res = await fetch('/api/entitlements/', {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  if (!res.ok) {
    const errorData = await res.text();
    throw new Error(`Failed to load entitlements with status ${res.status}: ${errorData}`);
  }

  return res.json();
}