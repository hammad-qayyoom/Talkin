import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:notisboard/ui/common/premium_content/premium_content_service.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class ExpertContentManager extends StatefulWidget {
  const ExpertContentManager({super.key});

  @override
  State<ExpertContentManager> createState() => _ExpertContentManagerState();
}

class _ExpertContentManagerState extends State<ExpertContentManager> {
  List<dynamic> _content = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    final result = await PremiumContentService.listMyContent(limit: 50);
    if (mounted) {
      setState(() {
        _content = result['data']?['content'] ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _previewContent(dynamic item) async {
    if (!mounted) return;
    final contentId = item['_id'] ?? '';
    final title = item['title'] ?? 'Preview';
    final mimeType = item['fileMimeType'] ?? '';

    if (mimeType.startsWith('image/')) {
      _previewImage(contentId, title);
    } else if (mimeType == 'application/pdf') {
      _previewPdf(contentId, title);
    } else {
      _downloadAndOpen(contentId, title, mimeType);
    }
  }

  Future<void> _previewImage(String contentId, String title) async {
    final token = await FirebaseAccessToken.onGet() ?? '';
    final url = '${Api.premiumContentPreview}$contentId';

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ImagePreviewScreen(
          imageUrl: url,
          title: title,
          token: token,
          secretKey: Api.secretKey,
          firebaseId: Database.loginUserFirebaseId,
        ),
      ),
    );
  }

  Future<void> _previewPdf(String contentId, String title) async {
    final token = await FirebaseAccessToken.onGet() ?? '';
    final url = '${Api.premiumContentPreview}$contentId';

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PdfPreviewScreen(
          fileUrl: url,
          title: title,
          token: token,
          secretKey: Api.secretKey,
          firebaseId: Database.loginUserFirebaseId,
        ),
      ),
    );
  }

  Future<void> _downloadAndOpen(String contentId, String title, String mimeType) async {
    try {
      final token = await FirebaseAccessToken.onGet() ?? '';
      final url = '${Api.premiumContentPreview}$contentId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'key': Api.secretKey,
          'x-auth-token': 'Bearer $token',
          'x-auth-uid': Database.loginUserFirebaseId,
        },
      );

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final ext = _getExtensionFromMime(mimeType);
        final file = File('${dir.path}/preview_$contentId$ext');
        await file.writeAsBytes(response.bodyBytes);

        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open this file type'),
              backgroundColor: AppColors.redesignBrandRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open file: $e'),
            backgroundColor: AppColors.redesignBrandRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  String _getExtensionFromMime(String mime) {
    const map = {
      'application/pdf': '.pdf',
      'application/msword': '.doc',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document': '.docx',
      'application/vnd.ms-excel': '.xls',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': '.xlsx',
      'text/plain': '.txt',
      'text/csv': '.csv',
      'video/mp4': '.mp4',
      'audio/mpeg': '.mp3',
      'audio/wav': '.wav',
    };
    return map[mime] ?? '.bin';
  }

  Future<void> _deleteContent(dynamic item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.redesignBrandRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline, color: AppColors.redesignBrandRed, size: 26),
              ),
              const SizedBox(height: 14),
              Text(
                'Delete Content?',
                style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.redesignBrandDark),
              ),
              const SizedBox(height: 6),
              Text(
                '"${item['title'] ?? ''}" will be permanently removed.',
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW400(fontSize: 13, fontColor: AppColors.redesignMutedText),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.redesignMutedText,
                        side: BorderSide(color: AppColors.redesignSoftBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel', style: AppFontStyle.fontStyleW500(fontSize: 14, fontColor: AppColors.redesignMutedText)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redesignBrandRed,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Delete', style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await PremiumContentService.deleteContent(item['_id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Deleted'),
            backgroundColor: result['status'] == true ? AppColors.green : AppColors.redesignBrandRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        if (result['status'] == true) _loadContent();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: AppColors.redesignBrandRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _uploadContent() async {
    final result = await FilePicker.platform.pickFiles(
      withData: false,
      withReadStream: false,
    );
    if (result == null || result.files.isEmpty) return;
    if (!mounted) return;

    final platformFile = result.files.first;
    if (platformFile.path == null) return;

    final file = File(platformFile.path!);
    final fileName = platformFile.name;

    final titleController = TextEditingController();
    final priceController = TextEditingController(text: '10');
    String selectedCategory = 'document';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setDialogState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Content',
                  style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: AppColors.redesignBrandDark),
                ),
                const SizedBox(height: 4),
                Text(
                  fileName,
                  style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: AppColors.redesignMutedText),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'document', child: Text('Document')),
                    DropdownMenuItem(value: 'image', child: Text('Image')),
                    DropdownMenuItem(value: 'worksheet', child: Text('Worksheet')),
                    DropdownMenuItem(value: 'prescription', child: Text('Prescription')),
                    DropdownMenuItem(value: 'report', child: Text('Report')),
                    DropdownMenuItem(value: 'guide', child: Text('Guide')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (val) {
                    setDialogState(() => selectedCategory = val ?? 'document');
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price (coins)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.redesignMutedText,
                          side: BorderSide(color: AppColors.redesignSoftBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Cancel', style: AppFontStyle.fontStyleW500(fontSize: 14, fontColor: AppColors.redesignMutedText)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.redesignBrandRed,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Upload', style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true) return;
    if (titleController.text.trim().isEmpty) return;
    if (!mounted) return;

    setState(() => _isUploading = true);

    try {
      final token = await _getMultipartToken();
      final request = http.MultipartRequest('POST', Uri.parse(Api.premiumContentUpload));
      request.headers.addAll({
        'key': Api.secretKey,
        'x-auth-token': 'Bearer $token',
        'x-auth-uid': Database.loginUserFirebaseId,
      });
      final mimeType = _getMimeType(fileName);
      final mimeParts = mimeType.split('/');
      request.files.add(
        http.MultipartFile(
          'file',
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: fileName,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        ),
      );
      request.fields['title'] = titleController.text.trim();
      request.fields['category'] = selectedCategory;
      request.fields['price'] = priceController.text.trim();

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final result = json.decode(response.body);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Upload completed'),
            backgroundColor: result['status'] == true ? AppColors.green : AppColors.redesignBrandRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        _loadContent();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.redesignBrandRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<String> _getMultipartToken() async {
    final token = await FirebaseAccessToken.onGet() ?? '';
    return token;
  }

  static String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    const mimeMap = {
      'pdf': 'application/pdf',
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'webp': 'image/webp',
      'gif': 'image/gif',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'txt': 'text/plain',
      'csv': 'text/csv',
      'mp4': 'video/mp4',
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    };
    return mimeMap[ext] ?? 'application/octet-stream';
  }

  Color _getStatusColor(dynamic item) {
    if (item['isActive'] == false && item['isApproved'] == false) return AppColors.redesignBrandRed;
    if (item['isApproved'] == true) return AppColors.green;
    return Colors.orange;
  }

  String _getStatusText(dynamic item) {
    if (item['isActive'] == false && item['isApproved'] == false) return 'Rejected';
    if (item['isApproved'] == true) return 'Approved';
    return 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        title: Text(
          'My Premium Content',
          style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: AppColors.redesignBrandDark),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _uploadContent,
        backgroundColor: AppColors.redesignBrandRed,
        icon: _isUploading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
            : const Icon(Icons.add, color: AppColors.white),
        label: Text(
          _isUploading ? 'Uploading...' : 'Upload Content',
          style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.white),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.redesignBrandRed))
          : _content.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 64, color: AppColors.redesignSoftBorder),
                      const SizedBox(height: 16),
                      Text(
                        'No content yet',
                        style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.redesignBrandDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload premium content to sell during sessions.',
                        style: AppFontStyle.fontStyleW400(fontSize: 13, fontColor: AppColors.redesignMutedText),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadContent(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _content.length,
                    itemBuilder: (context, index) {
                      final item = _content[index];
                      final statusColor = _getStatusColor(item);
                      final statusText = _getStatusText(item);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.redesignSoftBorder),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.redesignAccentSoftBg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(item['category']),
                                      color: AppColors.redesignBrandRed,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'] ?? '',
                                          style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.redesignBrandDark),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              '${item['price']} coins',
                                              style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.redesignBrandRed),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Sold: ${item['totalSold'] ?? 0}',
                                              style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: AppColors.redesignMutedText),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: statusColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                statusText,
                                                style: AppFontStyle.fontStyleW500(fontSize: 10, fontColor: statusColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _previewContent(item),
                                      icon: Icon(Icons.visibility_outlined, size: 16, color: AppColors.redesignBrandDark),
                                      label: Text('View', style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.redesignBrandDark)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.redesignBrandDark,
                                        side: BorderSide(color: AppColors.redesignSoftBorder),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _deleteContent(item),
                                      icon: Icon(Icons.delete_outline, size: 16, color: AppColors.redesignBrandRed),
                                      label: Text('Delete', style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.redesignBrandRed)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.redesignBrandRed,
                                        side: BorderSide(color: AppColors.redesignBrandRed.withValues(alpha: 0.3)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'document':
        return Icons.description;
      case 'image':
        return Icons.image;
      case 'worksheet':
        return Icons.article;
      case 'prescription':
        return Icons.medical_services;
      case 'report':
        return Icons.assessment;
      case 'guide':
        return Icons.menu_book;
      default:
        return Icons.insert_drive_file;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// Image Preview Screen
// ═══════════════════════════════════════════════════════════════
class _ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String token;
  final String secretKey;
  final String firebaseId;

  const _ImagePreviewScreen({
    required this.imageUrl,
    required this.title,
    required this.token,
    required this.secretKey,
    required this.firebaseId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.black,
        title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          headers: {
            'key': secretKey,
            'x-auth-token': 'Bearer $token',
            'x-auth-uid': firebaseId,
          },
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return CircularProgressIndicator(color: AppColors.redesignBrandRed);
          },
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.white54, size: 64),
                const SizedBox(height: 12),
                Text('Failed to load image', style: TextStyle(color: Colors.white54)),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PDF Preview Screen
// ═══════════════════════════════════════════════════════════════
class _PdfPreviewScreen extends StatefulWidget {
  final String fileUrl;
  final String title;
  final String token;
  final String secretKey;
  final String firebaseId;

  const _PdfPreviewScreen({
    required this.fileUrl,
    required this.title,
    required this.token,
    required this.secretKey,
    required this.firebaseId,
  });

  @override
  State<_PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<_PdfPreviewScreen> {
  String? _localPath;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      final response = await http.get(
        Uri.parse(widget.fileUrl),
        headers: {
          'key': widget.secretKey,
          'x-auth-token': 'Bearer ${widget.token}',
          'x-auth-uid': widget.firebaseId,
        },
      );

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/preview_${widget.title}.pdf');
        await file.writeAsBytes(response.bodyBytes);
        if (mounted) {
          setState(() {
            _localPath = file.path;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Failed to load PDF';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        title: Text(
          widget.title,
          style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.redesignBrandDark),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.redesignBrandRed))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: AppColors.redesignBrandRed, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!, style: TextStyle(color: AppColors.redesignMutedText)),
                    ],
                  ),
                )
              : PDFView(
                  filePath: _localPath,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                ),
    );
  }
}
