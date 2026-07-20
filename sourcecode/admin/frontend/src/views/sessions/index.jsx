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
import Tabs from '@mui/material/Tabs'
import Tab from '@mui/material/Tab'

import CustomTextField from '@/@core/components/mui/TextField'
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import { baseURL } from '@/config'
import { getAuthHeaders } from '@/utils/auth-headers'

const statusOptions = [
  { value: 'all', label: 'All' },
  { value: 'scheduled', label: 'Scheduled' },
  { value: 'live', label: 'Live' },
  { value: 'completed', label: 'Completed' },
  { value: 'canceled', label: 'Canceled' }
]

const consultationModeOptions = [
  { value: 'all', label: 'All Modes' },
  { value: 'online', label: 'Online' },
  { value: 'in_person', label: 'In-Person' }
]

const formatDateTime = value => {
  if (!value) {
    return '-'
  }

  const parsed = new Date(value)

  if (Number.isNaN(parsed.getTime())) {
    return '-'
  }

  return parsed.toLocaleString('en-US', {
    year: 'numeric',
    month: 'short',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const SessionsView = () => {
  const [status, setStatus] = useState('all')
  const [consultationMode, setConsultationMode] = useState('all')
  const [loading, setLoading] = useState(false)
  const [sessions, setSessions] = useState([])
  const [confirmOpen, setConfirmOpen] = useState(false)
  const [selectedSession, setSelectedSession] = useState(null)
  const [cancelLoading, setCancelLoading] = useState(false)

  const fetchSessions = useCallback(async () => {
    try {
      setLoading(true)

      const response = await axios.get(`${baseURL}/api/admin/session/list`, {
        headers: getAuthHeaders(),
        params: {
          includeGroup: true,
          start: 1,
          limit: 200,
          status,
          ...(consultationMode !== 'all' && { consultationMode })
        }
      })

      setSessions(response?.data?.data || [])
    } catch (error) {
      console.error('Failed to fetch sessions:', error)
      setSessions([])
    } finally {
      setLoading(false)
    }
  }, [status, consultationMode])

  useEffect(() => {
    fetchSessions()
  }, [fetchSessions])

  const rows = useMemo(() => sessions || [], [sessions])

  const handleCancelSession = async () => {
    if (!selectedSession?._id) return

    try {
      setCancelLoading(true)

      await axios.post(
        `${baseURL}/api/admin/session/cancel`,
        {
          sessionId: selectedSession._id,
          cancelReason: 'Canceled by admin dashboard.'
        },
        {
          headers: getAuthHeaders()
        }
      )

      setConfirmOpen(false)
      setSelectedSession(null)
      fetchSessions()
    } catch (error) {
      console.error('Failed to cancel session:', error)
    } finally {
      setCancelLoading(false)
    }
  }

  return (
    <>
      <Box className='mb-3'>
        <Typography variant='h4'>Sessions</Typography>
        <Typography variant='body2' color='text.secondary'>
          Monitor one-to-one and group sessions, and cancel scheduled sessions when required.
        </Typography>
      </Box>

      <Card>
        <Box sx={{ borderBottom: 1, borderColor: 'divider', px: 6, pt: 2 }}>
          <Tabs
            value={consultationMode}
            onChange={(event, newValue) => setConsultationMode(newValue)}
            aria-label='consultation mode tabs'
          >
            {consultationModeOptions.map(option => (
              <Tab key={option.value} label={option.label} value={option.value} />
            ))}
          </Tabs>
        </Box>

        <Stack direction='row' justifyContent='space-between' alignItems='center' className='p-6 pt-4'>
          <Stack direction='row' spacing={2}>
            <CustomTextField select value={status} onChange={event => setStatus(event.target.value)} className='w-[180px]'>
              {statusOptions.map(option => (
                <MenuItem key={option.value} value={option.value}>
                  {option.label}
                </MenuItem>
              ))}
            </CustomTextField>
          </Stack>
          <Button variant='outlined' onClick={fetchSessions}>
            Refresh
          </Button>
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
                  <TableCell>Title</TableCell>
                  <TableCell>Mode</TableCell>
                  <TableCell>Type</TableCell>
                  <TableCell>Call Type</TableCell>
                  <TableCell>User</TableCell>
                  <TableCell>Total Talk</TableCell>
                  <TableCell>Start</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Expert</TableCell>
                  <TableCell>Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {rows.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={10} align='center'>
                      No sessions found.
                    </TableCell>
                  </TableRow>
                ) : (
                  rows.map(session => {
                    const canCancel = ['scheduled', 'live'].includes(String(session?.sessionStatus || '').toLowerCase())

                    return (
                      <TableRow key={session._id}>
                        <TableCell>{session?.title || '-'}</TableCell>
                        <TableCell>
                          <Chip
                            label={session?.consultationMode === 'in_person' ? 'In-Person' : 'Online'}
                            color={session?.consultationMode === 'in_person' ? 'secondary' : 'primary'}
                            size='small'
                            variant='outlined'
                          />
                        </TableCell>
                        <TableCell>{session?.sessionType || '-'}</TableCell>
                        <TableCell>{session?.consultationMode === 'in_person' ? 'N/A' : (session?.callType || '-')}</TableCell>
                        <TableCell>{session?.participantUserName || '-'}</TableCell>
                        <TableCell>{session?.totalTalkDurationLabel || '0m 0s'}</TableCell>
                        <TableCell>{formatDateTime(session?.startAt)}</TableCell>
                        <TableCell>{session?.sessionStatus || session?.status || '-'}</TableCell>
                        <TableCell>{session?.expertId?.displayName || '-'}</TableCell>
                        <TableCell>
                          <Button
                            variant='outlined'
                            color='error'
                            size='small'
                            disabled={!canCancel}
                            onClick={() => {
                              setSelectedSession(session)
                              setConfirmOpen(true)
                            }}
                          >
                            Cancel
                          </Button>
                        </TableCell>
                      </TableRow>
                    )
                  })
                )}
              </TableBody>
            </Table>
          </TableContainer>
        )}
      </Card>

      <ConfirmationDialog
        open={confirmOpen}
        setOpen={setConfirmOpen}
        title='Cancel selected session?'
        content='This action will cancel the session for all participants and run applicable refunds.'
        onConfirm={handleCancelSession}
        loading={cancelLoading}
        onClose={() => {
          setConfirmOpen(false)
          setSelectedSession(null)
        }}
      />
    </>
  )
}

export default SessionsView
