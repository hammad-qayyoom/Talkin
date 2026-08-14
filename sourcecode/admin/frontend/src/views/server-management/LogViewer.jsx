'use client'

import { useEffect, useState } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Typography from '@mui/material/Typography'
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import TextField from '@mui/material/TextField'
import Tabs from '@mui/material/Tabs'
import Tab from '@mui/material/Tab'
import CircularProgress from '@mui/material/CircularProgress'
import MenuItem from '@mui/material/MenuItem'
import Select from '@mui/material/Select'
import InputLabel from '@mui/material/InputLabel'
import FormControl from '@mui/material/FormControl'

import { fetchLogs } from '@/redux-store/slices/serverManagement'

const LOG_TYPES = [
  { value: 'system', label: 'System Logs' },
  { value: 'nginx', label: 'Nginx Access' },
  { value: 'nginxError', label: 'Nginx Error' },
  { value: 'pm2', label: 'PM2 Logs' },
  { value: 'auth', label: 'Auth/SSH Logs' }
]

export default function LogViewer() {
  const dispatch = useDispatch()
  const { logs, logsType, loading } = useSelector(state => state.serverManagement)

  const [selectedType, setSelectedType] = useState('system')
  const [lineCount, setLineCount] = useState(100)
  const [searchFilter, setSearchFilter] = useState('')

  useEffect(() => {
    dispatch(fetchLogs({ type: selectedType, lines: lineCount }))
  }, [dispatch, selectedType, lineCount])

  const handleRefresh = () => {
    dispatch(fetchLogs({ type: selectedType, lines: lineCount }))
  }

  const filteredLogs = logs
    ? logs.split('\n').filter(line =>
        searchFilter ? line.toLowerCase().includes(searchFilter.toLowerCase()) : true
      ).join('\n')
    : ''

  return (
    <Box sx={{ p: 4 }}>
      <Typography variant='h4' fontWeight='bold' sx={{ mb: 1 }}>Server Logs</Typography>
      <Typography variant='body2' color='text.secondary' sx={{ mb: 3 }}>
        View and filter server log files
      </Typography>

      <Card>
        <CardContent>
          <Box sx={{ display: 'flex', gap: 2, mb: 3, alignItems: 'center', flexWrap: 'wrap' }}>
            <FormControl size='small' sx={{ minWidth: 180 }}>
              <InputLabel>Log Type</InputLabel>
              <Select
                value={selectedType}
                label='Log Type'
                onChange={(e) => setSelectedType(e.target.value)}
              >
                {LOG_TYPES.map(t => (
                  <MenuItem key={t.value} value={t.value}>{t.label}</MenuItem>
                ))}
              </Select>
            </FormControl>

            <FormControl size='small' sx={{ minWidth: 120 }}>
              <InputLabel>Lines</InputLabel>
              <Select
                value={lineCount}
                label='Lines'
                onChange={(e) => setLineCount(e.target.value)}
              >
                <MenuItem value={50}>50</MenuItem>
                <MenuItem value={100}>100</MenuItem>
                <MenuItem value={200}>200</MenuItem>
                <MenuItem value={500}>500</MenuItem>
              </Select>
            </FormControl>

            <TextField
              size='small'
              placeholder='Filter logs...'
              value={searchFilter}
              onChange={(e) => setSearchFilter(e.target.value)}
              sx={{ minWidth: 250 }}
            />

            <Button variant='outlined' onClick={handleRefresh} disabled={loading}>
              <i className='tabler-refresh' style={{ marginRight: 4 }} /> Refresh
            </Button>
          </Box>

          {loading ? (
            <Box sx={{ display: 'flex', justifyContent: 'center', py: 5 }}>
              <CircularProgress />
            </Box>
          ) : (
            <Box
              component='pre'
              sx={{
                p: 2,
                bgcolor: 'grey.900',
                color: 'grey.100',
                borderRadius: 1,
                overflow: 'auto',
                maxHeight: 600,
                fontSize: 12,
                fontFamily: '"Fira Code", "Cascadia Code", Consolas, monospace',
                whiteSpace: 'pre-wrap',
                wordBreak: 'break-all',
                lineHeight: 1.6
              }}
            >
              {filteredLogs || 'No logs available'}
            </Box>
          )}
        </CardContent>
      </Card>
    </Box>
  )
}
