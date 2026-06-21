import ModerationReportsTable from '@/views/moderation-reports/ModerationReportsTable'

export const metadata = {
  title: 'Reported Chats',
  description: 'Manage chat messages reported by users'
}

const ReportedChatsPage = () => {
  return (
    <ModerationReportsTable
      reportType="chat_message"
      title="Reported Chats"
      subtitle="Review and moderate chat messages that have been reported for violations."
    />
  )
}

export default ReportedChatsPage
