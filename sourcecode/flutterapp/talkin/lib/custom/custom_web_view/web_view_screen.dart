import 'package:notisboard/utils/enums.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String screen;

  const WebViewScreen({super.key, required this.url, required this.screen});

  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  bool _contentStyleInjected = false;

  bool get _isPolicyLikeScreen {
    final screen = widget.screen.trim().toLowerCase();
    return screen.contains('privacy') ||
        screen.contains('policy') ||
        screen.contains('terms');
  }

  String get _screenSubtitle {
    if (_isPolicyLikeScreen) {
      return 'Read important legal and privacy details';
    }
    return 'Helpful information and app details';
  }

  Future<void> _applyContentStyling() async {
    if (!_isPolicyLikeScreen || _contentStyleInjected != false) {
      return;
    }

    const script = '''
      (function() {
        if (window.__notisboardStyled) {
          return;
        }
        window.__notisboardStyled = true;
        var style = document.createElement('style');
        style.textContent = ""
          + "html,body{background:#F4F5F7 !important;color:#171A22 !important;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif !important;line-height:1.62 !important;margin:0 !important;padding:0 !important;}"
          + "body > *{max-width:980px !important;margin:0 auto !important;padding-left:18px !important;padding-right:18px !important;}"
          + "h1{font-size:38px !important;line-height:1.12 !important;margin-top:18px !important;margin-bottom:14px !important;letter-spacing:-0.7px !important;}"
          + "h2{font-size:27px !important;line-height:1.2 !important;margin-top:24px !important;margin-bottom:10px !important;letter-spacing:-0.4px !important;}"
          + "h3{font-size:21px !important;line-height:1.24 !important;margin-top:20px !important;margin-bottom:10px !important;}"
          + "p,li{font-size:17px !important;color:#2F3442 !important;}"
          + "a{color:#C71F37 !important;}"
          + "hr{border:0 !important;border-top:1px solid #E5E7EB !important;margin:18px 0 !important;}";
        document.head.appendChild(style);
      })();
    ''';

    try {
      await controller.runJavaScript(script);
      _contentStyleInjected = true;
    } catch (_) {
      // Styling injection is best-effort; keep default content if blocked.
    }
  }

  @override
  void initState() {
    super.initState();
    Utils.showLog("urlWebVie::::::::::::::::::::${widget.url}");
    Utils.showLog("screen::::::::::::::::::::${widget.screen}");
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF4F5F7))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
              _contentStyleInjected = false;
            });
          },
          onPageFinished: (url) async {
            await _applyContentStyling();

            if (!mounted) {
              return;
            }

            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    controller.clearLocalStorage();
    Utils.onChangeStatusBar(brightness: Brightness.light);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentArea = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          if (_isPolicyLikeScreen) ...[
            _PolicyHeroBanner(title: widget.screen),
            const SizedBox(height: 10),
          ],
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.redesignSoftBorder),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: WebViewWidget(
                        controller: controller,
                      ),
                    ),
                    if (isLoading)
                      Positioned.fill(
                        child: Container(
                          color: AppColors.white.withValues(alpha: 0.92),
                          child: Center(
                            child: LoadingAnimationWidget.threeArchedCircle(
                              color: AppColors.redesignBrandDark,
                              size: 42,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      appBar: WebViewAppBar(
        title: widget.screen,
        subtitle: _screenSubtitle,
        useCenteredContentLane: _isPolicyLikeScreen,
      ),
      body: SafeArea(
        top: false,
        child: _isPolicyLikeScreen
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final maxContentWidth = constraints.maxWidth >= 760
                      ? 980.0
                      : constraints.maxWidth;

                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: contentArea,
                    ),
                  );
                },
              )
            : contentArea,
      ),
    );
  }
}

class _PolicyHeroBanner extends StatelessWidget {
  const _PolicyHeroBanner({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.redesignBrandRed,
            AppColors.redesignBrandRedDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 14,
                    fontColor: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  EnumLocale.txtUnderstandHowYourInformationIsProtected.name.tr,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 12,
                    fontColor: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WebViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String subtitle;
  final bool useCenteredContentLane;

  const WebViewAppBar({
    super.key,
    this.title,
    required this.subtitle,
    this.useCenteredContentLane = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(96);

  @override
  Widget build(BuildContext context) {
    final headerContent = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          _HeaderIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {
              Navigator.of(context).maybePop();
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? '',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 22,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 12,
                    fontColor: AppColors.redesignMutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.redesignScreenBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: useCenteredContentLane
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final maxContentWidth = constraints.maxWidth >= 760
                      ? 980.0
                      : constraints.maxWidth;

                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: headerContent,
                    ),
                  );
                },
              )
            : headerContent,
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Icon(
            icon,
            size: 19,
            color: AppColors.redesignBrandDark,
          ),
        ),
      ),
    );
  }
}
