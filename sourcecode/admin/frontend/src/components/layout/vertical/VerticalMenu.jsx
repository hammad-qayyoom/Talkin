'use client'

import { useState } from 'react'

import { useRouter } from 'next/navigation'

import { signOut as firebaseSignOut } from 'firebase/auth'

import { useTheme } from '@mui/material/styles'

// Third-party Imports
import PerfectScrollbar from 'react-perfect-scrollbar'

import { useDispatch } from 'react-redux'

// Component Imports
import { Menu, MenuItem, MenuSection } from '@menu/vertical-menu'

// Hook Imports
import useVerticalNav from '@menu/hooks/useVerticalNav'

// Styled Component Imports
import StyledVerticalNavExpandIcon from '@menu/styles/vertical/StyledVerticalNavExpandIcon'

// Style Imports
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import { auth } from '@/libs/firebase'
import { logoutAdmin } from '@/redux-store/slices/admin'
import menuItemStyles from '@core/styles/vertical/menuItemStyles'
import menuSectionStyles from '@core/styles/vertical/menuSectionStyles'

const RenderExpandIcon = ({ open, transitionDuration }) => (
  <StyledVerticalNavExpandIcon open={open} transitionDuration={transitionDuration}>
    <i className='tabler-chevron-right' />
  </StyledVerticalNavExpandIcon>
)

const VerticalMenu = ({ scrollMenu }) => {
  // Hooks
  const theme = useTheme()
  const verticalNavOptions = useVerticalNav()
  const dispatch = useDispatch()
  const router = useRouter()

  // Vars
  const { isBreakpointReached, transitionDuration } = verticalNavOptions
  const ScrollWrapper = isBreakpointReached ? 'div' : PerfectScrollbar

  const [confirmOpen, setConfirmOpen] = useState(false)

  const handleUserLogout = async () => {
    try {
      // Sign out from Firebase
      await firebaseSignOut(auth)

      // Clear localStorage
      localStorage.removeItem('uid')
      localStorage.removeItem('admin_token')
      localStorage.removeItem('user')

      // Update Redux store
      dispatch(logoutAdmin())

      setConfirmOpen(false)
      router.push('/')
    } catch (error) {
      console.error('Logout error:', error)
    }
  }

  return (
    <>
      {/* Custom scrollbar instead of browser scroll, remove if you want browser scroll only */}
      <ScrollWrapper
        {...(isBreakpointReached
          ? {
              className: 'bs-full overflow-y-auto overflow-x-hidden',
              onScroll: container => scrollMenu(container, false)
            }
          : {
              options: { wheelPropagation: false, suppressScrollX: true },
              onScrollY: container => scrollMenu(container, true)
            })}
      >
        {/* Incase you also want to scroll NavHeader to scroll with Vertical Menu, remove NavHeader from above and paste it below this comment */}
        {/* Vertical Menu */}
        <Menu
          popoutMenuOffset={{ mainAxis: 23 }}
          menuItemStyles={menuItemStyles(verticalNavOptions, theme)}
          renderExpandIcon={({ open }) => <RenderExpandIcon open={open} transitionDuration={transitionDuration} />}
          renderExpandedMenuItemIcon={{ icon: <i className='tabler-circle text-xs' /> }}
          menuSectionStyles={menuSectionStyles(verticalNavOptions, theme)}
        >
          {/* Dashboard */}
          <MenuItem href='/dashboard' icon={<i className='tabler-smart-home' />}>
            Dashboard
          </MenuItem>

          <MenuSection label='USER MANAGEMENT'>
            <MenuItem href='/apps/user' icon={<i className='tabler-user' />} exactMatch={false} activeUrl='/apps/user'>
              User
            </MenuItem>
            <MenuItem
              href='/apps/listener'
              icon={<i className='tabler-user-star' />}
              exactMatch={false}
              activeUrl='/apps/listener'
            >
              Expert
            </MenuItem>
            <MenuItem href='/listener/request' icon={<i className='tabler-user-scan' />}>
              Expert Request
            </MenuItem>
            <MenuItem href='/apps/manual-verification' icon={<i className='tabler-badge' />}>
              Verification
            </MenuItem>
            <MenuItem href='/sessions' icon={<i className='tabler-calendar-time' />}>
              Sessions
            </MenuItem>
          </MenuSection>

          <MenuSection label='CONTENT'>
            <MenuItem href='/faq' icon={<i className='tabler-device-ipad-question' />}>
              FAQ
            </MenuItem>
            <MenuItem href='/talk-topics' icon={<i className='tabler-message-circle' />}>
              Category
            </MenuItem>
            <MenuItem href='/identity-proofs' icon={<i className='tabler-id' />}>
              Identity Proof
            </MenuItem>
            <MenuItem href='/growth-spotlight' icon={<i className='tabler-photo' />}>
              Growth Spotlight
            </MenuItem>
            <MenuItem href='/feed/posts' icon={<i className='tabler-news' />}>
              Feed Posts
            </MenuItem>
            <MenuItem href='/feed/reported' icon={<i className='tabler-flag-3' />}>
              Reported Feed Posts
            </MenuItem>
          </MenuSection>

          <MenuSection label='COMMUNICATIONS'>
            <MenuItem href='/email-marketing' icon={<i className='tabler-mail' />}>
              Email Marketing
            </MenuItem>
            <MenuItem href='/email-accounts' icon={<i className='tabler-mail-cog' />}>
              Email Accounts
            </MenuItem>
          </MenuSection>

          <MenuSection label='SUBSCRIPTION'>
            <MenuItem href='/coin-plans' icon={<i className='tabler-coins' />}>
              Subscription Plans
            </MenuItem>
            <MenuItem
              href='/coin-plan-history'
              exactMatch={false}
              activeUrl='/coin-plan-history'
              icon={<i className='tabler-history' />}
            >
              Subscription History
            </MenuItem>
          </MenuSection>

          <MenuSection label='FINANCIAL'>
            <MenuItem href='/payment-options' icon={<i className='tabler-cash' />}>
              Payment Options
            </MenuItem>
            <MenuItem href='/payout-requests' icon={<i className='tabler-cash-banknote' />}>
              Payout Request
            </MenuItem>
            <MenuItem href='/referrals' icon={<i className='tabler-gift' />}>
              Referrals
            </MenuItem>
          </MenuSection>

          <MenuSection label='SETTINGS'>
            <MenuItem href='/settings' icon={<i className='tabler-settings' />}>
              Settings
            </MenuItem>
            <MenuItem href='/profile' icon={<i className='tabler-user-circle' />}>
              Profile
            </MenuItem>
            <MenuItem onClick={() => setConfirmOpen(true)} icon={<i className='tabler-logout' />}>
              Logout
            </MenuItem>
          </MenuSection>
        </Menu>
      </ScrollWrapper>

      <ConfirmationDialog
        open={confirmOpen}
        title='Are you sure you want to logout?'
        content='You will be logged out of the system.'
        onConfirm={handleUserLogout}
        onClose={() => {
          setConfirmOpen(false)
        }}
      />
    </>
  )
}

export default VerticalMenu
