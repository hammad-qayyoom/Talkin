// MUI Imports

import { useState } from 'react'

import { Button, Chip, CircularProgress, Switch } from '@mui/material'

import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Grid from '@mui/material/Grid'
import Typography from '@mui/material/Typography'

import { getFormattedDate } from '@/utils/commonfunctions'
import { baseURL } from '@/config'
import { handleCopy, truncateString } from '@/views/apps/user/list/UserListTable'
import axios from 'axios'
import { toast } from 'react-toastify'

const AboutOverview = ({ data }) => {
  // const { userDetails } = useSelector(state => state.userReducer)

  const [userDetails, setUserDetails] = useState(
    localStorage.getItem('selectedListener') ? JSON.parse(localStorage.getItem('selectedListener')) : null
  )

  if (userDetails?.isFake) {
    return (
      <Grid container spacing={6}>
        <Grid size={{ xs: 6 }} spacing={6} gap={4}>
          <Card>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Personal Information
                </Typography>

                <div className='flex items-center gap-2'>
                  <i className='tabler-mail' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Email :</Typography>
                    <Typography className='cursor-pointer' onClick={() => handleCopy(userDetails?.email)}>
                      {' '}
                      {truncateString(userDetails?.email, 30)}
                    </Typography>
                  </div>
                </div>

                <div className='flex items-center gap-2'>
                  <i className='tabler-phone' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Phone :</Typography>
                    <Typography> {userDetails?.phoneNumber || '-'}</Typography>
                  </div>
                </div>

                <div className='flex items-center gap-2'>
                  <i className='tabler-id' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Unique Id :</Typography>
                    <Typography> {userDetails?.uniqueId || '-'}</Typography>
                  </div>
                </div>

                <div className='flex items-center gap-2'>
                  <i className='tabler-old' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Age :</Typography>
                    <Typography> {userDetails?.age || '0'}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-coin' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Session Credits :</Typography>
                    <Typography> {userDetails?.currentCoinBalance || '0'}</Typography>
                  </div>
                </div>

                <div className=''>
                  <div className='flex items-center gap-2'>
                    <i className='tabler-language' />
                    <div className=''>
                      <Typography className='font-medium'>Languages :</Typography>
                    </div>
                  </div>
                  <div className='flex items-center flex-wrap gap-2 mt-3'>
                    {userDetails?.language?.length &&
                      userDetails?.language.map((item, i) => {
                        return <Chip label={item} key={i} color='warning' variant='tonal' size='small' />
                      })}
                  </div>
                </div>
                <div className=''>
                  <div className='flex items-center gap-2'>
                    <i className='tabler-brand-kako-talk' />
                    <div className=''>
                      <Typography className='font-medium'>Categories :</Typography>
                    </div>
                  </div>
                  <div className='flex items-center flex-wrap gap-2 mt-3'>
                    {userDetails?.talkTopics?.length &&
                      userDetails?.talkTopics.map((item, i) => {
                        return <Chip label={item} key={i} color='info' variant='tonal' size='small' />
                      })}
                  </div>
                </div>
                <div className=''>
                  <div className='flex items-center gap-2'>
                    <i className='tabler-user-exclamation' />
                    <div className=''>
                      <Typography className='font-medium'>Self Introduction : </Typography>
                    </div>
                  </div>
                  <div className='flex items-center flex-wrap gap-2 mt-3'>
                    <p>{userDetails?.selfIntro || 'No self introduction provided.'}</p>
                  </div>
                </div>
              </div>
              {userDetails?.experience && (
                <div className='flex flex-col gap-4'>
                  <Typography className='uppercase' variant='body2' color='text.disabled'>
                    Experience
                  </Typography>
                  <p>{userDetails?.experience || 'No experience provided.'}</p>
                </div>
              )}
            </CardContent>
          </Card>
          <Card className='mt-4'>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Availability & Status
                </Typography>

                {userDetails?.isBlocked ? (
                  <div className='flex items-center gap-2'>
                    <i className='tabler-bell' />
                    <div className='flex items-center flex-wrap gap-2'>
                      <Typography className='font-medium'>Blocked :</Typography>
                      <Chip label='Blocked' color='error' variant='tonal' size='small' />
                    </div>
                  </div>
                ) : (
                  ''
                )}

                <div className='flex items-center gap-2'>
                  <i className='tabler-bell' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Busy :</Typography>

                    {!userDetails?.isBusy ? (
                      <Chip label='Available' color='success' variant='tonal' size='small' />
                    ) : (
                      <Chip label='Busy' color='error' variant='tonal' size='small' />
                    )}
                  </div>
                </div>
              </div>
              <div className='flex items-center gap-2'>
                <i className='tabler-wifi' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Status :</Typography>

                  {userDetails?.isOnline ? (
                    <Chip label='Online' color='success' variant='tonal' size='small' />
                  ) : (
                    <Chip label='Offline' color='error' variant='tonal' size='small' />
                  )}
                </div>
              </div>
            </CardContent>
          </Card>
          {userDetails?.audio && (
            <Card className='mt-4'>
              <CardContent className='flex flex-col gap-6'>
                <div className='flex flex-col gap-4'>
                  <Typography className='uppercase' variant='body2' color='text.disabled'>
                    Audio
                  </Typography>
                  <div className='flex gap-2 flex-wrap'>
                    {userDetails?.audio && (
                      <div className='flex items-center gap-4'>
                        <audio controls className='rounded'>
                          <source src={baseURL + '/' + userDetails?.audio} />
                          Your browser does not support the audio tag.
                        </audio>
                      </div>
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>
          )}
        </Grid>
        <Grid size={{ xs: 6 }}>
          <Card>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Call Rates (Per Session)
                </Typography>

                <div className='flex items-center gap-2'>
                  <i className='tabler-coin' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Private Video Call :</Typography>
                    <Typography> {userDetails?.ratePrivateVideoCall || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-coin' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Private Audio Call:</Typography>
                    <Typography> {userDetails?.ratePrivateAudioCall || 0}</Typography>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card className='mt-4'>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Performance Metrics
                </Typography>

                <div className='flex items-center gap-2'>
                  <i className='tabler-stars' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Rating :</Typography>
                    <Typography> {userDetails?.rating || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-eye-discount' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Review Count:</Typography>
                    <Typography> {userDetails?.reviewCount || '0'}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-phone-done' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Call count :</Typography>
                    <Typography> {userDetails?.callCount || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-crown' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Experience :</Typography>
                    <Typography> {userDetails?.experience || 0}</Typography>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card className='mt-4'>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Metadata
                </Typography>
                <div className='flex items-center gap-2'>
                  <i className='tabler-id' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Unique Id :</Typography>
                    <Typography> {userDetails?.uniqueId || '-'}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-michelin-star' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Review Date:</Typography>
                    <Typography> {getFormattedDate(userDetails?.reviewAt) || '-'}</Typography>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card className='mt-4'>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Video
                </Typography>
                <div className='flex gap-2 flex-wrap'>
                  {userDetails?.video.map((item, i) => {
                    return (
                      <div key={i} className='flex items-center gap-4 border rounded'>
                        <video width='125' height={125} controls className='rounded'>
                          <source src={baseURL + '/' + item} />
                          Your browser does not support the video tag.
                        </video>
                      </div>
                    )
                  })}
                </div>
              </div>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    )
  } else {
    return (
      <Grid container spacing={6}>
        <Grid size={{ xs: 12 }}>
          <Card>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Personal Information
                </Typography>
                <div className='flex items-center gap-2'>
                  <i className='tabler-mail' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Email:</Typography>
                    <Typography className='cursor-pointer' onClick={() => handleCopy(userDetails?.email)}>
                      {' '}
                      {truncateString(userDetails?.email, 25)}
                    </Typography>
                  </div>
                </div>
                 <div className='flex items-center gap-2'>
                <i className='tabler-phone' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Phone :</Typography>
                  <Typography> {userDetails?.phoneNumber || '-'}</Typography>
                </div>
              </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-id' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Unique Id :</Typography>
                    <Typography> {userDetails?.uniqueId || '-'}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-old' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Age :</Typography>
                    <Typography> {userDetails?.age || '0'}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-coin' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Session Credits :</Typography>
                    <Typography> {userDetails?.currentCoinBalance || '0'}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-stars' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Rating :</Typography>
                    <Typography> {userDetails?.rating || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-phone-done' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Call count :</Typography>
                    <Typography> {userDetails?.callCount || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-stars' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Current Session Credits :</Typography>
                    <Typography> {userDetails?.currentCoinBalance || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-michelin-star' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Review Date:</Typography>
                    <Typography> {getFormattedDate(userDetails?.reviewAt) || '-'}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-eye-discount' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Review Count:</Typography>
                    <Typography> {userDetails?.reviewCount || '0'}</Typography>
                  </div>
                </div>

                <div className='flex items-center gap-2'>
                  <i className='tabler-wifi' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Status :</Typography>

                    {userDetails?.isOnline ? (
                      <Chip label='Online' color='success' variant='tonal' size='small' />
                    ) : (
                      <Chip label='Offline' color='error' variant='tonal' size='small' />
                    )}
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-bell' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Busy :</Typography>

                    {!userDetails?.isBusy ? (
                      <Chip label='Available' color='success' variant='tonal' size='small' />
                    ) : (
                      <Chip label='Busy' color='error' variant='tonal' size='small' />
                    )}
                  </div>
                </div>
                {userDetails?.isBlocked ? (
                  <div className='flex items-center gap-2'>
                    <i className='tabler-bell' />
                    <div className='flex items-center flex-wrap gap-2'>
                      <Typography className='font-medium'>Blocked :</Typography>
                      <Chip label='Blocked' color='error' variant='tonal' size='small' />
                    </div>
                  </div>
                ) : (
                  ''
                )}

                <div className=''>
                  <div className='flex items-center gap-2'>
                    <i className='tabler-brand-kako-talk' />
                    <div className=''>
                      <Typography className='font-medium'>Categories :</Typography>
                    </div>
                  </div>
                  <div className='flex items-center flex-wrap gap-2 mt-3'>
                    {userDetails?.talkTopics?.length &&
                      userDetails?.talkTopics.map((item, i) => {
                        return <Chip label={item} key={i} color='info' variant='tonal' size='small' />
                      })}
                  </div>
                </div>
                <div className=''>
                  <div className='flex items-center gap-2'>
                    <i className='tabler-language' />
                    <div className=''>
                      <Typography className='font-medium'>Languages :</Typography>
                    </div>
                  </div>
                  <div className='flex items-center flex-wrap gap-2 mt-3'>
                    {userDetails?.language?.length &&
                      userDetails?.language.map((item, i) => {
                        return <Chip label={item} key={i} color='warning' variant='tonal' size='small' />
                      })}
                  </div>
                </div>
              </div>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Self Introduction
                </Typography>
                <p>{userDetails?.selfIntro || 'No self introduction provided.'}</p>
              </div>
              {userDetails?.experience && (
                <div className='flex flex-col gap-4'>
                  <Typography className='uppercase' variant='body2' color='text.disabled'>
                    Experience
                  </Typography>
                  <p>{userDetails?.experience || 'No experience provided.'}</p>
                </div>
              )}
            </CardContent>
          </Card>

          <Card className='mt-4'>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Verification Badge
                </Typography>

                <div className='flex items-center gap-2'>
                  <i className='tabler-badge' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Verified :</Typography>
                    <Chip
                      label={userDetails?.isVerifiedBadge ? 'Yes' : 'No'}
                      color={userDetails?.isVerifiedBadge ? 'success' : 'default'}
                      variant='tonal'
                      size='small'
                    />
                  </div>
                </div>

                <div className='flex items-center gap-2'>
                  <i className='tabler-id' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Badge Type :</Typography>
                    <Chip
                      label={userDetails?.verifiedBadgeType || 'none'}
                      color={userDetails?.verifiedBadgeType === 'auto_sessions' ? 'info'
                        : userDetails?.verifiedBadgeType === 'manual' ? 'primary'
                        : userDetails?.verifiedBadgeType === 'celebrity' ? 'secondary'
                        : 'default'}
                      variant='tonal'
                      size='small'
                    />
                  </div>
                </div>

                {userDetails?.verifiedBadgeAt && (
                  <div className='flex items-center gap-2'>
                    <i className='tabler-calendar' />
                    <div className='flex items-center flex-wrap gap-2'>
                      <Typography className='font-medium'>Verified At :</Typography>
                      <Typography>{getFormattedDate(userDetails?.verifiedBadgeAt)}</Typography>
                    </div>
                  </div>
                )}

                {userDetails?.isVerifiedBadge && (
                  <div className='mt-3'>
                    <Button
                      variant='contained'
                      color='warning'
                      size='small'
                      startIcon={<i className='tabler-shield-off' />}
                      onClick={async () => {
                        const confirmed = window.confirm(
                          'Are you sure you want to revoke the verification badge? This will reset all manual verification data as well.'
                        )
                        if (!confirmed) return

                        try {
                          const token = localStorage.getItem('admin_token')
                          const uid = localStorage.getItem('uid')
                          const secretKey = 'Eb6ek8wbjlrR3fiK36IXsUw'

                          const response = await axios.patch(
                            `${baseURL}/api/admin/manualVerification/revoke`,
                            { expertId: userDetails?._id },
                            {
                              headers: {
                                'Content-Type': 'application/json',
                                key: secretKey,
                                Authorization: `Bearer ${token}`,
                                'x-admin-uid': uid
                              }
                            }
                          )

                          if (response.data?.status) {
                            toast.success('Verification badge revoked')
                            window.location.reload()
                          } else {
                            toast.error(response.data?.message || 'Failed to revoke')
                          }
                        } catch (error) {
                          toast.error('Failed to revoke verification badge')
                        }
                      }}
                    >
                      Revoke Blue Tick
                    </Button>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>

          <Card className='mt-4'>
            <CardContent className='flex flex-col gap-6'>
              <Typography className='uppercase' variant='body2' color='text.disabled'>
                Availability For Calls
              </Typography>
              <div className='flex flex-col gap-4'>
                <div className='flex items-center gap-2'>
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Available For Private Audio Call :</Typography>
                    <Chip
                      label={userDetails?.isAvailableForPrivateAudioCall ? 'Available' : 'Not Abailable'}
                      color={userDetails?.isAvailableForPrivateAudioCall ? 'success' : 'error'}
                      variant='tonal'
                      size='small'
                    />
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Available For Private Video Call:</Typography>
                    <Chip
                      label={userDetails?.isAvailableForPrivateVideoCall ? 'Available' : 'Not Abailable'}
                      color={userDetails?.isAvailableForPrivateVideoCall ? 'success' : 'error'}
                      variant='tonal'
                      size='small'
                    />
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className='mt-4'>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Call Rates (Per Session)
                </Typography>

                <div className='flex items-center gap-2'>
                  <i className='tabler-coin' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Private Video Call :</Typography>
                    <Typography> {userDetails?.ratePrivateVideoCall || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-coin' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Private Audio Call:</Typography>
                    <Typography> {userDetails?.ratePrivateAudioCall || 0}</Typography>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    )
  }
}

export default AboutOverview
