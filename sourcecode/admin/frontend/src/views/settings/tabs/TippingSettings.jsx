'use client'

import { useEffect, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'

// MUI Imports
import Alert from '@mui/material/Alert'
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import CircularProgress from '@mui/material/CircularProgress'
import Divider from '@mui/material/Divider'
import FormControlLabel from '@mui/material/FormControlLabel'
import Grid from '@mui/material/Grid'
import InputAdornment from '@mui/material/InputAdornment'
import Switch from '@mui/material/Switch'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'
import { toast } from 'react-toastify'

// Redux Actions
import { updateSettings } from '@/redux-store/slices/settings'

const TippingSettings = () => {
  const [initialData, setInitialData] = useState({})
  const dispatch = useDispatch()
  const { settings, loading, error } = useSelector(state => state.settings)

  const [formData, setFormData] = useState({
    tippingEnabled: false,
    tippingAudioEnabled: true,
    tippingVideoEnabled: true,
    tippingMinAmount: 10,
    tippingMaxAmount: 500,
    tippingSuggestedAmounts: [10, 20, 50, 100, 200],
    tippingPlatformFeePercent: 20,
    tippingRefundPolicyEnabled: true,
    tippingRefundTimeLimitMinutes: 60
  })

  // Update form data when settings are fetched
  useEffect(() => {
    if (settings) {
      const newData = {
        tippingEnabled: settings.tippingEnabled ?? false,
        tippingAudioEnabled: settings.tippingAudioEnabled ?? true,
        tippingVideoEnabled: settings.tippingVideoEnabled ?? true,
        tippingMinAmount: settings.tippingMinAmount ?? 10,
        tippingMaxAmount: settings.tippingMaxAmount ?? 500,
        tippingSuggestedAmounts: settings.tippingSuggestedAmounts ?? [10, 20, 50, 100, 200],
        tippingPlatformFeePercent: settings.tippingPlatformFeePercent ?? 20,
        tippingRefundPolicyEnabled: settings.tippingRefundPolicyEnabled ?? true,
        tippingRefundTimeLimitMinutes: settings.tippingRefundTimeLimitMinutes ?? 60
      }

      setFormData(newData)
      setInitialData(newData)
    }
  }, [settings])

  const handleFieldChange = (field, value) => {
    if (['tippingMinAmount', 'tippingMaxAmount', 'tippingPlatformFeePercent', 'tippingRefundTimeLimitMinutes'].includes(field)) {
      if (value === '' || !isNaN(value)) {
        setFormData(prev => ({ ...prev, [field]: value }))
      }
    } else {
      setFormData(prev => ({ ...prev, [field]: value }))
    }
  }

  const handleSuggestedAmountsChange = value => {
    // Parse comma-separated string into array of numbers
    const amounts = value
      .split(',')
      .map(s => parseInt(s.trim()))
      .filter(n => !isNaN(n) && n > 0)
    setFormData(prev => ({ ...prev, tippingSuggestedAmounts: amounts }))
  }

  const getUpdatedFields = () => {
    const updates = {}
    const numericFields = ['tippingMinAmount', 'tippingMaxAmount', 'tippingPlatformFeePercent', 'tippingRefundTimeLimitMinutes']

    Object.keys(formData).forEach(key => {
      const current = formData[key]
      const original = initialData[key]

      // Check arrays
      if (Array.isArray(current) && Array.isArray(original)) {
        if (JSON.stringify(current) !== JSON.stringify(original)) {
          updates[key] = current
        }
      } else if (current !== original) {
        if (numericFields.includes(key)) {
          updates[key] = current === '' ? 0 : Number(current)
        } else {
          updates[key] = current
        }
      }
    })

    return updates
  }

  const handleSubmit = () => {
    const updatedFields = getUpdatedFields()

    if (Object.keys(updatedFields).length === 0) {
      toast.info('No changes to update')
      return
    }

    const payload = {
      _id: settings?._id,
      ...updatedFields
    }

    dispatch(updateSettings(payload))
  }

  if (!settings && loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 4, alignItems: 'center', height: '55vh' }}>
        <CircularProgress />
      </Box>
    )
  }

  if (error) {
    return (
      <Alert severity='error' sx={{ mb: 4 }}>
        {error}
      </Alert>
    )
  }

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Box>
          <Typography variant='h4'>Expert Tipping Settings</Typography>
          <Typography variant='body2' color='text.secondary'>
            Configure tipping behavior for audio and video consultation sessions.
          </Typography>
        </Box>
        <Button
          variant='contained'
          color='primary'
          onClick={handleSubmit}
          disabled={loading}
          startIcon={loading ? <CircularProgress color='white' size={20} /> : <i className='tabler-device-floppy' />}
        >
          Save Changes
        </Button>
      </Box>

      {/* Tipping Enable/Disable */}
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 600, display: 'flex', alignItems: 'center' }}>
            <i className='tabler-heart mr-2' />
            Tipping Configuration
          </Typography>
          <Divider sx={{ mb: 3 }} />

          <Grid container spacing={3}>
            <Grid item size={12}>
              <FormControlLabel
                control={
                  <Switch
                    checked={Boolean(formData.tippingEnabled)}
                    onChange={e => handleFieldChange('tippingEnabled', e.target.checked)}
                  />
                }
                label='Enable Expert Tipping Platform-Wide'
              />
            </Grid>
            <Grid item size={6}>
              <FormControlLabel
                control={
                  <Switch
                    checked={Boolean(formData.tippingAudioEnabled)}
                    onChange={e => handleFieldChange('tippingAudioEnabled', e.target.checked)}
                    disabled={!formData.tippingEnabled}
                  />
                }
                label='Allow Tipping in Audio Sessions'
              />
            </Grid>
            <Grid item size={6}>
              <FormControlLabel
                control={
                  <Switch
                    checked={Boolean(formData.tippingVideoEnabled)}
                    onChange={e => handleFieldChange('tippingVideoEnabled', e.target.checked)}
                    disabled={!formData.tippingEnabled}
                  />
                }
                label='Allow Tipping in Video Sessions'
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Tip Amount Configuration */}
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 600, display: 'flex', alignItems: 'center' }}>
            <i className='tabler-currency-dollar mr-2' />
            Tip Amount Configuration
          </Typography>
          <Divider sx={{ mb: 3 }} />

          <Grid container spacing={3}>
            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='Minimum Tip Amount'
                value={formData.tippingMinAmount}
                onChange={e => handleFieldChange('tippingMinAmount', e.target.value)}
                disabled={!formData.tippingEnabled}
                InputProps={{
                  inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                  startAdornment: (
                    <InputAdornment position='start'>
                      <Typography variant='caption' color='text.secondary'>₹</Typography>
                    </InputAdornment>
                  )
                }}
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='Maximum Tip Amount'
                value={formData.tippingMaxAmount}
                onChange={e => handleFieldChange('tippingMaxAmount', e.target.value)}
                disabled={!formData.tippingEnabled}
                InputProps={{
                  inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                  startAdornment: (
                    <InputAdornment position='start'>
                      <Typography variant='caption' color='text.secondary'>₹</Typography>
                    </InputAdornment>
                  )
                }}
              />
            </Grid>
            <Grid item size={12}>
              <TextField
                fullWidth
                type='text'
                label='Suggested Tip Amounts (comma-separated)'
                value={(formData.tippingSuggestedAmounts || []).join(', ')}
                onChange={e => handleSuggestedAmountsChange(e.target.value)}
                disabled={!formData.tippingEnabled}
                helperText='These amounts will appear as quick-select buttons for users. Example: 10, 20, 50, 100, 200'
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Platform Fee & Refund Policy */}
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 600, display: 'flex', alignItems: 'center' }}>
            <i className='tabler-percentage mr-2' />
            Platform Fee & Refund Policy
          </Typography>
          <Divider sx={{ mb: 3 }} />

          <Grid container spacing={3}>
            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='Platform Fee Percentage'
                value={formData.tippingPlatformFeePercent}
                onChange={e => handleFieldChange('tippingPlatformFeePercent', e.target.value)}
                disabled={!formData.tippingEnabled}
                helperText='Percentage of each tip retained by the platform'
                InputProps={{
                  inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                  endAdornment: (
                    <InputAdornment position='end'>
                      <Typography variant='caption' color='text.secondary'>%</Typography>
                    </InputAdornment>
                  )
                }}
              />
            </Grid>
            <Grid item size={6}>
              <FormControlLabel
                control={
                  <Switch
                    checked={Boolean(formData.tippingRefundPolicyEnabled)}
                    onChange={e => handleFieldChange('tippingRefundPolicyEnabled', e.target.checked)}
                    disabled={!formData.tippingEnabled}
                  />
                }
                label='Enable Tip Refund Policy'
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='Refund Time Limit (minutes after tip)'
                value={formData.tippingRefundTimeLimitMinutes}
                onChange={e => handleFieldChange('tippingRefundTimeLimitMinutes', e.target.value)}
                disabled={!formData.tippingEnabled || !formData.tippingRefundPolicyEnabled}
                helperText='Users can request a refund within this time window'
                InputProps={{
                  inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                  endAdornment: (
                    <InputAdornment position='end'>
                      <Typography variant='caption' color='text.secondary'>min</Typography>
                    </InputAdornment>
                  )
                }}
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>
    </Box>
  )
}

export default TippingSettings
