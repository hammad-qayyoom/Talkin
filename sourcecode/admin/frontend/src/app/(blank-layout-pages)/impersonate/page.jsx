'use client'

import { useState, useEffect } from 'react'
import Box from '@mui/material/Box'
import Typography from '@mui/material/Typography'
import Button from '@mui/material/Button'
import Chip from '@mui/material/Chip'
import IconButton from '@mui/material/IconButton'
import Tooltip from '@mui/material/Tooltip'
import CircularProgress from '@mui/material/CircularProgress'
import AdminPanelSettingsIcon from '@mui/icons-material/AdminPanelSettings'
import ExitToAppIcon from '@mui/icons-material/ExitToApp'
import PersonIcon from '@mui/icons-material/Person'
import ShieldIcon from '@mui/icons-material/Shield'

const ImpersonationBanner = () => {
  const [adminEmail, setAdminEmail] = useState('')
  const [targetUserName, setTargetUserName] = useState('')
  const [targetUserEmail, setTargetUserEmail] = useState('')
  const [elapsed, setElapsed] = useState('0m')
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    try {
      const backup = JSON.parse(localStorage.getItem('admin_impersonation_backup') || '{}')
      setAdminEmail(backup.adminEmail || 'Admin')

      const getStorage = JSON.parse(localStorage.getItem('GetStorage') || '{}')
      setTargetUserName(getStorage.loginUserName || 'User')
      setTargetUserEmail(getStorage.loginUserEmail || '')

      // Calculate elapsed time
      if (backup.startedAt) {
        const start = new Date(backup.startedAt)
        const updateElapsed = () => {
          const diff = Math.floor((Date.now() - start.getTime()) / 1000)
          const mins = Math.floor(diff / 60)
          const secs = diff % 60
          setElapsed(`${mins}m ${secs}s`)
        }
        updateElapsed()
        const interval = setInterval(updateElapsed, 1000)
        return () => clearInterval(interval)
      }
    } catch (e) {
      console.error('Failed to load impersonation data:', e)
    }
  }, [])

  const handleExitImpersonation = async () => {
    setLoading(true)
    try {
      // End audit log
      const backup = JSON.parse(localStorage.getItem('admin_impersonation_backup') || '{}')
      if (backup.adminToken) {
        try {
          await fetch('/api/admin/user/endImpersonation', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'key': process.env.NEXT_PUBLIC_SECRET_KEY || 'Eb6ek8wbjlrR3fiK36IXsUw',
              'Authorization': `Bearer ${backup.adminToken}`,
              'x-admin-uid': backup.adminUid || ''
            },
            body: JSON.stringify({ logId: null }) // Log ID would need to be stored if we want to track end time
          })
        } catch (e) {
          console.error('Failed to end impersonation log:', e)
        }
      }

      // Clean up impersonation state
      const getStorageStr = localStorage.getItem('GetStorage')
      if (getStorageStr) {
        const getStorage = JSON.parse(getStorageStr)
        delete getStorage['isImpersonation']
        delete getStorage['impersonationAdminUid']
        delete getStorage['impersonationStartedAt']
        localStorage.setItem('GetStorage', JSON.stringify(getStorage))
      }

      // Clear impersonation backup
      localStorage.removeItem('admin_impersonation_backup')

      // Restore admin session and redirect to admin panel
      if (backup.adminToken) {
        localStorage.setItem('admin_token', backup.adminToken)
        localStorage.setItem('uid', backup.adminUid || '')
        localStorage.setItem('email', backup.adminEmail || '')
      }

      // Redirect to admin panel
      window.location.href = '/'
    } catch (e) {
      console.error('Exit impersonation error:', e)
      // Fallback: just redirect to admin
      localStorage.removeItem('admin_impersonation_backup')
      window.location.href = '/'
    }
  }

  return (
    <Box
      sx={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        zIndex: 99999,
        bgcolor: '#1a1a2e',
        borderBottom: '3px solid #e94560',
        px: 2,
        py: 1,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        boxShadow: '0 4px 20px rgba(233, 69, 96, 0.3)',
      }}
    >
      {/* Left: Admin info + impersonation indicator */}
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
        <ShieldIcon sx={{ color: '#e94560', fontSize: 28 }} />
        <Box sx={{ display: 'flex', flexDirection: 'column' }}>
          <Typography sx={{ color: '#fff', fontWeight: 700, fontSize: 14, lineHeight: 1.2 }}>
            Admin Impersonation Session
          </Typography>
          <Typography sx={{ color: 'rgba(255,255,255,0.6)', fontSize: 11 }}>
            Logged in as: <strong style={{ color: '#e94560' }}>{targetUserName}</strong>
            {targetUserEmail && <span> ({targetUserEmail})</span>}
          </Typography>
        </Box>
        <Chip
          icon={<PersonIcon sx={{ fontSize: 14 }} />}
          label={`Viewing as user`}
          size='small'
          sx={{
            bgcolor: 'rgba(233, 69, 96, 0.2)',
            color: '#e94560',
            fontWeight: 600,
            fontSize: 11,
            '& .MuiChip-icon': { color: '#e94560' }
          }}
        />
      </Box>

      {/* Center: Elapsed time */}
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <Typography sx={{ color: 'rgba(255,255,255,0.5)', fontSize: 12 }}>
          Session active: {elapsed}
        </Typography>
      </Box>

      {/* Right: Exit button */}
      <Tooltip title='Exit impersonation and return to Admin Panel'>
        <Button
          variant='contained'
          onClick={handleExitImpersonation}
          disabled={loading}
          startIcon={loading ? <CircularProgress size={16} color='inherit' /> : <ExitToAppIcon />}
          sx={{
            bgcolor: '#e94560',
            color: '#fff',
            fontWeight: 700,
            textTransform: 'none',
            px: 3,
            py: 1,
            '&:hover': { bgcolor: '#c73650' },
          }}
        >
          {loading ? 'Exiting...' : 'Exit to Admin'}
        </Button>
      </Tooltip>
    </Box>
  )
}

export default function ImpersonationWrapperPage() {
  const [ready, setReady] = useState(false)

  useEffect(() => {
    // Small delay to ensure banner renders first
    const timer = setTimeout(() => setReady(true), 100)
    return () => clearTimeout(timer)
  }, [])

  return (
    <Box sx={{ width: '100vw', height: '100vh', display: 'flex', flexDirection: 'column' }}>
      {/* Impersonation Banner */}
      <ImpersonationBanner />

      {/* Flutter Web App in iframe */}
      <Box
        sx={{
          flex: 1,
          mt: '60px', // Height of banner
          width: '100%',
        }}
      >
        {ready ? (
          <iframe
            src='/app/index.html'
            style={{
              width: '100%',
              height: '100%',
              border: 'none',
            }}
            title='User App'
          />
        ) : (
          <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
            <CircularProgress size={60} />
          </Box>
        )}
      </Box>
    </Box>
  )
}
