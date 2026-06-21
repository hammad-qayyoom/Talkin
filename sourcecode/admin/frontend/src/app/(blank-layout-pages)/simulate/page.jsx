'use client'

import { useEffect, useState, Suspense } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { auth } from '@/libs/firebase'
import { signInWithCustomToken } from 'firebase/auth'
import { apiInstance } from '@/utils/ApiInstance'
import CircularProgress from '@mui/material/CircularProgress'
import Typography from '@mui/material/Typography'
import Box from '@mui/material/Box'

const SimulateUserContent = () => {
  const [error, setError] = useState('')
  const [status, setStatus] = useState('Initializing simulation...')
  const searchParams = useSearchParams()
  const uid = searchParams.get('uid')
  const router = useRouter()

  useEffect(() => {
    const startSimulation = async () => {
      if (!uid) {
        setError('User UID is missing.')
        return
      }

      try {
        setStatus('Fetching custom token...')
        // Call backend to get custom token
        const adminUid = typeof localStorage !== 'undefined' ? localStorage.getItem('uid') : ''
        const token = typeof localStorage !== 'undefined' ? localStorage.getItem('admin_token') : ''
        const response = await apiInstance.get(`/api/admin/user/simulate/${uid}`, {
          headers: {
            'x-admin-uid': adminUid || '',
            'Authorization': token ? `Bearer ${token}` : ''
          }
        })
        
        // Since apiInstance has an interceptor that returns response.data,
        // response might already be the body, or it might be the axios response object.
        const responseBody = response.data !== undefined ? response.data : response;
        const responseStatus = response.status !== undefined ? response.status : responseBody.status;

        if (!responseStatus || responseStatus === false) {
          throw new Error(responseBody.message || 'Failed to generate custom token')
        }

        const customToken = responseBody.data?.customToken || responseBody.customToken;
        if (!customToken) {
           throw new Error('Custom token is missing from the response.');
        }

        setStatus('Authenticating with Firebase...')
        // Sign in with custom token using the existing Firebase App
        // NOTE: This will log the admin out of the admin panel in this browser session
        await signInWithCustomToken(auth, customToken)

        setStatus('Fetching user profile...')
        // Fetch user profile from Firebase to populate GetStorage
        const idToken = await auth.currentUser.getIdToken()
        
        // Call the app's profile endpoint
        const userDetailsRes = await apiInstance.get(`/api/admin/user/listRegisteredUsers?userId=${uid}`, {
          headers: {
            'x-admin-uid': adminUid || '',
            'Authorization': token ? `Bearer ${token}` : ''
          }
        })
        const userDetailsBody = userDetailsRes.data !== undefined ? userDetailsRes.data : userDetailsRes;
        
        // Data could be directly in userDetailsBody or in userDetailsBody.data
        let userData = null;
        if (Array.isArray(userDetailsBody)) {
            userData = userDetailsBody[0];
        } else if (Array.isArray(userDetailsBody.data)) {
            userData = userDetailsBody.data[0];
        } else {
            userData = userDetailsBody.data || userDetailsBody;
        }

        setStatus('Redirecting to app...')
        
        const fid = searchParams.get('fid')
        const targetFirebaseId = fid || userData?.firebaseId || userData?._id || uid;

        // Inject session data into GetStorage for the Flutter app
        try {
          const getStorageStr = window.localStorage.getItem('GetStorage');
          let getStorage = getStorageStr ? JSON.parse(getStorageStr) : {};
          
          getStorage['isLogin'] = true;
          getStorage['loginUserFirebaseId'] = targetFirebaseId;
          getStorage['isFillProfile'] = true;
          getStorage['isGuestMode'] = false;
          getStorage['isSeenOnBoarding'] = true;
          
          if (userData) {
             getStorage['loginUserId'] = userData._id || userData.id || '';
             getStorage['loginUserName'] = userData.fullName || '';
             getStorage['loginUserEmail'] = userData.email || '';
             getStorage['isListener'] = userData.isListener || false;
             getStorage['loginType'] = userData.loginType || 0;
             if (userData.isListener && userData.listenerId) {
                getStorage['loginListenerId'] = userData.listenerId;
             }
          }
          
          window.localStorage.setItem('GetStorage', JSON.stringify(getStorage));
        } catch(e) {
          console.error("Failed to inject GetStorage state", e);
        }

        // Redirect to the Flutter Web app
        // We do not need to pass tokens in URL since we already authenticated Firebase and injected GetStorage
        window.location.href = `/app/index.html`

      } catch (err) {
        console.error('Simulation error:', err)
        setError(err.message || 'An error occurred during simulation.')
      }
    }

    startSimulation()
  }, [uid, router])

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
      {error ? (
        <Typography color="error" variant="h6">{error}</Typography>
      ) : (
        <>
          <CircularProgress size={60} sx={{ mb: 4 }} />
          <Typography variant="h5" color="textPrimary">
            {status}
          </Typography>
          <Typography variant="body2" color="textSecondary" sx={{ mt: 2 }}>
            You will be redirected shortly...
          </Typography>
        </>
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
