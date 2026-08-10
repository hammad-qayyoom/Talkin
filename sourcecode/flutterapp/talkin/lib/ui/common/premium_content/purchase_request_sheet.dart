import 'package:flutter/material.dart';
import 'package:notisboard/ui/common/premium_content/premium_content_socket_handler.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class PurchaseRequestSheet extends StatefulWidget {
  final Map<String, dynamic> requestData;

  const PurchaseRequestSheet({super.key, required this.requestData});

  @override
  State<PurchaseRequestSheet> createState() => _PurchaseRequestSheetState();
}

class _PurchaseRequestSheetState extends State<PurchaseRequestSheet> {
  bool _isProcessing = false;

  void _accept() {
    setState(() => _isProcessing = true);
    PremiumContentSocketHandler.acceptPurchaseRequest(
      widget.requestData['purchaseId'],
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _decline() {
    PremiumContentSocketHandler.declinePurchaseRequest(
      widget.requestData['purchaseId'],
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.requestData;
    final price = data['price'] ?? 0;
    final title = data['contentTitle'] ?? 'Premium Content';
    final description = data['contentDescription'] ?? '';
    final category = data['contentCategory'] ?? 'document';
    final fileSize = data['fileSizeBytes'] ?? 0;
    final expertName = data['expertName'] ?? 'Expert';
    final sessionTimeRemaining = data['sessionTimeRemaining'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.redesignSoftBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.redesignAccentSoftBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: AppColors.redesignBrandRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Content Offer',
                      style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.redesignBrandDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$expertName is offering you:',
                      style: AppFontStyle.fontStyleW400(fontSize: 13, fontColor: AppColors.redesignMutedText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.redesignSurfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFontStyle.fontStyleW600(fontSize: 15, fontColor: AppColors.redesignBrandDark),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: AppColors.redesignMutedText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoChip(_formatSize(fileSize)),
                    const SizedBox(width: 8),
                    _buildInfoChip(category.toUpperCase()),
                    if (sessionTimeRemaining != null) ...[
                      const SizedBox(width: 8),
                      _buildInfoChip('${sessionTimeRemaining}m left'),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.redesignBrandRed.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.redesignBrandRed.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, size: 20, color: AppColors.redesignBrandRed),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$price coins will be deducted from your wallet.',
                    style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: AppColors.redesignBrandRed),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isProcessing ? null : _decline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.redesignMutedText,
                    side: BorderSide(color: AppColors.redesignSoftBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Decline',
                    style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.redesignMutedText),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _accept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redesignBrandRed,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                        )
                      : Text(
                          'Accept & Pay $price Coins',
                          style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.white),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Text(
        text,
        style: AppFontStyle.fontStyleW500(fontSize: 10, fontColor: AppColors.redesignMutedText),
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

  String _formatSize(int bytes) {
    if (bytes == 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
