import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/common/session_booking/session_booking_service.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class UserBookSessionScreen extends StatefulWidget {
  const UserBookSessionScreen({super.key});

  @override
  State<UserBookSessionScreen> createState() => _UserBookSessionScreenState();
}

class _UserBookSessionScreenState extends State<UserBookSessionScreen> {
  final List<DateTime> _dates = List.generate(
    7,
    (index) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day).add(Duration(days: index));
    },
  );

  bool _isLoading = false;
  bool _isBooking = false;
  String _callType = 'audio';
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _slots = [];
  Map<String, dynamic>? _selectedSlot;
  String _bookingTimezone = 'UTC';
  int _configuredSlotDurationMinutes = 30;

  String _listenerId = '';
  String _expertId = '';
  String _listenerName = '';
  String _listenerImage = '';
  bool _isAudioServiceEnabled = true;
  bool _isVideoServiceEnabled = true;

  bool _parseBoolFlag(dynamic value, bool fallback) {
    if (value == null) {
      return fallback;
    }

    if (value is bool) {
      return value;
    }

    final normalized = value.toString().trim().toLowerCase();
    if (['true', '1', 'yes'].contains(normalized)) {
      return true;
    }
    if (['false', '0', 'no'].contains(normalized)) {
      return false;
    }

    return fallback;
  }

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      _listenerId = (arguments['listenerId'] ?? '').toString().trim();
      _expertId = (arguments['expertId'] ?? '').toString().trim();

      if (_expertId.isEmpty && _listenerId.isNotEmpty) {
        _expertId = _listenerId;
      }

      if (_listenerId.isEmpty && _expertId.isNotEmpty) {
        _listenerId = _expertId;
      }

      _listenerName = (arguments['listenerName'] ?? '').toString();
      _listenerImage = (arguments['listenerImage'] ?? '').toString();

      final hasAudioFlag =
          arguments.containsKey('availableForPrivateAudioCall');
      final hasVideoFlag =
          arguments.containsKey('availableForPrivateVideoCall');

      if (hasAudioFlag) {
        _isAudioServiceEnabled =
            _parseBoolFlag(arguments['availableForPrivateAudioCall'], false);
      }

      if (hasVideoFlag) {
        _isVideoServiceEnabled =
            _parseBoolFlag(arguments['availableForPrivateVideoCall'], false);
      }

      if (!_isAudioServiceEnabled && _isVideoServiceEnabled) {
        _callType = 'video';
      }

      if (!hasAudioFlag && !hasVideoFlag) {
        _isAudioServiceEnabled = true;
        _isVideoServiceEnabled = true;
      }
    }

    _selectedDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    _fetchSlots();
  }

  Future<void> _fetchSlots() async {
    if (_listenerId.isEmpty && _expertId.isEmpty) {
      return;
    }

    final selectedTypeEnabled =
        (_callType == 'audio' && _isAudioServiceEnabled) ||
            (_callType == 'video' && _isVideoServiceEnabled);

    if (!selectedTypeEnabled) {
      setState(() {
        _slots = [];
        _selectedSlot = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _selectedSlot = null;
    });

    final response = await SessionBookingService.getAvailableSlots(
      listenerId: _listenerId.isEmpty ? null : _listenerId,
      expertId: _expertId.isEmpty ? null : _expertId,
      date: _selectedDate,
      callType: _callType,
      clientTimezoneOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
      includeBooked: true,
    );

    final data = response['data'];
    final fetchedSlots = data is Map<String, dynamic>
        ? (data['slots'] as List<dynamic>? ?? [])
        : <dynamic>[];
    final bookingTimezone = data is Map<String, dynamic>
        ? (data['bookingTimezone'] ?? 'UTC').toString().trim()
        : 'UTC';
    final configuredSlotDurationMinutes = int.tryParse(
            (data is Map<String, dynamic>
                    ? (data['slotDurationMinutes'] ?? 30)
                    : 30)
                .toString()) ??
        30;

    setState(() {
      _slots = fetchedSlots;
      _bookingTimezone = bookingTimezone.isEmpty ? 'UTC' : bookingTimezone;
      _configuredSlotDurationMinutes = configuredSlotDurationMinutes < 10
          ? 30
          : configuredSlotDurationMinutes;
      _isLoading = false;
    });

    if (response['status'] != true && mounted) {
      Utils.showToast(context,
          (response['message'] ?? 'Unable to fetch slots.').toString());
    }
  }

  Future<void> _bookSelectedSlot() async {
    final selectedTypeEnabled =
        (_callType == 'audio' && _isAudioServiceEnabled) ||
            (_callType == 'video' && _isVideoServiceEnabled);

    if (!selectedTypeEnabled) {
      Utils.showToast(context, 'Selected session type is not available.');
      return;
    }

    if (_selectedSlot == null) {
      Utils.showToast(context, 'Please select a time slot.');
      return;
    }

    if (_isSlotBooked(_selectedSlot!)) {
      Utils.showToast(context,
          'This slot is already booked. Please select an available slot.');
      return;
    }

    final userId =
        (Database.fetchLoginUserProfileModel?.user?.id ?? '').toString();
    if (userId.isEmpty) {
      Utils.showToast(
          context, 'Unable to identify user session. Please login again.');
      return;
    }

    final startAtRaw = (_selectedSlot?['startAt'] ?? '').toString();
    final slotDurationMinutes = int.tryParse(
            (_selectedSlot?['slotDurationMinutes'] ??
                    _configuredSlotDurationMinutes)
                .toString()) ??
        _configuredSlotDurationMinutes;
    final parsedStartAt = DateTime.tryParse(startAtRaw);

    if (parsedStartAt == null) {
      Utils.showToast(context, 'Invalid slot selected.');
      return;
    }

    setState(() {
      _isBooking = true;
    });

    final response = await SessionBookingService.bookSession(
      userId: userId,
      listenerId: _listenerId.isEmpty ? null : _listenerId,
      expertId: _expertId.isEmpty ? null : _expertId,
      callType: _callType,
      slotStartAt: parsedStartAt,
      slotDurationMinutes: slotDurationMinutes,
      bookingTimezone: _bookingTimezone,
      clientTimezoneOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isBooking = false;
    });

    Utils.showToast(context,
        (response['message'] ?? 'Session booking updated.').toString());

    if (response['status'] == true) {
      Get.offNamed(AppRoutes.userMySessionsScreen);
    }
  }

  String _formatDay(DateTime value) {
    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final safeIndex = (value.weekday - 1).clamp(0, 6);
    return '${weekDays[safeIndex]} ${value.day}/${value.month}';
  }

  String _formatSlotLabel(Map<String, dynamic> slot) {
    final startAt =
        DateTime.tryParse((slot['startAt'] ?? '').toString())?.toLocal();
    final endAt =
        DateTime.tryParse((slot['endAt'] ?? '').toString())?.toLocal();

    if (startAt == null || endAt == null) {
      return 'Invalid slot';
    }

    final startHour = startAt.hour.toString().padLeft(2, '0');
    final startMin = startAt.minute.toString().padLeft(2, '0');
    final endHour = endAt.hour.toString().padLeft(2, '0');
    final endMin = endAt.minute.toString().padLeft(2, '0');

    return '$startHour:$startMin - $endHour:$endMin';
  }

  bool _isSlotBooked(Map<String, dynamic> slot) {
    final rawBooked = slot['isBooked'];
    if (rawBooked is bool) {
      return rawBooked;
    }

    final status = (slot['status'] ?? '').toString().trim().toLowerCase();
    return status == 'booked';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Book Session',
          style: AppFontStyle.fontStyleW700(
              fontSize: 18, fontColor: AppColors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.profileOptionColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _listenerName.isEmpty ? 'Expert' : _listenerName,
                    style: AppFontStyle.fontStyleW700(
                        fontSize: 15, fontColor: AppColors.black),
                  ),
                  if (_listenerImage.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _listenerImage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFontStyle.fontStyleW500(
                          fontSize: 11, fontColor: AppColors.grey),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  if (_isAudioServiceEnabled)
                    ChoiceChip(
                      label: const Text('Audio'),
                      selected: _callType == 'audio',
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(() {
                          _callType = 'audio';
                        });
                        _fetchSlots();
                      },
                    ),
                  if (_isAudioServiceEnabled && _isVideoServiceEnabled)
                    const SizedBox(width: 8),
                  if (_isVideoServiceEnabled)
                    ChoiceChip(
                      label: const Text('Video'),
                      selected: _callType == 'video',
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(() {
                          _callType = 'video';
                        });
                        _fetchSlots();
                      },
                    ),
                ],
              ),
            ),
            if (!_isAudioServiceEnabled && !_isVideoServiceEnabled)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Expert is currently unavailable for Audio/Video sessions.',
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.grey,
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: 56,
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: _dates.length,
                itemBuilder: (context, index) {
                  final date = _dates[index];
                  final isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                      _fetchSlots();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isSelected
                            ? AppColors.appColor
                            : AppColors.profileOptionColor,
                      ),
                      child: Center(
                        child: Text(
                          _formatDay(date),
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 12,
                            fontColor:
                                isSelected ? AppColors.white : AppColors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Times are shown in your local timezone. Booking policy timezone: $_bookingTimezone.',
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 11,
                    fontColor: AppColors.grey,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _slots.isEmpty
                      ? Center(
                          child: Text(
                            'No slots available for selected date.',
                            style: AppFontStyle.fontStyleW500(
                                fontSize: 13, fontColor: AppColors.grey),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _slots.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.6,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            final slot = (_slots[index] is Map<String, dynamic>)
                                ? _slots[index] as Map<String, dynamic>
                                : <String, dynamic>{};
                            final isBooked = _isSlotBooked(slot);
                            final isSelected = _selectedSlot == slot;
                            final slotStatusLabel =
                                isBooked ? 'Booked' : 'Available';

                            return GestureDetector(
                              onTap: isBooked
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedSlot = slot;
                                      });
                                    },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isBooked
                                        ? AppColors.red.withValues(alpha: 0.6)
                                        : isSelected
                                            ? AppColors.green
                                            : AppColors.green
                                                .withValues(alpha: 0.45),
                                  ),
                                  color: isBooked
                                      ? AppColors.lightRed
                                      : isSelected
                                          ? AppColors.green
                                              .withValues(alpha: 0.16)
                                          : AppColors.green
                                              .withValues(alpha: 0.08),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _formatSlotLabel(slot),
                                        style: AppFontStyle.fontStyleW600(
                                          fontSize: 12,
                                          fontColor: isBooked
                                              ? AppColors.red
                                              : AppColors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        slotStatusLabel,
                                        style: AppFontStyle.fontStyleW600(
                                          fontSize: 10,
                                          fontColor: isBooked
                                              ? AppColors.red
                                              : AppColors.green,
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isBooking ? null : _bookSelectedSlot,
                  child: _isBooking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm Booking'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
