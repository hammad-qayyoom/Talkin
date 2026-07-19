'use client'

import dynamic from 'next/dynamic'

const RecordingPlans = dynamic(() => import('.'), { ssr: false })

const ClientWrapper = () => {
  return <RecordingPlans />
}

export default ClientWrapper
