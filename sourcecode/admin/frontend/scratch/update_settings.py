import re

file_path = '/Users/hammadqayyoom/Projects/Notisboard/sourcecode/admin/frontend/src/views/settings/tabs/GeneralSettings.jsx'

with open(file_path, 'r') as f:
    content = f.read()

# 1. Add to initial state
content = content.replace(
    "    videoCallRatePrivate: '',\n    audioCallRatePrivate: '',",
    "    videoCallRatePrivate: '',\n    maxVideoCallRatePrivate: '',\n    audioCallRatePrivate: '',\n    maxAudioCallRatePrivate: '',"
)

# 2. Add to useEffect newData
content = content.replace(
    "        videoCallRatePrivate: settings.videoCallRatePrivate || 0,\n        audioCallRatePrivate: settings.audioCallRatePrivate || 0,",
    "        videoCallRatePrivate: settings.videoCallRatePrivate || 0,\n        maxVideoCallRatePrivate: settings.maxVideoCallRatePrivate || 0,\n        audioCallRatePrivate: settings.audioCallRatePrivate || 0,\n        maxAudioCallRatePrivate: settings.maxAudioCallRatePrivate || 0,"
)

# 3. Add to labels
content = content.replace(
    "  const privateAudioLabel = isSessionCreditMode ? 'Private Audio Credits' : 'Private Audio Rate'\n  const privateVideoLabel = isSessionCreditMode ? 'Private Video Credits' : 'Private Video Rate'",
    "  const privateAudioLabel = isSessionCreditMode ? 'Min Private Audio Credits' : 'Min Private Audio Rate'\n  const maxPrivateAudioLabel = isSessionCreditMode ? 'Max Private Audio Credits' : 'Max Private Audio Rate'\n  const privateVideoLabel = isSessionCreditMode ? 'Min Private Video Credits' : 'Min Private Video Rate'\n  const maxPrivateVideoLabel = isSessionCreditMode ? 'Max Private Video Credits' : 'Max Private Video Rate'"
)

# 4. Add to numericFields
content = content.replace(
    "    'videoCallRatePrivate',\n    'audioCallRatePrivate',",
    "    'videoCallRatePrivate',\n    'maxVideoCallRatePrivate',\n    'audioCallRatePrivate',\n    'maxAudioCallRatePrivate',"
)

# 5. Replace the UI block for Video and Audio calls
old_ui_block = """                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label={privateAudioLabel}
                    value={formData.audioCallRatePrivate || ''}
                    onChange={e => handleFieldChange('audioCallRatePrivate', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                      endAdornment: (
                        <InputAdornment position='end'>
                          <Typography variant='caption' color='text.secondary'>
                            {privateRateUnitLabel}
                          </Typography>
                        </InputAdornment>
                      )
                    }}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label={privateVideoLabel}
                    value={formData.videoCallRatePrivate || ''}
                    onChange={e => handleFieldChange('videoCallRatePrivate', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                      endAdornment: (
                        <InputAdornment position='end'>
                          <Typography variant='caption' color='text.secondary'>
                            {privateRateUnitLabel}
                          </Typography>
                        </InputAdornment>
                      )
                    }}
                  />
                </Grid>"""

new_ui_block = """                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label={privateAudioLabel}
                    value={formData.audioCallRatePrivate || ''}
                    onChange={e => handleFieldChange('audioCallRatePrivate', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                      endAdornment: (
                        <InputAdornment position='end'>
                          <Typography variant='caption' color='text.secondary'>
                            {privateRateUnitLabel}
                          </Typography>
                        </InputAdornment>
                      )
                    }}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label={maxPrivateAudioLabel}
                    value={formData.maxAudioCallRatePrivate || ''}
                    onChange={e => handleFieldChange('maxAudioCallRatePrivate', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                      endAdornment: (
                        <InputAdornment position='end'>
                          <Typography variant='caption' color='text.secondary'>
                            {privateRateUnitLabel}
                          </Typography>
                        </InputAdornment>
                      )
                    }}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label={privateVideoLabel}
                    value={formData.videoCallRatePrivate || ''}
                    onChange={e => handleFieldChange('videoCallRatePrivate', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                      endAdornment: (
                        <InputAdornment position='end'>
                          <Typography variant='caption' color='text.secondary'>
                            {privateRateUnitLabel}
                          </Typography>
                        </InputAdornment>
                      )
                    }}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    type='text'
                    label={maxPrivateVideoLabel}
                    value={formData.maxVideoCallRatePrivate || ''}
                    onChange={e => handleFieldChange('maxVideoCallRatePrivate', e.target.value)}
                    InputProps={{
                      inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                      endAdornment: (
                        <InputAdornment position='end'>
                          <Typography variant='caption' color='text.secondary'>
                            {privateRateUnitLabel}
                          </Typography>
                        </InputAdornment>
                      )
                    }}
                  />
                </Grid>"""

content = content.replace(old_ui_block, new_ui_block)

with open(file_path, 'w') as f:
    f.write(content)

print("Updated GeneralSettings.jsx successfully!")
