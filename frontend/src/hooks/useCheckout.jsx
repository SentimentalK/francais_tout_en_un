import { useState, useMemo, useCallback, useEffect, useRef } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useNavigate, useLocation } from 'react-router-dom';
import useCourses from './useCourses';
import useEntitlements from './useEntitlements';
import { createOrder } from '../api/purchase';

export default function useCheckout() {
    const navigate = useNavigate();
    const queryClient = useQueryClient();
    const location = useLocation();

    const [selectedCourseIds, setSelectedCourseIds] = useState(new Set());
    const initialUrlParamProcessedRef = useRef(false); 

    const { 
        data: allCoursesData, 
        isLoading: isLoadingCourses, 
        isError: isCoursesError, 
        error: coursesError 
    } = useCourses();

    const { 
        data: entitlementsData, 
        isLoading: isLoadingEntitlements, 
        isError: isEntitlementsError, 
        error: entitlementsError 
    } = useEntitlements();

    const ownedCourseIds = useMemo(() => {
        if (!entitlementsData) return [];
        const ids = Array.isArray(entitlementsData) ? entitlementsData : (entitlementsData.entitled_course_ids || []);
        return ids;
    }, [entitlementsData]);
    
    const allCourses = useMemo(() => {
        const courses = allCoursesData || [];
        return courses;
    }, [allCoursesData]);

    useEffect(() => {
        if (initialUrlParamProcessedRef.current || isLoadingCourses || isLoadingEntitlements || !allCourses.length) {
            return;
        }

        const queryParams = new URLSearchParams(location.search);
        const courseIdFromUrlParam = queryParams.get('course');

        if (courseIdFromUrlParam) {
            const numericCourseIdFromUrl = Number(courseIdFromUrlParam);
            const courseToSelect = allCourses.find(c => c.course_id === numericCourseIdFromUrl);

            if (courseToSelect) {
                const price = parseFloat(courseToSelect.price);
                const isFree = price === 0.00;
                const isAlreadyOwned = isFree || (ownedCourseIds && ownedCourseIds.includes(numericCourseIdFromUrl));

                if (!isAlreadyOwned) {
                    setSelectedCourseIds(prev => {
                        const newSelected = new Set(prev);
                        newSelected.add(numericCourseIdFromUrl);
                        return newSelected;
                    });
                }
            }
            initialUrlParamProcessedRef.current = true;
        }
    }, [location.search, allCourses, ownedCourseIds, isLoadingCourses, isLoadingEntitlements]);

    const createOrderMutation = useMutation({
        mutationFn: (courseIdsToPurchase) => createOrder(courseIdsToPurchase),
        onSuccess: (data) => {
            queryClient.invalidateQueries({ queryKey: ['entitlements'] });
            queryClient.invalidateQueries({ queryKey: ['myEntitlements'] });

            const orderedCoursesDetails = allCourses.filter(course => 
                selectedCourseIds.has(course.course_id)
            );
            const orderAmount = orderedCoursesDetails.reduce((sum, course) => sum + parseFloat(course.price), 0);
            
            navigate(`/payment/${data.order_id}`, {
                state: {
                    orderId: data.order_id,
                    amount: orderAmount,
                    courses: orderedCoursesDetails,
                }
            });
        },
        onError: (error) => {
            console.error('Failed to create order:', error);
        }
    });

    const { displayCourses, purchasableCourses, totalAmount } = useMemo(() => {
        let currentTotal = 0;
        const purchasable = [];
        
        const coursesWithStatus = allCourses.map(course => {
            const price = parseFloat(course.price);
            const isFree = price === 0.00;
            const isAlreadyOwnedByEntitlement = ownedCourseIds.some(c => c.course_id == course.course_id);
            const isOwned = isFree || isAlreadyOwnedByEntitlement;

            const isSelectable = !isOwned;
            const isSelected = selectedCourseIds.has(course.course_id);

            if (isSelectable) {
                purchasable.push(course);
            }
            if (isSelected && isSelectable) {
                currentTotal += price;
            }

            return {
                ...course,
                price,
                isOwned, 
                isSelectable,
                isSelected,
            };
        });
        return { displayCourses: coursesWithStatus, purchasableCourses: purchasable, totalAmount: currentTotal };
    }, [allCourses, ownedCourseIds, selectedCourseIds]);

    const toggleCourseSelection = useCallback((courseId) => {
        setSelectedCourseIds(prev => {
            const newSelected = new Set(prev);
            const course = displayCourses.find(c => c.course_id === courseId);
            
            if (course && course.isSelectable) {
                if (newSelected.has(courseId)) {
                    newSelected.delete(courseId);
                } else {
                    newSelected.add(courseId);
                }
            }
            return newSelected;
        });
    }, [displayCourses]);

    const selectAllPurchasable = useCallback(() => {
        const allPurchasableIds = new Set(purchasableCourses.map(c => c.course_id));
        setSelectedCourseIds(allPurchasableIds);
    }, [purchasableCourses]);

    const deselectAll = useCallback(() => {
        setSelectedCourseIds(new Set());
    }, []);

    const handleSubmitOrder = useCallback(() => {
        createOrderMutation.mutate(Array.from(selectedCourseIds));
    }, [selectedCourseIds, createOrderMutation]);

    return {
        allCourses: displayCourses,
        isLoading: isLoadingCourses || isLoadingEntitlements,
        isError: isCoursesError || isEntitlementsError,
        error: coursesError || entitlementsError,
        
        selectedCourseIds,
        totalAmount,
        purchasableCoursesCount: purchasableCourses.length,

        toggleCourseSelection,
        selectAllPurchasable,
        deselectAll,
        handleSubmitOrder,
        isCreatingOrder: createOrderMutation.isLoading,
        createOrderError: createOrderMutation.error,
    };
}