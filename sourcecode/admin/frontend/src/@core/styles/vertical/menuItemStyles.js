// Util Imports
import { menuClasses } from '@menu/utils/menuClasses'

const menuItemStyles = (verticalNavOptions, theme) => {
  // Vars
  const { isCollapsed, isHovered, isPopoutWhenCollapsed, transitionDuration } = verticalNavOptions
  const popoutCollapsed = isPopoutWhenCollapsed && isCollapsed
  const popoutExpanded = isPopoutWhenCollapsed && !isCollapsed
  const collapsedNotHovered = isCollapsed && !isHovered

  return {
    root: ({ level }) => ({
      ...(!isPopoutWhenCollapsed || popoutExpanded || (popoutCollapsed && level === 0)
        ? {
            marginBlockStart: theme.spacing(1)
          }
        : {
            marginBlockStart: 0
          }),
      [`&.${menuClasses.subMenuRoot}.${menuClasses.open} > .${menuClasses.button}, &.${menuClasses.subMenuRoot} > .${menuClasses.button}.${menuClasses.active}`]:
        {
          backgroundColor: 'var(--mui-palette-primary-lightOpacity) !important'
        },
      [`&.${menuClasses.disabled} > .${menuClasses.button}`]: {
        color: 'var(--mui-palette-text-disabled)',
        '& *': {
          color: 'inherit'
        }
      },
      [`&:not(.${menuClasses.subMenuRoot}) > .${menuClasses.button}.${menuClasses.active}`]: {
        ...(popoutCollapsed && level > 0
          ? {
              backgroundColor: 'var(--mui-palette-primary-lightOpacity)',
              color: 'var(--mui-palette-primary-main)',
              [`& .${menuClasses.icon}`]: {
                color: 'var(--mui-palette-primary-main)'
              }
            }
          : {
              color: 'var(--mui-palette-primary-contrastText)',
              background: 'var(--mui-palette-primary-main) !important',
              boxShadow: 'var(--mui-customShadows-primary-sm)',
              [`& .${menuClasses.icon}`]: {
                color: 'inherit'
              }
            })
      }
    }),
    button: ({ level, active }) => ({
      paddingBlock: '10px',
      paddingInline: '14px',
      borderRadius: 'var(--border-radius)',
      ...(!(isCollapsed && !isHovered) && {
        '&:has(.MuiChip-root)': {
          paddingBlock: theme.spacing(1.75)
        }
      }),
      ...((!isPopoutWhenCollapsed || popoutExpanded || (popoutCollapsed && level === 0)) && {
        borderRadius: 'var(--mui-shape-borderRadius)',
        transition: `padding-inline-start ${transitionDuration}ms ease-in-out`
      }),
      ...(!active && {
        '&:hover, &:focus-visible': {
          backgroundColor: 'var(--mui-palette-action-hover)',
          color: 'var(--mui-palette-secondary-dark)'
        },
        '&[aria-expanded="true"]': {
          backgroundColor: 'var(--mui-palette-primary-lightOpacity)',
          color: 'var(--mui-palette-primary-main)'
        }
      })
    }),
    icon: ({ level }) => ({
      transition: `margin-inline-end ${transitionDuration}ms ease-in-out`,
      ...(level === 0 && {
        fontSize: '1.2rem'
      }),
      ...(level > 0 && {
        fontSize: '0.8rem',
        color: 'var(--mui-palette-text-secondary)'
      }),
      ...(level === 0 && {
        marginInlineEnd: theme.spacing(2)
      }),
      ...(level > 0 && {
        marginInlineEnd: theme.spacing(3.5)
      }),
      ...(level === 1 &&
        !popoutCollapsed && {
          marginInlineStart: theme.spacing(1.5)
        }),
      ...(level > 1 && {
        marginInlineStart: theme.spacing((popoutCollapsed ? 0 : 1.5) + 2.5 * (level - 1))
      }),
      ...(collapsedNotHovered && {
        marginInlineEnd: 0
      }),
      ...(popoutCollapsed &&
        level > 0 && {
          marginInlineEnd: theme.spacing(2)
        }),
      '& > i, & > svg': {
        fontSize: 'inherit'
      }
    }),
    prefix: {
      marginInlineEnd: theme.spacing(2)
    },
    label: ({ level }) => ({
      ...((!isPopoutWhenCollapsed || popoutExpanded || (popoutCollapsed && level === 0)) && {
        transition: `opacity ${transitionDuration}ms ease-in-out`,
        ...(collapsedNotHovered && {
          opacity: 0
        })
      })
    }),
    suffix: {
      marginInlineStart: theme.spacing(2)
    },
    subMenuExpandIcon: {
      fontSize: '1.25rem',
      marginInlineStart: theme.spacing(2),
      '& i, & svg': {
        fontSize: 'inherit'
      }
    },
    subMenuContent: ({ level }) => ({
      zIndex: 'calc(var(--drawer-z-index) + 1)',
      borderRadius: 'var(--border-radius)',
      backgroundColor: popoutCollapsed ? 'var(--mui-palette-background-paper)' : 'transparent',
      ...(popoutCollapsed && {
        '& > ul, & > div > ul': {
          [`& > li:not(:last-child), & > li > .${menuClasses.button}:not(:last-child)`]: {
            marginBlockEnd: `${theme.spacing(0.5)} !important`
          }
        },
        ...(level === 0 && {
          boxShadow: 'var(--mui-customShadows-md)',
          '[data-skin="bordered"] ~ [data-floating-ui-portal] &': {
            boxShadow: 'none',
            border: '1px solid var(--mui-palette-divider)'
          },
          [`& .${menuClasses.button}`]: {
            paddingInline: theme.spacing(4)
          },
          padding: theme.spacing(2)
        })
      })
    })
  }
}

export default menuItemStyles
