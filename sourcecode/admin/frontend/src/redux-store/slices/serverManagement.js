'use client'

import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'
import { baseURL, secretKey } from '@/config'

const getAuthHeaders = () => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('admin_token')
    const uid = localStorage.getItem('uid')
    return {
      'Content-Type': 'application/json',
      key: secretKey,
      Authorization: `Bearer ${token}`,
      'x-admin-uid': uid
    }
  }
  return {}
}

const api = axios.create({
  baseURL: `${baseURL}/api/admin/server-management`,
  headers: getAuthHeaders()
})

api.interceptors.request.use((config) => {
  config.headers = { ...config.headers, ...getAuthHeaders() }
  return config
})

// Thunks
export const testConnection = createAsyncThunk('serverManagement/testConnection', async (_, thunkAPI) => {
  try {
    const res = await api.get('/test-connection')
    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || 'Connection failed')
  }
})

export const fetchOverview = createAsyncThunk('serverManagement/fetchOverview', async (_, thunkAPI) => {
  try {
    const res = await api.get('/overview')
    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || 'Failed to fetch overview')
  }
})

export const fetchCpu = createAsyncThunk('serverManagement/fetchCpu', async (_, thunkAPI) => {
  try {
    const res = await api.get('/cpu')
    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || 'Failed to fetch CPU')
  }
})

export const fetchMemory = createAsyncThunk('serverManagement/fetchMemory', async (_, thunkAPI) => {
  try {
    const res = await api.get('/memory')
    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || 'Failed to fetch memory')
  }
})

export const fetchDisk = createAsyncThunk('serverManagement/fetchDisk', async (_, thunkAPI) => {
  try {
    const res = await api.get('/disk')
    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || 'Failed to fetch disk')
  }
})

export const fetchNetwork = createAsyncThunk('serverManagement/fetchNetwork', async (_, thunkAPI) => {
  try {
    const res = await api.get('/network')
    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || 'Failed to fetch network')
  }
})

export const fetchProcesses = createAsyncThunk('serverManagement/fetchProcesses', async (_, thunkAPI) => {
  try {
    const res = await api.get('/processes')
    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || 'Failed to fetch processes')
  }
})

export const fetchServices = createAsyncThunk('serverManagement/fetchServices', async (_, thunkAPI) => {
  try {
    const res = await api.get('/services')
    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || 'Failed to fetch services')
  }
})

export const controlService = createAsyncThunk('serverManagement/controlService', async ({ service, action }, thunkAPI) => {
  try {
    const res = await api.post('/services/control', { service, action })
    toast.success(`Service ${action} successful`)
    return res.data
  } catch (err) {
    toast.error(err.response?.data?.message || 'Service control failed')
    return thunkAPI.rejectWithValue(err.response?.data?.message)
  }
})

export const fetchLogs = createAsyncThunk('serverManagement/fetchLogs', async ({ type = 'system', lines = 100 }, thunkAPI) => {
  try {
    const res = await api.get('/logs', { params: { type, lines } })
    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || 'Failed to fetch logs')
  }
})

export const fetchFiles = createAsyncThunk('serverManagement/fetchFiles', async (path = '/home', thunkAPI) => {
  try {
    const res = await api.get('/files', { params: { path } })
    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || 'Failed to list files')
  }
})

export const readFile = createAsyncThunk('serverManagement/readFile', async (path, thunkAPI) => {
  try {
    const res = await api.get('/files/read', { params: { path } })
    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || 'Failed to read file')
  }
})

export const writeFile = createAsyncThunk('serverManagement/writeFile', async ({ path, content }, thunkAPI) => {
  try {
    const res = await api.post('/files/write', { path, content })
    toast.success('File saved successfully')
    return res.data
  } catch (err) {
    toast.error(err.response?.data?.message || 'Failed to save file')
    return thunkAPI.rejectWithValue(err.response?.data?.message)
  }
})

export const createDirectory = createAsyncThunk('serverManagement/createDirectory', async (path, thunkAPI) => {
  try {
    const res = await api.post('/files/mkdir', { path })
    toast.success('Directory created')
    return res.data
  } catch (err) {
    toast.error(err.response?.data?.message || 'Failed to create directory')
    return thunkAPI.rejectWithValue(err.response?.data?.message)
  }
})

export const deleteFileOrDir = createAsyncThunk('serverManagement/deleteFileOrDir', async (path, thunkAPI) => {
  try {
    const res = await api.post('/files/delete', { path })
    toast.success('Deleted successfully')
    return res.data
  } catch (err) {
    toast.error(err.response?.data?.message || 'Failed to delete')
    return thunkAPI.rejectWithValue(err.response?.data?.message)
  }
})

export const renameFileOrDir = createAsyncThunk('serverManagement/renameFileOrDir', async ({ oldPath, newPath }, thunkAPI) => {
  try {
    const res = await api.post('/files/rename', { oldPath, newPath })
    toast.success('Renamed successfully')
    return res.data
  } catch (err) {
    toast.error(err.response?.data?.message || 'Failed to rename')
    return thunkAPI.rejectWithValue(err.response?.data?.message)
  }
})

export const searchFiles = createAsyncThunk('serverManagement/searchFiles', async ({ path, query }, thunkAPI) => {
  try {
    const res = await api.get('/files/search', { params: { path, query } })
    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || 'Search failed')
  }
})

export const fetchPm2 = createAsyncThunk('serverManagement/fetchPm2', async (_, thunkAPI) => {
  try {
    const res = await api.get('/pm2')
    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || 'Failed to fetch PM2')
  }
})

export const pm2Action = createAsyncThunk('serverManagement/pm2Action', async ({ name, action }, thunkAPI) => {
  try {
    const res = await api.post('/pm2/action', { name, action })
    toast.success(`PM2 ${action} successful`)
    return res.data
  } catch (err) {
    toast.error(err.response?.data?.message || 'PM2 action failed')
    return thunkAPI.rejectWithValue(err.response?.data?.message)
  }
})

export const fetchAuditLogs = createAsyncThunk('serverManagement/fetchAuditLogs', async ({ page = 1, limit = 50, category } = {}, thunkAPI) => {
  try {
    const res = await api.get('/audit-logs', { params: { page, limit, category } })
    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || 'Failed to fetch audit logs')
  }
})

export const fetchAlerts = createAsyncThunk('serverManagement/fetchAlerts', async (_, thunkAPI) => {
  try {
    const res = await api.get('/alerts')
    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || 'Failed to fetch alerts')
  }
})

export const updateAlert = createAsyncThunk('serverManagement/updateAlert', async ({ type, threshold, enabled }, thunkAPI) => {
  try {
    const res = await api.post('/alerts', { type, threshold, enabled })
    toast.success('Alert updated')
    return res.data
  } catch (err) {
    toast.error(err.response?.data?.message || 'Failed to update alert')
    return thunkAPI.rejectWithValue(err.response?.data?.message)
  }
})

const initialState = {
  // Connection
  connected: false,
  connecting: false,

  // Overview
  overview: null,
  overviewLoading: false,

  // CPU / Memory / Disk
  cpu: null,
  memory: null,
  disk: null,
  network: null,

  // Processes & Services
  processes: [],
  services: null,
  pm2Processes: [],

  // Logs
  logs: '',
  logsType: 'system',

  // Files
  files: { path: '/', items: [] },
  fileContent: null,
  searchResults: [],

  // Audit & Alerts
  auditLogs: [],
  auditTotal: 0,
  alerts: [],

  // General
  loading: false,
  error: null
}

const serverManagementSlice = createSlice({
  name: 'serverManagement',
  initialState,
  reducers: {
    clearFileContent: (state) => { state.fileContent = null },
    clearSearchResults: (state) => { state.searchResults = [] },
    clearError: (state) => { state.error = null }
  },
  extraReducers: (builder) => {
    // Test connection
    builder.addCase(testConnection.pending, (state) => { state.connecting = true })
    builder.addCase(testConnection.fulfilled, (state, action) => {
      state.connecting = false
      state.connected = action.payload.data?.connected || false
    })
    builder.addCase(testConnection.rejected, (state) => {
      state.connecting = false
      state.connected = false
    })

    // Overview
    builder.addCase(fetchOverview.pending, (state) => { state.overviewLoading = true })
    builder.addCase(fetchOverview.fulfilled, (state, action) => {
      state.overviewLoading = false
      if (action.payload.status) state.overview = action.payload.data
    })
    builder.addCase(fetchOverview.rejected, (state) => { state.overviewLoading = false })

    // CPU
    builder.addCase(fetchCpu.fulfilled, (state, action) => {
      if (action.payload.status) state.cpu = action.payload.data
    })

    // Memory
    builder.addCase(fetchMemory.fulfilled, (state, action) => {
      if (action.payload.status) state.memory = action.payload.data
    })

    // Disk
    builder.addCase(fetchDisk.fulfilled, (state, action) => {
      if (action.payload.status) state.disk = action.payload.data
    })

    // Network
    builder.addCase(fetchNetwork.fulfilled, (state, action) => {
      if (action.payload.status) state.network = action.payload.data
    })

    // Processes
    builder.addCase(fetchProcesses.fulfilled, (state, action) => {
      if (action.payload.status) state.processes = action.payload.data
    })

    // Services
    builder.addCase(fetchServices.fulfilled, (state, action) => {
      if (action.payload.status) state.services = action.payload.data
    })

    // Logs
    builder.addCase(fetchLogs.fulfilled, (state, action) => {
      if (action.payload.status) {
        state.logs = action.payload.data.logs
        state.logsType = action.payload.data.type
      }
    })

    // Files
    builder.addCase(fetchFiles.fulfilled, (state, action) => {
      if (action.payload.status) state.files = action.payload.data
    })
    builder.addCase(readFile.fulfilled, (state, action) => {
      if (action.payload.status) state.fileContent = action.payload.data
    })
    builder.addCase(searchFiles.fulfilled, (state, action) => {
      if (action.payload.status) state.searchResults = action.payload.data
    })

    // PM2
    builder.addCase(fetchPm2.fulfilled, (state, action) => {
      if (action.payload.status) state.pm2Processes = action.payload.data
    })

    // Audit Logs
    builder.addCase(fetchAuditLogs.fulfilled, (state, action) => {
      if (action.payload.status) {
        state.auditLogs = action.payload.data.logs
        state.auditTotal = action.payload.data.total
      }
    })

    // Alerts
    builder.addCase(fetchAlerts.fulfilled, (state, action) => {
      if (action.payload.status) state.alerts = action.payload.data
    })
    builder.addCase(updateAlert.fulfilled, (state, action) => {
      if (action.payload.status) {
        const idx = state.alerts.findIndex(a => a.type === action.payload.data.type)
        if (idx !== -1) state.alerts[idx] = action.payload.data
        else state.alerts.push(action.payload.data)
      }
    })
  }
})

export const { clearFileContent, clearSearchResults, clearError } = serverManagementSlice.actions
export default serverManagementSlice.reducer
