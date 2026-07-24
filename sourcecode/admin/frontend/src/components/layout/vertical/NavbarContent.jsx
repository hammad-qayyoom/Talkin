'use client'

import { useMemo } from 'react'

import { usePathname } from 'next/navigation'

import Box from '@mui/material/Box'
import Typography from '@mui/material/Typography'

// Third-party Imports
import classnames from 'classnames'

// Component Imports
import NavToggle from './NavToggle'
import UserDropdown from '@components/layout/shared/UserDropdown'
import BrandName from '@/components/common/BrandName'

// Util Imports
import { verticalLayoutClasses } from '@layouts/utils/layoutClasses'
import NavSearch from '../shared/search'

const routeTitleMap = {
  '/dashboard': 'Dashboard',
  '/apps/user': 'Users',
  '/apps/listener': 'Experts',
  '/listener/request': 'Expert Requests',
  '/apps/manual-verification': 'Verification',
  '/sessions': 'Sessions',
  '/faq': 'FAQs',
  '/talk-topics': 'Categories',
  '/identity-proofs': 'Identity Proofs',
  '/feed/posts': 'Feed Posts',
  '/feed/reported': 'Reported Feed Posts',
  '/moderation/users': 'Reported Users',
  '/moderation/experts': 'Reported Experts',
  '/moderation/chats': 'Reported Chats',
  '/moderation/sessions': 'Reported Sessions',
  '/email-marketing': 'Email Marketing',
  '/email-accounts': 'Email Accounts',
  '/coin-plans': 'Subscription Plans',
  '/recording-plans': 'Recording Storage Plans',
  '/boost-plans': 'Boost Plans',
  '/coin-plan-history': 'Subscription History',
  '/payment-options': 'Payment Options',
  '/payout-requests': 'Payout Requests',
  '/settings': 'Settings',
  '/profile': 'Profile'
}

const resolvePageTitle = pathname => {
  if (!pathname || pathname === '/') return 'Dashboard'

  if (routeTitleMap[pathname]) return routeTitleMap[pathname]

  const prefixMatch = Object.entries(routeTitleMap).find(([route]) => pathname.startsWith(`${route}/`))

  if (prefixMatch) return prefixMatch[1]

  const segments = pathname
    .split('/')
    .filter(Boolean)
    .map(segment => segment.replace(/-/g, ' '))

  if (segments.length === 0) return 'Dashboard'

  const lastSegment = segments[segments.length - 1]
  const isNumericLike = /^\d+$/.test(lastSegment)
  const fallbackSegment = isNumericLike && segments.length > 1 ? segments[segments.length - 2] : lastSegment

  return fallbackSegment.replace(/\b\w/g, char => char.toUpperCase())
}

const NavbarContent = () => {
  const pathname = usePathname()

  const pageTitle = useMemo(() => resolvePageTitle(pathname), [pathname])

  return (
    <div className={classnames(verticalLayoutClasses.navbarContent, 'flex items-center justify-between gap-4 is-full')}>
      <div className='flex items-center gap-3 min-is-0'>
        <NavToggle />
        <Box className='min-is-0'>
          <Typography
            variant='h6'
            sx={{
              fontWeight: 800,
              color: 'var(--mui-palette-secondary-dark)',
              lineHeight: 1.1,
              whiteSpace: 'nowrap',
              overflow: 'hidden',
              textOverflow: 'ellipsis'
            }}
          >
            {pageTitle}
          </Typography>
          <Typography variant='caption' sx={{ color: 'var(--mui-palette-text-secondary)', letterSpacing: 0.3 }}>
            <BrandName /> Admin Console
          </Typography>
        </Box>
      </div>

      <div className='flex items-center gap-2'>
        <NavSearch />
        <UserDropdown />
      </div>
    </div>
  )
}

export default NavbarContent
