'use client'

import { useEffect, useState } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Typography from '@mui/material/Typography'
import Box from '@mui/material/Box'
import Table from '@mui/material/Table'
import TableBody from '@mui/material/TableBody'
import TableCell from '@mui/material/TableCell'
import TableContainer from '@mui/material/TableContainer'
import TableHead from '@mui/material/TableHead'
import TableRow from '@mui/material/TableRow'
import Paper from '@mui/material/Paper'
import Button from '@mui/material/Button'
import Chip from '@mui/material/Chip'
import Tabs from '@mui/material/Tabs'
import Tab from '@mui/material/Tab'
import CircularProgress from '@mui/material/CircularProgress'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'
import DialogContentText from '@mui/material/DialogContentText'
import Alert from '@mui/material/Alert'
import IconButton from '@mui/material/IconButton'

import {
  fetchProcesses, fetchServices, controlService,
  fetchPm2, pm2Action
} from '@/redux-store/slices/serverManagement'

export default function Processes() {
  const dispatch = useDispatch()
  const { processes, services, pm2Processes, loading } = useSelector(state => state.serverManagement)

  const [tab, setTab] = useState(0)
  const [actionDialog, setActionDialog] = useState({ open: false, service: null, action: null })
  const [pm2Dialog, setPm2Dialog] = useState({ open: false, name: null, action: null })

  useEffect(() => {
    dispatch(fetchProcesses())
    dispatch(fetchServices())
    dispatch(fetchPm2())
  }, [dispatch])

  const handleServiceAction = (service, action) => {
    setActionDialog({ open: true, service, action })
  }

  const confirmServiceAction = () => {
    dispatch(controlService({ service: actionDialog.service, action: actionDialog.action }))
    setActionDialog({ open: false, service: null, action: null })
    setTimeout(() => dispatch(fetchServices()), 2000)
  }

  const handlePm2Action = (name, action) => {
    setPm2Dialog({ open: true, name, action })
  }

  const confirmPm2Action = () => {
    dispatch(pm2Action({ name: pm2Dialog.name, action: pm2Dialog.action }))
    setPm2Dialog({ open: false, name: null, action: null })
    setTimeout(() => dispatch(fetchPm2()), 2000)
  }

  const serviceStatusColor = (status) => {
    switch (status) {
      case 'active': return 'success'
      case 'inactive': return 'warning'
      case 'failed': return 'error'
      default: return 'default'
    }
  }

  return (
    <Box sx={{ p: 4 }}>
      <Typography variant='h4' fontWeight='bold' sx={{ mb: 1 }}>Processes & Services</Typography>
      <Typography variant='body2' color='text.secondary' sx={{ mb: 3 }}>
        Monitor and manage server processes and services
      </Typography>

      <Tabs value={tab} onChange={(_, v) => setTab(v)} sx={{ mb: 3 }}>
        <Tab label='System Processes' />
        <Tab label='Services' />
        <Tab label='PM2 Processes' />
      </Tabs>

      {/* System Processes */}
      {tab === 0 && (
        <Card>
          <CardContent>
            <Typography variant='h6' fontWeight='bold' sx={{ mb: 2 }}>
              Running Processes (Top CPU)
            </Typography>
            <TableContainer component={Paper} variant='outlined'>
              <Table size='small'>
                <TableHead>
                  <TableRow>
                    <TableCell>User</TableCell>
                    <TableCell>PID</TableCell>
                    <TableCell>CPU %</TableCell>
                    <TableCell>MEM %</TableCell>
                    <TableCell>Command</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {processes.map((proc, i) => (
                    <TableRow key={i}>
                      <TableCell>{proc.user}</TableCell>
                      <TableCell>{proc.pid}</TableCell>
                      <TableCell>
                        <Chip
                          label={`${proc.cpu}%`}
                          size='small'
                          color={parseFloat(proc.cpu) > 50 ? 'error' : parseFloat(proc.cpu) > 20 ? 'warning' : 'default'}
                        />
                      </TableCell>
                      <TableCell>{proc.mem}%</TableCell>
                      <TableCell sx={{ maxWidth: 400, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                        {proc.command}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </CardContent>
        </Card>
      )}

      {/* Services */}
      {tab === 1 && (
        <Card>
          <CardContent>
            <Typography variant='h6' fontWeight='bold' sx={{ mb: 2 }}>
              Server Services
            </Typography>
            {services && (
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                {Object.entries(services).map(([name, status]) => (
                  <Box key={name} sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', p: 2, border: '1px solid', borderColor: 'divider', borderRadius: 1 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                      <Typography variant='subtitle1' fontWeight='bold' sx={{ textTransform: 'capitalize' }}>
                        {name}
                      </Typography>
                      <Chip label={status} size='small' color={serviceStatusColor(status)} />
                    </Box>
                    <Box sx={{ display: 'flex', gap: 1 }}>
                      {name !== 'mongodb' || status !== 'not-installed' ? (
                        <>
                          <Button size='small' variant='outlined' onClick={() => handleServiceAction(name, 'restart')}>Restart</Button>
                          <Button size='small' variant='outlined' color='warning' onClick={() => handleServiceAction(name, 'stop')}>Stop</Button>
                          <Button size='small' variant='outlined' color='success' onClick={() => handleServiceAction(name, 'start')}>Start</Button>
                        </>
                      ) : null}
                    </Box>
                  </Box>
                ))}
              </Box>
            )}
          </CardContent>
        </Card>
      )}

      {/* PM2 Processes */}
      {tab === 2 && (
        <Card>
          <CardContent>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
              <Typography variant='h6' fontWeight='bold'>PM2 Processes</Typography>
              <IconButton onClick={() => dispatch(fetchPm2())}>
                <i className='tabler-refresh' />
              </IconButton>
            </Box>
            <TableContainer component={Paper} variant='outlined'>
              <Table size='small'>
                <TableHead>
                  <TableRow>
                    <TableCell>Name</TableCell>
                    <TableCell>Mode</TableCell>
                    <TableCell>PID</TableCell>
                    <TableCell>Status</TableCell>
                    <TableCell>CPU</TableCell>
                    <TableCell>Memory</TableCell>
                    <TableCell>Actions</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {pm2Processes.map((proc, i) => (
                    <TableRow key={i}>
                      <TableCell fontWeight='bold'>{proc.name}</TableCell>
                      <TableCell>{proc.pm2_env?.exec_mode || 'N/A'}</TableCell>
                      <TableCell>{proc.pid}</TableCell>
                      <TableCell>
                        <Chip
                          label={proc.pm2_env?.status || 'unknown'}
                          size='small'
                          color={proc.pm2_env?.status === 'online' ? 'success' : 'error'}
                        />
                      </TableCell>
                      <TableCell>{proc.monit?.cpu || 0}%</TableCell>
                      <TableCell>{formatMem(proc.monit?.memory || 0)}</TableCell>
                      <TableCell>
                        <Box sx={{ display: 'flex', gap: 0.5 }}>
                          <Button size='small' onClick={() => handlePm2Action(proc.name, 'restart')}>Restart</Button>
                          <Button size='small' color='warning' onClick={() => handlePm2Action(proc.name, 'stop')}>Stop</Button>
                          <Button size='small' color='success' onClick={() => handlePm2Action(proc.name, 'start')}>Start</Button>
                        </Box>
                      </TableCell>
                    </TableRow>
                  ))}
                  {pm2Processes.length === 0 && (
                    <TableRow>
                      <TableCell colSpan={7} align='center'>
                        {loading ? <CircularProgress size={24} /> : 'No PM2 processes found'}
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </TableContainer>
          </CardContent>
        </Card>
      )}

      {/* Service Action Dialog */}
      <Dialog open={actionDialog.open} onClose={() => setActionDialog({ open: false, service: null, action: null })}>
        <DialogTitle>Confirm {actionDialog.action}</DialogTitle>
        <DialogContent>
          <DialogContentText>
            Are you sure you want to {actionDialog.action} the <strong>{actionDialog.service}</strong> service?
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setActionDialog({ open: false, service: null, action: null })}>Cancel</Button>
          <Button color={actionDialog.action === 'stop' ? 'warning' : 'primary'} onClick={confirmServiceAction}>
            {actionDialog.action}
          </Button>
        </DialogActions>
      </Dialog>

      {/* PM2 Action Dialog */}
      <Dialog open={pm2Dialog.open} onClose={() => setPm2Dialog({ open: false, name: null, action: null })}>
        <DialogTitle>Confirm PM2 {pm2Dialog.action}</DialogTitle>
        <DialogContent>
          <DialogContentText>
            Are you sure you want to {pm2Dialog.action} the <strong>{pm2Dialog.name}</strong> process?
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setPm2Dialog({ open: false, name: null, action: null })}>Cancel</Button>
          <Button onClick={confirmPm2Action}>{pm2Dialog.action}</Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}

function formatMem(bytes) {
  if (!bytes) return '0 B'
  const mb = bytes / (1024 * 1024)
  return `${mb.toFixed(1)} MB`
}
