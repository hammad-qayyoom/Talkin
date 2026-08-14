'use client'

import { useEffect, useState, useCallback } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import Grid from '@mui/material/Grid'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Typography from '@mui/material/Typography'
import Box from '@mui/material/Box'
import CircularProgress from '@mui/material/CircularProgress'
import Button from '@mui/material/Button'
import Chip from '@mui/material/Chip'
import IconButton from '@mui/material/IconButton'
import Alert from '@mui/material/Alert'
import LinearProgress from '@mui/material/LinearProgress'
import Divider from '@mui/material/Divider'

import { fetchOverview, testConnection } from '@/redux-store/slices/serverManagement'

const statusColor = (status) => {
  switch (status) {
    case 'healthy': return 'success'
    case 'warning': return 'warning'
    case 'critical': return 'error'
    default: return 'error'
  }
}

const UsageCard = ({ title, value, icon, color, subtitle }) => (
  <Card sx={{ height: '100%' }}>
    <CardContent>
      <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
        <Typography variant='body2' color='text.secondary'>{title}</Typography>
        <Box sx={{ color: `${color}.main` }}>{icon}</Box>
      </Box>
      <Typography variant='h4' fontWeight='bold' sx={{ color: `${color}.main` }}>
        {typeof value === 'number' ? `${value.toFixed(1)}%` : value || 'N/A'}
      </Typography>
      {subtitle && <Typography variant='body2' color='text.secondary' sx={{ mt: 1 }}>{subtitle}</Typography>}
      {typeof value === 'number' && (
        <LinearProgress
          variant='determinate'
          value={Math.min(value, 100)}
          color={value > 90 ? 'error' : value > 70 ? 'warning' : 'primary'}
          sx={{ mt: 2, height: 6, borderRadius: 3 }}
        />
      )}
    </CardContent>
  </Card>
)

const InfoRow = ({ label, value }) => (
  <Box sx={{ display: 'flex', justifyContent: 'space-between', py: 1 }}>
    <Typography variant='body2' color='text.secondary'>{label}</Typography>
    <Typography variant='body2' fontWeight={500}>{value || 'N/A'}</Typography>
  </Box>
)

export default function ServerOverview() {
  const dispatch = useDispatch()
  const { overview, overviewLoading, connected, connecting } = useSelector(state => state.serverManagement)
  const [autoRefresh, setAutoRefresh] = useState(false)

  const load = useCallback(() => {
    dispatch(fetchOverview())
  }, [dispatch])

  useEffect(() => {
    dispatch(testConnection())
    load()
  }, [dispatch, load])

  useEffect(() => {
    if (!autoRefresh) return
    const interval = setInterval(load, 15000)
    return () => clearInterval(interval)
  }, [autoRefresh, load])

  const cpuUsage = overview?.cpuUsage || 0
  const memPercent = overview?.memory?.percent || 0
  const rootDisk = overview?.disks?.find(d => d.mount === '/')
  const diskPercent = rootDisk?.percent || 0

  return (
    <Box sx={{ p: 4 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Box>
          <Typography variant='h4' fontWeight='bold'>Server Management</Typography>
          <Typography variant='body2' color='text.secondary' sx={{ mt: 0.5 }}>
            Monitor and manage your server infrastructure
          </Typography>
        </Box>
        <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
          <Chip
            label={connected ? 'Connected' : 'Disconnected'}
            color={connected ? 'success' : 'error'}
            variant='outlined'
            size='small'
          />
          <Button
            variant={autoRefresh ? 'contained' : 'outlined'}
            onClick={() => setAutoRefresh(!autoRefresh)}
            size='small'
          >
            {autoRefresh ? 'Auto-Refresh ON' : 'Auto-Refresh OFF'}
          </Button>
          <IconButton onClick={load} disabled={overviewLoading}>
            <i className='tabler-refresh' />
          </IconButton>
        </Box>
      </Box>

      {!connected && !connecting && (
        <Alert severity='error' sx={{ mb: 4 }}>
          Cannot connect to server. Please check SSH credentials and server status.
        </Alert>
      )}

      {overviewLoading && !overview ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', py: 10 }}>
          <CircularProgress />
        </Box>
      ) : overview ? (
        <>
          {/* Health Status */}
          <Card sx={{ mb: 4 }}>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                <Box
                  sx={{
                    width: 12, height: 12, borderRadius: '50%',
                    bgcolor: overview.health?.status === 'healthy' ? 'success.main' :
                             overview.health?.status === 'warning' ? 'warning.main' : 'error.main'
                  }}
                />
                <Typography variant='h6' fontWeight='bold'>
                  Server Health: {overview.health?.status?.toUpperCase() || 'UNKNOWN'}
                </Typography>
              </Box>
              {overview.health?.issues?.length > 0 && (
                <Box sx={{ mt: 2 }}>
                  {overview.health.issues.map((issue, i) => (
                    <Alert key={i} severity={issue.level === 'critical' ? 'error' : 'warning'} sx={{ mb: 1 }}>
                      {issue.message}
                    </Alert>
                  ))}
                </Box>
              )}
            </CardContent>
          </Card>

          {/* Usage Cards */}
          <Grid container spacing={3} sx={{ mb: 4 }}>
            <Grid item xs={12} sm={6} md={3}>
              <UsageCard
                title='CPU Usage'
                value={cpuUsage}
                color='primary'
                icon={<i className='tabler-cpu' style={{ fontSize: 24 }} />}
                subtitle={`${overview.cpuCores || 'N/A'} cores`}
              />
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <UsageCard
                title='Memory Usage'
                value={memPercent}
                color='warning'
                icon={<i className='tabler-device-desktop-memory' style={{ fontSize: 24 }} />}
                subtitle={overview.memory ? `${formatBytes(overview.memory.used)} / ${formatBytes(overview.memory.total)}` : 'N/A'}
              />
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <UsageCard
                title='Disk Usage'
                value={diskPercent}
                color='info'
                icon={<i className='tabler-device-hard-drive' style={{ fontSize: 24 }} />}
                subtitle={rootDisk ? `${formatBytes(rootDisk.used)} / ${formatBytes(rootDisk.total)}` : 'N/A'}
              />
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <UsageCard
                title='Load Average'
                value={overview.loadAverage?.one || 0}
                color='secondary'
                icon={<i className='tabler-gauge' style={{ fontSize: 24 }} />}
                subtitle={`${overview.loadAverage?.one || 0} / ${overview.loadAverage?.five || 0} / ${overview.loadAverage?.fifteen || 0}`}
              />
            </Grid>
          </Grid>

          {/* Server Info */}
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Card sx={{ height: '100%' }}>
                <CardContent>
                  <Typography variant='h6' fontWeight='bold' sx={{ mb: 2 }}>
                    <i className='tabler-server' style={{ marginRight: 8 }} />
                    Server Information
                  </Typography>
                  <Divider sx={{ mb: 2 }} />
                  <InfoRow label='Hostname' value={overview.hostname} />
                  <InfoRow label='IP Address' value={overview.publicIP} />
                  <InfoRow label='Operating System' value={overview.os} />
                  <InfoRow label='Kernel' value={overview.kernel} />
                  <InfoRow label='Uptime' value={overview.uptime} />
                  <InfoRow label='Timezone' value={overview.timezone} />
                  <InfoRow label='Current Time' value={overview.currentTime} />
                  <InfoRow label='CPU Model' value={overview.cpuModel} />
                  <InfoRow label='CPU Cores' value={overview.cpuCores} />
                  <InfoRow label='Processes' value={overview.processCount} />
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} md={6}>
              <Card sx={{ height: '100%' }}>
                <CardContent>
                  <Typography variant='h6' fontWeight='bold' sx={{ mb: 2 }}>
                    <i className='tabler-device-desktop' style={{ marginRight: 8 }} />
                    Resource Details
                  </Typography>
                  <Divider sx={{ mb: 2 }} />
                  {overview.memory && (
                    <>
                      <Typography variant='subtitle2' color='text.secondary' sx={{ mb: 1 }}>Memory</Typography>
                      <InfoRow label='Total' value={formatBytes(overview.memory.total)} />
                      <InfoRow label='Used' value={formatBytes(overview.memory.used)} />
                      <InfoRow label='Available' value={formatBytes(overview.memory.available)} />
                      <InfoRow label='Free' value={formatBytes(overview.memory.free)} />
                      <Divider sx={{ my: 2 }} />
                    </>
                  )}
                  {overview.disks?.map((disk, i) => (
                    <Box key={i} sx={{ mb: 2 }}>
                      <Typography variant='subtitle2' color='text.secondary' sx={{ mb: 1 }}>
                        Disk: {disk.mount} ({disk.device})
                      </Typography>
                      <InfoRow label='Total' value={formatBytes(disk.total)} />
                      <InfoRow label='Used' value={formatBytes(disk.used)} />
                      <InfoRow label='Available' value={formatBytes(disk.available)} />
                      <InfoRow label='Filesystem' value={disk.fstype} />
                      <LinearProgress
                        variant='determinate'
                        value={disk.percent}
                        color={disk.percent > 90 ? 'error' : disk.percent > 70 ? 'warning' : 'primary'}
                        sx={{ mt: 1, height: 6, borderRadius: 3 }}
                      />
                    </Box>
                  ))}
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </>
      ) : null}
    </Box>
  )
}

function formatBytes(bytes) {
  if (!bytes || bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${sizes[i]}`
}
