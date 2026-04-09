import FeedPostsTable from '@/views/feed-management/FeedPostsTable'

export const metadata = {
  title: 'Feed Posts'
}

const FeedPostsPage = () => {
  return <FeedPostsTable reportedOnly={false} />
}

export default FeedPostsPage
