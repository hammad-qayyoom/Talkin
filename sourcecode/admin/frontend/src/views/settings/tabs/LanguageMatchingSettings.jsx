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
import Slider from '@mui/material/Slider'
import Switch from '@mui/material/Switch'
import Typography from '@mui/material/Typography'

import { updateSettings } from '@/redux-store/slices/settings'

const LanguageMatchingSettings = () => {
  const dispatch = useDispatch()
  const { settings, loading } = useSelector(state => state.settings)

  const [formData, setFormData] = useState({
    smartLanguageMatchingEnabled: true,
    smartLanguageMatchingWeight: 0.12,
    smartLanguageMatchingBoostNativeSpeakers: true,
    smartLanguageMatchingNativeBoost: 1.2,
    smartLanguageMatchingConsiderAppLanguage: true,
    smartLanguageMatchingFallbackToAny: true,
    discoveryRankingWeights: {
      relevance: 0.22,
      distance: 0.18,
      rating: 0.28,
      recency: 0.12,
      availability: 0.08,
      language: 0.12
    }
  })

  const [saving, setSaving] = useState(false)
  const [saveMessage, setSaveMessage] = useState('')

  useEffect(() => {
    if (settings) {
      setFormData({
        smartLanguageMatchingEnabled: settings.smartLanguageMatchingEnabled ?? true,
        smartLanguageMatchingWeight: settings.smartLanguageMatchingWeight ?? 0.12,
        smartLanguageMatchingBoostNativeSpeakers: settings.smartLanguageMatchingBoostNativeSpeakers ?? true,
        smartLanguageMatchingNativeBoost: settings.smartLanguageMatchingNativeBoost ?? 1.2,
        smartLanguageMatchingConsiderAppLanguage: settings.smartLanguageMatchingConsiderAppLanguage ?? true,
        smartLanguageMatchingFallbackToAny: settings.smartLanguageMatchingFallbackToAny ?? true,
        discoveryRankingWeights: {
          relevance: settings.discoveryRankingWeights?.relevance ?? 0.22,
          distance: settings.discoveryRankingWeights?.distance ?? 0.18,
          rating: settings.discoveryRankingWeights?.rating ?? 0.28,
          recency: settings.discoveryRankingWeights?.recency ?? 0.12,
          availability: settings.discoveryRankingWeights?.availability ?? 0.08,
          language: settings.discoveryRankingWeights?.language ?? 0.12
        }
      })
    }
  }, [settings])

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))
  }

  const handleWeightChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      discoveryRankingWeights: {
        ...prev.discoveryRankingWeights,
        [field]: value
      }
    }))
  }

  const handleSave = async () => {
    setSaving(true)
    setSaveMessage('')
    try {
      const payload = { ...settings, ...formData }
      const result = await dispatch(updateSettings(payload))
      if (result?.payload?.status) {
        setSaveMessage('Language matching settings saved successfully.')
      } else {
        setSaveMessage('Failed to save settings.')
      }
    } catch {
      setSaveMessage('An error occurred while saving.')
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <Box display='flex' justifyContent='center' p={4}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Card>
      <CardContent>
        <Typography variant='h6' gutterBottom>
          Smart Language Matching
        </Typography>
        <Typography variant='body2' color='text.secondary' sx={{ mb: 3 }}>
          Configure how language preferences affect expert discovery and recommendations.
        </Typography>

        {saveMessage && (
          <Alert severity={saveMessage.includes('success') ? 'success' : 'error'} sx={{ mb: 2 }}>
            {saveMessage}
          </Alert>
        )}

        <Grid container spacing={4}>
          {/* Enable/Disable */}
          <Grid item xs={12}>
            <FormControlLabel
              control={
                <Switch
                  checked={formData.smartLanguageMatchingEnabled}
                  onChange={e => handleChange('smartLanguageMatchingEnabled', e.target.checked)}
                />
              }
              label='Enable Smart Language Matching'
            />
            <Typography variant='body2' color='text.secondary'>
              When enabled, experts who speak the user's preferred language will be ranked higher in discovery results.
            </Typography>
          </Grid>

          <Grid item xs={12}>
            <Divider />
          </Grid>

          {/* Language Weight */}
          <Grid item xs={12} md={6}>
            <Typography gutterBottom>
              Language Match Weight: {formData.smartLanguageMatchingWeight.toFixed(2)}
            </Typography>
            <Slider
              value={formData.smartLanguageMatchingWeight}
              onChange={(_, value) => handleChange('smartLanguageMatchingWeight', value)}
              min={0}
              max={0.5}
              step={0.01}
              valueLabelDisplay='auto'
              valueLabelFormat={v => v.toFixed(2)}
            />
            <Typography variant='body2' color='text.secondary'>
              How much language matching affects ranking (0 = no effect, 0.5 = maximum effect).
            </Typography>
          </Grid>

          {/* Native Boost */}
          <Grid item xs={12} md={6}>
            <Typography gutterBottom>
              Native Speaker Boost: {formData.smartLanguageMatchingNativeBoost.toFixed(1)}x
            </Typography>
            <Slider
              value={formData.smartLanguageMatchingNativeBoost}
              onChange={(_, value) => handleChange('smartLanguageMatchingNativeBoost', value)}
              min={1.0}
              max={2.0}
              step={0.1}
              valueLabelDisplay='auto'
              valueLabelFormat={v => `${v.toFixed(1)}x`}
            />
            <Typography variant='body2' color='text.secondary'>
              Extra ranking boost for native speakers vs. other proficiency levels.
            </Typography>
          </Grid>

          <Grid item xs={12}>
            <Divider />
          </Grid>

          {/* Boolean Options */}
          <Grid item xs={12} md={4}>
            <FormControlLabel
              control={
                <Switch
                  checked={formData.smartLanguageMatchingBoostNativeSpeakers}
                  onChange={e => handleChange('smartLanguageMatchingBoostNativeSpeakers', e.target.checked)}
                />
              }
              label='Boost Native Speakers'
            />
          </Grid>

          <Grid item xs={12} md={4}>
            <FormControlLabel
              control={
                <Switch
                  checked={formData.smartLanguageMatchingConsiderAppLanguage}
                  onChange={e => handleChange('smartLanguageMatchingConsiderAppLanguage', e.target.checked)}
                />
              }
              label='Consider App Language'
            />
          </Grid>

          <Grid item xs={12} md={4}>
            <FormControlLabel
              control={
                <Switch
                  checked={formData.smartLanguageMatchingFallbackToAny}
                  onChange={e => handleChange('smartLanguageMatchingFallbackToAny', e.target.checked)}
                />
              }
              label='Fallback When No Match'
            />
          </Grid>

          <Grid item xs={12}>
            <Divider />
          </Grid>

          {/* Ranking Weights */}
          <Grid item xs={12}>
            <Typography variant='subtitle1' gutterBottom>
              Discovery Ranking Weights
            </Typography>
            <Typography variant='body2' color='text.secondary' sx={{ mb: 2 }}>
              Adjust the relative importance of each ranking signal. Weights are normalized automatically.
            </Typography>
          </Grid>

          {[
            { key: 'relevance', label: 'Text Relevance' },
            { key: 'distance', label: 'Distance / Proximity' },
            { key: 'rating', label: 'Rating & Reviews' },
            { key: 'recency', label: 'Profile Recency' },
            { key: 'availability', label: 'Availability' },
            { key: 'language', label: 'Language Match' }
          ].map(({ key, label }) => (
            <Grid item xs={12} md={4} key={key}>
              <Typography gutterBottom>
                {label}: {(formData.discoveryRankingWeights[key] * 100).toFixed(0)}%
              </Typography>
              <Slider
                value={formData.discoveryRankingWeights[key]}
                onChange={(_, value) => handleWeightChange(key, value)}
                min={0}
                max={0.5}
                step={0.01}
                valueLabelDisplay='auto'
                valueLabelFormat={v => `${(v * 100).toFixed(0)}%`}
              />
            </Grid>
          ))}
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
  )
}

export default LanguageMatchingSettings
