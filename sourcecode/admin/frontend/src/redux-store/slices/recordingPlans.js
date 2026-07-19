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

export const fetchRecordingPlans = createAsyncThunk('recordingPlans/fetchRecordingPlans', async (params, thunkAPI) => {
  try {
    const { page, pageSize } = params

    const response = await axios.get(`${BASE_URL}/api/admin/recordingPlan/listRecordingPlans`, {
      headers: getAuthHeaders(),
      params: { page, pageSize }
    })

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const createRecordingPlan = createAsyncThunk('recordingPlans/createRecordingPlan', async (payload, thunkAPI) => {
  try {
    const response = await axios.post(`${BASE_URL}/api/admin/recordingPlan/addRecordingPlan`, payload, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const updateRecordingPlan = createAsyncThunk('recordingPlans/updateRecordingPlan', async (payload, thunkAPI) => {
  try {
    const response = await axios.patch(`${BASE_URL}/api/admin/recordingPlan/editRecordingPlan`, payload, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const deleteRecordingPlan = createAsyncThunk('recordingPlans/deleteRecordingPlan', async (planId, thunkAPI) => {
  try {
    const response = await axios.delete(`${BASE_URL}/api/admin/recordingPlan/deleteRecordingPlan?planId=${planId}`, {
      headers: getAuthHeaders()
    })

    return { ...response.data, planId }
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const toggleRecordingPlanField = createAsyncThunk(
  'recordingPlans/toggleRecordingPlanField',
  async ({ planId, field }, thunkAPI) => {
    try {
      const response = await axios.patch(
        `${BASE_URL}/api/admin/recordingPlan/toggleRecordingPlanField?planId=${planId}&field=${field}`,
        {},
        { headers: getAuthHeaders() }
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
  plans: [],
  status: 'idle',
  error: null,
  page: 1,
  pageSize: 10,
  total: 0
}

const recordingPlansSlice = createSlice({
  name: 'recordingPlans',
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
    builder.addCase(fetchRecordingPlans.pending, state => {
      state.initialLoading = true
    })
    builder.addCase(fetchRecordingPlans.fulfilled, (state, action) => {
      state.initialLoading = false
      if (action.payload.status) {
        state.plans = action.payload.data
        state.total = action.payload.total
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(fetchRecordingPlans.rejected, (state, action) => {
      state.initialLoading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(createRecordingPlan.pending, state => {
      state.loading = true
    })
    builder.addCase(createRecordingPlan.fulfilled, (state, action) => {
      state.loading = false
      if (action.payload.status) {
        state.plans = [...state.plans, action.payload.data]
        state.total += 1
        toast.success(action.payload.message || 'Recording storage plan created successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(createRecordingPlan.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(updateRecordingPlan.pending, state => {
      state.loading = true
    })
    builder.addCase(updateRecordingPlan.fulfilled, (state, action) => {
      state.loading = false
      if (action.payload.status) {
        const index = state.plans.findIndex(p => p._id === action.payload.data._id)
        if (index !== -1) state.plans[index] = action.payload.data
        toast.success(action.payload.message || 'Recording storage plan updated successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(updateRecordingPlan.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(deleteRecordingPlan.pending, state => {
      state.loading = true
    })
    builder.addCase(deleteRecordingPlan.fulfilled, (state, action) => {
      state.loading = false
      if (action.payload.status) {
        state.plans = state.plans.filter(p => p._id !== action.payload.planId)
        state.total -= 1
        toast.success(action.payload.message || 'Recording storage plan deleted successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(deleteRecordingPlan.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(toggleRecordingPlanField.pending, state => {
      state.loading = true
    })
    builder.addCase(toggleRecordingPlanField.fulfilled, (state, action) => {
      state.loading = false
      if (action.payload.status) {
        const index = state.plans.findIndex(p => p._id === action.payload.data._id)
        if (index !== -1) state.plans[index] = action.payload.data
        toast.success(action.payload.message || 'Field toggled successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(toggleRecordingPlanField.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })
  }
})

export const { setPage, setPageSize } = recordingPlansSlice.actions

export default recordingPlansSlice.reducer
