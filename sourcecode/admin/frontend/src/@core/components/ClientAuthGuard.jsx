'use client'

import { useEffect, useState } from 'react'

import { usePathname, useRouter } from 'next/navigation'

import { onAuthStateChanged } from 'firebase/auth'

import { CircularProgress } from '@mui/material'

import { auth } from '@/libs/firebase'
import { initTokenRefresh } from '@/utils/token-refresh-middleware'
import { isRememberMeEnabled } from '@/utils/firebase-auth'
import { canAccessPath, getFirstAllowedPath, getStoredAdmin } from '@/config/moderatorPermissions'

const AUTH_PATHS = ['/', '/login', '/register', '/forgot-password']

const isResetPath = pathname => pathname.startsWith('/reset-password')

const ClientAuthGuard = ({ children }) => {
  const router = useRouter()
  const pathname = usePathname()
  const [loading, setLoading] = useState(true)
  const [authenticated, setAuthenticated] = useState(false)

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, user => {
      const currentPath = pathname || window.location.pathname
      const isAuthPath = AUTH_PATHS.includes(currentPath) || isResetPath(currentPath)

      if (user) {
        const storedAdmin = getStoredAdmin()

        if (isAuthPath) {
          router.replace(getFirstAllowedPath(storedAdmin))

          return
        }

        if (!storedAdmin) {
          router.replace('/login')

          return
        }

        if (!canAccessPath(storedAdmin, currentPath)) {
          router.replace(getFirstAllowedPath(storedAdmin))

          return
        }

        setAuthenticated(true)

        if (isRememberMeEnabled()) {
          initTokenRefresh()
        }
      } else {
        if (!isAuthPath) {
          router.replace('/login')

          return
        }

        setAuthenticated(true)
      }

      setTimeout(() => {
        setLoading(false)
      }, 1000)
    })

    return () => unsubscribe()
  }, [pathname, router])

  if (loading) {
    return (
      <div className='flex justify-center items-center min-h-screen fixed inset-0 bg-white' style={{ zIndex: 9999 }}>
        <CircularProgress />
      </div>
    )
  }

  return authenticated ? children : null
}

export default ClientAuthGuard
