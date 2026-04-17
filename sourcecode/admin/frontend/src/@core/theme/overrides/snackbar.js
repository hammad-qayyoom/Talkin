const snackbar = skin => ({
  MuiSnackbarContent: {
    styleOverrides: {
      root: ({ theme }) => ({
        padding: theme.spacing(0, 4),
        borderRadius: 12,
        border: '1px solid var(--mui-palette-divider)',
        ...(skin !== 'bordered'
          ? {
              boxShadow: 'var(--mui-customShadows-sm)'
            }
          : {
              boxShadow: 'none'
            }),
        '& .MuiSnackbarContent-message': {
          paddingBlock: theme.spacing(3)
        }
      })
    }
  }
})

export default snackbar
