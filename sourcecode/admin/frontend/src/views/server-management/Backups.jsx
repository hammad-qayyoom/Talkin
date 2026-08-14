'use client'

import { useEffect } from 'react'
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
import Chip from '@mui/material/Chip'
import Alert from '@mui/material/Alert'
import LinearProgress from '@mui/material/LinearProgress'

import { fetchDisk } from '@/redux-store/slices/serverManagement'

export default function Backups() {
  const dispatch = useDispatch()
  const { disk, loading } = useSelector(state => state.serverManagement)

  useEffect(() => {
    dispatch(fetchDisk())
  }, [dispatch])

  const formatBytes = (bytes) => {
    if (!bytes || bytes === 0) return '0 B'
    const k = 1024
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${sizes[i]}`
  }

  return (
    <Box sx={{ p: 4 }}>
      <Typography variant='h4' fontWeight='bold' sx={{ mb: 1 }}>Backups & Storage</Typography>
      <Typography variant='body2' color='text.secondary' sx={{ mb: 3 }}>
        View disk partitions and storage information
      </Typography>

      <Alert severity='info' sx={{ mb: 3 }}>
        Backup management connects to your server via SSH. Backup files are stored on the server.
      </Alert>

      {/* Disk Partitions */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant='h6' fontWeight='bold' sx={{ mb: 2 }}>
            <i className='tabler-device-hard-drive' style={{ marginRight: 8 }} />
            Disk Partitions
          </Typography>
          <TableContainer component={Paper} variant='outlined'>
            <Table size='small'>
              <TableHead>
                <TableRow>
                  <TableCell>Device</TableCell>
                  <TableCell>Mount Point</TableCell>
                  <TableCell>Filesystem</TableCell>
                  <TableCell>Total</TableCell>
                  <TableCell>Used</TableCell>
                  <TableCell>Available</TableCell>
                  <TableCell>Usage</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {disk?.disks?.map((d, i) => (
                  <TableRow key={i}>
                    <TableCell>{d.device}</TableCell>
                    <TableCell>{d.mount}</TableCell>
                    <TableCell>{d.fstype}</TableCell>
                    <TableCell>{formatBytes(d.total)}</TableCell>
                    <TableCell>{formatBytes(d.used)}</TableCell>
                    <TableCell>{formatBytes(d.available)}</TableCell>
                    <TableCell sx={{ minWidth: 200 }}>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <LinearProgress
                          variant='determinate'
                          value={d.percent}
                          color={d.percent > 90 ? 'error' : d.percent > 70 ? 'warning' : 'primary'}
                          sx={{ flex: 1, height: 8, borderRadius: 4 }}
                        />
                        <Typography variant='body2' fontWeight='bold' sx={{ minWidth: 40 }}>
                          {d.percent}%
                        </Typography>
                      </Box>
                    </TableCell>
                  </TableRow>
                ))}
                {(!disk?.disks || disk.disks.length === 0) && (
                  <TableRow>
                    <TableCell colSpan={7} align='center'>
                      {loading ? 'Loading...' : 'No disk information available'}
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </CardContent>
      </Card>

      {/* Large Directories */}
      <Card>
        <CardContent>
          <Typography variant='h6' fontWeight='bold' sx={{ mb: 2 }}>
            <i className='tabler-folder' style={{ marginRight: 8 }} />
            Large Directories (Root Level)
          </Typography>
          <TableContainer component={Paper} variant='outlined'>
            <Table size='small'>
              <TableHead>
                <TableRow>
                  <TableCell>Directory</TableCell>
                  <TableCell>Size</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {disk?.largeDirs?.map((dir, i) => (
                  <TableRow key={i}>
                    <TableCell>{dir.path}</TableCell>
                    <TableCell>
                      <Chip label={dir.size} size='small' color='info' variant='outlined' />
                    </TableCell>
                  </TableRow>
                ))}
                {(!disk?.largeDirs || disk.largeDirs.length === 0) && (
                  <TableRow>
                    <TableCell colSpan={2} align='center'>
                      {loading ? 'Loading...' : 'No directory size information available'}
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </CardContent>
      </Card>
    </Box>
  )
}
