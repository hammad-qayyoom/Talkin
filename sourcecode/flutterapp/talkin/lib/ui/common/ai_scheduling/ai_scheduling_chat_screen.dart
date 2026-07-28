import 'package:flutter/material.dart';
import 'package:notisboard/ui/common/session_booking/ai_scheduling_service.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/database.dart';

class AiSchedulingChatScreen extends StatefulWidget {
  final String? listenerId;
  final String? expertId;
  final String expertName;
  final String callType;
  final String consultationMode;
  final VoidCallback? onBookingConfirmed;

  const AiSchedulingChatScreen({
    super.key,
    this.listenerId,
    this.expertId,
    required this.expertName,
    this.callType = 'audio',
    this.consultationMode = 'online',
    this.onBookingConfirmed,
  });

  @override
  State<AiSchedulingChatScreen> createState() => _AiSchedulingChatScreenState();
}

class _ChatMessage {
  final bool isUser;
  final String text;
  final List<dynamic> suggestedSlots;
  final DateTime timestamp;

  _ChatMessage({
    required this.isUser,
    required this.text,
    this.suggestedSlots = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class _AiSchedulingChatScreenState extends State<AiSchedulingChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      isUser: false,
      text: 'Hello! I can help you schedule an appointment with ${widget.expertName}. '
          'What time works best for you?',
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: text));
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();

    final result = await AiSchedulingService.chatWithAssistant(
      listenerId: widget.listenerId,
      expertId: widget.expertId,
      message: text,
      callType: widget.callType,
      consultationMode: widget.consultationMode,
    );

    if (!mounted) return;

    final aiMessage = (result['data']?['aiMessage'] ?? result['message'] ?? 'Sorry, I could not process that.').toString();
    final slots = result['data']?['suggestedSlots'] ?? [];

    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage(
        isUser: false,
        text: aiMessage,
        suggestedSlots: slots,
      ));
    });
    _scrollToBottom();
  }

  Future<void> _bookSlot(Map<String, dynamic> slot) async {
    setState(() {
      _isBooking = true;
    });

    final slotStartAt = (slot['startAt'] ?? '').toString();
    final slotEndAt = (slot['endAt'] ?? '').toString();

    final result = await AiSchedulingService.confirmSmartSchedule(
      userId: Database.loginUserId,
      listenerId: widget.listenerId,
      expertId: widget.expertId,
      callType: widget.callType,
      slotStartAt: slotStartAt,
      slotEndAt: slotEndAt,
      consultationMode: widget.consultationMode,
    );

    if (!mounted) return;

    setState(() {
      _isBooking = false;
    });

    if (result['status'] == true) {
      setState(() {
        _messages.add(_ChatMessage(
          isUser: false,
          text: 'Your appointment has been confirmed! You will receive a notification when the session is ready.',
        ));
      });
      _scrollToBottom();
      widget.onBookingConfirmed?.call();
    } else {
      setState(() {
        _messages.add(_ChatMessage(
          isUser: false,
          text: (result['message'] ?? 'Booking failed. Please try again.').toString(),
        ));
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      appBar: AppBar(
        title: Text(
          'Schedule with ${widget.expertName}',
          style: AppFontStyle.fontStyleW600(
            fontSize: 17,
            fontColor: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.redesignBrandDark,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.redesignBrandDark
                    : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(color: AppColors.redesignSoftBorder),
              ),
              child: Text(
                message.text,
                style: AppFontStyle.fontStyleW400(
                  fontSize: 14,
                  fontColor: isUser ? AppColors.white : AppColors.redesignBrandDark,
                  height: 1.4,
                ),
              ),
            ),
            if (message.suggestedSlots.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...message.suggestedSlots.map<Widget>((slot) {
                return _buildSlotOption(slot);
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSlotOption(Map<String, dynamic> slot) {
    final fullLabel = (slot['fullLabel'] ?? '').toString();
    final slotDuration = slot['slotDurationMinutes'] ?? 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: AppColors.redesignSurfaceSoft,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _isBooking ? null : () => _bookSlot(slot),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: AppColors.redesignAccentSoftBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.redesignBrandRed,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullLabel,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 13,
                          fontColor: AppColors.redesignBrandDark,
                        ),
                      ),
                      Text(
                        '$slotDuration min',
                        style: AppFontStyle.fontStyleW400(
                          fontSize: 11,
                          fontColor: AppColors.redesignMutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.redesignBrandRed, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.redesignSoftBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.redesignBrandRed,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Thinking...',
              style: AppFontStyle.fontStyleW400(
                fontSize: 13,
                fontColor: AppColors.redesignMutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                style: AppFontStyle.fontStyleW400(
                  fontSize: 14,
                  fontColor: AppColors.redesignBrandDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask about available slots...',
                  hintStyle: AppFontStyle.fontStyleW400(
                    fontSize: 14,
                    fontColor: AppColors.redesignMutedText,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.redesignSoftBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.redesignSoftBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.redesignBrandRed),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.redesignBrandRed,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isTyping ? null : _sendMessage,
                icon: const Icon(Icons.send, color: AppColors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
