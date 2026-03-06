import { useState, useCallback, useEffect } from 'react';

const STORAGE_KEY = 'loop_playback_range';

/**
 * Generates a list of valid course IDs from 1 to maxId,
 * skipping multiples of 7 (review lessons placeholder).
 */
function getValidCourseIds(maxId) {
    const ids = [];
    for (let i = 1; i <= maxId; i++) {
        if (i % 7 !== 0) ids.push(i);
    }
    return ids;
}

/**
 * Hook managing loop‑playback range state with localStorage persistence.
 *
 * @param {number} currentCourseId  – the course being viewed right now
 * @param {number} maxAccessibleId  – highest course the user can access
 */
export default function useLoopPlayback(currentCourseId, maxAccessibleId) {
    const validIds = getValidCourseIds(maxAccessibleId || 1);

    // Clamp a value into the valid course IDs range
    const clamp = (v) => {
        const n = Number(v);
        if (!n || n < 1) return 1;
        if (n > maxAccessibleId) return maxAccessibleId;
        return n;
    };

    // ── Initialise from cache or defaults ──────────────────────────
    const [rangeStart, setRangeStartRaw] = useState(() => {
        try {
            const cached = JSON.parse(localStorage.getItem(STORAGE_KEY));
            if (cached?.start) return clamp(cached.start);
        } catch { /* ignore */ }
        return currentCourseId;
    });

    const [rangeEnd, setRangeEndRaw] = useState(() => {
        try {
            const cached = JSON.parse(localStorage.getItem(STORAGE_KEY));
            if (cached?.end) return clamp(cached.end);
        } catch { /* ignore */ }
        return maxAccessibleId || currentCourseId;
    });

    const [loopEnabled, setLoopEnabled] = useState(false);

    // ── Persist to localStorage whenever range changes ─────────────
    const persist = useCallback((start, end) => {
        try {
            localStorage.setItem(STORAGE_KEY, JSON.stringify({ start, end }));
        } catch { /* quota exceeded – silently ignore */ }
    }, []);

    const setRangeStart = useCallback((val) => {
        const v = clamp(val);
        setRangeStartRaw(v);
        setRangeEndRaw((prev) => {
            const end = prev < v ? v : prev;
            persist(v, end);
            return end;
        });
    }, [maxAccessibleId, persist]);

    const setRangeEnd = useCallback((val) => {
        const v = clamp(val);
        setRangeEndRaw(v);
        setRangeStartRaw((prev) => {
            const start = prev > v ? v : prev;
            persist(start, v);
            return start;
        });
    }, [maxAccessibleId, persist]);

    // ── Re‑clamp when maxAccessibleId changes (e.g. login/logout) ──
    useEffect(() => {
        if (!maxAccessibleId) return;
        setRangeStartRaw((prev) => {
            const clamped = clamp(prev);
            return clamped !== prev ? clamped : prev;
        });
        setRangeEndRaw((prev) => {
            const clamped = clamp(prev);
            return clamped !== prev ? clamped : prev;
        });
    }, [maxAccessibleId]);

    // ── Compute next course in the range ───────────────────────────
    const getNextCourseId = useCallback((currentId) => {
        const rangeIds = validIds.filter((id) => id >= rangeStart && id <= rangeEnd);
        if (rangeIds.length === 0) return currentId;

        if (currentId < rangeStart) {
            // Before the range → play forward sequentially toward it
            const next = validIds.find((id) => id > currentId);
            return next ?? rangeIds[0];
        }

        if (currentId > rangeEnd) {
            // After the range → play forward to max, then jump into loop
            const next = validIds.find((id) => id > currentId);
            return next ?? rangeIds[0];
        }

        // Within the range → loop inside [rangeStart, rangeEnd]
        const idx = rangeIds.indexOf(currentId);
        if (idx === -1 || idx === rangeIds.length - 1) {
            return rangeIds[0]; // wrap
        }
        return rangeIds[idx + 1];
    }, [validIds, rangeStart, rangeEnd]);

    return {
        rangeStart,
        rangeEnd,
        setRangeStart,
        setRangeEnd,
        loopEnabled,
        setLoopEnabled,
        getNextCourseId,
        validIds,
    };
}
