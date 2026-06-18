'use client'

import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { baseURL, secretKey } from '@/config'

const BASE_URL = baseURL

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

export const fetchManualVerificationQueue = createAsyncThunk(
  'manualVerification/fetchQueue',
  async (params = {}, { rejectWithValue, getState }) => {
    try {
      const state = getState()
      const page = params.page || state.manualVerification?.page || 1
      const limit = params.limit || state.manualVerification?.pageSize || 10
      const search = params.search || state.manualVerification?.searchQuery || 'All'
      const status = params.status || state.manualVerification?.statusFilter || 'pending'

      const response = await axios.get(`${BASE_URL}/api/admin/manualVerification/queue`, {
        headers: getAuthHeaders(),
        params: { start: page, limit, search, status }
      })

      return response.data
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const approveManualVerification = createAsyncThunk(
  'manualVerification/approve',
  async ({ expertId, adminNotes }, { rejectWithValue }) => {
    try {
      const response = await axios.patch(`${BASE_URL}/api/admin/manualVerification/approve`, {
        expertId,
        adminNotes
      }, {
        headers: getAuthHeaders()
      })

      return response.data
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const rejectManualVerification = createAsyncThunk(
  'manualVerification/reject',
  async ({ expertId, rejectionReason, adminNotes }, { rejectWithValue }) => {
    try {
      const response = await axios.patch(`${BASE_URL}/api/admin/manualVerification/reject`, {
        expertId,
        rejectionReason,
        adminNotes
      }, {
        headers: getAuthHeaders()
      })

      return response.data
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const revokeVerificationBadge = createAsyncThunk(
  'manualVerification/revoke',
  async ({ expertId }, { rejectWithValue }) => {
    try {
      const response = await axios.patch(`${BASE_URL}/api/admin/manualVerification/revoke`, {
        expertId
      }, {
        headers: getAuthHeaders()
      })

      return response.data
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

const manualVerificationSlice = createSlice({
  name: 'manualVerification',
  initialState: {
    requests: [],
    total: 0,
    loading: false,
    initialLoad: true,
    error: null,
    page: 1,
    pageSize: 10,
    searchQuery: '',
    statusFilter: 'pending'
  },
  reducers: {
    setPage: (state, action) => { state.page = action.payload },
    setPageSize: (state, action) => { state.pageSize = action.payload },
    setSearchQuery: (state, action) => { state.searchQuery = action.payload },
    setStatusFilter: (state, action) => { state.statusFilter = action.payload }
  },
  extraReducers: builder => {
    builder
      .addCase(fetchManualVerificationQueue.pending, state => {
        state.loading = true
      })
      .addCase(fetchManualVerificationQueue.fulfilled, (state, action) => {
        state.loading = false
        state.initialLoad = false
        if (action.payload?.status) {
          state.requests = action.payload.data || []
          state.total = action.payload.total || 0
        } else {
          state.requests = []
          state.total = 0
        }
      })
      .addCase(fetchManualVerificationQueue.rejected, (state, action) => {
        state.loading = false
        state.initialLoad = false
        state.error = action.payload || 'Failed to fetch verification requests'
        toast.error(action.payload || 'Failed to fetch verification requests')
      })
      .addCase(approveManualVerification.fulfilled, (state, action) => {
        if (action.payload?.status) {
          toast.success(action.payload.message || 'Verification approved')
          state.requests = state.requests.filter(r => r._id !== action.meta.arg.expertId)
          state.total = Math.max(0, state.total - 1)
        } else {
          toast.error(action.payload?.message || 'Failed to approve')
        }
      })
      .addCase(approveManualVerification.rejected, (state, action) => {
        toast.error(action.payload || 'Failed to approve verification')
      })
      .addCase(rejectManualVerification.fulfilled, (state, action) => {
        if (action.payload?.status) {
          toast.success(action.payload.message || 'Verification rejected')
          state.requests = state.requests.filter(r => r._id !== action.meta.arg.expertId)
          state.total = Math.max(0, state.total - 1)
        } else {
          toast.error(action.payload?.message || 'Failed to reject')
        }
      })
      .addCase(rejectManualVerification.rejected, (state, action) => {
        toast.error(action.payload || 'Failed to reject verification')
      })
      .addCase(revokeVerificationBadge.fulfilled, (state, action) => {
        if (action.payload?.status) {
          toast.success(action.payload.message || 'Verification revoked')
        } else {
          toast.error(action.payload?.message || 'Failed to revoke')
        }
      })
      .addCase(revokeVerificationBadge.rejected, (state, action) => {
        toast.error(action.payload || 'Failed to revoke verification')
      })
  }
})

export const { setPage, setPageSize, setSearchQuery, setStatusFilter } = manualVerificationSlice.actions
export default manualVerificationSlice.reducer
