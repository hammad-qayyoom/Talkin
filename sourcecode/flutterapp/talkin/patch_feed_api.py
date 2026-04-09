import re
with open('lib/ui/user_flow/feed_screen/api/feed_api.dart', 'r') as f:
    text = f.read()

import_statement = "import 'package:http_parser/http_parser.dart';\n"
if "http_parser.dart" not in text:
    text = text.replace("import 'package:http/http.dart' as http;", "import 'package:http/http.dart' as http;\n" + import_statement)

replacement = """      if (mediaFile != null && await mediaFile.exists()) {
        final path = mediaFile.path.toLowerCase();
        final isVideo = path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.mkv') || path.endsWith('.webm') || path.endsWith('.avi');
        final isPng = path.endsWith('.png');
        final isGif = path.endsWith('.gif');
        
        request.files.add(await http.MultipartFile.fromPath(
          'media',
          mediaFile.path,
          contentType: MediaType(
            isVideo ? 'video' : 'image',
            isVideo ? 'mp4' : (isPng ? 'png' : (isGif ? 'gif' : 'jpeg')),
          ),
        ));
      }"""

old_code = """      if (mediaFile != null && await mediaFile.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'media',
          mediaFile.path,
        ));
      }"""

text = text.replace(old_code, replacement)

with open('lib/ui/user_flow/feed_screen/api/feed_api.dart', 'w') as f:
    f.write(text)
