'use client'

import React, { useEffect, useState, useMemo } from 'react'
import { useDispatch, useSelector } from 'react-redux'

// MUI Imports
import Alert from '@mui/material/Alert'
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import CardHeader from '@mui/material/CardHeader'
import CircularProgress from '@mui/material/CircularProgress'
import Divider from '@mui/material/Divider'
import Grid from '@mui/material/Grid'
import IconButton from '@mui/material/IconButton'
import InputAdornment from '@mui/material/InputAdornment'
import Paper from '@mui/material/Paper'
import Switch from '@mui/material/Switch'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'
import Chip from '@mui/material/Chip'
import Stack from '@mui/material/Stack'
import { toast } from 'react-toastify'

// Redux Actions
import { updateSettings } from '@/redux-store/slices/settings'

const SEMVER_REGEX = /^\d+(\.\d+){1,3}([-+][\w.-]+)?$/

const isValidSemver = ver => {
  if (!ver || typeof ver !== 'string') return false
  return SEMVER_REGEX.test(ver.trim())
}

const isValidUrl = url => {
  if (!url || typeof url !== 'string') return true // Allow empty or validate when entered
  try {
    const parsed = new URL(url.trim())
    return ['http:', 'https:'].includes(parsed.protocol)
  } catch {
    return false
  }
}

const AppUpdateSettings = () => {
  const dispatch = useDispatch()
  const { settings, loading, error } = useSelector(state => state.settings)

  const [initialData, setInitialData] = useState({})
  const [previewMode, setPreviewMode] = useState('flexible') // 'force' | 'flexible'
  const [previewPlatform, setPreviewPlatform] = useState('android') // 'android' | 'ios'

  const [formData, setFormData] = useState({
    isForceUpdateEnabled: false,
    isFlexibleUpdateEnabled: false,
    androidLatestVersion: '1.0.0',
    androidMinVersion: '1.0.0',
    androidAppLink: '',
    iosLatestVersion: '1.0.0',
    iosMinVersion: '1.0.0',
    iosAppLink: '',
    updateDialogTitle: 'Update Available',
    updateDialogMessage:
      'A new version of the app is available with new features, performance improvements, and bug fixes. Please update to enjoy the best experience.',
    updateDialogButtonText: 'Update Now',
    updateDialogSkipText: 'Maybe Later'
  })

  useEffect(() => {
    if (settings) {
      const data = {
        isForceUpdateEnabled: settings.isForceUpdateEnabled ?? false,
        isFlexibleUpdateEnabled: settings.isFlexibleUpdateEnabled ?? false,
        androidLatestVersion: settings.androidLatestVersion || settings.androidAppVersion || '1.0.0',
        androidMinVersion: settings.androidMinVersion || '1.0.0',
        androidAppLink: settings.androidAppLink || '',
        iosLatestVersion: settings.iosLatestVersion || settings.iosAppVersion || '1.0.0',
        iosMinVersion: settings.iosMinVersion || '1.0.0',
        iosAppLink: settings.iosAppLink || '',
        updateDialogTitle: settings.updateDialogTitle || 'Update Available',
        updateDialogMessage:
          settings.updateDialogMessage ||
          'A new version of the app is available with new features, performance improvements, and bug fixes. Please update to enjoy the best experience.',
        updateDialogButtonText: settings.updateDialogButtonText || 'Update Now',
        updateDialogSkipText: settings.updateDialogSkipText || 'Maybe Later'
      }

      setFormData(data)
      setInitialData(data)
    }
  }, [settings])

  const handleFieldChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))
  }

  // Validation
  const errors = useMemo(() => {
    const errs = {}

    if (!isValidSemver(formData.androidLatestVersion)) {
      errs.androidLatestVersion = 'Enter a valid version (e.g. 1.0.0 or 1.2.3)'
    }
    if (!isValidSemver(formData.androidMinVersion)) {
      errs.androidMinVersion = 'Enter a valid version (e.g. 1.0.0 or 1.2.3)'
    }
    if (!isValidSemver(formData.iosLatestVersion)) {
      errs.iosLatestVersion = 'Enter a valid version (e.g. 1.0.0 or 1.2.3)'
    }
    if (!isValidSemver(formData.iosMinVersion)) {
      errs.iosMinVersion = 'Enter a valid version (e.g. 1.0.0 or 1.2.3)'
    }

    if (formData.androidAppLink && !isValidUrl(formData.androidAppLink)) {
      errs.androidAppLink = 'Enter a valid URL (https://...)'
    }
    if (formData.iosAppLink && !isValidUrl(formData.iosAppLink)) {
      errs.iosAppLink = 'Enter a valid URL (https://...)'
    }

    return errs
  }, [formData])

  const hasValidationErrors = Object.keys(errors).length > 0

  const hasChanges = useMemo(() => {
    return Object.keys(formData).some(key => formData[key] !== initialData[key])
  }, [formData, initialData])

  const handleSubmit = () => {
    if (hasValidationErrors) {
      toast.error('Please resolve validation errors before saving.')
      return
    }

    const payload = {
      _id: settings?._id,
      ...formData,
      // Keep legacy fields synchronized
      androidAppVersion: formData.androidLatestVersion,
      iosAppVersion: formData.iosLatestVersion
    }

    dispatch(updateSettings(payload))
  }

  const handleReset = () => {
    setFormData(initialData)
    toast.info('Form reset to saved values.')
  }

  if (!settings && loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 8, alignItems: 'center', height: '50vh' }}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      {/* Top Banner / Summary */}
      <Card
        sx={{
          background: 'linear-gradient(135deg, rgba(115, 103, 240, 0.08) 0%, rgba(115, 103, 240, 0.02) 100%)',
          borderColor: 'primary.light',
          borderWidth: 1,
          borderStyle: 'solid'
        }}
      >
        <CardContent>
          <Grid container spacing={3} alignItems='center'>
            <Grid item xs={12} md={7}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, mb: 1 }}>
                <Box
                  sx={{
                    width: 42,
                    height: 42,
                    borderRadius: 2,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    bgcolor: 'primary.main',
                    color: 'white'
                  }}
                >
                  <i className='tabler-refresh text-xl' />
                </Box>
                <Box>
                  <Typography variant='h6' sx={{ fontWeight: 700 }}>
                    App Update Management
                  </Typography>
                  <Typography variant='body2' color='text.secondary'>
                    Dynamically control Android & iOS app updates, minimum supported versions, and dialog copy.
                  </Typography>
                </Box>
              </Box>
            </Grid>
            <Grid item xs={12} md={5}>
              <Stack direction='row' spacing={1.5} flexWrap='wrap' justifyContent={{ xs: 'flex-start', md: 'flex-end' }}>
                <Chip
                  icon={<i className={formData.isForceUpdateEnabled ? 'tabler-alert-triangle' : 'tabler-shield-check'} />}
                  label={`Force Update: ${formData.isForceUpdateEnabled ? 'ACTIVE' : 'OFF'}`}
                  color={formData.isForceUpdateEnabled ? 'warning' : 'default'}
                  variant={formData.isForceUpdateEnabled ? 'filled' : 'outlined'}
                  size='small'
                />
                <Chip
                  icon={<i className={formData.isFlexibleUpdateEnabled ? 'tabler-sparkles' : 'tabler-minus'} />}
                  label={`Flexible Update: ${formData.isFlexibleUpdateEnabled ? 'ACTIVE' : 'OFF'}`}
                  color={formData.isFlexibleUpdateEnabled ? 'info' : 'default'}
                  variant={formData.isFlexibleUpdateEnabled ? 'filled' : 'outlined'}
                  size='small'
                />
              </Stack>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {error && (
        <Alert severity='error' sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      <Grid container spacing={4}>
        {/* Left Column: Update Settings Controls */}
        <Grid item xs={12} lg={7}>
          <Stack spacing={4}>
            {/* Update Mode Switches */}
            <Card>
              <CardHeader
                title='Update Modes & Behavior'
                subheader='Configure how and when updates are enforced on users mobile devices'
                avatar={<i className='tabler-toggle-right text-2xl text-primary' />}
              />
              <Divider />
              <CardContent>
                <Grid container spacing={3}>
                  <Grid item xs={12}>
                    <Paper
                      elevation={0}
                      sx={{
                        p: 2.5,
                        borderRadius: 2,
                        border: 1,
                        borderColor: formData.isForceUpdateEnabled ? 'warning.main' : 'divider',
                        bgcolor: formData.isForceUpdateEnabled ? 'warning.lightOpacity' : 'background.paper',
                        transition: 'all 0.2s ease-in-out'
                      }}
                    >
                      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                        <Box sx={{ pr: 2 }}>
                          <Typography variant='subtitle1' sx={{ fontWeight: 600, display: 'flex', alignItems: 'center', gap: 1 }}>
                            <i className='tabler-shield-lock text-warning' />
                            Force Update (Blocking)
                          </Typography>
                          <Typography variant='body2' color='text.secondary' sx={{ mt: 0.5 }}>
                            When enabled or when a user version is below the <strong>Minimum Supported Version</strong>, the app displays a non-dismissible modal and completely prevents app usage until updated.
                          </Typography>
                        </Box>
                        <Switch
                          checked={formData.isForceUpdateEnabled}
                          onChange={e => handleFieldChange('isForceUpdateEnabled', e.target.checked)}
                          color='warning'
                        />
                      </Box>
                    </Paper>
                  </Grid>

                  <Grid item xs={12}>
                    <Paper
                      elevation={0}
                      sx={{
                        p: 2.5,
                        borderRadius: 2,
                        border: 1,
                        borderColor: formData.isFlexibleUpdateEnabled ? 'info.main' : 'divider',
                        bgcolor: formData.isFlexibleUpdateEnabled ? 'info.lightOpacity' : 'background.paper',
                        transition: 'all 0.2s ease-in-out'
                      }}
                    >
                      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                        <Box sx={{ pr: 2 }}>
                          <Typography variant='subtitle1' sx={{ fontWeight: 600, display: 'flex', alignItems: 'center', gap: 1 }}>
                            <i className='tabler-bell-ringing text-info' />
                            Flexible Update (Skippable Recommendation)
                          </Typography>
                          <Typography variant='body2' color='text.secondary' sx={{ mt: 0.5 }}>
                            When enabled, users with an installed version lower than the <strong>Latest Version</strong> (and at or above Minimum Supported Version) receive a skippable update recommendation with a skip/maybe later button.
                          </Typography>
                        </Box>
                        <Switch
                          checked={formData.isFlexibleUpdateEnabled}
                          onChange={e => handleFieldChange('isFlexibleUpdateEnabled', e.target.checked)}
                          color='info'
                        />
                      </Box>
                    </Paper>
                  </Grid>
                </Grid>
              </CardContent>
            </Card>

            {/* Android Version Controls */}
            <Card>
              <CardHeader
                title='Android Version & Store Settings'
                subheader='Google Play Store release versions and download URL'
                avatar={<i className='tabler-brand-android text-2xl text-success' />}
              />
              <Divider />
              <CardContent>
                <Grid container spacing={3}>
                  <Grid item xs={12} sm={6}>
                    <TextField
                      fullWidth
                      label='Android Latest Version'
                      placeholder='e.g. 1.5.0'
                      value={formData.androidLatestVersion}
                      onChange={e => handleFieldChange('androidLatestVersion', e.target.value)}
                      error={Boolean(errors.androidLatestVersion)}
                      helperText={errors.androidLatestVersion || 'Current latest build published on Google Play Store'}
                      InputProps={{
                        startAdornment: (
                          <InputAdornment position='start'>
                            <i className='tabler-tag text-muted' />
                          </InputAdornment>
                        )
                      }}
                    />
                  </Grid>

                  <Grid item xs={12} sm={6}>
                    <TextField
                      fullWidth
                      label='Android Minimum Supported Version'
                      placeholder='e.g. 1.0.0'
                      value={formData.androidMinVersion}
                      onChange={e => handleFieldChange('androidMinVersion', e.target.value)}
                      error={Boolean(errors.androidMinVersion)}
                      helperText={errors.androidMinVersion || 'Versions below this must force update to continue'}
                      InputProps={{
                        startAdornment: (
                          <InputAdornment position='start'>
                            <i className='tabler-shield-check text-muted' />
                          </InputAdornment>
                        )
                      }}
                    />
                  </Grid>

                  <Grid item xs={12}>
                    <TextField
                      fullWidth
                      label='Google Play Store Link'
                      placeholder='https://play.google.com/store/apps/details?id=com.yourapp.package'
                      value={formData.androidAppLink}
                      onChange={e => handleFieldChange('androidAppLink', e.target.value)}
                      error={Boolean(errors.androidAppLink)}
                      helperText={errors.androidAppLink || 'Direct link to open in Google Play Store when user taps Update'}
                      InputProps={{
                        startAdornment: (
                          <InputAdornment position='start'>
                            <i className='tabler-brand-google-play text-muted' />
                          </InputAdornment>
                        ),
                        endAdornment: formData.androidAppLink && isValidUrl(formData.androidAppLink) && (
                          <InputAdornment position='end'>
                            <IconButton
                              size='small'
                              component='a'
                              href={formData.androidAppLink}
                              target='_blank'
                              rel='noopener noreferrer'
                            >
                              <i className='tabler-external-link' />
                            </IconButton>
                          </InputAdornment>
                        )
                      }}
                    />
                  </Grid>
                </Grid>
              </CardContent>
            </Card>

            {/* iOS Version Controls */}
            <Card>
              <CardHeader
                title='iOS Version & App Store Settings'
                subheader='Apple App Store release versions and download URL'
                avatar={<i className='tabler-brand-apple text-2xl text-secondary' />}
              />
              <Divider />
              <CardContent>
                <Grid container spacing={3}>
                  <Grid item xs={12} sm={6}>
                    <TextField
                      fullWidth
                      label='iOS Latest Version'
                      placeholder='e.g. 1.5.0'
                      value={formData.iosLatestVersion}
                      onChange={e => handleFieldChange('iosLatestVersion', e.target.value)}
                      error={Boolean(errors.iosLatestVersion)}
                      helperText={errors.iosLatestVersion || 'Current latest build published on Apple App Store'}
                      InputProps={{
                        startAdornment: (
                          <InputAdornment position='start'>
                            <i className='tabler-tag text-muted' />
                          </InputAdornment>
                        )
                      }}
                    />
                  </Grid>

                  <Grid item xs={12} sm={6}>
                    <TextField
                      fullWidth
                      label='iOS Minimum Supported Version'
                      placeholder='e.g. 1.0.0'
                      value={formData.iosMinVersion}
                      onChange={e => handleFieldChange('iosMinVersion', e.target.value)}
                      error={Boolean(errors.iosMinVersion)}
                      helperText={errors.iosMinVersion || 'Versions below this must force update to continue'}
                      InputProps={{
                        startAdornment: (
                          <InputAdornment position='start'>
                            <i className='tabler-shield-check text-muted' />
                          </InputAdornment>
                        )
                      }}
                    />
                  </Grid>

                  <Grid item xs={12}>
                    <TextField
                      fullWidth
                      label='Apple App Store Link'
                      placeholder='https://apps.apple.com/app/id123456789'
                      value={formData.iosAppLink}
                      onChange={e => handleFieldChange('iosAppLink', e.target.value)}
                      error={Boolean(errors.iosAppLink)}
                      helperText={errors.iosAppLink || 'Direct link to open in Apple App Store when user taps Update'}
                      InputProps={{
                        startAdornment: (
                          <InputAdornment position='start'>
                            <i className='tabler-brand-apple text-muted' />
                          </InputAdornment>
                        ),
                        endAdornment: formData.iosAppLink && isValidUrl(formData.iosAppLink) && (
                          <InputAdornment position='end'>
                            <IconButton
                              size='small'
                              component='a'
                              href={formData.iosAppLink}
                              target='_blank'
                              rel='noopener noreferrer'
                            >
                              <i className='tabler-external-link' />
                            </IconButton>
                          </InputAdornment>
                        )
                      }}
                    />
                  </Grid>
                </Grid>
              </CardContent>
            </Card>

            {/* Dialog Customization */}
            <Card>
              <CardHeader
                title='Update Dialog Customization'
                subheader='Customize the copy and action text displayed on users screens'
                avatar={<i className='tabler-message-2-code text-2xl text-primary' />}
              />
              <Divider />
              <CardContent>
                <Grid container spacing={3}>
                  <Grid item xs={12}>
                    <TextField
                      fullWidth
                      label='Update Dialog Title'
                      placeholder='Update Available'
                      value={formData.updateDialogTitle}
                      onChange={e => handleFieldChange('updateDialogTitle', e.target.value)}
                      helperText='Header text displayed at the top of the update dialog'
                    />
                  </Grid>

                  <Grid item xs={12}>
                    <TextField
                      fullWidth
                      multiline
                      rows={3}
                      label='Update Dialog Message'
                      placeholder='A new version of the app is available with new features...'
                      value={formData.updateDialogMessage}
                      onChange={e => handleFieldChange('updateDialogMessage', e.target.value)}
                      helperText='Detailed message explaining the update benefits or requirements'
                    />
                  </Grid>

                  <Grid item xs={12} sm={6}>
                    <TextField
                      fullWidth
                      label='Update Button Text'
                      placeholder='Update Now'
                      value={formData.updateDialogButtonText}
                      onChange={e => handleFieldChange('updateDialogButtonText', e.target.value)}
                      helperText='Primary button label that opens the app store'
                    />
                  </Grid>

                  <Grid item xs={12} sm={6}>
                    <TextField
                      fullWidth
                      label='Skip Button Text (Flexible Update)'
                      placeholder='Maybe Later'
                      value={formData.updateDialogSkipText}
                      onChange={e => handleFieldChange('updateDialogSkipText', e.target.value)}
                      helperText='Dismiss button label shown on flexible update dialogs'
                    />
                  </Grid>
                </Grid>
              </CardContent>
            </Card>

            {/* Form Actions */}
            <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end', mt: 2 }}>
              <Button variant='tonal' color='secondary' onClick={handleReset} disabled={!hasChanges || loading}>
                Reset
              </Button>
              <Button
                variant='contained'
                color='primary'
                onClick={handleSubmit}
                disabled={loading || hasValidationErrors || !hasChanges}
                startIcon={loading ? <CircularProgress size={18} color='inherit' /> : <i className='tabler-check' />}
              >
                {loading ? 'Saving...' : 'Save Update Settings'}
              </Button>
            </Box>
          </Stack>
        </Grid>

        {/* Right Column: Live Interactive Mobile Preview */}
        <Grid item xs={12} lg={5}>
          <Box sx={{ position: 'sticky', top: 24 }}>
            <Card sx={{ border: 1, borderColor: 'divider' }}>
              <CardHeader
                title='Live Dialog Preview'
                subheader='Real-time mobile simulation of the configured dialog'
                avatar={<i className='tabler-device-mobile text-2xl text-primary' />}
              />
              <Divider />
              <CardContent>
                {/* Preview controls */}
                <Box sx={{ mb: 3 }}>
                  <Typography variant='caption' sx={{ fontWeight: 600, color: 'text.secondary', display: 'block', mb: 1 }}>
                    DIALOG TYPE TO PREVIEW:
                  </Typography>
                  <Stack direction='row' spacing={1} sx={{ mb: 2 }}>
                    <Button
                      size='small'
                      variant={previewMode === 'force' ? 'contained' : 'outlined'}
                      color='warning'
                      onClick={() => setPreviewMode('force')}
                      startIcon={<i className='tabler-shield-lock' />}
                    >
                      Force Update
                    </Button>
                    <Button
                      size='small'
                      variant={previewMode === 'flexible' ? 'contained' : 'outlined'}
                      color='info'
                      onClick={() => setPreviewMode('flexible')}
                      startIcon={<i className='tabler-sparkles' />}
                    >
                      Flexible Update
                    </Button>
                  </Stack>

                  <Typography variant='caption' sx={{ fontWeight: 600, color: 'text.secondary', display: 'block', mb: 1 }}>
                    TARGET PLATFORM:
                  </Typography>
                  <Stack direction='row' spacing={1}>
                    <Chip
                      icon={<i className='tabler-brand-android' />}
                      label={`Android (v${formData.androidLatestVersion || '1.0.0'})`}
                      clickable
                      color={previewPlatform === 'android' ? 'success' : 'default'}
                      variant={previewPlatform === 'android' ? 'filled' : 'outlined'}
                      onClick={() => setPreviewPlatform('android')}
                      size='small'
                    />
                    <Chip
                      icon={<i className='tabler-brand-apple' />}
                      label={`iOS (v${formData.iosLatestVersion || '1.0.0'})`}
                      clickable
                      color={previewPlatform === 'ios' ? 'secondary' : 'default'}
                      variant={previewPlatform === 'ios' ? 'filled' : 'outlined'}
                      onClick={() => setPreviewPlatform('ios')}
                      size='small'
                    />
                  </Stack>
                </Box>

                {/* Simulated Phone Frame */}
                <Box
                  sx={{
                    mx: 'auto',
                    maxWidth: 340,
                    borderRadius: 5,
                    p: 2,
                    bgcolor: '#111329',
                    boxShadow: '0 20px 40px -15px rgba(0,0,0,0.3)',
                    border: '8px solid #222538',
                    position: 'relative'
                  }}
                >
                  {/* Phone Notch */}
                  <Box
                    sx={{
                      width: 90,
                      height: 14,
                      bgcolor: '#222538',
                      borderRadius: '0 0 10px 10px',
                      mx: 'auto',
                      mb: 2
                    }}
                  />

                  {/* Backdrop overlay */}
                  <Box
                    sx={{
                      bgcolor: 'rgba(0,0,0,0.65)',
                      borderRadius: 3,
                      p: 2,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      minHeight: 460
                    }}
                  >
                    {/* Simulated Flutter Dialog */}
                    <Paper
                      elevation={8}
                      sx={{
                        width: '100%',
                        borderRadius: 3.5,
                        p: 3,
                        bgcolor: 'background.paper',
                        textAlign: 'center',
                        boxShadow: '0 12px 32px rgba(115, 103, 240, 0.25)',
                        border: 1,
                        borderColor: 'divider'
                      }}
                    >
                      {/* Animated Icon Mock */}
                      <Box
                        sx={{
                          width: 64,
                          height: 64,
                          borderRadius: '50%',
                          mx: 'auto',
                          mb: 2,
                          background: 'linear-gradient(135deg, #7367F0 0%, #9E95F5 100%)',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          color: 'white',
                          boxShadow: '0 8px 20px rgba(115, 103, 240, 0.4)'
                        }}
                      >
                        <i className='tabler-download text-2xl' />
                      </Box>

                      {/* Version Badge */}
                      <Chip
                        label={`v${previewPlatform === 'android' ? formData.androidLatestVersion : formData.iosLatestVersion} Available`}
                        size='small'
                        sx={{
                          mb: 1.5,
                          fontWeight: 600,
                          fontSize: '0.72rem',
                          bgcolor: 'rgba(115, 103, 240, 0.1)',
                          color: 'primary.main'
                        }}
                      />

                      {/* Dialog Title */}
                      <Typography variant='h6' sx={{ fontWeight: 700, mb: 1, fontSize: '1.1rem', lineHeight: 1.3 }}>
                        {formData.updateDialogTitle || 'Update Available'}
                      </Typography>

                      {/* Dialog Message */}
                      <Typography
                        variant='body2'
                        color='text.secondary'
                        sx={{
                          mb: 3,
                          fontSize: '0.8rem',
                          lineHeight: 1.45,
                          maxHeight: 110,
                          overflowY: 'auto'
                        }}
                      >
                        {formData.updateDialogMessage ||
                          'A new version of the app is available. Please update to enjoy the best experience.'}
                      </Typography>

                      {/* Update Now Button */}
                      <Button
                        fullWidth
                        variant='contained'
                        sx={{
                          py: 1.2,
                          borderRadius: 2,
                          fontWeight: 700,
                          fontSize: '0.88rem',
                          mb: previewMode === 'flexible' ? 1 : 0,
                          background: 'linear-gradient(135deg, #7367F0 0%, #8C82F3 100%)',
                          boxShadow: '0 4px 14px rgba(115, 103, 240, 0.35)'
                        }}
                        endIcon={<i className='tabler-arrow-right text-sm' />}
                      >
                        {formData.updateDialogButtonText || 'Update Now'}
                      </Button>

                      {/* Skip Button (Flexible mode only) */}
                      {previewMode === 'flexible' && (
                        <Button
                          fullWidth
                          variant='text'
                          color='secondary'
                          size='small'
                          sx={{
                            fontWeight: 600,
                            fontSize: '0.8rem',
                            color: 'text.secondary',
                            py: 0.8
                          }}
                        >
                          {formData.updateDialogSkipText || 'Maybe Later'}
                        </Button>
                      )}

                      {/* Force update footer */}
                      {previewMode === 'force' && (
                        <Typography variant='caption' sx={{ display: 'block', mt: 1.5, color: 'text.disabled', fontSize: '0.7rem' }}>
                          This update is required to continue.
                        </Typography>
                      )}
                    </Paper>
                  </Box>

                  {/* Phone Home Bar */}
                  <Box
                    sx={{
                      width: 100,
                      height: 4,
                      bgcolor: '#343852',
                      borderRadius: 2,
                      mx: 'auto',
                      mt: 2
                    }}
                  />
                </Box>
              </CardContent>
            </Card>
          </Box>
        </Grid>
      </Grid>
    </Box>
  )
}

export default AppUpdateSettings
