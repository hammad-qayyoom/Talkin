import 'package:flutter/material.dart';
import 'package:notisboard/ui/common/calendar_integration/calendar_service.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleCalendarConnect extends StatefulWidget {
  final VoidCallback? onConnected;

  const GoogleCalendarConnect({super.key, this.onConnected});

  @override
  State<GoogleCalendarConnect> createState() => _GoogleCalendarConnectState();
}

class _GoogleCalendarConnectState extends State<GoogleCalendarConnect> {
  bool _isLoading = false;

  Future<void> _connect() async {
    setState(() => _isLoading = true);

    final result = await CalendarService.connectGoogle();
    if (!mounted) return;

    if (result['status'] != true) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']?.toString() ?? 'Failed to initiate Google connection.'),
            backgroundColor: AppColors.redesignBrandRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return;
    }

    final authUrl = result['data']?['authUrl'] ?? '';

    if (authUrl.isEmpty) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No authorization URL received from server.'),
            backgroundColor: AppColors.redesignBrandRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _GoogleOAuthWebView(authUrl: authUrl),
      ),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    await Future.delayed(const Duration(seconds: 1));

    final connectionsResult = await CalendarService.getConnections();
    if (!mounted) return;

    final connections = connectionsResult['data']?['connections'] ?? [];
    final hasGoogle = (connections as List).any((c) => c['provider'] == 'google');

    if (hasGoogle) {
      widget.onConnected?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Google Calendar connected successfully.'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Google Calendar connection was cancelled or failed.'),
            backgroundColor: AppColors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
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
          onTap: _isLoading ? null : _connect,
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
                  child: Icon(Icons.g_mobiledata, size: 22, color: AppColors.redesignBrandDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google Calendar',
                        style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.redesignBrandDark),
                      ),
                      Text(
                        'Sync your Google Calendar to prevent conflicts',
                        style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: AppColors.redesignMutedText),
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.redesignBrandRed),
                  )
                else
                  Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.redesignMutedText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleOAuthWebView extends StatefulWidget {
  final String authUrl;

  const _GoogleOAuthWebView({required this.authUrl});

  @override
  State<_GoogleOAuthWebView> createState() => _GoogleOAuthWebViewState();
}

class _GoogleOAuthWebViewState extends State<_GoogleOAuthWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('FlutterChannel', onMessageReceived: (_) {
        if (mounted) Navigator.pop(context, true);
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
            if (url.contains('/api/v2/calendar/callback/google')) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) Navigator.pop(context, true);
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.redesignBrandDark),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          'Google Calendar',
          style: AppFontStyle.fontStyleW600(fontSize: 18, fontColor: AppColors.redesignBrandDark),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(color: AppColors.redesignBrandRed),
            ),
        ],
      ),
    );
  }
}
