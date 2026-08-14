'use client'

import { useState, useEffect, useCallback } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Typography from '@mui/material/Typography'
import Box from '@mui/material/Box'
import TextField from '@mui/material/TextField'
import IconButton from '@mui/material/IconButton'
import Button from '@mui/material/Button'
import List from '@mui/material/List'
import ListItem from '@mui/material/ListItem'
import ListItemIcon from '@mui/material/ListItemIcon'
import ListItemText from '@mui/material/ListItemText'
import ListItemSecondaryAction from '@mui/material/ListItemSecondaryAction'
import Breadcrumbs from '@mui/material/Breadcrumbs'
import Link from '@mui/material/Link'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'
import DialogContentText from '@mui/material/DialogContentText'
import CircularProgress from '@mui/material/CircularProgress'
import Chip from '@mui/material/Chip'
import Menu from '@mui/material/Menu'
import MenuItem from '@mui/material/MenuItem'
import Divider from '@mui/material/Divider'

import {
  fetchFiles, readFile, writeFile, createDirectory,
  deleteFileOrDir, renameFileOrDir, searchFiles, clearFileContent
} from '@/redux-store/slices/serverManagement'

export default function FileManager() {
  const dispatch = useDispatch()
  const { files, fileContent, searchResults, loading } = useSelector(state => state.serverManagement)

  const [currentPath, setCurrentPath] = useState('/home')
  const [selectedFile, setSelectedFile] = useState(null)
  const [fileContentText, setFileContentText] = useState('')
  const [editMode, setEditMode] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const [isSearching, setIsSearching] = useState(false)
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
  const [deleteTarget, setDeleteTarget] = useState(null)
  const [newDirDialogOpen, setNewDirDialogOpen] = useState(false)
  const [newDirName, setNewDirName] = useState('')
  const [renameDialogOpen, setRenameDialogOpen] = useState(false)
  const [renameTarget, setRenameTarget] = useState(null)
  const [renameValue, setRenameValue] = useState('')
  const [contextMenu, setContextMenu] = useState(null)

  const loadDir = useCallback((path) => {
    setCurrentPath(path)
    setIsSearching(false)
    setSearchQuery('')
    dispatch(fetchFiles(path))
  }, [dispatch])

  useEffect(() => {
    loadDir(currentPath)
  }, [])

  useEffect(() => {
    if (fileContent) {
      setFileContentText(fileContent.content || '')
      setEditMode(false)
    }
  }, [fileContent])

  const handleBreadcrumbClick = (path) => {
    loadDir(path)
    setSelectedFile(null)
    setEditMode(false)
  }

  const handleItemClick = (item) => {
    if (item.isDirectory) {
      loadDir(item.path)
      setSelectedFile(null)
    } else {
      setSelectedFile(item)
      dispatch(readFile(item.path))
    }
  }

  const handleSave = () => {
    if (selectedFile) {
      dispatch(writeFile({ path: selectedFile.path, content: fileContentText }))
      setEditMode(false)
    }
  }

  const handleSearch = () => {
    if (searchQuery.trim()) {
      setIsSearching(true)
      dispatch(searchFiles({ path: currentPath, query: searchQuery }))
    }
  }

  const handleDelete = () => {
    if (deleteTarget) {
      dispatch(deleteFileOrDir(deleteTarget.path))
      setDeleteDialogOpen(false)
      setDeleteTarget(null)
      if (selectedFile?.path === deleteTarget.path) {
        setSelectedFile(null)
        dispatch(clearFileContent())
      }
      loadDir(currentPath)
    }
  }

  const handleCreateDir = () => {
    if (newDirName) {
      const fullPath = currentPath === '/' ? `/${newDirName}` : `${currentPath}/${newDirName}`
      dispatch(createDirectory(fullPath))
      setNewDirDialogOpen(false)
      setNewDirName('')
      loadDir(currentPath)
    }
  }

  const handleRename = () => {
    if (renameTarget && renameValue) {
      const dir = renameTarget.path.substring(0, renameTarget.path.lastIndexOf('/'))
      const newPath = dir === '/' ? `/${renameValue}` : `${dir}/${renameValue}`
      dispatch(renameFileOrDir({ oldPath: renameTarget.path, newPath }))
      setRenameDialogOpen(false)
      setRenameTarget(null)
      setRenameValue('')
      loadDir(currentPath)
    }
  }

  const handleContextMenu = (e, item) => {
    e.preventDefault()
    setContextMenu({ mouseX: e.clientX, mouseY: e.clientY, item })
  }

  const formatSize = (bytes) => {
    if (!bytes) return '0 B'
    const k = 1024
    const sizes = ['B', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return `${parseFloat((bytes / Math.pow(k, i)).toFixed(1))} ${sizes[i]}`
  }

  const pathParts = currentPath.split('/').filter(Boolean)

  return (
    <Box sx={{ p: 4 }}>
      <Typography variant='h4' fontWeight='bold' sx={{ mb: 1 }}>File Manager</Typography>
      <Typography variant='body2' color='text.secondary' sx={{ mb: 3 }}>
        Browse and manage server files securely
      </Typography>

      <Card>
        <CardContent>
          {/* Toolbar */}
          <Box sx={{ display: 'flex', gap: 2, mb: 3, alignItems: 'center', flexWrap: 'wrap' }}>
            <TextField
              size='small'
              placeholder='Search files...'
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
              sx={{ minWidth: 250 }}
            />
            <Button variant='outlined' onClick={handleSearch}>Search</Button>
            <Button variant='outlined' startIcon={<i className='tabler-folder-plus' />} onClick={() => setNewDirDialogOpen(true)}>
              New Folder
            </Button>
            <Button variant='outlined' onClick={() => loadDir(currentPath)}>
              <i className='tabler-refresh' />
            </Button>
            <Chip label={currentPath} size='small' />
          </Box>

          {/* Breadcrumbs */}
          <Breadcrumbs sx={{ mb: 2 }}>
            <Link
              component='button'
              variant='body2'
              onClick={() => handleBreadcrumbClick('/')}
              sx={{ cursor: 'pointer' }}
            >
              /
            </Link>
            {pathParts.map((part, i) => {
              const path = '/' + pathParts.slice(0, i + 1).join('/')
              return (
                <Link
                  key={i}
                  component='button'
                  variant='body2'
                  onClick={() => handleBreadcrumbClick(path)}
                  sx={{ cursor: 'pointer' }}
                >
                  {part}
                </Link>
              )
            })}
          </Breadcrumbs>

          <Box sx={{ display: 'flex', gap: 3 }}>
            {/* File List */}
            <Box sx={{ flex: 2, maxHeight: 600, overflow: 'auto' }}>
              {loading ? (
                <Box sx={{ display: 'flex', justifyContent: 'center', py: 5 }}>
                  <CircularProgress />
                </Box>
              ) : isSearching ? (
                <List dense>
                  {searchResults.map((item, i) => (
                    <ListItem
                      key={i}
                      button
                      onClick={() => handleItemClick({ ...item, isDirectory: false })}
                      onContextMenu={(e) => handleContextMenu(e, item)}
                    >
                      <ListItemIcon><i className='tabler-file' /></ListItemIcon>
                      <ListItemText primary={item.name} secondary={item.path} />
                    </ListItem>
                  ))}
                  {searchResults.length === 0 && (
                    <Typography variant='body2' color='text.secondary' sx={{ textAlign: 'center', py: 3 }}>
                      No results found
                    </Typography>
                  )}
                </List>
              ) : (
                <List dense>
                  {currentPath !== '/' && (
                    <ListItem button onClick={() => {
                      const parent = currentPath.substring(0, currentPath.lastIndexOf('/')) || '/'
                      handleBreadcrumbClick(parent)
                    }}>
                      <ListItemIcon><i className='tabler-arrow-up' /></ListItemIcon>
                      <ListItemText primary='..' secondary='Parent directory' />
                    </ListItem>
                  )}
                  {files.items?.map((item, i) => (
                    <ListItem
                      key={i}
                      button
                      selected={selectedFile?.path === item.path}
                      onClick={() => handleItemClick(item)}
                      onContextMenu={(e) => handleContextMenu(e, item)}
                    >
                      <ListItemIcon>
                        <i className={item.isDirectory ? 'tabler-folder' : 'tabler-file'} style={{ color: item.isDirectory ? '#ffa726' : '#42a5f5' }} />
                      </ListItemIcon>
                      <ListItemText
                        primary={item.name}
                        secondary={`${item.permissions} | ${formatSize(item.size)} | ${item.modified}`}
                      />
                      <ListItemSecondaryAction>
                        <IconButton size='small' onClick={(e) => { e.stopPropagation(); handleContextMenu(e, item) }}>
                          <i className='tabler-dots-vertical' />
                        </IconButton>
                      </ListItemSecondaryAction>
                    </ListItem>
                  ))}
                  {(!files.items || files.items.length === 0) && (
                    <Typography variant='body2' color='text.secondary' sx={{ textAlign: 'center', py: 3 }}>
                      Empty directory
                    </Typography>
                  )}
                </List>
              )}
            </Box>

            {/* File Preview */}
            {selectedFile && fileContent && (
              <Box sx={{ flex: 3, maxHeight: 600, overflow: 'auto' }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                  <Typography variant='subtitle1' fontWeight='bold'>{selectedFile.name}</Typography>
                  <Box sx={{ display: 'flex', gap: 1 }}>
                    {editMode ? (
                      <>
                        <Button variant='contained' size='small' onClick={handleSave}>Save</Button>
                        <Button variant='outlined' size='small' onClick={() => setEditMode(false)}>Cancel</Button>
                      </>
                    ) : (
                      <Button variant='outlined' size='small' onClick={() => setEditMode(true)}>
                        <i className='tabler-edit' style={{ marginRight: 4 }} /> Edit
                      </Button>
                    )}
                  </Box>
                </Box>
                {editMode ? (
                  <TextField
                    fullWidth
                    multiline
                    minRows={20}
                    value={fileContentText}
                    onChange={(e) => setFileContentText(e.target.value)}
                    sx={{ fontFamily: 'monospace', fontSize: 13 }}
                  />
                ) : (
                  <Box
                    component='pre'
                    sx={{
                      p: 2,
                      bgcolor: 'grey.900',
                      color: 'grey.100',
                      borderRadius: 1,
                      overflow: 'auto',
                      fontSize: 13,
                      fontFamily: 'monospace',
                      whiteSpace: 'pre-wrap',
                      wordBreak: 'break-all'
                    }}
                  >
                    {fileContent.content || 'Empty file'}
                  </Box>
                )}
              </Box>
            )}
          </Box>
        </CardContent>
      </Card>

      {/* Context Menu */}
      <Menu
        open={contextMenu !== null}
        onClose={() => setContextMenu(null)}
        anchorReference='anchorPosition'
        anchorPosition={contextMenu ? { top: contextMenu.mouseY, left: contextMenu.mouseX } : undefined}
      >
        <MenuItem onClick={() => {
          if (contextMenu?.item) handleItemClick(contextMenu.item)
          setContextMenu(null)
        }}>
          <i className='tabler-eye' style={{ marginRight: 8 }} /> Open
        </MenuItem>
        <MenuItem onClick={() => {
          if (contextMenu?.item) {
            setRenameTarget(contextMenu.item)
            setRenameValue(contextMenu.item.name)
            setRenameDialogOpen(true)
          }
          setContextMenu(null)
        }}>
          <i className='tabler-pencil' style={{ marginRight: 8 }} /> Rename
        </MenuItem>
        <Divider />
        <MenuItem onClick={() => {
          if (contextMenu?.item) {
            setDeleteTarget(contextMenu.item)
            setDeleteDialogOpen(true)
          }
          setContextMenu(null)
        }} sx={{ color: 'error.main' }}>
          <i className='tabler-trash' style={{ marginRight: 8 }} /> Delete
        </MenuItem>
      </Menu>

      {/* Delete Confirmation Dialog */}
      <Dialog open={deleteDialogOpen} onClose={() => setDeleteDialogOpen(false)}>
        <DialogTitle>Confirm Delete</DialogTitle>
        <DialogContent>
          <DialogContentText>
            Are you sure you want to delete "{deleteTarget?.name}"? This action cannot be undone.
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialogOpen(false)}>Cancel</Button>
          <Button color='error' onClick={handleDelete}>Delete</Button>
        </DialogActions>
      </Dialog>

      {/* New Directory Dialog */}
      <Dialog open={newDirDialogOpen} onClose={() => setNewDirDialogOpen(false)}>
        <DialogTitle>Create New Folder</DialogTitle>
        <DialogContent>
          <TextField
            autoFocus
            fullWidth
            label='Folder Name'
            value={newDirName}
            onChange={(e) => setNewDirName(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleCreateDir()}
            sx={{ mt: 1 }}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setNewDirDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleCreateDir}>Create</Button>
        </DialogActions>
      </Dialog>

      {/* Rename Dialog */}
      <Dialog open={renameDialogOpen} onClose={() => setRenameDialogOpen(false)}>
        <DialogTitle>Rename</DialogTitle>
        <DialogContent>
          <TextField
            autoFocus
            fullWidth
            label='New Name'
            value={renameValue}
            onChange={(e) => setRenameValue(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleRename()}
            sx={{ mt: 1 }}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setRenameDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleRename}>Rename</Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
