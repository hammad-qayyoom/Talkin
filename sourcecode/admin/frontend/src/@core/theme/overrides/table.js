const table = {
  MuiTableContainer: {
    styleOverrides: {
      root: {
        borderRadius: 'var(--mui-shape-customBorderRadius-lg)',
        border: '1px solid var(--mui-palette-divider)',
        backgroundColor: 'var(--mui-palette-background-paper)'
      }
    }
  },
  MuiTableHead: {
    styleOverrides: {
      root: {
        backgroundColor: 'var(--mui-palette-customColors-tableHeaderBg)'
      }
    }
  },
  MuiTableRow: {
    styleOverrides: {
      root: {
        '&:last-child .MuiTableCell-root': {
          borderBlockEnd: 0
        },
        '&.MuiTableRow-hover:hover': {
          backgroundColor: 'var(--mui-palette-action-hover)'
        }
      }
    }
  },
  MuiTableCell: {
    styleOverrides: {
      root: ({ theme }) => ({
        borderColor: 'var(--mui-palette-divider)',
        padding: theme.spacing(3, 4)
      }),
      head: ({ theme }) => ({
        fontSize: theme.typography.caption.fontSize,
        fontWeight: 800,
        lineHeight: 1.4,
        letterSpacing: '0.5px',
        color: 'var(--mui-palette-text-secondary)',
        textTransform: 'uppercase',
        borderBlockEnd: '1px solid var(--mui-palette-divider)'
      }),
      body: ({ theme }) => ({
        fontSize: theme.typography.body2.fontSize,
        color: 'var(--mui-palette-text-primary)'
      })
    }
  },
  MuiTableSortLabel: {
    styleOverrides: {
      root: {
        color: 'inherit',
        '&.Mui-active': {
          color: 'var(--mui-palette-primary-main)'
        },
        '&:hover': {
          color: 'var(--mui-palette-primary-main)'
        }
      }
    }
  }
}

export default table
