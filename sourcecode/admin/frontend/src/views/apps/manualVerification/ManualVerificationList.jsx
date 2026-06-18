'use client'

import { useEffect, useMemo, useState } from 'react'

import { useRouter, useSearchParams, usePathname } from 'next/navigation'

import { useDispatch, useSelector } from 'react-redux'

import { Chip, CircularProgress, Switch, Tooltip } from '@mui/material'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Dialog from '@mui/material/Dialog'
import DialogActions from '@mui/material/DialogActions'
import DialogContent from '@mui/material/DialogContent'
import DialogTitle from '@mui/material/DialogTitle'
import Grid from '@mui/material/Grid'
import IconButton from '@mui/material/IconButton'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'
import { useTheme } from '@mui/material/styles'

import { rankItem } from '@tanstack/match-sorter-utils'
import {
  createColumnHelper,
  flexRender,
  getCoreRowModel,
  getFilteredRowModel,
  getSortedRowModel,
  useReactTable
} from '@tanstack/react-table'
import classnames from 'classnames'

import TablePaginationComponent from '@components/TablePaginationComponent'
import CustomTextField from '@core/components/mui/TextField'
import tableStyles from '@core/styles/table.module.css'

import { getFullImageUrl } from '@/utils/commonfunctions'
import { getInitials } from '@/utils/getInitials'
import CustomAvatar from '@core/components/mui/Avatar'

import {
  fetchManualVerificationQueue,
  approveManualVerification,
  rejectManualVerification,
  revokeVerificationBadge,
  setPage,
  setPageSize,
  setSearchQuery,
  setStatusFilter
} from '@/redux-store/slices/manualVerification'

import { baseURL } from '@/config'

const columnHelper = createColumnHelper()

const fuzzyFilter = (row, columnId, value, addMeta) => {
  const itemRank = rankItem(row.getValue(columnId), value)
  addMeta({ itemRank })
  return itemRank.passed
}

const ManualVerificationList = () => {
  const dispatch = useDispatch()
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()
  const theme = useTheme()

  const { requests, total, loading, page, pageSize } = useSelector(state => state.manualVerification)

  const [globalFilter, setGlobalFilter] = useState('')
  const [rejectDialogOpen, setRejectDialogOpen] = useState(false)
  const [rejectReason, setRejectReason] = useState('')
  const [selectedExpertId, setSelectedExpertId] = useState(null)
  const [actionLoading, setActionLoading] = useState({})

  useEffect(() => {
    dispatch(setSearchQuery(''))
    dispatch(setPage(1))
    dispatch(setPageSize(10))
  }, [dispatch])

  useEffect(() => {
    const params = {
      page,
      limit: pageSize,
      search: searchParams.get('search') || 'All',
      status: searchParams.get('status') || 'pending'
    }
    dispatch(fetchManualVerificationQueue(params))
  }, [page, pageSize, searchParams, dispatch])

  const handleApprove = (expertId) => {
    setActionLoading(prev => ({ ...prev, [expertId]: 'approve' }))
    dispatch(approveManualVerification({ expertId })).finally(() => {
      setActionLoading(prev => ({ ...prev, [expertId]: null }))
      dispatch(fetchManualVerificationQueue({ page, limit: pageSize }))
    })
  }

  const handleRejectClick = (expertId) => {
    setSelectedExpertId(expertId)
    setRejectReason('')
    setRejectDialogOpen(true)
  }

  const handleRejectConfirm = () => {
    if (!rejectReason.trim() || !selectedExpertId) return
    setActionLoading(prev => ({ ...prev, [selectedExpertId]: 'reject' }))
    dispatch(rejectManualVerification({
      expertId: selectedExpertId,
      rejectionReason: rejectReason.trim()
    })).finally(() => {
      setActionLoading(prev => ({ ...prev, [selectedExpertId]: null }))
      setRejectDialogOpen(false)
      setSelectedExpertId(null)
      setRejectReason('')
      dispatch(fetchManualVerificationQueue({ page, limit: pageSize }))
    })
  }

  const handleRevoke = (expertId) => {
    setActionLoading(prev => ({ ...prev, [expertId]: 'revoke' }))
    dispatch(revokeVerificationBadge({ expertId })).finally(() => {
      setActionLoading(prev => ({ ...prev, [expertId]: null }))
    })
  }

  const openDocument = (url) => {
    let fullUrl = url
    if (!url.startsWith('http')) {
      const cleanUrl = url.replace(/^storage[\/\\]/, '')
      fullUrl = `${baseURL}/storage/${cleanUrl}`
    }
    window.open(fullUrl, '_blank')
  }

  const columns = useMemo(() => [
    columnHelper.accessor('expertName', {
      header: 'Expert',
      cell: ({ row }) => {
        const { expertName, expertEmail, expertImage } = row.original
        return (
          <div className='flex items-center gap-3 min-w-[200px]'>
            <CustomAvatar
              src={getFullImageUrl(expertImage) || '/images/avatars/1.png'}
              size={40}
              skin='light'
              color='primary'
            >
              {getInitials(expertName)}
            </CustomAvatar>
            <div className='flex flex-col'>
              <Typography variant='body2' className='font-medium'>
                {expertName || '-'}
              </Typography>
              <Typography variant='caption' color='text.secondary'>
                {expertEmail || '-'}
              </Typography>
            </div>
          </div>
        )
      }
    }),
    columnHelper.accessor('manualVerificationSubmittedAt', {
      header: 'Submitted',
      cell: ({ row }) => {
        const date = row.original.manualVerificationSubmittedAt
        if (!date) return <Typography color='text.secondary'>-</Typography>
        return (
          <Typography variant='body2'>
            {new Date(date).toLocaleDateString('en-US', {
              year: 'numeric',
              month: 'short',
              day: 'numeric',
              hour: '2-digit',
              minute: '2-digit'
            })}
          </Typography>
        )
      }
    }),
    columnHelper.accessor('manualVerificationDocuments', {
      header: 'Documents',
      cell: ({ row }) => {
        const docs = row.original.manualVerificationDocuments || []
        if (!docs.length) return <Typography color='text.secondary'>No documents</Typography>

        return (
          <div className='flex flex-wrap gap-1'>
            {docs.map((doc, i) => (
              <Tooltip key={i} title={doc.originalName || `Document ${i + 1}`}>
                <Chip
                  size='small'
                  label={doc.originalName?.length > 20
                    ? doc.originalName.substring(0, 20) + '...'
                    : (doc.originalName || `Doc ${i + 1}`)}
                  icon={<i className='tabler-file' style={{ fontSize: 14 }} />}
                  onClick={() => openDocument(doc.url)}
                  variant='outlined'
                  sx={{ cursor: 'pointer' }}
                />
              </Tooltip>
            ))}
          </div>
        )
      }
    }),
    columnHelper.accessor('verifiedBadgeType', {
      header: 'Badge Type',
      cell: ({ row }) => {
        const type = row.original.verifiedBadgeType || 'none'
        const isVerified = row.original.isVerifiedBadge
        if (!isVerified) {
          return <Chip size='small' label='Pending' color='warning' variant='tonal' />
        }
        const label = type === 'auto_sessions' ? 'Auto Sessions'
          : type === 'celebrity' ? 'Celebrity'
          : type === 'manual' ? 'Manual'
          : 'None'
        return <Chip size='small' label={label} color='primary' variant='tonal' />
      }
    }),
    columnHelper.accessor('manualVerificationStatus', {
      header: 'Status',
      cell: ({ row }) => {
        const status = row.original.manualVerificationStatus
        return (
          <Chip
            size='small'
            label={status === 'pending' ? 'Pending' : status === 'approved' ? 'Approved' : status === 'rejected' ? 'Rejected' : status}
            color={status === 'pending' ? 'warning' : status === 'approved' ? 'success' : status === 'rejected' ? 'error' : 'default'}
            variant='tonal'
          />
        )
      }
    }),
    columnHelper.accessor('_id', {
      header: 'Actions',
      cell: ({ row }) => {
        const expertId = row.original._id
        const isBusy = actionLoading[expertId]

        return (
          <div className='flex items-center gap-2'>
            <Tooltip title='Approve verification'>
              <span>
                <Button
                  size='small'
                  variant='contained'
                  color='success'
                  disabled={!!isBusy}
                  startIcon={isBusy === 'approve'
                    ? <CircularProgress size={14} color='inherit' />
                    : <i className='tabler-check' />}
                  onClick={() => handleApprove(expertId)}
                >
                  Approve
                </Button>
              </span>
            </Tooltip>
            <Tooltip title='Reject with reason'>
              <span>
                <Button
                  size='small'
                  variant='contained'
                  color='error'
                  disabled={!!isBusy}
                  startIcon={isBusy === 'reject'
                    ? <CircularProgress size={14} color='inherit' />
                    : <i className='tabler-x' />}
                  onClick={() => handleRejectClick(expertId)}
                >
                  Reject
                </Button>
              </span>
            </Tooltip>
            {row.original.isVerifiedBadge && (
              <Tooltip title='Revoke verification badge'>
                <span>
                  <Button
                    size='small'
                    variant='outlined'
                    color='warning'
                    disabled={!!isBusy}
                    startIcon={isBusy === 'revoke'
                      ? <CircularProgress size={14} color='inherit' />
                      : <i className='tabler-shield-off' />}
                    onClick={() => handleRevoke(expertId)}
                  >
                    Revoke
                  </Button>
                </span>
              </Tooltip>
            )}
          </div>
        )
      }
    })
  ], [actionLoading])

  const table = useReactTable({
    data: requests,
    columns,
    state: { globalFilter },
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getSortedRowModel: getSortedRowModel(),
    filterFns: { fuzzy: fuzzyFilter },
    globalFilterFn: fuzzyFilter,
    onGlobalFilterChange: setGlobalFilter
  })

  return (
    <>
      <Card>
        <CardContent>
          <div className='flex flex-wrap items-center justify-between gap-4 mb-4'>
            <div>
              <Typography variant='h5' className='font-semibold'>
                Manual Verification Requests
              </Typography>
              <Typography variant='body2' color='text.secondary'>
                Review evidence-based blue tick verification requests from experts.
              </Typography>
            </div>
            <div className='flex items-center gap-3'>
              <CustomTextField
                placeholder='Search experts...'
                value={globalFilter}
                onChange={e => setGlobalFilter(e.target.value)}
                InputProps={{
                  startAdornment: <i className='tabler-search text-textDisabled' />
                }}
              />
            </div>
          </div>

          {loading ? (
            <div className='flex justify-center items-center py-20'>
              <CircularProgress />
            </div>
          ) : requests.length === 0 ? (
            <div className='flex flex-col items-center justify-center py-20'>
              <i className='tabler-badge-off text-6xl text-textDisabled mb-4' />
              <Typography variant='h6' color='text.secondary'>
                No verification requests
              </Typography>
              <Typography variant='body2' color='text.disabled'>
                All manual verification requests have been processed.
              </Typography>
            </div>
          ) : (
            <>
              <div className='overflow-x-auto'>
                <table className={tableStyles.table}>
                  <thead>
                    {table.getHeaderGroups().map(headerGroup => (
                      <tr key={headerGroup.id}>
                        {headerGroup.headers.map(header => (
                          <th key={header.id}>
                            {header.isPlaceholder
                              ? null
                              : flexRender(header.column.columnDef.header, header.getContext())}
                          </th>
                        ))}
                      </tr>
                    ))}
                  </thead>
                  <tbody>
                    {table.getRowModel().rows.map(row => (
                      <tr key={row.id}>
                        {row.getVisibleCells().map(cell => (
                          <td key={cell.id}>
                            {flexRender(cell.column.columnDef.cell, cell.getContext())}
                          </td>
                        ))}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              <TablePaginationComponent
                total={total}
                page={page}
                pageSize={pageSize}
                onPageChange={newPage => dispatch(setPage(newPage))}
                onPageSizeChange={newSize => dispatch(setPageSize(newSize))}
              />
            </>
          )}
        </CardContent>
      </Card>

      <Dialog open={rejectDialogOpen} onClose={() => setRejectDialogOpen(false)} maxWidth='sm' fullWidth>
        <DialogTitle>Reject Verification Request</DialogTitle>
        <DialogContent>
          <Typography variant='body2' color='text.secondary' sx={{ mb: 2 }}>
            Please provide a reason for rejecting this verification request. The expert will be notified.
          </Typography>
          <TextField
            autoFocus
            fullWidth
            multiline
            rows={3}
            label='Rejection Reason'
            value={rejectReason}
            onChange={e => setRejectReason(e.target.value)}
            placeholder='e.g. Documents are insufficient or invalid'
            required
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setRejectDialogOpen(false)}>
            Cancel
          </Button>
          <Button
            variant='contained'
            color='error'
            onClick={handleRejectConfirm}
            disabled={!rejectReason.trim()}
          >
            Reject
          </Button>
        </DialogActions>
      </Dialog>
    </>
  )
}

export default ManualVerificationList
