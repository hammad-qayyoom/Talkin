// Next Imports
import { Manrope } from 'next/font/google'

// Theme Options Imports
import overrides from './overrides'
import colorSchemes from './colorSchemes'
import spacing from './spacing'
import shadows from './shadows'
import customShadows from './customShadows'
import typography from './typography'

const manrope = Manrope({ subsets: ['latin'], weight: ['400', '500', '600', '700', '800'] })

const theme = (settings, mode, direction) => {
  return {
    direction,
    components: overrides(settings.skin),
    colorSchemes: colorSchemes(settings.skin),
    ...spacing,
    shape: {
      borderRadius: 12,
      customBorderRadius: {
        xs: 6,
        sm: 8,
        md: 12,
        lg: 16,
        xl: 20
      }
    },
    shadows: shadows(mode),
    typography: typography(manrope.style.fontFamily),
    customShadows: customShadows(mode),
    mainColorChannels: {
      light: '17 24 39',
      dark: '241 245 249',
      lightShadow: '15 23 42',
      darkShadow: '2 6 23'
    }
  }
}

export default theme
