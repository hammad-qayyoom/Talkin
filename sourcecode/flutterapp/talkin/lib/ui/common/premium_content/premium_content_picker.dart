import 'package:flutter/material.dart';
import 'package:notisboard/ui/common/premium_content/premium_content_service.dart';
import 'package:notisboard/ui/common/premium_content/premium_content_socket_handler.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class PremiumContentPicker extends StatefulWidget {
  final String sessionId;
  final VoidCallback? onContentSent;

  const PremiumContentPicker({
    super.key,
    required this.sessionId,
    this.onContentSent,
  });

  @override
  State<PremiumContentPicker> createState() => _PremiumContentPickerState();
}

class _PremiumContentPickerState extends State<PremiumContentPicker> {
  List<dynamic> _content = [];
  bool _isLoading = true;
  String? _selectedContentId;
  int? _customPrice;
  bool _isSending = false;

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

  void _sendPurchaseRequest() {
    if (_selectedContentId == null || _isSending) return;

    setState(() => _isSending = true);

    PremiumContentSocketHandler.sendPurchaseRequest(
      sessionId: widget.sessionId,
      contentId: _selectedContentId!,
      customPrice: _customPrice,
    );

    setState(() => _isSending = false);

    if (mounted) {
      widget.onContentSent?.call();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Send Premium Content',
                style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: AppColors.redesignBrandDark),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: AppColors.redesignMutedText),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Select content to offer for purchase during this session.',
            style: AppFontStyle.fontStyleW400(fontSize: 13, fontColor: AppColors.redesignMutedText),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            Center(child: CircularProgressIndicator(color: AppColors.redesignBrandRed))
          else if (_content.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.redesignSurfaceSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No content available. Upload content first.',
                  style: AppFontStyle.fontStyleW400(fontSize: 14, fontColor: AppColors.redesignMutedText),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _content.length,
                itemBuilder: (context, index) {
                  final item = _content[index];
                  final isSelected = _selectedContentId == item['_id'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedContentId = item['_id'];
                        _customPrice = item['price'];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.redesignBrandRed.withValues(alpha: 0.08) : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.redesignBrandRed : AppColors.redesignSoftBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.redesignAccentSoftBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getCategoryIcon(item['category']),
                              color: AppColors.redesignBrandRed,
                              size: 20,
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
                                Text(
                                  '${item['category'] ?? 'document'} · ${_formatSize(item['fileSizeBytes'])}',
                                  style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: AppColors.redesignMutedText),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${item['price']} coins',
                            style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: AppColors.redesignBrandRed),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_selectedContentId != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.redesignSurfaceSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_money, size: 18, color: AppColors.redesignBrandRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'User will be charged from their wallet balance.',
                      style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: AppColors.redesignMutedText),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendPurchaseRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redesignBrandRed,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                      )
                    : Text(
                        'Send Purchase Request',
                        style: AppFontStyle.fontStyleW600(fontSize: 15, fontColor: AppColors.white),
                      ),
              ),
            ),
          ],
        ],
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

  String _formatSize(int? bytes) {
    if (bytes == null || bytes == 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
