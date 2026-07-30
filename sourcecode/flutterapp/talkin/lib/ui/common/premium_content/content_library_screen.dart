import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:notisboard/ui/common/premium_content/premium_content_service.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class ContentLibraryScreen extends StatefulWidget {
  const ContentLibraryScreen({super.key});

  @override
  State<ContentLibraryScreen> createState() => _ContentLibraryScreenState();
}

class _ContentLibraryScreenState extends State<ContentLibraryScreen> {
  List<dynamic> _purchases = [];
  bool _isLoading = true;
  int _page = 1;
  bool _hasMore = true;
  Set<String> _downloadingIds = {};

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }
    setState(() => _isLoading = _page == 1);

    final result = await PremiumContentService.getUserPurchaseHistory(page: _page);
    if (mounted) {
      final purchases = result['data']?['purchases'] ?? [];
      final pages = result['data']?['pages'] ?? 1;
      setState(() {
        if (_page == 1) {
          _purchases = purchases;
        } else {
          _purchases.addAll(purchases);
        }
        _hasMore = _page < pages;
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadAndOpen(Map<String, dynamic> purchase) async {
    final purchaseId = purchase['_id'] ?? '';
    final contentTitle = purchase['contentId']?['title'] ?? 'content';
    final mimeType = purchase['contentId']?['fileMimeType'] ?? '';
    final fileName = purchase['contentId']?['fileName'] ?? 'download';

    if (_downloadingIds.contains(purchaseId)) return;

    setState(() => _downloadingIds.add(purchaseId));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading "$contentTitle"...'),
        backgroundColor: AppColors.redesignBrandDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    try {
      final token = await FirebaseAccessToken.onGet() ?? '';
      final url = '${Api.premiumContentDownload}$purchaseId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'key': Api.secretKey,
          'x-auth-token': 'Bearer $token',
          'x-auth-uid': Database.loginUserFirebaseId,
        },
      );

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final ext = _getExtensionFromMime(mimeType, fileName);
        final safeName = contentTitle.replaceAll(RegExp(r'[^\w\-]'), '_');
        final file = File('${dir.path}/${safeName}_$purchaseId$ext');
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          final result = await OpenFilex.open(file.path);
          if (result.type != ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cannot open this file type. Saved to: ${file.path}'),
                backgroundColor: AppColors.redesignBrandDark,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download failed (${response.statusCode})'),
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
            content: Text('Download failed: $e'),
            backgroundColor: AppColors.redesignBrandRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingIds.remove(purchaseId));
    }
  }

  String _getExtensionFromMime(String mime, String originalName) {
    if (originalName.contains('.')) {
      return originalName.substring(originalName.lastIndexOf('.'));
    }
    const map = {
      'application/pdf': '.pdf',
      'image/png': '.png',
      'image/jpeg': '.jpg',
      'image/webp': '.webp',
      'application/msword': '.doc',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document': '.docx',
      'text/plain': '.txt',
      'video/mp4': '.mp4',
      'audio/mpeg': '.mp3',
    };
    return map[mime] ?? '.bin';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        title: Text(
          'Content Library',
          style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: AppColors.redesignBrandDark),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.redesignBrandRed))
          : _purchases.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.redesignSoftBorder),
                      const SizedBox(height: 16),
                      Text(
                        'No purchases yet',
                        style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.redesignBrandDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Purchased content during sessions will appear here.',
                        style: AppFontStyle.fontStyleW400(fontSize: 13, fontColor: AppColors.redesignMutedText),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadPurchases(refresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _purchases.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _purchases.length) {
                        _loadPurchases();
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(color: AppColors.redesignBrandRed),
                          ),
                        );
                      }
                      final purchase = _purchases[index];
                      final content = purchase['contentId'];
                      final expert = purchase['expertId'];
                      final purchaseId = purchase['_id'] ?? '';
                      final isDownloading = _downloadingIds.contains(purchaseId);
                      final expertName = expert?['displayName'] ?? expert?['userId']?['fullName'] ?? 'Expert';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.redesignSoftBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.redesignAccentSoftBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getCategoryIcon(content?['category']),
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
                                    content?['title'] ?? 'Content',
                                    style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.redesignBrandDark),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'From $expertName · ${purchase['price']} coins',
                                    style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: AppColors.redesignMutedText),
                                  ),
                                ],
                              ),
                            ),
                            isDownloading
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.redesignBrandRed),
                                  )
                                : IconButton(
                                    onPressed: () => _downloadAndOpen(purchase),
                                    icon: Icon(Icons.download_rounded, color: AppColors.redesignBrandRed, size: 22),
                                    tooltip: 'Download & Open',
                                  ),
                          ],
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
