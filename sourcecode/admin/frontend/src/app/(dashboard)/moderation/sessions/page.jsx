import ModerationReportsTable from '@/views/moderation-reports/ModerationReportsTable'

export const metadata = {
  title: 'Reported Sessions',
  description: 'Manage consultation sessions reported by users'
}

const ReportedSessionsPage = () => {
  return (
    <ModerationReportsTable
      reportType="session"
      title="Reported Sessions"
      subtitle="Review and moderate consultation sessions that have been reported."
    />
  )
}

export default ReportedSessionsPage
