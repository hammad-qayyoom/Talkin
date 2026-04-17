const customShadows = mode => {
  return {
    xs: `0px 1px 3px rgb(var(--mui-mainColorChannels-${mode}Shadow) / ${mode === 'light' ? 0.08 : 0.2})`,
    sm: `0px 6px 16px rgb(var(--mui-mainColorChannels-${mode}Shadow) / ${mode === 'light' ? 0.08 : 0.22})`,
    md: `0px 10px 24px rgb(var(--mui-mainColorChannels-${mode}Shadow) / ${mode === 'light' ? 0.1 : 0.24})`,
    lg: `0px 16px 36px rgb(var(--mui-mainColorChannels-${mode}Shadow) / ${mode === 'light' ? 0.12 : 0.26})`,
    xl: `0px 24px 52px rgb(var(--mui-mainColorChannels-${mode}Shadow) / ${mode === 'light' ? 0.14 : 0.3})`,
    primary: {
      sm: '0px 8px 18px rgb(var(--mui-palette-primary-mainChannel) / 0.28)',
      md: '0px 12px 28px rgb(var(--mui-palette-primary-mainChannel) / 0.34)',
      lg: '0px 18px 36px rgb(var(--mui-palette-primary-mainChannel) / 0.4)'
    },
    secondary: {
      sm: '0px 2px 6px rgb(var(--mui-palette-secondary-mainChannel) / 0.3)',
      md: '0px 4px 16px rgb(var(--mui-palette-secondary-mainChannel) / 0.4)',
      lg: '0px 6px 20px rgb(var(--mui-palette-secondary-mainChannel) / 0.5)'
    },
    error: {
      sm: '0px 2px 6px rgb(var(--mui-palette-error-mainChannel) / 0.3)',
      md: '0px 4px 16px rgb(var(--mui-palette-error-mainChannel) / 0.4)',
      lg: '0px 6px 20px rgb(var(--mui-palette-error-mainChannel) / 0.5)'
    },
    warning: {
      sm: '0px 2px 6px rgb(var(--mui-palette-warning-mainChannel) / 0.3)',
      md: '0px 4px 16px rgb(var(--mui-palette-warning-mainChannel) / 0.4)',
      lg: '0px 6px 20px rgb(var(--mui-palette-warning-mainChannel) / 0.5)'
    },
    info: {
      sm: '0px 2px 6px rgb(var(--mui-palette-info-mainChannel) / 0.3)',
      md: '0px 4px 16px rgb(var(--mui-palette-info-mainChannel) / 0.4)',
      lg: '0px 6px 20px rgb(var(--mui-palette-info-mainChannel) / 0.5)'
    },
    success: {
      sm: '0px 2px 6px rgb(var(--mui-palette-success-mainChannel) / 0.3)',
      md: '0px 4px 16px rgb(var(--mui-palette-success-mainChannel) / 0.4)',
      lg: '0px 6px 20px rgb(var(--mui-palette-success-mainChannel) / 0.5)'
    }
  }
}

export default customShadows
