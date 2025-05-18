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

export async function fetchCourseSentences(courseId, token) {
  const url = `/api/courses/${courseId}/sentences`;
  const headers = {
    'Content-Type': 'application/json',
  };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const response = await fetch(url, { headers });

  if (!response.ok) {
    if (response.status === 403) {
      const errorData = await response.json(); 
      const error = new Error(errorData.detail);
      error.status = 403;
      error.data = errorData;
      throw error;
    }
    const error = new Error(`Failed to fetch course sentences. Status: ${response.status}`);
    error.status = response.status;
    try {
      error.data = await response.json();
    } catch (e) {
      error.data = { detail: await response.text() };
    }
    throw error;
  }
  return response.json();
}

export async function fetchCourseAudioBlob(courseId, token) {
  const url = `/api/courses/${courseId}/audio`;
  const headers = {};
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const response = await fetch(url, { headers });

  if (!response.ok) {
    if (response.status === 403) {
      let errorData;
      try {
        errorData = await response.json();
      } catch (e) {
        errorData = { detail: 'Access to audio denied and non-JSON response.' };
      }
      const error = new Error(errorData.detail || 'Access to course audio forbidden.');
      error.status = 403;
      error.data = errorData;
      throw error;
    }
    const error = new Error(`Failed to fetch course audio. Status: ${response.status}`);
    error.status = response.status;
    try {
      error.data = await response.json();
    } catch (e) {
      error.data = { detail: await response.text() };
    }
    throw error;
  }
  return response.blob();
}