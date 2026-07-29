'use client'

import { useEffect, useState } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import Alert from '@mui/material/Alert'
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import CircularProgress from '@mui/material/CircularProgress'
import Divider from '@mui/material/Divider'
import FormControlLabel from '@mui/material/FormControlLabel'
import Grid from '@mui/material/Grid'
import Switch from '@mui/material/Switch'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'

import { updateSettings } from '@/redux-store/slices/settings'

const CalendarIntegrationSettings = () => {
  const dispatch = useDispatch()
  const { settings, loading } = useSelector(state => state.settings)

  const [formData, setFormData] = useState({
    calendarIntegrationEnabled: false,
    calendarSyncIntervalMinutes: 15,
    calendarConflictBufferMinutes: 10,
    calendarMaxSyncRetries: 3,
    calendarSyncBatchSize: 100,
    calendarGoogleOAuthClientId: '',
    calendarGoogleOAuthClientSecret: '',
    calendarGoogleOAuthRedirectUri: ''
  })

  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (settings) {
      setFormData({
        calendarIntegrationEnabled: settings.calendarIntegrationEnabled ?? false,
        calendarSyncIntervalMinutes: settings.calendarSyncIntervalMinutes ?? 15,
        calendarConflictBufferMinutes: settings.calendarConflictBufferMinutes ?? 10,
        calendarMaxSyncRetries: settings.calendarMaxSyncRetries ?? 3,
        calendarSyncBatchSize: settings.calendarSyncBatchSize ?? 100,
        calendarGoogleOAuthClientId: settings.calendarGoogleOAuthClientId ?? '',
        calendarGoogleOAuthClientSecret: settings.calendarGoogleOAuthClientSecret ?? '',
        calendarGoogleOAuthRedirectUri: settings.calendarGoogleOAuthRedirectUri ?? ''
      })
    }
  }, [settings])

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))
  }

  const handleSave = async () => {
    setSaving(true)
    try {
      const payload = { ...settings, ...formData }
      await dispatch(updateSettings(payload)).unwrap()
    } catch (error) {
      // Error toast is handled by the Redux thunk
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Grid container spacing={6}>
      <Grid item size={12}>
        <Typography variant='h6' sx={{ mb: 2 }}>
          Calendar Integration
        </Typography>
        <Typography variant='body2' color='text.secondary' sx={{ mb: 4 }}>
          Connect external calendars (Google Calendar, Apple Calendar) to automatically block busy time slots
          and prevent double bookings. External calendar events will be considered during slot generation.
        </Typography>
      </Grid>

      <Grid item size={12} md={8}>
        <Card>
          <CardContent>
            <Typography variant='subtitle1' sx={{ mb: 3, fontWeight: 600 }}>
              General Settings
            </Typography>

            <FormControlLabel
              control={
                <Switch
                  checked={formData.calendarIntegrationEnabled}
                  onChange={e => handleChange('calendarIntegrationEnabled', e.target.checked)}
                  color='primary'
                />
              }
              label='Enable Calendar Integration'
            />
            <Typography variant='body2' color='text.secondary' sx={{ ml: 6, mb: 3 }}>
              When enabled, experts can connect their external calendars to sync busy times.
            </Typography>

            <Divider sx={{ my: 3 }} />

            <Typography variant='subtitle1' sx={{ mb: 3, fontWeight: 600 }}>
              Sync Settings
            </Typography>

            <Grid container spacing={3}>
              <Grid item size={12} sm={6}>
                <TextField
                  fullWidth
                  label='Sync Interval (minutes)'
                  type='number'
                  value={formData.calendarSyncIntervalMinutes}
                  onChange={e => handleChange('calendarSyncIntervalMinutes', parseInt(e.target.value) || 15)}
                  inputProps={{ min: 5, max: 60 }}
                  helperText='How often to sync with external calendars (5-60 minutes)'
                />
              </Grid>
              <Grid item size={12} sm={6}>
                <TextField
                  fullWidth
                  label='Conflict Buffer (minutes)'
                  type='number'
                  value={formData.calendarConflictBufferMinutes}
                  onChange={e => handleChange('calendarConflictBufferMinutes', parseInt(e.target.value) || 10)}
                  inputProps={{ min: 0, max: 30 }}
                  helperText='Extra buffer time around external events (0-30 minutes)'
                />
              </Grid>
              <Grid item size={12} sm={6}>
                <TextField
                  fullWidth
                  label='Max Sync Retries'
                  type='number'
                  value={formData.calendarMaxSyncRetries}
                  onChange={e => handleChange('calendarMaxSyncRetries', parseInt(e.target.value) || 3)}
                  inputProps={{ min: 1, max: 10 }}
                  helperText='Number of retries before marking connection as error'
                />
              </Grid>
              <Grid item size={12} sm={6}>
                <TextField
                  fullWidth
                  label='Sync Batch Size'
                  type='number'
                  value={formData.calendarSyncBatchSize}
                  onChange={e => handleChange('calendarSyncBatchSize', parseInt(e.target.value) || 100)}
                  inputProps={{ min: 10, max: 500 }}
                  helperText='Max events to process per sync batch'
                />
              </Grid>
            </Grid>
          </CardContent>
        </Card>
      </Grid>

      <Grid item size={12} md={8}>
        <Card>
          <CardContent>
            <Typography variant='subtitle1' sx={{ mb: 3, fontWeight: 600 }}>
              Google Calendar (OAuth 2.0)
            </Typography>
            <Alert severity='info' sx={{ mb: 3 }}>
              Create a Google Cloud project, enable Calendar API, and create OAuth 2.0 credentials.
              Set the authorized redirect URI to your backend callback URL.
            </Alert>

            <Grid container spacing={3}>
              <Grid item size={12}>
                <TextField
                  fullWidth
                  label='OAuth Client ID'
                  value={formData.calendarGoogleOAuthClientId}
                  onChange={e => handleChange('calendarGoogleOAuthClientId', e.target.value)}
                  placeholder='your-client-id.apps.googleusercontent.com'
                />
              </Grid>
              <Grid item size={12}>
                <TextField
                  fullWidth
                  label='OAuth Client Secret'
                  type='password'
                  value={formData.calendarGoogleOAuthClientSecret}
                  onChange={e => handleChange('calendarGoogleOAuthClientSecret', e.target.value)}
                />
              </Grid>
              <Grid item size={12}>
                <TextField
                  fullWidth
                  label='Redirect URI'
                  value={formData.calendarGoogleOAuthRedirectUri}
                  onChange={e => handleChange('calendarGoogleOAuthRedirectUri', e.target.value)}
                  placeholder='https://your-backend.com/api/v2/calendar/callback/google'
                  helperText='Must match the redirect URI configured in Google Cloud Console'
                />
              </Grid>
            </Grid>

            <Divider sx={{ my: 3 }} />

            <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 600 }}>
              Apple Calendar (CalDAV)
            </Typography>
            <Typography variant='body2' color='text.secondary' sx={{ mb: 2 }}>
              Apple Calendar uses CalDAV protocol. Experts connect using their Apple ID and an app-specific
              password (generated at appleid.apple.com). No server-side OAuth configuration is needed.
            </Typography>
            <Alert severity='info'>
              Experts must enable 2FA on their Apple ID and generate an app-specific password under
              Security &gt; App-Specific Passwords. This password is entered directly in the Flutter app.
            </Alert>
          </CardContent>
        </Card>
      </Grid>

      <Grid item size={12} md={8}>
        <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
          <Button
            variant='contained'
            onClick={handleSave}
            disabled={saving}
            startIcon={saving ? <CircularProgress size={16} /> : null}
          >
            {saving ? 'Saving...' : 'Save Settings'}
          </Button>
        </Box>
      </Grid>
    </Grid>
  )
}

export default CalendarIntegrationSettings
