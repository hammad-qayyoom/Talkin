'use client'

import { useCallback, useEffect, useMemo, useState } from 'react'

import axios from 'axios'

import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import Chip from '@mui/material/Chip'
import CircularProgress from '@mui/material/CircularProgress'
import IconButton from '@mui/material/IconButton'
import MenuItem from '@mui/material/MenuItem'
import Tooltip from '@mui/material/Tooltip'
import Typography from '@mui/material/Typography'
import { toast } from 'react-toastify'

import CustomTextField from '@/@core/components/mui/TextField'
import TablePaginationComponent from '@/components/TablePaginationComponent'
import EmprtyTableRow from '@/components/common/EmprtyTableRow'
import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'
import { baseURL, secretKey } from '@/config'

import tableStyles from '@core/styles/table.module.css'

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

const normalizeMediaUrl = mediaPath => {
  const path = String(mediaPath || '').trim()

  if (!path) return ''

  if (path.startsWith('http://') || path.startsWith('https://')) {
    return path
  }

  if (path.startsWith('/')) {
    return `${baseURL}${path}`
  }

  return `${baseURL}/${path}`
}

const shorten = (value, max = 110) => {
  const text = String(value || '').trim()

  if (text.length <= max) return text

  return `${text.slice(0, max)}...`
}

const formatDate = value => {
  if (!value) return '-'

  const parsed = new Date(value)

  if (Number.isNaN(parsed.getTime())) return '-'

  return parsed.toLocaleString('en-US', {
    year: 'numeric',
    month: 'short',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const FeedPostsTable = ({ reportedOnly = false }) => {
  const [loading, setLoading] = useState(true)
  const [posts, setPosts] = useState([])
  const [total, setTotal] = useState(0)

  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)

  const [searchInput, setSearchInput] = useState('')
  const [search, setSearch] = useState('')
  const [postType, setPostType] = useState('all')

  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
  const [selectedPost, setSelectedPost] = useState(null)
  const [deleting, setDeleting] = useState(false)
  const [deleteError, setDeleteError] = useState(null)

  const loadPosts = useCallback(async () => {
    setLoading(true)

    try {
      const endpoint = reportedOnly
        ? `${baseURL}/api/v2/feed/admin/posts/reported`
        : `${baseURL}/api/v2/feed/admin/posts/list`

      const params = {
        start: page,
        limit: pageSize
      }

      if (search.trim()) {
        params.search = search.trim()
      }

      if (postType !== 'all') {
        params.postType = postType
      }

      const response = await axios.get(endpoint, {
        headers: getAuthHeaders(),
        params
      })

      if (response?.data?.status === true) {
        setPosts(response.data.data || [])
        setTotal(Number(response.data.total || 0))
      } else {
        setPosts([])
        setTotal(0)
        toast.error(response?.data?.message || 'Unable to fetch feed posts.')
      }
    } catch (error) {
      setPosts([])
      setTotal(0)
      toast.error(error?.response?.data?.message || 'Failed to load feed posts.')
    } finally {
      setLoading(false)
    }
  }, [page, pageSize, postType, reportedOnly, search])

  useEffect(() => {
    loadPosts()
  }, [loadPosts])

  useEffect(() => {
    const maxPage = Math.max(1, Math.ceil(total / pageSize))

    if (page > maxPage) {
      setPage(maxPage)
    }
  }, [page, pageSize, total])

  const handleApplySearch = () => {
    setPage(1)
    setSearch(searchInput)
  }

  const handleResetFilters = () => {
    setSearchInput('')
    setSearch('')
    setPostType('all')
    setPage(1)
  }

  const handleDeleteClick = post => {
    setSelectedPost(post)
    setDeleteError(null)
    setDeleting(false)
    setDeleteDialogOpen(true)
  }

  const handleDeleteConfirm = async () => {
    if (!selectedPost) return

    setDeleting(true)
    setDeleteError(null)

    try {
      const response = await axios.patch(
        `${baseURL}/api/v2/feed/admin/posts/delete`,
        {
          postId: selectedPost.id || selectedPost._id
        },
        {
          headers: getAuthHeaders()
        }
      )

      if (response?.data?.status === true) {
        const postId = selectedPost.id || selectedPost._id

        setPosts(prev => prev.filter(item => (item.id || item._id) !== postId))
        setTotal(prev => Math.max(0, prev - 1))
        toast.success(response?.data?.message || 'Post deleted successfully.')
      } else {
        const message = response?.data?.message || 'Unable to delete this post.'

        setDeleteError(message)
        toast.error(message)
      }
    } catch (error) {
      const message = error?.response?.data?.message || 'Failed to delete this post.'

      setDeleteError(message)
      toast.error(message)
    } finally {
      setDeleting(false)
    }
  }

  const columns = useMemo(
    () => [
      'Author',
      'Content',
      'Media',
      'Likes',
      'Comments',
      'Shares',
      'Reports',
      'Visibility',
      'Created At',
      'Actions'
    ],
    []
  )

  return (
    <Box>
      <Box className='mb-4'>
        <Typography variant='h4'>{reportedOnly ? 'Reported Feed Posts' : 'Feed Posts'}</Typography>
        <Typography variant='body2' color='text.secondary'>
          {reportedOnly
            ? 'Review and moderate feed posts with reports from users.'
            : 'Browse all feed posts and remove posts that violate policies.'}
        </Typography>
      </Box>

      <Card>
        <div className='flex flex-col md:flex-row md:items-center md:justify-between gap-3 p-6'>
          <div className='flex flex-col md:flex-row gap-3 w-full'>
            <CustomTextField
              value={searchInput}
              onChange={e => setSearchInput(e.target.value)}
              onKeyDown={e => {
                if (e.key === 'Enter') {
                  handleApplySearch()
                }
              }}
              placeholder='Search content'
              className='w-full md:w-[280px]'
            />
            <CustomTextField
              select
              value={postType}
              onChange={e => {
                setPostType(e.target.value)
                setPage(1)
              }}
              className='w-full md:w-[150px]'
            >
              <MenuItem value='all'>All Types</MenuItem>
              <MenuItem value='text'>Text</MenuItem>
              <MenuItem value='image'>Image</MenuItem>
              <MenuItem value='video'>Video</MenuItem>
            </CustomTextField>
            <CustomTextField
              select
              value={pageSize}
              onChange={e => {
                setPageSize(Number(e.target.value))
                setPage(1)
              }}
              className='w-full md:w-[90px]'
            >
              <MenuItem value={10}>10</MenuItem>
              <MenuItem value={25}>25</MenuItem>
              <MenuItem value={50}>50</MenuItem>
            </CustomTextField>
          </div>

          <div className='flex gap-2'>
            <Button variant='contained' onClick={handleApplySearch}>
              Search
            </Button>
            <Button variant='tonal' color='secondary' onClick={handleResetFilters}>
              Reset
            </Button>
          </div>
        </div>

        <div className='overflow-x-auto'>
          {loading ? (
            <div className='flex justify-center items-center p-6 h-[50vh]'>
              <CircularProgress />
            </div>
          ) : (
            <table className={tableStyles.table}>
              <thead>
                <tr>
                  {columns.map(col => (
                    <th key={col}>{col}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {posts.map(post => {
                  const mediaUrl = normalizeMediaUrl(post.mediaUrl || post.mediaUrls?.[0] || '')
                  const reportStats = post.reportStats || {}

                  return (
                    <tr key={post.id || post._id}>
                      <td>
                        <div className='flex flex-col'>
                          <Typography variant='body2' className='font-medium'>
                            {post.user?.nickName || post.user?.fullName || 'Unknown'}
                          </Typography>
                          <Typography variant='caption' color='text.secondary'>
                            {post.user?.uniqueId || '-'}
                          </Typography>
                        </div>
                      </td>
                      <td>
                        <Typography variant='body2'>{shorten(post.content || '-', 130)}</Typography>
                      </td>
                      <td>
                        {mediaUrl ? (
                          post.mediaType === 'image' ? (
                            <img
                              src={mediaUrl}
                              alt='post media'
                              className='h-[56px] w-[84px] rounded object-cover border'
                            />
                          ) : (
                            <Button
                              size='small'
                              variant='tonal'
                              onClick={() => window.open(mediaUrl, '_blank', 'noopener,noreferrer')}
                            >
                              View Video
                            </Button>
                          )
                        ) : (
                          <Typography variant='body2' color='text.secondary'>
                            No media
                          </Typography>
                        )}
                      </td>
                      <td>{post.likeCount || 0}</td>
                      <td>{post.commentCount || 0}</td>
                      <td>{post.shareCount || 0}</td>
                      <td>
                        <div className='flex flex-col gap-1'>
                          <Chip size='small' color={(reportStats.totalReports || 0) > 0 ? 'error' : 'default'} label={`Total: ${reportStats.totalReports || 0}`} />
                          <Chip
                            size='small'
                            variant='outlined'
                            color={(reportStats.openReports || 0) > 0 ? 'warning' : 'default'}
                            label={`Open: ${reportStats.openReports || 0}`}
                          />
                        </div>
                      </td>
                      <td>
                        <Chip
                          size='small'
                          label={post.visibility || 'public'}
                          color={post.visibility === 'private' ? 'warning' : post.visibility === 'followers_only' ? 'info' : 'success'}
                        />
                      </td>
                      <td>{formatDate(post.createdAt)}</td>
                      <td>
                        <Tooltip title='Delete post'>
                          <IconButton onClick={() => handleDeleteClick(post)}>
                            <i className='tabler-trash text-error' />
                          </IconButton>
                        </Tooltip>
                      </td>
                    </tr>
                  )
                })}
                <EmprtyTableRow
                  limit={pageSize}
                  data={posts}
                  columns={columns}
                  noDataLebel={reportedOnly ? 'No reported feed posts found' : 'No feed posts found'}
                />
              </tbody>
            </table>
          )}
        </div>

        <TablePaginationComponent page={page} pageSize={pageSize} total={total} onPageChange={setPage} />
      </Card>

      <ConfirmationDialog
        open={deleteDialogOpen}
        onClose={() => {
          setDeleteDialogOpen(false)
          setSelectedPost(null)
          setDeleteError(null)
          setDeleting(false)
        }}
        onConfirm={handleDeleteConfirm}
        title='Are you sure you want to delete this feed post?'
        content='This action will remove the post from feed and cannot be undone.'
        type='delete-post'
        loading={deleting}
        error={deleteError}
      />
    </Box>
  )
}

export default FeedPostsTable
