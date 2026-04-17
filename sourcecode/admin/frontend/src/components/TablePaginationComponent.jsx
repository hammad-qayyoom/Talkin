// MUI Imports
import Box from '@mui/material/Box'
import Pagination from '@mui/material/Pagination'
import Typography from '@mui/material/Typography'

/**
 * TablePaginationComponent - A reusable pagination component for tables
 *
 * @param {Object} props
 * @param {Object} [props.table] - Optional table instance from useReactTable
 * @param {number} props.page - Current page number (1-indexed)
 * @param {number} props.pageSize - Number of items per page
 * @param {number} props.total - Total number of items
 * @param {Function} props.onPageChange - Callback when page changes, receives the new page number (1-indexed)
 * @param {string} [props.customText] - Optional custom text to display instead of default pagination info
 */
const TablePaginationComponent = ({ table: _table, page, pageSize, total, onPageChange, customText }) => {
  // Handle page change
  const handlePageChange = (_, newPage) => {
    if (onPageChange) {
      onPageChange(newPage)
    }
  }

  const startEntry = total === 0 ? 0 : (page - 1) * pageSize + 1
  const endEntry = Math.min(page * pageSize, total)
  const totalPages = Math.max(1, Math.ceil(total / pageSize))

  return (
    <Box
      sx={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        flexWrap: 'wrap',
        gap: 2,
        px: 4,
        py: 1.5,
        borderTop: '1px solid var(--mui-palette-divider)',
        backgroundColor: 'rgb(var(--mui-palette-background-paperChannel) / 0.72)'
      }}
    >
      <Typography variant='body2' color='text.secondary' sx={{ fontWeight: 600 }}>
        {customText || `Showing ${startEntry} to ${endEntry} of ${total} entries`}
      </Typography>
      <Pagination
        shape='rounded'
        color='primary'
        variant='tonal'
        count={totalPages}
        page={page}
        onChange={handlePageChange}
        showFirstButton
        showLastButton
        sx={{
          '& .MuiPaginationItem-root': {
            fontWeight: 700
          }
        }}
      />
    </Box>
  )
}

export default TablePaginationComponent
