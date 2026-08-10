import 'package:flutter/material.dart';
import 'package:notisboard/ui/common/calendar_integration/calendar_service.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class AppleCalendarConnect extends StatefulWidget {
  final VoidCallback? onConnected;

  const AppleCalendarConnect({super.key, this.onConnected});

  @override
  State<AppleCalendarConnect> createState() => _AppleCalendarConnectState();
}

class _AppleCalendarConnectState extends State<AppleCalendarConnect> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connect(StateSetter setDialogState) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setDialogState(() => _error = 'Please enter your Apple ID and app-specific password.');
      return;
    }

    setDialogState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await CalendarService.connectApple(email: email, appPassword: password);
    if (!mounted) return;

    if (result['status'] == true) {
      widget.onConnected?.call();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Apple Calendar connected.'),
          backgroundColor: AppColors.green,
        ),
      );
    } else {
      setDialogState(() {
        _isLoading = false;
        _error = (result['message'] ?? 'Failed to connect.').toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showConnectDialog(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.redesignSurfaceSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.redesignSoftBorder),
            ),
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.redesignSoftBorder),
                  ),
                  child: Icon(Icons.apple, size: 22, color: AppColors.redesignBrandDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apple Calendar (iCloud)',
                        style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.redesignBrandDark),
                      ),
                      Text(
                        'Sync via CalDAV using app-specific password',
                        style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: AppColors.redesignMutedText),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.redesignMutedText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: AppColors.redesignAccentSoftBg,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(Icons.apple, color: AppColors.redesignBrandRed, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Connect Apple Calendar',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: AppColors.redesignBrandDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your Apple ID and an app-specific password. Generate one at appleid.apple.com under Security > App-Specific Passwords.',
                style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: AppColors.redesignMutedText, height: 1.45),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Apple ID (email)',
                  hintStyle: AppFontStyle.fontStyleW400(fontSize: 14, fontColor: AppColors.redesignMutedText),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.redesignSoftBorder)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.redesignSoftBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.redesignBrandRed)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'App-Specific Password',
                  hintStyle: AppFontStyle.fontStyleW400(fontSize: 14, fontColor: AppColors.redesignMutedText),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.redesignSoftBorder)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.redesignSoftBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.redesignBrandRed)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: AppColors.redesignBrandRed)),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.redesignSoftBorder),
                        foregroundColor: AppColors.redesignBrandDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Cancel', style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.redesignBrandDark)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _connect(setDialogState),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.redesignBrandDark,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                          : Text('Connect', style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      ),
      ),
    );
  }
}
