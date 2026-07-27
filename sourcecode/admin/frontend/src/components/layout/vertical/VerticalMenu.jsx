'use client'

import { useEffect, useState } from 'react'

import { useRouter } from 'next/navigation'

import { signOut as firebaseSignOut } from 'firebase/auth'

import { useTheme } from '@mui/material/styles'

import PerfectScrollbar from 'react-perfect-scrollbar'

import { useDispatch } from 'react-redux'

import { Menu, MenuItem, MenuSection } from '@menu/vertical-menu'
import useVerticalNav from '@menu/hooks/useVerticalNav'
import StyledVerticalNavExpandIcon from '@menu/styles/vertical/StyledVerticalNavExpandIcon'

import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import { auth } from '@/libs/firebase'
import { logoutAdmin } from '@/redux-store/slices/admin'
import { getStoredAdmin, hasModeratorPermission, isOwnerAdmin } from '@/config/moderatorPermissions'
import menuItemStyles from '@core/styles/vertical/menuItemStyles'
import menuSectionStyles from '@core/styles/vertical/menuSectionStyles'

const RenderExpandIcon = ({ open, transitionDuration }) => (
  <StyledVerticalNavExpandIcon open={open} transitionDuration={transitionDuration}>
    <i className='tabler-chevron-right' />
  </StyledVerticalNavExpandIcon>
)

const VerticalMenu = ({ scrollMenu }) => {
  const theme = useTheme()
  const verticalNavOptions = useVerticalNav()
  const dispatch = useDispatch()
  const router = useRouter()
  const [confirmOpen, setConfirmOpen] = useState(false)
  const [admin, setAdmin] = useState(null)

  const { isBreakpointReached, transitionDuration } = verticalNavOptions
  const ScrollWrapper = isBreakpointReached ? 'div' : PerfectScrollbar

  useEffect(() => {
    setAdmin(getStoredAdmin())
  }, [])

  const can = permissionKey => hasModeratorPermission(admin, permissionKey)

  const handleUserLogout = async () => {
    try {
      await firebaseSignOut(auth)

      localStorage.removeItem('uid')
      localStorage.removeItem('admin_token')
      localStorage.removeItem('user')

      dispatch(logoutAdmin())

      setConfirmOpen(false)
      router.push('/login')
    } catch (error) {
      console.error('Logout error:', error)
    }
  }

  const showUserBlock = [can('users'), can('experts'), can('expertRequests'), can('manualVerification'), can('sessions')].some(Boolean)
  const showContentBlock = [can('faq'), can('categories'), can('identityProofs'), can('growthSpotlight'), can('feedPosts'), can('blog')].some(Boolean)
  const showModerationBlock = [can('reportedFeedPosts'), can('reportedUsers'), can('reportedExperts'), can('reportedChats'), can('reportedSessions')].some(Boolean)
  const showCommunicationBlock = [can('emailMarketing'), can('emailAccounts')].some(Boolean)
  const showSubscriptionBlock = [can('subscriptionPlans'), can('recordingStoragePlans'), can('subscriptionHistory')].some(Boolean)
  const showFinancialBlock = [can('paymentOptions'), can('payoutRequests'), can('referrals')].some(Boolean)

  return (
    <>
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
        <Menu
          popoutMenuOffset={{ mainAxis: 23 }}
          menuItemStyles={menuItemStyles(verticalNavOptions, theme)}
          renderExpandIcon={({ open }) => <RenderExpandIcon open={open} transitionDuration={transitionDuration} />}
          renderExpandedMenuItemIcon={{ icon: <i className='tabler-circle text-xs' /> }}
          menuSectionStyles={menuSectionStyles(verticalNavOptions, theme)}
        >
          {can('dashboard') && (
            <MenuItem href='/dashboard' icon={<i className='tabler-smart-home' />}>
              Dashboard
            </MenuItem>
          )}

          {showUserBlock && (
            <MenuSection label='USER MANAGEMENT'>
              {can('users') && (
                <MenuItem href='/apps/user' icon={<i className='tabler-user' />} exactMatch={false} activeUrl='/apps/user'>
                  User
                </MenuItem>
              )}
              {can('experts') && (
                <MenuItem
                  href='/apps/listener'
                  icon={<i className='tabler-user-star' />}
                  exactMatch={false}
                  activeUrl='/apps/listener'
                >
                  Expert
                </MenuItem>
              )}
              {can('expertRequests') && (
                <MenuItem href='/listener/request' icon={<i className='tabler-user-scan' />}>
                  Expert Request
                </MenuItem>
              )}
              {can('manualVerification') && (
                <MenuItem href='/apps/manual-verification' icon={<i className='tabler-badge' />}>
                  Verification
                </MenuItem>
              )}
              {can('sessions') && (
                <MenuItem href='/sessions' icon={<i className='tabler-calendar-time' />}>
                  Sessions
                </MenuItem>
              )}
              {can('clinicManagement') && (
                <MenuItem href='/clinic-management' icon={<i className='tabler-stethoscope' />}>
                  Clinic Management
                </MenuItem>
              )}
            </MenuSection>
          )}

          {showContentBlock && (
            <MenuSection label='CONTENT'>
              {can('blog') && (
                <MenuItem href='/blog-management' icon={<i className='tabler-article' />}>
                  Blog / News
                </MenuItem>
              )}
              {can('faq') && (
                <MenuItem href='/faq' icon={<i className='tabler-device-ipad-question' />}>
                  FAQ
                </MenuItem>
              )}
              {can('categories') && (
                <MenuItem href='/talk-topics' icon={<i className='tabler-message-circle' />}>
                  Category
                </MenuItem>
              )}
              {can('identityProofs') && (
                <MenuItem href='/identity-proofs' icon={<i className='tabler-id' />}>
                  Identity Proof
                </MenuItem>
              )}
              {can('growthSpotlight') && (
                <>
                  <MenuItem href='/growth-spotlight' icon={<i className='tabler-photo-star' />}>
                    Expert Spotlight
                  </MenuItem>
                  <MenuItem href='/user-growth-spotlight' icon={<i className='tabler-photo' />}>
                    User Spotlight
                  </MenuItem>
                </>
              )}
              {can('feedPosts') && (
                <MenuItem href='/feed/posts' icon={<i className='tabler-news' />}>
                  Feed Posts
                </MenuItem>
              )}
            </MenuSection>
          )}

          {showModerationBlock && (
            <MenuSection label='MODERATION'>
              {can('reportedFeedPosts') && (
                <MenuItem href='/feed/reported' icon={<i className='tabler-flag-3' />}>
                  Reported Feed Posts
                </MenuItem>
              )}
              {can('reportedUsers') && (
                <MenuItem href='/moderation/users' icon={<i className='tabler-user-exclamation' />}>
                  Reported Users
                </MenuItem>
              )}
              {can('reportedExperts') && (
                <MenuItem href='/moderation/experts' icon={<i className='tabler-shield-exclamation' />}>
                  Reported Experts
                </MenuItem>
              )}
              {can('reportedChats') && (
                <MenuItem href='/moderation/chats' icon={<i className='tabler-message-report' />}>
                  Reported Chats
                </MenuItem>
              )}
              {can('reportedSessions') && (
                <MenuItem href='/moderation/sessions' icon={<i className='tabler-video-off' />}>
                  Reported Sessions
                </MenuItem>
              )}
            </MenuSection>
          )}

          {showCommunicationBlock && (
            <MenuSection label='COMMUNICATIONS'>
              {can('emailMarketing') && (
                <MenuItem href='/email-marketing' icon={<i className='tabler-mail' />}>
                  Email Marketing
                </MenuItem>
              )}
              {can('emailAccounts') && (
                <MenuItem href='/email-accounts' icon={<i className='tabler-mail-cog' />}>
                  Email Accounts
                </MenuItem>
              )}
            </MenuSection>
          )}

          {showSubscriptionBlock && (
            <MenuSection label='SUBSCRIPTION'>
              {can('subscriptionPlans') && (
                <MenuItem href='/coin-plans' icon={<i className='tabler-coins' />}>
                  Subscription Plans
                </MenuItem>
              )}
              {can('recordingStoragePlans') && (
                <MenuItem href='/recording-plans' icon={<i className='tabler-cloud' />}>
                  Recording Storage Plans
                </MenuItem>
              )}
              {can('experts') && (
                <MenuItem href='/boost-plans' icon={<i className='tabler-lightning' />}>
                  Boost Plans
                </MenuItem>
              )}
              {can('subscriptionHistory') && (
                <MenuItem
                  href='/coin-plan-history'
                  exactMatch={false}
                  activeUrl='/coin-plan-history'
                  icon={<i className='tabler-history' />}
                >
                  Subscription History
                </MenuItem>
              )}
            </MenuSection>
          )}

          {showFinancialBlock && (
            <MenuSection label='FINANCIAL'>
              {can('paymentOptions') && (
                <MenuItem href='/payment-options' icon={<i className='tabler-cash' />}>
                  Payment Options
                </MenuItem>
              )}
              {can('payoutRequests') && (
                <MenuItem href='/payout-requests' icon={<i className='tabler-cash-banknote' />}>
                  Payout Request
                </MenuItem>
              )}
              {can('tipAnalytics') && (
                <MenuItem href='/tipping/analytics' icon={<i className='tabler-heart' />}>
                  Tip Analytics
                </MenuItem>
              )}
              {can('referrals') && (
                <MenuItem href='/referrals' icon={<i className='tabler-gift' />}>
                  Referrals
                </MenuItem>
              )}
            </MenuSection>
          )}

          <MenuSection label='SETTINGS'>
            {can('settings') && (
              <MenuItem href='/settings' icon={<i className='tabler-settings' />}>
                Settings
              </MenuItem>
            )}
            {can('profile') && (
              <MenuItem href='/profile' icon={<i className='tabler-user-circle' />}>
                Profile
              </MenuItem>
            )}
            {isOwnerAdmin(admin) && (
              <MenuItem href='/moderators' icon={<i className='tabler-shield-lock' />}>
                Moderators
              </MenuItem>
            )}
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
