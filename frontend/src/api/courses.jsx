import apiClient from './service'

export async function fetchCourses() {
  try {
    const res = await apiClient.get('/courses/');
    return res.data;
  } catch (error) {
    if (import.meta.env.DEV) {
      console.warn('fetchCourses failed in dev, using mock data');
      return [{ "course_id": 1, "price": 0.00 }, { "course_id": 2, "price": 9.99 },];
    } else {
      console.error("Error fetching courses: ",error.config?.url, error.message);
      throw error;
    }
  }
}

export async function fetchEntitlements() {
  if (!localStorage.getItem('access_token')) {
    return [];
  }
  try {
    const res = await apiClient.get('/entitlements/');
    return res.data;
  } catch (error) {
    console.error("Error fetching entitlements: ",error.config?.url, error.message);
    throw error;
  }
}

export async function fetchCourseSentences(courseId) {
  const url = `/courses/${courseId}/sentences`;
  try {
    const res = await apiClient.get(url);
    return res.data;
  }
  catch (error) {
    console.error("Error fetching course sentences: ",error.config?.url, error.message);
    throw error;
  }
}

export async function fetchCourseAudioBlob(courseId) {
  const url = `/courses/${courseId}/audio`;
  try {
    const response = await apiClient.get(url, { responseType: 'blob' });
    if (response.data && response.data.type && !response.data.type.startsWith('audio/')) {
      console.warn(`Expected an audio blob, but received type: ${response.data.type}. This might be an error blob.`);
      let errorDetail = 'Received non-audio data when expecting audio.';
      try {
        const errorText = await response.data.text();
        console.error('Content of unexpected blob:', errorText);
        errorDetail = errorText;
      } catch (e){}
      throw new Error(errorDetail);
    }
    return response.data;

  } catch (error) {
    console.error('Error fetching course audio with apiClient:', error.config?.url, error.message);
    throw error;
  }
}