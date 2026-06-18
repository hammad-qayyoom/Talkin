'use client'

import { useCallback, useEffect, useMemo, useState } from 'react'

import axios from 'axios'
import { toast } from 'react-toastify'

import Alert from '@mui/material/Alert'
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Chip from '@mui/material/Chip'
import CircularProgress from '@mui/material/CircularProgress'
import Dialog from '@mui/material/Dialog'
import DialogActions from '@mui/material/DialogActions'
import DialogContent from '@mui/material/DialogContent'
import DialogTitle from '@mui/material/DialogTitle'
import Grid from '@mui/material/Grid'
import IconButton from '@mui/material/IconButton'
import LinearProgress from '@mui/material/LinearProgress'
import Stack from '@mui/material/Stack'
import Table from '@mui/material/Table'
import TableBody from '@mui/material/TableBody'
import TableCell from '@mui/material/TableCell'
import TableContainer from '@mui/material/TableContainer'
import TableHead from '@mui/material/TableHead'
import TableRow from '@mui/material/TableRow'
import Tooltip from '@mui/material/Tooltip'
import Typography from '@mui/material/Typography'

import CustomTextField from '@/@core/components/mui/TextField'
import { baseURL } from '@/config'
import { getAuthHeaders } from '@/utils/auth-headers'

const initialOverview = {
  baseDomain: 'notisboard.com',
  serverIp: '31.97.148.27',
  domains: [],
  selectedDomain: 'notisboard.com',
  webmailUrl: 'https://admin.notisboard.com/webmail/',
  accounts: [],
  dnsRecords: []
}

const generatePassword = (length = 18) => {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%+-_'
  const randomValues =
    typeof window !== 'undefined' && window.crypto?.getRandomValues
      ? window.crypto.getRandomValues(new Uint32Array(length))
      : Array.from({ length }, () => Math.floor(Math.random() * chars.length))

  return Array.from(randomValues, value => chars[value % chars.length]).join('')
}

const copyText = async (value, label = 'Copied') => {
  const text = String(value || '')

  if (!text) return

  try {
    await navigator.clipboard.writeText(text)
    toast.success(label)
  } catch (_) {
    toast.error('Copy failed')
  }
}

const recordText = record =>
  [record.type, record.name, record.priority ? `priority ${record.priority}` : '', record.value]
    .filter(Boolean)
    .join(' | ')

const EmailAccounts = () => {
  const [overview, setOverview] = useState(initialOverview)
  const [accountForm, setAccountForm] = useState({ account: '', password: generatePassword(), quotaMb: 1024 })
  const [loading, setLoading] = useState(true)
  const [actionLoading, setActionLoading] = useState(false)
  const [lastCredential, setLastCredential] = useState(null)
  const [passwordDialog, setPasswordDialog] = useState({ open: false, account: null, password: generatePassword() })

  const domain = overview.baseDomain || 'notisboard.com'
  const webmailUrl = overview.webmailUrl || 'https://admin.notisboard.com/webmail/'
  const domainDetails = useMemo(() => overview.domains.find(item => item.domain === domain), [overview.domains, domain])
  const domainReady = Boolean(domainDetails)
  const canCreateAccount = Boolean(domainReady && accountForm.account.trim() && accountForm.password.trim().length >= 8)

  const fetchOverview = useCallback(async () => {
    setLoading(true)

    try {
      const response = await axios.get(`${baseURL}/api/admin/emailAccounts/overview`, {
        headers: getAuthHeaders(),
        params: { domain: 'notisboard.com' }
      })

      if (response.data?.status) {
        setOverview(response.data.data || initialOverview)
      } else {
        toast.error(response.data?.message || 'Failed to load email accounts')
      }
    } catch (error) {
      toast.error(error?.response?.data?.message || 'Failed to load email accounts')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchOverview()
  }, [fetchOverview])

  const handleEnableDomain = async () => {
    setActionLoading(true)

    try {
      const response = await axios.post(
        `${baseURL}/api/admin/emailAccounts/domains`,
        { domain },
        { headers: getAuthHeaders() }
      )

      if (response.data?.status) {
        toast.success(response.data.message || `${domain} mailboxes enabled`)
        await fetchOverview()
      } else {
        toast.error(response.data?.message || `${domain} could not be enabled`)
      }
    } catch (error) {
      toast.error(error?.response?.data?.message || `${domain} could not be enabled`)
    } finally {
      setActionLoading(false)
    }
  }

  const handleCreateAccount = async event => {
    event.preventDefault()

    if (!canCreateAccount) {
      toast.error('Mailbox name and password are required')

      return
    }

    setActionLoading(true)

    try {
      const payload = {
        domain,
        account: accountForm.account.trim(),
        password: accountForm.password.trim(),
        quotaMb: Number(accountForm.quotaMb) || 1024
      }
      const response = await axios.post(`${baseURL}/api/admin/emailAccounts/accounts`, payload, {
        headers: getAuthHeaders()
      })

      if (response.data?.status) {
        const created = response.data.data

        setLastCredential({
          email: created?.email || `${payload.account}@${domain}`,
          password: payload.password,
          webmailUrl: created?.webmailUrl || webmailUrl,
          imapHost: created?.imapHost || `mail.${domain}`,
          smtpHost: created?.smtpHost || `mail.${domain}`
        })
        toast.success(response.data.message || 'Mailbox created')
        setAccountForm({ account: '', password: generatePassword(), quotaMb: payload.quotaMb })
        await fetchOverview()
      } else {
        toast.error(response.data?.message || 'Mailbox could not be created')
      }
    } catch (error) {
      toast.error(error?.response?.data?.message || 'Mailbox could not be created')
    } finally {
      setActionLoading(false)
    }
  }

  const handleDeleteAccount = async account => {
    if (!account) return
    if (!window.confirm(`Delete ${account.email}?`)) return

    setActionLoading(true)

    try {
      const response = await axios.delete(`${baseURL}/api/admin/emailAccounts/accounts`, {
        headers: getAuthHeaders(),
        data: { domain, account: account.account }
      })

      if (response.data?.status) {
        toast.success(response.data.message || 'Mailbox deleted')
        await fetchOverview()
      } else {
        toast.error(response.data?.message || 'Mailbox could not be deleted')
      }
    } catch (error) {
      toast.error(error?.response?.data?.message || 'Mailbox could not be deleted')
    } finally {
      setActionLoading(false)
    }
  }

  const handleChangePassword = async () => {
    if (!passwordDialog.account || passwordDialog.password.trim().length < 8) {
      toast.error('Password must be at least 8 characters')

      return
    }

    setActionLoading(true)

    try {
      const response = await axios.patch(
        `${baseURL}/api/admin/emailAccounts/accounts/password`,
        {
          domain,
          account: passwordDialog.account.account,
          password: passwordDialog.password.trim()
        },
        { headers: getAuthHeaders() }
      )

      if (response.data?.status) {
        setLastCredential({
          email: passwordDialog.account.email,
          password: passwordDialog.password.trim(),
          webmailUrl,
          imapHost: `mail.${domain}`,
          smtpHost: `mail.${domain}`
        })
        toast.success(response.data.message || 'Password updated')
        setPasswordDialog({ open: false, account: null, password: generatePassword() })
      } else {
        toast.error(response.data?.message || 'Password could not be updated')
      }
    } catch (error) {
      toast.error(error?.response?.data?.message || 'Password could not be updated')
    } finally {
      setActionLoading(false)
    }
  }

  return (
    <Box className='container'>
      <Box className='flex justify-between items-center flex-wrap gap-4 mb-3'>
        <Box>
          <Typography variant='h4'>Email Accounts</Typography>
          <Typography variant='body2' color='text.secondary'>
            Create mailboxes on @{domain}.
          </Typography>
        </Box>
        <Box className='flex items-center gap-2 flex-wrap'>
          <Chip color='primary' variant='tonal' icon={<i className='tabler-mail' />} label={`@${domain}`} />
          <Chip color='secondary' variant='tonal' icon={<i className='tabler-server' />} label={overview.serverIp} />
          <Button
            variant='tonal'
            color='secondary'
            startIcon={<i className='tabler-refresh' />}
            onClick={fetchOverview}
            disabled={loading || actionLoading}
          >
            Refresh
          </Button>
        </Box>
      </Box>

      {loading ? <LinearProgress className='mb-4' /> : null}

      <Grid container spacing={6}>
        <Grid item size={{ xs: 12, lg: 4 }}>
          <Card>
            {actionLoading ? <LinearProgress /> : null}
            <CardContent>
              <Typography variant='h5' className='mb-1'>
                Domain
              </Typography>
              <Typography variant='h3' className='mb-3'>
                {domain}
              </Typography>

              <Stack direction='row' flexWrap='wrap' gap={2} className='mb-4'>
                <Chip
                  size='small'
                  variant='tonal'
                  color={domainReady ? 'success' : 'warning'}
                  label={domainReady ? 'enabled' : 'not enabled'}
                />
                <Chip
                  size='small'
                  variant='tonal'
                  color='info'
                  label={`${domainDetails?.accounts || 0} mailboxes`}
                />
                <Chip
                  size='small'
                  variant='tonal'
                  color={domainDetails?.dkim ? 'primary' : 'warning'}
                  label={domainDetails?.dkim ? 'DKIM on' : 'DKIM pending'}
                />
              </Stack>

              {!domainReady ? (
                <Alert severity='warning' className='mb-4'>
                  Enable {domain} before creating support@{domain}, no-reply@{domain}, or other mailboxes.
                </Alert>
              ) : null}

              <Box className='flex flex-wrap gap-2'>
                <Button
                  variant={domainReady ? 'outlined' : 'contained'}
                  color='primary'
                  startIcon={<i className={domainReady ? 'tabler-check' : 'tabler-plus'} />}
                  onClick={handleEnableDomain}
                  disabled={actionLoading}
                >
                  {domainReady ? 'Domain Enabled' : 'Enable Mailboxes'}
                </Button>
                <Button
                  variant='outlined'
                  color='primary'
                  startIcon={<i className='tabler-inbox' />}
                  onClick={() => window.open(webmailUrl, '_blank', 'noopener,noreferrer')}
                >
                  Webmail
                </Button>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item size={{ xs: 12, lg: 8 }}>
          <Card>
            {actionLoading ? <LinearProgress /> : null}
            <CardContent>
              <Box className='flex justify-between items-center flex-wrap gap-3 mb-4'>
                <Box>
                  <Typography variant='h5'>Mailboxes</Typography>
                  <Typography variant='body2' color='text.secondary'>
                    support@{domain}, no-reply@{domain}, info@{domain}
                  </Typography>
                </Box>
                <Chip color='primary' variant='tonal' icon={<i className='tabler-mail-cog' />} label={`mail.${domain}`} />
              </Box>

              <Box component='form' onSubmit={handleCreateAccount} className='flex flex-col gap-4'>
                <Grid container spacing={4}>
                  <Grid item size={{ xs: 12, md: 4 }}>
                    <CustomTextField
                      fullWidth
                      label='Mailbox name'
                      placeholder='support'
                      value={accountForm.account}
                      onChange={event => setAccountForm(current => ({ ...current, account: event.target.value }))}
                      helperText={
                        accountForm.account.trim()
                          ? `${accountForm.account.trim().toLowerCase()}@${domain}`
                          : `name@${domain}`
                      }
                      disabled={!domainReady}
                    />
                  </Grid>
                  <Grid item size={{ xs: 12, md: 4 }}>
                    <CustomTextField
                      fullWidth
                      label='Password'
                      value={accountForm.password}
                      onChange={event => setAccountForm(current => ({ ...current, password: event.target.value }))}
                      helperText='Minimum 8 characters.'
                      disabled={!domainReady}
                    />
                  </Grid>
                  <Grid item size={{ xs: 12, md: 2 }}>
                    <CustomTextField
                      fullWidth
                      type='number'
                      label='Quota MB'
                      value={accountForm.quotaMb}
                      onChange={event => setAccountForm(current => ({ ...current, quotaMb: event.target.value }))}
                      disabled={!domainReady}
                    />
                  </Grid>
                  <Grid item size={{ xs: 12, md: 2 }} className='flex items-end gap-2'>
                    <Tooltip title='Generate password'>
                      <span>
                        <IconButton
                          color='secondary'
                          disabled={!domainReady}
                          onClick={() => setAccountForm(current => ({ ...current, password: generatePassword() }))}
                        >
                          <i className='tabler-key' />
                        </IconButton>
                      </span>
                    </Tooltip>
                    <Button type='submit' variant='contained' disabled={!canCreateAccount || actionLoading}>
                      Create
                    </Button>
                  </Grid>
                </Grid>
              </Box>

              {lastCredential ? (
                <Alert severity='success' className='mt-4'>
                  <Box className='flex flex-col gap-1'>
                    <Typography variant='body2'>
                      {lastCredential.email} password: {lastCredential.password}
                    </Typography>
                    <Typography variant='caption'>
                      IMAP/SMTP: {lastCredential.imapHost} | Webmail: {lastCredential.webmailUrl}
                    </Typography>
                  </Box>
                </Alert>
              ) : null}

              <TableContainer className='mt-5'>
                <Table>
                  <TableHead>
                    <TableRow>
                      <TableCell>Email</TableCell>
                      <TableCell>Quota</TableCell>
                      <TableCell>Disk</TableCell>
                      <TableCell>Status</TableCell>
                      <TableCell align='right'>Actions</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {overview.accounts.length ? (
                      overview.accounts.map(account => (
                        <TableRow key={account.email}>
                          <TableCell>
                            <Box className='flex items-center gap-2'>
                              <Typography variant='body2'>{account.email}</Typography>
                              <Tooltip title='Copy email'>
                                <IconButton size='small' onClick={() => copyText(account.email, 'Email copied')}>
                                  <i className='tabler-copy' />
                                </IconButton>
                              </Tooltip>
                            </Box>
                          </TableCell>
                          <TableCell>{account.quota || '-'}</TableCell>
                          <TableCell>{account.disk || 0}</TableCell>
                          <TableCell>
                            <Chip
                              size='small'
                              color={account.suspended ? 'warning' : 'success'}
                              variant='tonal'
                              label={account.suspended ? 'suspended' : 'active'}
                            />
                          </TableCell>
                          <TableCell align='right'>
                            <Tooltip title='Open webmail'>
                              <IconButton
                                onClick={() => window.open(account.webmailUrl, '_blank', 'noopener,noreferrer')}
                              >
                                <i className='tabler-inbox' />
                              </IconButton>
                            </Tooltip>
                            <Tooltip title='Reset password'>
                              <IconButton
                                onClick={() =>
                                  setPasswordDialog({ open: true, account, password: generatePassword() })
                                }
                              >
                                <i className='tabler-key' />
                              </IconButton>
                            </Tooltip>
                            <Tooltip title='Delete mailbox'>
                              <IconButton color='error' onClick={() => handleDeleteAccount(account)}>
                                <i className='tabler-trash' />
                              </IconButton>
                            </Tooltip>
                          </TableCell>
                        </TableRow>
                      ))
                    ) : (
                      <TableRow>
                        <TableCell colSpan={5} align='center'>
                          {domainReady ? 'No mailboxes yet.' : `Enable ${domain} mailboxes first.`}
                        </TableCell>
                      </TableRow>
                    )}
                  </TableBody>
                </Table>
              </TableContainer>
            </CardContent>
          </Card>
        </Grid>

        <Grid item size={{ xs: 12 }}>
          <Card>
            <CardContent>
              <Box className='flex justify-between items-center flex-wrap gap-3 mb-4'>
                <Box>
                  <Typography variant='h5'>DNS Records</Typography>
                  <Typography variant='body2' color='text.secondary'>
                    Add these records before receiving mail on @{domain}.
                  </Typography>
                </Box>
                <Button
                  variant='tonal'
                  color='secondary'
                  startIcon={<i className='tabler-copy' />}
                  disabled={!overview.dnsRecords.length}
                  onClick={() =>
                    copyText(
                      overview.dnsRecords.map(recordText).join('\n'),
                      'DNS records copied'
                    )
                  }
                >
                  Copy All
                </Button>
              </Box>

              <TableContainer>
                <Table>
                  <TableHead>
                    <TableRow>
                      <TableCell>Type</TableCell>
                      <TableCell>Name</TableCell>
                      <TableCell>Priority</TableCell>
                      <TableCell>Value</TableCell>
                      <TableCell align='right'>Copy</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {overview.dnsRecords.length ? (
                      overview.dnsRecords.map((record, index) => (
                        <TableRow key={`${record.type}-${record.name}-${index}`}>
                          <TableCell>
                            <Chip size='small' variant='tonal' color='primary' label={record.type} />
                          </TableCell>
                          <TableCell sx={{ minWidth: 220 }}>{record.name}</TableCell>
                          <TableCell>{record.priority || '-'}</TableCell>
                          <TableCell sx={{ wordBreak: 'break-word', maxWidth: 720 }}>{record.value}</TableCell>
                          <TableCell align='right'>
                            <Tooltip title='Copy record'>
                              <IconButton onClick={() => copyText(recordText(record), 'Record copied')}>
                                <i className='tabler-copy' />
                              </IconButton>
                            </Tooltip>
                          </TableCell>
                        </TableRow>
                      ))
                    ) : (
                      <TableRow>
                        <TableCell colSpan={5} align='center'>
                          DNS records will appear after refresh.
                        </TableCell>
                      </TableRow>
                    )}
                  </TableBody>
                </Table>
              </TableContainer>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Dialog
        open={passwordDialog.open}
        onClose={() => setPasswordDialog({ open: false, account: null, password: generatePassword() })}
        fullWidth
        maxWidth='sm'
      >
        <DialogTitle>Reset Mailbox Password</DialogTitle>
        <DialogContent className='flex flex-col gap-4 pt-2'>
          <Typography variant='body2' color='text.secondary'>
            {passwordDialog.account?.email || ''}
          </Typography>
          <CustomTextField
            fullWidth
            label='New password'
            value={passwordDialog.password}
            onChange={event => setPasswordDialog(current => ({ ...current, password: event.target.value }))}
          />
          <Button
            variant='tonal'
            color='secondary'
            startIcon={<i className='tabler-key' />}
            onClick={() => setPasswordDialog(current => ({ ...current, password: generatePassword() }))}
          >
            Generate Password
          </Button>
        </DialogContent>
        <DialogActions>
          <Button
            variant='tonal'
            color='secondary'
            onClick={() => setPasswordDialog({ open: false, account: null, password: generatePassword() })}
          >
            Cancel
          </Button>
          <Button
            variant='contained'
            onClick={handleChangePassword}
            disabled={actionLoading || passwordDialog.password.trim().length < 8}
            startIcon={actionLoading ? <CircularProgress size={16} color='inherit' /> : <i className='tabler-check' />}
          >
            Save
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}

export default EmailAccounts
