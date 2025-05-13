import { useState, useEffect } from 'react'

export default function useAuth() {
    const [isLoggedIn, setIsLoggedIn] = useState(false)

    useEffect(() => {
        const token = localStorage.getItem('token')
        setIsLoggedIn(!!token)
    }, [])

    const handleLogout = () => {
        localStorage.removeItem('token')
        setIsLoggedIn(false)
    }

    return { isLoggedIn, handleLogout }
}