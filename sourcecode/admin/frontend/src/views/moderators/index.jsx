'use client'

import { useEffect, useMemo, useState } from 'react'

import axios from 'axios'

import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import Chip from '@mui/material/Chip'
import Dialog from '@mui/material/Dialog'
import DialogActions from '@mui/material/DialogActions'
import DialogContent from '@mui/material/DialogContent'
import DialogTitle from '@mui/material/DialogTitle'
import Divider from '@mui/material/Divider'
import FormControlLabel from '@mui/material/FormControlLabel'
import Grid from '@mui/material/Grid'
import IconButton from '@mui/material/IconButton'
import Stack from '@mui/material/Stack'
import Switch from '@mui/material/Switch'
import Table from '@mui/material/Table'
import TableBody from '@mui/material/TableBody'
import TableCell from '@mui/material/TableCell'
import TableHead from '@mui/material/TableHead'
import TableRow from '@mui/material/TableRow'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'
import { toast } from 'react-toastify'

import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import { baseURL, secretKey } from '@/config'
import { DEFAULT_MODERATOR_PERMISSIONS, MODERATOR_SECTIONS, normalizeModeratorPermissions } from '@/config/moderatorPermissions'

const emptyForm = () => ({
  _id: '',
  name: '',
  email: '',
  password: '',
  isActive: true,
  permissions: { ...DEFAULT_MODERATOR_PERMISSIONS }
})

const getAuthHeaders = () => {
  if (typeof window === 'undefined') return {}

  return {
    'Content-Type': 'application/json',
    key: secretKey,
    Authorization: `Bearer ${localStorage.getItem('admin_token') || ''}`,
    'x-admin-uid': localStorage.getItem('uid') || ''
  }
}

const ModeratorAccessRow = ({ label, permissions, onToggle, group }) => {
  return (
    <div className='rounded-lg border border-solid border-divider p-4'>
      <div className='flex items-start justify-between gap-3'>
        <div>
          <Typography variant='subtitle1' className='font-medium'>
            {label}
          </Typography>
          <Typography variant='body2' color='text.secondary'>
            {group}
          </Typography>
        </div>
        <Switch checked={permissions} onChange={onToggle} />
      </div>
    </div>
  )
}

const ModeratorManagement = () => {
  const [loading, setLoading] = useState(true)
  const [moderators, setModerators] = useState([])
  const [formOpen, setFormOpen] = useState(false)
  const [saving, setSaving] = useState(false)
  const [form, setForm] = useState(emptyForm())
  const [deleteTarget, setDeleteTarget] = useState(null)

  const loadModerators = async () => {
    setLoading(true)

    try {
      const response = await axios.get(`${baseURL}/api/admin/moderator/list`, {
        headers: getAuthHeaders()
      })

      if (response?.data?.status) {
        setModerators(response.data.data || [])
      } else {
        setModerators([])
        toast.error(response?.data?.message || 'Unable to load moderators.')
      }
    } catch (error) {
      setModerators([])
      toast.error(error?.response?.data?.message || 'Failed to load moderators.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadModerators()
  }, [])

  const openCreate = () => {
    setForm(emptyForm())
    setFormOpen(true)
  }

  const openEdit = moderator => {
    setForm({
      _id: moderator._id,
      name: moderator.name || '',
      email: moderator.email || '',
      password: '',
      isActive: moderator.isActive !== false,
      permissions: normalizeModeratorPermissions(moderator.permissions)
    })
    setFormOpen(true)
  }

  const closeForm = () => {
    setFormOpen(false)
    setSaving(false)
  }

  const handleSubmit = async () => {
    if (!form.name.trim() || !form.email.trim()) {
      toast.error('Name and email are required.')

      return
    }

    if (!form._id && !form.password.trim()) {
      toast.error('Password is required for new moderators.')

      return
    }

    setSaving(true)

    try {
      const payload = {
        name: form.name.trim(),
        email: form.email.trim(),
        permissions: form.permissions,
        isActive: form.isActive
      }

      if (form.password.trim()) {
        payload.password = form.password.trim()
      }

      const response = form._id
        ? await axios.patch(`${baseURL}/api/admin/moderator/${form._id}`, payload, { headers: getAuthHeaders() })
        : await axios.post(`${baseURL}/api/admin/moderator/create`, payload, { headers: getAuthHeaders() })

      if (response?.data?.status) {
        toast.success(response.data.message || 'Saved successfully.')
        setFormOpen(false)
        await loadModerators()
      } else {
        toast.error(response?.data?.message || 'Unable to save moderator.')
      }
    } catch (error) {
      toast.error(error?.response?.data?.message || 'Failed to save moderator.')
    } finally {
      setSaving(false)
    }
  }

  const handleDelete = async () => {
    if (!deleteTarget) return

    try {
      const response = await axios.delete(`${baseURL}/api/admin/moderator/${deleteTarget._id}`, {
        headers: getAuthHeaders()
      })

      if (response?.data?.status) {
        toast.success(response.data.message || 'Moderator deleted.')
        setDeleteTarget(null)
        await loadModerators()
      } else {
        toast.error(response?.data?.message || 'Unable to delete moderator.')
      }
    } catch (error) {
      toast.error(error?.response?.data?.message || 'Failed to delete moderator.')
    }
  }

  const groupedSections = useMemo(() => {
    return MODERATOR_SECTIONS.reduce((groups, section) => {
      if (!groups[section.group]) {
        groups[section.group] = []
      }

      groups[section.group].push(section)

      return groups
    }, {})

  }, [])

  return (
    <Box>
      <div className='flex items-center justify-between gap-3 mb-6'>
        <div>
          <Typography variant='h4'>Moderators</Typography>
          <Typography variant='body2' color='text.secondary'>
            Create moderator accounts and grant access one section at a time.
          </Typography>
        </div>
        <Button variant='contained' onClick={openCreate} startIcon={<i className='tabler-plus' />}>
          Create Moderator
        </Button>
      </div>

      <Card className='p-4'>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell>Email</TableCell>
              <TableCell>Status</TableCell>
              <TableCell>Permissions</TableCell>
              <TableCell align='right'>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {loading ? (
              <TableRow>
                <TableCell colSpan={5}>
                  <Typography variant='body2'>Loading moderators...</Typography>
                </TableCell>
              </TableRow>
            ) : moderators.length === 0 ? (
              <TableRow>
                <TableCell colSpan={5}>
                  <Typography variant='body2' color='text.secondary'>
                    No moderators created yet.
                  </Typography>
                </TableCell>
              </TableRow>
            ) : (
              moderators.map(moderator => (
                <TableRow key={moderator._id}>
                  <TableCell>{moderator.name}</TableCell>
                  <TableCell>{moderator.email}</TableCell>
                  <TableCell>
                    <Chip
                      label={moderator.isActive === false ? 'Disabled' : 'Active'}
                      color={moderator.isActive === false ? 'default' : 'success'}
                      size='small'
                    />
                  </TableCell>
                  <TableCell>
                    <Typography variant='body2' color='text.secondary'>
                      {Object.entries(normalizeModeratorPermissions(moderator.permissions))
                        .filter(([, value]) => value)
                        .map(([key]) => key)
                        .join(', ') || 'No access granted'}
                    </Typography>
                  </TableCell>
                  <TableCell align='right'>
                    <Stack direction='row' spacing={1} justifyContent='flex-end'>
                      <IconButton onClick={() => openEdit(moderator)}>
                        <i className='tabler-pencil' />
                      </IconButton>
                      <IconButton onClick={() => setDeleteTarget(moderator)}>
                        <i className='tabler-trash' />
                      </IconButton>
                    </Stack>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </Card>

      <Dialog open={formOpen} onClose={closeForm} maxWidth='md' fullWidth>
        <DialogTitle>{form._id ? 'Edit Moderator' : 'Create Moderator'}</DialogTitle>
        <DialogContent dividers>
          <Grid container spacing={4} className='pt-2'>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                label='Name'
                value={form.name}
                onChange={event => setForm(prev => ({ ...prev, name: event.target.value }))}
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                label='Email'
                type='email'
                value={form.email}
                onChange={event => setForm(prev => ({ ...prev, email: event.target.value }))}
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                label={form._id ? 'New Password (optional)' : 'Password'}
                type='password'
                value={form.password}
                onChange={event => setForm(prev => ({ ...prev, password: event.target.value }))}
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <FormControlLabel
                control={
                  <Switch checked={form.isActive} onChange={event => setForm(prev => ({ ...prev, isActive: event.target.checked }))} />
                }
                label='Account active'
              />
            </Grid>
            <Grid item xs={12}>
              <Divider className='my-2' />
              <Typography variant='h6' className='mb-4'>
                Permissions
              </Typography>
              <Grid container spacing={3}>
                {Object.entries(groupedSections).map(([group, sections]) => (
                  <Grid item xs={12} md={6} key={group}>
                    <div className='mb-3'>
                      <Typography variant='subtitle2' color='text.secondary' className='mb-2'>
                        {group}
                      </Typography>
                      <Stack spacing={2}>
                        {sections.map(section => (
                          <ModeratorAccessRow
                            key={section.key}
                            label={section.label}
                            group={section.group}
                            permissions={Boolean(form.permissions?.[section.key])}
                            onToggle={event =>
                              setForm(prev => ({
                                ...prev,
                                permissions: {
                                  ...prev.permissions,
                                  [section.key]: event.target.checked
                                }
                              }))
                            }
                          />
                        ))}
                      </Stack>
                    </div>
                  </Grid>
                ))}
              </Grid>
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={closeForm}>Cancel</Button>
          <Button variant='contained' onClick={handleSubmit} disabled={saving} startIcon={<i className='tabler-device-floppy' />}>
            {saving ? 'Saving...' : 'Save'}
          </Button>
        </DialogActions>
      </Dialog>

      <ConfirmationDialog
        open={Boolean(deleteTarget)}
        title='Delete moderator?'
        content={`This will remove ${deleteTarget?.name || 'the moderator'} and their Firebase login.`}
        onClose={() => setDeleteTarget(null)}
        onConfirm={handleDelete}
      />
    </Box>
  )
}

export default ModeratorManagement
