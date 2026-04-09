import FeedPostsTable from '@/views/feed-management/FeedPostsTable'

export const metadata = {
  title: 'Reported Feed Posts'
}

const ReportedFeedPostsPage = () => {
  return <FeedPostsTable reportedOnly />
}

export default ReportedFeedPostsPage
