import styles from './NotisboardHome.module.css'

const storeLinks = [
  {
    label: 'Google Play',
    icon: 'tabler-brand-google-play',
    text: 'Android app',
    href: '#download'
  },
  {
    label: 'App Store',
    icon: 'tabler-brand-apple',
    text: 'iPhone app',
    href: '#download'
  }
]

const featureCards = [
  {
    title: 'Find Experts',
    text: 'Browse experts by topic, language, rating, profile status and availability.',
    icon: 'tabler-user-search',
    tone: 'red'
  },
  {
    title: 'Feed and Chat',
    text: 'Post updates, follow experts, comment, share and continue conversations in chat.',
    icon: 'tabler-messages',
    tone: 'dark'
  },
  {
    title: 'Book Sessions',
    text: 'Reserve audio, video and group sessions, then manage them from My Sessions.',
    icon: 'tabler-calendar-check',
    tone: 'teal'
  },
  {
    title: 'Session Credits',
    text: 'Track wallet balance, credit history, payouts and conversion rate from the app.',
    icon: 'tabler-coin',
    tone: 'gold'
  }
]

const expertItems = [
  'Apply from the app with profile, topics, language and identity details.',
  'Set availability for private calls, booked sessions and group sessions.',
  'Track earnings, session credit history and payout requests from Expert Center.'
]

const safetyItems = [
  'Do not share passwords, OTP codes, financial details or private identity data.',
  'Report abusive, fraudulent, adult or unsafe behavior from chats, calls or posts.',
  'Notisboard is for supportive conversations and discovery, not emergency care.'
]

const faqs = [
  {
    q: 'What is Notisboard?',
    a: 'Notisboard helps users find experts for supportive conversations, chat, private calls, video calls and scheduled sessions.'
  },
  {
    q: 'Who are Experts?',
    a: 'Experts are approved profiles who can support users through topics, calls, posts and sessions after verification.'
  },
  {
    q: 'How do session credits work?',
    a: 'Users add session credits to access paid calls and sessions. Experts can track earned credits and request payouts when eligible.'
  },
  {
    q: 'Can I delete my account?',
    a: 'Yes. Use Delete Account in app settings, or follow the account deletion instructions on this website.'
  }
]

const navItems = [
  { label: 'Features', href: '#features' },
  { label: 'Experts', href: '#experts' },
  { label: 'Safety', href: '#safety' },
  { label: 'FAQ', href: '#faq' }
]

const Brand = () => (
  <a className={styles.brand} href='/' aria-label='Notisboard home'>
    <span className={styles.logoWrap}>
      <img src='/images/notisboard-app/app-logo.webp' alt='' />
    </span>
    <span className={styles.wordmark}>
      Notisb<span>o</span>ard
    </span>
  </a>
)

const StoreButton = ({ item }) => (
  <a className={styles.storeButton} href={item.href}>
    <span className={item.icon} aria-hidden='true' />
    <span>
      <strong>{item.label}</strong>
      <small>{item.text}</small>
    </span>
  </a>
)

const PhonePreview = () => (
  <div className={styles.phoneCluster} aria-label='Notisboard app preview'>
    <div className={`${styles.phoneFrame} ${styles.phoneMain}`}>
      <img src='/images/notisboard-app/home-user.webp' alt='Notisboard user home screen' />
    </div>
    <div className={`${styles.phoneFrame} ${styles.phoneSide}`}>
      <img src='/images/notisboard-app/expert-dashboard.webp' alt='Notisboard expert dashboard screen' />
    </div>
    <div className={styles.previewBadge}>
      <span className='tabler-shield-check' aria-hidden='true' />
      <span>Real app screens</span>
    </div>
  </div>
)

const NotisboardHome = () => {
  return (
    <main className={styles.siteShell}>
      <header className={styles.header}>
        <div className={styles.headerInner}>
          <Brand />
          <nav className={styles.nav} aria-label='Main navigation'>
            {navItems.map(item => (
              <a href={item.href} key={item.href}>
                {item.label}
              </a>
            ))}
          </nav>
          <div className={styles.headerActions}>
            <a className={styles.textLink} href='/support'>
              Support
            </a>
          </div>
        </div>
      </header>

      <section className={styles.hero}>
        <div className={styles.heroCopy}>
          <p className={styles.kicker}>Expert Chat, Calls and Sessions</p>
          <h1>
            Notisb<span>o</span>ard
          </h1>
          <p className={styles.heroText}>
            Find trusted experts, post in the feed, book audio or video sessions, and manage session credits in the
            same clean mobile experience shown inside the app.
          </p>
          <div className={styles.heroActions} id='download'>
            {storeLinks.map(item => (
              <StoreButton key={item.label} item={item} />
            ))}
          </div>
          <div className={styles.heroStats} aria-label='Notisboard highlights'>
            <span>Chat</span>
            <span>Audio Call</span>
            <span>Video Call</span>
            <span>Sessions</span>
            <span>Wallet</span>
          </div>
        </div>
        <PhonePreview />
      </section>

      <section className={styles.section} id='features'>
        <div className={styles.sectionHeader}>
          <p className={styles.kicker}>Core app flows</p>
          <h2>Built around the same Notisboard app experience</h2>
          <p>
            The website mirrors the app language: Home, Feed, Expert, Chat, Sessions, Wallet, session credits and
            expert dashboard controls.
          </p>
        </div>
        <div className={styles.featureGrid}>
          {featureCards.map(card => (
            <article className={styles.featureCard} data-tone={card.tone} key={card.title}>
              <span className={`${styles.featureIcon} ${card.icon}`} aria-hidden='true' />
              <h3>{card.title}</h3>
              <p>{card.text}</p>
            </article>
          ))}
        </div>
      </section>

      <section className={`${styles.section} ${styles.splitSection}`} id='experts'>
        <div className={styles.appPanel}>
          <img src='/images/notisboard-app/expert-dashboard.webp' alt='Expert dashboard screen in Notisboard' />
        </div>
        <div className={styles.splitCopy}>
          <p className={styles.kicker}>Expert Center</p>
          <h2>Experts can help users and manage earnings from the app</h2>
          <p>
            Notisboard supports verified expert profiles with availability, sessions, chat, calling, wallet records and
            payout-ready earnings controls.
          </p>
          <ul className={styles.checkList}>
            {expertItems.map(item => (
              <li key={item}>
                <span className='tabler-check' aria-hidden='true' />
                {item}
              </li>
            ))}
          </ul>
        </div>
      </section>

      <section className={`${styles.section} ${styles.safetySection}`} id='safety'>
        <div className={styles.safetyCopy}>
          <p className={styles.kicker}>Privacy and safety</p>
          <h2>Controls needed for a publish-ready mobile app</h2>
          <p>
            Public policy pages, account deletion instructions, support access and user safety guidance are available
            from the website footer and app store listing links.
          </p>
        </div>
        <div className={styles.safetyGrid}>
          {safetyItems.map((item, index) => (
            <article className={styles.safetyCard} key={item}>
              <span>{String(index + 1).padStart(2, '0')}</span>
              <p>{item}</p>
            </article>
          ))}
        </div>
      </section>

      <section className={styles.section} id='faq'>
        <div className={styles.sectionHeader}>
          <p className={styles.kicker}>Help Center</p>
          <h2>Frequently asked questions</h2>
        </div>
        <div className={styles.faqGrid}>
          {faqs.map(item => (
            <article className={styles.faqItem} key={item.q}>
              <h3>{item.q}</h3>
              <p>{item.a}</p>
            </article>
          ))}
        </div>
      </section>

      <section className={styles.ctaBand}>
        <div>
          <p className={styles.kicker}>Ready for publication</p>
          <h2>Legal, support and data deletion pages are live in the website structure.</h2>
        </div>
        <div className={styles.ctaLinks}>
          <a href='/privacy-policy'>Privacy Policy</a>
          <a href='/terms-of-use'>Terms</a>
          <a href='/delete-account'>Delete Account</a>
          <a href='/support'>Support</a>
        </div>
      </section>

      <footer className={styles.footer}>
        <Brand />
        <div className={styles.footerLinks}>
          <a href='/privacy-policy'>Privacy Policy</a>
          <a href='/terms-of-use'>Terms of Use</a>
          <a href='/delete-account'>Delete Account</a>
          <a href='/support'>Support</a>
        </div>
        <p>(c) 2026 Notisboard. All rights reserved.</p>
      </footer>
    </main>
  )
}

export default NotisboardHome
