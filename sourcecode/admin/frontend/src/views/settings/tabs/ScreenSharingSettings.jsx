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
import FormControl from '@mui/material/FormControl'
import FormControlLabel from '@mui/material/FormControlLabel'
import Grid from '@mui/material/Grid'
import InputLabel from '@mui/material/InputLabel'
import MenuItem from '@mui/material/MenuItem'
import Radio from '@mui/material/Radio'
import RadioGroup from '@mui/material/RadioGroup'
import FormLabel from '@mui/material/FormLabel'
import Select from '@mui/material/Select'
import Switch from '@mui/material/Switch'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'
import { toast } from 'react-toastify'

// Redux Actions
import { updateSettings } from '@/redux-store/slices/settings'

const ScreenSharingSettings = () => {
  const [initialData, setInitialData] = useState({})
  const dispatch = useDispatch()
  const { settings, loading, error } = useSelector(state => state.settings)

  const [formData, setFormData] = useState({
    screenSharingEnabled: false,
    screenSharingVideoEnabled: true,
    screenSharingAudioEnabled: false,
    screenSharingPermission: 'both',
    screenSharingCategoriesEnabled: [],
    screenSharingMaxDurationMinutes: 30
  })

  useEffect(() => {
    if (settings) {
      const newData = {
        screenSharingEnabled: settings.screenSharingEnabled ?? false,
        screenSharingVideoEnabled: settings.screenSharingVideoEnabled ?? true,
        screenSharingAudioEnabled: settings.screenSharingAudioEnabled ?? false,
        screenSharingPermission: settings.screenSharingPermission ?? 'both',
        screenSharingCategoriesEnabled: settings.screenSharingCategoriesEnabled ?? [],
        screenSharingMaxDurationMinutes: settings.screenSharingMaxDurationMinutes ?? 30
      }

      setFormData(newData)
      setInitialData(newData)
    }
  }, [settings])

  const handleFieldChange = (field, value) => {
    if (['screenSharingMaxDurationMinutes'].includes(field)) {
      if (value === '' || !isNaN(value)) {
        setFormData(prev => ({ ...prev, [field]: value }))
      }
    } else {
      setFormData(prev => ({ ...prev, [field]: value }))
    }
  }

  const handleCategoriesChange = value => {
    const categories = value
      .split(',')
      .map(s => s.trim())
      .filter(s => s.length > 0)
    setFormData(prev => ({ ...prev, screenSharingCategoriesEnabled: categories }))
  }

  const getUpdatedFields = () => {
    const updates = {}
    const numericFields = ['screenSharingMaxDurationMinutes']

    Object.keys(formData).forEach(key => {
      const current = formData[key]
      const original = initialData[key]

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
          <Typography variant='h4'>Screen Sharing Settings</Typography>
          <Typography variant='body2' color='text.secondary'>
            Configure screen sharing behavior for consultation sessions.
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

      {/* Enable/Disable */}
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 600, display: 'flex', alignItems: 'center' }}>
            <i className='tabler-screen-share mr-2' />
            Screen Sharing Configuration
          </Typography>
          <Divider sx={{ mb: 3 }} />

          <Grid container spacing={3}>
            <Grid item size={12}>
              <FormControlLabel
                control={
                  <Switch
                    checked={Boolean(formData.screenSharingEnabled)}
                    onChange={e => handleFieldChange('screenSharingEnabled', e.target.checked)}
                  />
                }
                label='Enable Screen Sharing Platform-Wide'
              />
            </Grid>
            <Grid item size={6}>
              <FormControlLabel
                control={
                  <Switch
                    checked={Boolean(formData.screenSharingVideoEnabled)}
                    onChange={e => handleFieldChange('screenSharingVideoEnabled', e.target.checked)}
                    disabled={!formData.screenSharingEnabled}
                  />
                }
                label='Allow Screen Sharing in Video Calls'
              />
            </Grid>
            <Grid item size={6}>
              <FormControlLabel
                control={
                  <Switch
                    checked={Boolean(formData.screenSharingAudioEnabled)}
                    onChange={e => handleFieldChange('screenSharingAudioEnabled', e.target.checked)}
                    disabled={!formData.screenSharingEnabled}
                  />
                }
                label='Allow Screen Sharing in Audio Calls'
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Permission & Duration */}
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 600, display: 'flex', alignItems: 'center' }}>
            <i className='tabler-settings mr-2' />
            Permissions & Duration
          </Typography>
          <Divider sx={{ mb: 3 }} />

          <Grid container spacing={3}>
            <Grid item size={12}>
              <FormControl component='fieldset' disabled={!formData.screenSharingEnabled}>
                <FormLabel component='legend' sx={{ mb: 1 }}>Who Can Share Their Screen</FormLabel>
                <RadioGroup
                  row
                  value={formData.screenSharingPermission}
                  onChange={e => handleFieldChange('screenSharingPermission', e.target.value)}
                >
                  <FormControlLabel value='both' control={<Radio />} label='Both Experts & Users' />
                  <FormControlLabel value='expert_only' control={<Radio />} label='Expert Only' />
                  <FormControlLabel value='user_only' control={<Radio />} label='User Only' />
                </RadioGroup>
              </FormControl>
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='Max Screen Share Duration (minutes)'
                value={formData.screenSharingMaxDurationMinutes}
                onChange={e => handleFieldChange('screenSharingMaxDurationMinutes', e.target.value)}
                disabled={!formData.screenSharingEnabled}
                helperText='Maximum continuous screen sharing duration (0 = unlimited)'
                InputProps={{
                  inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                  endAdornment: (
                    <Typography variant='caption' color='text.secondary'>min</Typography>
                  )
                }}
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='Category Restrictions (comma-separated IDs)'
                value={(formData.screenSharingCategoriesEnabled || []).join(', ')}
                onChange={e => handleCategoriesChange(e.target.value)}
                disabled={!formData.screenSharingEnabled}
                helperText='Leave empty to allow all categories. Example: cat1, cat2'
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>
    </Box>
  )
}

export default ScreenSharingSettings
