'use client'

import { useEffect, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'

import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Chip from '@mui/material/Chip'
import CircularProgress from '@mui/material/CircularProgress'
import Grid from '@mui/material/Grid'
import MenuItem from '@mui/material/MenuItem'
import Table from '@mui/material/Table'
import TableBody from '@mui/material/TableBody'
import TableCell from '@mui/material/TableCell'
import TableHead from '@mui/material/TableHead'
import TableRow from '@mui/material/TableRow'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'

import { fetchReferralRecords, updateReferralRewardStatus } from '@/redux-store/slices/referralSystem'

const statusColor = status => {
  switch (status) {
    case 'approved':
      return 'success'
    case 'paid':
      return 'info'
    case 'rejected':
      return 'error'
    default:
      return 'warning'
  }
}

const displayName = user => user?.fullName || user?.nickName || user?.email || user?.uniqueId || 'Unknown'

const Referrals = () => {
  const dispatch = useDispatch()
  const { records, total, loading } = useSelector(state => state.referralSystem)

  const [filters, setFilters] = useState({
    page: 1,
    pageSize: 20,
    rewardStatus: 'All',
    rewardTriggerType: 'All',
    search: ''
  })

  useEffect(() => {
    dispatch(fetchReferralRecords(filters))
  }, [dispatch, filters])

  const onRefresh = () => dispatch(fetchReferralRecords(filters))

  const onMarkPaid = record => {
    dispatch(updateReferralRewardStatus({ referralId: record._id, rewardStatus: 'paid' }))
  }

  const onReject = record => {
    dispatch(updateReferralRewardStatus({ referralId: record._id, rewardStatus: 'rejected', rejectionReason: 'Rejected by admin' }))
  }

  return (
    <Grid container spacing={6}>
      <Grid item size={12}>
        <Box sx={{ mb: 4 }}>
          <Typography variant='h4'>Referral Management</Typography>
          <Typography variant='body2' color='text.secondary'>
            Track referrers, referred users, reward trigger, and payout status.
          </Typography>
        </Box>

        <Card>
          <CardContent>
            <Grid container spacing={3} sx={{ mb: 4 }}>
              <Grid item size={3}>
                <TextField
                  fullWidth
                  value={filters.search}
                  label='Search'
                  onChange={event => setFilters(prev => ({ ...prev, search: event.target.value, page: 1 }))}
                />
              </Grid>
              <Grid item size={3}>
                <TextField
                  fullWidth
                  select
                  label='Reward Status'
                  value={filters.rewardStatus}
                  onChange={event => setFilters(prev => ({ ...prev, rewardStatus: event.target.value, page: 1 }))}
                >
                  <MenuItem value='All'>All</MenuItem>
                  <MenuItem value='pending'>Pending</MenuItem>
                  <MenuItem value='approved'>Approved</MenuItem>
                  <MenuItem value='paid'>Paid</MenuItem>
                  <MenuItem value='rejected'>Rejected</MenuItem>
                </TextField>
              </Grid>
              <Grid item size={3}>
                <TextField
                  fullWidth
                  select
                  label='Trigger'
                  value={filters.rewardTriggerType}
                  onChange={event => setFilters(prev => ({ ...prev, rewardTriggerType: event.target.value, page: 1 }))}
                >
                  <MenuItem value='All'>All</MenuItem>
                  <MenuItem value='signup'>Signup</MenuItem>
                  <MenuItem value='subscription'>Subscription</MenuItem>
                  <MenuItem value='completed_session'>Completed Session</MenuItem>
                </TextField>
              </Grid>
              <Grid item size={3}>
                <Button fullWidth variant='contained' onClick={onRefresh} disabled={loading} sx={{ height: '100%' }}>
                  {loading ? <CircularProgress size={20} color='inherit' /> : 'Refresh'}
                </Button>
              </Grid>
            </Grid>

            <Box sx={{ overflowX: 'auto' }}>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Referrer</TableCell>
                    <TableCell>Referred User</TableCell>
                    <TableCell>Code</TableCell>
                    <TableCell>Trigger</TableCell>
                    <TableCell>Reward</TableCell>
                    <TableCell>Status</TableCell>
                    <TableCell>Date</TableCell>
                    <TableCell>Action</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {records.map(record => (
                    <TableRow key={record._id}>
                      <TableCell>{displayName(record.referrerUserId)}</TableCell>
                      <TableCell>{displayName(record.referredUserId)}</TableCell>
                      <TableCell>{record.referralCode}</TableCell>
                      <TableCell>{String(record.rewardTriggerType || '').replace('_', ' ')}</TableCell>
                      <TableCell>
                        {Number(record.rewardAmount || 0)} {record.rewardCurrency || 'credits'}
                      </TableCell>
                      <TableCell>
                        <Chip size='small' color={statusColor(record.rewardStatus)} label={record.rewardStatus || 'pending'} />
                      </TableCell>
                      <TableCell>{record.createdAt ? new Date(record.createdAt).toLocaleString() : '-'}</TableCell>
                      <TableCell>
                        <Box sx={{ display: 'flex', gap: 1 }}>
                          <Button
                            size='small'
                            variant='outlined'
                            disabled={record.rewardStatus === 'paid'}
                            onClick={() => onMarkPaid(record)}
                          >
                            Paid
                          </Button>
                          <Button
                            size='small'
                            color='error'
                            variant='outlined'
                            disabled={record.rewardStatus === 'rejected'}
                            onClick={() => onReject(record)}
                          >
                            Reject
                          </Button>
                        </Box>
                      </TableCell>
                    </TableRow>
                  ))}
                  {!records.length && !loading && (
                    <TableRow>
                      <TableCell colSpan={8} align='center'>
                        No referral records found.
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </Box>

            <Typography variant='body2' color='text.secondary' sx={{ mt: 3 }}>
              Total records: {total}
            </Typography>
          </CardContent>
        </Card>
      </Grid>
    </Grid>
  )
}

export default Referrals
