import Link from 'next/link'

import styles from './NotisboardHome.module.css'

const navItems = [
  { label: 'Features', href: '/#features' },
  { label: 'Experts', href: '/#experts' },
  { label: 'Safety', href: '/#safety' },
  { label: 'FAQ', href: '/#faq' },
  { label: 'Blog', href: '/blog' }
]

const Brand = () => (
  <Link className={styles.brand} href='/' aria-label='Notisboard home'>
    <span className={styles.logoWrap}>
      <img src='/images/notisboard-app/app-logo.webp' alt='' />
    </span>
    <span className={styles.wordmark}>
      Notisb<span>o</span>ard
    </span>
  </Link>
)

const PublicLayout = ({ children, hideFooter = false }) => {
  return (
    <div className={styles.siteShell}>
      <header className={styles.header}>
        <div className={styles.headerInner}>
          <Brand />
          <nav className={styles.nav} aria-label='Main navigation'>
            {navItems.map(item => (
              <Link href={item.href} key={item.href}>
                {item.label}
              </Link>
            ))}
          </nav>
          <div className={styles.headerActions}>
            <Link className={styles.textLink} href='/support'>
              Support
            </Link>
          </div>
        </div>
      </header>

      {children}

      {!hideFooter && (
        <footer className={styles.footer}>
          <Brand />
          <div className={styles.footerLinks}>
            <Link href='/privacy-policy'>Privacy Policy</Link>
            <Link href='/terms-of-use'>Terms of Use</Link>
            <Link href='/delete-account'>Delete Account</Link>
            <Link href='/support'>Support</Link>
            <Link href='/blog'>Blog</Link>
          </div>
          <p>(c) 2026 Notisboard. All rights reserved.</p>
        </footer>
      )}
    </div>
  )
}

export default PublicLayout
