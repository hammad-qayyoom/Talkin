import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/services/translation/translation_models.dart';
import 'package:notisboard/services/translation/translation_service.dart';
import 'package:notisboard/utils/constant.dart';

class SubtitleOverlay extends StatelessWidget {
  const SubtitleOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TranslationService>(
      id: Constant.idSubtitle,
      builder: (service) {
        final activeSubs = service.activeSubtitles;
        final mySubtitle = service.myLastSubtitle;

        // Show nothing if no subtitles
        if (activeSubs.isEmpty &&
            (mySubtitle == null || mySubtitle.translatedText.isEmpty)) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: 16,
          right: 16,
          bottom: 140,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Other participants' subtitles (group: up to 3)
              ...activeSubs.map((sub) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _SubtitleBubble(
                      subtitle: sub,
                      isOwn: false,
                      key: ValueKey('other_${sub.senderId}_${sub.timestamp}'),
                    ),
                  )),

              // My own subtitle (only when no other subtitles showing)
              if (mySubtitle != null &&
                  mySubtitle.translatedText.isNotEmpty &&
                  activeSubs.isEmpty)
                _SubtitleBubble(
                  subtitle: mySubtitle,
                  isOwn: true,
                  key: ValueKey('mine_${mySubtitle.timestamp}'),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SubtitleBubble extends StatefulWidget {
  final SubtitleData subtitle;
  final bool isOwn;

  const _SubtitleBubble({
    required this.subtitle,
    required this.isOwn,
    super.key,
  });

  @override
  State<_SubtitleBubble> createState() => _SubtitleBubbleState();
}

class _SubtitleBubbleState extends State<_SubtitleBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.subtitle;

    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isOwn
                ? const Color(0xFF00C853).withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isOwn
                  ? const Color(0xFF00C853).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.12),
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sender name + role badge
              if (subtitle.senderName.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      subtitle.senderRole == 'expert'
                          ? Icons.star_rounded
                          : Icons.person_rounded,
                      size: 12,
                      color: subtitle.senderRole == 'expert'
                          ? const Color(0xFFFFD700)
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subtitle.senderName,
                      style: TextStyle(
                        color: subtitle.senderRole == 'expert'
                            ? const Color(0xFFFFD700)
                            : Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],

              // Original text (dimmed, if different from translated)
              if (subtitle.originalText.isNotEmpty &&
                  subtitle.originalText != subtitle.translatedText) ...[
                Text(
                  subtitle.originalText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: widget.isOwn ? 0.6 : 0.55),
                    fontSize: widget.isOwn ? 11 : 12,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],

              // Translated text (primary)
              Text(
                subtitle.translatedText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.isOwn ? 13 : 15,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              // Language direction
              Row(
                children: [
                  Icon(
                    widget.isOwn ? Icons.mic : Icons.translate,
                    size: 12,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${TranslationService.getLanguageName(subtitle.sourceLang)} → ${TranslationService.getLanguageName(subtitle.targetLang)}",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TranslationToggleWidget extends StatelessWidget {
  final String callType;
  final VoidCallback? onToggle;

  const TranslationToggleWidget({
    super.key,
    required this.callType,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TranslationService>(
      id: Constant.idTranslation,
      builder: (service) {
        if (!service.isEnabled) return const SizedBox.shrink();
        if (!service.isCallTypeSupported(callType)) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: onToggle ??
              () {
                if (service.isActive) {
                  service.stopTranslation();
                } else {
                  // Will be called with the actual callId from the controller
                }
              },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: service.isActive
                  ? const Color(0xFF00C853).withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: service.isActive
                    ? const Color(0xFF00C853).withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.translate,
                  size: 18,
                  color: service.isActive
                      ? const Color(0xFF00C853)
                      : Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  service.isActive ? 'ON' : 'Translate',
                  style: TextStyle(
                    color: service.isActive
                        ? const Color(0xFF00C853)
                        : Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LanguageSelectorSheet extends StatelessWidget {
  final String title;
  final String selectedCode;
  final List<String> supportedCodes;
  final ValueChanged<String> onSelected;

  const LanguageSelectorSheet({
    super.key,
    required this.title,
    required this.selectedCode,
    required this.supportedCodes,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: supportedCodes.length,
              itemBuilder: (context, index) {
                final code = supportedCodes[index];
                final lang = SupportedLanguage.findByCode(code);
                final isSelected = code == selectedCode;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    lang?.name ?? code.toUpperCase(),
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    onSelected(code);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
