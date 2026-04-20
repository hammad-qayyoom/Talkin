'use client'

import { useEffect } from 'react'

const shouldOptimizeImage = img => {
  const src = String(img?.getAttribute('src') || '').trim().toLowerCase()

  if (!src) return false

  return (
    src.includes('/storage/') ||
    src.includes('talkin.notisboard.com/storage/') ||
    src.startsWith('http://') ||
    src.startsWith('https://')
  )
}

const applyHints = img => {
  if (!img || img.tagName !== 'IMG') return
  if (!shouldOptimizeImage(img)) return

  if (!img.getAttribute('decoding')) {
    img.setAttribute('decoding', 'async')
  }

  if (!img.getAttribute('loading')) {
    img.setAttribute('loading', 'lazy')
  }
}

const GlobalImageHints = () => {
  useEffect(() => {
    const images = document.querySelectorAll('img')

    images.forEach(applyHints)

    const observer = new MutationObserver(mutations => {
      mutations.forEach(mutation => {
        mutation.addedNodes.forEach(node => {
          if (!(node instanceof HTMLElement)) return

          if (node.tagName === 'IMG') {
            applyHints(node)
          }

          const nestedImages = node.querySelectorAll?.('img') || []

          nestedImages.forEach(applyHints)
        })
      })
    })

    observer.observe(document.body, {
      childList: true,
      subtree: true
    })

    return () => observer.disconnect()
  }, [])

  return null
}

export default GlobalImageHints
