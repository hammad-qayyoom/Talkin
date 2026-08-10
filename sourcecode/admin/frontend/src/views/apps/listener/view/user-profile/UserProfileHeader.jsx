// MUI Imports
import { useState } from 'react'

import { Box } from '@mui/material'
import Card from '@mui/material/Card'
import Button from '@mui/material/Button'
import CardContent from '@mui/material/CardContent'
import CardMedia from '@mui/material/CardMedia'
import Typography from '@mui/material/Typography'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'
import Alert from '@mui/material/Alert'
import PersonIcon from '@mui/icons-material/Person'
import ShieldIcon from '@mui/icons-material/Shield'

import CustomAvatar from '@/@core/components/mui/Avatar'
import { getFullImageUrl } from '@/utils/commonfunctions'

const UserProfileHeader = ({ data }) => {
  const [userDetails, setUserDetails] = useState(localStorage.getItem('selectedListener') ? JSON.parse(localStorage.getItem('selectedListener')) : null)
  const [confirmOpen, setConfirmOpen] = useState(false)

  const handleLoginAsUser = () => {
    setConfirmOpen(true)
  }

  const handleConfirm = () => {
    setConfirmOpen(false)
    const listenerId = userDetails?._id
    const userFirebaseId = userDetails?.userDetails?.firebaseId
    window.open(`/simulate?uid=${listenerId}&fid=${userFirebaseId || listenerId}`, '_blank')
  }

  return (
    <>
    <Card>
      <CardMedia image={"/images/profile-banner.png"} className='bs-[250px]' />
      <CardContent className='flex gap-5 justify-center flex-col items-center md:items-end md:flex-row !pt-0 md:justify-start'>
        <div className='flex rounded-bs-md mbs-[-40px] border-[5px] mis-[-5px] border-be-0  border-backgroundPaper bg-backgroundPaper'>
          <CustomAvatar
            alt='user-profile'
            src={getFullImageUrl(userDetails?.image) || '/images/avatars/1.png'}
            variant='rounded'
            size={120}
          />
        </div>
        <div className='flex is-full justify-start self-end flex-col items-center gap-6 sm-gap-0 sm:flex-row sm:justify-between sm:items-end '>
          <div className='flex flex-col items-center sm:items-start gap-1'>
            <Box className="flex items-center justify-center gap-3">
              <Typography variant='h4'>{userDetails?.name}</Typography>
              (<Typography variant='span'>{userDetails?.nickName}</Typography>)
            </Box>
            <div className='flex flex-wrap gap-6 justify-center sm:justify-normal'>
              <div className='flex items-center gap-2'>
                <i className='tabler-calendar' />
                <Typography className='font-medium'>{userDetails?.date}</Typography>
              </div>
            </div>
          </div>
          <Button
            variant='contained'
            color='primary'
            className='flex gap-2'
            onClick={handleLoginAsUser}
          >
            <i className='tabler-external-link !text-base'></i>
            <span>Login As User</span>
          </Button>
        </div>
      </CardContent>
    </Card>

    <Dialog open={confirmOpen} onClose={() => setConfirmOpen(false)} maxWidth='sm' fullWidth>
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
        <ShieldIcon color='warning' />
        <span>Confirm User Impersonation</span>
      </DialogTitle>
      <DialogContent>
        <Alert severity='warning' sx={{ mb: 2 }}>
          You are about to log in as another user. This action will be logged for audit purposes.
        </Alert>
        <Typography variant='body2' sx={{ mb: 1 }}>
          You are impersonating: <strong>{userDetails?.name || 'Unknown User'}</strong> (Expert)
        </Typography>
        <Typography variant='body2' color='text.secondary'>
          This will open the application as this expert in a new tab. You will see their profile, bookings, consultations, subscriptions, wallet, notifications, and all other data.
        </Typography>
        <Typography variant='body2' color='text.secondary' sx={{ mt: 1 }}>
          A floating banner will allow you to exit impersonation and return to the admin panel at any time.
        </Typography>
      </DialogContent>
      <DialogActions>
        <Button onClick={() => setConfirmOpen(false)} color='secondary'>
          Cancel
        </Button>
        <Button onClick={handleConfirm} variant='contained' color='primary' startIcon={<PersonIcon />}>
          Login as User
        </Button>
      </DialogActions>
    </Dialog>
    </>
  )
}

export default UserProfileHeader
