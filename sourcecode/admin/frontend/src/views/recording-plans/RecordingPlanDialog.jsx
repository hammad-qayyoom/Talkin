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
import Switch from '@mui/material/Switch'
import FormControlLabel from '@mui/material/FormControlLabel'
import Divider from '@mui/material/Divider'

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
    maxRecordingMinutes: 0,
    unlimitedStorage: false,
    retentionDays: 30,
    unlimitedRetention: false,
    gracePeriodDays: 14,
    warningThreshold80: true,
    warningThreshold90: true,
    warningThreshold100: true,
    targetUserType: 'both',
    planVisibility: 'public',
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
        maxRecordingMinutes: plan.maxRecordingMinutes || 0,
        unlimitedStorage: plan.unlimitedStorage || false,
        retentionDays: plan.retentionDays || 30,
        unlimitedRetention: plan.unlimitedRetention || false,
        gracePeriodDays: plan.gracePeriodDays || 14,
        warningThreshold80: plan.warningThreshold80 !== false,
        warningThreshold90: plan.warningThreshold90 !== false,
        warningThreshold100: plan.warningThreshold100 !== false,
        targetUserType: plan.targetUserType || 'both',
        planVisibility: plan.planVisibility || 'public',
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
        maxRecordingMinutes: 0,
        unlimitedStorage: false,
        retentionDays: 30,
        unlimitedRetention: false,
        gracePeriodDays: 14,
        warningThreshold80: true,
        warningThreshold90: true,
        warningThreshold100: true,
        targetUserType: 'both',
        planVisibility: 'public',
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
      if ((field === 'price' || field === 'storageDays' || field === 'retentionDays') && value > 0) {
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
    if (!formData.unlimitedRetention && (!formData.retentionDays || formData.retentionDays <= 0)) {
      newErrors.retentionDays = 'Retention days must be a positive number when not unlimited'
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
        if (Number(formData.maxRecordingMinutes) !== (plan.maxRecordingMinutes || 0)) updatedPayload.maxRecordingMinutes = formData.maxRecordingMinutes
        if (formData.unlimitedStorage !== (plan.unlimitedStorage || false)) updatedPayload.unlimitedStorage = formData.unlimitedStorage
        if (Number(formData.retentionDays) !== (plan.retentionDays || 30)) updatedPayload.retentionDays = formData.retentionDays
        if (formData.unlimitedRetention !== (plan.unlimitedRetention || false)) updatedPayload.unlimitedRetention = formData.unlimitedRetention
        if (Number(formData.gracePeriodDays) !== (plan.gracePeriodDays || 14)) updatedPayload.gracePeriodDays = formData.gracePeriodDays
        if (formData.warningThreshold80 !== (plan.warningThreshold80 !== false)) updatedPayload.warningThreshold80 = formData.warningThreshold80
        if (formData.warningThreshold90 !== (plan.warningThreshold90 !== false)) updatedPayload.warningThreshold90 = formData.warningThreshold90
        if (formData.warningThreshold100 !== (plan.warningThreshold100 !== false)) updatedPayload.warningThreshold100 = formData.warningThreshold100
        if (formData.targetUserType !== (plan.targetUserType || 'both')) updatedPayload.targetUserType = formData.targetUserType
        if (formData.planVisibility !== (plan.planVisibility || 'public')) updatedPayload.planVisibility = formData.planVisibility
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
      maxRecordingMinutes: 0,
      unlimitedStorage: false,
      retentionDays: 30,
      unlimitedRetention: false,
      gracePeriodDays: 14,
      warningThreshold80: true,
      warningThreshold90: true,
      warningThreshold100: true,
      targetUserType: 'both',
      planVisibility: 'public',
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
      maxWidth='md'
      PaperProps={{
        sx: { overflow: 'visible', width: '750px', maxWidth: '95vw' }
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
        <Typography variant='h6' color='primary'>
          Basic Information
        </Typography>

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
          label='Description'
          fullWidth
          multiline
          rows={2}
          value={formData.description}
          onChange={e => handleChange('description', e.target.value)}
          placeholder='Record and store your consultation sessions securely in the cloud.'
        />

        <Divider sx={{ my: 2 }} />
        <Typography variant='h6' color='primary'>
          Subscription Duration
        </Typography>

        <TextField
          label='Storage Days (Subscription Duration)'
          type='number'
          fullWidth
          value={formData.storageDays}
          error={!!errors.storageDays}
          helperText={errors.storageDays || 'Number of days the subscription is active'}
          onChange={e => handleChange('storageDays', parseInt(e.target.value, 10) || '')}
          placeholder='30'
          inputProps={{ min: 1 }}
        />

        <Divider sx={{ my: 2 }} />
        <Typography variant='h6' color='primary'>
          Recording Storage Capacity
        </Typography>

        <FormControlLabel
          control={
            <Switch
              checked={formData.unlimitedStorage}
              onChange={e => handleChange('unlimitedStorage', e.target.checked)}
            />
          }
          label='Unlimited Storage'
        />

        {!formData.unlimitedStorage && (
          <TextField
            label='Max Recording Minutes'
            type='number'
            fullWidth
            value={formData.maxRecordingMinutes}
            helperText='Maximum total recording minutes allowed (0 = unlimited)'
            onChange={e => handleChange('maxRecordingMinutes', parseInt(e.target.value, 10) || 0)}
            placeholder='0'
            inputProps={{ min: 0 }}
          />
        )}

        <Divider sx={{ my: 2 }} />
        <Typography variant='h6' color='primary'>
          Recording Retention
        </Typography>

        <FormControlLabel
          control={
            <Switch
              checked={formData.unlimitedRetention}
              onChange={e => handleChange('unlimitedRetention', e.target.checked)}
            />
          }
          label='Unlimited Retention'
        />

        {!formData.unlimitedRetention && (
          <TextField
            label='Retention Days'
            type='number'
            fullWidth
            value={formData.retentionDays}
            error={!!errors.retentionDays}
            helperText={errors.retentionDays || 'Number of days recordings are kept after creation'}
            onChange={e => handleChange('retentionDays', parseInt(e.target.value, 10) || '')}
            placeholder='30'
            inputProps={{ min: 1 }}
          />
        )}

        <Divider sx={{ my: 2 }} />
        <Typography variant='h6' color='primary'>
          Grace Period & Notifications
        </Typography>

        <TextField
          label='Grace Period Days'
          type='number'
          fullWidth
          value={formData.gracePeriodDays}
          helperText='Days after subscription expires before recordings are locked (0 = no grace period)'
          onChange={e => handleChange('gracePeriodDays', parseInt(e.target.value, 10) || 0)}
          placeholder='14'
          inputProps={{ min: 0 }}
        />

        <Typography variant='subtitle2' color='text.secondary'>
          Capacity Warning Thresholds
        </Typography>
        <div className='flex gap-4'>
          <FormControlLabel
            control={
              <Switch
                checked={formData.warningThreshold80}
                onChange={e => handleChange('warningThreshold80', e.target.checked)}
              />
            }
            label='80% Warning'
          />
          <FormControlLabel
            control={
              <Switch
                checked={formData.warningThreshold90}
                onChange={e => handleChange('warningThreshold90', e.target.checked)}
              />
            }
            label='90% Warning'
          />
          <FormControlLabel
            control={
              <Switch
                checked={formData.warningThreshold100}
                onChange={e => handleChange('warningThreshold100', e.target.checked)}
              />
            }
            label='100% Warning'
          />
        </div>

        <Divider sx={{ my: 2 }} />
        <Typography variant='h6' color='primary'>
          Targeting & Visibility
        </Typography>

        <TextField
          select
          label='Target User Type'
          fullWidth
          value={formData.targetUserType}
          onChange={e => handleChange('targetUserType', e.target.value)}
        >
          <MenuItem value='both'>Both (Users & Listeners)</MenuItem>
          <MenuItem value='user'>Users Only</MenuItem>
          <MenuItem value='listener'>Listeners Only</MenuItem>
        </TextField>

        <TextField
          select
          label='Plan Visibility'
          fullWidth
          value={formData.planVisibility}
          onChange={e => handleChange('planVisibility', e.target.value)}
        >
          <MenuItem value='public'>Public</MenuItem>
          <MenuItem value='admin_only'>Admin Only</MenuItem>
        </TextField>

        <Divider sx={{ my: 2 }} />
        <Typography variant='h6' color='primary'>
          Platform Product IDs
        </Typography>

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

        <Divider sx={{ my: 2 }} />
        <Typography variant='h6' color='primary'>
          Status
        </Typography>

        <div className='flex gap-4'>
          <FormControlLabel
            control={
              <Switch
                checked={formData.isPopular}
                onChange={e => handleChange('isPopular', e.target.checked)}
              />
            }
            label='Popular Plan'
          />
          <FormControlLabel
            control={
              <Switch
                checked={formData.isActive}
                onChange={e => handleChange('isActive', e.target.checked)}
              />
            }
            label='Active'
          />
        </div>
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
