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
import TextField from '@mui/material/TextField'
import Switch from '@mui/material/Switch'
import FormControlLabel from '@mui/material/FormControlLabel'
import Tabs from '@mui/material/Tabs'
import Tab from '@mui/material/Tab'
import Chip from '@mui/material/Chip'
import CircularProgress from '@mui/material/CircularProgress'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'

import { fetchAuditLogs, fetchAlerts, updateAlert } from '@/redux-store/slices/serverManagement'

const ALERT_TYPES = [
  { type: 'high_cpu', label: 'High CPU Usage', description: 'Alert when CPU exceeds threshold' },
  { type: 'high_memory', label: 'High Memory Usage', description: 'Alert when RAM exceeds threshold' },
  { type: 'high_disk', label: 'High Disk Usage', description: 'Alert when disk usage exceeds threshold' },
  { type: 'server_offline', label: 'Server Offline', description: 'Alert when server is unreachable' },
  { type: 'service_stopped', label: 'Service Stopped', description: 'Alert when a critical service stops' },
  { type: 'backup_failed', label: 'Backup Failed', description: 'Alert when backup operation fails' },
  { type: 'low_storage', label: 'Low Storage', description: 'Alert when storage is critically low' }
]

export default function AlertsAudit() {
  const dispatch = useDispatch()
  const { auditLogs, auditTotal, alerts, loading } = useSelector(state => state.serverManagement)

  const [tab, setTab] = useState(0)
  const [page, setPage] = useState(1)
  const [editDialog, setEditDialog] = useState({ open: false, alert: null })
  const [threshold, setThreshold] = useState(80)

  useEffect(() => {
    dispatch(fetchAlerts())
    dispatch(fetchAuditLogs({ page, limit: 50 }))
  }, [dispatch, page])

  const handleEditAlert = (alert) => {
    setThreshold(alert.threshold || 80)
    setEditDialog({ open: true, alert })
  }

  const handleSaveAlert = () => {
    if (editDialog.alert) {
      dispatch(updateAlert({
        type: editDialog.alert.type,
        threshold,
        enabled: editDialog.alert.enabled
      }))
      setEditDialog({ open: false, alert: null })
    }
  }

  const handleToggleAlert = (alert) => {
    dispatch(updateAlert({
      type: alert.type,
      threshold: alert.threshold,
      enabled: !alert.enabled
    }))
  }

  const getAlertStatus = (type) => {
    const alert = alerts.find(a => a.type === type)
    return alert || { type, threshold: 80, enabled: false }
  }

  const actionColor = (action) => {
    if (action.includes('delete')) return 'error'
    if (action.includes('create') || action.includes('write') || action.includes('restart')) return 'success'
    if (action.includes('update') || action.includes('edit') || action.includes('rename')) return 'info'
    return 'default'
  }

  return (
    <Box sx={{ p: 4 }}>
      <Typography variant='h4' fontWeight='bold' sx={{ mb: 1 }}>Alerts & Audit Logs</Typography>
      <Typography variant='body2' color='text.secondary' sx={{ mb: 3 }}>
        Configure alerts and review administrative actions
      </Typography>

      <Tabs value={tab} onChange={(_, v) => setTab(v)} sx={{ mb: 3 }}>
        <Tab label='Alert Configuration' />
        <Tab label='Audit Logs' />
      </Tabs>

      {/* Alert Configuration */}
      {tab === 0 && (
        <Card>
          <CardContent>
            <Typography variant='h6' fontWeight='bold' sx={{ mb: 2 }}>
              <i className='tabler-bell' style={{ marginRight: 8 }} />
              Alert Thresholds
            </Typography>
            <TableContainer component={Paper} variant='outlined'>
              <Table size='small'>
                <TableHead>
                  <TableRow>
                    <TableCell>Alert Type</TableCell>
                    <TableCell>Description</TableCell>
                    <TableCell>Threshold</TableCell>
                    <TableCell>Enabled</TableCell>
                    <TableCell>Last Triggered</TableCell>
                    <TableCell>Actions</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {ALERT_TYPES.map(({ type, label, description }) => {
                    const alert = getAlertStatus(type)
                    return (
                      <TableRow key={type}>
                        <TableCell fontWeight='bold'>{label}</TableCell>
                        <TableCell>{description}</TableCell>
                        <TableCell>
                          {['high_cpu', 'high_memory', 'high_disk', 'low_storage'].includes(type)
                            ? `${alert.threshold}%`
                            : 'N/A'}
                        </TableCell>
                        <TableCell>
                          <Switch
                            checked={alert.enabled || false}
                            onChange={() => handleToggleAlert(alert)}
                            color='primary'
                          />
                        </TableCell>
                        <TableCell>
                          {alert.lastTriggeredAt
                            ? new Date(alert.lastTriggeredAt).toLocaleString()
                            : 'Never'}
                        </TableCell>
                        <TableCell>
                          {['high_cpu', 'high_memory', 'high_disk', 'low_storage'].includes(type) && (
                            <Button size='small' onClick={() => handleEditAlert(alert)}>
                              Configure
                            </Button>
                          )}
                        </TableCell>
                      </TableRow>
                    )
                  })}
                </TableBody>
              </Table>
            </TableContainer>
          </CardContent>
        </Card>
      )}

      {/* Audit Logs */}
      {tab === 1 && (
        <Card>
          <CardContent>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
              <Typography variant='h6' fontWeight='bold'>
                <i className='tabler-history' style={{ marginRight: 8 }} />
                Audit Logs ({auditTotal})
              </Typography>
              <Button onClick={() => dispatch(fetchAuditLogs({ page, limit: 50 }))}>
                <i className='tabler-refresh' />
              </Button>
            </Box>
            <TableContainer component={Paper} variant='outlined'>
              <Table size='small'>
                <TableHead>
                  <TableRow>
                    <TableCell>Time</TableCell>
                    <TableCell>Admin</TableCell>
                    <TableCell>Action</TableCell>
                    <TableCell>Category</TableCell>
                    <TableCell>Target</TableCell>
                    <TableCell>Result</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {auditLogs.map((log, i) => (
                    <TableRow key={i}>
                      <TableCell sx={{ whiteSpace: 'nowrap' }}>
                        {new Date(log.createdAt).toLocaleString()}
                      </TableCell>
                      <TableCell>{log.adminEmail || log.adminName}</TableCell>
                      <TableCell>
                        <Chip label={log.action} size='small' color={actionColor(log.action)} variant='outlined' />
                      </TableCell>
                      <TableCell>{log.category}</TableCell>
                      <TableCell sx={{ maxWidth: 250, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                        {log.target}
                      </TableCell>
                      <TableCell>
                        <Chip
                          label={log.result}
                          size='small'
                          color={log.result === 'success' ? 'success' : log.result === 'failure' ? 'error' : 'warning'}
                        />
                      </TableCell>
                    </TableRow>
                  ))}
                  {auditLogs.length === 0 && (
                    <TableRow>
                      <TableCell colSpan={6} align='center'>
                        {loading ? <CircularProgress size={24} /> : 'No audit logs yet'}
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </TableContainer>

            {auditTotal > 50 && (
              <Box sx={{ display: 'flex', justifyContent: 'center', mt: 2, gap: 1 }}>
                <Button disabled={page <= 1} onClick={() => setPage(p => p - 1)}>Previous</Button>
                <Typography variant='body2' sx={{ alignSelf: 'center' }}>Page {page}</Typography>
                <Button disabled={page * 50 >= auditTotal} onClick={() => setPage(p => p + 1)}>Next</Button>
              </Box>
            )}
          </CardContent>
        </Card>
      )}

      {/* Edit Threshold Dialog */}
      <Dialog open={editDialog.open} onClose={() => setEditDialog({ open: false, alert: null })}>
        <DialogTitle>Configure Alert Threshold</DialogTitle>
        <DialogContent>
          <Typography variant='body2' color='text.secondary' sx={{ mb: 2 }}>
            {editDialog.alert?.type && ALERT_TYPES.find(t => t.type === editDialog.alert.type)?.description}
          </Typography>
          <TextField
            autoFocus
            fullWidth
            type='number'
            label='Threshold (%)'
            value={threshold}
            onChange={(e) => setThreshold(Number(e.target.value))}
            inputProps={{ min: 1, max: 100 }}
            sx={{ mt: 1 }}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setEditDialog({ open: false, alert: null })}>Cancel</Button>
          <Button onClick={handleSaveAlert}>Save</Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
