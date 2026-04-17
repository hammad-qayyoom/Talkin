const tablePagination = {
  MuiTablePagination: {
    styleOverrides: {
      toolbar: ({ theme }) => ({
        minHeight: '58px',
        paddingInline: `${theme.spacing(4)} !important`,
        borderBlockStart: '1px solid var(--mui-palette-divider)',
        backgroundColor: 'rgb(var(--mui-palette-background-paperChannel) / 0.72)'
      }),
      displayedRows: {
        fontWeight: 600,
        color: 'var(--mui-palette-text-secondary)'
      },
      actions: {
        '& .MuiIconButton-root': {
          borderRadius: 10
        }
      },
      select: {
        '& ~ i, & ~ svg': {
          right: '2px !important'
        }
      }
    }
  }
}

export default tablePagination
