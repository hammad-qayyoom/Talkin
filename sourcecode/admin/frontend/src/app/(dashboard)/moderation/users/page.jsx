import ModerationReportsTable from '@/views/moderation-reports/ModerationReportsTable'

export const metadata = {
  title: 'Reported Users',
  description: 'Manage users reported by other members'
}

const ReportedUsersPage = () => {
  return (
    <ModerationReportsTable
      reportType="user"
      title="Reported Users"
      subtitle="Review and moderate user accounts that have been reported."
    />
  )
}

export default ReportedUsersPage
