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
import MenuItem from '@mui/material/MenuItem'

import DialogCloseButton from '@components/dialogs/DialogCloseButton'

import { createRecordingPlan, updateRecordingPlan } from '@/redux-store/slices/recordingPlans'

const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const RecordingPlanDialog = ({ open, onClose, mode = 'create', plan = null }) => {
  const dispatch = useDispatch()
  const { loading } = useSelector(state => state.recordingPlans)

  const [formData, setFormData] = useState({
    name: '',
    price: '',
    billingCycle: 'monthly',
    storageDays: 30,
    appleProductId: '',
    googleProductId: '',
    description: '',
    isPopular: false,
    isActive: true
  })

  const [errors, setErrors] = useState({})
  const [isSubmitting, setIsSubmitting] = useState(false)

  useEffect(() => {
    if (mode === 'edit' && plan) {
      setFormData({
        name: plan.name || '',
        price: plan.price || '',
        billingCycle: plan.billingCycle || 'monthly',
        storageDays: plan.storageDays || 30,
        appleProductId: plan.appleProductId || '',
        googleProductId: plan.googleProductId || '',
        description: plan.description || '',
        isPopular: plan.isPopular || false,
        isActive: plan.isActive !== undefined ? plan.isActive : true
      })
    } else {
      setFormData({
        name: '',
        price: '',
        billingCycle: 'monthly',
        storageDays: 30,
        appleProductId: '',
        googleProductId: '',
        description: '',
        isPopular: false,
        isActive: true
      })
    }
  }, [mode, plan])

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))
    setErrors(prev => {
      const updatedErrors = { ...prev }
      if ((field === 'price' || field === 'storageDays') && value > 0) {
        delete updatedErrors[field]
      }
      return updatedErrors
    })
  }

  const handleValidation = () => {
    const newErrors = {}
    if (!formData.name || formData.name.trim() === '') {
      newErrors.name = 'Plan name is required'
    }
    if (!formData.price || formData.price <= 0) {
      newErrors.price = 'Price must be a positive number'
    }
    if (!formData.storageDays || formData.storageDays <= 0) {
      newErrors.storageDays = 'Storage days must be a positive number'
    }
    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async () => {
    if (!handleValidation()) return

    try {
      setIsSubmitting(true)

      if (mode === 'edit') {
        const updatedPayload = {}
        if (formData.name !== plan.name) updatedPayload.name = formData.name
        if (formData.price !== plan.price) updatedPayload.price = formData.price
        if (formData.billingCycle !== plan.billingCycle) updatedPayload.billingCycle = formData.billingCycle
        if (Number(formData.storageDays) !== plan.storageDays) updatedPayload.storageDays = formData.storageDays
        if (formData.appleProductId !== plan.appleProductId) updatedPayload.appleProductId = formData.appleProductId
        if (formData.googleProductId !== plan.googleProductId) updatedPayload.googleProductId = formData.googleProductId
        if (formData.description !== (plan.description || '')) updatedPayload.description = formData.description
        if (formData.isPopular !== plan.isPopular) updatedPayload.isPopular = formData.isPopular
        if (formData.isActive !== plan.isActive) updatedPayload.isActive = formData.isActive

        if (Object.keys(updatedPayload).length === 0) {
          return
        }
        await dispatch(updateRecordingPlan({ planId: plan._id, ...updatedPayload })).unwrap()
      } else {
        await dispatch(createRecordingPlan(formData)).unwrap()
      }

      resetForm()
      onClose()
    } catch (error) {
      console.error('Error submitting form:', error)
    } finally {
      setIsSubmitting(false)
    }
  }

  const resetForm = () => {
    setFormData({
      name: '',
      price: '',
      billingCycle: 'monthly',
      storageDays: 30,
      appleProductId: '',
      googleProductId: '',
      description: '',
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
      aria-labelledby='recordingplan-dialog-title'
      fullWidth
      maxWidth='sm'
      PaperProps={{
        sx: { overflow: 'visible', width: '600px', maxWidth: '95vw' }
      }}
    >
      <DialogTitle id='recordingplan-dialog-title'>
        <Typography variant='h5' component='span'>
          {mode === 'edit' ? 'Edit Recording Storage Plan' : 'Create Recording Storage Plan'}
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
          error={!!errors.name}
          helperText={errors.name || ''}
          onChange={e => handleChange('name', e.target.value)}
          placeholder='Recording Storage Monthly'
        />

        <TextField
          label='Price'
          type='number'
          fullWidth
          value={formData.price}
          error={!!errors.price}
          helperText={errors.price || ''}
          onChange={e => handleChange('price', parseFloat(e.target.value) || '')}
          placeholder='4.99'
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
          label='Storage Days'
          type='number'
          fullWidth
          value={formData.storageDays}
          error={!!errors.storageDays}
          helperText={errors.storageDays || 'Number of days recording storage is valid'}
          onChange={e => handleChange('storageDays', parseInt(e.target.value, 10) || '')}
          placeholder='30'
          inputProps={{ min: 1 }}
        />

        <TextField
          label='Apple Product ID'
          fullWidth
          value={formData.appleProductId}
          onChange={e => handleChange('appleProductId', e.target.value)}
          placeholder='com.notisboard.recording.storage.monthly'
        />

        <TextField
          label='Google Play Product ID'
          fullWidth
          value={formData.googleProductId}
          helperText='Used for Google Play Billing on Android'
          onChange={e => handleChange('googleProductId', e.target.value)}
          placeholder='recording_storage_monthly'
        />

        <TextField
          label='Description'
          fullWidth
          multiline
          rows={2}
          value={formData.description}
          onChange={e => handleChange('description', e.target.value)}
          placeholder='Record and store your consultation sessions securely in the cloud.'
        />
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

export default RecordingPlanDialog
