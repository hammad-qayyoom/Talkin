'use client'

import { useEffect, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'
import { toast } from 'react-toastify'

import Alert from '@mui/material/Alert'
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import CircularProgress from '@mui/material/CircularProgress'
import FormControlLabel from '@mui/material/FormControlLabel'
import Grid from '@mui/material/Grid'
import MenuItem from '@mui/material/MenuItem'
import Switch from '@mui/material/Switch'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'

import { updateSettings, toggleSetting } from '@/redux-store/slices/settings'

const APPLE_EULA_URL = 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'
const APPLE_MANAGE_SUBSCRIPTIONS_URL = 'https://apps.apple.com/account/subscriptions'

const defaultFormData = {
  _id: '',
  isAppleInAppPurchaseEnabled: true,
  appStoreBundleId: '',
  appStoreSharedSecret: '',
  appStoreIssuerId: '',
  appStoreKeyId: '',
  appStorePrivateKey: '',
  appStoreEnvironment: 'auto',
  appleManageSubscriptionsUrl: APPLE_MANAGE_SUBSCRIPTIONS_URL,
  appleEulaUrl: APPLE_EULA_URL,

  isStripeEnabled: false,
  stripePublicKey: '',
  stripeSecretKey: '',

  isRazorpayEnabled: false,
  razorpayKeyId: '',
  razorpayKeySecret: '',

  isFlutterwaveEnabled: false,
  flutterwavePublicKey: '',

  isPaystackAndroidEnabled: false,
  paystackPublicKey: '',
  paystackSecretKey: '',

  isCashfreeAndroidEnabled: false,
  cashfreeClientId: '',
  cashfreeClientSecret: '',

  isPaypalAndroidEnabled: false,
  paypalClientId: '',
  paypalSecretKey: '',

  isGooglePlayEnabled: false
}

const androidGateways = [
  {
    title: 'Stripe',
    switchField: 'isStripeEnabled',
    switchLabel: 'Enable Stripe (Android)',
    fields: [
      { name: 'stripePublicKey', label: 'Stripe Publishable Key' },
      { name: 'stripeSecretKey', label: 'Stripe Secret Key', secret: true }
    ]
  },
  {
    title: 'Razorpay',
    switchField: 'isRazorpayEnabled',
    switchLabel: 'Enable Razorpay (Android)',
    fields: [
      { name: 'razorpayKeyId', label: 'Razorpay ID' },
      { name: 'razorpayKeySecret', label: 'Razorpay Secret Key', secret: true }
    ]
  },
  {
    title: 'Flutterwave',
    switchField: 'isFlutterwaveEnabled',
    switchLabel: 'Enable Flutterwave (Android)',
    fields: [{ name: 'flutterwavePublicKey', label: 'Flutterwave Public Key' }]
  },
  {
    title: 'Paystack',
    switchField: 'isPaystackAndroidEnabled',
    switchLabel: 'Enable Paystack (Android)',
    fields: [
      { name: 'paystackPublicKey', label: 'Paystack Public Key' },
      { name: 'paystackSecretKey', label: 'Paystack Secret Key', secret: true }
    ]
  },
  {
    title: 'Cashfree',
    switchField: 'isCashfreeAndroidEnabled',
    switchLabel: 'Enable Cashfree (Android)',
    fields: [
      { name: 'cashfreeClientId', label: 'Cashfree Client ID' },
      { name: 'cashfreeClientSecret', label: 'Cashfree Client Secret', secret: true }
    ]
  },
  {
    title: 'PayPal',
    switchField: 'isPaypalAndroidEnabled',
    switchLabel: 'Enable PayPal (Android)',
    fields: [
      { name: 'paypalClientId', label: 'PayPal Client ID' },
      { name: 'paypalSecretKey', label: 'PayPal Secret Key', secret: true }
    ]
  },
  {
    title: 'Google Play Billing',
    switchField: 'isGooglePlayEnabled',
    switchLabel: 'Enable Google Play Billing (Android)',
    fields: []
  }
]

const PaymentSettings = () => {
  const dispatch = useDispatch()
  const { settings, loading } = useSelector(state => state.settings)

  const [formData, setFormData] = useState(defaultFormData)
  const [initialData, setInitialData] = useState(defaultFormData)

  useEffect(() => {
    if (!settings) return

    const nextData = {
      ...defaultFormData,
      ...Object.fromEntries(Object.keys(defaultFormData).map(key => [key, settings[key] ?? defaultFormData[key]])),
      _id: settings._id || '',
      isAppleInAppPurchaseEnabled: settings.isAppleInAppPurchaseEnabled !== false,
      appStoreEnvironment: settings.appStoreEnvironment || 'auto',
      appleManageSubscriptionsUrl: settings.appleManageSubscriptionsUrl || APPLE_MANAGE_SUBSCRIPTIONS_URL,
      appleEulaUrl: settings.appleEulaUrl || APPLE_EULA_URL
    }

    setFormData(nextData)
    setInitialData(nextData)
  }, [settings])

  const handleToggle = type => {
    if (!settings?._id) return

    dispatch(toggleSetting({ settingId: settings._id, type }))
    setFormData(prev => ({ ...prev, [type]: !prev[type] }))
  }

  const handleInputChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))
  }

  const getUpdatedFields = () => {
    const updates = {}

    Object.keys(formData).forEach(key => {
      if (formData[key] !== initialData[key]) {
        updates[key] = formData[key]
      }
    })

    return updates
  }

  const handleSubmit = () => {
    if (!settings?._id) return

    const updatedFields = getUpdatedFields()

    if (Object.keys(updatedFields).length === 0) {
      toast.info('No changes to update')

      return
    }

    dispatch(updateSettings({ _id: settings._id, ...updatedFields }))
  }

  const renderGatewayCard = gateway => (
    <Grid item size={12} key={gateway.title}>
      <Card>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3, gap: 2 }}>
            <Typography variant='subtitle1' sx={{ fontWeight: 600, display: 'flex', alignItems: 'center' }}>
              <i className='tabler-settings mr-2' />
              {gateway.title} Setting
            </Typography>
            <Typography variant='caption' color='text.secondary'>
              Android only
            </Typography>
          </Box>

          <FormControlLabel
            control={
              <Switch
                checked={Boolean(formData[gateway.switchField])}
                onChange={() => handleToggle(gateway.switchField)}
                name={gateway.switchField}
              />
            }
            label={gateway.switchLabel}
            sx={{ mb: gateway.fields.length ? 4 : 0 }}
          />

          {gateway.fields.length > 0 ? (
            <Grid container spacing={4}>
              {gateway.fields.map(field => (
                <Grid item size={gateway.fields.length === 1 ? 12 : 6} key={field.name}>
                  <TextField
                    fullWidth
                    label={field.label}
                    type={field.secret ? 'password' : 'text'}
                    value={formData[field.name] || ''}
                    onChange={event => handleInputChange(field.name, event.target.value)}
                  />
                </Grid>
              ))}
            </Grid>
          ) : null}
        </CardContent>
      </Card>
    </Grid>
  )

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4, gap: 3 }}>
        <Box>
          <Typography variant='h4'>Payment Setting</Typography>
          <Typography variant='body2' color='text.secondary'>
            Configure Android payment gateways and Apple In-App Purchase credentials for iOS subscriptions.
          </Typography>
        </Box>
        <Button
          variant='contained'
          color='primary'
          onClick={handleSubmit}
          disabled={loading}
          startIcon={
            loading ? <CircularProgress size={20} sx={{ color: 'white' }} /> : <i className='tabler-device-floppy' />
          }
        >
          Save Changes
        </Button>
      </Box>

      <Grid container spacing={6}>
        <Grid item size={12}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3, gap: 2 }}>
                <Typography variant='subtitle1' sx={{ fontWeight: 600, display: 'flex', alignItems: 'center' }}>
                  <i className='tabler-brand-apple mr-2' />
                  Apple In-App Purchase Setting
                </Typography>
                <Typography variant='caption' color='text.secondary'>
                  iOS only
                </Typography>
              </Box>

              <Alert severity='info' sx={{ mb: 4 }}>
                iOS checkout uses only Apple In-App Purchase. Stripe, Razorpay, PayPal, Paystack, Cashfree, Flutterwave,
                and Google Play are kept Android-only.
              </Alert>

              <FormControlLabel
                control={
                  <Switch
                    checked={Boolean(formData.isAppleInAppPurchaseEnabled)}
                    onChange={() => handleToggle('isAppleInAppPurchaseEnabled')}
                    name='isAppleInAppPurchaseEnabled'
                  />
                }
                label='Enable Apple In-App Purchase (iOS)'
                sx={{ mb: 4 }}
              />

              <Grid container spacing={4}>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    label='iOS Bundle ID'
                    value={formData.appStoreBundleId || ''}
                    onChange={event => handleInputChange('appStoreBundleId', event.target.value)}
                    placeholder='com.company.notisboard'
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    select
                    label='Receipt Environment'
                    value={formData.appStoreEnvironment || 'auto'}
                    onChange={event => handleInputChange('appStoreEnvironment', event.target.value)}
                  >
                    <MenuItem value='auto'>Auto</MenuItem>
                    <MenuItem value='production'>Production</MenuItem>
                    <MenuItem value='sandbox'>Sandbox</MenuItem>
                  </TextField>
                </Grid>
                <Grid item size={12}>
                  <TextField
                    fullWidth
                    label='App-Specific Shared Secret'
                    type='password'
                    value={formData.appStoreSharedSecret || ''}
                    onChange={event => handleInputChange('appStoreSharedSecret', event.target.value)}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    label='Issuer ID'
                    value={formData.appStoreIssuerId || ''}
                    onChange={event => handleInputChange('appStoreIssuerId', event.target.value)}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    label='Key ID'
                    value={formData.appStoreKeyId || ''}
                    onChange={event => handleInputChange('appStoreKeyId', event.target.value)}
                  />
                </Grid>
                <Grid item size={12}>
                  <TextField
                    fullWidth
                    multiline
                    minRows={4}
                    label='In-App Purchase Private Key (.p8)'
                    value={formData.appStorePrivateKey || ''}
                    onChange={event => handleInputChange('appStorePrivateKey', event.target.value)}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    label='Manage Subscriptions URL'
                    value={formData.appleManageSubscriptionsUrl || ''}
                    onChange={event => handleInputChange('appleManageSubscriptionsUrl', event.target.value)}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    label='Apple Standard EULA URL'
                    value={formData.appleEulaUrl || ''}
                    onChange={event => handleInputChange('appleEulaUrl', event.target.value)}
                  />
                </Grid>
              </Grid>
            </CardContent>
          </Card>
        </Grid>

        {androidGateways.map(renderGatewayCard)}
      </Grid>
    </Box>
  )
}

export default PaymentSettings
