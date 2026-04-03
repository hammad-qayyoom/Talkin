'use client'

// React Imports
import { useEffect, useState } from 'react'

const useMediaQuery = breakpoint => {
  // States
  const [matches, setMatches] = useState(breakpoint === 'always')

  useEffect(() => {
    if (breakpoint && breakpoint !== 'always') {
      const media = window.matchMedia(`(max-width: ${breakpoint})`)

      if (media.matches !== matches) {
        setMatches(media.matches)
      }

      const expert = () => setMatches(media.matches)

      window.addEventListener('resize', expert)

      return () => window.removeEventListener('resize', expert)
    }
  }, [matches, breakpoint])

  return matches
}

export default useMediaQuery
