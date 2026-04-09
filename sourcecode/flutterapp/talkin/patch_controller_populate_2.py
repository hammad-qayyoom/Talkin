import re
with open('/Users/hammadqayyoom/Projects/Talkin/sourcecode/admin/backend/controllers/v2/feed.controller.js', 'r') as f:
    text = f.read()

replacement = """    expert: expertRef
      ? {
          id: String(expertRef._id || ""),
          displayName: String(expertRef.displayName || ""),
          headline: String(expertRef.headline || ""),
          profileImage: normalizeMediaPath(expertRef.profileImage || expertRef.image || userRef?.profilePic || ""),
        }
      : null,"""

text = re.sub(r'    expert: expertRef\s*\?\s*\{\s*id: String\(expertRef._id \|\| ""\),\s*displayName: String\(expertRef\.displayName \|\| ""\),\s*headline: String\(expertRef\.headline \|\| ""\),\s*profileImage: normalizeMediaPath\(expertRef\.profileImage \|\| expertRef\.image \|\| ""\),\s*\}\s*: null,', replacement, text)

with open('/Users/hammadqayyoom/Projects/Talkin/sourcecode/admin/backend/controllers/v2/feed.controller.js', 'w') as f:
    f.write(text)
