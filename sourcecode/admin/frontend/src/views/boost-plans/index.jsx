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
import Switch from '@mui/material/Switch'
import Typography from '@mui/material/Typography'

import TablePaginationComponent from '@/components/TablePaginationComponent'
import EmprtyTableRow from '@/components/common/EmprtyTableRow'
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import {
  deleteBoostPlan,
  fetchBoostPlans,
  setPage,
  setPageSize,
  toggleBoostPlanField
} from '@/redux-store/slices/boostPlans'

import tableStyles from '@core/styles/table.module.css'

import BoostPlanDialog from './BoostPlanDialog'

const columnHelper = createColumnHelper()

const formatDuration = hours => {
  if (!hours) return '-'
  if (hours < 24) return `${hours} Hour${hours === 1 ? '' : 's'}`
  const days = Math.round(hours / 24)
  return `${days} Day${days === 1 ? '' : 's'}`
}

const BoostPlans = () => {
  const dispatch = useDispatch()
  const searchParams = useSearchParams()
  const router = useRouter()
  const pathname = usePathname()

  const { boostPlans, initialLoading, loading, error, page, pageSize, total } = useSelector(
    state => state.boostPlans
  )

  const [openDialog, setOpenDialog] = useState(false)
  const [selectedPlan, setSelectedPlan] = useState(null)
  const [mode, setMode] = useState('create')
  const [confirmOpen, setConfirmOpen] = useState(false)
  const [confirmType, setConfirmType] = useState('delete-boost-plan')

  const urlPage = parseInt(searchParams.get('page') || '1')
  const urlPageSize = parseInt(searchParams.get('pageSize') || '10')

  useEffect(() => {
    dispatch(fetchBoostPlans({ page: urlPage, pageSize: urlPageSize }))
  }, [dispatch, urlPage, urlPageSize])

  const handleOpenDeleteDialog = plan => {
    setSelectedPlan(plan)
    setConfirmType('delete-boost-plan')
    setConfirmOpen(true)
  }

  const handleConfirmDelete = () => {
    if (selectedPlan) {
      dispatch(deleteBoostPlan(selectedPlan._id))
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
      dispatch(toggleBoostPlanField({ boostPlanId: selectedPlan._id, field }))
    }
  }

  const handleConfirm = () => {
    if (confirmType === 'delete-boost-plan') {
      handleConfirmDelete()
    } else if (confirmType.startsWith('toggle-')) {
      handleConfirmToggle()
    }
  }

  const getConfirmTitle = () => {
    if (confirmType === 'delete-boost-plan') return 'Delete this boost plan?'
    if (confirmType === 'toggle-isActive') return 'Toggle plan active status?'
    return 'Confirm action?'
  }

  const getConfirmContent = () => {
    if (confirmType === 'delete-boost-plan')
      return 'This action cannot be undone. Plans with active boosts cannot be deleted.'
    if (confirmType === 'toggle-isActive') return 'This will enable or disable the boost plan for experts.'
    return ''
  }

  const columns = useMemo(
    () => [
      columnHelper.accessor(row => row.name, {
        id: 'name',
        header: 'Plan Name',
        cell: ({ getValue }) => <Typography>{getValue() || '-'}</Typography>
      }),
      columnHelper.accessor(row => row.durationHours, {
        id: 'durationHours',
        header: 'Duration',
        cell: ({ getValue }) => <Typography>{formatDuration(getValue())}</Typography>
      }),
      columnHelper.accessor(row => row.creditCost, {
        id: 'creditCost',
        header: 'Credit Cost',
        cell: ({ getValue }) => (
          <Typography sx={{ fontWeight: 600, color: 'primary.main' }}>
            {getValue() || 0} credits
          </Typography>
        )
      }),
      columnHelper.accessor(row => row.visibilityMultiplier, {
        id: 'visibilityMultiplier',
        header: 'Visibility Multiplier',
        cell: ({ getValue }) => (
          <Typography sx={{ fontWeight: 600, color: 'success.main' }}>
            {getValue()}x
          </Typography>
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
        header: 'Created',
        cell: ({ getValue }) => {
          const date = getValue()
          if (!date) return '-'
          return new Date(date).toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
          })
        }
      }),
      columnHelper.accessor('actions', {
        header: 'Actions',
        cell: ({ row }) => (
          <Box sx={{ display: 'flex', gap: 2 }}>
            <Button
              variant='outlined'
              size='small'
              onClick={() => {
                setSelectedPlan(row.original)
                setMode('edit')
                setOpenDialog(true)
              }}
            >
              Edit
            </Button>
            <Button
              variant='outlined'
              color='error'
              size='small'
              onClick={() => handleOpenDeleteDialog(row.original)}
            >
              Delete
            </Button>
          </Box>
        )
      })
    ],
    // eslint-disable-next-line react-hooks/exhaustive-deps
    []
  )

  const table = useReactTable({
    data: boostPlans || [],
    columns,
    getCoreRowModel: getCoreRowModel()
  })

  const handlePageChange = newPage => {
    const params = new URLSearchParams(searchParams.toString())
    params.set('page', String(newPage))
    router.push(`${pathname}?${params.toString()}`)
  }

  if (initialLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '55vh' }}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Typography variant='h4'>Boost Plans</Typography>
        <Button
          variant='contained'
          onClick={() => {
            setSelectedPlan(null)
            setMode('create')
            setOpenDialog(true)
          }}
        >
          Add Boost Plan
        </Button>
      </Box>

      <Card>
        <table className={tableStyles.table}>
          <thead>
            {table.getHeaderGroups().map(headerGroup => (
              <tr key={headerGroup.id}>
                {headerGroup.headers.map(header => (
                  <th key={header.id}>{header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}</th>
                ))}
              </tr>
            ))}
          </thead>
          <tbody>
            {table.getRowModel().rows.length === 0 ? (
              <EmprtyTableRow colSpan={columns.length} />
            ) : (
              table.getRowModel().rows.map(row => (
                <tr key={row.id} style={{ cursor: 'pointer' }}>
                  {row.getVisibleCells().map(cell => (
                    <td key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>

        <TablePaginationComponent
          total={total || 0}
          pageSize={pageSize || 10}
          page={page || 1}
          onPageChange={handlePageChange}
        />
      </Card>

      <BoostPlanDialog
        open={openDialog}
        onClose={() => {
          setOpenDialog(false)
          setSelectedPlan(null)
        }}
        mode={mode}
        plan={selectedPlan}
      />

      <ConfirmationDialog
        open={confirmOpen}
        setOpen={setConfirmOpen}
        title={getConfirmTitle()}
        content={getConfirmContent()}
        onConfirm={handleConfirm}
        loading={loading}
        onClose={() => {
          setConfirmOpen(false)
          setSelectedPlan(null)
          setConfirmType('')
        }}
      />
    </>
  )
}

export default BoostPlans
