'use client'

import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { baseURL, secretKey } from '@/config'

const BASE_URL = baseURL

// Helper to get auth headers
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

// Fetch listeners with pagination, search, and date range
export const fetchExperts = createAsyncThunk(
  'expert/fetchExperts',
  async (params = {}, { rejectWithValue, getState }) => {
    try {
      const state = getState()

      // Get parameters from params or state
      const page = params.page || state.expert.page || 1
      const limit = params.limit || state.expert.pageSize || 10
      const searchQuery = params.searchQuery || state.expert.searchQuery || ''
      const startDate = params.startDate || state.expert.startDate || 'All'
      const endDate = params.endDate || state.expert.endDate || 'All'
      const gender = params.gender || state.expert.gender || 'All'
      const isFake = params.isFake !== undefined ? params.isFake : state.expert.isFake

      const isBlock = params.isBlock !== undefined ? params.isBlock : state.expert.isBlock
      const isOnline = params.isOnline !== undefined ? params.isOnline : state.expert.isOnline
      const isBusy = params.isBusy !== undefined ? params.isBusy : state.expert.isBusy

      const response = await axios.get(`${BASE_URL}/api/admin/expert/fetchExperts`, {
        headers: getAuthHeaders(),
        params: {
          start: page,
          limit,
          searchString: searchQuery,
          startDate,
          endDate,
          isFake,
          isBlock,
          isOnline,
          isBusy,
          gender
        }
      })

      return response.data
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

// Fetch listeners with pagination, search, and date range
export const fetchDropdownUser = createAsyncThunk(
  'expert/retrieveUserList',
  async (params = {}, { rejectWithValue, getState }) => {
    try {
      const response = await axios.get(`${BASE_URL}/api/admin/user/retrieveUserList`, {
        headers: getAuthHeaders(),
        params: {
          search: 'All'
        }
      })

      return response.data
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

// Create a new expert
export const createExpert = createAsyncThunk('expert/createExpert', async (formData, { rejectWithValue }) => {
  try {
    const response = await axios.post(`${BASE_URL}/api/admin/expert/createExpert`, formData, {
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    })

    if (response.data.status) {
      toast.success(response.data.message || 'Expert created successfully')

      return response.data.newListener
    } else {
      return rejectWithValue(response.data.message)
    }
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    return rejectWithValue(errorMsg)
  }
})

// Update a expert
export const updateListener = createAsyncThunk(
  'expert/updateListener',
  async ({ listenerId, formData }, { rejectWithValue }) => {
    try {
      const response = await axios.patch(`${BASE_URL}/api/admin/expert/updateExpertProfile`, formData, {
        headers: {
          ...getAuthHeaders(),
          'Content-Type': 'multipart/form-data'
        },
        params: { listenerId }
      })

      if (response.data.status) {
        toast.success(response.data.message || 'Expert updated successfully')

        return response.data.data
      } else {
        return rejectWithValue(response.data.message)
      }
    } catch (error) {
      const errorMsg = error.response?.data?.message || error.message

      return rejectWithValue(errorMsg)
    }
  }
)

// Delete a expert
export const deleteListener = createAsyncThunk('expert/deleteListener', async (listenerId, { rejectWithValue }) => {
  try {
    const response = await axios.delete(`${BASE_URL}/api/admin/expert/deleteExpertProfile`, {
      headers: getAuthHeaders(),
      params: { listenerId }
    })

    if (response.data.status) {
      toast.success(response.data.message || 'Expert deleted successfully')

      return listenerId
    } else {
      return rejectWithValue(response.data.message)
    }
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    return rejectWithValue(errorMsg)
  }
})

// Expert Session Credit History
export const fetchCoinHistoryListener = createAsyncThunk(
  'user/fetchCoinTransactions',
  async ({ userId, start = 1, limit = 20, startDate = 'All', endDate = 'All' }, thunkAPI) => {
    try {
      // If we have date filters, always start from page 1 to avoid pagination issues
      const effectiveStart = startDate !== 'All' || endDate !== 'All' ? 1 : start

      const res = await axios.get(`${baseURL}/api/admin/history/fetchCoinTransactions`, {
        headers: getAuthHeaders(),
        params: { listenerId: userId, start, limit, startDate, endDate }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

// Expert Call History
export const fetchCallHistoryListener = createAsyncThunk(
  'user/fetchCallHistoryListener',
  async ({ userId, start = 1, limit = 20, startDate = 'All', endDate = 'All' }, thunkAPI) => {
    try {
      // If we have date filters, always start from page 1 to avoid pagination issues
      const effectiveStart = startDate !== 'All' || endDate !== 'All' ? 1 : start

      const res = await axios.get(`${baseURL}/api/admin/history/fetchCallHistory`, {
        headers: getAuthHeaders(),
        params: { listenerId: userId, start, limit, startDate, endDate }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

// Block expert
export const blockListener = createAsyncThunk('expert/blockListener', async (listenerId, { rejectWithValue }) => {
  try {
    const response = await axios.patch(
      `${BASE_URL}/api/admin/expert/updateBlockStatus?listenerId=${listenerId}`,
      {},
      {
        headers: getAuthHeaders()
      }
    )
    return response.data
  } catch (error) {
    return rejectWithValue(error.response?.data?.message || error.message)
  }
})

const initialState = {
  listeners: [],
  data : {},
  total: 0,
  loading: false,
  initialLoad: true,
  page: 1,
  pageSize: 10,
  searchQuery: '',
  startDate: 'All',
  endDate: 'All',
  isFake: false,
  error: null,
  selectedListener: null,
  dropDownUser: [],
  history: {
    data: [],
    filteredData: [],
    liveStreamHistory: [],
    total: 0,
    totalIncome: 0,
    totalOutgoing: 0,
    typeWiseStats: [],
    loading: false,
    initialLoading: true,
    page: 1,
    limit: 10,
    hasMore: true,
    error: null
  }
}

const listenerSlice = createSlice({
  name: 'expert',
  initialState,
  reducers: {
    setPage: (state, action) => {
      state.page = action.payload
    },
    setPageSize: (state, action) => {
      state.pageSize = action.payload
    },
    setSearchQuery: (state, action) => {
      
      state.searchQuery = action.payload
    },
    setDateRange: (state, action) => {
      state.startDate = action.payload.startDate
      state.endDate = action.payload.endDate
    },
    setIsFake: (state, action) => {
      state.isFake = action.payload
    },
    setSelectedListener: (state, action) => {
      state.selectedListener = action.payload
    },
    resetListenerFilters: state => {
      state.page = 1
      state.searchQuery = ''
      state.startDate = 'All'
      state.endDate = 'All'
      state.data = {}
    },
    resetHistoryState: state => {
      state.history = {
        data: [],
        filteredData: [],
        liveStreamHistory: [],
        total: 0,
        totalIncome: 0,
        totalOutgoing: 0,
        typeWiseStats: [],
        loading: false,
        initialLoading: true,
        page: 1,
        limit: 10,
        hasMore: true,
        error: null
      }
    }
  },
  extraReducers: builder => {
    builder

      // Handle fetchExperts states
      .addCase(fetchExperts.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(fetchExperts.fulfilled, (state, action) => {
        state.loading = false
        state.initialLoad = false
        state.listeners = action.payload.data || []
        state.data = {
          activeListeners : action.payload.total,
          maleListeners : action.payload.totalMaleListeners,
          femaleListeners : action.payload.totalFemaleListeners,
        }
        state.total = action.payload.total || 0
        state.error = null
      })
      .addCase(fetchExperts.rejected, (state, action) => {
        state.loading = false
        state.initialLoad = false
        state.error = action.payload || 'Failed to fetch experts'
        toast.error(action.payload || 'Failed to fetch experts')
      })
      .addCase(fetchDropdownUser.pending, state => {})
      .addCase(fetchDropdownUser.fulfilled, (state, action) => {
        state.dropDownUser = action.payload.data || []
      })
      .addCase(fetchDropdownUser.rejected, (state, action) => {})

      // Handle createExpert states
      .addCase(createExpert.pending, state => {
        // No state changes needed for pending creation
      })
      .addCase(createExpert.fulfilled, (state, action) => {
        // Optionally add the new expert to the state if needed immediately
        state.listeners = [action.payload, ...state.listeners]
        state.total += 1
      })
      .addCase(createExpert.rejected, (state, action) => {
        state.error = action.payload || 'Failed to create expert'
        toast.error(action.payload || 'Failed to create expert')
      })

      // Handle updateListener states
      .addCase(updateListener.pending, state => {
        // No state changes needed for pending update
      })
      .addCase(updateListener.fulfilled, (state, action) => {
        // Update the expert in the state if it exists
        // const updatedListener = action.payload
        // state.listeners = state.listeners.map(expert =>
        //   expert._id === updatedListener._id ? updatedListener : expert
        // )
      })
      .addCase(updateListener.rejected, (state, action) => {
        state.error = action.payload || 'Failed to update expert'
        toast.error(action.payload || 'Failed to update expert')
      })

      // Handle deleteListener states
      .addCase(deleteListener.pending, state => {
        // No state changes needed for pending deletion
      })
      .addCase(deleteListener.fulfilled, (state, action) => {
        // Remove the deleted expert from the state
        state.listeners = state.listeners.filter(expert => expert._id !== action.payload)
        state.total -= 1
      })
      .addCase(deleteListener.rejected, (state, action) => {
        state.error = action.payload || 'Failed to delete expert'
        toast.error(action.payload || 'Failed to delete expert')
      })

    builder
      .addCase(fetchCoinHistoryListener.pending, state => {
        state.history.loading = true
      })
      .addCase(fetchCoinHistoryListener.fulfilled, (state, action) => {
        const { data, total } = action.payload

        state.history.data = data
        state.history.total = total
        state.history.loading = false
        state.history.initialLoading = false
        state.history.page = 1
      })
      .addCase(fetchCoinHistoryListener.rejected, (state, action) => {
        state.history.loading = false
        state.history.initialLoading = false
        state.history.error = action.payload
      })

      .addCase(fetchCallHistoryListener.pending, state => {
        state.history.loading = true
      })
      .addCase(fetchCallHistoryListener.fulfilled, (state, action) => {
        const { data, total } = action.payload

        state.history.data = data
        state.history.total = total
        state.history.loading = false
        state.history.initialLoading = false
        state.history.page = 1
      })
      .addCase(fetchCallHistoryListener.rejected, (state, action) => {
        state.history.loading = false
        state.history.initialLoading = false
        state.history.error = action.payload
      })

      // Handle blockListener states
      .addCase(blockListener.pending, state => {
        // No state changes needed for pending deletion
      })
      .addCase(blockListener.fulfilled, (state, action) => {
        // change isblock status
        if (action.payload.status) {
          state.listeners = state.listeners.map(expert =>
            expert._id === action.meta.arg ? { ...expert, isBlock: !expert.isBlock } : expert
          )
          toast.success(action.payload.message)
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(blockListener.rejected, (state, action) => {
        state.error = action.payload || 'Failed to block expert'
        toast.error(action.payload || 'Failed to block expert')
      })
  }
})

export const {
  setPage,
  setPageSize,
  setSearchQuery,
  setDateRange,
  setIsFake,
  setSelectedListener,
  resetListenerFilters,
  resetHistoryState
} = listenerSlice.actions

export default listenerSlice.reducer
