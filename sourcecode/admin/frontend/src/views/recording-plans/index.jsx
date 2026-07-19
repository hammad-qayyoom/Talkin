'use client'

import { useEffect, useMemo, useState } from 'react'

import { usePathname, useRouter, useSearchParams } from 'next/navigation'

import { createColumnHelper, flexRender, getCoreRowModel, useReactTable } from '@tanstack/react-table'
import { useDispatch, useSelector } from 'react-redux'

import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import CircularProgress from '@mui/material/CircularProgress'
import IconButton from '@mui/material/IconButton'
import MenuItem from '@mui/material/MenuItem'
import Switch from '@mui/material/Switch'
import Typography from '@mui/material/Typography'

import CustomTextField from '@/@core/components/mui/TextField'
import TablePaginationComponent from '@/components/TablePaginationComponent'
import EmprtyTableRow from '@/components/common/EmprtyTableRow'
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import {
  deleteRecordingPlan,
  fetchRecordingPlans,
  setPage,
  setPageSize,
  toggleRecordingPlanField
} from '@/redux-store/slices/recordingPlans'

import tableStyles from '@core/styles/table.module.css'

import RecordingPlanDialog from './RecordingPlanDialog'

const columnHelper = createColumnHelper()

const formatDate = dateString => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

const RecordingPlans = () => {
  const dispatch = useDispatch()
  const searchParams = useSearchParams()
  const router = useRouter()
  const pathname = usePathname()

  const { plans, initialLoading, loading, page, pageSize, total } = useSelector(
    state => state.recordingPlans
  )

  const [openDialog, setOpenDialog] = useState(false)
  const [selectedPlan, setSelectedPlan] = useState(null)
  const [mode, setMode] = useState('create')
  const [confirmOpen, setConfirmOpen] = useState(false)
  const [confirmType, setConfirmType] = useState('delete-recording-plan')

  const urlPage = parseInt(searchParams.get('page') || '1')
  const urlPageSize = parseInt(searchParams.get('pageSize') || '10')

  useEffect(() => {
    dispatch(fetchRecordingPlans({ page: urlPage, pageSize: urlPageSize }))
  }, [dispatch, urlPage, urlPageSize])

  const handleOpenDeleteDialog = plan => {
    setSelectedPlan(plan)
    setConfirmType('delete-recording-plan')
    setConfirmOpen(true)
  }

  const handleConfirmDelete = () => {
    if (selectedPlan) {
      dispatch(deleteRecordingPlan(selectedPlan._id))
    }
  }

  const handleToggleField = (planId, field) => {
    setSelectedPlan({ _id: planId })
    setConfirmType(`toggle-${field}`)
    setConfirmOpen(true)
  }

  const handleConfirmToggle = () => {
    if (selectedPlan && confirmType) {
      const field = confirmType.replace('toggle-', '')
      dispatch(toggleRecordingPlanField({ planId: selectedPlan._id, field }))
    }
  }

  const handleConfirm = () => {
    if (confirmType === 'delete-recording-plan') {
      handleConfirmDelete()
    } else if (confirmType.startsWith('toggle-')) {
      handleConfirmToggle()
    }
  }

  const columns = useMemo(
    () => [
      columnHelper.accessor(row => row.name, {
        id: 'name',
        header: 'Plan Name',
        cell: ({ getValue }) => <Typography>{getValue() || '-'}</Typography>
      }),
      columnHelper.accessor(row => row.appleProductId, {
        id: 'appleProductId',
        header: 'Apple Product ID',
        cell: ({ getValue }) => <Typography>{getValue() || '-'}</Typography>
      }),
      columnHelper.accessor(row => row.googleProductId, {
        id: 'googleProductId',
        header: 'Google Product ID',
        cell: ({ getValue }) => <Typography>{getValue() || '-'}</Typography>
      }),
      columnHelper.accessor(row => row.price, {
        id: 'price',
        header: 'Price (USD)',
        cell: ({ getValue }) => <Typography>$ {getValue().toFixed(2)}</Typography>
      }),
      columnHelper.accessor(row => row.billingCycle, {
        id: 'billingCycle',
        header: 'Billing Cycle',
        cell: ({ getValue }) => <Typography sx={{ textTransform: 'capitalize' }}>{getValue() || '-'}</Typography>
      }),
      columnHelper.accessor(row => row.storageDays, {
        id: 'storageDays',
        header: 'Storage Days',
        cell: ({ getValue }) => <Typography>{getValue() || '-'}</Typography>
      }),
      columnHelper.accessor(row => row.isPopular, {
        id: 'isPopular',
        header: 'Popular',
        cell: ({ getValue, row }) => (
          <Switch
            checked={getValue()}
            onChange={() => handleToggleField(row.original._id, 'isPopular')}
          />
        )
      }),
      columnHelper.accessor(row => row.isActive, {
        id: 'isActive',
        header: 'Active',
        cell: ({ getValue, row }) => (
          <Switch
            checked={getValue()}
            onChange={() => handleToggleField(row.original._id, 'isActive')}
          />
        )
      }),
      columnHelper.accessor(row => row.createdAt, {
        id: 'createdAt',
        header: 'Created At',
        cell: ({ getValue }) => <Typography>{formatDate(getValue())}</Typography>
      }),
      columnHelper.display({
        id: 'actions',
        header: 'Actions',
        cell: ({ row }) => (
          <div className='flex gap-2'>
            <IconButton
              onClick={() => {
                setSelectedPlan(row.original)
                setMode('edit')
                setOpenDialog(true)
              }}
            >
              <i className='tabler-edit text-primary' />
            </IconButton>
            <IconButton
              onClick={() => {
                handleOpenDeleteDialog(row.original)
              }}
            >
              <i className='tabler-trash text-error' />
            </IconButton>
          </div>
        )
      })
    ],
    []
  )

  const table = useReactTable({
    data: plans,
    columns,
    getCoreRowModel: getCoreRowModel()
  })

  const updateUrlPagination = (page, pageSize) => {
    const params = new URLSearchParams(searchParams.toString())
    if (page !== 1) {
      params.set('page', page.toString())
    } else {
      params.delete('page')
    }
    if (pageSize !== 10) {
      params.set('pageSize', pageSize.toString())
    } else {
      params.delete('pageSize')
    }
    router.replace(`${pathname}?${params.toString()}`, { scroll: false })
  }

  const handleRowsPerPageChange = e => {
    const newPageSize = parseInt(e.target.value, 10)
    dispatch(setPageSize(newPageSize))
    dispatch(setPage(1))
    updateUrlPagination(1, newPageSize)
  }

  const handlePageChange = newPage => {
    dispatch(setPage(newPage))
    updateUrlPagination(newPage, searchParams.get('pageSize') ? parseInt(searchParams.get('pageSize'), 10) : pageSize)
  }

  return (
    <Box>
      <Box className='mb-3'>
        <Typography variant='h4'>
          Recording Storage Plans
        </Typography>
        <Typography variant='body2' color='text.secondary'>
          Create and manage recording storage subscription plans, pricing, and platform product IDs.
        </Typography>
      </Box>

      <Card className=''>
        <div className='flex justify-between flex-col items-start md:flex-row md:items-center p-6 gap-4'>
          <CustomTextField
            select
            value={searchParams.get('pageSize') || 10}
            onChange={handleRowsPerPageChange}
            className='max-sm:is-full sm:is-[70px]'
          >
            <MenuItem value='10'>10</MenuItem>
            <MenuItem value='25'>25</MenuItem>
            <MenuItem value='50'>50</MenuItem>
          </CustomTextField>
          <Button
            className='sm:w-auto w-full'
            variant='contained'
            onClick={() => {
              setMode('create')
              setSelectedPlan(null)
              setOpenDialog(true)
            }}
          >
            + Create Recording Storage Plan
          </Button>
        </div>

        <div className='overflow-x-auto'>
          {initialLoading ? (
            <div className='flex justify-center items-center p-6 h-[55vh]'>
              <CircularProgress />
            </div>
          ) : (
            <table className={tableStyles.table}>
              <thead>
                {table.getHeaderGroups().map(headerGroup => (
                  <tr key={headerGroup.id}>
                    {headerGroup.headers.map(header => (
                      <th key={header.id}>
                        {header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}
                      </th>
                    ))}
                  </tr>
                ))}
              </thead>
              <tbody>
                {table.getRowModel().rows.map(row => (
                  <tr key={row.id}>
                    {row.getVisibleCells().map(cell => (
                      <td key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</td>
                    ))}
                  </tr>
                ))}
                <EmprtyTableRow limit={9} data={plans} columns={columns} noDataLebel={'No recording storage plans found'} />
              </tbody>
            </table>
          )}
        </div>

        <TablePaginationComponent
          page={searchParams.get('page') ? parseInt(searchParams.get('page'), 10) : page}
          pageSize={searchParams.get('pageSize') ? parseInt(searchParams.get('pageSize'), 10) : pageSize}
          total={total}
          onPageChange={handlePageChange}
        />
      </Card>

      <RecordingPlanDialog open={openDialog} onClose={() => setOpenDialog(false)} mode={mode} plan={selectedPlan} />

      <ConfirmationDialog
        open={confirmOpen}
        onClose={() => setConfirmOpen(false)}
        onConfirm={handleConfirm}
        type={confirmType}
        title={
          confirmType === 'delete-recording-plan'
            ? 'Are you sure you want to delete this recording storage plan?'
            : confirmType === 'toggle-isActive'
              ? 'Are you sure you want to change the active status?'
              : 'Are you sure you want to change the popular status?'
        }
        loading={loading}
      />
    </Box>
  )
}

export default RecordingPlans
