'use client'

import { useCallback, useEffect, useState } from 'react'

import axios from 'axios'

import Box from '@mui/material/Box'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Typography from '@mui/material/Typography'
import CircularProgress from '@mui/material/CircularProgress'
import Grid from '@mui/material/Grid'
import Button from '@mui/material/Button'
import Table from '@mui/material/Table'
import TableBody from '@mui/material/TableBody'
import TableCell from '@mui/material/TableCell'
import TableContainer from '@mui/material/TableContainer'
import TableHead from '@mui/material/TableHead'
import TableRow from '@mui/material/TableRow'
import Chip from '@mui/material/Chip'
import MenuItem from '@mui/material/MenuItem'

import CustomTextField from '@/@core/components/mui/TextField'
import { baseURL, secretKey } from '@/config'

const getAuthHeaders = () => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('admin_token')
    const uid = localStorage.getItem('uid')

    return {
      'Content-Type': 'application/json',
      key: secretKey,
      Authorization: `Bearer ${token}`,
      'x-admin-uid': uid
    }
  }

  return {}
}

const formatCurrency = value => {
  if (value == null) return '₹0'
  return `₹${Number(value).toLocaleString('en-IN')}`
}

const formatDate = value => {
  if (!value) return '-'
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return '-'
  return d.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: '2-digit' })
}

const TipAnalyticsView = () => {
  const [loading, setLoading] = useState(false)
  const [stats, setStats] = useState(null)
  const [timeframe, setTimeframe] = useState('all')
  const [recentTips, setRecentTips] = useState([])

  const fetchStats = useCallback(async () => {
    try {
      setLoading(true)
      const params = timeframe !== 'all' ? { timeframe } : {}
      const response = await axios.get(`${baseURL}/api/v2/tipping/admin/stats`, {
        headers: getAuthHeaders(),
        params
      })
      setStats(response?.data?.data || null)
      setRecentTips(response?.data?.data?.recentTips || [])
    } catch (error) {
      console.error('Failed to fetch tip analytics:', error)
      setStats(null)
      setRecentTips([])
    } finally {
      setLoading(false)
    }
  }, [timeframe])

  useEffect(() => {
    fetchStats()
  }, [fetchStats])

  if (loading && !stats) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 4, alignItems: 'center', height: '55vh' }}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <>
      <Box className='mb-3'>
        <Typography variant='h4'>Tip Analytics</Typography>
        <Typography variant='body2' color='text.secondary'>
          Monitor expert tipping activity, revenue, and platform commission.
        </Typography>
      </Box>

      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
            <CustomTextField
              select
              value={timeframe}
              onChange={e => setTimeframe(e.target.value)}
              className='w-[180px]'
              size='small'
            >
              <MenuItem value='all'>All Time</MenuItem>
              <MenuItem value='today'>Today</MenuItem>
              <MenuItem value='week'>This Week</MenuItem>
              <MenuItem value='month'>This Month</MenuItem>
            </CustomTextField>
            <Button variant='outlined' onClick={fetchStats}>
              Refresh
            </Button>
          </Box>

          <Grid container spacing={3}>
            <Grid item xs={12} sm={6} md={3}>
              <Box sx={{ p: 3, border: theme => `1px solid ${theme.palette.divider}`, borderRadius: 2, textAlign: 'center' }}>
                <Typography variant='h4' color='primary'>
                  {formatCurrency(stats?.totalTipsAmount || 0)}
                </Typography>
                <Typography variant='body2' color='text.secondary' sx={{ mt: 1 }}>
                  Total Tips Sent
                </Typography>
              </Box>
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <Box sx={{ p: 3, border: theme => `1px solid ${theme.palette.divider}`, borderRadius: 2, textAlign: 'center' }}>
                <Typography variant='h4' color='success.main'>
                  {formatCurrency(stats?.totalExpertEarnings || 0)}
                </Typography>
                <Typography variant='body2' color='text.secondary' sx={{ mt: 1 }}>
                  Expert Earnings
                </Typography>
              </Box>
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <Box sx={{ p: 3, border: theme => `1px solid ${theme.palette.divider}`, borderRadius: 2, textAlign: 'center' }}>
                <Typography variant='h4' color='warning.main'>
                  {formatCurrency(stats?.totalPlatformCommission || 0)}
                </Typography>
                <Typography variant='body2' color='text.secondary' sx={{ mt: 1 }}>
                  Platform Commission
                </Typography>
              </Box>
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <Box sx={{ p: 3, border: theme => `1px solid ${theme.palette.divider}`, borderRadius: 2, textAlign: 'center' }}>
                <Typography variant='h4'>
                  {stats?.totalTipCount || 0}
                </Typography>
                <Typography variant='body2' color='text.secondary' sx={{ mt: 1 }}>
                  Total Tips
                </Typography>
              </Box>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      <Card>
        <CardContent>
          <Typography variant='subtitle1' sx={{ mb: 3, fontWeight: 600, display: 'flex', alignItems: 'center' }}>
            <i className='tabler-list mr-2' />
            Recent Tips
          </Typography>

          <TableContainer>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Date</TableCell>
                  <TableCell>User</TableCell>
                  <TableCell>Expert</TableCell>
                  <TableCell>Session</TableCell>
                  <TableCell>Amount</TableCell>
                  <TableCell>Platform Fee</TableCell>
                  <TableCell>Expert Earned</TableCell>
                  <TableCell>Status</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {recentTips.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={8} align='center'>
                      No tips recorded yet.
                    </TableCell>
                  </TableRow>
                ) : (
                  recentTips.map(tip => (
                    <TableRow key={tip._id}>
                      <TableCell>{formatDate(tip.createdAt)}</TableCell>
                      <TableCell>{tip.user?.displayName || tip.userId || '-'}</TableCell>
                      <TableCell>{tip.expert?.displayName || tip.expertId || '-'}</TableCell>
                      <TableCell>{tip.sessionBookingId || '-'}</TableCell>
                      <TableCell>{formatCurrency(tip.tipAmount)}</TableCell>
                      <TableCell>{formatCurrency(tip.platformFee)}</TableCell>
                      <TableCell>{formatCurrency(tip.expertEarning)}</TableCell>
                      <TableCell>
                        <Chip
                          label={tip.status || 'completed'}
                          color={
                            tip.status === 'completed'
                              ? 'success'
                              : tip.status === 'refunded'
                                ? 'warning'
                                : 'default'
                          }
                          size='small'
                          variant='outlined'
                        />
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </CardContent>
      </Card>
    </>
  )
}

export default TipAnalyticsView
