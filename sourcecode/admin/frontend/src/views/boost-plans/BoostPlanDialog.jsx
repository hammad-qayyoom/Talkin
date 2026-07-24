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

import DialogCloseButton from '@components/dialogs/DialogCloseButton'

import { createBoostPlan, updateBoostPlan } from '@/redux-store/slices/boostPlans'

const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const BoostPlanDialog = ({ open, onClose, mode = 'create', plan = null }) => {
  const dispatch = useDispatch()
  const { loading } = useSelector(state => state.boostPlans)

  const [formData, setFormData] = useState({
    name: '',
    durationHours: '',
    creditCost: '',
    visibilityMultiplier: '1.5',
    description: '',
    sortOrder: '0'
  })

  const [errors, setErrors] = useState({})
  const [isSubmitting, setIsSubmitting] = useState(false)

  useEffect(() => {
    if (mode === 'edit' && plan) {
      setFormData({
        name: plan.name || '',
        durationHours: plan.durationHours || '',
        creditCost: plan.creditCost || '',
        visibilityMultiplier: plan.visibilityMultiplier || '1.5',
        description: plan.description || '',
        sortOrder: plan.sortOrder || '0'
      })
    } else {
      setFormData({
        name: '',
        durationHours: '',
        creditCost: '',
        visibilityMultiplier: '1.5',
        description: '',
        sortOrder: '0'
      })
    }
    setErrors({})
  }, [mode, plan, open])

  const handleFieldChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: '' }))
    }
  }

  const handleValidation = () => {
    const newErrors = {}

    if (!formData.name.trim()) newErrors.name = 'Name is required'
    if (!formData.durationHours || Number(formData.durationHours) < 1)
      newErrors.durationHours = 'Duration must be at least 1 hour'
    if (!formData.creditCost || Number(formData.creditCost) < 0)
      newErrors.creditCost = 'Credit cost must be non-negative'
    if (
      !formData.visibilityMultiplier ||
      Number(formData.visibilityMultiplier) < 1.0 ||
      Number(formData.visibilityMultiplier) > 5.0
    )
      newErrors.visibilityMultiplier = 'Multiplier must be between 1.0 and 5.0'

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async () => {
    if (!handleValidation()) return

    setIsSubmitting(true)

    try {
      const payload = {
        name: formData.name.trim(),
        durationHours: Number(formData.durationHours),
        creditCost: Number(formData.creditCost),
        visibilityMultiplier: Number(formData.visibilityMultiplier),
        description: formData.description.trim(),
        sortOrder: Number(formData.sortOrder)
      }

      if (mode === 'edit' && plan) {
        await dispatch(updateBoostPlan({ boostPlanId: plan._id, ...payload })).unwrap()
      } else {
        await dispatch(createBoostPlan(payload)).unwrap()
      }

      onClose()
    } catch (error) {
      console.error('Failed to save boost plan:', error)
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <Dialog
      fullWidth
      open={open}
      onClose={onClose}
      maxWidth='sm'
      TransitionComponent={Transition}
    >
      <DialogTitle>
        <Typography variant='h5'>{mode === 'edit' ? 'Edit Boost Plan' : 'Create Boost Plan'}</Typography>
        <DialogCloseButton onClick={onClose} />
      </DialogTitle>

      <DialogContent dividers>
        <TextField
          fullWidth
          label='Plan Name'
          value={formData.name}
          onChange={e => handleFieldChange('name', e.target.value)}
          error={!!errors.name}
          helperText={errors.name}
          sx={{ mb: 4 }}
          placeholder='e.g. 24-Hour Boost'
        />

        <TextField
          fullWidth
          label='Duration (Hours)'
          type='number'
          value={formData.durationHours}
          onChange={e => handleFieldChange('durationHours', e.target.value)}
          error={!!errors.durationHours}
          helperText={errors.durationHours || 'e.g. 24, 72, 168, 336, 720'}
          sx={{ mb: 4 }}
        />

        <TextField
          fullWidth
          label='Credit Cost'
          type='number'
          value={formData.creditCost}
          onChange={e => handleFieldChange('creditCost', e.target.value)}
          error={!!errors.creditCost}
          helperText={errors.creditCost || 'Credits deducted from expert wallet'}
          sx={{ mb: 4 }}
        />

        <TextField
          fullWidth
          label='Visibility Multiplier'
          type='number'
          inputProps={{ min: 1.0, max: 5.0, step: 0.1 }}
          value={formData.visibilityMultiplier}
          onChange={e => handleFieldChange('visibilityMultiplier', e.target.value)}
          error={!!errors.visibilityMultiplier}
          helperText={errors.visibilityMultiplier || 'Range: 1.0 to 5.0 (e.g. 1.5 = 50% more visibility)'}
          sx={{ mb: 4 }}
        />

        <TextField
          fullWidth
          label='Description (Optional)'
          value={formData.description}
          onChange={e => handleFieldChange('description', e.target.value)}
          multiline
          rows={2}
          sx={{ mb: 4 }}
        />

        <TextField
          fullWidth
          label='Sort Order'
          type='number'
          value={formData.sortOrder}
          onChange={e => handleFieldChange('sortOrder', e.target.value)}
        />
      </DialogContent>

      <DialogActions>
        <Button onClick={onClose} disabled={isSubmitting}>
          Cancel
        </Button>
        <Button variant='contained' onClick={handleSubmit} disabled={isSubmitting}>
          {isSubmitting ? <CircularProgress size={20} /> : mode === 'edit' ? 'Update' : 'Create'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default BoostPlanDialog
