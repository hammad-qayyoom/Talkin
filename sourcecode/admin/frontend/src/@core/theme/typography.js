const typography = fontFamily => ({
  fontFamily:
    typeof fontFamily === 'undefined' || fontFamily === ''
      ? [
          '"Manrope"',
          'sans-serif',
          '-apple-system',
          'BlinkMacSystemFont',
          '"Segoe UI"',
          'Roboto',
          '"Helvetica Neue"',
          'Arial',
          'sans-serif',
          '"Apple Color Emoji"',
          '"Segoe UI Emoji"',
          '"Segoe UI Symbol"'
        ].join(',')
      : fontFamily,
  fontSize: 14,
  h1: {
    fontSize: '3rem',
    fontWeight: 700,
    lineHeight: 1.2
  },
  h2: {
    fontSize: '2.5rem',
    fontWeight: 700,
    lineHeight: 1.22
  },
  h3: {
    fontSize: '2rem',
    fontWeight: 700,
    lineHeight: 1.25
  },
  h4: {
    fontSize: '1.5rem',
    fontWeight: 700,
    lineHeight: 1.3
  },
  h5: {
    fontSize: '1.125rem',
    fontWeight: 700,
    lineHeight: 1.35
  },
  h6: {
    fontSize: '1rem',
    fontWeight: 700,
    lineHeight: 1.35
  },
  subtitle1: {
    fontSize: '1rem',
    fontWeight: 600,
    lineHeight: 1.4
  },
  subtitle2: {
    fontSize: '0.875rem',
    fontWeight: 600,
    lineHeight: 1.4
  },
  body1: {
    fontSize: '0.9375rem',
    lineHeight: 1.55
  },
  body2: {
    fontSize: '0.875rem',
    lineHeight: 1.5
  },
  button: {
    fontSize: '0.9375rem',
    fontWeight: 700,
    lineHeight: 1.2,
    textTransform: 'none'
  },
  caption: {
    fontSize: '0.8125rem',
    lineHeight: 1.4,
    letterSpacing: '0.4px'
  },
  overline: {
    fontSize: '0.75rem',
    lineHeight: 1.16667,
    letterSpacing: '0.8px'
  }
})

export default typography
