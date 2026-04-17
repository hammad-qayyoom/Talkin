// Util Imports
import { menuClasses } from '@menu/utils/menuClasses'

const menuSectionStyles = (verticalNavOptions, theme) => {
  // Vars
  const { isCollapsed, isHovered } = verticalNavOptions
  const collapsedNotHovered = isCollapsed && !isHovered

  return {
    root: {
      marginBlockStart: theme.spacing(0),
      [`& .${menuClasses.menuSectionContent}`]: {
        color: 'var(--mui-palette-text-secondary)',
        paddingInline: '12px !important',
        paddingBlock: `${theme.spacing(collapsedNotHovered ? 3.625 : 1.25)} !important`,
        marginBlockStart: theme.spacing(2.5),
        '&:before': {
          content: '""',
          blockSize: 1,
          inlineSize: '1.375rem',
          backgroundColor: 'var(--mui-palette-divider)'
        },
        ...(!collapsedNotHovered && {
          '&:before': {
            content: 'none'
          }
        }),
        [`& .${menuClasses.menuSectionLabel}`]: {
          flexGrow: 0,
          textTransform: 'uppercase',
          fontSize: '11px',
          fontWeight: 700,
          lineHeight: 1.4,
          letterSpacing: '0.8px',
          ...(collapsedNotHovered && {
            display: 'none'
          })
        }
      }
    }
  }
}

export default menuSectionStyles
