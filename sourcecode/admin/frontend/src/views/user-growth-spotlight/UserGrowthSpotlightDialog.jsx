'use client'

import { forwardRef, useEffect, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'

import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import CircularProgress from '@mui/material/CircularProgress'
import Dialog from '@mui/material/Dialog'
import DialogActions from '@mui/material/DialogActions'
import DialogContent from '@mui/material/DialogContent'
import DialogTitle from '@mui/material/DialogTitle'
import Slide from '@mui/material/Slide'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'

import { toast } from 'react-toastify'

import CustomAvatar from '@/@core/components/mui/Avatar'
import CustomIconButton from '@/@core/components/mui/IconButton'
import DialogCloseButton from '@/components/dialogs/DialogCloseButton'
import { baseURL } from '@/config'
import { createUserGrowthSpotlight, updateUserGrowthSpotlight } from '@/redux-store/slices/userGrowthSpotlight'

const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const UserGrowthSpotlightDialog = ({ open, onClose, mode = 'create', spotlight = null }) => {
  const dispatch = useDispatch()
  const { loading } = useSelector(state => state.userGrowthSpotlight)

  const [formData, setFormData] = useState({
    title: '',
    description: '',
    sortOrder: 0,
    image: null
  })

  const [imagePreview, setImagePreview] = useState('')
  const [errors, setErrors] = useState({})
  const [isSubmitting, setIsSubmitting] = useState(false)

  useEffect(() => {
    if (mode === 'edit' && spotlight) {
      setFormData({
        title: spotlight.title || '',
        description: spotlight.description || '',
        sortOrder: spotlight.sortOrder ?? 0,
        image: null
      })
      setImagePreview(spotlight.image ? `${baseURL}/${spotlight.image}` : '')
      setErrors({})

      return
    }

    setFormData({
      title: '',
      description: '',
      sortOrder: 0,
      image: null
    })
    setImagePreview('')
    setErrors({})
  }, [mode, spotlight, open])

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))
    setErrors(prev => {
      const updated = { ...prev }

      delete updated[field]

      return updated
    })
  }

  const handleImageChange = e => {
    const file = e.target.files?.[0]

    if (!file) {
      return
    }

    setFormData(prev => ({ ...prev, image: file }))
    setImagePreview(URL.createObjectURL(file))
    setErrors(prev => {
      const updated = { ...prev }

      delete updated.image

      return updated
    })
  }

  const validate = () => {
    const nextErrors = {}

    if (mode === 'create' && !formData.image) {
      nextErrors.image = 'Image is required'
    }

    if (Number.isNaN(Number(formData.sortOrder))) {
      nextErrors.sortOrder = 'Sort order must be a valid number'
    }

    setErrors(nextErrors)

    return Object.keys(nextErrors).length === 0
  }

  const handleSubmit = async () => {
    if (!validate()) return

    setIsSubmitting(true)

    try {
      if (mode === 'edit' && spotlight?._id) {
        const updatedFields = new FormData()
        let hasChanges = false

        if (formData.title !== (spotlight.title || '')) {
          updatedFields.append('title', formData.title)
          hasChanges = true
        }

        if (formData.description !== (spotlight.description || '')) {
          updatedFields.append('description', formData.description)
          hasChanges = true
        }

        if (Number(formData.sortOrder) !== Number(spotlight.sortOrder ?? 0)) {
          updatedFields.append('sortOrder', String(formData.sortOrder))
          hasChanges = true
        }

        if (formData.image) {
          updatedFields.append('image', formData.image)
          hasChanges = true
        }

        if (!hasChanges) {
          toast.info('No changes detected')
        } else {
          updatedFields.append('spotlightId', spotlight._id)
          await dispatch(updateUserGrowthSpotlight(updatedFields)).unwrap()
        }
      } else {
        const payload = new FormData()

        payload.append('title', formData.title)
        payload.append('description', formData.description)
        payload.append('sortOrder', String(formData.sortOrder))

        if (formData.image) {
          payload.append('image', formData.image)
        }

        await dispatch(createUserGrowthSpotlight(payload)).unwrap()
      }

      onClose()
    } catch (error) {
      setErrors(prev => ({
        ...prev,
        submit: error || 'Failed to save user growth spotlight.'
      }))
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleClose = () => {
    onClose()
  }

  return (
    <Dialog
      open={open}
      onClose={handleClose}
      keepMounted
      TransitionComponent={Transition}
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
      <DialogTitle>
        <Typography variant='h5' component='span'>
          {mode === 'edit' ? 'Edit User Growth Spotlight' : 'Create User Growth Spotlight'}
        </Typography>
        <DialogCloseButton onClick={handleClose}>
          <i className='tabler-x' />
        </DialogCloseButton>
      </DialogTitle>

      <DialogContent className='flex flex-col gap-4 py-4'>
        <TextField
          label='Title'
          fullWidth
          value={formData.title}
          onChange={e => handleChange('title', e.target.value)}
          placeholder='Optional title for the user spotlight card'
        />

        <TextField
          label='Description'
          fullWidth
          multiline
          rows={3}
          value={formData.description}
          onChange={e => handleChange('description', e.target.value)}
          placeholder='Optional description shown on user app'
        />

        <TextField
          label='Sort Order'
          type='number'
          fullWidth
          value={formData.sortOrder}
          onChange={e => handleChange('sortOrder', e.target.value)}
          error={!!errors.sortOrder}
          helperText={errors.sortOrder || 'Lower values appear first'}
        />

        <Box>
          <Typography variant='subtitle1' component='label' className='mb-2 block'>
            Spotlight Image
          </Typography>

          {!imagePreview && (
            <>
              <input
                accept='image/png, image/jpeg, image/jpg, image/webp'
                type='file'
                id='user-growth-spotlight-image'
                onChange={handleImageChange}
                style={{ display: 'none' }}
              />
              <Box className='flex flex-col gap-2'>
                <label htmlFor='user-growth-spotlight-image' className='w-full'>
                  <Button variant='outlined' color='primary' className='w-full' component='span'>
                    Choose Image
                  </Button>
                </label>
                <Typography variant='caption' color='text.secondary'>
                  Recommended ratio: 16:9. Accepted: png, jpg, jpeg, webp.
                </Typography>
                {errors.image && (
                  <Typography variant='caption' className='text-error'>
                    {errors.image}
                  </Typography>
                )}
              </Box>
            </>
          )}

          {imagePreview && (
            <Box className='mt-2 border p-2 rounded flex justify-between items-center'>
              <Box className='flex items-center gap-4'>
                <CustomAvatar size={84} variant='rounded' src={imagePreview} />
                {formData?.image?.name && <Typography>{formData.image.name}</Typography>}
              </Box>
              <CustomIconButton
                color='error'
                onClick={() => {
                  setFormData(prev => ({ ...prev, image: null }))
                  setImagePreview('')
                }}
              >
                <i className='tabler-trash' />
              </CustomIconButton>
            </Box>
          )}
        </Box>

        {errors.submit && (
          <Typography variant='caption' className='text-error'>
            {errors.submit}
          </Typography>
        )}
      </DialogContent>

      <DialogActions>
        <Button onClick={handleClose} disabled={loading || isSubmitting}>
          Cancel
        </Button>
        <Button variant='contained' onClick={handleSubmit} disabled={loading || isSubmitting}>
          {loading || isSubmitting ? <CircularProgress size={22} /> : mode === 'edit' ? 'Update' : 'Create'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default UserGrowthSpotlightDialog
