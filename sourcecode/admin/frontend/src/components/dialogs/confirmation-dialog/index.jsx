'use client'

import { useEffect, useState } from 'react'

import Dialog from '@mui/material/Dialog'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'
import Typography from '@mui/material/Typography'
import Button from '@mui/material/Button'
import CircularProgress from '@mui/material/CircularProgress'
import Box from '@mui/material/Box'

// Icons
import ErrorOutlineIcon from '@mui/icons-material/ErrorOutline'
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutline'
import CancelOutlinedIcon from '@mui/icons-material/CancelOutlined'

const ConfirmationDialog = ({
  open,
  onClose,
  type,
  title,
  content,
  onConfirm,
  loading,
  error,
  confirmButtonText = 'Yes, Confirm',
  cancelButtonText = 'Cancel'
}) => {
  const [dialogState, setDialogState] = useState('confirmation') // 'confirmation', 'success', 'error', 'cancelled'
  const [isProcessing, setIsProcessing] = useState(false)

  // Reset state when dialog opens/closes
  useEffect(() => {
    if (!open) {
      // Reset state when dialog closes
      setTimeout(() => {
        setDialogState('confirmation')
        setIsProcessing(false)
      }, 300) // Short delay to prevent flashing between state changes
    }
  }, [open])

  // Handle API result changes
  useEffect(() => {
    if (isProcessing && !loading) {
      if (error) {
        setDialogState('error')
      } else {
        setDialogState('success')
      }

      setIsProcessing(false)
    }
  }, [loading, error, isProcessing])

  // Handle primary confirmation
  const handleConfirmation = () => {
    setIsProcessing(true)
    if (onConfirm) onConfirm()
  }

  // Handle cancellation
  const handleCancel = () => {
    setDialogState('cancelled')
  }

  // Close all dialogs and reset state
  const handleFinalClose = () => {
    if (onClose) onClose()
  }

  // Get success message based on action type
  const getSuccessMessage = () => {
    if (title) return `${title.replace(/\?/g, '')} successful.`

    const messages = {
      'delete-account': 'Your account has been deactivated successfully.',
      unsubscribe: 'Your subscription cancelled successfully.',
      'suspend-account': 'User has been suspended.',
      'delete-order': 'Your order deleted successfully.',
      'delete-customer': 'Your customer removed successfully.',
      'delete-expert': 'Expert deleted succefully.',
      'delete-category': 'Your category deleted successfully.',
      'delete-ride': 'Your ride deleted successfully.',
      'delete-theme': 'Your theme deleted successfully.',
      'delete-frame': 'Your frame deleted successfully.',
      'delete-wealth-level': 'Your wealth level deleted successfully.',
      'delete-gift': 'Your gift deleted successfully.',
      'delete-hashtag': 'Your hashtag deleted successfully.',
      'delete-talk-topic': 'Your category deleted successfully.',
      'delete-identity-proof': 'Identity proof deleted successfully.',
      'delete-reason': 'Report reason deleted successfully.',
      'delete-post': 'Post deleted successfully.',
      'delete-reaction': 'Reaction deleted successfully.',
      'approve-payout': 'Payout request approved successfully.',
      'reject-payout': 'Payout request rejected successfully.',
      'approve-request': 'Request approved successfully.',
      default: 'Success!'
    }

    return messages[type] || messages.default
  }

  // Get cancel message based on action type
  const getCancelMessage = () => {
    if (title) return `${title.replace(/\?/g, '')} cancelled.`

    const messages = {
      'delete-account': 'Account Deactivation Cancelled!',
      unsubscribe: 'Unsubscription Cancelled!',
      'suspend-account': 'Cancelled Suspension :)',
      'delete-order': 'Order Deletion Cancelled',
      'delete-customer': 'Customer Deletion Cancelled',
      'delete-expert': 'Expert Deletion Cancelled',
      'delete-category': 'Category Deletion Cancelled',
      'delete-ride': 'Ride Deletion Cancelled',
      'delete-theme': 'Theme Deletion Cancelled',
      'delete-frame': 'Frame Deletion Cancelled',
      'delete-wealth-level': 'Wealth Level Deletion Cancelled',
      'delete-gift': 'Gift Deletion Cancelled',
      'delete-hashtag': 'Hashtag Deletion Cancelled',
      'delete-talk-topic': 'Category Deletion Cancelled',
      'delete-identity-proof': 'Identity Proof Deletion Cancelled',
      'delete-reason': 'Report Reason Deletion Cancelled',
      'delete-post': 'Post Deletion Cancelled',
      'delete-reaction': 'Reaction Deletion Cancelled',
      'approve-payout': 'Payout approval cancelled',
      'reject-payout': 'Payout rejection cancelled',
      'approve-request': 'Request approval cancelled',
      default: 'Action Cancelled'
    }

    return messages[type] || messages.default
  }

  // Get confirmation title based on action type
  const getConfirmationTitle = () => {
    if (title) return title

    const titles = {
      'delete-account': 'Are you sure you want to deactivate your account?',
      unsubscribe: 'Are you sure to cancel your subscription?',
      'suspend-account': 'Are you sure?',
      'delete-order': 'Are you sure?',
      'delete-customer': 'Are you sure?',
      'delete-expert': 'Are you sure you want to delete this expert?',
      'delete-category': 'Are you sure you want to delete this category?',
      'delete-ride': 'Are you sure you want to delete this ride?',
      'delete-theme': 'Are you sure you want to delete this theme?',
      'delete-frame': 'Are you sure you want to delete this frame?',
      'delete-wealth-level': 'Are you sure you want to delete this wealth level?',
      'delete-gift': 'Are you sure you want to delete this gift?',
      'delete-hashtag': 'Are you sure you want to delete this hashtag?',
      'delete-talk-topic': 'Are you sure you want to delete this category?',
      'delete-identity-proof': 'Are you sure you want to delete this identity proof?',
      'delete-reason': 'Are you sure you want to delete this report reason?',
      'delete-post': 'Are you sure you want to delete this post?',
      'delete-reaction': 'Are you sure you want to delete this reaction?',
      'approve-request': 'Are you sure you want to approve this request?',
      default: 'Are you sure?'
    }

    return titles[type] || titles.default
  }

  // Get confirmation content
  const getConfirmationContent = () => {
    if (content) return content

    return `You won't be able to revert this ${type?.replace('delete-', '').replace('-', ' ') || 'action'}!`
  }

  // Determine if the result dialog should be shown
  const isConfirmationDialog = dialogState === 'confirmation'
  const isResultDialog = ['success', 'error', 'cancelled'].includes(dialogState)

  const resultMeta =
    dialogState === 'success'
      ? {
          title: 'Success',
          color: 'var(--mui-palette-success-main)',
          icon: <CheckCircleOutlineIcon sx={{ fontSize: 34 }} />,
          message: getSuccessMessage(),
          buttonColor: 'success'
        }
      : dialogState === 'error'
        ? {
            title: 'Action Failed',
            color: 'var(--mui-palette-error-main)',
            icon: <CancelOutlinedIcon sx={{ fontSize: 34 }} />,
            message: error,
            buttonColor: 'error'
          }
        : {
            title: 'Cancelled',
            color: 'var(--mui-palette-warning-main)',
            icon: <CancelOutlinedIcon sx={{ fontSize: 34 }} />,
            message: getCancelMessage(),
            buttonColor: 'secondary'
          }

  return (
    <>
      {/* Confirmation Dialog */}
      <Dialog
        fullWidth
        maxWidth='xs'
        open={open && isConfirmationDialog}
        onClose={() => !loading && handleCancel()}
        closeAfterTransition={false}
        PaperProps={{
          sx: {
            borderRadius: 3,
            border: '1px solid var(--mui-palette-divider)',
            boxShadow: 'var(--mui-customShadows-lg)'
          }
        }}
      >
        <DialogContent sx={{ px: 4, pt: 4.5, pb: 2, textAlign: 'center' }}>
          <Box
            sx={{
              mx: 'auto',
              mb: 2,
              width: 68,
              height: 68,
              borderRadius: 2.5,
              display: 'grid',
              placeItems: 'center',
              color: 'var(--mui-palette-primary-main)',
              backgroundColor: 'var(--mui-palette-primary-lightOpacity)'
            }}
          >
            <ErrorOutlineIcon sx={{ fontSize: 34 }} />
          </Box>
          <Typography variant='h5' sx={{ mb: 1, fontWeight: 800, color: 'var(--mui-palette-secondary-dark)' }}>
            {getConfirmationTitle()}
          </Typography>
          <Typography color='text.secondary' sx={{ lineHeight: 1.55 }}>
            {getConfirmationContent()}
          </Typography>
        </DialogContent>
        <DialogActions sx={{ px: 4, pb: 4, pt: 2, justifyContent: 'center', gap: 1.5 }}>
          <Button variant='outlined' color='secondary' onClick={handleCancel} disabled={loading} sx={{ minWidth: 120 }}>
            {cancelButtonText}
          </Button>
          <Button
            variant='contained'
            color='primary'
            onClick={handleConfirmation}
            disabled={loading}
            sx={{ minWidth: 140 }}
          >
            {loading ? <CircularProgress size={20} sx={{ color: 'white' }} /> : confirmButtonText}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Result Dialog */}
      <Dialog
        open={open && isResultDialog}
        onClose={handleFinalClose}
        closeAfterTransition={false}
        PaperProps={{
          sx: {
            borderRadius: 3,
            border: '1px solid var(--mui-palette-divider)',
            boxShadow: 'var(--mui-customShadows-lg)'
          }
        }}
      >
        <DialogContent sx={{ px: 4, pt: 4.5, pb: 2, textAlign: 'center' }}>
          <Box
            sx={{
              mx: 'auto',
              mb: 2,
              width: 68,
              height: 68,
              borderRadius: 2.5,
              display: 'grid',
              placeItems: 'center',
              color: resultMeta.color,
              backgroundColor: `${resultMeta.color}1F`
            }}
          >
            {resultMeta.icon}
          </Box>
          <Typography variant='h5' sx={{ mb: 1, fontWeight: 800, color: 'var(--mui-palette-secondary-dark)' }}>
            {resultMeta.title}
          </Typography>
          <Typography color='text.secondary' sx={{ lineHeight: 1.55 }}>
            {resultMeta.message}
          </Typography>
        </DialogContent>
        <DialogActions sx={{ px: 4, pb: 4, pt: 2, justifyContent: 'center' }}>
          <Button variant='contained' color={resultMeta.buttonColor} onClick={handleFinalClose} sx={{ minWidth: 120 }}>
            Ok
          </Button>
        </DialogActions>
      </Dialog>
    </>
  )
}

export default ConfirmationDialog
