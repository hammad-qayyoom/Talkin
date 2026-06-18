'use client'

import { useCallback, useEffect, useMemo, useState } from 'react'

import axios from 'axios'
import { toast } from 'react-toastify'

import Alert from '@mui/material/Alert'
import Autocomplete from '@mui/material/Autocomplete'
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Chip from '@mui/material/Chip'
import CircularProgress from '@mui/material/CircularProgress'
import Divider from '@mui/material/Divider'
import Grid from '@mui/material/Grid'
import LinearProgress from '@mui/material/LinearProgress'
import Table from '@mui/material/Table'
import TableBody from '@mui/material/TableBody'
import TableCell from '@mui/material/TableCell'
import TableContainer from '@mui/material/TableContainer'
import TableHead from '@mui/material/TableHead'
import TableRow from '@mui/material/TableRow'
import ToggleButton from '@mui/material/ToggleButton'
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup'
import Typography from '@mui/material/Typography'

import CustomTextField from '@/@core/components/mui/TextField'
import { baseURL } from '@/config'
import { getAuthHeaders } from '@/utils/auth-headers'

const EMAIL_DOMAIN = 'notisboard.com'
const MAX_SUBJECT_LENGTH = 180
const MAX_MESSAGE_LENGTH = 5000

const audienceOptions = [
  { value: 'custom', label: 'Custom' },
  { value: 'users', label: 'Users' },
  { value: 'experts', label: 'Experts' },
  { value: 'all', label: 'All' },
  { value: 'selected', label: 'Selected' }
]

const initialForm = {
  fromLocalPart: 'support@notisboard.com',
  fromName: 'Notisboard',
  replyTo: '',
  recipients: '',
  subject: '',
  message: ''
}

const isValidEmail = value => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(value || '').trim())

const normalizeRecipients = value => {
  const seen = new Set()
  const recipients = []
  const invalid = []

  String(value || '')
    .split(/[\n,;]+/g)
    .map(item => item.trim().toLowerCase())
    .filter(Boolean)
    .forEach(email => {
      if (!isValidEmail(email)) {
        invalid.push(email)

        return
      }

      if (!seen.has(email)) {
        seen.add(email)
        recipients.push(email)
      }
    })

  return { recipients, invalid }
}

const normalizeFromLocalPart = value => {
  let localPart = String(value || '').trim().toLowerCase()

  if (localPart.includes('@')) {
    const parts = localPart.split('@')
    const domain = parts.pop()

    if (parts.length !== 1 || domain !== EMAIL_DOMAIN) {
      return { localPart: '', error: `Sender must use ${EMAIL_DOMAIN}.` }
    }

    localPart = parts[0]
  }

  if (!localPart) return { localPart: '', error: 'Sender mailbox is required.' }
  if (localPart.length > 64) return { localPart: '', error: 'Sender mailbox is too long.' }
  if (localPart.includes('..')) return { localPart: '', error: 'Sender mailbox cannot contain consecutive dots.' }

  if (!/^[a-z0-9](?:[a-z0-9._+-]{0,62}[a-z0-9])?$/.test(localPart)) {
    return { localPart: '', error: 'Sender mailbox has invalid characters.' }
  }

  return { localPart, error: '' }
}

const formatDate = value => {
  if (!value) return '-'
  const date = new Date(value)

  if (Number.isNaN(date.getTime())) return '-'

  return date.toLocaleString('en-US', {
    month: 'short',
    day: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const statusColor = status => {
  if (status === 'sent') return 'success'
  if (status === 'skipped') return 'warning'

  return 'error'
}

const compactReason = item => {
  if (!item) return ''

  return item.reason || item.error || ''
}

const recipientLabel = option => {
  const name = option?.name || option?.email || ''
  const uniqueId = option?.uniqueId ? ` · ${option.uniqueId}` : ''

  return `${name}${option?.email && option.email !== name ? ` · ${option.email}` : ''}${uniqueId}`
}

const roleLabel = role => {
  if (role === 'expert') return 'Expert'
  if (role === 'user') return 'User'

  return 'Custom'
}

const EmailMarketing = () => {
  const [form, setForm] = useState(initialForm)
  const [audienceMode, setAudienceMode] = useState('custom')
  const [recipientDirectory, setRecipientDirectory] = useState({
    users: [],
    experts: [],
    counts: { users: 0, experts: 0, all: 0 },
    maxRecipients: null
  })
  const [directoryLoading, setDirectoryLoading] = useState(false)
  const [selectedUsers, setSelectedUsers] = useState([])
  const [selectedExperts, setSelectedExperts] = useState([])
  const [loading, setLoading] = useState(false)
  const [historyLoading, setHistoryLoading] = useState(false)
  const [history, setHistory] = useState([])
  const [result, setResult] = useState(null)

  const recipientState = useMemo(() => normalizeRecipients(form.recipients), [form.recipients])
  const senderState = useMemo(() => normalizeFromLocalPart(form.fromLocalPart), [form.fromLocalPart])
  const fromEmail = senderState.localPart ? `${senderState.localPart}@${EMAIL_DOMAIN}` : `@${EMAIL_DOMAIN}`
  const remainingSubject = MAX_SUBJECT_LENGTH - form.subject.length
  const remainingMessage = MAX_MESSAGE_LENGTH - form.message.length
  const recipientLimit =
    Number.isFinite(Number(recipientDirectory.maxRecipients)) && Number(recipientDirectory.maxRecipients) > 0
      ? Number(recipientDirectory.maxRecipients)
      : null
  const hasRecipientLimit = Boolean(recipientLimit)
  const selectedRecipientCount = useMemo(() => {
    const selected = new Set()

    selectedUsers.forEach(item => item?.email && selected.add(item.email.toLowerCase()))
    selectedExperts.forEach(item => item?.email && selected.add(item.email.toLowerCase()))

    return selected.size
  }, [selectedUsers, selectedExperts])

  const audienceRecipientCount = useMemo(() => {
    if (audienceMode === 'users') return recipientDirectory.counts.users || 0
    if (audienceMode === 'experts') return recipientDirectory.counts.experts || 0
    if (audienceMode === 'all') return recipientDirectory.counts.all || 0
    if (audienceMode === 'selected') return selectedRecipientCount

    return recipientState.recipients.length
  }, [audienceMode, recipientDirectory.counts, recipientState.recipients.length, selectedRecipientCount])

  const recipientError = audienceMode === 'custom' && recipientState.invalid.length > 0
  const recipientReady =
    audienceRecipientCount > 0 && !recipientError && (!hasRecipientLimit || audienceRecipientCount <= recipientLimit)

  const canSend =
    !loading &&
    recipientReady &&
    !senderState.error &&
    form.subject.trim().length > 0 &&
    form.message.trim().length > 0 &&
    remainingSubject >= 0 &&
    remainingMessage >= 0 &&
    (!form.replyTo.trim() || isValidEmail(form.replyTo.trim()))

  const updateForm = field => event => {
    setForm(current => ({ ...current, [field]: event.target.value }))
  }

  const fetchRecipients = useCallback(async () => {
    setDirectoryLoading(true)

    try {
      const response = await axios.get(`${baseURL}/api/admin/emailMarketing/recipients`, {
        headers: getAuthHeaders(),
        params: { limit: 5000 }
      })

      if (response.data?.status) {
        setRecipientDirectory({
          users: response.data.data?.users || [],
          experts: response.data.data?.experts || [],
          counts: response.data.counts || { users: 0, experts: 0, all: 0 },
          maxRecipients: response.data.maxRecipients || null
        })
      }
    } catch (error) {
      toast.error(error?.response?.data?.message || 'Failed to load recipients')
    } finally {
      setDirectoryLoading(false)
    }
  }, [])

  const fetchHistory = useCallback(async () => {
    setHistoryLoading(true)

    try {
      const response = await axios.get(`${baseURL}/api/admin/emailMarketing/history`, {
        headers: getAuthHeaders(),
        params: { start: 1, limit: 10 }
      })

      if (response.data?.status) {
        setHistory(response.data.data || [])
      }
    } catch (error) {
      toast.error(error?.response?.data?.message || 'Failed to load email history')
    } finally {
      setHistoryLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchHistory()
    fetchRecipients()
  }, [fetchHistory, fetchRecipients])

  const validateForm = () => {
    if (audienceMode === 'custom' && recipientState.invalid.length) {
      toast.error(`Invalid recipient: ${recipientState.invalid[0]}`)

      return false
    }

    if (!audienceRecipientCount) {
      toast.error('At least one recipient is required')

      return false
    }

    if (hasRecipientLimit && audienceRecipientCount > recipientLimit) {
      toast.error(`Maximum ${recipientLimit} recipients are allowed`)

      return false
    }

    if (senderState.error) {
      toast.error(senderState.error)

      return false
    }

    if (form.replyTo.trim() && !isValidEmail(form.replyTo.trim())) {
      toast.error('Reply-to email is invalid')

      return false
    }

    if (!form.subject.trim()) {
      toast.error('Subject is required')

      return false
    }

    if (!form.message.trim()) {
      toast.error('Message is required')

      return false
    }

    if (remainingSubject < 0 || remainingMessage < 0) {
      toast.error('Subject or message is too long')

      return false
    }

    return true
  }

  const handleSubmit = async event => {
    event.preventDefault()

    if (!validateForm()) return

    setLoading(true)
    setResult(null)

    try {
      const payload = {
        audienceMode,
        recipients: audienceMode === 'custom' ? recipientState.recipients : [],
        selectedUserIds: audienceMode === 'selected' ? selectedUsers.map(item => item.id) : [],
        selectedExpertIds: audienceMode === 'selected' ? selectedExperts.map(item => item.id) : [],
        fromLocalPart: senderState.localPart,
        fromName: form.fromName.trim() || 'Notisboard',
        replyTo: form.replyTo.trim(),
        subject: form.subject.trim(),
        message: form.message.trim()
      }

      const response = await axios.post(`${baseURL}/api/admin/emailMarketing/send`, payload, {
        headers: getAuthHeaders()
      })

      setResult(response.data)

      if (response.data?.status) {
        toast.success(response.data.message || 'Email sent successfully')
      } else {
        toast.error(response.data?.message || 'Email could not be sent')
      }

      fetchHistory()
    } catch (error) {
      const message = error?.response?.data?.message || 'Email could not be sent'

      setResult({ status: false, message })
      toast.error(message)
    } finally {
      setLoading(false)
    }
  }

  const handleReset = () => {
    setForm(initialForm)
    setAudienceMode('custom')
    setSelectedUsers([])
    setSelectedExperts([])
    setResult(null)
  }

  return (
    <Box className='container'>
      <Box className='flex justify-between items-center flex-wrap gap-4 mb-3'>
        <Box>
          <Typography variant='h4'>Email Marketing</Typography>
          <Typography variant='body2' color='text.secondary'>
            Send direct Notisboard emails from the admin console.
          </Typography>
        </Box>
        <Chip
          color={senderState.error ? 'error' : 'primary'}
          icon={<i className='tabler-mail' />}
          label={fromEmail}
          variant='tonal'
        />
      </Box>

      <Grid container spacing={6}>
        <Grid item size={{ xs: 12, lg: 8 }}>
          <Card>
            {loading ? <LinearProgress /> : null}
            <CardContent>
              <Box component='form' onSubmit={handleSubmit} className='flex flex-col gap-5'>
                <Grid container spacing={4}>
                  <Grid item size={{ xs: 12, md: 6 }}>
                    <CustomTextField
                      fullWidth
                      label='Sender email'
                      placeholder='support@notisboard.com'
                      value={form.fromLocalPart}
                      onChange={updateForm('fromLocalPart')}
                      error={Boolean(senderState.error)}
                      helperText={
                        senderState.error || `Use any ${EMAIL_DOMAIN} mailbox, e.g. support@${EMAIL_DOMAIN}.`
                      }
                    />
                  </Grid>
                  <Grid item size={{ xs: 12, md: 6 }}>
                    <CustomTextField
                      fullWidth
                      label='Sender name'
                      placeholder='Notisboard'
                      value={form.fromName}
                      onChange={updateForm('fromName')}
                    />
                  </Grid>
                </Grid>

                <CustomTextField
                  fullWidth
                  label='Reply-to'
                  placeholder='support@notisboard.com'
                  value={form.replyTo}
                  onChange={updateForm('replyTo')}
                  error={Boolean(form.replyTo.trim() && !isValidEmail(form.replyTo.trim()))}
                  helperText={form.replyTo.trim() && !isValidEmail(form.replyTo.trim()) ? 'Invalid email address' : ' '}
                />

                <Box className='flex flex-col gap-3'>
                  <Box className='flex items-center justify-between flex-wrap gap-3'>
                    <Typography variant='subtitle1'>Audience</Typography>
                    <Box className='flex flex-wrap gap-2'>
                      <Chip size='small' variant='tonal' color='info' label={`${recipientDirectory.counts.users || 0} users`} />
                      <Chip
                        size='small'
                        variant='tonal'
                        color='primary'
                        label={`${recipientDirectory.counts.experts || 0} experts`}
                      />
                      <Chip size='small' variant='tonal' color='secondary' label={`${recipientDirectory.counts.all || 0} all`} />
                    </Box>
                  </Box>

                  <ToggleButtonGroup
                    exclusive
                    value={audienceMode}
                    onChange={(_, value) => {
                      if (!value) return
                      setAudienceMode(value)
                      setResult(null)
                    }}
                    className='flex flex-wrap gap-2'
                  >
                    {audienceOptions.map(option => (
                      <ToggleButton key={option.value} value={option.value} className='px-4'>
                        {option.label}
                      </ToggleButton>
                    ))}
                  </ToggleButtonGroup>

                  {audienceMode === 'custom' ? (
                    <CustomTextField
                      fullWidth
                      multiline
                      minRows={3}
                      label='Custom recipients'
                      placeholder='user@example.com'
                      value={form.recipients}
                      onChange={updateForm('recipients')}
                      error={
                        recipientState.invalid.length > 0 ||
                        (hasRecipientLimit && recipientState.recipients.length > recipientLimit)
                      }
                      helperText={
                        recipientState.invalid.length
                          ? `Invalid: ${recipientState.invalid[0]}`
                          : hasRecipientLimit
                            ? `${recipientState.recipients.length}/${recipientLimit} recipients`
                            : `${recipientState.recipients.length} recipient${
                                recipientState.recipients.length === 1 ? '' : 's'
                              }`
                      }
                    />
                  ) : null}

                  {audienceMode === 'selected' ? (
                    <Grid container spacing={4}>
                      <Grid item size={{ xs: 12, md: 6 }}>
                        <Autocomplete
                          multiple
                          loading={directoryLoading}
                          options={recipientDirectory.users}
                          value={selectedUsers}
                          getOptionLabel={recipientLabel}
                          isOptionEqualToValue={(option, value) => option.id === value.id}
                          onChange={(_, value) => {
                            setSelectedUsers(value)
                            setResult(null)
                          }}
                          renderInput={params => (
                            <CustomTextField
                              {...params}
                              label='Select users'
                              placeholder='Search users'
                              helperText={`${selectedUsers.length}/${recipientDirectory.counts.users || 0} selected`}
                            />
                          )}
                        />
                      </Grid>
                      <Grid item size={{ xs: 12, md: 6 }}>
                        <Autocomplete
                          multiple
                          loading={directoryLoading}
                          options={recipientDirectory.experts}
                          value={selectedExperts}
                          getOptionLabel={recipientLabel}
                          isOptionEqualToValue={(option, value) => option.id === value.id}
                          onChange={(_, value) => {
                            setSelectedExperts(value)
                            setResult(null)
                          }}
                          renderInput={params => (
                            <CustomTextField
                              {...params}
                              label='Select experts'
                              placeholder='Search experts'
                              helperText={`${selectedExperts.length}/${recipientDirectory.counts.experts || 0} selected`}
                            />
                          )}
                        />
                      </Grid>
                    </Grid>
                  ) : null}

                  {audienceMode !== 'custom' && audienceMode !== 'selected' ? (
                    <Alert severity='info' variant='tonal'>
                      {audienceRecipientCount} recipient{audienceRecipientCount === 1 ? '' : 's'} selected.
                    </Alert>
                  ) : null}
                </Box>

                <CustomTextField
                  fullWidth
                  label='Subject'
                  placeholder='Your Notisboard update'
                  value={form.subject}
                  onChange={updateForm('subject')}
                  error={remainingSubject < 0}
                  helperText={`${Math.max(0, remainingSubject)} characters left`}
                />

                <CustomTextField
                  fullWidth
                  multiline
                  minRows={9}
                  label='Message'
                  placeholder='Write your message'
                  value={form.message}
                  onChange={updateForm('message')}
                  error={remainingMessage < 0}
                  helperText={`${Math.max(0, remainingMessage)} characters left`}
                />

                <Box className='flex flex-wrap gap-3 justify-end'>
                  <Button variant='tonal' color='secondary' type='button' onClick={handleReset} disabled={loading}>
                    Reset
                  </Button>
                  <Button
                    variant='contained'
                    type='submit'
                    disabled={!canSend}
                    startIcon={loading ? <CircularProgress color='inherit' size={18} /> : <i className='tabler-send' />}
                  >
                    Send Email
                  </Button>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item size={{ xs: 12, lg: 4 }}>
          <Card>
            <CardContent className='flex flex-col gap-4'>
              <Box>
                <Typography variant='h6'>Preview</Typography>
                <Typography variant='body2' color='text.secondary'>
                  {audienceRecipientCount || 0} recipient{audienceRecipientCount === 1 ? '' : 's'}
                </Typography>
              </Box>

              <Divider />

              <Box className='flex flex-col gap-3'>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Audience
                  </Typography>
                  <Typography variant='body2'>{audienceOptions.find(item => item.value === audienceMode)?.label || 'Custom'}</Typography>
                </Box>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    From
                  </Typography>
                  <Typography variant='body2'>{fromEmail}</Typography>
                </Box>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Subject
                  </Typography>
                  <Typography variant='body2'>{form.subject.trim() || '-'}</Typography>
                </Box>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Message
                  </Typography>
                  <Typography
                    variant='body2'
                    sx={{
                      whiteSpace: 'pre-wrap',
                      overflowWrap: 'anywhere',
                      maxBlockSize: 260,
                      overflow: 'auto'
                    }}
                  >
                    {form.message.trim() || '-'}
                  </Typography>
                </Box>
              </Box>

              {result ? (
                <Alert severity={result.status ? 'success' : 'error'} variant='tonal'>
                  {result.message}
                </Alert>
              ) : null}

              {result?.data?.results?.length ? (
                <Box className='flex flex-col gap-2'>
                  {result.data.results.map(item => (
                    <Box key={`${item.recipientEmail}-${item._id}`} className='flex items-start justify-between gap-3'>
                      <Box>
                        <Typography variant='body2' sx={{ overflowWrap: 'anywhere' }}>
                          {item.recipientEmail}
                        </Typography>
                        <Typography variant='caption' color='text.secondary'>
                          {roleLabel(item.recipientRole)}
                          {item.recipientName ? ` · ${item.recipientName}` : ''}
                        </Typography>
                        {compactReason(item) ? (
                          <Typography variant='caption' color='text.secondary' sx={{ overflowWrap: 'anywhere' }}>
                            {compactReason(item)}
                          </Typography>
                        ) : null}
                      </Box>
                      <Chip size='small' color={statusColor(item.status)} label={item.status} variant='tonal' />
                    </Box>
                  ))}
                </Box>
              ) : null}
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Card className='mt-6'>
        <CardContent>
          <Box className='flex items-center justify-between gap-4 mb-4'>
            <Box>
              <Typography variant='h6'>Recent Sends</Typography>
              <Typography variant='body2' color='text.secondary'>
                Latest email delivery attempts.
              </Typography>
            </Box>
            <Button
              variant='tonal'
              color='secondary'
              size='small'
              startIcon={historyLoading ? <CircularProgress color='inherit' size={16} /> : <i className='tabler-refresh' />}
              onClick={fetchHistory}
              disabled={historyLoading}
            >
              Refresh
            </Button>
          </Box>

          <TableContainer>
            <Table size='small'>
              <TableHead>
                <TableRow>
                  <TableCell>Recipient</TableCell>
                  <TableCell>Role</TableCell>
                  <TableCell>From</TableCell>
                  <TableCell>Subject</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Reason</TableCell>
                  <TableCell>Date</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {historyLoading && !history.length ? (
                  <TableRow>
                    <TableCell colSpan={7} align='center'>
                      <CircularProgress size={24} />
                    </TableCell>
                  </TableRow>
                ) : history.length ? (
                  history.map(item => (
                    <TableRow key={item._id}>
                      <TableCell sx={{ overflowWrap: 'anywhere' }}>
                        <Box>
                          <Typography variant='body2'>{item.recipientEmail}</Typography>
                          {item.recipientName ? (
                            <Typography variant='caption' color='text.secondary'>
                              {item.recipientName}
                            </Typography>
                          ) : null}
                        </Box>
                      </TableCell>
                      <TableCell>
                        <Chip size='small' color={item.recipientRole === 'expert' ? 'primary' : item.recipientRole === 'user' ? 'info' : 'secondary'} label={roleLabel(item.recipientRole)} variant='tonal' />
                      </TableCell>
                      <TableCell sx={{ overflowWrap: 'anywhere' }}>{item.fromEmail}</TableCell>
                      <TableCell sx={{ minInlineSize: 180 }}>{item.subject}</TableCell>
                      <TableCell>
                        <Chip size='small' color={statusColor(item.status)} label={item.status} variant='tonal' />
                      </TableCell>
                      <TableCell sx={{ maxInlineSize: 260, overflowWrap: 'anywhere' }}>
                        {compactReason(item) || '-'}
                      </TableCell>
                      <TableCell>{formatDate(item.createdAt)}</TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={7} align='center'>
                      No email history found
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

export default EmailMarketing
