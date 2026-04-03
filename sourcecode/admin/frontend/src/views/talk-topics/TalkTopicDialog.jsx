'use client'

import React, { forwardRef, useEffect, useState } from 'react'

import { useDispatch } from 'react-redux'

import Slide from '@mui/material/Slide'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'
import Button from '@mui/material/Button'
import Typography from '@mui/material/Typography'
import TextField from '@mui/material/TextField'
import CircularProgress from '@mui/material/CircularProgress'
import Avatar from '@mui/material/Avatar'
import Box from '@mui/material/Box'

import { toast } from 'react-toastify'

import DialogCloseButton from '@components/dialogs/DialogCloseButton'

import { createTalkTopic, updateTalkTopic } from '@/redux-store/slices/talkTopics'
import { getFullImageUrl } from '@/utils/commonfunctions'


const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const TalkTopicDialog = ({ open, onClose, mode = 'create', talkTopic = null }) => {
  const dispatch = useDispatch()

  const [formData, setFormData] = useState({
    name: '',
    icon: ''
  })

  const [imageFile, setImageFile] = useState(null)
  const [previewImage, setPreviewImage] = useState('')

  const [errors, setErrors] = useState({})
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (mode === 'edit' && talkTopic) {
      setFormData({
        name: talkTopic.name || '',
        icon: talkTopic.icon || ''
      })
      setPreviewImage(talkTopic.image ? getFullImageUrl(talkTopic.image) : '')
      setImageFile(null)
    } else {
      setFormData({
        name: '',
        icon: ''
      })
      setPreviewImage('')
      setImageFile(null)
    }
  }, [mode, talkTopic, open])

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))

    // Clear field-specific error if valid
    setErrors(prev => {
      const updatedErrors = { ...prev }

      if (field === 'name' && value.trim() !== '') {
        delete updatedErrors.name
      }

      return updatedErrors
    })
  }

  const handleValidation = () => {
    const newErrors = {}

    if (!formData.name || formData.name.trim() === '') {
      newErrors.name = 'Category name is required'
    }

    setErrors(newErrors)

    return Object.keys(newErrors).length === 0
  }

  const handleImageChange = event => {
    const file = event.target.files?.[0]

    if (!file) return

    setImageFile(file)
    setPreviewImage(URL.createObjectURL(file))
  }

  const handleSubmit = async () => {
    if (!handleValidation()) return

    try {
      setLoading(true)

      const trimmedName = formData.name.trim()
      const trimmedIcon = formData.icon.trim()

      if (mode === 'edit') {
        const updatedPayload = {}

        if (trimmedName !== (talkTopic.name || '').trim()) {
          updatedPayload.name = trimmedName
        }

        if (trimmedIcon !== (talkTopic.icon || '').trim()) {
          updatedPayload.icon = trimmedIcon
        }

        if (imageFile) {
          updatedPayload.image = imageFile
        }

        if (Object.keys(updatedPayload).length === 0) {
          toast.info('No changes detected')
        } else {
          await dispatch(
            updateTalkTopic({ talkTopicId: talkTopic._id, ...updatedPayload })
          ).unwrap()
        }
      } else {
        await dispatch(
          createTalkTopic({
            name: trimmedName,
            icon: trimmedIcon,
            image: imageFile
          })
        ).unwrap()
      }

      setFormData({ name: '', icon: '' })
      setImageFile(null)
      setPreviewImage('')
      onClose()
    } catch (error) {
      console.error('Error submitting form:', error)
      setErrors({ submit: 'An error occurred while submitting the form' })
    } finally {
      setLoading(false)
    }
  }

  const resetForm = () => {
    setFormData({ name: '', icon: '' })
    setImageFile(null)
    setPreviewImage('')
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
      aria-labelledby='talktopic-dialog-title'
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
      <DialogTitle id='talktopic-dialog-title'>
        <Typography variant='h5' component='span'>
          {mode === 'edit' ? 'Edit Category' : 'Create Category'}
        </Typography>
        <DialogCloseButton onClick={handleClose}>
          <i className='tabler-x' />
        </DialogCloseButton>
      </DialogTitle>

      <DialogContent className='flex flex-col gap-4 py-4'>
        <TextField
          label='Category Name'
          fullWidth
          value={formData.name}
          error={!!errors.name}
          helperText={errors.name || ''}
          onChange={e => handleChange('name', e.target.value)}
          placeholder='Family Guidance'
        />

        <TextField
          label='Icon Class (optional)'
          fullWidth
          value={formData.icon}
          onChange={e => handleChange('icon', e.target.value)}
          placeholder='tabler-heart-handshake'
          helperText='Optional tabler icon class used in web/admin previews.'
        />

        <Box className='flex items-center gap-4'>
          <Avatar
            variant='rounded'
            src={previewImage || undefined}
            sx={{ width: 72, height: 72, bgcolor: 'action.hover' }}
          >
            {!previewImage && (
              <i
                className={formData.icon?.trim() || 'tabler-photo'}
                style={{ fontSize: 24 }}
              />
            )}
          </Avatar>

          <Box className='flex flex-col gap-1'>
            <Button component='label' variant='tonal'>
              Upload Category Image
              <input hidden accept='image/*' type='file' onChange={handleImageChange} />
            </Button>
            <Typography variant='caption' color='text.secondary'>
              PNG/JPG/WebP recommended. Square image gives best result.
            </Typography>
          </Box>
        </Box>

        {errors.submit && (
          <Typography color='error' variant='body2'>
            {errors.submit}
          </Typography>
        )}
      </DialogContent>

      <DialogActions>
        <Button onClick={handleClose} variant='tonal' color='secondary' disabled={loading}>
          Cancel
        </Button>
        <Button variant='contained' onClick={handleSubmit} disabled={loading}>
          {loading ? <CircularProgress size={20} sx={{ color: 'white' }} /> : 'Submit'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default TalkTopicDialog
