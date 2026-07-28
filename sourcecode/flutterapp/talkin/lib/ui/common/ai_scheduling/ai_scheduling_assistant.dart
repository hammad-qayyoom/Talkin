import 'package:flutter/material.dart';
import 'package:notisboard/ui/common/session_booking/ai_scheduling_service.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/database.dart';

class AiSchedulingAssistant extends StatefulWidget {
  final String? listenerId;
  final String? expertId;
  final String expertName;
  final String callType;
  final String consultationMode;
  final VoidCallback? onBookingConfirmed;

  const AiSchedulingAssistant({
    super.key,
    this.listenerId,
    this.expertId,
    required this.expertName,
    this.callType = 'audio',
    this.consultationMode = 'online',
    this.onBookingConfirmed,
  });

  @override
  State<AiSchedulingAssistant> createState() => _AiSchedulingAssistantState();
}

class _AiSchedulingAssistantState extends State<AiSchedulingAssistant> {
  bool _isLoading = true;
  bool _isBooking = false;
  String _aiMessage = '';
  List<dynamic> _suggestedSlots = [];
  Map<String, dynamic>? _selectedSlot;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSuggestedSlots();
  }

  Future<void> _loadSuggestedSlots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AiSchedulingService.getSuggestedSlots(
      listenerId: widget.listenerId,
      expertId: widget.expertId,
      callType: widget.callType,
      consultationMode: widget.consultationMode,
    );

    if (!mounted) return;

    if (result['status'] == true) {
      final data = result['data'] ?? {};
      setState(() {
        _isLoading = false;
        _aiMessage = (data['aiMessage'] ?? '').toString();
        _suggestedSlots = data['suggestedSlots'] ?? [];
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = (result['message'] ?? 'Failed to load slots.').toString();
      });
    }
  }

  Future<void> _loadAlternatives() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AiSchedulingService.getAlternativeSlots(
      listenerId: widget.listenerId,
      expertId: widget.expertId,
      callType: widget.callType,
      consultationMode: widget.consultationMode,
    );

    if (!mounted) return;

    if (result['status'] == true) {
      final data = result['data'] ?? {};
      setState(() {
        _isLoading = false;
        _suggestedSlots = data['suggestedSlots'] ?? [];
        _selectedSlot = null;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = (result['message'] ?? 'Failed to load alternatives.').toString();
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedSlot == null) return;

    setState(() {
      _isBooking = true;
      _errorMessage = null;
    });

    final slotStartAt = (_selectedSlot!['startAt'] ?? '').toString();
    final slotEndAt = (_selectedSlot!['endAt'] ?? '').toString();

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

    if (result['status'] == true) {
      setState(() {
        _isBooking = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: AppColors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
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
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColors.redesignBrandRed,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Appointment Confirmed',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 18,
                            fontColor: AppColors.redesignBrandDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your appointment with ${widget.expertName} has been booked successfully. You will be notified when the session is ready.',
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 13,
                      fontColor: AppColors.redesignMutedText,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onBookingConfirmed?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.redesignBrandDark,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'OK',
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 14,
                          fontColor: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } else {
      final alternativeSlots = result['data']?['alternativeSlots'];
      setState(() {
        _isBooking = false;
        _errorMessage = (result['message'] ?? 'Booking failed.').toString();
        if (alternativeSlots is List && alternativeSlots.isNotEmpty) {
          _suggestedSlots = alternativeSlots;
          _selectedSlot = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header — matches _buildSectionCard pattern
          Row(
            children: [
              Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: AppColors.redesignAccentSoftBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: AppColors.redesignBrandRed,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AI Scheduling Assistant',
                style: AppFontStyle.fontStyleW700(
                  fontSize: 17,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: AppColors.redesignBrandRed),
              ),
            ),
          ] else if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: AppFontStyle.fontStyleW400(
                fontSize: 13,
                fontColor: AppColors.redesignBrandRed,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _loadSuggestedSlots,
              icon: Icon(Icons.refresh, size: 16, color: AppColors.redesignBrandDark),
              label: Text(
                'Retry',
                style: AppFontStyle.fontStyleW600(
                  fontSize: 13,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
            ),
          ] else ...[
            if (_aiMessage.isNotEmpty) ...[
              Text(
                _aiMessage,
                style: AppFontStyle.fontStyleW400(
                  fontSize: 13,
                  fontColor: AppColors.redesignMutedText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_suggestedSlots.isEmpty) ...[
              Text(
                'No upcoming availability found. Please check back later.',
                style: AppFontStyle.fontStyleW400(
                  fontSize: 13,
                  fontColor: AppColors.redesignMutedText,
                ),
              ),
            ] else ...[
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestedSlots.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final slot = _suggestedSlots[index];
                    final isSelected = _selectedSlot?['slotId'] == slot['slotId'];
                    return _buildSlotCard(slot, isSelected);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _loadAlternatives,
                      icon: const Icon(Icons.schedule, size: 16),
                      label: Text(
                        'Other Slots',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 13,
                          fontColor: AppColors.redesignBrandDark,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.redesignBrandDark,
                        side: BorderSide(color: AppColors.redesignSoftBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (_selectedSlot != null && !_isBooking)
                          ? _confirmBooking
                          : null,
                      icon: _isBooking
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline, size: 16),
                      label: Text(_isBooking ? 'Booking...' : 'Book Slot'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redesignBrandRed,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.redesignSoftBorder,
                        disabledForegroundColor: AppColors.redesignMutedText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSlotCard(Map<String, dynamic> slot, bool isSelected) {
    final dayLabel = (slot['dayLabel'] ?? '').toString();
    final timeLabel = (slot['timeLabel'] ?? '').toString();
    final isRecommended = slot['isRecommended'] == true;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSlot = isSelected ? null : slot;
        });
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.redesignBrandRed : AppColors.redesignSurfaceSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.redesignBrandRed
                : isRecommended
                    ? AppColors.redesignBrandRed.withValues(alpha: 0.3)
                    : AppColors.redesignSoftBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRecommended)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.white.withValues(alpha: 0.2)
                      : AppColors.redesignStatusSuccessBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Recommended',
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 9,
                    fontColor: isSelected
                        ? AppColors.white
                        : AppColors.redesignStatusSuccessDark,
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              dayLabel,
              style: AppFontStyle.fontStyleW500(
                fontSize: 12,
                fontColor: isSelected
                    ? AppColors.white.withValues(alpha: 0.7)
                    : AppColors.redesignMutedText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeLabel,
              style: AppFontStyle.fontStyleW700(
                fontSize: 16,
                fontColor: isSelected
                    ? AppColors.white
                    : AppColors.redesignBrandDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
