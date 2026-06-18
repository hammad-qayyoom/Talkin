import os
import re

path = '/opt/talkin-all/app/frontend/src/views/apps/manualVerification/ManualVerificationList.jsx'
with open(path, 'r') as f:
    content = f.read()

replacement = """  const openDocument = (url) => {
    let fullUrl = url
    if (!url.startsWith('http')) {
      const cleanUrl = url.replace(/^storage[\\\\\\/]/, '')
      fullUrl = `${baseURL}/storage/${cleanUrl}`
    }
    window.open(fullUrl, '_blank')
  }"""

new_content = re.sub(r'  const openDocument = \(url\) => \{.*?window\.open\(fullUrl, \'_blank\'\)\n  \}', replacement, content, flags=re.DOTALL)

with open(path, 'w') as f:
    f.write(new_content)
