import Link from 'next/link'
import { notFound } from 'next/navigation'

import { baseURL } from '@/config'
import PublicLayout from '@/components/public/PublicLayout'
import styles from '@/components/public/Blog.module.css'

async function fetchPost(slug) {
  try {
    const res = await fetch(`${baseURL}/api/blog/posts/${encodeURIComponent(slug)}`, {
      next: { revalidate: 60 }
    })

    if (!res.ok) return null

    const json = await res.json()

    return json.status ? json.data : null
  } catch (error) {
    console.error('Failed to fetch blog post:', error)

    return null
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

export async function generateMetadata({ params }) {
  const { slug } = await params
  const post = await fetchPost(slug)

  if (!post) {
    return { title: 'Not Found | Notisboard Blog' }
  }

  return {
    title: `${post.title} | Notisboard Blog`,
    description: post.summary || 'Read the latest from Notisboard.'
  }
}

export default async function BlogPostPage({ params }) {
  const { slug } = await params
  const post = await fetchPost(slug)

  if (!post) {
    notFound()
  }

  return (
    <PublicLayout>
      <article className={styles.detailBody}>
        <Link href='/blog' className={styles.backLink}>
          <i className='tabler-arrow-left' /> Back to Blog
        </Link>
        <h1 className={styles.detailTitle}>{post.title}</h1>
        <div className={styles.detailMeta}>
          <span>{formatDate(post.publishedAt || post.createdAt)}</span>
          {post.author && <span>• {post.author}</span>}
        </div>
        {post.summary && <p className={styles.detailSummary}>{post.summary}</p>}
        {post.coverImage && (
          <div className={styles.detailCover}>
            <img src={`${baseURL}/${post.coverImage}`} alt={post.title} />
          </div>
        )}
        <div className={styles.detailContent} dangerouslySetInnerHTML={{ __html: post.content }} />
      </article>
    </PublicLayout>
  )
}
