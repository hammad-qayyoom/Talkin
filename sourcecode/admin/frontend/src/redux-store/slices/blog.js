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

export const fetchBlogPosts = createAsyncThunk(
  'blog/fetchBlogPosts',
  async (params = {}, thunkAPI) => {
    try {
      const { page, pageSize, search, status } = params

      const response = await axios.get(`${baseURL}/api/admin/blog/list`, {
        headers: getAuthHeaders(),
        params: {
          page,
          limit: pageSize,
          search,
          status
        }
      })

      return response.data
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const createBlogPost = createAsyncThunk(
  'blog/createBlogPost',
  async (formData, thunkAPI) => {
    try {
      const response = await axios.post(`${baseURL}/api/admin/blog/create`, formData, {
        headers: getAuthHeaders({ omitContentType: true })
      })

      return response.data
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const updateBlogPost = createAsyncThunk(
  'blog/updateBlogPost',
  async ({ postId, formData }, thunkAPI) => {
    try {
      const response = await axios.patch(`${baseURL}/api/admin/blog/${postId}`, formData, {
        headers: getAuthHeaders({ omitContentType: true })
      })

      return response.data
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const deleteBlogPost = createAsyncThunk(
  'blog/deleteBlogPost',
  async (postId, thunkAPI) => {
    try {
      const response = await axios.delete(`${baseURL}/api/admin/blog/${postId}`, {
        headers: getAuthHeaders()
      })

      return { ...response.data, postId }
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

const blogSlice = createSlice({
  name: 'blog',
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
    builder.addCase(fetchBlogPosts.pending, state => {
      state.initialLoading = true
    })
    builder.addCase(fetchBlogPosts.fulfilled, (state, action) => {
      state.initialLoading = false

      if (action.payload.status) {
        state.items = action.payload.data
        state.total = action.payload.total
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(fetchBlogPosts.rejected, (state, action) => {
      state.initialLoading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(createBlogPost.pending, state => {
      state.loading = true
    })
    builder.addCase(createBlogPost.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.items = [action.payload.data, ...state.items]
        state.total += 1
        toast.success(action.payload.message || 'Blog post created successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(createBlogPost.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(updateBlogPost.pending, state => {
      state.loading = true
    })
    builder.addCase(updateBlogPost.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        const index = state.items.findIndex(item => item._id === action.payload.data._id)

        if (index !== -1) {
          state.items[index] = action.payload.data
        }

        toast.success(action.payload.message || 'Blog post updated successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(updateBlogPost.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    builder.addCase(deleteBlogPost.pending, state => {
      state.loading = true
    })
    builder.addCase(deleteBlogPost.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.items = state.items.filter(item => item._id !== action.payload.postId)
        state.total -= 1
        toast.success(action.payload.message || 'Blog post deleted successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(deleteBlogPost.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })
  }
})

export const { setPage, setPageSize } = blogSlice.actions
export default blogSlice.reducer
