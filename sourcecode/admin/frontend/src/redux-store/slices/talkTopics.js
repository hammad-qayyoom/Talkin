'use client'

import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { baseURL, secretKey } from '@/config'

// Helpers
const getAuthHeaders = ({ isMultipart = false } = {}) => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('admin_token')
    const uid = localStorage.getItem('uid')

    const headers = {
      key: secretKey,
      Authorization: `Bearer ${token}`,
      'x-admin-uid': uid
    }

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json'
    }

    return headers
  }

  return {}
}

export const fetchTalkTopics = createAsyncThunk('talkTopics/fetchTalkTopics', async (params = {}, thunkAPI) => {
  try {
    const { page, pageSize, isActive, search } = params
    
    const response = await axios.get(`${baseURL}/api/v2/categories/list`, {
      headers: getAuthHeaders(),
      params: {
        start: page || 1,
        limit: pageSize || 10,
        ...(isActive !== undefined ? { isActive } : { isActive: true }),
        ...(search ? { search } : {})
      }
    })

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const createTalkTopic = createAsyncThunk('talkTopics/createTalkTopic', async (payload, thunkAPI) => {
  try {
    const formData = new FormData()

    if (payload.name !== undefined) formData.append('name', payload.name)
    if (payload.icon !== undefined) formData.append('icon', payload.icon)
    if (payload.description !== undefined) formData.append('description', payload.description)
    if (payload.image) formData.append('image', payload.image)

    const response = await axios.post(`${baseURL}/api/v2/categories/create`, formData, {
      headers: getAuthHeaders({ isMultipart: true })
    })

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const updateTalkTopic = createAsyncThunk('talkTopics/updateTalkTopic', async (payload, thunkAPI) => {
  try {
    const formData = new FormData()

    if (payload.name !== undefined) formData.append('name', payload.name)
    if (payload.icon !== undefined) formData.append('icon', payload.icon)
    if (payload.description !== undefined) formData.append('description', payload.description)
    if (payload.image) formData.append('image', payload.image)

    const response = await axios.patch(
      `${baseURL}/api/v2/categories/update?categoryId=${payload.talkTopicId}`,
      formData,
      {
        headers: getAuthHeaders({ isMultipart: true })
      }
    )

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const deleteTalkTopic = createAsyncThunk('talkTopics/deleteTalkTopic', async (talkTopicId, thunkAPI) => {
  try {
    const response = await axios.delete(`${baseURL}/api/v2/categories/delete?categoryId=${talkTopicId}`, {
      headers: getAuthHeaders()
    })

    return { ...response.data, talkTopicId }
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

const initialState = {
  initialLoading: true,
  loading: false,
  talkTopics: [],
  status: 'idle',
  error: null,
  page: 1,
  pageSize: 10,
  total: 0
}

const talkTopicsSlice = createSlice({
  name: 'talkTopics',
  initialState,
  reducers: {
    setPage: (state, action) => {
      state.page = action.payload
    },
    setPageSize: (state, action) => {
      state.pageSize = action.payload
      state.page = 1 // Reset to first page when changing page size
    }
  },
  extraReducers: builder => {
    // Fetch talk topics
    builder.addCase(fetchTalkTopics.pending, state => {
      state.initialLoading = true
    })
    builder.addCase(fetchTalkTopics.fulfilled, (state, action) => {
      state.initialLoading = false

      if (action.payload.status) {
        state.talkTopics = action.payload.data
        state.total = action.payload.total
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(fetchTalkTopics.rejected, (state, action) => {
      state.initialLoading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Create talk topic
    builder.addCase(createTalkTopic.pending, state => {
      state.loading = true
    })
    builder.addCase(createTalkTopic.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.talkTopics = [...state.talkTopics, action.payload.data]
        state.total += 1
        toast.success(action.payload.message || 'Category created successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(createTalkTopic.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Update talk topic
    builder.addCase(updateTalkTopic.pending, state => {
      state.loading = true
    })
    builder.addCase(updateTalkTopic.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        const index = state.talkTopics.findIndex(talkTopic => talkTopic._id === action.payload.data._id)

        if (index !== -1) {
          state.talkTopics[index] = action.payload.data
        }

        toast.success(action.payload.message || 'Category updated successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(updateTalkTopic.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Delete talk topic
    builder.addCase(deleteTalkTopic.pending, state => {
      state.loading = true
    })
    builder.addCase(deleteTalkTopic.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.talkTopics = state.talkTopics.filter(talkTopic => talkTopic._id !== action.payload.talkTopicId)
        state.total -= 1
        toast.success(action.payload.message || 'Category deleted successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(deleteTalkTopic.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })
  }
})

export const { setPage, setPageSize } = talkTopicsSlice.actions

export default talkTopicsSlice.reducer
