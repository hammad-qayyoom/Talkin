'use client'

import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { baseURL, secretKey } from '@/config'

const getAuthHeaders = () => {
  if (typeof window === 'undefined') return {}

  return {
    'Content-Type': 'application/json',
    key: secretKey,
    Authorization: `Bearer ${localStorage.getItem('admin_token') || ''}`,
    'x-admin-uid': localStorage.getItem('uid') || ''
  }
}

export const fetchReferralRecords = createAsyncThunk('referralSystem/fetchRecords', async params => {
  const query = new URLSearchParams({
    start: String(params?.page || 1),
    limit: String(params?.pageSize || 20),
    rewardStatus: params?.rewardStatus || 'All',
    rewardTriggerType: params?.rewardTriggerType || 'All',
    search: params?.search || ''
  })

  const response = await axios.get(`${baseURL}/api/admin/referral/list?${query.toString()}`, {
    headers: getAuthHeaders()
  })

  return response.data
})

export const updateReferralRewardStatus = createAsyncThunk(
  'referralSystem/updateRewardStatus',
  async ({ referralId, rewardStatus, rejectionReason }) => {
    const response = await axios.patch(
      `${baseURL}/api/admin/referral/updateRewardStatus?referralId=${referralId}`,
      { rewardStatus, rejectionReason },
      { headers: getAuthHeaders() }
    )

    if (response.data?.status) {
      toast.success(response.data.message || 'Referral reward updated')
    } else {
      toast.error(response.data?.message || 'Failed to update referral reward')
    }

    return response.data
  }
)

const referralSystemSlice = createSlice({
  name: 'referralSystem',
  initialState: {
    records: [],
    total: 0,
    loading: false,
    error: null
  },
  reducers: {},
  extraReducers: builder => {
    builder
      .addCase(fetchReferralRecords.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(fetchReferralRecords.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload?.status) {
          state.records = action.payload.data || []
          state.total = action.payload.total || 0
        } else {
          state.error = action.payload?.message || 'Failed to fetch referral records'
        }
      })
      .addCase(fetchReferralRecords.rejected, (state, action) => {
        state.loading = false
        state.error = action.error?.message || 'Failed to fetch referral records'
      })
      .addCase(updateReferralRewardStatus.fulfilled, (state, action) => {
        if (!action.payload?.status) return

        const updatedRecord = action.payload.data

        state.records = state.records.map(record => (record._id === updatedRecord._id ? updatedRecord : record))
      })
  }
})

export default referralSystemSlice.reducer
