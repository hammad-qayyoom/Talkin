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

export const fetchGrowthSpotlights = createAsyncThunk(
  'growthSpotlight/fetchGrowthSpotlights',
  async (params = {}, thunkAPI) => {
    try {
      const { page, pageSize } = params

      const response = await axios.get(`${baseURL}/api/admin/growthSpotlight/getAllGrowthSpotlights`, {
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

export const createGrowthSpotlight = createAsyncThunk(
  'growthSpotlight/createGrowthSpotlight',
  async (formData, thunkAPI) => {
    try {
      const response = await axios.post(`${baseURL}/api/admin/growthSpotlight/createGrowthSpotlight`, formData, {
        headers: getAuthHeaders({ omitContentType: true })
      })

      return response.data
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const updateGrowthSpotlight = createAsyncThunk(
  'growthSpotlight/updateGrowthSpotlight',
  async (formData, thunkAPI) => {
    try {
      const response = await axios.patch(`${baseURL}/api/admin/growthSpotlight/updateGrowthSpotlight`, formData, {
        headers: getAuthHeaders({ omitContentType: true })
      })

      return response.data
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const deleteGrowthSpotlight = createAsyncThunk(
  'growthSpotlight/deleteGrowthSpotlight',
  async (spotlightId, thunkAPI) => {
    try {
      const response = await axios.delete(
        `${baseURL}/api/admin/growthSpotlight/deleteGrowthSpotlight?spotlightId=${spotlightId}`,
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

export const toggleGrowthSpotlightStatus = createAsyncThunk(
  'growthSpotlight/toggleGrowthSpotlightStatus',
  async (spotlightId, thunkAPI) => {
    try {
      const response = await axios.patch(
        `${baseURL}/api/admin/growthSpotlight/toggleGrowthSpotlightStatus?spotlightId=${spotlightId}`,
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

const growthSpotlightSlice = createSlice({
  name: 'growthSpotlight',
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
    builder.addCase(fetchGrowthSpotlights.pending, state => {
      state.initialLoading = true
    })
    builder.addCase(fetchGrowthSpotlights.fulfilled, (state, action) => {
      state.initialLoading = false

      if (action.payload.status) {
        state.items = action.payload.data
        state.total = action.payload.total
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(fetchGrowthSpotlights.rejected, (state, action) => {
      state.initialLoading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(createGrowthSpotlight.pending, state => {
      state.loading = true
    })
    builder.addCase(createGrowthSpotlight.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.items = [action.payload.data, ...state.items]
        state.total += 1
        toast.success(action.payload.message || 'Growth spotlight created successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(createGrowthSpotlight.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(updateGrowthSpotlight.pending, state => {
      state.loading = true
    })
    builder.addCase(updateGrowthSpotlight.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        const index = state.items.findIndex(item => item._id === action.payload.data._id)

        if (index !== -1) {
          state.items[index] = action.payload.data
        }

        toast.success(action.payload.message || 'Growth spotlight updated successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(updateGrowthSpotlight.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(deleteGrowthSpotlight.pending, state => {
      state.loading = true
    })
    builder.addCase(deleteGrowthSpotlight.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.items = state.items.filter(item => item._id !== action.payload.spotlightId)
        state.total -= 1
        toast.success(action.payload.message || 'Growth spotlight deleted successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(deleteGrowthSpotlight.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(toggleGrowthSpotlightStatus.pending, state => {
      state.loading = true
    })
    builder.addCase(toggleGrowthSpotlightStatus.fulfilled, (state, action) => {
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
    builder.addCase(toggleGrowthSpotlightStatus.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })
  }
})

export const { setPage, setPageSize } = growthSpotlightSlice.actions
export default growthSpotlightSlice.reducer
