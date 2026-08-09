'use client'

import { useEffect, useState, Suspense, useCallback } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { auth } from '@/libs/firebase'
import { signInWithCustomToken } from 'firebase/auth'
import { apiInstance } from '@/utils/ApiInstance'
import CircularProgress from '@mui/material/CircularProgress'
import Typography from '@mui/material/Typography'
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'
import Alert from '@mui/material/Alert'
import ShieldIcon from '@mui/icons-material/Shield'
import PersonIcon from '@mui/icons-material/Person'

const SimulateUserContent = () => {
  const [error, setError] = useState('')
  const [status, setStatus] = useState('Initializing simulation...')
  const [confirmOpen, setConfirmOpen] = useState(true)
  const [targetUser, setTargetUser] = useState(null)
  const [loading, setLoading] = useState(false)
  const searchParams = useSearchParams()
  const uid = searchParams.get('uid')
  const router = useRouter()

  // Fetch target user details for confirmation dialog
  useEffect(() => {
    if (!uid) return

    const fetchTargetUser = async () => {
      try {
        const adminUid = localStorage.getItem('uid') || ''
        const token = localStorage.getItem('admin_token') || ''
        const response = await apiInstance.get(`/api/admin/user/listRegisteredUsers?userId=${uid}`, {
          headers: {
            'x-admin-uid': adminUid,
            'Authorization': `Bearer ${token}`
          }
        })
        const body = response.data !== undefined ? response.data : response
        let userData = null
        if (Array.isArray(body)) userData = body[0]
        else if (Array.isArray(body.data)) userData = body.data[0]
        else userData = body.data || body

        if (userData) setTargetUser(userData)
      } catch (err) {
        console.error('Failed to fetch target user:', err)
      }
    }

    fetchTargetUser()
  }, [uid])

  const handleConfirmImpersonation = useCallback(async () => {
    setConfirmOpen(false)
    setLoading(true)

    if (!uid) {
      setError('User UID is missing.')
      return
    }

    try {
      setStatus('Saving admin session...')
      // Save admin session for restoration later
      const adminToken = localStorage.getItem('admin_token') || ''
      const adminUid = localStorage.getItem('uid') || ''
      const adminEmail = localStorage.getItem('email') || ''

      // Store admin session backup under a separate key
      const impersonationBackup = {
        adminToken,
        adminUid,
        adminEmail,
        startedAt: new Date().toISOString(),
        targetUserId: uid,
      }
      localStorage.setItem('admin_impersonation_backup', JSON.stringify(impersonationBackup))

      setStatus('Fetching custom token...')
      const response = await apiInstance.get(`/api/admin/user/simulate/${uid}`, {
        headers: {
          'x-admin-uid': adminUid,
          'Authorization': `Bearer ${adminToken}`
        }
      })

      const responseBody = response.data !== undefined ? response.data : response
      const responseStatus = response.status !== undefined ? response.status : responseBody.status

      if (!responseStatus || responseStatus === false) {
        throw new Error(responseBody.message || 'Failed to generate custom token')
      }

      const customToken = responseBody.data?.customToken || responseBody.customToken
      if (!customToken) {
        throw new Error('Custom token is missing from the response.')
      }

      setStatus('Authenticating with Firebase...')
      // Sign in with custom token
      // NOTE: This replaces the current Firebase auth state
      await signInWithCustomToken(auth, customToken)

      setStatus('Fetching user profile...')
      const idToken = await auth.currentUser.getIdToken()

      const userDetailsRes = await apiInstance.get(`/api/admin/user/listRegisteredUsers?userId=${uid}`, {
        headers: {
          'x-admin-uid': adminUid,
          'Authorization': `Bearer ${adminToken}`
        }
      })
      const userDetailsBody = userDetailsRes.data !== undefined ? userDetailsRes.data : userDetailsRes

      let userData = null
      if (Array.isArray(userDetailsBody)) {
        userData = userDetailsBody[0]
      } else if (Array.isArray(userDetailsBody.data)) {
        userData = userDetailsBody.data[0]
      } else {
        userData = userDetailsBody.data || userDetailsBody
      }

      setStatus('Setting up impersonation session...')

      const fid = searchParams.get('fid')
      const targetFirebaseId = userData?.firebaseId || fid || userData?._id || uid

      // Inject session data into GetStorage for the Flutter app
      try {
        const getStorageStr = window.localStorage.getItem('GetStorage')
        let getStorage = getStorageStr ? JSON.parse(getStorageStr) : {}

        getStorage['isLogin'] = true
        getStorage['loginUserFirebaseId'] = targetFirebaseId
        getStorage['isFillProfile'] = true
        getStorage['isGuestMode'] = false
        getStorage['isSeenOnBoarding'] = true
        getStorage['isNewUser'] = false
        getStorage['userExist'] = true

        if (userData) {
          getStorage['loginUserId'] = userData._id || userData.id || ''
          getStorage['loginUserName'] = userData.fullName || ''
          getStorage['loginUserEmail'] = userData.email || ''
          getStorage['loginUserNickName'] = userData.nickName || userData.fullName || ''
          getStorage['loginUserProfilePic'] = userData.profilePic || ''
          getStorage['loginUserPhoneNumber'] = userData.phoneNumber || ''
          getStorage['loginUserBirthDate'] = userData.birthDate || ''
          getStorage['loginUserGender'] = userData.gender || 'Male'
          getStorage['isListener'] = userData.isListener || false
          getStorage['loginType'] = userData.loginType || 0
          getStorage['countryCode'] = userData.countryCode || ''
          getStorage['country'] = userData.country || ''
          getStorage['userCoin'] = String(userData.coin || userData.coins || '0.00')
          if (userData.isListener && userData.listenerId) {
            getStorage['loginListenerId'] = userData.listenerId
          }
        }

        // Mark as impersonation session
        getStorage['isImpersonation'] = true
        getStorage['impersonationAdminUid'] = adminUid
        getStorage['impersonationStartedAt'] = new Date().toISOString()

        window.localStorage.setItem('GetStorage', JSON.stringify(getStorage))
      } catch (e) {
        console.error('Failed to inject GetStorage state', e)
      }

      setStatus('Redirecting to app...')

      // Redirect directly to the Flutter Web app
      window.location.href = `/app/index.html`

    } catch (err) {
      console.error('Simulation error:', err)
      setError(err.message || 'An error occurred during simulation.')
      setLoading(false)
    }
  }, [uid, searchParams])

  const handleCancel = useCallback(() => {
    // Return to admin panel
    window.history.back()
  }, [])

  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        height: '100vh',
        backgroundColor: '#f5f5f5'
      }}
    >
      {/* Confirmation Dialog */}
      <Dialog open={confirmOpen} onClose={handleCancel} maxWidth='sm' fullWidth>
        <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
          <ShieldIcon color='warning' />
          <span>Confirm User Impersonation</span>
        </DialogTitle>
        <DialogContent>
          <Alert severity='warning' sx={{ mb: 2 }}>
            You are about to log in as another user. This action will be logged for audit purposes.
          </Alert>

          {targetUser && (
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, p: 2, bgcolor: 'grey.50', borderRadius: 1 }}>
              <PersonIcon sx={{ fontSize: 40, color: 'primary.main' }} />
              <Box>
                <Typography variant='subtitle1' fontWeight='bold'>
                  {targetUser.fullName || 'Unknown User'}
                </Typography>
                <Typography variant='body2' color='text.secondary'>
                  {targetUser.email || targetUser.uniqueId || targetUser._id}
                </Typography>
                {targetUser.isListener && (
                  <Typography variant='caption' color='primary'>
                    Expert / Listener Account
                  </Typography>
                )}
              </Box>
            </Box>
          )}

          <Typography variant='body2' sx={{ mt: 2 }}>
            This will open the application as this user. You will see their profile, bookings, consultations, subscriptions, wallet, notifications, and all other data.
          </Typography>
          <Typography variant='body2' color='text.secondary' sx={{ mt: 1 }}>
            A floating banner will allow you to exit impersonation and return to the admin panel at any time.
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCancel} color='secondary'>
            Cancel
          </Button>
          <Button
            onClick={handleConfirmImpersonation}
            variant='contained'
            color='primary'
            disabled={loading}
            startIcon={loading ? <CircularProgress size={16} /> : <PersonIcon />}
          >
            {loading ? 'Starting...' : 'Login as User'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Loading State */}
      {loading && !confirmOpen && (
        <>
          <CircularProgress size={60} sx={{ mb: 4 }} />
          <Typography variant='h5' color='textPrimary'>
            {status}
          </Typography>
          <Typography variant='body2' color='textSecondary' sx={{ mt: 2 }}>
            You will be redirected shortly...
          </Typography>
        </>
      )}

      {/* Error State */}
      {error && (
        <Box sx={{ textAlign: 'center', maxWidth: 500 }}>
          <Typography color='error' variant='h6' sx={{ mb: 2 }}>
            {error}
          </Typography>
          <Button variant='contained' onClick={() => window.history.back()}>
            Return to Admin Panel
          </Button>
        </Box>
      )}
    </Box>
  )
}

const SimulateUserPage = () => {
  return (
    <Suspense fallback={<Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}><CircularProgress /></Box>}>
      <SimulateUserContent />
    </Suspense>
  )
}

export default SimulateUserPage
