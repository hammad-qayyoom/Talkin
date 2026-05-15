'use client'

import React, { forwardRef, useEffect, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'

import Slide from '@mui/material/Slide'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'
import Button from '@mui/material/Button'
import Typography from '@mui/material/Typography'
import TextField from '@mui/material/TextField'
import CircularProgress from '@mui/material/CircularProgress'
import FormControlLabel from '@mui/material/FormControlLabel'
import Switch from '@mui/material/Switch'
import MenuItem from '@mui/material/MenuItem'
import { toast } from 'react-toastify'

import DialogCloseButton from '@components/dialogs/DialogCloseButton'

import { createCoinPlan, updateCoinPlan } from '@/redux-store/slices/coinPlans'



const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const CoinPlanDialog = ({ open, onClose, mode = 'create', coinPlan = null }) => {
  const dispatch = useDispatch()
  const { loading } = useSelector(state => state.coinPlansReducer)

  const [formData, setFormData] = useState({
    name: '',
    sessionCredits: '',
    price: '',
    billingCycle: 'monthly',
    appleProductId: '',
    googleProductId: '',
    isPopular: false,
    isActive: true
  })

  const [errors, setErrors] = useState({})
  const [isSubmitting, setIsSubmitting] = useState(false)

  useEffect(() => {
    if (mode === 'edit' && coinPlan) {
      setFormData({
        name: coinPlan.name || '',
        sessionCredits: coinPlan.sessionCredits || coinPlan.coins || '',
        price: coinPlan.price || '',
        billingCycle: coinPlan.billingCycle || 'monthly',
        appleProductId: coinPlan.appleProductId || coinPlan.productId || '',
        googleProductId: coinPlan.googleProductId || '',
        isPopular: coinPlan.isPopular || false,
        isActive: coinPlan.isActive !== undefined ? coinPlan.isActive : true
      })
    } else {
      setFormData({
        name: '',
        sessionCredits: '',
        price: '',
        billingCycle: 'monthly',
        appleProductId: '',
        googleProductId: '',
        isPopular: false,
        isActive: true
      })
    }
  }, [mode, coinPlan])

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))

    // Clear field-specific error if valid
    setErrors(prev => {
      const updatedErrors = { ...prev }

      if (field === 'sessionCredits' && value > 0) {
        delete updatedErrors.sessionCredits
      } else if (field === 'price' && value > 0) {
        delete updatedErrors.price
      } else if (field === 'appleProductId' && value.trim() !== '') {
        delete updatedErrors.appleProductId
      }

      return updatedErrors
    })
  }

  const handleValidation = () => {
    const newErrors = {}

    if (!formData.sessionCredits || formData.sessionCredits <= 0) {
      newErrors.sessionCredits = 'Session credits must be a positive number'
    }

    if (!formData.price || formData.price <= 0) {
      newErrors.price = 'Price must be a positive number'
    }

    if (!formData.appleProductId || formData.appleProductId.trim() === '') {
      newErrors.appleProductId = 'Apple product ID is required for iOS subscriptions'
    }

    setErrors(newErrors)

    return Object.keys(newErrors).length === 0
  }

  const { profileData } = useSelector(state => state.adminSlice)


  const handleSubmit = async () => {
      
    
    if (!handleValidation()) return

    try {
      setIsSubmitting(true)

      if (mode === 'edit') {
        const updatedPayload = {}

        if (formData.sessionCredits !== (coinPlan.sessionCredits || coinPlan.coins)) {
          updatedPayload.sessionCredits = formData.sessionCredits
          updatedPayload.coins = formData.sessionCredits
        }

        if (formData.name !== coinPlan.name) updatedPayload.name = formData.name
        if (formData.price !== coinPlan.price) updatedPayload.price = formData.price
        if (formData.billingCycle !== coinPlan.billingCycle) updatedPayload.billingCycle = formData.billingCycle

        if (formData.appleProductId !== (coinPlan.appleProductId || coinPlan.productId)) {
          updatedPayload.appleProductId = formData.appleProductId
          updatedPayload.productId = formData.appleProductId
        }

        if (formData.googleProductId !== coinPlan.googleProductId) updatedPayload.googleProductId = formData.googleProductId
        if (formData.isPopular !== coinPlan.isPopular) updatedPayload.isPopular = formData.isPopular
        if (formData.isActive !== coinPlan.isActive) updatedPayload.isActive = formData.isActive

        if (Object.keys(updatedPayload).length === 0) {
          toast.info('No changes detected')
        } else {
          await dispatch(
            updateCoinPlan({ coinPlanId: coinPlan._id, ...updatedPayload })
          ).unwrap()
        }
      } else {
        await dispatch(
          createCoinPlan({
            ...formData,
            productId: formData.appleProductId,
            coins: formData.sessionCredits
          })
        ).unwrap()
      }

      resetForm()
      onClose()
    } catch (error) {
      console.error('Error submitting form:', error)
      setErrors({ submit: 'An error occurred while submitting the form' })
    } finally {
      setIsSubmitting(false)
    }
  }

  const resetForm = () => {
    setFormData({
      name: '',
      sessionCredits: '',
      price: '',
      billingCycle: 'monthly',
      appleProductId: '',
      googleProductId: '',
      isPopular: false,
      isActive: true
    })
    setErrors({})
  }

  const handleClose = () => {
    resetForm()
    onClose()
  }

  return (
    <Dialog
      open={open}
      onClose={handleClose}
      keepMounted
      TransitionComponent={Transition}
      aria-labelledby='coinplan-dialog-title'
      fullWidth
      maxWidth='sm'
      PaperProps={{
        sx: {
          overflow: 'visible',
          width: '600px',
          maxWidth: '95vw'
        }
      }}
    >
      <DialogTitle id='coinplan-dialog-title'>
        <Typography variant='h5' component='span'>
          {mode === 'edit' ? 'Edit Subscription Plan' : 'Create Subscription Plan'}
        </Typography>
        <DialogCloseButton onClick={handleClose}>
          <i className='tabler-x' />
        </DialogCloseButton>
      </DialogTitle>

      <DialogContent className='flex flex-col gap-4 py-4'>
        <TextField
          label='Plan Name'
          fullWidth
          value={formData.name}
          onChange={e => handleChange('name', e.target.value)}
          placeholder='Premium Monthly'
        />

        <TextField
          label='Session Credits'
          type='number'
          fullWidth
          value={formData.sessionCredits}
          error={!!errors.sessionCredits}
          helperText={errors.sessionCredits || ''}
          onChange={e => handleChange('sessionCredits', parseInt(e.target.value, 10) || '')}
          placeholder='10'
          inputProps={{ min: 1 }}
        />

        <TextField
          label='Price'
          type='number'
          fullWidth
          value={formData.price}
          error={!!errors.price}
          helperText={errors.price || ''}
          onChange={e => handleChange('price', parseFloat(e.target.value) || '')}
          placeholder='9.99'
          inputProps={{ min: 0.01, step: 0.01 }}
        />

        <TextField
          select
          label='Billing Cycle'
          fullWidth
          value={formData.billingCycle}
          onChange={e => handleChange('billingCycle', e.target.value)}
        >
          <MenuItem value='monthly'>Monthly</MenuItem>
          <MenuItem value='quarterly'>Quarterly</MenuItem>
          <MenuItem value='yearly'>Yearly</MenuItem>
        </TextField>

        <TextField
          label='Apple Product ID'
          fullWidth
          value={formData.appleProductId}
          error={!!errors.appleProductId}
          helperText={errors.appleProductId || 'Must match the Product ID created in App Store Connect.'}
          onChange={e => handleChange('appleProductId', e.target.value)}
          placeholder='com.notisboard.premium.monthly'
        />

        <TextField
          label='Google Play Product ID'
          fullWidth
          value={formData.googleProductId}
          helperText='Optional. Used only when Google Play Billing is enabled on Android.'
          onChange={e => handleChange('googleProductId', e.target.value)}
          placeholder='premium_monthly'
        />

        {/* <div className='flex flex-col gap-2'>
          <FormControlLabel
            control={
              <Switch checked={formData.isPopular} onChange={e => handleChange('isPopular', e.target.checked)} />
            }
            label='Popular'
          />

          <FormControlLabel
            control={<Switch checked={formData.isActive} onChange={e => handleChange('isActive', e.target.checked)} />}
            label='Active'
          />
        </div> */}
      </DialogContent>

      <DialogActions>
        <Button variant='tonal' color='secondary' onClick={handleClose} disabled={loading}>
          Cancel
        </Button>
        <Button variant='contained' onClick={handleSubmit} disabled={isSubmitting || loading}>
          {isSubmitting || loading ? <CircularProgress size={24} /> : mode === 'edit' ? 'Update' : 'Create'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default CoinPlanDialog
