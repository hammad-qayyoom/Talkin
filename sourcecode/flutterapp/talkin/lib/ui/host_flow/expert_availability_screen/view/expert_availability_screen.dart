import 'package:flutter/material.dart';
import 'package:notisboard/ui/common/session_booking/session_booking_service.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class ExpertAvailabilityScreen extends StatefulWidget {
  const ExpertAvailabilityScreen({super.key});

  @override
  State<ExpertAvailabilityScreen> createState() =>
      _ExpertAvailabilityScreenState();
}

class _ExpertAvailabilityScreenState extends State<ExpertAvailabilityScreen> {
  bool _isLoading = false;
  bool _isSaving = false;

  int _selectedDay = DateTime.now().weekday % 7;
  TimeOfDay _selectedStart = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _selectedEnd = const TimeOfDay(hour: 10, minute: 0);

  List<Map<String, dynamic>> _slots = [];

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  String get _listenerId {
    final fromLogin =
        (Database.fetchLoginUserProfileModel?.user?.listenerId ?? '')
            .toString()
            .trim();
    if (fromLogin.isNotEmpty) {
      return fromLogin;
    }

    final fromListenerProfile =
        (Database.fetchListenerProfileModel?.data?.id ?? '').toString().trim();
    if (fromListenerProfile.isNotEmpty) {
      return fromListenerProfile;
    }

    return Database.loginListenerId.trim();
  }

  bool get _isAudioServiceEnabled =>
      Database
          .fetchListenerProfileModel?.data?.isAvailableForPrivateAudioCall !=
      false;

  bool get _isVideoServiceEnabled =>
      Database
          .fetchListenerProfileModel?.data?.isAvailableForPrivateVideoCall !=
      false;

  int get _configuredSlotDurationMinutes {
    final raw = Database.settingApiModel?.data?.sessionSlotDurationMinutes;
    final parsed = int.tryParse((raw ?? 30).toString()) ?? 30;

    if (parsed < 10) {
      return 30;
    }

    if (parsed > 240) {
      return 240;
    }

    return parsed;
  }

  String get _configuredBookingTimezone {
    final raw = (Database.settingApiModel?.data?.sessionBookingTimezone ?? '')
        .toString()
        .trim();
    return raw.isEmpty ? 'UTC' : raw;
  }

  String _buildNormalizedSlotKey(Map<String, dynamic> slot) {
    final day = int.tryParse((slot['dayOfWeek'] ?? '0').toString()) ?? 0;
    final start = int.tryParse((slot['startMinutes'] ?? '0').toString()) ?? 0;
    final end = int.tryParse((slot['endMinutes'] ?? '0').toString()) ?? 0;
    final duration = int.tryParse(
            (slot['slotDurationMinutes'] ?? _configuredSlotDurationMinutes)
                .toString()) ??
        _configuredSlotDurationMinutes;
    final timezone =
        (slot['timezone'] ?? _configuredBookingTimezone).toString().trim();

    return '${day}_${start}_${end}_${duration}_$timezone';
  }

  String _serviceTypeLabel() {
    if (_isAudioServiceEnabled && _isVideoServiceEnabled) {
      return 'General (Audio + Video enabled)';
    }

    if (_isAudioServiceEnabled) {
      return 'General (Audio only enabled)';
    }

    if (_isVideoServiceEnabled) {
      return 'General (Video only enabled)';
    }

    return 'General (enable Audio/Video from home)';
  }

  Future<void> _loadAvailability() async {
    setState(() {
      _isLoading = true;
    });

    final response = await SessionBookingService.getExpertAvailability(
      listenerId: _listenerId.isEmpty ? null : _listenerId,
    );
    final data = response['data'] as List<dynamic>? ?? [];

    final mergedSlots = <String, Map<String, dynamic>>{};

    for (final slot in data.whereType<Map<String, dynamic>>()) {
      final key = _buildNormalizedSlotKey(slot);
      final existing = mergedSlots[key] ??
          {
            'dayOfWeek':
                int.tryParse((slot['dayOfWeek'] ?? '0').toString()) ?? 0,
            'startMinutes':
                int.tryParse((slot['startMinutes'] ?? '0').toString()) ?? 0,
            'endMinutes':
                int.tryParse((slot['endMinutes'] ?? '0').toString()) ?? 0,
            'slotDurationMinutes': int.tryParse((slot['slotDurationMinutes'] ??
                        _configuredSlotDurationMinutes)
                    .toString()) ??
                _configuredSlotDurationMinutes,
            'timezone':
                (slot['timezone'] ?? _configuredBookingTimezone).toString(),
            'isActive': true,
          };

      mergedSlots[key] = existing;
    }

    final normalized = mergedSlots.values.toList()
      ..sort((a, b) {
        final dayCompare =
            (a['dayOfWeek'] as int).compareTo((b['dayOfWeek'] as int));
        if (dayCompare != 0) {
          return dayCompare;
        }

        return (a['startMinutes'] as int).compareTo((b['startMinutes'] as int));
      });

    if (!mounted) {
      return;
    }

    setState(() {
      _slots = normalized;
      _isLoading = false;
    });

    if (response['status'] != true) {
      Utils.showToast(context,
          (response['message'] ?? 'Failed to fetch availability.').toString());
    }
  }

  int _timeToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  String _dayLabel(int day) {
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return labels[day.clamp(0, 6)];
  }

  String _minutesToTime(int minutes) {
    final hour = (minutes ~/ 60).clamp(0, 23);
    final minute = (minutes % 60).clamp(0, 59);
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  Future<void> _addSlot() async {
    if (!_isAudioServiceEnabled && !_isVideoServiceEnabled) {
      Utils.showToast(
        context,
        'Enable Audio or Video from home screen before adding slots.',
      );
      return;
    }

    final startMinutes = _timeToMinutes(_selectedStart);
    final endMinutes = _timeToMinutes(_selectedEnd);

    if (startMinutes >= endMinutes) {
      Utils.showToast(context, 'End time must be after start time.');
      return;
    }

    final proposedSlot = {
      'dayOfWeek': _selectedDay,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'slotDurationMinutes': _configuredSlotDurationMinutes,
      'timezone': _configuredBookingTimezone,
      'isActive': true,
    };

    final alreadyExists = _slots.any((slot) =>
        _buildNormalizedSlotKey(slot) == _buildNormalizedSlotKey(proposedSlot));

    if (alreadyExists) {
      Utils.showToast(context, 'Same day and time slot already exists.');
      return;
    }

    setState(() {
      _slots.add(proposedSlot);

      _slots.sort((a, b) {
        final dayCompare =
            (a['dayOfWeek'] as int).compareTo((b['dayOfWeek'] as int));
        if (dayCompare != 0) {
          return dayCompare;
        }
        return (a['startMinutes'] as int).compareTo((b['startMinutes'] as int));
      });
    });
  }

  Future<void> _saveAvailability() async {
    if (!_isAudioServiceEnabled && !_isVideoServiceEnabled) {
      Utils.showToast(
        context,
        'Enable Audio or Video from home screen before saving availability.',
      );
      return;
    }

    if (_slots.isEmpty) {
      Utils.showToast(context, 'Add at least one slot before saving.');
      return;
    }

    final payloadSlots = <Map<String, dynamic>>[];

    for (final slot in _slots) {
      if (_isAudioServiceEnabled) {
        payloadSlots.add({
          ...slot,
          'sessionType': 'one_to_one',
          'callType': 'audio',
        });
      }

      if (_isVideoServiceEnabled) {
        payloadSlots.add({
          ...slot,
          'sessionType': 'one_to_one',
          'callType': 'video',
        });
      }
    }

    if (payloadSlots.isEmpty) {
      Utils.showToast(context, 'No valid service type available for slots.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final response = await SessionBookingService.setExpertAvailability(
      listenerId: _listenerId.isEmpty ? null : _listenerId,
      slots: payloadSlots,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    Utils.showToast(
        context, (response['message'] ?? 'Availability updated.').toString());

    if (response['status'] == true) {
      _loadAvailability();
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await _showStyledTimePicker(initialTime: _selectedStart);
    if (picked == null) {
      return;
    }

    setState(() {
      _selectedStart = picked;
    });
  }

  Future<void> _pickEndTime() async {
    final picked = await _showStyledTimePicker(initialTime: _selectedEnd);
    if (picked == null) {
      return;
    }

    setState(() {
      _selectedEnd = picked;
    });
  }

  Future<TimeOfDay?> _showStyledTimePicker({
    required TimeOfDay initialTime,
  }) {
    final baseTheme = Theme.of(context);

    return showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: baseTheme.copyWith(
            colorScheme: baseTheme.colorScheme.copyWith(
              primary: AppColors.redesignBrandRed,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.redesignBrandDark,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.white,
              dialBackgroundColor: AppColors.redesignSurfaceNeutralAlt,
              dialHandColor: AppColors.redesignBrandRed,
              dayPeriodColor: AppColors.redesignSurfaceNeutralAlt,
              dayPeriodTextColor: AppColors.redesignBrandDark,
              dayPeriodBorderSide:
                  BorderSide(color: AppColors.redesignSoftBorder),
              hourMinuteColor: AppColors.redesignSurfaceNeutralAlt,
              hourMinuteTextColor: AppColors.redesignBrandDark,
              entryModeIconColor: AppColors.redesignBrandDark,
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: AppColors.redesignBrandRed,
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: AppColors.redesignMutedText,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> _openDayPickerSheet() async {
    final selectedDay = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).padding.bottom + 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 54,
                    decoration: BoxDecoration(
                      color: AppColors.redesignSoftBorder,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Select Day',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 16,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(7, (index) {
                  final isSelected = index == _selectedDay;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: AppColors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(index),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.redesignAccentSoftBg
                                : AppColors.redesignSurfaceNeutralAlt,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.redesignBrandRed
                                      .withValues(alpha: 0.32)
                                  : AppColors.redesignSoftBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _dayLabel(index),
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 15,
                                    fontColor: isSelected
                                        ? AppColors.redesignBrandDark
                                        : AppColors.redesignTextMeta,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: AppColors.redesignBrandRed,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selectedDay == null) {
      return;
    }

    setState(() {
      _selectedDay = selectedDay;
    });
  }

  Widget _buildTopComposerCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            width: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [
                  AppColors.redesignBrandRed,
                  AppColors.redesignAccentGradientEnd,
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Create Slot',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 16,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.redesignSurfaceNeutralAlt,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.redesignSoftBorder),
                ),
                child: Text(
                  _dayLabel(_selectedDay),
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 10,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: _openDayPickerSheet,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.redesignSurfaceNeutralAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.redesignSoftBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 15,
                      color: AppColors.redesignMutedText,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Day: ${_dayLabel(_selectedDay)}',
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 13,
                          fontColor: AppColors.redesignBrandDark,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.redesignMutedText,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Service Type: ${_serviceTypeLabel()}',
            style: AppFontStyle.fontStyleW500(
              fontSize: 11,
              fontColor: AppColors.redesignMutedText,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Slot duration: $_configuredSlotDurationMinutes min  |  Timezone: $_configuredBookingTimezone',
            style: AppFontStyle.fontStyleW500(
              fontSize: 11,
              fontColor: AppColors.redesignMutedText,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickStartTime,
                  icon: Icon(
                    Icons.schedule_rounded,
                    size: 15,
                    color: AppColors.redesignMutedText,
                  ),
                  label: Text(
                    _selectedStart.format(context),
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 13,
                      fontColor: AppColors.redesignTextMeta,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.redesignSoftBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppColors.redesignSurfaceNeutralAlt,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickEndTime,
                  icon: Icon(
                    Icons.schedule_rounded,
                    size: 15,
                    color: AppColors.redesignMutedText,
                  ),
                  label: Text(
                    _selectedEnd.format(context),
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 13,
                      fontColor: AppColors.redesignTextMeta,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.redesignSoftBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppColors.redesignSurfaceNeutralAlt,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: _addSlot,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
              label: Text(
                'Add Slot',
                style: AppFontStyle.fontStyleW700(
                  fontSize: 13,
                  fontColor: AppColors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.redesignBrandRed,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 28,
                color: AppColors.redesignMutedText,
              ),
              const SizedBox(height: 8),
              Text(
                'No availability slots yet.',
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW600(
                  fontSize: 13,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Create your first slot using the section above.',
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 11,
                  fontColor: AppColors.redesignMutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotItem(Map<String, dynamic> slot, int index) {
    final day = _dayLabel(slot['dayOfWeek'] as int);
    final start = _minutesToTime(slot['startMinutes'] as int);
    final end = _minutesToTime(slot['endMinutes'] as int);
    final duration = int.tryParse(
            (slot['slotDurationMinutes'] ?? _configuredSlotDurationMinutes)
                .toString()) ??
        _configuredSlotDurationMinutes;
    final timezone =
        (slot['timezone'] ?? _configuredBookingTimezone).toString().trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.redesignAccentSoftBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color: AppColors.redesignBrandRed.withValues(alpha: 0.2)),
            ),
            child: Text(
              day,
              style: AppFontStyle.fontStyleW700(
                fontSize: 10,
                fontColor: AppColors.redesignBrandRed,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$start - $end',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 14,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$duration min  |  $timezone',
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 11,
                    fontColor: AppColors.redesignMutedText,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _slots.removeAt(index);
                });
              },
              borderRadius: BorderRadius.circular(9),
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: AppColors.redesignSurfaceNeutralAlt,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: AppColors.redesignSoftBorder),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 17,
                  color: AppColors.redesignBrandDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsSection() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.redesignBrandRed,
          strokeWidth: 2.4,
        ),
      );
    }

    if (_slots.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Scheduled Slots',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 16,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.redesignSurfaceNeutralAlt,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.redesignSoftBorder),
                ),
                child: Text(
                  '${_slots.length} slots',
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 10,
                    fontColor: AppColors.redesignMutedText,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            itemCount: _slots.length,
            itemBuilder: (context, index) =>
                _buildSlotItem(_slots[index], index),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: AppColors.redesignScreenBackground,
          child: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth >= 760;
                final maxContentWidth =
                    constraints.maxWidth >= 760 ? 980.0 : constraints.maxWidth;

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                      child: Row(
                        children: [
                          Material(
                            color: AppColors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.redesignSoftBorder,
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 20,
                                  color: AppColors.redesignBrandDark,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Manage Availability',
                              textAlign: TextAlign.center,
                              style: AppFontStyle.fontStyleW700(
                                fontSize: isTablet ? 24 : 18,
                                fontColor: AppColors.redesignBrandDark,
                              ),
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.redesignSoftBorder,
                              ),
                            ),
                            child: Icon(
                              Icons.calendar_month_outlined,
                              size: 18,
                              color: AppColors.redesignBrandDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxContentWidth =
                constraints.maxWidth >= 760 ? 980.0 : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  children: [
                    _buildTopComposerCard(),
                    Expanded(child: _buildSlotsSection()),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.redesignSoftBorder)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width >= 760
                  ? 980.0
                  : MediaQuery.sizeOf(context).width,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAvailability,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.redesignBrandRed,
                    disabledBackgroundColor: AppColors.redesignSurfaceNeutralAlt
                        .withValues(alpha: 0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          'Save Availability',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 14,
                            fontColor: AppColors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
