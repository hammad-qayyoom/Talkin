'use client'

import { useEffect, useMemo, useState } from 'react'

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
import MenuItem from '@mui/material/MenuItem'
import Switch from '@mui/material/Switch'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'
import { toast } from 'react-toastify'

// Redux Actions
import { toggleSetting, updateSettings } from '@/redux-store/slices/settings'
import HoverPopover from '@/common/HoverPopover'
import { toolTipData } from '@/settingTooltip'

const getTimezoneOffsetMinutes = (timezone, referenceDate = new Date()) => {
  try {
    const formatter = new Intl.DateTimeFormat('en-US', {
      timeZone: timezone,
      hour12: false,
      hourCycle: 'h23',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    })

    const parts = formatter.formatToParts(referenceDate)
    const partMap = {}

    parts.forEach(part => {
      if (part.type !== 'literal') {
        partMap[part.type] = part.value
      }
    })

    const year = Number(partMap.year)
    const month = Number(partMap.month)
    const day = Number(partMap.day)
    let hour = Number(partMap.hour)
    const minute = Number(partMap.minute)
    const second = Number(partMap.second)

    if (hour === 24) {
      hour = 0
    }

    if (
      ![year, month, day, hour, minute, second].every(Number.isFinite) ||
      hour < 0 ||
      hour > 23
    ) {
      return 0
    }

    const reconstructedUtcMs = Date.UTC(year, month - 1, day, hour, minute, second, 0)

    return Math.round((reconstructedUtcMs - referenceDate.getTime()) / (60 * 1000))
  } catch (error) {
    return 0
  }
}

const formatUtcOffset = offsetMinutes => {
  const normalizedOffset = Number.isFinite(offsetMinutes) ? Math.trunc(offsetMinutes) : 0
  const sign = normalizedOffset >= 0 ? '+' : '-'
  const absoluteOffset = Math.abs(normalizedOffset)
  const hours = String(Math.floor(absoluteOffset / 60)).padStart(2, '0')
  const minutes = String(absoluteOffset % 60).padStart(2, '0')

  return `UTC${sign}${hours}:${minutes}`
}

const GeneralSettings = () => {
  const [initialData, setInitialData] = useState({})
  const dispatch = useDispatch()
  const { settings, loading, error } = useSelector(state => state.settings)

  const { profileData } = useSelector(state => state.adminSlice)

  

  const [formData, setFormData] = useState({
    _id: '',
    privateKey: {},
    privateCallRate: '',
    loginBonus: '',
    durationOfShorts: '',
    minCoinsToCashOut: '',
    minCoinsForPayout: '',
    pkEndTime: '',
    expertPrivacyPolicyUrl: '',
    aboutUsUrl: '',
    helpdeskEmail: '',
    userPrivacyPolicyUrl: '',
    shortsEffectEnabled: false,
    androidEffectLicenseKey: '',
    iosEffectLicenseKey: '',
    watermarkEnabled: false,
    watermarkIcon: '',
    agoraAppId: '',
    agoraAppCertificate: '',
    isDummyData: false,
    videoCallRatePrivate: '',
    maxVideoCallRatePrivate: '',
    audioCallRatePrivate: '',
    maxAudioCallRatePrivate: '',
    dailyLoginBonusCoins: '',
    isDemoContentEnabled: '',
    isApplicationLive: '',
    allowBecomeHostOption: '',
    androidAppVersion: '',
    iosAppVersion: '',
    androidAppLink: '',
    iosAppLink: '',
    sessionCommissionPercent: '',
    monetizationMode: 'subscription_session_commission',
    requireActiveSubscriptionForSessionBooking: false,
    allowDirectPaidSessionBooking: true,
    sessionSlotDurationMinutes: 30,
    sessionBookingTimezone: 'UTC',
    sessionUserCancellationTimeLimitMinutes: '',
    sessionUserCancellationRefundPercent: '',
    sessionUserCancellationRefundCredits: true,
    sessionUserCancellationRefundCreditsCount: '',
    sessionExpertCancellationPenaltyPercent: '',
    sessionJoinEarlyWindowMinutes: '',
    sessionJoinLateWindowMinutes: '',
    groupAudioSessionPricingMode: 'paid',
    groupVideoSessionPricingMode: 'paid',
    groupAudioSessionCredits: 1,
    groupVideoSessionCredits: 1,
    groupSessionCommissionPercent: '',
    groupSessionMinimumExpertTalkTimeMinutes: '',
    autoExpertBadgeEnabled: false,
    autoExpertBadgeSessionThreshold: 0,
    isReferralProgramEnabled: false,
    referralRewardTriggerType: 'subscription',
    referralRewardAmount: 0,
    referralRewardCurrency: 'credits',
    referralLinkBaseUrl: 'https://notisboard.com/ref',
  })

  const [privateKeyJson, setPrivateKeyJson] = useState('')
  const [jsonError, setJsonError] = useState('')

  // Update form data when settings are fetched
  useEffect(() => {
    if (settings) {
      const newData = {
        ...settings,
        _id: settings._id || '',
        loginBonus: settings.loginBonus?.toString() || '',
        durationOfShorts: settings.durationOfShorts?.toString() || '',
        pkEndTime: settings.pkEndTime?.toString() || '',
        minCoinsToCashOut: settings.minCoinsToCashOut?.toString() || '',
        minCoinsForPayout: settings.minCoinsForPayout?.toString() || '',
        userPrivacyPolicyUrl: settings.userPrivacyPolicyUrl || '',
        expertPrivacyPolicyUrl: settings.expertPrivacyPolicyUrl || '',
        aboutUsUrl: settings.aboutUsUrl || '',
        helpdeskEmail: settings.helpdeskEmail || '',
        shortsEffectEnabled: settings.shortsEffectEnabled || false,
        androidEffectLicenseKey: settings.androidEffectLicenseKey || '',
        iosEffectLicenseKey: settings.iosEffectLicenseKey || '',
        watermarkEnabled: settings.watermarkEnabled || false,
        watermarkIcon: settings.watermarkIcon || '',
        zegoAppId: settings.zegoAppId || '',
        zegoAppSignIn: settings.zegoAppSignIn || '',
        isDummyData: settings.isDummyData || false,
        videoCallRatePrivate: settings.videoCallRatePrivate || 0,
        maxVideoCallRatePrivate: settings.maxVideoCallRatePrivate || 0,
        audioCallRatePrivate: settings.audioCallRatePrivate || 0,
        maxAudioCallRatePrivate: settings.maxAudioCallRatePrivate || 0,
        dailyLoginBonusCoins: settings.dailyLoginBonusCoins || 0,
        adminCommissionPercent: settings.adminCommissionPercent || 0,
        sessionCommissionPercent: settings.sessionCommissionPercent || 0,
        monetizationMode: settings.monetizationMode || 'subscription_session_commission',
        requireActiveSubscriptionForSessionBooking: settings.requireActiveSubscriptionForSessionBooking || false,
        allowDirectPaidSessionBooking: settings.allowDirectPaidSessionBooking !== false,
        sessionSlotDurationMinutes: settings.sessionSlotDurationMinutes ?? 30,
        sessionBookingTimezone: settings.sessionBookingTimezone || 'UTC',
        sessionUserCancellationTimeLimitMinutes: settings.sessionUserCancellationTimeLimitMinutes ?? 60,
        sessionUserCancellationRefundPercent: settings.sessionUserCancellationRefundPercent ?? 100,
        sessionUserCancellationRefundCredits: settings.sessionUserCancellationRefundCredits !== false,
        sessionUserCancellationRefundCreditsCount: settings.sessionUserCancellationRefundCreditsCount ?? 1,
        sessionExpertCancellationPenaltyPercent: settings.sessionExpertCancellationPenaltyPercent ?? 10,
        sessionJoinEarlyWindowMinutes: settings.sessionJoinEarlyWindowMinutes ?? 5,
        sessionJoinLateWindowMinutes: settings.sessionJoinLateWindowMinutes ?? 5,
        groupAudioSessionPricingMode: settings.groupAudioSessionPricingMode || 'paid',
        groupVideoSessionPricingMode: settings.groupVideoSessionPricingMode || 'paid',
        groupAudioSessionCredits: settings.groupAudioSessionCredits ?? 1,
        groupVideoSessionCredits: settings.groupVideoSessionCredits ?? 1,
        groupSessionCommissionPercent: settings.groupSessionCommissionPercent ?? settings.sessionCommissionPercent ?? 0,
        groupSessionMinimumExpertTalkTimeMinutes: settings.groupSessionMinimumExpertTalkTimeMinutes ?? 10,
        autoExpertBadgeEnabled: settings.autoExpertBadgeEnabled ?? false,
        autoExpertBadgeSessionThreshold: settings.autoExpertBadgeSessionThreshold ?? 0,
        isReferralProgramEnabled: settings.isReferralProgramEnabled ?? false,
        referralRewardTriggerType: settings.referralRewardTriggerType || 'subscription',
        referralRewardAmount: settings.referralRewardAmount ?? 0,
        referralRewardCurrency: settings.referralRewardCurrency || 'credits',
        referralLinkBaseUrl: settings.referralLinkBaseUrl || 'https://notisboard.com/ref',
        allowBecomeHostOption: settings.allowBecomeHostOption || false,
        isApplicationLive: settings.isApplicationLive || false,
        isDemoContentEnabled: settings.isDemoContentEnabled || false,
        androidAppVersion: settings.androidAppVersion || '1.0.0',
        iosAppVersion: settings.iosAppVersion || '1.0.0',
        androidAppLink: settings.androidAppLink || 'https://andriodapplink.com',
        iosAppLink: settings.iosAppLink || 'https://iosapplink.com'
      }

      setFormData(newData)
      setInitialData(newData)

      if (settings.privateKey) {
        try {
          setPrivateKeyJson(JSON.stringify(settings.privateKey, null, 2))
        } catch (err) {
          setPrivateKeyJson(JSON.stringify({}))
        }
      }
    }

   
  }, [settings])

  const handleFieldChange = (field, value) => {
    // Handle numeric fields differently
    if (
      [
        'privateCallRate',
        'loginBonus',
        'durationOfShorts',
        'pkEndTime',
        'minCoinsToCashOut',
        'minCoinsForPayout',
        'dailyLoginBonusCoins',
        'adminCommissionPercent',
        'sessionCommissionPercent',
        'sessionSlotDurationMinutes',
        'sessionUserCancellationTimeLimitMinutes',
        'sessionUserCancellationRefundPercent',
        'sessionUserCancellationRefundCreditsCount',
        'sessionExpertCancellationPenaltyPercent',
        'sessionJoinEarlyWindowMinutes',
        'sessionJoinLateWindowMinutes',
        'groupAudioSessionCredits',
        'groupVideoSessionCredits',
        'groupSessionCommissionPercent',
        'groupSessionMinimumExpertTalkTimeMinutes',
        'autoExpertBadgeSessionThreshold',
        'referralRewardAmount'
      ].includes(field)
    ) {
      // Allow empty string or valid numbers
      if (value === '' || !isNaN(value)) {
        setFormData(prev => ({
          ...prev,
          [field]: value
        }))
      }
    } else {
      setFormData(prev => ({
        ...prev,
        [field]: value
      }))
    }
  }

  const handleJsonChange = value => {
    setPrivateKeyJson(value)

    try {
      if (value.trim()) {
        const parsedJson = JSON.parse(value)

        setFormData(prev => ({
          ...prev,
          privateKey: parsedJson
        }))
        setJsonError('')
      } else {
        setFormData(prev => ({
          ...prev,
          privateKey: {}
        }))
      }
    } catch (err) {
      setJsonError('Invalid JSON format')
    }
  }

  const isSessionCreditMode = String(formData.monetizationMode || '').trim().toLowerCase() === 'subscription_session_commission'
  const isGroupAudioFree = String(formData.groupAudioSessionPricingMode || '').trim().toLowerCase() === 'free'
  const isGroupVideoFree = String(formData.groupVideoSessionPricingMode || '').trim().toLowerCase() === 'free'
  const privateAudioLabel = isSessionCreditMode ? 'Min Private Audio Credits' : 'Min Private Audio Rate'
  const maxPrivateAudioLabel = isSessionCreditMode ? 'Max Private Audio Credits' : 'Max Private Audio Rate'
  const privateVideoLabel = isSessionCreditMode ? 'Min Private Video Credits' : 'Min Private Video Rate'
  const maxPrivateVideoLabel = isSessionCreditMode ? 'Max Private Video Credits' : 'Max Private Video Rate'
  const privateRateUnitLabel = isSessionCreditMode ? 'credits/session' : 'coins/minute'

  const timezoneOptions = useMemo(() => {
    const currentSelectedTimezone = String(formData.sessionBookingTimezone || '').trim()
    let supported = []

    if (typeof Intl !== 'undefined' && typeof Intl.supportedValuesOf === 'function') {
      const candidate = Intl.supportedValuesOf('timeZone')

      if (Array.isArray(candidate) && candidate.length) {
        supported = candidate
      }
    }

    const uniqueTimezones = new Set(['UTC', ...supported])

    if (currentSelectedTimezone) {
      uniqueTimezones.add(currentSelectedTimezone)
    }

    return Array.from(uniqueTimezones)
      .map(timezoneValue => {
        const offsetMinutes = getTimezoneOffsetMinutes(timezoneValue)

        return {
          value: timezoneValue,
          offsetMinutes,
          label: `${timezoneValue} (${formatUtcOffset(offsetMinutes)})`
        }
      })
      .sort((left, right) => {
        if (left.offsetMinutes !== right.offsetMinutes) {
          return left.offsetMinutes - right.offsetMinutes
        }

        return left.value.localeCompare(right.value)
      })
  }, [formData.sessionBookingTimezone])

  const handleToggle = type => {

    if (settings?._id) {
      dispatch(toggleSetting({ settingId: settings._id, type }))
    }
  }

  const numericFields = [
    'privateCallRate',
    'loginBonus',
    'durationOfShorts',
    'pkEndTime',
    'minCoinsToCashOut',
    'minCoinsForPayout',
    'videoCallRatePrivate',
    'maxVideoCallRatePrivate',
    'audioCallRatePrivate',
    'maxAudioCallRatePrivate',
    'dailyLoginBonusCoins',
    'adminCommissionPercent',
    'sessionCommissionPercent',
    'sessionSlotDurationMinutes',
    'sessionUserCancellationTimeLimitMinutes',
    'sessionUserCancellationRefundPercent',
    'sessionUserCancellationRefundCreditsCount',
    'sessionExpertCancellationPenaltyPercent',
    'sessionJoinEarlyWindowMinutes',
    'sessionJoinLateWindowMinutes',
    'groupAudioSessionCredits',
    'groupVideoSessionCredits',
    'groupSessionCommissionPercent',
    'groupSessionMinimumExpertTalkTimeMinutes',
    'autoExpertBadgeSessionThreshold',
    'referralRewardAmount'
  ]

  const getUpdatedFields = () => {
    const updates = {}

    Object.keys(formData).forEach(key => {
      const current = formData[key]
      const original = initialData[key]

      // Check arrays
      if (Array.isArray(current) && Array.isArray(original)) {
        if (JSON.stringify(current) !== JSON.stringify(original)) {
          updates[key] = current
        }
      }

      // Check other values
      else if (current !== original) {
        // Convert numeric fields before sending
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

    const updatedFields = getUpdatedFields();

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

  const handlePopoverOpen = event => {
    setAnchorEl(event.currentTarget)
  }

  const handlePopoverClose = () => {
    setAnchorEl(null)
  }

  return (
    <Box>
      {/* <Box sx={{ p: 5 }}>
        <HoverPopover popoverContent={"bdfb"}>
          <i className='tabler-info-circle' />
        </HoverPopover>
      </Box> */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Box>
          <Typography variant='h4'>General Setting</Typography>
          <Typography variant='body2' color='text.secondary'>
            Manage global platform configurations including app settings, commissions, and call rate controls.
          </Typography>
        </Box>
        <Button
          variant='contained'
          color='primary'
          onClick={handleSubmit}
          disabled={loading || !!jsonError}
          startIcon={loading ? <CircularProgress color='white' size={20} /> : <i className='tabler-device-floppy' />}
        >
          Save Changes
        </Button>
      </Box>

      {/* App Settings */}
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
              <i className='tabler-settings mr-2' />
              App Setting
            </Typography>
            <HoverPopover
              popoverContent={
                <>
                  <Box>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['dailyLoginBonusCoins'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['dailyLoginBonusCoins'].tooltip}</p>
                  </Box>

                  <Box className='mt-2'>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['adminCommissionPercent'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['adminCommissionPercent'].tooltip}</p>
                  </Box>

                  <Box>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['androidAppLink'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['androidAppLink'].tooltip}</p>
                  </Box>

                  <Box className='mt-2'>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['IOSappVersion'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['IOSappVersion'].tooltip}</p>
                  </Box>

                  <Box>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['androidAppLink'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['androidAppLink'].tooltip}</p>
                  </Box>

                  <Box className='mt-2'>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['iosAppLink'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['iosAppLink'].tooltip}</p>
                  </Box>
                </>
              }
            >
              <i className='tabler-info-circle' />
            </HoverPopover>
          </Box>
          <Divider sx={{ mb: 3 }} />
          <Grid container spacing={3}>
            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='Login Bonus'
                value={formData.dailyLoginBonusCoins}
                onChange={e => handleFieldChange('dailyLoginBonusCoins', e.target.value)}
                InputProps={{
                  inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                  endAdornment: (
                    <InputAdornment position='end'>
                      <Typography variant='caption' color='text.secondary'>
                        coins
                      </Typography>
                    </InputAdornment>
                  )
                }}
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='Admin Commission Percent'
                value={formData.adminCommissionPercent || ''}
                onChange={e => handleFieldChange('adminCommissionPercent', e.target.value)}
                InputProps={{
                  inputProps: { inputMode: 'numeric', pattern: '[0-9]*' }
                }}
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='Session Commission Percent'
                value={formData.sessionCommissionPercent || ''}
                onChange={e => handleFieldChange('sessionCommissionPercent', e.target.value)}
                InputProps={{
                  inputProps: { inputMode: 'numeric', pattern: '[0-9]*' }
                }}
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                select
                label='Monetization Mode'
                value={formData.monetizationMode || 'subscription_session_commission'}
                onChange={e => handleFieldChange('monetizationMode', e.target.value)}
              >
                <MenuItem value='subscription_session_commission'>Subscription + Session Commission</MenuItem>
                <MenuItem value='coin_per_minute'>Legacy Session Credit Per Minute (deprecated)</MenuItem>
              </TextField>
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='Android App Version'
                value={formData.androidAppVersion || ''}
                onChange={e => handleFieldChange('androidAppVersion', e.target.value)}
                InputProps={{
                  inputProps: { inputMode: 'numeric', pattern: '[0-9.]*' }
                }}
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='IOS App Version'
                value={formData.iosAppVersion || ''}
                onChange={e => handleFieldChange('iosAppVersion', e.target.value)}
                InputProps={{
                  inputProps: { inputMode: 'numeric', pattern: '[0-9.]*' }
                }}
              />
            </Grid>

            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='Android App Link'
                value={formData.androidAppLink || ''}
                onChange={e => handleFieldChange('androidAppLink', e.target.value)}
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='IOS App Link'
                value={formData.iosAppLink || ''}
                onChange={e => handleFieldChange('iosAppLink', e.target.value)}
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Box>
              <Typography variant='subtitle1' sx={{ mb: 0.5, fontWeight: 600, display: 'flex', alignItems: 'center' }}>
                <i className='tabler-calendar-stats mr-2' />
                Session & Call Settings
              </Typography>
              <Typography variant='body2' color='text.secondary'>
                Configure one-to-one calls and live group sessions from one place.
              </Typography>
            </Box>
            <HoverPopover
              popoverContent={
                <>
                  <Box>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['audioCallRatePrivate'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['audioCallRatePrivate'].tooltip}</p>
                  </Box>
                  <Box className='mt-2'>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['videoCallRatePrivate'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['videoCallRatePrivate'].tooltip}</p>
                  </Box>
                </>
              }
            >
              <i className='tabler-info-circle' />
            </HoverPopover>
          </Box>

          <Divider sx={{ mb: 3 }} />

          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
            <Box
              sx={{
                p: 3,
                border: theme => `1px solid ${theme.palette.divider}`,
                borderRadius: 2,
                bgcolor: 'background.default'
              }}
            >
              <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 600, display: 'flex', alignItems: 'center' }}>
                <i className='tabler-user-check mr-2' />
                One-to-One Call Setting
              </Typography>
              <Divider sx={{ mb: 3 }} />

              <Grid container spacing={3}>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    select
                    label='Session Slot Duration (minutes)'
                    value={formData.sessionSlotDurationMinutes || 30}
                    onChange={e => handleFieldChange('sessionSlotDurationMinutes', e.target.value)}
                  >
                    {[15, 30, 45, 60, 90, 120, 180, 240].map(duration => (
                      <MenuItem key={duration} value={duration}>
                        {duration} minutes
                      </MenuItem>
                    ))}
                  </TextField>
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    select
                    label='Session Booking Timezone'
                    value={formData.sessionBookingTimezone || 'UTC'}
                    onChange={e => handleFieldChange('sessionBookingTimezone', e.target.value)}
                    helperText={`Availability and booking policy are anchored to this timezone. Showing ${timezoneOptions.length} supported timezones with UTC offsets.`}
                    SelectProps={{
                      MenuProps: {
                        PaperProps: {
                          style: {
                            maxHeight: 320
                          }
                        }
                      }
                    }}
                  >
                    {timezoneOptions.map(timezoneOption => (
                      <MenuItem key={timezoneOption.value} value={timezoneOption.value}>
                        {timezoneOption.label}
                      </MenuItem>
                    ))}
                  </TextField>
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label={privateAudioLabel}
                    value={formData.audioCallRatePrivate || ''}
                    onChange={e => handleFieldChange('audioCallRatePrivate', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                      endAdornment: (
                        <InputAdornment position='end'>
                          <Typography variant='caption' color='text.secondary'>
                            {privateRateUnitLabel}
                          </Typography>
                        </InputAdornment>
                      )
                    }}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label={maxPrivateAudioLabel}
                    value={formData.maxAudioCallRatePrivate || ''}
                    onChange={e => handleFieldChange('maxAudioCallRatePrivate', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                      endAdornment: (
                        <InputAdornment position='end'>
                          <Typography variant='caption' color='text.secondary'>
                            {privateRateUnitLabel}
                          </Typography>
                        </InputAdornment>
                      )
                    }}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label={privateVideoLabel}
                    value={formData.videoCallRatePrivate || ''}
                    onChange={e => handleFieldChange('videoCallRatePrivate', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                      endAdornment: (
                        <InputAdornment position='end'>
                          <Typography variant='caption' color='text.secondary'>
                            {privateRateUnitLabel}
                          </Typography>
                        </InputAdornment>
                      )
                    }}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label={maxPrivateVideoLabel}
                    value={formData.maxVideoCallRatePrivate || ''}
                    onChange={e => handleFieldChange('maxVideoCallRatePrivate', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                      endAdornment: (
                        <InputAdornment position='end'>
                          <Typography variant='caption' color='text.secondary'>
                            {privateRateUnitLabel}
                          </Typography>
                        </InputAdornment>
                      )
                    }}
                  />
                </Grid>
                <Grid item size={12}>
                  <Box sx={{ display: 'flex', flexWrap: 'wrap', columnGap: 4, rowGap: 1 }}>
                    <FormControlLabel
                      control={
                        <Switch
                          checked={Boolean(formData.requireActiveSubscriptionForSessionBooking)}
                          onChange={e => handleFieldChange('requireActiveSubscriptionForSessionBooking', e.target.checked)}
                        />
                      }
                      label='Require Active Subscription For Session Booking'
                    />
                    <FormControlLabel
                      control={
                        <Switch
                          checked={Boolean(formData.allowDirectPaidSessionBooking)}
                          onChange={e => handleFieldChange('allowDirectPaidSessionBooking', e.target.checked)}
                        />
                      }
                      label='Allow Direct Paid Session Booking'
                    />
                  </Box>
                </Grid>
                <Grid item size={12}>
                  <Typography variant='subtitle2' sx={{ mt: 1, mb: 1, fontWeight: 600 }}>
                    One-to-One Cancellation & Start Window Policy
                  </Typography>
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label='User Cancellation Time Limit (minutes before start)'
                    value={formData.sessionUserCancellationTimeLimitMinutes || ''}
                    onChange={e => handleFieldChange('sessionUserCancellationTimeLimitMinutes', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' }
                    }}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label='User Late Cancellation Refund (%)'
                    value={formData.sessionUserCancellationRefundPercent || ''}
                    onChange={e => handleFieldChange('sessionUserCancellationRefundPercent', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                      endAdornment: (
                        <InputAdornment position='end'>
                          <Typography variant='caption' color='text.secondary'>
                            %
                          </Typography>
                        </InputAdornment>
                      )
                    }}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label='Expert Cancellation Penalty (%)'
                    value={formData.sessionExpertCancellationPenaltyPercent || ''}
                    onChange={e => handleFieldChange('sessionExpertCancellationPenaltyPercent', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                      endAdornment: (
                        <InputAdornment position='end'>
                          <Typography variant='caption' color='text.secondary'>
                            %
                          </Typography>
                        </InputAdornment>
                      )
                    }}
                  />
                </Grid>
                <Grid item size={6}>
                  <FormControlLabel
                    control={
                      <Switch
                        checked={Boolean(formData.sessionUserCancellationRefundCredits)}
                        onChange={e => handleFieldChange('sessionUserCancellationRefundCredits', e.target.checked)}
                      />
                    }
                    label='Restore Subscription Credits On Eligible User Cancellation'
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label='User Cancellation Refund Credits (count)'
                    value={formData.sessionUserCancellationRefundCreditsCount || ''}
                    onChange={e => handleFieldChange('sessionUserCancellationRefundCreditsCount', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' }
                    }}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label='Join Early Window (minutes)'
                    value={formData.sessionJoinEarlyWindowMinutes || ''}
                    onChange={e => handleFieldChange('sessionJoinEarlyWindowMinutes', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' }
                    }}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label='Join Late Window (minutes after end)'
                    value={formData.sessionJoinLateWindowMinutes || ''}
                    onChange={e => handleFieldChange('sessionJoinLateWindowMinutes', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' }
                    }}
                  />
                </Grid>
	              </Grid>
	            </Box>

	            <Box
	              sx={{
	                p: 3,
	                border: theme => `1px solid ${theme.palette.divider}`,
	                borderRadius: 2,
	                bgcolor: 'background.default'
	              }}
	            >
	              <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 600, display: 'flex', alignItems: 'center' }}>
	                <i className='tabler-clock-check mr-2' />
	                Shared Session Completion Policy
	              </Typography>
	              <Divider sx={{ mb: 3 }} />

	              <Grid container spacing={3}>
	                <Grid item size={6}>
	                  <TextField
	                    fullWidth
	                    type='text'
	                    label='Minimum Expert Talk Time (All Sessions)'
	                    helperText='Applies to both one-to-one and live group sessions. Changing this value affects both.'
	                    value={formData.groupSessionMinimumExpertTalkTimeMinutes || ''}
	                    onChange={e => handleFieldChange('groupSessionMinimumExpertTalkTimeMinutes', e.target.value)}
	                    InputProps={{
	                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
	                      endAdornment: (
	                        <InputAdornment position='end'>
	                          <Typography variant='caption' color='text.secondary'>
	                            minutes
	                          </Typography>
	                        </InputAdornment>
	                      )
	                    }}
	                  />
	                </Grid>
	              </Grid>
	            </Box>

	            <Box
	              sx={{
	                p: 3,
                border: theme => `1px solid ${theme.palette.divider}`,
                borderRadius: 2,
                bgcolor: 'background.default'
              }}
            >
              <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 600, display: 'flex', alignItems: 'center' }}>
                <i className='tabler-users-group mr-2' />
                Live Group Session Setting
              </Typography>
              <Divider sx={{ mb: 3 }} />

              <Grid container spacing={3}>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    select
                    label='Group Audio Session Mode'
                    value={formData.groupAudioSessionPricingMode || 'paid'}
                    onChange={e => handleFieldChange('groupAudioSessionPricingMode', e.target.value)}
                  >
                    <MenuItem value='paid'>Paid (Session Credits)</MenuItem>
                    <MenuItem value='free'>Free</MenuItem>
                  </TextField>
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label='Group Audio Session Credits'
                    value={formData.groupAudioSessionCredits ?? ''}
                    disabled={isGroupAudioFree}
                    onChange={e => handleFieldChange('groupAudioSessionCredits', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                      endAdornment: (
                        <InputAdornment position='end'>
                          <Typography variant='caption' color='text.secondary'>
                            credits
                          </Typography>
                        </InputAdornment>
                      )
                    }}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    select
                    label='Group Video Session Mode'
                    value={formData.groupVideoSessionPricingMode || 'paid'}
                    onChange={e => handleFieldChange('groupVideoSessionPricingMode', e.target.value)}
                  >
                    <MenuItem value='paid'>Paid (Session Credits)</MenuItem>
                    <MenuItem value='free'>Free</MenuItem>
                  </TextField>
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label='Group Video Session Credits'
                    value={formData.groupVideoSessionCredits ?? ''}
                    disabled={isGroupVideoFree}
                    onChange={e => handleFieldChange('groupVideoSessionCredits', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                      endAdornment: (
                        <InputAdornment position='end'>
                          <Typography variant='caption' color='text.secondary'>
                            credits
                          </Typography>
                        </InputAdornment>
                      )
                    }}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label='Group Session Commission (%)'
                    value={formData.groupSessionCommissionPercent || ''}
                    onChange={e => handleFieldChange('groupSessionCommissionPercent', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                      endAdornment: (
                        <InputAdornment position='end'>
                          <Typography variant='caption' color='text.secondary'>
                            %
                          </Typography>
                        </InputAdornment>
                      )
                    }}
	                  />
	                </Grid>
	              </Grid>
	            </Box>
          </Box>
        </CardContent>
      </Card>

      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
              <i className='tabler-badge mr-2' />
              Expert Verification Badge
            </Typography>
          </Box>

          <Divider sx={{ mb: 3 }} />

          <Grid container spacing={3}>
            <Grid item size={6}>
              <FormControlLabel
                control={
                  <Switch
                    checked={Boolean(formData.autoExpertBadgeEnabled)}
                    onChange={event => handleFieldChange('autoExpertBadgeEnabled', event.target.checked)}
                  />
                }
                label='Auto verify experts by completed sessions'
              />
            </Grid>

            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='Auto verify threshold (completed sessions)'
                value={formData.autoExpertBadgeSessionThreshold ?? ''}
                onChange={e => handleFieldChange('autoExpertBadgeSessionThreshold', e.target.value)}
                disabled={!Boolean(formData.autoExpertBadgeEnabled)}
                InputProps={{
                  inputProps: { inputMode: 'numeric', pattern: '[0-9]*', min: 0 },
                  endAdornment: (
                    <InputAdornment position='end'>
                      <Typography variant='caption' color='text.secondary'>
                        sessions
                      </Typography>
                    </InputAdornment>
                  )
                }}
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Box>
              <Typography variant='subtitle1' sx={{ mb: 0.5, fontWeight: 600, display: 'flex', alignItems: 'center' }}>
                <i className='tabler-gift mr-2' />
                Referral Program
              </Typography>
              <Typography variant='body2' color='text.secondary'>
                Configure invite rewards and when referral credits should be approved.
              </Typography>
            </Box>
          </Box>

          <Divider sx={{ mb: 3 }} />

          <Grid container spacing={3}>
            <Grid item size={12}>
              <FormControlLabel
                control={
                  <Switch
                    checked={Boolean(formData.isReferralProgramEnabled)}
                    onChange={event => handleFieldChange('isReferralProgramEnabled', event.target.checked)}
                  />
                }
                label='Enable referral program'
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                select
                label='Reward trigger'
                value={formData.referralRewardTriggerType || 'subscription'}
                onChange={e => handleFieldChange('referralRewardTriggerType', e.target.value)}
                disabled={!Boolean(formData.isReferralProgramEnabled)}
                helperText='Rewards are only approved after this trusted action.'
              >
                <MenuItem value='signup'>Successful signup</MenuItem>
                <MenuItem value='subscription'>Successful subscription/payment</MenuItem>
                <MenuItem value='completed_session'>First completed session</MenuItem>
              </TextField>
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='Reward amount'
                value={formData.referralRewardAmount ?? ''}
                onChange={e => handleFieldChange('referralRewardAmount', e.target.value)}
                disabled={!Boolean(formData.isReferralProgramEnabled)}
                InputProps={{
                  inputProps: { inputMode: 'numeric', pattern: '[0-9]*', min: 0 },
                  endAdornment: (
                    <InputAdornment position='end'>
                      <Typography variant='caption' color='text.secondary'>
                        {formData.referralRewardCurrency || 'credits'}
                      </Typography>
                    </InputAdornment>
                  )
                }}
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                label='Reward currency label'
                value={formData.referralRewardCurrency || ''}
                onChange={e => handleFieldChange('referralRewardCurrency', e.target.value)}
                disabled={!Boolean(formData.isReferralProgramEnabled)}
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                label='Referral link base URL'
                value={formData.referralLinkBaseUrl || ''}
                onChange={e => handleFieldChange('referralLinkBaseUrl', e.target.value)}
                disabled={!Boolean(formData.isReferralProgramEnabled)}
                helperText='Example: https://notisboard.com/ref'
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Agora settings keys */}
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
              <i className='tabler-settings mr-2' />
              Zego Setting
            </Typography>
            <HoverPopover
              popoverContent={
                <>
                  <Box>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['zegoAppId'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['zegoAppId'].tooltip}</p>
                  </Box>
                  <Box className='mt-2'>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['zegoAppSignIn'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['zegoAppSignIn'].tooltip}</p>
                  </Box>
                </>
              }
            >
              <i className='tabler-info-circle' />
            </HoverPopover>
          </Box>

          <Divider sx={{ mb: 3 }} />

          <Grid container spacing={3}>
            <Grid item size={6}>
              <TextField
                fullWidth
                label='Zego App ID'
                value={formData.zegoAppId || ''}
                onChange={e => handleFieldChange('zegoAppId', e.target.value)}
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                label='Zego App SignIn'
                value={formData.zegoAppSignIn || ''}
                onChange={e => handleFieldChange('zegoAppSignIn', e.target.value)}
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Policy Links */}
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
              <i className='tabler-settings mr-2' />
              Policy Links
            </Typography>
            <HoverPopover
              popoverContent={
                <>
                  <Box>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['userPrivacyPolicyUrl'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['userPrivacyPolicyUrl'].tooltip}</p>
                  </Box>
                  <Box className='mt-2'>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['expertPrivacyPolicyUrl'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['expertPrivacyPolicyUrl'].tooltip}</p>
                  </Box>
                  <Box className='mt-2'>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['aboutUsUrl'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['aboutUsUrl'].tooltip}</p>
                  </Box>
                </>
              }
            >
              <i className='tabler-info-circle' />
            </HoverPopover>
          </Box>

          <Divider sx={{ mb: 3 }} />

          <Grid container spacing={3}>
            <Grid item size={6}>
              <TextField
                fullWidth
                label='Privacy Policy (User)'
                value={formData.userPrivacyPolicyUrl || ''}
                onChange={e => handleFieldChange('userPrivacyPolicyUrl', e.target.value)}
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                label='Privacy Policy Link (Expert)'
                value={formData.expertPrivacyPolicyUrl || ''}
                onChange={e => handleFieldChange('expertPrivacyPolicyUrl', e.target.value)}
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                label='About Us Link'
                value={formData.aboutUsUrl || ''}
                onChange={e => handleFieldChange('aboutUsUrl', e.target.value)}
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
              <i className='tabler-help-octagon mr-2' />
              Support Setting
            </Typography>
            <HoverPopover
              popoverContent={
                <>
                  <Box>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['helpdeskEmail'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['helpdeskEmail'].tooltip}</p>
                  </Box>
                </>
              }
            >
              <i className='tabler-info-circle' />
            </HoverPopover>
          </Box>

          <Divider sx={{ mb: 3 }} />

          <Grid container spacing={3}>
            <Grid item size={6}>
              <TextField
                fullWidth
                label='Support Email'
                value={formData.helpdeskEmail || ''}
                onChange={e => handleFieldChange('helpdeskEmail', e.target.value)}
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Firebase Configuration */}
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
              <i className='tabler-brand-firebase mr-2' />
              Firebase Notification Setting
            </Typography>
            <HoverPopover
              popoverContent={
                <>
                  <Box>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['privateKeyJson'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['privateKeyJson'].tooltip}</p>
                  </Box>
                </>
              }
            >
              <i className='tabler-info-circle' />
            </HoverPopover>
          </Box>

          <Divider sx={{ mb: 3 }} />

          <Typography variant='subtitle2' sx={{ mb: 2 }}>
            Private Key JSON
          </Typography>

          <TextField
            fullWidth
            multiline
            rows={10}
            value={privateKeyJson || ''}
            onChange={e => handleJsonChange(e.target.value)}
            placeholder={'Paste your Firebase private key JSON here'
                
            }
            error={!!jsonError}
            helperText={jsonError}
            sx={{
              '& .MuiInputBase-root': {
                fontFamily: 'monospace',
                fontSize: '0.875rem'
              }
            }}
          />

          {!jsonError && privateKeyJson && (
            <Alert severity='success' sx={{ mt: 2 }}>
              Firebase configuration is valid
            </Alert>
          )}

          <Alert severity='info' sx={{ mt: 3 }}>
            <Typography variant='body2'>
              Paste your Firebase service account JSON credentials from Firebase console. This is used for server-side
              Firebase operations.
            </Typography>
          </Alert>
        </CardContent>
      </Card>

      <Card>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
              <i className='tabler-settings mr-2' />
              Other Setting
            </Typography>
            <HoverPopover
              popoverContent={
                <>
                  <Box>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['isDemoContentEnabled'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['isDemoContentEnabled'].tooltip}</p>
                  </Box>
                  <Box className='mt-2'>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['allowBecomeHostOption'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['allowBecomeHostOption'].tooltip}</p>
                  </Box>
                  <Box className='mt-2'>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['isApplicationLive'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['isApplicationLive'].tooltip}</p>
                  </Box>
                </>
              }
            >
              <i className='tabler-info-circle' />
            </HoverPopover>
          </Box>
          <Divider sx={{ mb: 3 }} />
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <FormControlLabel
              control={
                <Switch
                  value={''}
                  checked={formData.isDemoContentEnabled || ''}
                  onChange={() => handleToggle('isDemoContentEnabled')}
                  name='isDemoContentEnabled'
                />
              }
              label='Demo Content'
            />
          </Box>
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <FormControlLabel
              control={
                <Switch
                  value={''}
                  checked={formData.allowBecomeHostOption || ''}
                  onChange={() => handleToggle('allowBecomeHostOption')}
                  name='allowBecomeHostOption'
                />
              }
              label='Allow to become host'
            />
          </Box>
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <FormControlLabel
              control={
                <Switch
                  value={''}
                  checked={formData.isApplicationLive || ''}
                  onChange={() => handleToggle('isApplicationLive')}
                  name='isApplicationLive'
                />
              }
              label='Application Live'
            />
          </Box>
        </CardContent>
      </Card>

      {/* <Box sx={{ display: 'flex', justifyContent: 'flex-end', mt: 4 }}>
        <Button
          variant='contained'
          onClick={handleSubmit}
          disabled={loading || !!jsonError}
          startIcon={loading ? <CircularProgress size={20} /> : <i className='tabler-device-floppy' />}
        >
          Save Changes
        </Button>
      </Box> */}
    </Box>
  )
}

export default GeneralSettings
