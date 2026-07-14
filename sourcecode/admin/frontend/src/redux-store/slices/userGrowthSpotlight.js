'use client'

import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { baseURL, secretKey } from '@/config'

const getAuthHeaders = (options = {}) => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('admin_token')
    const uid = localStorage.getItem('uid')

    const headers = {
      key: secretKey,
      Authorization: token ? `Bearer ${token}` : '',
      'x-admin-uid': uid
    }

    if (!options.omitContentType) {
      headers['Content-Type'] = 'application/json'
    }

    return headers
  }

  return {}
}

export const fetchUserGrowthSpotlights = createAsyncThunk(
  'userGrowthSpotlight/fetchUserGrowthSpotlights',
  async (params = {}, thunkAPI) => {
    try {
      const { page, pageSize } = params

      const response = await axios.get(`${baseURL}/api/admin/userGrowthSpotlight/getAllUserGrowthSpotlights`, {
        headers: getAuthHeaders(),
        params: {
          page,
          limit: pageSize
        }
      })

      return response.data
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const createUserGrowthSpotlight = createAsyncThunk(
  'userGrowthSpotlight/createUserGrowthSpotlight',
  async (formData, thunkAPI) => {
    try {
      const response = await axios.post(`${baseURL}/api/admin/userGrowthSpotlight/createUserGrowthSpotlight`, formData, {
        headers: getAuthHeaders({ omitContentType: true })
      })

      return response.data
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const updateUserGrowthSpotlight = createAsyncThunk(
  'userGrowthSpotlight/updateUserGrowthSpotlight',
  async (formData, thunkAPI) => {
    try {
      const response = await axios.patch(`${baseURL}/api/admin/userGrowthSpotlight/updateUserGrowthSpotlight`, formData, {
        headers: getAuthHeaders({ omitContentType: true })
      })

      return response.data
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const deleteUserGrowthSpotlight = createAsyncThunk(
  'userGrowthSpotlight/deleteUserGrowthSpotlight',
  async (spotlightId, thunkAPI) => {
    try {
      const response = await axios.delete(
        `${baseURL}/api/admin/userGrowthSpotlight/deleteUserGrowthSpotlight?spotlightId=${spotlightId}`,
        {
          headers: getAuthHeaders()
        }
      )

      return { ...response.data, spotlightId }
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const toggleUserGrowthSpotlightStatus = createAsyncThunk(
  'userGrowthSpotlight/toggleUserGrowthSpotlightStatus',
  async (spotlightId, thunkAPI) => {
    try {
      const response = await axios.patch(
        `${baseURL}/api/admin/userGrowthSpotlight/toggleUserGrowthSpotlightStatus?spotlightId=${spotlightId}`,
        {},
        {
          headers: getAuthHeaders()
        }
      )

      return response.data
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

const initialState = {
  initialLoading: true,
  loading: false,
  items: [],
  error: null,
  page: 1,
  pageSize: 10,
  total: 0
}

const userGrowthSpotlightSlice = createSlice({
  name: 'userGrowthSpotlight',
  initialState,
  reducers: {
    setPage: (state, action) => {
      state.page = action.payload
    },
    setPageSize: (state, action) => {
      state.pageSize = action.payload
      state.page = 1
    }
  },
  extraReducers: builder => {
    builder.addCase(fetchUserGrowthSpotlights.pending, state => {
      state.initialLoading = true
    })
    builder.addCase(fetchUserGrowthSpotlights.fulfilled, (state, action) => {
      state.initialLoading = false

      if (action.payload.status) {
        state.items = action.payload.data
        state.total = action.payload.total
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(fetchUserGrowthSpotlights.rejected, (state, action) => {
      state.initialLoading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(createUserGrowthSpotlight.pending, state => {
      state.loading = true
    })
    builder.addCase(createUserGrowthSpotlight.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.items = [action.payload.data, ...state.items]
        state.total += 1
        toast.success(action.payload.message || 'User spotlight created successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(createUserGrowthSpotlight.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(updateUserGrowthSpotlight.pending, state => {
      state.loading = true
    })
    builder.addCase(updateUserGrowthSpotlight.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        const index = state.items.findIndex(item => item._id === action.payload.data._id)

        if (index !== -1) {
          state.items[index] = action.payload.data
        }

        toast.success(action.payload.message || 'User spotlight updated successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(updateUserGrowthSpotlight.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(deleteUserGrowthSpotlight.pending, state => {
      state.loading = true
    })
    builder.addCase(deleteUserGrowthSpotlight.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.items = state.items.filter(item => item._id !== action.payload.spotlightId)
        state.total -= 1
        toast.success(action.payload.message || 'User spotlight deleted successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(deleteUserGrowthSpotlight.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(toggleUserGrowthSpotlightStatus.pending, state => {
      state.loading = true
    })
    builder.addCase(toggleUserGrowthSpotlightStatus.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        const index = state.items.findIndex(item => item._id === action.payload.data._id)

        if (index !== -1) {
          state.items[index] = action.payload.data
        }

        toast.success(action.payload.message || 'Status updated successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(toggleUserGrowthSpotlightStatus.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })
  }
})

export const { setPage, setPageSize } = userGrowthSpotlightSlice.actions
export default userGrowthSpotlightSlice.reducer
