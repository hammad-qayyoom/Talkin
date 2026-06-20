import Link from 'next/link'

import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import Typography from '@mui/material/Typography'

export const metadata = {
  title: 'Access Denied'
}

export default function AccessDeniedPage() {
  return (
    <Box className='flex min-h-[60vh] items-center justify-center p-6'>
      <Card className='max-w-lg w-full p-8'>
        <Typography variant='h4' className='mb-2'>
          Access denied
        </Typography>
        <Typography variant='body2' color='text.secondary' className='mb-6'>
          Your account does not have permission for this section.
        </Typography>
        <Button component={Link} href='/dashboard' variant='contained'>
          Go to dashboard
        </Button>
      </Card>
    </Box>
  )
}
