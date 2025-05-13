export async function fetchCourses() {
  try {
    const res = await fetch('/api/courses/');
    if (!res.ok) throw new Error('/api/courses/ failed.');
    return res.json();
  } catch (error) {
    if (import.meta.env.DEV) {
      console.warn('fetchCourses failed in dev, using mock data');
      return [{ "lesson": 1, "free": true }, { "lesson": 2, "free": false },];
    } else {
      throw error;
    }
  }
}
