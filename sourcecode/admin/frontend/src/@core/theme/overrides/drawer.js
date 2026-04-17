const drawer = skin => ({
  MuiDrawer: {
    defaultProps: {
      ...(skin === 'bordered' && {
        PaperProps: {
          elevation: 0
        }
      })
    },
    styleOverrides: {
      paper: {
        border: '1px solid var(--mui-palette-divider)',
        borderRadius: 18,
        ...(skin !== 'bordered' && {
          boxShadow: 'var(--mui-customShadows-lg)'
        })
      }
    }
  }
})

export default drawer
