import styles from './PublicationPage.module.css'

const updatedAt = 'April 25, 2026'
const supportEmail = 'support@notisboard.com'

const pageContent = {
  privacy: {
    eyebrow: 'Privacy Policy',
    title: 'Notisboard Privacy Policy',
    intro:
      'This policy explains how Notisboard collects, uses, shares and protects user and device data for people who use the app or website, and supports App Store privacy disclosures in App Store Connect.',
    sections: [
      {
        title: 'Information We Collect',
        body: [
          'Account details such as name, email address, mobile number, login method, profile photo, language, country and unique user ID.',
          'Expert profile details such as topic selection, verification request information, availability, session history, ratings and payout-related records.',
          'App activity such as chats, session bookings, wallet/session credit history, notifications, reports, blocked accounts and support requests.',
          'Media you choose to upload, including profile images, chat images, feed posts and verification images.',
          'Payment and purchase status from payment providers and store billing systems. Notisboard does not store full card numbers.',
          'Device and technical information such as app version, device identifiers, Firebase authentication IDs, notification token, crash/debug data and approximate network information.',
          'If you allow location access, the app may process location data to help show nearest experts.',
          'Notisboard does not record or store call audio/video content.'
        ]
      },
      {
        title: 'How We Use Information',
        body: [
          'To create accounts, authenticate users, show expert profiles, connect chats/calls and manage booked sessions.',
          'To process session credits, subscriptions, wallet balances, expert earnings, payouts, refunds and payment support.',
          'To operate safety features such as reporting, blocking, moderation, identity checks, fraud prevention and abuse prevention.',
          'To send app notifications, service updates, support replies and important account messages.',
          'To improve app reliability, language matching, expert discovery, customer support, uptime and performance.',
          'To show nearest experts when location access is enabled by the user.',
          'To comply with legal obligations, enforce our terms and resolve disputes.'
        ]
      },
      {
        title: 'Data Linked to You',
        body: [
          'The following data is generally linked to your account or device: account profile details, user ID, device identifiers, notification token, session and purchase history, and support records.',
          'User content you submit, such as chat messages, uploaded media, posts and reports, may be linked to your account to provide core app features and safety controls.',
          'Where possible, aggregated or de-identified data may be used for service improvement and reliability reporting.'
        ]
      },
      {
        title: 'Tracking',
        body: [
          'Notisboard does not use app data for cross-app or cross-website tracking for third-party advertising purposes.',
          'Notisboard does not share personal data with data brokers.',
          'If a future version introduces tracking, we will request permission through Apple App Tracking Transparency (ATT) before tracking is enabled.'
        ]
      },
      {
        title: 'Sharing and Third Parties',
        body: [
          'We may share limited data with service providers for authentication, cloud hosting, storage, notifications, analytics, moderation and customer support.',
          'Payment transactions are processed through payment partners and store billing providers (for example, Google Play or App Store) according to their terms and privacy practices.',
          'We may share required data with communication infrastructure providers used for chat/call delivery, abuse prevention and service reliability.',
          'We may disclose information when required by law, to protect users, to investigate abuse, or to enforce platform rules.',
          'Public profile content, ratings and feed posts may be visible to other app users according to the feature design.',
          'Third-party partners that process Notisboard user data are required to provide data protection standards consistent with this policy and applicable platform requirements.',
          'Notisboard does not sell personal information to third parties.'
        ]
      },
      {
        title: 'Permissions and Sensitive Access',
        body: [
          'Camera, microphone, photos and notifications permissions are requested only when needed for app features such as profile upload, calls and notifications.',
          'Location permission is requested only to help users discover nearest experts.',
          'The iOS app currently requests camera, microphone and photo library access only for user-facing features that need them.',
          'The current app experience does not require SMS or Call Log permissions for core functionality.',
          'The current app experience does not require contacts access or health data access for core functionality.',
          'Location access is used only to help users discover nearest experts, and can be disabled from device settings.',
          'If a future version requests any high-risk or sensitive permission, the purpose will be disclosed in-app and in required platform declarations before use.',
          'You can change app permissions from your device settings. Some features may stop working if required permissions are disabled.'
        ]
      },
      {
        title: 'Ads and Promotional Content',
        body: [
          'Current app configuration does not include third-party advertising SDKs for personalized ad tracking.',
          'If ads or ad measurement are introduced in a future release, this policy and App Store privacy answers will be updated before release.',
          'Any required consent flow will be shown to users before ad tracking or similar processing is enabled.'
        ]
      },
      {
        title: 'Target Audience and Children',
        body: [
          'Target age group information is declared in app store submission forms and should be checked in the app listing.',
          'If a version is made available to children, additional safeguards and applicable child privacy requirements are followed.',
          `Parents or guardians can contact ${supportEmail} for privacy-related questions about a child account.`
        ]
      },
      {
        title: 'Data Security',
        body: [
          'We use reasonable technical and organizational safeguards such as access controls, transport encryption and monitoring to protect user information.',
          'No method of storage or transmission is fully secure, but we continuously work to reduce security risk and unauthorized access.'
        ]
      },
      {
        title: 'Retention and Deletion',
        body: [
          'We keep information while your account is active or as needed for service, security, legal, financial, dispute and fraud-prevention purposes.',
          'You can request account deletion from the app or the Delete Account page. Some transaction, security or legal records may be retained where required.',
          'Most verified deletion requests are processed within 30 days unless a longer period is required for security, legal or payment reasons.'
        ]
      },
      {
        title: 'Contact and Policy Updates',
        body: [
          `For privacy questions, contact Notisboard Support at ${supportEmail}.`,
          'For privacy choices, access, correction or deletion requests, use the in-app settings flow or the public Delete Account page.',
          'This privacy policy is intended to be accessible from the app listing and in-app settings.',
          'We may update this policy when app features, legal requirements, Google Play policies or App Store policies change. The revised date is shown at the top of this page.'
        ]
      }
    ]
  },
  terms: {
    eyebrow: 'Terms of Use',
    title: 'Notisboard Terms of Use',
    intro:
      'These terms apply when you access Notisboard as a user, expert or website visitor. By using the service, you agree to follow these rules.',
    sections: [
      {
        title: 'Service Overview',
        body: [
          'Notisboard helps users discover experts, chat, call, book sessions, view feed content and manage session credits.',
          'Experts may provide supportive conversation, topic-based guidance, sessions and content after approval by the platform.'
        ]
      },
      {
        title: 'Accounts and Eligibility',
        body: [
          'You are responsible for keeping your login details secure and for activity under your account.',
          'You must provide accurate profile and verification information. We may reject, suspend or remove accounts that provide false, unsafe or abusive information.',
          'Do not share OTP codes, passwords, payment information or another person account access.'
        ]
      },
      {
        title: 'Safety Rules',
        body: [
          'Do not use Notisboard for harassment, hate, threats, nudity, pornography, scams, spam, impersonation or illegal activity.',
          'Do not request or share personal financial details, passwords, OTP codes, private identity documents or unsafe contact information in chats, calls or posts.',
          'Notisboard is not an emergency, medical, therapy, legal or financial service. If you are in danger or need urgent help, contact local emergency services.'
        ]
      },
      {
        title: 'Session Credits, Payments and Payouts',
        body: [
          'Session credits are used inside the app for paid features such as calls or sessions where applicable.',
          'Purchases, subscriptions and refunds may depend on the payment provider, Google Play, App Store rules and local law.',
          'Expert earnings, conversion minimums, payout minimums and platform commission are managed by platform settings and may change over time.'
        ]
      },
      {
        title: 'Content and Moderation',
        body: [
          'You are responsible for content you upload or send, including profile images, chat media, feed posts and reports.',
          'We may review, remove, restrict or report content or accounts that violate these terms, safety policies or applicable law.'
        ]
      },
      {
        title: 'Changes and Contact',
        body: [
          'We may update these terms when the app, safety rules or legal requirements change.',
          `Questions about these terms can be sent to ${supportEmail}.`
        ]
      }
    ]
  },
  deletion: {
    eyebrow: 'Account Deletion',
    title: 'Delete Your Notisboard Account',
    intro:
      'Users and experts can request account deletion directly from the app or by contacting support. This page is provided for app store publication and user data control.',
    sections: [
      {
        title: 'Delete From the App',
        body: [
          'Open the Notisboard app and log in to your account.',
          'Go to Profile.',
          'Then open Settings.',
          'Tap Delete Account.',
          'Confirm the deletion prompt. Your account will be deleted permanently.'
        ]
      },
      {
        title: 'Delete by Email',
        body: [
          `Email ${supportEmail} from the email address linked to your account.`,
          'Use the subject "Delete My Notisboard Account".',
          'Include your full name, registered email or mobile number, and your Notisboard user ID if available.',
          'If you are an expert, mention that your expert profile should also be deleted.'
        ]
      },
      {
        title: 'What Gets Deleted',
        body: [
          'Profile information, login-linked user record, expert profile details where applicable, app preferences and non-required account data are deleted or anonymized.',
          'Some records may be retained for legal, fraud prevention, payment, payout, tax, dispute, safety or audit reasons where required.',
          'Deletion may affect access to chats, calls, sessions, wallet records, feed posts, ratings and expert earnings.'
        ]
      },
      {
        title: 'Processing Time',
        body: [
          'Most verified requests are processed within 30 days unless a longer period is required for security, legal or payment reasons.',
          'Support may contact you to verify account ownership before deletion.'
        ]
      }
    ]
  },
  support: {
    eyebrow: 'Support',
    title: 'Notisboard Support Center',
    intro:
      'Need help with login, experts, chat, calls, session credits, verification, payments or account deletion? Contact support from here.',
    sections: [
      {
        title: 'Contact Support',
        body: [
          `Email: ${supportEmail}`,
          'Recommended subject examples: Login Help, Payment Issue, Expert Verification, Session Booking, Report Safety Issue, Delete Account.'
        ]
      },
      {
        title: 'Before You Email',
        body: [
          'Include your registered email or mobile number, device type, app version, screenshots if useful and a short description of the issue.',
          'For payment questions, include transaction date, payment provider and order ID if available. Do not send full card numbers or passwords.'
        ]
      },
      {
        title: 'Safety Reports',
        body: [
          'Use in-app reporting or email support if someone asks for money transfers, lottery payments, OTP codes, passwords, identity documents or unsafe private information.',
          'For emergencies or immediate danger, contact local emergency services first.'
        ]
      },
      {
        title: 'Useful Pages',
        body: ['Privacy Policy, Terms of Use and Account Deletion pages are linked below for app store review and user access.']
      }
    ]
  }
}

const pageLinks = [
  { href: '/', label: 'Home' },
  { href: '/privacy-policy', label: 'Privacy Policy' },
  { href: '/terms-of-use', label: 'Terms' },
  { href: '/delete-account', label: 'Delete Account' },
  { href: '/support', label: 'Support' }
]

const PublicationPage = ({ type }) => {
  const content = pageContent[type]

  return (
    <main className={styles.pageShell}>
      <header className={styles.header}>
        <a className={styles.brand} href='/'>
          <span className={styles.logoWrap}>
            <img src='/images/notisboard-app/app-logo.webp' alt='' />
          </span>
          <span className={styles.wordmark}>
            Notisb<span>o</span>ard
          </span>
        </a>
        <nav aria-label='Publication pages'>
          {pageLinks.map(item => (
            <a href={item.href} key={item.href}>
              {item.label}
            </a>
          ))}
        </nav>
      </header>

      <section className={styles.hero}>
        <p>{content.eyebrow}</p>
        <h1>{content.title}</h1>
        <span>Last updated: {updatedAt}</span>
        <div>{content.intro}</div>
      </section>

      <section className={styles.contentWrap}>
        {content.sections.map(section => (
          <article className={styles.policyBlock} key={section.title}>
            <h2>{section.title}</h2>
            <ul>
              {section.body.map(item => (
                <li key={item}>{item}</li>
              ))}
            </ul>
          </article>
        ))}
      </section>

      <section className={styles.contactBand}>
        <div>
          <p>Need help?</p>
          <h2>Contact Notisboard Support</h2>
        </div>
        <a href={`mailto:${supportEmail}`}>{supportEmail}</a>
      </section>

      <footer className={styles.footer}>
        <p>(c) 2026 Notisboard. All rights reserved.</p>
        <div>
          {pageLinks.map(item => (
            <a href={item.href} key={item.href}>
              {item.label}
            </a>
          ))}
        </div>
      </footer>
    </main>
  )
}

export default PublicationPage
