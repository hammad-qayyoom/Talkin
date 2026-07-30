'use client'

import { useEffect, useState } from 'react'

import { useRouter } from 'next/navigation'

import axios from 'axios'

// MUI Imports
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import CircularProgress from '@mui/material/CircularProgress'
import Divider from '@mui/material/Divider'
import Grid from '@mui/material/Grid'
import Typography from '@mui/material/Typography'

// Config Import
import { baseURL, secretKey } from '@/config'
import { getAuthHeaders } from '@/utils/auth-headers'

const formatDuration = (seconds) => {
  if (!seconds || seconds <= 0) return '0s'
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  const s = Math.floor(seconds % 60)
  if (h > 0) return `${h}h ${m}m`
  if (m > 0) return `${m}m ${s}s`
  return `${s}s`
}

const ScreenShareAnalytics = () => {
  const [stats, setStats] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const router = useRouter()

  useEffect(() => {
    const fetchStats = async () => {
      setLoading(true)
      try {
        const response = await axios.get(`${baseURL}/api/v2/screen-share/admin/stats`, {
          headers: getAuthHeaders()
        })
        const data = response.data
        if (data.status) {
          setStats(data.data)
        } else {
          setError(data.message || 'Failed to fetch stats')
        }
      } catch (err) {
        setError('Failed to fetch screen sharing analytics')
      } finally {
        setLoading(false)
      }
    }

    fetchStats()
  }, [])

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 4, alignItems: 'center', height: '55vh' }}>
        <CircularProgress />
      </Box>
    )
  }

  if (error) {
    return (
      <Box sx={{ p: 4 }}>
        <Typography color='error' sx={{ mb: 2 }}>{error}</Typography>
        <Button variant='outlined' onClick={() => router.push('/settings?tab=screen_sharing')}>
          Back to Settings
        </Button>
      </Box>
    )
  }

  const allTime = stats?.allTime || {}
  const monthly = stats?.monthly || {}
  const weekly = stats?.weekly || {}
  const byCallType = stats?.byCallType || {}
  const topSessions = stats?.topSessions || []

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Box>
          <Typography variant='h4'>Screen Sharing Analytics</Typography>
          <Typography variant='body2' color='text.secondary'>
            Usage statistics for the screen sharing feature.
          </Typography>
        </Box>
        <Button variant='outlined' onClick={() => router.push('/settings?tab=screen_sharing')}>
          Back to Settings
        </Button>
      </Box>

      {/* Overview Cards */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item size={4}>
          <Card>
            <CardContent>
              <Typography variant='subtitle2' color='text.secondary'>All Time</Typography>
              <Typography variant='h4' sx={{ mt: 1 }}>{allTime.totalSessions || 0}</Typography>
              <Typography variant='body2' color='text.secondary'>sessions with screen share</Typography>
              <Divider sx={{ my: 2 }} />
              <Typography variant='body2'>
                Total: {formatDuration(allTime.totalDurationSeconds)}
              </Typography>
              <Typography variant='body2'>
                Avg: {formatDuration(allTime.avgDurationSeconds)}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item size={4}>
          <Card>
            <CardContent>
              <Typography variant='subtitle2' color='text.secondary'>This Month</Typography>
              <Typography variant='h4' sx={{ mt: 1 }}>{monthly.totalSessions || 0}</Typography>
              <Typography variant='body2' color='text.secondary'>sessions with screen share</Typography>
              <Divider sx={{ my: 2 }} />
              <Typography variant='body2'>
                Total: {formatDuration(monthly.totalDurationSeconds)}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item size={4}>
          <Card>
            <CardContent>
              <Typography variant='subtitle2' color='text.secondary'>This Week</Typography>
              <Typography variant='h4' sx={{ mt: 1 }}>{weekly.totalSessions || 0}</Typography>
              <Typography variant='body2' color='text.secondary'>sessions with screen share</Typography>
              <Divider sx={{ my: 2 }} />
              <Typography variant='body2'>
                Total: {formatDuration(weekly.totalDurationSeconds)}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* By Call Type */}
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 600 }}>
            By Call Type
          </Typography>
          <Divider sx={{ mb: 2 }} />
          <Grid container spacing={2}>
            {Object.entries(byCallType).map(([type, data]) => (
              <Grid item size={6} key={type}>
                <Box sx={{ p: 2, border: 1, borderColor: 'divider', borderRadius: 1 }}>
                  <Typography variant='subtitle2' sx={{ textTransform: 'capitalize' }}>
                    {type} Calls
                  </Typography>
                  <Typography variant='h5' sx={{ mt: 1 }}>{data.totalSessions}</Typography>
                  <Typography variant='body2' color='text.secondary'>
                    {formatDuration(data.totalDurationSeconds)}
                  </Typography>
                </Box>
              </Grid>
            ))}
            {Object.keys(byCallType).length === 0 && (
              <Grid item size={12}>
                <Typography variant='body2' color='text.secondary'>No screen sharing data yet.</Typography>
              </Grid>
            )}
          </Grid>
        </CardContent>
      </Card>

      {/* Top Sessions */}
      <Card>
        <CardContent>
          <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 600 }}>
            Top Screen Sharing Sessions
          </Typography>
          <Divider sx={{ mb: 2 }} />
          {topSessions.length === 0 ? (
            <Typography variant='body2' color='text.secondary'>No sessions with screen sharing yet.</Typography>
          ) : (
            <Box>
              {topSessions.map((session, index) => (
                <Box
                  key={index}
                  sx={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    py: 1.5,
                    borderBottom: index < topSessions.length - 1 ? 1 : 0,
                    borderColor: 'divider'
                  }}
                >
                  <Box>
                    <Typography variant='body2' fontWeight={500}>
                      {session.title || 'Untitled Session'}
                    </Typography>
                    <Typography variant='caption' color='text.secondary'>
                      {session.expertName} • {session.callType}
                    </Typography>
                  </Box>
                  <Typography variant='body2' fontWeight={600} color='primary'>
                    {formatDuration(session.screenShareDurationSeconds)}
                  </Typography>
                </Box>
              ))}
            </Box>
          )}
        </CardContent>
      </Card>
    </Box>
  )
}

export default ScreenShareAnalytics
