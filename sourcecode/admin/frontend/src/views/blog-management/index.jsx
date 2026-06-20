'use client'

import { useEffect, useMemo, useRef, useState } from 'react'

import { usePathname, useRouter, useSearchParams } from 'next/navigation'

import { createColumnHelper, flexRender, getCoreRowModel, useReactTable } from '@tanstack/react-table'
import { useDispatch, useSelector } from 'react-redux'

import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import Chip from '@mui/material/Chip'
import CircularProgress from '@mui/material/CircularProgress'
import Dialog from '@mui/material/Dialog'
import DialogActions from '@mui/material/DialogActions'
import DialogContent from '@mui/material/DialogContent'
import DialogTitle from '@mui/material/DialogTitle'
import FormControlLabel from '@mui/material/FormControlLabel'
import Grid from '@mui/material/Grid'
import IconButton from '@mui/material/IconButton'
import MenuItem from '@mui/material/MenuItem'
import Switch from '@mui/material/Switch'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'
import { toast } from 'react-toastify'
import dynamic from 'next/dynamic'
import 'react-quill-new/dist/quill.snow.css'

import ConfirmationDialog from '@/components/dialogs/confirmation-dialog'

const ReactQuill = dynamic(() => import('react-quill-new'), { ssr: false })
import CustomTextField from '@/@core/components/mui/TextField'
import EmprtyTableRow from '@/components/common/EmprtyTableRow'
import TablePaginationComponent from '@/components/TablePaginationComponent'
import axios from 'axios'

import { baseURL, secretKey } from '@/config'
import {
  createBlogPost,
  deleteBlogPost,
  fetchBlogPosts,
  setPage,
  setPageSize,
  updateBlogPost
} from '@/redux-store/slices/blog'

import tableStyles from '@core/styles/table.module.css'

const columnHelper = createColumnHelper()

const formatDate = dateString => {
  if (!dateString) return '-'
  const date = new Date(dateString)

  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

const emptyForm = () => ({
  _id: '',
  title: '',
  slug: '',
  summary: '',
  content: '',
  author: '',
  coverImage: '',
  publishedAt: '',
  isPublished: false,
  coverImageFile: null
})

const quillFormats = [
  'header',
  'bold',
  'italic',
  'underline',
  'strike',
  'blockquote',
  'list',
  'bullet',
  'indent',
  'link',
  'image',
  'align',
  'color',
  'background',
  'font',
  'size'
]

const createQuillModules = imageHandler => ({
  toolbar: {
    container: [
      [{ header: [1, 2, 3, 4, 5, 6, false] }],
      [{ font: [] }, { size: [] }],
      ['bold', 'italic', 'underline', 'strike', 'blockquote'],
      [{ list: 'ordered' }, { list: 'bullet' }, { indent: '-1' }, { indent: '+1' }],
      [{ align: [] }],
      [{ color: [] }, { background: [] }],
      ['link', 'image'],
      ['clean']
    ],
    handlers: {
      image: imageHandler
    }
  }
})

const BlogManagement = () => {
  const dispatch = useDispatch()
  const searchParams = useSearchParams()
  const router = useRouter()
  const pathname = usePathname()

  const { items, initialLoading, loading, page, pageSize, total } = useSelector(state => state.blog)

  const [openDialog, setOpenDialog] = useState(false)
  const [mode, setMode] = useState('create')
  const [form, setForm] = useState(emptyForm())
  const [confirmOpen, setConfirmOpen] = useState(false)
  const [deleteTarget, setDeleteTarget] = useState(null)
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')

  const urlPage = parseInt(searchParams.get('page') || '1', 10)
  const urlPageSize = parseInt(searchParams.get('pageSize') || '10', 10)

  useEffect(() => {
    dispatch(
      fetchBlogPosts({
        page: urlPage,
        pageSize: urlPageSize,
        search: searchParams.get('search') || '',
        status: searchParams.get('status') || 'all'
      })
    )
  }, [dispatch, urlPage, urlPageSize, searchParams])

  const updateUrlParams = updates => {
    const params = new URLSearchParams(searchParams.toString())

    Object.entries(updates).forEach(([key, value]) => {
      if (value === undefined || value === null || value === '' || value === 'all') {
        params.delete(key)
      } else {
        params.set(key, String(value))
      }
    })

    router.replace(`${pathname}?${params.toString()}`, { scroll: false })
  }

  const handleSearch = () => {
    updateUrlParams({ search, page: 1 })
  }

  const handleStatusFilterChange = value => {
    setStatusFilter(value)
    updateUrlParams({ status: value === 'all' ? '' : value, page: 1 })
  }

  const openCreate = () => {
    setMode('create')
    setForm(emptyForm())
    setOpenDialog(true)
  }

  const openEdit = post => {
    setMode('edit')
    setForm({
      ...emptyForm(),
      _id: post._id,
      title: post.title || '',
      slug: post.slug || '',
      summary: post.summary || '',
      content: post.content || '',
      author: post.author || '',
      coverImage: post.coverImage || '',
      publishedAt: post.publishedAt ? new Date(post.publishedAt).toISOString().slice(0, 16) : '',
      isPublished: post.isPublished === true,
      coverImageFile: null
    })
    setOpenDialog(true)
  }

  const closeDialog = () => {
    setOpenDialog(false)
    setForm(emptyForm())
  }

  const handleQuillImageUpload = () => {
    const input = document.createElement('input')

    input.setAttribute('type', 'file')
    input.setAttribute('accept', 'image/*')
    input.click()

    input.onchange = async () => {
      const file = input.files?.[0]

      if (!file) return

      const uploadForm = new FormData()

      uploadForm.append('image', file)

      try {
        const token = localStorage.getItem('admin_token')
        const uid = localStorage.getItem('uid')

        const response = await axios.post(`${baseURL}/api/admin/blog/upload-image`, uploadForm, {
          headers: {
            key: secretKey,
            Authorization: token ? `Bearer ${token}` : '',
            'x-admin-uid': uid
          }
        })

        if (response.data?.status) {
          const range = quillRef?.current?.getEditor().getSelection()

          quillRef?.current?.getEditor().insertEmbed(range?.index || 0, 'image', `${baseURL}${response.data.url}`)
        } else {
          toast.error(response.data?.message || 'Image upload failed')
        }
      } catch (error) {
        toast.error(error?.response?.data?.message || 'Image upload failed')
      }
    }
  }

  const quillRef = useRef(null)
  const quillModules = useMemo(() => createQuillModules(handleQuillImageUpload), [])

  const handleSubmit = () => {
    if (!form.title.trim()) {
      toast.error('Title is required.')

      return
    }

    if (!form.content.trim() || form.content === '<p><br></p>') {
      toast.error('Content is required.')

      return
    }

    const formData = new FormData()
    formData.append('title', form.title.trim())
    formData.append('summary', form.summary.trim())
    formData.append('content', form.content.trim())
    formData.append('author', form.author.trim())
    formData.append('isPublished', String(form.isPublished))
    if (form.publishedAt) formData.append('publishedAt', form.publishedAt)

    if (form.coverImageFile) {
      formData.append('coverImage', form.coverImageFile)
    } else if (form.coverImage) {
      formData.append('coverImage', form.coverImage)
    }

    if (mode === 'edit') {
      dispatch(updateBlogPost({ postId: form._id, formData })).then(response => {
        if (response.payload?.status) {
          closeDialog()
          dispatch(fetchBlogPosts({ page: urlPage, pageSize: urlPageSize }))
        }
      })
    } else {
      dispatch(createBlogPost(formData)).then(response => {
        if (response.payload?.status) {
          closeDialog()
          dispatch(fetchBlogPosts({ page: urlPage, pageSize: urlPageSize }))
        }
      })
    }
  }

  const handleDelete = () => {
    if (!deleteTarget) return

    dispatch(deleteBlogPost(deleteTarget._id)).then(() => {
      setDeleteTarget(null)
      setConfirmOpen(false)
    })
  }

  const columns = useMemo(
    () => [
      columnHelper.accessor(row => row.coverImage, {
        id: 'coverImage',
        header: 'Cover',
        cell: ({ row }) =>
          row.original.coverImage ? (
            <img
              src={`${baseURL}/${row.original.coverImage}`}
              alt={row.original.title}
              className='w-16 h-10 object-cover rounded'
            />
          ) : (
            <Typography color='text.secondary'>-</Typography>
          )
      }),
      columnHelper.accessor(row => row.title, {
        id: 'title',
        header: 'Title',
        cell: ({ getValue }) => (
          <Typography className='max-w-[300px] truncate'>{getValue() || '-'}</Typography>
        )
      }),
      columnHelper.accessor(row => row.author, {
        id: 'author',
        header: 'Author',
        cell: ({ getValue }) => <Typography>{getValue() || '-'}</Typography>
      }),
      columnHelper.accessor(row => row.isPublished, {
        id: 'status',
        header: 'Status',
        cell: ({ getValue }) => (
          <Chip
            label={getValue() ? 'Published' : 'Draft'}
            color={getValue() ? 'success' : 'default'}
            size='small'
          />
        )
      }),
      columnHelper.accessor(row => row.publishedAt, {
        id: 'publishedAt',
        header: 'Published At',
        cell: ({ getValue }) => <Typography>{formatDate(getValue())}</Typography>
      }),
      columnHelper.accessor(row => row.createdAt, {
        id: 'createdAt',
        header: 'Created At',
        cell: ({ getValue }) => <Typography>{formatDate(getValue())}</Typography>
      }),
      columnHelper.display({
        id: 'actions',
        header: 'Actions',
        cell: ({ row }) => (
          <div className='flex gap-2'>
            <IconButton onClick={() => openEdit(row.original)}>
              <i className='tabler-edit text-primary' />
            </IconButton>
            <IconButton
              onClick={() => {
                setDeleteTarget(row.original)
                setConfirmOpen(true)
              }}
            >
              <i className='tabler-trash text-error' />
            </IconButton>
          </div>
        )
      })
    ],
    []
  )

  const table = useReactTable({
    data: items,
    columns,
    getCoreRowModel: getCoreRowModel()
  })

  const updateUrlPagination = (nextPage, nextPageSize) => {
    updateUrlParams({
      page: nextPage === 1 ? '' : nextPage,
      pageSize: nextPageSize === 10 ? '' : nextPageSize
    })
  }

  const handleRowsPerPageChange = e => {
    const nextPageSize = parseInt(e.target.value, 10)

    dispatch(setPageSize(nextPageSize))
    dispatch(setPage(1))
    updateUrlPagination(1, nextPageSize)
  }

  const handlePageChange = nextPage => {
    dispatch(setPage(nextPage))
    updateUrlPagination(nextPage, searchParams.get('pageSize') ? parseInt(searchParams.get('pageSize'), 10) : pageSize)
  }

  return (
    <>
      <Box className='mb-3'>
        <Typography variant='h4'>Blog / News</Typography>
        <Typography variant='body2' color='text.secondary'>
          Create, edit, and manage blog posts and news articles.
        </Typography>
      </Box>

      <Card>
        <div className='flex justify-between flex-col md:flex-row md:items-center p-6 gap-4'>
          <div className='flex items-center gap-4 flex-wrap'>
            <CustomTextField
              select
              value={searchParams.get('pageSize') || 10}
              onChange={handleRowsPerPageChange}
              className='max-sm:is-full sm:is-[70px]'
            >
              <MenuItem value='10'>10</MenuItem>
              <MenuItem value='25'>25</MenuItem>
              <MenuItem value='50'>50</MenuItem>
            </CustomTextField>

            <CustomTextField
              select
              value={statusFilter}
              onChange={e => handleStatusFilterChange(e.target.value)}
              className='max-sm:is-full sm:is-[140px]'
              label='Status'
            >
              <MenuItem value='all'>All</MenuItem>
              <MenuItem value='published'>Published</MenuItem>
              <MenuItem value='draft'>Draft</MenuItem>
            </CustomTextField>

            <div className='flex items-center gap-2'>
              <TextField
                placeholder='Search posts...'
                value={search}
                onChange={e => setSearch(e.target.value)}
                onKeyDown={e => e.key === 'Enter' && handleSearch()}
                className='min-w-[220px]'
                size='small'
              />
              <Button variant='outlined' onClick={handleSearch}>
                Search
              </Button>
            </div>
          </div>

          <Button variant='contained' onClick={openCreate} startIcon={<i className='tabler-plus' />}>
            Create Post
          </Button>
        </div>

        <div className='overflow-x-auto'>
          {initialLoading ? (
            <div className='flex justify-center items-center p-6 h-[55vh]'>
              <CircularProgress />
            </div>
          ) : (
            <table className={tableStyles.table}>
              <thead>
                {table.getHeaderGroups().map(headerGroup => (
                  <tr key={headerGroup.id}>
                    {headerGroup.headers.map(header => (
                      <th key={header.id}>
                        {header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}
                      </th>
                    ))}
                  </tr>
                ))}
              </thead>
              <tbody>
                {table.getRowModel().rows.map(row => (
                  <tr key={row.id}>
                    {row.getVisibleCells().map(cell => (
                      <td key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</td>
                    ))}
                  </tr>
                ))}
                <EmprtyTableRow limit={urlPageSize} data={items} columns={columns} noDataLebel='No blog posts found' />
              </tbody>
            </table>
          )}
        </div>

        <TablePaginationComponent
          page={searchParams.get('page') ? parseInt(searchParams.get('page'), 10) : page}
          pageSize={searchParams.get('pageSize') ? parseInt(searchParams.get('pageSize'), 10) : pageSize}
          total={total}
          onPageChange={handlePageChange}
        />
      </Card>

      <Dialog open={openDialog} onClose={closeDialog} maxWidth='md' fullWidth>
        <DialogTitle>{mode === 'edit' ? 'Edit Blog Post' : 'Create Blog Post'}</DialogTitle>
        <DialogContent dividers>
          <Grid container spacing={4} className='pt-2'>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label='Title'
                value={form.title}
                onChange={e => setForm(prev => ({ ...prev, title: e.target.value }))}
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                label='Author'
                value={form.author}
                onChange={e => setForm(prev => ({ ...prev, author: e.target.value }))}
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                label='Published At'
                type='datetime-local'
                value={form.publishedAt}
                onChange={e => setForm(prev => ({ ...prev, publishedAt: e.target.value }))}
                InputLabelProps={{ shrink: true }}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label='Summary'
                multiline
                rows={2}
                value={form.summary}
                onChange={e => setForm(prev => ({ ...prev, summary: e.target.value }))}
              />
            </Grid>
            <Grid item xs={12}>
              <Typography variant='body2' className='mb-2'>
                Content
              </Typography>
              <div className='blog-editor'>
                <ReactQuill
                  ref={quillRef}
                  theme='snow'
                  value={form.content}
                  onChange={value => setForm(prev => ({ ...prev, content: value }))}
                  modules={quillModules}
                  formats={quillFormats}
                  placeholder='Write your blog post content here...'
                  style={{ height: '300px', marginBottom: '50px' }}
                />
              </div>
            </Grid>
            <Grid item xs={12}>
              <Button variant='outlined' component='label'>
                {form.coverImageFile ? 'Change Cover Image' : 'Upload Cover Image'}
                <input
                  type='file'
                  hidden
                  accept='image/*'
                  onChange={e => {
                    const file = e.target.files?.[0]

                    if (file) {
                      setForm(prev => ({ ...prev, coverImageFile: file, coverImage: '' }))
                    }
                  }}
                />
              </Button>
              {form.coverImageFile && (
                <Typography variant='body2' className='mt-2'>
                  Selected: {form.coverImageFile.name}
                </Typography>
              )}
              {!form.coverImageFile && form.coverImage && (
                <img
                  src={`${baseURL}/${form.coverImage}`}
                  alt='Cover'
                  className='mt-2 w-32 h-20 object-cover rounded'
                />
              )}
            </Grid>
            <Grid item xs={12}>
              <FormControlLabel
                control={
                  <Switch
                    checked={form.isPublished}
                    onChange={e => setForm(prev => ({ ...prev, isPublished: e.target.checked }))}
                  />
                }
                label='Publish immediately'
              />
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={closeDialog}>Cancel</Button>
          <Button variant='contained' onClick={handleSubmit} disabled={loading}>
            {loading ? 'Saving...' : 'Save'}
          </Button>
        </DialogActions>
      </Dialog>

      <ConfirmationDialog
        open={confirmOpen}
        onClose={() => {
          setConfirmOpen(false)
          setDeleteTarget(null)
        }}
        onConfirm={handleDelete}
        title='Delete blog post?'
        content={`This will permanently remove "${deleteTarget?.title || 'this post'}".`}
        loading={loading}
      />
    </>
  )
}

export default BlogManagement
