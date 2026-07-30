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
import Chip from '@mui/material/Chip'
import Autocomplete from '@mui/material/Autocomplete'

import { updateSettings } from '@/redux-store/slices/settings'

const FILE_TYPE_OPTIONS = [
  { label: 'PDF', value: 'application/pdf' },
  { label: 'PNG Image', value: 'image/png' },
  { label: 'JPEG Image', value: 'image/jpeg' },
  { label: 'WebP Image', value: 'image/webp' },
  { label: 'Word Document', value: 'application/msword' },
  { label: 'Word (DOCX)', value: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' }
]

const PremiumContentSettings = () => {
  const dispatch = useDispatch()
  const { settings, loading } = useSelector(state => state.settings)

  const [formData, setFormData] = useState({
    premiumContentEnabled: false,
    premiumContentModerationRequired: false,
    premiumContentAllowedFileTypes: [
      'application/pdf',
      'image/png',
      'image/jpeg',
      'image/webp',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    ],
    premiumContentMaxFileSizeMB: 20,
    premiumContentMinPrice: 1,
    premiumContentMaxPrice: 1000,
    premiumContentCommissionPercent: 0
  })

  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (settings) {
      setFormData({
        premiumContentEnabled: settings.premiumContentEnabled ?? false,
        premiumContentModerationRequired: settings.premiumContentModerationRequired ?? false,
        premiumContentAllowedFileTypes: settings.premiumContentAllowedFileTypes ?? [
          'application/pdf',
          'image/png',
          'image/jpeg',
          'image/webp',
          'application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        ],
        premiumContentMaxFileSizeMB: settings.premiumContentMaxFileSizeMB ?? 20,
        premiumContentMinPrice: settings.premiumContentMinPrice ?? 1,
        premiumContentMaxPrice: settings.premiumContentMaxPrice ?? 1000,
        premiumContentCommissionPercent: settings.premiumContentCommissionPercent ?? 0
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
      // Error toast handled by Redux thunk
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
          Premium Content (Pay-per-Action)
        </Typography>
        <Typography variant='body2' color='text.secondary' sx={{ mb: 4 }}>
          Allow Experts to sell premium digital content (PDFs, documents, images, worksheets) to Users during
          live consultation sessions. Content is purchased using the existing wallet/coins system.
        </Typography>
      </Grid>

      {/* General Settings */}
      <Grid item size={12} md={8}>
        <Card>
          <CardContent>
            <Typography variant='subtitle1' sx={{ mb: 3, fontWeight: 600 }}>
              General Settings
            </Typography>

            <FormControlLabel
              control={
                <Switch
                  checked={formData.premiumContentEnabled}
                  onChange={e => handleChange('premiumContentEnabled', e.target.checked)}
                  color='primary'
                />
              }
              label='Enable Premium Content'
            />
            <Typography variant='body2' color='text.secondary' sx={{ ml: 6, mb: 3 }}>
              When enabled, Experts can upload and sell premium content during live sessions.
            </Typography>

            <FormControlLabel
              control={
                <Switch
                  checked={formData.premiumContentModerationRequired}
                  onChange={e => handleChange('premiumContentModerationRequired', e.target.checked)}
                  color='primary'
                />
              }
              label='Require Admin Approval'
            />
            <Typography variant='body2' color='text.secondary' sx={{ ml: 6, mb: 1 }}>
              When enabled, uploaded content must be approved by an admin before it becomes available for purchase.
            </Typography>
          </CardContent>
        </Card>
      </Grid>

      {/* File Configuration */}
      <Grid item size={12} md={8}>
        <Card>
          <CardContent>
            <Typography variant='subtitle1' sx={{ mb: 3, fontWeight: 600 }}>
              File Configuration
            </Typography>

            <Grid container spacing={3}>
              <Grid item size={12}>
                <Autocomplete
                  multiple
                  options={FILE_TYPE_OPTIONS}
                  value={FILE_TYPE_OPTIONS.filter(opt =>
                    (formData.premiumContentAllowedFileTypes || []).includes(opt.value)
                  )}
                  onChange={(e, newValue) =>
                    handleChange('premiumContentAllowedFileTypes', newValue.map(v => v.value))
                  }
                  getOptionLabel={option => option.label}
                  renderTags={(value, getTagProps) =>
                    value.map((option, index) => (
                      <Chip variant='outlined' label={option.label} {...getTagProps({ index })} key={option.value} />
                    ))
                  }
                  renderInput={params => (
                    <TextField {...params} variant='outlined' label='Allowed File Types' placeholder='Select types' />
                  )}
                />
              </Grid>
              <Grid item size={12} sm={6}>
                <TextField
                  fullWidth
                  label='Max File Size (MB)'
                  type='number'
                  value={formData.premiumContentMaxFileSizeMB}
                  onChange={e => handleChange('premiumContentMaxFileSizeMB', parseInt(e.target.value) || 20)}
                  inputProps={{ min: 1, max: 500 }}
                  helperText='Maximum upload file size in megabytes (1-500)'
                />
              </Grid>
            </Grid>
          </CardContent>
        </Card>
      </Grid>

      {/* Pricing */}
      <Grid item size={12} md={8}>
        <Card>
          <CardContent>
            <Typography variant='subtitle1' sx={{ mb: 3, fontWeight: 600 }}>
              Pricing & Commission
            </Typography>

            <Grid container spacing={3}>
              <Grid item size={12} sm={4}>
                <TextField
                  fullWidth
                  label='Min Price (coins)'
                  type='number'
                  value={formData.premiumContentMinPrice}
                  onChange={e => handleChange('premiumContentMinPrice', parseInt(e.target.value) || 1)}
                  inputProps={{ min: 0 }}
                  helperText='Minimum price experts can set'
                />
              </Grid>
              <Grid item size={12} sm={4}>
                <TextField
                  fullWidth
                  label='Max Price (coins)'
                  type='number'
                  value={formData.premiumContentMaxPrice}
                  onChange={e => handleChange('premiumContentMaxPrice', parseInt(e.target.value) || 1000)}
                  inputProps={{ min: 1 }}
                  helperText='Maximum price experts can set'
                />
              </Grid>
              <Grid item size={12} sm={4}>
                <TextField
                  fullWidth
                  label='Platform Commission (%)'
                  type='number'
                  value={formData.premiumContentCommissionPercent}
                  onChange={e => handleChange('premiumContentCommissionPercent', parseFloat(e.target.value) || 0)}
                  inputProps={{ min: 0, max: 100, step: 0.1 }}
                  helperText='Platform fee on each content sale (0-100%)'
                />
              </Grid>
            </Grid>

            <Alert severity='info' sx={{ mt: 3 }}>
              Commission is calculated on the sale price. The remaining amount is credited to the Expert's wallet
              immediately upon purchase, same as tips.
            </Alert>
          </CardContent>
        </Card>
      </Grid>

      {/* Save Button */}
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

export default PremiumContentSettings
