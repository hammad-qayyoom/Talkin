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

import CustomTextField from '@/@core/components/mui/TextField'
import { baseURL } from '@/config'
import { getAuthHeaders } from '@/utils/auth-headers'

const approvalStatusOptions = [
  { value: 'all', label: 'All' },
  { value: 'pending', label: 'Pending' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' }
]

const approvalColor = {
  pending: 'warning',
  approved: 'success',
  rejected: 'error'
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

const ClinicManagementView = () => {
  const [approvalFilter, setApprovalFilter] = useState('all')
  const [search, setSearch] = useState('')
  const [loading, setLoading] = useState(false)
  const [clinics, setClinics] = useState([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [actionLoading, setActionLoading] = useState(false)

  // Dialog state
  const [rejectDialogOpen, setRejectDialogOpen] = useState(false)
  const [selectedClinic, setSelectedClinic] = useState(null)
  const [rejectionReason, setRejectionReason] = useState('')

  // Expanded row state
  const [expandedRows, setExpandedRows] = useState({})

  const fetchClinics = useCallback(async () => {
    try {
      setLoading(true)
      const params = { start: page, limit: 20 }

      if (approvalFilter !== 'all') params.approvalStatus = approvalFilter
      if (search.trim()) params.search = search.trim()

      const response = await axios.get(`${baseURL}/api/admin/clinic/list`, {
        headers: getAuthHeaders(),
        params
      })

      setClinics(response?.data?.data || [])
      setTotal(response?.data?.total || 0)
    } catch (error) {
      console.error('Failed to fetch clinics:', error)
      setClinics([])
    } finally {
      setLoading(false)
    }
  }, [approvalFilter, page, search])

  useEffect(() => {
    fetchClinics()
  }, [fetchClinics])

  const handleApprove = async clinic => {
    try {
      setActionLoading(true)
      await axios.patch(
        `${baseURL}/api/admin/clinic/approve`,
        { expertProfileId: clinic._id, action: 'approved' },
        { headers: getAuthHeaders() }
      )
      fetchClinics()
    } catch (error) {
      console.error('Failed to approve clinic:', error)
    } finally {
      setActionLoading(false)
    }
  }

  const handleRejectClick = clinic => {
    setSelectedClinic(clinic)
    setRejectionReason('')
    setRejectDialogOpen(true)
  }

  const handleRejectConfirm = async () => {
    if (!selectedClinic) return

    try {
      setActionLoading(true)
      await axios.patch(
        `${baseURL}/api/admin/clinic/approve`,
        { expertProfileId: selectedClinic._id, action: 'rejected', rejectionReason },
        { headers: getAuthHeaders() }
      )
      setRejectDialogOpen(false)
      setSelectedClinic(null)
      setRejectionReason('')
      fetchClinics()
    } catch (error) {
      console.error('Failed to reject clinic:', error)
    } finally {
      setActionLoading(false)
    }
  }

  const toggleRow = id => {
    setExpandedRows(prev => ({ ...prev, [id]: !prev[id] }))
  }

  const rows = useMemo(() => clinics || [], [clinics])

  return (
    <>
      <Box className='mb-3'>
        <Typography variant='h4'>Clinic Management</Typography>
        <Typography variant='body2' color='text.secondary'>
          Review and manage expert clinic registrations for in-person consultations.
        </Typography>
      </Box>

      <Card>
        <Stack direction='row' justifyContent='space-between' alignItems='center' className='p-6'>
          <Stack direction='row' spacing={2} alignItems='center'>
            <CustomTextField
              select
              value={approvalFilter}
              onChange={event => {
                setApprovalFilter(event.target.value)
                setPage(1)
              }}
              className='w-[180px]'
            >
              {approvalStatusOptions.map(option => (
                <MenuItem key={option.value} value={option.value}>
                  {option.label}
                </MenuItem>
              ))}
            </CustomTextField>
            <CustomTextField
              placeholder='Search clinics...'
              value={search}
              onChange={event => {
                setSearch(event.target.value)
                setPage(1)
              }}
              className='w-[250px]'
            />
          </Stack>
          <Stack direction='row' spacing={2} alignItems='center'>
            <Typography variant='body2' color='text.secondary'>
              {total} clinic(s)
            </Typography>
            <Button variant='outlined' onClick={fetchClinics}>
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
                  <TableCell>Clinic Name</TableCell>
                  <TableCell>City</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Pricing</TableCell>
                  <TableCell>Submitted</TableCell>
                  <TableCell>Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {rows.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={8} align='center'>
                      No clinics found.
                    </TableCell>
                  </TableRow>
                ) : (
                  rows.map(clinic => {
                    const isExpanded = Boolean(expandedRows[clinic._id])
                    const status = clinic?.clinicDetails?.approvalStatus || 'pending'
                    const canAct = status === 'pending'

                    return (
                      <>
                        <TableRow key={clinic._id} hover>
                          <TableCell>
                            <IconButton size='small' onClick={() => toggleRow(clinic._id)}>
                              <i className={isExpanded ? 'tabler-chevron-down' : 'tabler-chevron-right'} />
                            </IconButton>
                          </TableCell>
                          <TableCell>
                            <Typography variant='body2' fontWeight={500}>
                              {clinic.displayName || clinic.user?.name || '-'}
                            </Typography>
                            <Typography variant='caption' color='text.secondary'>
                              {clinic.user?.email || '-'}
                            </Typography>
                          </TableCell>
                          <TableCell>{clinic?.clinicDetails?.clinicName || '-'}</TableCell>
                          <TableCell>{clinic?.clinicDetails?.address?.city || '-'}</TableCell>
                          <TableCell>
                            <Chip label={status} color={approvalColor[status] || 'default'} size='small' />
                          </TableCell>
                          <TableCell>
                            {clinic?.inPersonPricing?.oneToOneSession || 0}{' '}
                            {clinic?.inPersonPricing?.currency || 'USD'}
                          </TableCell>
                          <TableCell>{formatDateTime(clinic?.clinicDetails?.approvedAt || clinic?.createdAt)}</TableCell>
                          <TableCell>
                            {canAct ? (
                              <Stack direction='row' spacing={1}>
                                <Button
                                  variant='outlined'
                                  color='success'
                                  size='small'
                                  disabled={actionLoading}
                                  onClick={() => handleApprove(clinic)}
                                >
                                  Approve
                                </Button>
                                <Button
                                  variant='outlined'
                                  color='error'
                                  size='small'
                                  disabled={actionLoading}
                                  onClick={() => handleRejectClick(clinic)}
                                >
                                  Reject
                                </Button>
                              </Stack>
                            ) : status === 'rejected' ? (
                              <Typography variant='caption' color='error'>
                                {clinic?.clinicDetails?.rejectionReason || 'Rejected'}
                              </Typography>
                            ) : (
                              <Typography variant='caption' color='success'>
                                Approved
                              </Typography>
                            )}
                          </TableCell>
                        </TableRow>
                        <TableRow key={`${clinic._id}-detail`}>
                          <TableCell style={{ paddingBottom: 0, paddingTop: 0 }} colSpan={8}>
                            <Collapse in={isExpanded} timeout='auto' unmountOnExit>
                              <Box sx={{ margin: 2 }}>
                                <Typography variant='subtitle2' gutterBottom>
                                  Clinic Details
                                </Typography>
                                <Box sx={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 2, mb: 2 }}>
                                  <Box>
                                    <Typography variant='caption' color='text.secondary'>Address</Typography>
                                    <Typography variant='body2'>
                                      {clinic?.clinicDetails?.address?.full || clinic?.clinicDetails?.address?.street || '-'}
                                    </Typography>
                                  </Box>
                                  <Box>
                                    <Typography variant='caption' color='text.secondary'>State / Country</Typography>
                                    <Typography variant='body2'>
                                      {clinic?.clinicDetails?.address?.state || '-'}, {clinic?.clinicDetails?.address?.country || '-'}
                                    </Typography>
                                  </Box>
                                  <Box>
                                    <Typography variant='caption' color='text.secondary'>Postal Code</Typography>
                                    <Typography variant='body2'>
                                      {clinic?.clinicDetails?.address?.postalCode || '-'}
                                    </Typography>
                                  </Box>
                                  <Box>
                                    <Typography variant='caption' color='text.secondary'>Floor / Suite</Typography>
                                    <Typography variant='body2'>
                                      {clinic?.clinicDetails?.floorSuite || '-'}
                                    </Typography>
                                  </Box>
                                  <Box>
                                    <Typography variant='caption' color='text.secondary'>Landmark</Typography>
                                    <Typography variant='body2'>
                                      {clinic?.clinicDetails?.landmark || '-'}
                                    </Typography>
                                  </Box>
                                  <Box>
                                    <Typography variant='caption' color='text.secondary'>Parking</Typography>
                                    <Typography variant='body2'>
                                      {clinic?.clinicDetails?.parkingInfo || '-'}
                                    </Typography>
                                  </Box>
                                  <Box>
                                    <Typography variant='caption' color='text.secondary'>Contact Phone</Typography>
                                    <Typography variant='body2'>
                                      {clinic?.clinicDetails?.contactPhone || '-'}
                                    </Typography>
                                  </Box>
                                  <Box>
                                    <Typography variant='caption' color='text.secondary'>Contact Email</Typography>
                                    <Typography variant='body2'>
                                      {clinic?.clinicDetails?.contactEmail || '-'}
                                    </Typography>
                                  </Box>
                                  <Box>
                                    <Typography variant='caption' color='text.secondary'>Rating / Sessions</Typography>
                                    <Typography variant='body2'>
                                      {clinic.averageRating || 0} / {clinic.totalSessions || 0}
                                    </Typography>
                                  </Box>
                                </Box>
                                {clinic?.clinicDetails?.consultationInstructions && (
                                  <Box sx={{ mb: 1 }}>
                                    <Typography variant='caption' color='text.secondary'>Instructions</Typography>
                                    <Typography variant='body2'>
                                      {clinic.clinicDetails.consultationInstructions}
                                    </Typography>
                                  </Box>
                                )}
                                {clinic?.clinicDetails?.clinicPhotos?.length > 0 && (
                                  <Box>
                                    <Typography variant='caption' color='text.secondary'>Photos</Typography>
                                    <Stack direction='row' spacing={1} sx={{ mt: 0.5 }}>
                                      {clinic.clinicDetails.clinicPhotos.map((photo, idx) => (
                                        <Box
                                          key={idx}
                                          component='img'
                                          src={photo.url}
                                          alt={photo.caption || `Photo ${idx + 1}`}
                                          sx={{ width: 80, height: 80, objectFit: 'cover', borderRadius: 1 }}
                                        />
                                      ))}
                                    </Stack>
                                  </Box>
                                )}
                                {clinic?.clinicDetails?.rejectionReason && status === 'rejected' && (
                                  <Box sx={{ mt: 1 }}>
                                    <Typography variant='caption' color='error'>Rejection Reason</Typography>
                                    <Typography variant='body2' color='error'>
                                      {clinic.clinicDetails.rejectionReason}
                                    </Typography>
                                  </Box>
                                )}
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
            <Typography className='mx-4 self-center'>Page {page}</Typography>
            <Button disabled={page * 20 >= total} onClick={() => setPage(p => p + 1)}>
              Next
            </Button>
          </Stack>
        )}
      </Card>

      {/* Rejection Reason Dialog */}
      <Dialog open={rejectDialogOpen} onClose={() => setRejectDialogOpen(false)} maxWidth='sm' fullWidth>
        <DialogTitle>Reject Clinic: {selectedClinic?.clinicDetails?.clinicName}</DialogTitle>
        <DialogContent>
          <TextField
            autoFocus
            fullWidth
            multiline
            rows={3}
            label='Rejection Reason'
            value={rejectionReason}
            onChange={e => setRejectionReason(e.target.value)}
            placeholder='Enter reason for rejection...'
            sx={{ mt: 2 }}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setRejectDialogOpen(false)}>Cancel</Button>
          <Button variant='contained' color='error' onClick={handleRejectConfirm} disabled={actionLoading}>
            Reject
          </Button>
        </DialogActions>
      </Dialog>
    </>
  )
}

export default ClinicManagementView
