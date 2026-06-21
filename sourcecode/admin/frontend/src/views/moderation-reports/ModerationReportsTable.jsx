'use client'

import { useCallback, useEffect, useMemo, useState } from 'react'
import axios from 'axios'

import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import Chip from '@mui/material/Chip'
import CircularProgress from '@mui/material/CircularProgress'
import IconButton from '@mui/material/IconButton'
import MenuItem from '@mui/material/MenuItem'
import Typography from '@mui/material/Typography'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'
import Grid from '@mui/material/Grid'
import Tooltip from '@mui/material/Tooltip'

import { toast } from 'react-toastify'

import CustomTextField from '@/@core/components/mui/TextField'
import TablePaginationComponent from '@/components/TablePaginationComponent'
import EmprtyTableRow from '@/components/common/EmprtyTableRow'
import { baseURL, secretKey } from '@/config'

import tableStyles from '@core/styles/table.module.css'

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

const formatDate = value => {
  if (!value) return '-'
  const parsed = new Date(value)
  if (Number.isNaN(parsed.getTime())) return '-'

  return parsed.toLocaleString('en-US', {
    year: 'numeric',
    month: 'short',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const statusColors = {
  open: 'error',
  in_review: 'warning',
  action_taken: 'success',
  dismissed: 'default',
  resolved: 'success'
}

const ModerationReportsTable = ({ reportType, title, subtitle }) => {
  const [loading, setLoading] = useState(true)
  const [reports, setReports] = useState([])
  const [total, setTotal] = useState(0)

  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)

  const [searchInput, setSearchInput] = useState('')
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')

  const [reviewDialogOpen, setReviewDialogOpen] = useState(false)
  const [selectedReport, setSelectedReport] = useState(null)
  const [reviewAction, setReviewAction] = useState('')
  const [reviewNote, setReviewNote] = useState('')
  const [reviewing, setReviewing] = useState(false)

  const loadReports = useCallback(async () => {
    setLoading(true)

    try {
      const params = {
        start: page,
        limit: pageSize,
        reportType
      }

      if (search.trim()) {
        params.search = search.trim()
      }

      if (statusFilter !== 'all') {
        params.status = statusFilter
      }

      const response = await axios.get(`${baseURL}/api/v2/moderation/reports/list`, {
        headers: getAuthHeaders(),
        params
      })

      if (response?.data?.status === true) {
        setReports(response.data.data || [])
        setTotal(Number(response.data.total || 0))
      } else {
        setReports([])
        setTotal(0)
        toast.error(response?.data?.message || 'Unable to fetch reports.')
      }
    } catch (error) {
      setReports([])
      setTotal(0)
      toast.error(error?.response?.data?.message || 'Failed to load reports.')
    } finally {
      setLoading(false)
    }
  }, [page, pageSize, statusFilter, search, reportType])

  useEffect(() => {
    loadReports()
  }, [loadReports])

  useEffect(() => {
    const maxPage = Math.max(1, Math.ceil(total / pageSize))
    if (page > maxPage) {
      setPage(maxPage)
    }
  }, [page, pageSize, total])

  const handleApplySearch = () => {
    setPage(1)
    setSearch(searchInput)
  }

  const handleResetFilters = () => {
    setSearchInput('')
    setSearch('')
    setStatusFilter('all')
    setPage(1)
  }

  const handleOpenReview = report => {
    setSelectedReport(report)
    setReviewAction('')
    setReviewNote('')
    setReviewDialogOpen(true)
  }

  const handleReviewSubmit = async () => {
    if (!selectedReport) return

    if (!reviewAction) {
      toast.error('Please select an action to take.')
      return
    }

    setReviewing(true)
    try {
      // API expects: reportId, status, actionType, reviewNotes
      // actionType: none, warn, suspend, block, dismiss, clear
      // status: open, in_review, action_taken, dismissed, resolved
      
      let newStatus = 'action_taken'
      if (reviewAction === 'dismiss') {
        newStatus = 'dismissed'
      } else if (reviewAction === 'none') {
        newStatus = 'resolved'
      }

      const payload = {
        reportId: selectedReport._id,
        status: newStatus,
        actionType: reviewAction,
        reviewNotes: reviewNote
      }

      const response = await axios.patch(
        `${baseURL}/api/v2/moderation/reports/review`,
        payload,
        {
          headers: getAuthHeaders()
        }
      )

      if (response?.data?.status === true) {
        toast.success(response?.data?.message || 'Report reviewed successfully.')
        setReviewDialogOpen(false)
        loadReports()
      } else {
        toast.error(response?.data?.message || 'Failed to review report.')
      }
    } catch (error) {
      toast.error(error?.response?.data?.message || 'An error occurred while reviewing the report.')
    } finally {
      setReviewing(false)
    }
  }

  const renderTargetInfo = report => {
    const targetUser = report.reportedUserId
    const metadata = report.metadata || {}

    if (reportType === 'user') {
      return (
        <div className='flex flex-col'>
          <Typography variant='body2' className='font-medium'>
            {targetUser?.fullName || targetUser?.nickName || 'Unknown User'}
          </Typography>
          <Typography variant='caption' color='text.secondary'>
            {targetUser?.uniqueId || '-'}
          </Typography>
          {targetUser?.isSuspended && <Chip size='small' color='error' label='Suspended' className='mt-1' />}
        </div>
      )
    }
    
    if (reportType === 'expert_profile') {
      return (
        <div className='flex flex-col'>
          <Typography variant='body2' className='font-medium'>
            {metadata.expertDisplayName || targetUser?.fullName || 'Unknown Expert'}
          </Typography>
          <Typography variant='caption' color='text.secondary'>
            Expert Profile
          </Typography>
        </div>
      )
    }

    if (reportType === 'chat_message') {
      return (
        <div className='flex flex-col'>
          <Typography variant='body2' className='font-medium' noWrap sx={{ maxWidth: 200 }}>
            {metadata.messagePreview || '-'}
          </Typography>
          <Typography variant='caption' color='text.secondary'>
            Sender: {targetUser?.fullName || 'Unknown'}
          </Typography>
        </div>
      )
    }

    if (reportType === 'session') {
      return (
        <div className='flex flex-col'>
          <Typography variant='body2' className='font-medium'>
            {metadata.title || 'Session'}
          </Typography>
          <Typography variant='caption' color='text.secondary'>
            Expert: {metadata.expertDisplayName || '-'}
          </Typography>
        </div>
      )
    }

    return '-'
  }

  const columns = useMemo(
    () => [
      'Reporter',
      'Target',
      'Reason',
      'Status',
      'Reported On',
      'Actions'
    ],
    []
  )

  return (
    <Box>
      <Box className='mb-4'>
        <Typography variant='h4'>{title}</Typography>
        <Typography variant='body2' color='text.secondary'>
          {subtitle}
        </Typography>
      </Box>

      <Card>
        <div className='flex flex-col md:flex-row md:items-center md:justify-between gap-3 p-6'>
          <div className='flex flex-col md:flex-row gap-3 w-full'>
            <CustomTextField
              value={searchInput}
              onChange={e => setSearchInput(e.target.value)}
              onKeyDown={e => {
                if (e.key === 'Enter') {
                  handleApplySearch()
                }
              }}
              placeholder='Search reasons'
              className='w-full md:w-[280px]'
            />
            <CustomTextField
              select
              value={statusFilter}
              onChange={e => {
                setStatusFilter(e.target.value)
                setPage(1)
              }}
              className='w-full md:w-[180px]'
            >
              <MenuItem value='all'>All Statuses</MenuItem>
              <MenuItem value='open'>Open</MenuItem>
              <MenuItem value='in_review'>In Review</MenuItem>
              <MenuItem value='action_taken'>Action Taken</MenuItem>
              <MenuItem value='dismissed'>Dismissed</MenuItem>
              <MenuItem value='resolved'>Resolved</MenuItem>
            </CustomTextField>
            <CustomTextField
              select
              value={pageSize}
              onChange={e => {
                setPageSize(Number(e.target.value))
                setPage(1)
              }}
              className='w-full md:w-[90px]'
            >
              <MenuItem value={10}>10</MenuItem>
              <MenuItem value={25}>25</MenuItem>
              <MenuItem value={50}>50</MenuItem>
            </CustomTextField>
          </div>

          <div className='flex gap-2'>
            <Button variant='contained' onClick={handleApplySearch}>
              Search
            </Button>
            <Button variant='tonal' color='secondary' onClick={handleResetFilters}>
              Reset
            </Button>
          </div>
        </div>

        <div className='overflow-x-auto'>
          {loading ? (
            <div className='flex justify-center items-center p-6 h-[50vh]'>
              <CircularProgress />
            </div>
          ) : (
            <table className={tableStyles.table}>
              <thead>
                <tr>
                  {columns.map(col => (
                    <th key={col}>{col}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {reports.map(report => {
                  const reporter = report.reporterUserId

                  return (
                    <tr key={report._id}>
                      <td>
                        <div className='flex flex-col'>
                          <Typography variant='body2' className='font-medium'>
                            {reporter?.fullName || reporter?.nickName || 'Unknown'}
                          </Typography>
                          <Typography variant='caption' color='text.secondary'>
                            {reporter?.uniqueId || '-'}
                          </Typography>
                        </div>
                      </td>
                      <td>{renderTargetInfo(report)}</td>
                      <td>
                        <div className='flex flex-col'>
                          <Typography variant='body2' className='font-medium capitalize'>
                            {(report.reasonCode || '').replace(/_/g, ' ')}
                          </Typography>
                          <Typography variant='caption' color='text.secondary' sx={{ maxWidth: 200 }} noWrap>
                            {report.reasonText || '-'}
                          </Typography>
                        </div>
                      </td>
                      <td>
                        <Chip
                          size='small'
                          label={(report.status || 'open').replace(/_/g, ' ')}
                          color={statusColors[report.status] || 'default'}
                          className='capitalize'
                        />
                      </td>
                      <td>{formatDate(report.createdAt)}</td>
                      <td>
                        <Tooltip title='Review Report'>
                          <IconButton onClick={() => handleOpenReview(report)}>
                            <i className='tabler-gavel text-primary' />
                          </IconButton>
                        </Tooltip>
                      </td>
                    </tr>
                  )
                })}
                <EmprtyTableRow
                  limit={pageSize}
                  data={reports}
                  columns={columns}
                  noDataLebel='No reports found'
                />
              </tbody>
            </table>
          )}
        </div>

        <TablePaginationComponent page={page} pageSize={pageSize} total={total} onPageChange={setPage} />
      </Card>

      <Dialog open={reviewDialogOpen} onClose={() => !reviewing && setReviewDialogOpen(false)} maxWidth='sm' fullWidth>
        <DialogTitle>Review Report</DialogTitle>
        <DialogContent>
          <Box className='flex flex-col gap-4 pt-2'>
            <Typography variant='body2' className='mb-2'>
              Review the details and take an appropriate action.
            </Typography>
            
            <div className='bg-actionHover p-4 rounded'>
              <Grid container spacing={2}>
                <Grid item xs={12} sm={6}>
                  <Typography variant='caption' color='text.secondary'>Reported By</Typography>
                  <Typography variant='body2' className='font-medium'>
                    {selectedReport?.reporterUserId?.fullName || 'Unknown'}
                  </Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant='caption' color='text.secondary'>Reason Code</Typography>
                  <Typography variant='body2' className='font-medium capitalize'>
                    {(selectedReport?.reasonCode || '').replace(/_/g, ' ')}
                  </Typography>
                </Grid>
                <Grid item xs={12}>
                  <Typography variant='caption' color='text.secondary'>Details / Notes provided by user</Typography>
                  <Typography variant='body2' className='whitespace-pre-wrap'>
                    {selectedReport?.reasonText || 'No additional details provided.'}
                  </Typography>
                </Grid>
              </Grid>
            </div>

            <CustomTextField
              select
              fullWidth
              label='Action to Take'
              value={reviewAction}
              onChange={e => setReviewAction(e.target.value)}
              required
            >
              <MenuItem value=''>Select an action...</MenuItem>
              <MenuItem value='warn'>Send Warning (warn user)</MenuItem>
              <MenuItem value='suspend'>Suspend Target (72h suspension)</MenuItem>
              <MenuItem value='block'>Block Target (permanent ban)</MenuItem>
              <MenuItem value='dismiss'>Dismiss Report (false report)</MenuItem>
              <MenuItem value='none'>Resolve (No action needed)</MenuItem>
            </CustomTextField>

            <CustomTextField
              fullWidth
              multiline
              rows={3}
              label='Review Note (Internal)'
              placeholder='Enter details about your decision...'
              value={reviewNote}
              onChange={e => setReviewNote(e.target.value)}
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button variant='tonal' color='secondary' onClick={() => setReviewDialogOpen(false)} disabled={reviewing}>
            Cancel
          </Button>
          <Button variant='contained' onClick={handleReviewSubmit} disabled={reviewing || !reviewAction}>
            {reviewing ? <CircularProgress size={24} /> : 'Submit Review'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}

export default ModerationReportsTable
