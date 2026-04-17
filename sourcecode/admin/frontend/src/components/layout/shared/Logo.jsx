'use client'

// React Imports
import { useEffect, useRef } from 'react'

// Third-party Imports
import styled from '@emotion/styled'

// Component Imports
import BrandLogo from '@core/svg/Logo'

// Hook Imports
import useVerticalNav from '@menu/hooks/useVerticalNav'
import { useSettings } from '@core/hooks/useSettings'
import { projectName } from '@/config'

const LogoMarkWrap = styled.div`
  inline-size: 42px;
  block-size: 42px;
  border-radius: 11px;
  display: grid;
  place-items: center;
  flex-shrink: 0;
  background: var(--mui-palette-background-paper);
  border: 1px solid var(--mui-palette-divider);
  box-shadow: 0 8px 18px rgb(var(--mui-mainColorChannels-lightShadow) / 0.08);
`

const LogoText = styled.span`
  color: ${({ color }) => color ?? 'var(--mui-palette-text-primary)'};
  font-size: clamp(1.4rem, 2.4vw, 1.75rem);
  line-height: 1.08;
  font-weight: 800;
  letter-spacing: 0.1px;
  display: inline-block;
  min-inline-size: 0;
  max-inline-size: calc(100% - 54px);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  transition: ${({ transitionDuration }) =>
    `margin-inline-start ${transitionDuration}ms ease-in-out, opacity ${transitionDuration}ms ease-in-out`};

  ${({ isHovered, isCollapsed, isBreakpointReached }) =>
    !isBreakpointReached && isCollapsed && !isHovered
      ? 'opacity: 0; margin-inline-start: 0;'
      : 'opacity: 1; margin-inline-start: 12px;'}
`

const Logo = ({ color }) => {
  // Refs
  const logoTextRef = useRef(null)

  // Hooks
  const { isHovered, transitionDuration, isBreakpointReached } = useVerticalNav()
  const { settings } = useSettings()

  // Vars
  const { layout } = settings

  useEffect(() => {
    if (layout !== 'collapsed') {
      return
    }

    if (logoTextRef && logoTextRef.current) {
      if (!isBreakpointReached && layout === 'collapsed' && !isHovered) {
        logoTextRef.current?.classList.add('hidden')
      } else {
        logoTextRef.current.classList.remove('hidden')
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isHovered, layout, isBreakpointReached])

  return (
    <div className='flex items-center min-is-0 max-is-full'>
      <LogoMarkWrap>
        <BrandLogo className='text-2xl text-primary' />
      </LogoMarkWrap>
      <LogoText
        color={color}
        ref={logoTextRef}
        isHovered={isHovered}
        isCollapsed={layout === 'collapsed'}
        transitionDuration={transitionDuration}
        isBreakpointReached={isBreakpointReached}
        title={projectName?.trim() || '-'}
      >
        {projectName?.trim() || '-'}
      </LogoText>
    </div>
  )
}

export default Logo
