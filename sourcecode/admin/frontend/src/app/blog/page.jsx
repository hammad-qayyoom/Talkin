import Link from 'next/link'

import { baseURL } from '@/config'
import PublicLayout from '@/components/public/PublicLayout'
import styles from '@/components/public/Blog.module.css'

async function fetchPublishedPosts() {
  try {
    const res = await fetch(`${baseURL}/api/blog/posts?limit=50`, {
      next: { revalidate: 60 }
    })

    if (!res.ok) return { data: [], total: 0 }

    const json = await res.json()

    return json.status ? { data: json.data || [], total: json.total || 0 } : { data: [], total: 0 }
  } catch (error) {
    console.error('Failed to fetch blog posts:', error)

    return { data: [], total: 0 }
  }
}

const formatDate = dateString => {
  if (!dateString) return ''
  const date = new Date(dateString)

  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

export const metadata = {
  title: 'Blog & News | Notisboard',
  description: 'Latest updates, features, partnerships, and news from Notisboard.'
}

export default async function BlogPage() {
  const { data: posts } = await fetchPublishedPosts()

  return (
    <PublicLayout>
      <section className={styles.blogHero}>
        <div className={styles.blogHeroInner}>
          <h1>Blog & News</h1>
          <p>Stay updated with the latest features, partnerships, and announcements from Notisboard.</p>
        </div>
      </section>

      <section className={styles.blogContainer}>
        {posts.length === 0 ? (
          <div className={styles.emptyState}>
            <p>No articles published yet. Check back soon!</p>
          </div>
        ) : (
          <div className={styles.blogGrid}>
            {posts.map(post => (
              <article key={post._id} className={styles.blogCard}>
                <Link href={`/blog/${post.slug}`} className={styles.blogCardImage}>
                  {post.coverImage ? (
                    <img src={`${baseURL}/${post.coverImage}`} alt={post.title} />
                  ) : (
                    <div className='w-full h-full flex items-center justify-center text-gray-400'>
                      <i className='tabler-photo text-4xl' />
                    </div>
                  )}
                </Link>
                <div className={styles.blogCardBody}>
                  <div className={styles.blogCardMeta}>
                    <span>{formatDate(post.publishedAt || post.createdAt)}</span>
                    {post.author && <span>• {post.author}</span>}
                  </div>
                  <h2>
                    <Link href={`/blog/${post.slug}`}>{post.title}</Link>
                  </h2>
                  {post.summary && <p>{post.summary}</p>}
                  <Link href={`/blog/${post.slug}`} className={styles.readMore}>
                    Read more <i className='tabler-arrow-right' />
                  </Link>
                </div>
              </article>
            ))}
          </div>
        )}
      </section>
    </PublicLayout>
  )
}
