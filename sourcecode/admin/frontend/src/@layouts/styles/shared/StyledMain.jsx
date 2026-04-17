// Third-party Imports
import styled from '@emotion/styled'

// Config Imports
import themeConfig from '@configs/themeConfig'

// Util Imports
import { commonLayoutClasses } from '@layouts/utils/layoutClasses'

const StyledMain = styled.main`
  position: relative;
  padding: ${themeConfig.layoutPadding}px;
  min-block-size: calc(100dvh - var(--header-height));
  ${({ isContentCompact }) =>
    isContentCompact &&
    `
    margin-inline: auto;
    max-inline-size: ${themeConfig.compactContentWidth}px;
  `}

  &:has(.${commonLayoutClasses.contentHeightFixed}) {
    display: flex;
    overflow: hidden;
  }
`

export default StyledMain
