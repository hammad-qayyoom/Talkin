// Util Imports
import { menuClasses, verticalNavClasses } from '@menu/utils/menuClasses'

const navigationCustomStyles = (verticalNavOptions, theme) => {
  // Vars
  const { collapsedWidth, isCollapsed, isHovered, transitionDuration } = verticalNavOptions
  const collapsedHovered = isCollapsed && isHovered
  const collapsedNotHovered = isCollapsed && !isHovered

  return {
    color: 'var(--mui-palette-text-primary)',
    zIndex: 'var(--drawer-z-index) !important',
    [`& .${verticalNavClasses.header}`]: {
      paddingBlock: theme.spacing(4.5),
      paddingInline: theme.spacing(4, 3.5),
      borderBlockEnd: '1px solid var(--mui-palette-divider)',
      ...(collapsedNotHovered && {
        paddingInline: theme.spacing((collapsedWidth - 35) / 8),
        '& a': {
          transform: `translateX(-${22 - (collapsedWidth - 29) / 2}px)`
        }
      }),
      '& a': {
        transition: `transform ${transitionDuration}ms ease`
      }
    },
    [`& .${verticalNavClasses.container}`]: {
      transition: theme.transitions.create(['inline-size', 'inset-inline-start', 'box-shadow'], {
        duration: transitionDuration,
        easing: 'ease-in-out'
      }),
      borderRadius: 20,
      overflow: 'hidden',
      border: '1px solid var(--mui-palette-divider)',
      backgroundColor: 'var(--mui-palette-background-paper)',
      boxShadow: 'var(--mui-customShadows-md)',
      '[data-skin="bordered"] &': {
        boxShadow: 'none',
        ...(collapsedHovered && {
          boxShadow: 'var(--mui-customShadows-md)'
        }),
        borderColor: 'var(--mui-palette-divider)'
      }
    },
    [`& .${menuClasses.root}`]: {
      paddingBlock: theme.spacing(2.25),
      paddingInline: theme.spacing(2.5)
    },
    [`& .${verticalNavClasses.backdrop}`]: {
      backgroundColor: 'var(--backdrop-color)'
    }
  }
}

export default navigationCustomStyles
