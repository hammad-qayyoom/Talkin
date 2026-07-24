'use client'

import { useEffect, useState } from 'react'

import CircularProgress from '@mui/material/CircularProgress'
import Box from '@mui/material/Box'

import BoostPlans from './index'

export default function ClientWrapper() {
  const [isClient, setIsClient] = useState(false)

  useEffect(() => {
    setIsClient(true)
  }, [])

  if (!isClient) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
        <CircularProgress />
      </Box>
    )
  }

  return <BoostPlans />
}
