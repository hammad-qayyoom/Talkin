import ModerationReportsTable from '@/views/moderation-reports/ModerationReportsTable'

export const metadata = {
  title: 'Reported Experts',
  description: 'Manage experts reported by other members'
}

const ReportedExpertsPage = () => {
  return (
    <ModerationReportsTable
      reportType="expert_profile"
      title="Reported Experts"
      subtitle="Review and moderate expert profiles that have been reported."
    />
  )
}

export default ReportedExpertsPage
