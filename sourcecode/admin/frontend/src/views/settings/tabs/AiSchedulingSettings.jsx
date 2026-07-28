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
import MenuItem from '@mui/material/MenuItem'

import { updateSettings } from '@/redux-store/slices/settings'
import axios from 'axios'

const AiSchedulingSettings = () => {
  const dispatch = useDispatch()
  const { settings, loading } = useSelector(state => state.settings)

  const [formData, setFormData] = useState({
    aiSmartSchedulingEnabled: false,
    aiSmartSchedulingProvider: 'none',
    aiSmartSchedulingOpenaiKey: '',
    aiSmartSchedulingOpenaiModel: 'gpt-4o-mini',
    aiSmartSchedulingMaxDaysAhead: 7,
    aiSmartSchedulingMaxSuggestions: 5,
    aiSmartSchedulingAutoRoomCreationEnabled: true,
    aiSmartSchedulingAutoRoomMinutesBefore: 10,
    aiSmartSchedulingReminderMinutesBefore: 10
  })

  const [analytics, setAnalytics] = useState(null)
  const [analyticsLoading, setAnalyticsLoading] = useState(false)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (settings) {
      setFormData({
        aiSmartSchedulingEnabled: settings.aiSmartSchedulingEnabled ?? false,
        aiSmartSchedulingProvider: settings.aiSmartSchedulingProvider ?? 'none',
        aiSmartSchedulingOpenaiKey: settings.aiSmartSchedulingOpenaiKey ?? '',
        aiSmartSchedulingOpenaiModel: settings.aiSmartSchedulingOpenaiModel ?? 'gpt-4o-mini',
        aiSmartSchedulingMaxDaysAhead: settings.aiSmartSchedulingMaxDaysAhead ?? 7,
        aiSmartSchedulingMaxSuggestions: settings.aiSmartSchedulingMaxSuggestions ?? 5,
        aiSmartSchedulingAutoRoomCreationEnabled: settings.aiSmartSchedulingAutoRoomCreationEnabled ?? true,
        aiSmartSchedulingAutoRoomMinutesBefore: settings.aiSmartSchedulingAutoRoomMinutesBefore ?? 10,
        aiSmartSchedulingReminderMinutesBefore: settings.aiSmartSchedulingReminderMinutesBefore ?? 10
      })
    }
  }, [settings])

  const fetchAnalytics = async () => {
    setAnalyticsLoading(true)
    try {
      const response = await axios.get('/api/v2/smart-scheduling/analytics', {
        headers: { key: process.env.NEXT_PUBLIC_ADMIN_SECRET_KEY }
      })
      if (response.data?.status) {
        setAnalytics(response.data.data)
      }
    } catch (error) {
      console.error('Failed to fetch analytics:', error)
    } finally {
      setAnalyticsLoading(false)
    }
  }

  useEffect(() => {
    fetchAnalytics()
  }, [])

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
          AI Smart Scheduling
        </Typography>
        <Typography variant='body2' color='text.secondary' sx={{ mb: 4 }}>
          Configure AI-powered appointment scheduling for offline experts. When enabled, users will see
          intelligent slot suggestions instead of a simple "offline" message.
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
                  checked={formData.aiSmartSchedulingEnabled}
                  onChange={e => handleChange('aiSmartSchedulingEnabled', e.target.checked)}
                  color='primary'
                />
              }
              label='Enable AI Smart Scheduling'
              sx={{ mb: 2 }}
            />
            <Typography variant='body2' color='text.secondary' sx={{ mb: 3, ml: 6 }}>
              When disabled, users will see the standard "Expert is offline" message.
            </Typography>

            <Divider sx={{ my: 3 }} />

            <Typography variant='subtitle1' sx={{ mb: 3, fontWeight: 600 }}>
              Scheduling Rules
            </Typography>

            <Grid container spacing={3}>
              <Grid item size={12} sm={6}>
                <TextField
                  fullWidth
                  label='Max Days Ahead'
                  type='number'
                  value={formData.aiSmartSchedulingMaxDaysAhead}
                  onChange={e => handleChange('aiSmartSchedulingMaxDaysAhead', parseInt(e.target.value) || 7)}
                  inputProps={{ min: 1, max: 30 }}
                  helperText='How far ahead to search for available slots (1-30 days)'
                />
              </Grid>
              <Grid item size={12} sm={6}>
                <TextField
                  fullWidth
                  label='Max Suggestions per Request'
                  type='number'
                  value={formData.aiSmartSchedulingMaxSuggestions}
                  onChange={e => handleChange('aiSmartSchedulingMaxSuggestions', parseInt(e.target.value) || 5)}
                  inputProps={{ min: 1, max: 10 }}
                  helperText='Number of slot suggestions to show (1-10)'
                />
              </Grid>
            </Grid>

            <Divider sx={{ my: 3 }} />

            <Typography variant='subtitle1' sx={{ mb: 3, fontWeight: 600 }}>
              Automatic Room Creation
            </Typography>

            <FormControlLabel
              control={
                <Switch
                  checked={formData.aiSmartSchedulingAutoRoomCreationEnabled}
                  onChange={e => handleChange('aiSmartSchedulingAutoRoomCreationEnabled', e.target.checked)}
                  color='primary'
                />
              }
              label='Enable Automatic Room Creation'
              sx={{ mb: 2 }}
            />

            <Grid container spacing={3}>
              <Grid item size={12} sm={6}>
                <TextField
                  fullWidth
                  label='Minutes Before Session'
                  type='number'
                  value={formData.aiSmartSchedulingAutoRoomMinutesBefore}
                  onChange={e => handleChange('aiSmartSchedulingAutoRoomMinutesBefore', parseInt(e.target.value) || 10)}
                  inputProps={{ min: 5, max: 30 }}
                  helperText='Create consultation room this many minutes before session'
                />
              </Grid>
              <Grid item size={12} sm={6}>
                <TextField
                  fullWidth
                  label='Reminder Minutes Before'
                  type='number'
                  value={formData.aiSmartSchedulingReminderMinutesBefore}
                  onChange={e => handleChange('aiSmartSchedulingReminderMinutesBefore', parseInt(e.target.value) || 10)}
                  inputProps={{ min: 5, max: 60 }}
                  helperText='Send reminder notification this many minutes before'
                />
              </Grid>
            </Grid>

            <Divider sx={{ my: 3 }} />

            <Typography variant='subtitle1' sx={{ mb: 3, fontWeight: 600 }}>
              AI Provider (Optional)
            </Typography>

            <Grid container spacing={3}>
              <Grid item size={12} sm={6}>
                <TextField
                  fullWidth
                  select
                  label='AI Provider'
                  value={formData.aiSmartSchedulingProvider}
                  onChange={e => handleChange('aiSmartSchedulingProvider', e.target.value)}
                >
                  <MenuItem value='none'>None (Deterministic only)</MenuItem>
                  <MenuItem value='openai'>OpenAI</MenuItem>
                </TextField>
              </Grid>
              {formData.aiSmartSchedulingProvider === 'openai' && (
                <>
                  <Grid item size={12} sm={6}>
                    <TextField
                      fullWidth
                      label='OpenAI API Key'
                      type='password'
                      value={formData.aiSmartSchedulingOpenaiKey}
                      onChange={e => handleChange('aiSmartSchedulingOpenaiKey', e.target.value)}
                      helperText='Your OpenAI API key (stored securely)'
                    />
                  </Grid>
                  <Grid item size={12} sm={6}>
                    <TextField
                      fullWidth
                      select
                      label='OpenAI Model'
                      value={formData.aiSmartSchedulingOpenaiModel}
                      onChange={e => handleChange('aiSmartSchedulingOpenaiModel', e.target.value)}
                    >
                      <MenuItem value='gpt-4o-mini'>GPT-4o Mini (Recommended)</MenuItem>
                      <MenuItem value='gpt-4o'>GPT-4o</MenuItem>
                      <MenuItem value='gpt-3.5-turbo'>GPT-3.5 Turbo</MenuItem>
                    </TextField>
                  </Grid>
                </>
              )}
            </Grid>

            <Box sx={{ mt: 4, display: 'flex', justifyContent: 'flex-end' }}>
              <Button
                variant='contained'
                onClick={handleSave}
                disabled={saving}
                startIcon={saving ? <CircularProgress size={16} /> : null}
              >
                {saving ? 'Saving...' : 'Save Settings'}
              </Button>
            </Box>
          </CardContent>
        </Card>
      </Grid>

      <Grid item size={12} md={4}>
        <Card>
          <CardContent>
            <Typography variant='subtitle1' sx={{ mb: 3, fontWeight: 600 }}>
              Analytics (Last 30 Days)
            </Typography>

            {analyticsLoading ? (
              <Box sx={{ display: 'flex', justifyContent: 'center', p: 2 }}>
                <CircularProgress size={24} />
              </Box>
            ) : analytics ? (
              <Box>
                <Box sx={{ mb: 2 }}>
                  <Typography variant='body2' color='text.secondary'>Slots Generated</Typography>
                  <Typography variant='h5' fontWeight={600}>{analytics.totalSlotsGenerated || 0}</Typography>
                </Box>
                <Box sx={{ mb: 2 }}>
                  <Typography variant='body2' color='text.secondary'>Bookings Confirmed</Typography>
                  <Typography variant='h5' fontWeight={600}>{analytics.totalBookingsConfirmed || 0}</Typography>
                </Box>
                <Box sx={{ mb: 2 }}>
                  <Typography variant='body2' color='text.secondary'>Conversion Rate</Typography>
                  <Typography variant='h5' fontWeight={600} color='primary'>{analytics.conversionRate || '0.0%'}</Typography>
                </Box>
                <Box sx={{ mb: 2 }}>
                  <Typography variant='body2' color='text.secondary'>Chat Interactions</Typography>
                  <Typography variant='h5' fontWeight={600}>{analytics.totalChatInteractions || 0}</Typography>
                </Box>
                <Box sx={{ mb: 2 }}>
                  <Typography variant='body2' color='text.secondary'>Expert Opt-Outs</Typography>
                  <Typography variant='h5' fontWeight={600}>{analytics.expertOptOuts || 0}</Typography>
                </Box>

                {analytics.recentBookings?.length > 0 && (
                  <>
                    <Divider sx={{ my: 2 }} />
                    <Typography variant='body2' color='text.secondary' sx={{ mb: 1 }}>Recent Bookings</Typography>
                    {analytics.recentBookings.slice(0, 5).map((booking, index) => (
                      <Box key={index} sx={{ mb: 1 }}>
                        <Typography variant='caption' display='block'>
                          {booking.userName} → {booking.expertName}
                        </Typography>
                        <Typography variant='caption' color='text.secondary'>
                          {new Date(booking.slotStartAt).toLocaleString()}
                        </Typography>
                      </Box>
                    ))}
                  </>
                )}
              </Box>
            ) : (
              <Alert severity='info'>No analytics data available yet.</Alert>
            )}

            <Button
              variant='outlined'
              size='small'
              onClick={fetchAnalytics}
              disabled={analyticsLoading}
              sx={{ mt: 2 }}
            >
              Refresh
            </Button>
          </CardContent>
        </Card>
      </Grid>
    </Grid>
  )
}

export default AiSchedulingSettings
