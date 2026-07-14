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

import CustomAvatar from '@/@core/components/mui/Avatar'
import CustomTextField from '@/@core/components/mui/TextField'
import EmprtyTableRow from '@/components/common/EmprtyTableRow'
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import TablePaginationComponent from '@/components/TablePaginationComponent'
import { baseURL } from '@/config'
import {
  deleteUserGrowthSpotlight,
  fetchUserGrowthSpotlights,
  setPage,
  setPageSize,
  toggleUserGrowthSpotlightStatus
} from '@/redux-store/slices/userGrowthSpotlight'

import tableStyles from '@core/styles/table.module.css'

import UserGrowthSpotlightDialog from './UserGrowthSpotlightDialog'

const columnHelper = createColumnHelper()

const formatDate = dateString => {
  if (!dateString) return '-'
  const date = new Date(dateString)

  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

const UserGrowthSpotlight = () => {
  const dispatch = useDispatch()
  const searchParams = useSearchParams()
  const router = useRouter()
  const pathname = usePathname()

  const { items, initialLoading, loading, page, pageSize, total } = useSelector(state => state.userGrowthSpotlight)

  const [openDialog, setOpenDialog] = useState(false)
  const [selectedSpotlight, setSelectedSpotlight] = useState(null)
  const [mode, setMode] = useState('create')
  const [confirmOpen, setConfirmOpen] = useState(false)
  const [confirmType, setConfirmType] = useState('delete-user-growth-spotlight')

  const urlPage = parseInt(searchParams.get('page') || '1', 10)
  const urlPageSize = parseInt(searchParams.get('pageSize') || '10', 10)

  useEffect(() => {
    dispatch(fetchUserGrowthSpotlights({ page: urlPage, pageSize: urlPageSize }))
  }, [dispatch, urlPage, urlPageSize])

  const handleOpenDeleteDialog = spotlight => {
    setSelectedSpotlight(spotlight)
    setConfirmType('delete-user-growth-spotlight')
    setConfirmOpen(true)
  }

  const handleToggleStatus = spotlightId => {
    setSelectedSpotlight({ _id: spotlightId })
    setConfirmType('toggle-status')
    setConfirmOpen(true)
  }

  const handleConfirm = () => {
    if (!selectedSpotlight?._id) return

    if (confirmType === 'delete-user-growth-spotlight') {
      dispatch(deleteUserGrowthSpotlight(selectedSpotlight._id))

      return
    }

    dispatch(toggleUserGrowthSpotlightStatus(selectedSpotlight._id))
  }

  const columns = useMemo(
    () => [
      columnHelper.accessor(row => row.image, {
        id: 'image',
        header: 'Image',
        cell: ({ row }) => (
          <CustomAvatar size={72} variant='rounded' src={`${baseURL}/${row.original.image}`} alt='Spotlight image' />
        )
      }),
      columnHelper.accessor(row => row.title, {
        id: 'title',
        header: 'Title',
        cell: ({ getValue }) => <Typography>{getValue() || '-'}</Typography>
      }),
      columnHelper.accessor(row => row.description, {
        id: 'description',
        header: 'Description',
        cell: ({ getValue }) => (
          <Typography className='max-w-[360px]' sx={{ whiteSpace: 'pre-wrap' }}>
            {getValue() || '-'}
          </Typography>
        )
      }),
      columnHelper.accessor(row => row.sortOrder, {
        id: 'sortOrder',
        header: 'Sort Order',
        cell: ({ getValue }) => <Typography>{getValue() ?? 0}</Typography>
      }),
      columnHelper.accessor(row => row.isActive, {
        id: 'isActive',
        header: 'Active',
        cell: ({ getValue, row }) => (
          <Switch checked={!!getValue()} onChange={() => handleToggleStatus(row.original._id)} />
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
                setSelectedSpotlight(row.original)
                setMode('edit')
                setOpenDialog(true)
              }}
            >
              <i className='tabler-edit text-primary' />
            </IconButton>
            <IconButton onClick={() => handleOpenDeleteDialog(row.original)}>
              <i className='tabler-trash text-error' />
            </IconButton>
          </div>
        )
      })
    ],
    []
  )

  const table = useReactTable({
    data: items,
    columns,
    getCoreRowModel: getCoreRowModel()
  })

  const updateUrlPagination = (nextPage, nextPageSize) => {
    const params = new URLSearchParams(searchParams.toString())

    if (nextPage !== 1) {
      params.set('page', String(nextPage))
    } else {
      params.delete('page')
    }

    if (nextPageSize !== 10) {
      params.set('pageSize', String(nextPageSize))
    } else {
      params.delete('pageSize')
    }

    router.replace(`${pathname}?${params.toString()}`, { scroll: false })
  }

  const handleRowsPerPageChange = e => {
    const nextPageSize = parseInt(e.target.value, 10)

    dispatch(setPageSize(nextPageSize))
    dispatch(setPage(1))
    updateUrlPagination(1, nextPageSize)
  }

  const handlePageChange = nextPage => {
    dispatch(setPage(nextPage))
    updateUrlPagination(nextPage, searchParams.get('pageSize') ? parseInt(searchParams.get('pageSize'), 10) : pageSize)
  }

  return (
    <>
      <Box className='mb-3'>
        <Typography variant='h4'>User Growth Spotlight</Typography>
        <Typography variant='body2' color='text.secondary'>
          Upload and manage spotlight images shown exclusively on the User home page.
        </Typography>
      </Box>

      <Card>
        <div className='flex justify-between flex-col items-start md:flex-row md:items-center p-6 gap-4'>
          <CustomTextField
            select
            value={searchParams.get('pageSize') || 10}
            onChange={handleRowsPerPageChange}
            className='max-sm:is-full sm:is-[70px]'
          >
            <MenuItem value='2'>2</MenuItem>
            <MenuItem value='10'>10</MenuItem>
            <MenuItem value='25'>25</MenuItem>
            <MenuItem value='50'>50</MenuItem>
          </CustomTextField>

          <Button
            className='sm:w-auto w-full'
            variant='contained'
            onClick={() => {
              setMode('create')
              setSelectedSpotlight(null)
              setOpenDialog(true)
            }}
          >
            + Add User Spotlight
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
                <EmprtyTableRow limit={urlPageSize} data={items} columns={columns} noDataLebel='No user spotlight found' />
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

      <UserGrowthSpotlightDialog
        open={openDialog}
        onClose={() => setOpenDialog(false)}
        mode={mode}
        spotlight={selectedSpotlight}
      />

      <ConfirmationDialog
        open={confirmOpen}
        onClose={() => {
          setConfirmOpen(false)
          setMode('create')
        }}
        onConfirm={handleConfirm}
        type={confirmType}
        title={
          confirmType === 'delete-user-growth-spotlight'
            ? 'Are you sure you want to delete this user spotlight image?'
            : 'Are you sure you want to change active status?'
        }
        loading={loading}
      />
    </>
  )
}

export default UserGrowthSpotlight
