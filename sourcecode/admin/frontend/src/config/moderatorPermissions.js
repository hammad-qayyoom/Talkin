export const MODERATOR_SECTIONS = [
  { key: 'dashboard', label: 'Dashboard', group: 'Overview', path: '/dashboard' },
  { key: 'users', label: 'Users', group: 'User Management', path: '/apps/user' },
  { key: 'experts', label: 'Experts', group: 'User Management', path: '/apps/listener' },
  { key: 'expertRequests', label: 'Expert Requests', group: 'User Management', path: '/listener/request' },
  { key: 'manualVerification', label: 'Verification', group: 'User Management', path: '/apps/manual-verification' },
  { key: 'sessions', label: 'Sessions', group: 'User Management', path: '/sessions' },
  { key: 'blog', label: 'Blog / News', group: 'Content', path: '/blog-management' },
  { key: 'faq', label: 'FAQ', group: 'Content', path: '/faq' },
  { key: 'categories', label: 'Category', group: 'Content', path: '/talk-topics' },
  { key: 'identityProofs', label: 'Identity Proof', group: 'Content', path: '/identity-proofs' },
  { key: 'growthSpotlight', label: 'Growth Spotlight', group: 'Content', path: '/growth-spotlight' },
  { key: 'feedPosts', label: 'Feed Posts', group: 'Content', path: '/feed/posts' },
  { key: 'reportedFeedPosts', label: 'Reported Feed Posts', group: 'Moderation', path: '/feed/reported' },
  { key: 'reportedUsers', label: 'Reported Users', group: 'Moderation', path: '/moderation/users' },
  { key: 'reportedExperts', label: 'Reported Experts', group: 'Moderation', path: '/moderation/experts' },
  { key: 'reportedChats', label: 'Reported Chats', group: 'Moderation', path: '/moderation/chats' },
  { key: 'reportedSessions', label: 'Reported Sessions', group: 'Moderation', path: '/moderation/sessions' },
  { key: 'emailMarketing', label: 'Email Marketing', group: 'Communications', path: '/email-marketing' },
  { key: 'emailAccounts', label: 'Email Accounts', group: 'Communications', path: '/email-accounts' },
  { key: 'subscriptionPlans', label: 'Subscription Plans', group: 'Subscription', path: '/coin-plans' },
  { key: 'subscriptionHistory', label: 'Subscription History', group: 'Subscription', path: '/coin-plan-history' },
  { key: 'paymentOptions', label: 'Payment Options', group: 'Financial', path: '/payment-options' },
  { key: 'payoutRequests', label: 'Payout Requests', group: 'Financial', path: '/payout-requests' },
  { key: 'referrals', label: 'Referrals', group: 'Financial', path: '/referrals' },
  { key: 'settings', label: 'Settings', group: 'Settings', path: '/settings' },
  { key: 'profile', label: 'Profile', group: 'Settings', path: '/profile' }
]

export const DEFAULT_MODERATOR_PERMISSIONS = MODERATOR_SECTIONS.reduce((permissions, section) => {
  permissions[section.key] = false

  return permissions
}, {})

const ROUTE_PERMISSIONS = [
  { prefix: '/access-denied', permission: null },
  { prefix: '/moderators', permission: 'ownerOnly' },
  { prefix: '/apps/dashboard', permission: 'dashboard' },
  { prefix: '/dashboard', permission: 'dashboard' },
  { prefix: '/apps/user', permission: 'users' },
  { prefix: '/apps/listener', permission: 'experts' },
  { prefix: '/listener/request', permission: 'expertRequests' },
  { prefix: '/listener/list', permission: 'experts' },
  { prefix: '/listener', permission: 'experts' },
  { prefix: '/apps/manual-verification', permission: 'manualVerification' },
  { prefix: '/sessions', permission: 'sessions' },
  { prefix: '/blog-management', permission: 'blog' },
  { prefix: '/blog', permission: null },
  { prefix: '/faq', permission: 'faq' },
  { prefix: '/talk-topics', permission: 'categories' },
  { prefix: '/identity-proofs', permission: 'identityProofs' },
  { prefix: '/growth-spotlight', permission: 'growthSpotlight' },
  { prefix: '/feed/posts', permission: 'feedPosts' },
  { prefix: '/feed/reported', permission: 'reportedFeedPosts' },
  { prefix: '/moderation/users', permission: 'reportedUsers' },
  { prefix: '/moderation/experts', permission: 'reportedExperts' },
  { prefix: '/moderation/chats', permission: 'reportedChats' },
  { prefix: '/moderation/sessions', permission: 'reportedSessions' },
  { prefix: '/email-marketing', permission: 'emailMarketing' },
  { prefix: '/email-accounts', permission: 'emailAccounts' },
  { prefix: '/coin-plans', permission: 'subscriptionPlans' },
  { prefix: '/coin-plan-history', permission: 'subscriptionHistory' },
  { prefix: '/payment-options', permission: 'paymentOptions' },
  { prefix: '/payout-requests', permission: 'payoutRequests' },
  { prefix: '/referrals', permission: 'referrals' },
  { prefix: '/settings', permission: 'settings' },
  { prefix: '/profile', permission: 'profile' }
].sort((a, b) => b.prefix.length - a.prefix.length)

export const normalizeModeratorPermissions = permissions => {
  return MODERATOR_SECTIONS.reduce((normalized, section) => {
    normalized[section.key] = permissions?.[section.key] === true

    return normalized
  }, {})
}

export const normalizeAdminSession = admin => {
  if (!admin) return null

  return {
    _id: admin._id || '',
    uid: admin.uid || '',
    name: admin.name || '',
    email: admin.email || '',
    image: admin.image || '',
    role: admin.role || 'owner',
    permissions: normalizeModeratorPermissions(admin.permissions),
    isActive: admin.isActive !== false
  }
}

export const getStoredAdmin = () => {
  if (typeof window === 'undefined') return null

  try {
    return normalizeAdminSession(JSON.parse(localStorage.getItem('user') || 'null'))
  } catch (error) {
    return null
  }
}

export const isOwnerAdmin = admin => !admin?.role || admin.role !== 'moderator'

export const hasModeratorPermission = (admin, permissionKey) => {
  if (!permissionKey) return true
  if (permissionKey === 'ownerOnly') return isOwnerAdmin(admin)
  if (isOwnerAdmin(admin)) return true

  return admin?.permissions?.[permissionKey] === true
}

export const getPermissionForPath = pathname => {
  const normalizedPath = pathname || '/'

  const match = ROUTE_PERMISSIONS.find(route => {
    return normalizedPath === route.prefix || normalizedPath.startsWith(`${route.prefix}/`)
  })

  return match ? match.permission : 'ownerOnly'
}

export const canAccessPath = (admin, pathname) => {
  return hasModeratorPermission(admin, getPermissionForPath(pathname))
}

export const getFirstAllowedPath = admin => {
  if (isOwnerAdmin(admin)) return '/dashboard'

  const firstAllowedSection = MODERATOR_SECTIONS.find(section => admin?.permissions?.[section.key] === true)

  return firstAllowedSection?.path || '/access-denied'
}
