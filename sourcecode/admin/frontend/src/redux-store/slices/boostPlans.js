'use client'
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

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

export const fetchBoostPlans = createAsyncThunk('boostPlans/fetchBoostPlans', async (params, thunkAPI) => {
  try {
    const { page, pageSize } = params

    const response = await axios.get(`${BASE_URL}/api/admin/boost/plan/list`, {
      headers: getAuthHeaders(),
      params: {
        start: page,
        limit: pageSize
      }
    })

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const createBoostPlan = createAsyncThunk('boostPlans/createBoostPlan', async (payload, thunkAPI) => {
  try {
    const response = await axios.post(`${BASE_URL}/api/admin/boost/plan/add`, payload, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const updateBoostPlan = createAsyncThunk('boostPlans/updateBoostPlan', async (payload, thunkAPI) => {
  try {
    const response = await axios.patch(`${BASE_URL}/api/admin/boost/plan/edit`, payload, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const deleteBoostPlan = createAsyncThunk('boostPlans/deleteBoostPlan', async (boostPlanId, thunkAPI) => {
  try {
    const response = await axios.delete(`${BASE_URL}/api/admin/boost/plan/delete?boostPlanId=${boostPlanId}`, {
      headers: getAuthHeaders()
    })

    return { ...response.data, boostPlanId }
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const toggleBoostPlanField = createAsyncThunk(
  'boostPlans/toggleBoostPlanField',
  async ({ boostPlanId, field }, thunkAPI) => {
    try {
      const response = await axios.patch(
        `${BASE_URL}/api/admin/boost/plan/toggle?boostPlanId=${boostPlanId}&field=${field}`,
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
  boostPlans: [],
  status: 'idle',
  error: null,
  page: 1,
  pageSize: 10,
  total: 0
}

const boostPlansSlice = createSlice({
  name: 'boostPlans',
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
    builder.addCase(fetchBoostPlans.pending, state => {
      state.initialLoading = true
    })
    builder.addCase(fetchBoostPlans.fulfilled, (state, action) => {
      state.initialLoading = false

      if (action.payload.status) {
        state.boostPlans = action.payload.data
        state.total = action.payload.total
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(fetchBoostPlans.rejected, (state, action) => {
      state.initialLoading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(createBoostPlan.pending, state => {
      state.loading = true
    })
    builder.addCase(createBoostPlan.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.boostPlans = [...state.boostPlans, action.payload.data]
        state.total += 1
        toast.success(action.payload.message || 'Boost plan created successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(createBoostPlan.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(updateBoostPlan.pending, state => {
      state.loading = true
    })
    builder.addCase(updateBoostPlan.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        const index = state.boostPlans.findIndex(plan => plan._id === action.payload.data._id)

        if (index !== -1) {
          state.boostPlans[index] = action.payload.data
        }

        toast.success(action.payload.message || 'Boost plan updated successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(updateBoostPlan.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(deleteBoostPlan.pending, state => {
      state.loading = true
    })
    builder.addCase(deleteBoostPlan.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.boostPlans = state.boostPlans.filter(plan => plan._id !== action.payload.boostPlanId)
        state.total -= 1
        toast.success(action.payload.message || 'Boost plan deleted successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(deleteBoostPlan.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(toggleBoostPlanField.pending, state => {
      state.loading = true
    })
    builder.addCase(toggleBoostPlanField.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        const index = state.boostPlans.findIndex(plan => plan._id === action.payload.data._id)

        if (index !== -1) {
          state.boostPlans[index] = action.payload.data
        }

        toast.success(action.payload.message || 'Field toggled successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(toggleBoostPlanField.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })
  }
})

export const { setPage, setPageSize } = boostPlansSlice.actions

export default boostPlansSlice.reducer
