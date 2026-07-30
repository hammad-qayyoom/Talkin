'use client'

import { useCallback, useEffect, useMemo, useState } from 'react'

import axios from 'axios'

import Box from '@mui/material/Box'
import Card from '@mui/material/Card'
import Typography from '@mui/material/Typography'
import CircularProgress from '@mui/material/CircularProgress'
import Table from '@mui/material/Table'
import TableBody from '@mui/material/TableBody'
import TableCell from '@mui/material/TableCell'
import TableContainer from '@mui/material/TableContainer'
import TableHead from '@mui/material/TableHead'
import TableRow from '@mui/material/TableRow'
import Button from '@mui/material/Button'
import Stack from '@mui/material/Stack'
import MenuItem from '@mui/material/MenuItem'
import Chip from '@mui/material/Chip'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'
import TextField from '@mui/material/TextField'
import IconButton from '@mui/material/IconButton'
import Collapse from '@mui/material/Collapse'
import Avatar from '@mui/material/Avatar'
import Tooltip from '@mui/material/Tooltip'

import CustomTextField from '@/@core/components/mui/TextField'
import { baseURL } from '@/config'
import { getAuthHeaders } from '@/utils/auth-headers'

const statusOptions = [
  { value: 'all', label: 'All' },
  { value: 'pending', label: 'Pending Approval' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' }
]

const statusColor = {
  pending: 'warning',
  approved: 'success',
  rejected: 'error'
}

const categoryLabels = {
  document: 'Document',
  image: 'Image',
  worksheet: 'Worksheet',
  video: 'Video',
  audio: 'Audio',
  other: 'Other'
}

const formatDateTime = value => {
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

const formatFileSize = bytes => {
  if (!bytes) return '-'
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}

const PremiumContentModeration = () => {
  const [statusFilter, setStatusFilter] = useState('pending')
  const [loading, setLoading] = useState(false)
  const [contentList, setContentList] = useState([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [actionLoading, setActionLoading] = useState(false)

  const [rejectDialogOpen, setRejectDialogOpen] = useState(false)
  const [selectedContent, setSelectedContent] = useState(null)
  const [rejectionReason, setRejectionReason] = useState('')

  const [expandedRows, setExpandedRows] = useState({})
  const [previewOpen, setPreviewOpen] = useState(false)
  const [previewUrl, setPreviewUrl] = useState('')
  const [previewMime, setPreviewMime] = useState('')

  const fetchContent = useCallback(async () => {
    try {
      setLoading(true)
      const params = { page, limit: 20 }
      if (statusFilter !== 'all') params.status = statusFilter

      const response = await axios.get(`${baseURL}/api/v2/premium-content/admin/list`, {
        headers: getAuthHeaders(),
        params
      })

      setContentList(response?.data?.data?.content || [])
      setTotal(response?.data?.data?.total || 0)
    } catch (error) {
      console.error('Failed to fetch premium content:', error)
      setContentList([])
    } finally {
      setLoading(false)
    }
  }, [statusFilter, page])

  useEffect(() => {
    fetchContent()
  }, [fetchContent])

  const handleApprove = async content => {
    try {
      setActionLoading(true)
      await axios.patch(
        `${baseURL}/api/v2/premium-content/admin/${content._id}/approve`,
        {},
        { headers: getAuthHeaders() }
      )
      fetchContent()
    } catch (error) {
      console.error('Failed to approve content:', error)
    } finally {
      setActionLoading(false)
    }
  }

  const handleRejectClick = content => {
    setSelectedContent(content)
    setRejectionReason('')
    setRejectDialogOpen(true)
  }

  const handleRejectConfirm = async () => {
    if (!selectedContent) return
    try {
      setActionLoading(true)
      await axios.patch(
        `${baseURL}/api/v2/premium-content/admin/${selectedContent._id}/reject`,
        { reason: rejectionReason },
        { headers: getAuthHeaders() }
      )
      setRejectDialogOpen(false)
      setSelectedContent(null)
      setRejectionReason('')
      fetchContent()
    } catch (error) {
      console.error('Failed to reject content:', error)
    } finally {
      setActionLoading(false)
    }
  }

  const toggleRow = id => {
    setExpandedRows(prev => ({ ...prev, [id]: !prev[id] }))
  }

  const handlePreview = async item => {
    try {
      const response = await fetch(`${baseURL}/api/v2/premium-content/admin/preview/${item._id}`, {
        headers: getAuthHeaders()
      })
      if (!response.ok) throw new Error('Preview failed')
      const blob = await response.blob()
      const url = URL.createObjectURL(blob)
      setPreviewUrl(url)
      setPreviewMime(item.fileMimeType || '')
      setPreviewOpen(true)
    } catch (error) {
      console.error('Preview error:', error)
    }
  }

  const rows = useMemo(() => contentList || [], [contentList])

  const getApprovalStatus = item => {
    if (item.isActive === false && item.isApproved === false) return 'rejected'
    if (item.isApproved === true) return 'approved'
    return 'pending'
  }

  return (
    <>
      <Box className='mb-3'>
        <Typography variant='h4'>Premium Content Management</Typography>
        <Typography variant='body2' color='text.secondary'>
          Review and approve/deny expert-uploaded premium content before it becomes available for purchase.
        </Typography>
      </Box>

      <Card>
        <Stack direction='row' justifyContent='space-between' alignItems='center' className='p-6'>
          <Stack direction='row' spacing={2} alignItems='center'>
            <CustomTextField
              select
              value={statusFilter}
              onChange={event => {
                setStatusFilter(event.target.value)
                setPage(1)
              }}
              className='w-[200px]'
            >
              {statusOptions.map(option => (
                <MenuItem key={option.value} value={option.value}>
                  {option.label}
                </MenuItem>
              ))}
            </CustomTextField>
          </Stack>
          <Stack direction='row' spacing={2} alignItems='center'>
            <Typography variant='body2' color='text.secondary'>
              {total} item(s)
            </Typography>
            <Button variant='outlined' onClick={fetchContent}>
              Refresh
            </Button>
          </Stack>
        </Stack>

        {loading ? (
          <div className='flex justify-center items-center my-10 h-[55vh]'>
            <CircularProgress />
          </div>
        ) : (
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell />
                  <TableCell>Expert</TableCell>
                  <TableCell>Title</TableCell>
                  <TableCell>Category</TableCell>
                  <TableCell>Price</TableCell>
                  <TableCell>File</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Uploaded</TableCell>
                  <TableCell>Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {rows.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={9} align='center'>
                      No premium content found.
                    </TableCell>
                  </TableRow>
                ) : (
                  rows.map(item => {
                    const isExpanded = Boolean(expandedRows[item._id])
                    const itemStatus = getApprovalStatus(item)
                    const canAct = itemStatus === 'pending'

                    return (
                      <>
                        <TableRow key={item._id} hover>
                          <TableCell>
                            <IconButton size='small' onClick={() => toggleRow(item._id)}>
                              <i className={isExpanded ? 'tabler-chevron-down' : 'tabler-chevron-right'} />
                            </IconButton>
                          </TableCell>
                          <TableCell>
                            <Stack direction='row' spacing={1.5} alignItems='center'>
                              <Avatar
                                src={item.expertId?.legacyListenerId?.image}
                                alt={item.expertId?.displayName || item.expertId?.userId?.fullName}
                                sx={{ width: 32, height: 32 }}
                              />
                              <Box>
                                <Typography variant='body2' fontWeight={500}>
                                  {item.expertId?.displayName || item.expertId?.userId?.fullName || 'Unknown Expert'}
                                </Typography>
                              </Box>
                            </Stack>
                          </TableCell>
                          <TableCell>
                            <Typography variant='body2' fontWeight={500}>
                              {item.title}
                            </Typography>
                          </TableCell>
                          <TableCell>
                            <Chip
                              label={categoryLabels[item.category] || item.category}
                              size='small'
                              variant='outlined'
                            />
                          </TableCell>
                          <TableCell>
                            <Typography variant='body2' fontWeight={500}>
                              {item.price} {item.currency || 'coins'}
                            </Typography>
                          </TableCell>
                          <TableCell>
                            <Tooltip title={item.fileName || ''}>
                              <Typography variant='caption' color='text.secondary'>
                                {item.fileMimeType?.split('/')[1]?.toUpperCase() || '-'} ({formatFileSize(item.fileSizeBytes)})
                              </Typography>
                            </Tooltip>
                          </TableCell>
                          <TableCell>
                            <Chip label={itemStatus} color={statusColor[itemStatus] || 'default'} size='small' />
                          </TableCell>
                          <TableCell>{formatDateTime(item.createdAt)}</TableCell>
                          <TableCell>
                            {canAct ? (
                              <Stack direction='row' spacing={1}>
                                <Button
                                  variant='outlined'
                                  color='success'
                                  size='small'
                                  disabled={actionLoading}
                                  onClick={() => handleApprove(item)}
                                >
                                  Approve
                                </Button>
                                <Button
                                  variant='outlined'
                                  color='error'
                                  size='small'
                                  disabled={actionLoading}
                                  onClick={() => handleRejectClick(item)}
                                >
                                  Reject
                                </Button>
                              </Stack>
                            ) : itemStatus === 'rejected' ? (
                              <Typography variant='caption' color='error'>
                                Rejected
                              </Typography>
                            ) : (
                              <Typography variant='caption' color='success'>
                                Approved
                              </Typography>
                            )}
                          </TableCell>
                        </TableRow>
                        <TableRow key={`${item._id}-detail`}>
                          <TableCell style={{ paddingBottom: 0, paddingTop: 0 }} colSpan={9}>
                            <Collapse in={isExpanded} timeout='auto' unmountOnExit>
                              <Box sx={{ margin: 2 }}>
                                <Typography variant='subtitle2' gutterBottom>
                                  Content Details
                                </Typography>
                                <Box sx={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 2, mb: 2 }}>
                                  <Box>
                                    <Typography variant='caption' color='text.secondary'>
                                      Description
                                    </Typography>
                                    <Typography variant='body2'>
                                      {item.description || 'No description'}
                                    </Typography>
                                  </Box>
                                  <Box>
                                    <Typography variant='caption' color='text.secondary'>
                                      File Name
                                    </Typography>
                                    <Typography variant='body2'>{item.fileName || '-'}</Typography>
                                  </Box>
                                  <Box>
                                    <Typography variant='caption' color='text.secondary'>
                                      MIME Type
                                    </Typography>
                                    <Typography variant='body2'>{item.fileMimeType || '-'}</Typography>
                                  </Box>
                                  <Box>
                                    <Typography variant='caption' color='text.secondary'>
                                      Total Sold
                                    </Typography>
                                    <Typography variant='body2'>{item.totalSold || 0}</Typography>
                                  </Box>
                                  <Box>
                                    <Typography variant='caption' color='text.secondary'>
                                      Total Revenue
                                    </Typography>
                                    <Typography variant='body2'>{item.totalRevenue || 0} coins</Typography>
                                  </Box>
                                  <Box>
                                    <Typography variant='caption' color='text.secondary'>
                                      Active
                                    </Typography>
                                    <Typography variant='body2'>{item.isActive ? 'Yes' : 'No'}</Typography>
                                  </Box>
                                </Box>
                                <Button
                                  variant='outlined'
                                  size='small'
                                  startIcon={<i className='tabler-eye' />}
                                  onClick={() => handlePreview(item)}
                                >
                                  Preview File
                                </Button>
                              </Box>
                            </Collapse>
                          </TableCell>
                        </TableRow>
                      </>
                    )
                  })
                )}
              </TableBody>
            </Table>
          </TableContainer>
        )}

        {total > 20 && (
          <Stack direction='row' justifyContent='center' className='p-4'>
            <Button disabled={page <= 1} onClick={() => setPage(p => p - 1)}>
              Previous
            </Button>
            <Typography className='mx-4 self-center'>
              Page {page} of {Math.ceil(total / 20)}
            </Typography>
            <Button disabled={page * 20 >= total} onClick={() => setPage(p => p + 1)}>
              Next
            </Button>
          </Stack>
        )}
      </Card>

      <Dialog open={rejectDialogOpen} onClose={() => setRejectDialogOpen(false)} maxWidth='sm' fullWidth>
        <DialogTitle>Reject Content: {selectedContent?.title}</DialogTitle>
        <DialogContent>
          <Typography variant='body2' color='text.secondary' sx={{ mb: 2 }}>
            This content will be removed and the expert will be notified.
          </Typography>
          <TextField
            autoFocus
            fullWidth
            multiline
            rows={3}
            label='Rejection Reason'
            value={rejectionReason}
            onChange={e => setRejectionReason(e.target.value)}
            placeholder='Enter reason for rejection...'
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setRejectDialogOpen(false)}>Cancel</Button>
          <Button variant='contained' color='error' onClick={handleRejectConfirm} disabled={actionLoading}>
            Reject
          </Button>
        </DialogActions>
      </Dialog>

      <Dialog
        open={previewOpen}
        onClose={() => {
          setPreviewOpen(false)
          if (previewUrl) URL.revokeObjectURL(previewUrl)
          setPreviewUrl('')
        }}
        maxWidth='lg'
        fullWidth
      >
        <DialogTitle>
          <Stack direction='row' justifyContent='space-between' alignItems='center'>
            <Typography variant='h6'>File Preview</Typography>
            <IconButton onClick={() => {
              setPreviewOpen(false)
              if (previewUrl) URL.revokeObjectURL(previewUrl)
              setPreviewUrl('')
            }}>
              <i className='tabler-x' />
            </IconButton>
          </Stack>
        </DialogTitle>
        <DialogContent sx={{ p: 0, minHeight: '60vh' }}>
          {previewMime.startsWith('image/') ? (
            <Box component='img' src={previewUrl} alt='Preview' sx={{ width: '100%', objectFit: 'contain' }} />
          ) : previewMime === 'application/pdf' ? (
            <Box component='iframe' src={previewUrl} sx={{ width: '100%', height: '70vh', border: 'none' }} />
          ) : (
            <Box sx={{ p: 4, textAlign: 'center' }}>
              <Typography variant='body1' color='text.secondary'>
                Preview not available for this file type ({previewMime}).
              </Typography>
              <Button
                variant='outlined'
                sx={{ mt: 2 }}
                onClick={() => {
                  const a = document.createElement('a')
                  a.href = previewUrl
                  a.download = selectedContent?.fileName || 'file'
                  a.click()
                }}
              >
                Download File
              </Button>
            </Box>
          )}
        </DialogContent>
      </Dialog>
    </>
  )
}

export default PremiumContentModeration
