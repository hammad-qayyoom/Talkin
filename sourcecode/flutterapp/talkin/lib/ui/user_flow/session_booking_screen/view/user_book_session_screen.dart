import 'package:notisboard/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/custom/verified_badge/verified_badge.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/services/app_review/app_review_service.dart';
import 'package:notisboard/ui/common/session_booking/session_booking_service.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/auth_guard.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

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
  bool _isVerifiedExpert = false;
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
    if (AuthGuard.isGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        AuthGuard.showLoginPrompt(
          message: 'Please log in to book sessions with experts.',
        );
      });
      return;
    }

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
      _listenerImage = (arguments['listenerImage'] ??
              arguments['expertImage'] ??
              arguments['image'] ??
              arguments['profilePic'] ??
              '')
          .toString()
          .trim();
      _isVerifiedExpert = _parseBoolFlag(arguments['isVerifiedBadge'], false);

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
    if (!AuthGuard.requireLogin(
      message: 'Please log in to book sessions with experts.',
    )) {
      return;
    }

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
      await AppReviewService.trackPositiveAction(source: 'session_booking');
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

  bool _isDateSelected(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  bool get _canConfirmBooking {
    if (_isBooking || _selectedSlot == null) {
      return false;
    }

    return !_isSlotBooked(_selectedSlot!);
  }

  double _maxContentWidthFor(double width) {
    return width >= 760 ? 980.0 : width;
  }

  double _horizontalInsetFor(double width) {
    return width >= 760 ? 22.0 : 16.0;
  }

  int _slotCrossAxisCountFor({required bool isTablet}) {
    return isTablet ? 4 : 2;
  }

  double _slotAspectRatioFor({
    required double availableWidth,
    required bool isTablet,
  }) {
    if (isTablet) return 2.0;
    return availableWidth >= 400 ? 2.2 : 2.0;
  }

  SliverGridDelegate _buildSlotsGridDelegate({
    required double availableWidth,
    required bool isTablet,
  }) {
    final crossAxisCount = _slotCrossAxisCountFor(isTablet: isTablet);
    final childAspectRatio = _slotAspectRatioFor(
      availableWidth: availableWidth,
      isTablet: isTablet,
    );

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    );
  }

  Widget _buildHeader({
    required double horizontalInset,
    required bool isTablet,
  }) {
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
        child: Padding(
          padding: EdgeInsets.fromLTRB(horizontalInset, 8, horizontalInset, 12),
          child: Row(
            children: [
              _HeaderIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: Get.back,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EnumLocale.txtBookSession.name.tr,
                      style: AppFontStyle.fontStyleW700(
                        fontSize: isTablet ? 22 : 20,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      EnumLocale.txtPickATimeThatWorksForYou.name.tr,
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 11,
                        fontColor: AppColors.redesignMutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpertCard({required double horizontalInset}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(horizontalInset, 12, horizontalInset, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: AppColors.redesignAccentSoftBg,
              borderRadius: BorderRadius.circular(11),
            ),
            clipBehavior: Clip.hardEdge,
            child: _listenerImage.isNotEmpty
                ? CustomListenerProfileImage(
                    image: _listenerImage,
                    fit: BoxFit.cover,
                  )
                : Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                    color: AppColors.redesignBrandRed,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _listenerName.trim().isEmpty ? 'Expert' : _listenerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 18,
                          fontColor: AppColors.redesignBrandDark,
                        ),
                      ),
                    ),
                    VerifiedBadge(
                      isVerified: _isVerifiedExpert,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  (_isAudioServiceEnabled || _isVideoServiceEnabled)
                      ? 'Available for private booking'
                      : 'Private booking unavailable right now',
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 11,
                    fontColor: AppColors.redesignMutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallTypeChip({
    required String value,
    required String label,
  }) {
    final bool isSelected = _callType == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isSelected) {
              return;
            }

            setState(() {
              _callType = value;
            });
            _fetchSlots();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minWidth: 90),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.redesignBrandDark : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.redesignBrandDark
                    : AppColors.redesignSoftBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(
                    alpha: isSelected ? 0.10 : 0.03,
                  ),
                  blurRadius: isSelected ? 10 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  label,
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 12,
                    fontColor: isSelected
                        ? AppColors.white
                        : AppColors.redesignBrandDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(DateTime date) {
    final isSelected = _isDateSelected(date);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isSelected) {
              return;
            }

            setState(() {
              _selectedDate = date;
            });
            _fetchSlots();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected ? AppColors.redesignBrandDark : AppColors.white,
              border: Border.all(
                color: isSelected
                    ? AppColors.redesignBrandDark
                    : AppColors.redesignSoftBorder,
              ),
            ),
            child: Text(
              _formatDay(date),
              style: AppFontStyle.fontStyleW600(
                fontSize: 12,
                fontColor:
                    isSelected ? AppColors.white : AppColors.redesignBrandDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlotsLoading({
    required double horizontalInset,
    required double contentWidth,
  }) {
    final availableWidth = (contentWidth - (horizontalInset * 2))
        .clamp(0.0, double.infinity)
        .toDouble();
    final isTablet = contentWidth >= 760;

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(horizontalInset, 8, horizontalInset, 10),
      itemCount: 8,
      gridDelegate: _buildSlotsGridDelegate(
        availableWidth: availableWidth,
        isTablet: isTablet,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
        );
      },
    );
  }

  Widget _buildSlotsEmpty({required double horizontalInset}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(horizontalInset, 30, horizontalInset, 20),
      children: [
        Icon(
          Icons.event_busy_outlined,
          size: 52,
          color: AppColors.redesignSoftBorder,
        ),
        const SizedBox(height: 12),
        Text(
          EnumLocale.txtNoSlotsAvailable.name.tr,
          textAlign: TextAlign.center,
          style: AppFontStyle.fontStyleW700(
            fontSize: 20,
            fontColor: AppColors.redesignBrandDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          EnumLocale.txtPleaseChooseAnotherDateToViewAvailableTimeSlots.name.tr,
          textAlign: TextAlign.center,
          style: AppFontStyle.fontStyleW500(
            fontSize: 12,
            fontColor: AppColors.redesignMutedText,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth = _maxContentWidthFor(constraints.maxWidth);
          final horizontalInset = _horizontalInsetFor(maxContentWidth);

          return Row(
            children: [
              const Spacer(),
              SizedBox(
                width: maxContentWidth,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        horizontalInset, 8, horizontalInset, 10),
                    decoration: BoxDecoration(
                      color: AppColors.redesignScreenBackground,
                      border: Border(
                        top: BorderSide(color: AppColors.redesignSoftBorder),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _canConfirmBooking ? _bookSelectedSlot : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.redesignBrandDark,
                          disabledBackgroundColor: AppColors.redesignSoftBorder,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isBooking
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : Text(
                                EnumLocale.txtConfirmBooking.name.tr,
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: 17,
                                  fontColor: _canConfirmBooking
                                      ? AppColors.white
                                      : AppColors.redesignMutedText,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          );
        },
      ),
      body: LayoutBuilder(
        builder: (context, viewportConstraints) {
          final maxContentWidth =
              _maxContentWidthFor(viewportConstraints.maxWidth);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: LayoutBuilder(
                builder: (context, contentConstraints) {
                  final contentWidth = contentConstraints.maxWidth;
                  final isTablet = contentWidth >= 760;
                  final horizontalInset = _horizontalInsetFor(contentWidth);
                  final slotAvailableWidth =
                      (contentWidth - (horizontalInset * 2))
                          .clamp(0.0, double.infinity)
                          .toDouble();

                  return Column(
                    children: [
                      _buildHeader(
                        horizontalInset: horizontalInset,
                        isTablet: isTablet,
                      ),
                      _buildExpertCard(horizontalInset: horizontalInset),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            horizontalInset, 12, horizontalInset, 0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              if (_isAudioServiceEnabled)
                                _buildCallTypeChip(
                                    value: 'audio', label: 'Audio'),
                              if (_isVideoServiceEnabled)
                                _buildCallTypeChip(
                                    value: 'video', label: 'Video'),
                            ],
                          ),
                        ),
                      ),
                      if (!_isAudioServiceEnabled && !_isVideoServiceEnabled)
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              horizontalInset, 8, horizontalInset, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              EnumLocale.txtExpertIsCurrentlyUnavailableForAudioVideoSessions.name.tr,
                              style: AppFontStyle.fontStyleW500(
                                fontSize: 12,
                                fontColor: AppColors.redesignMutedText,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 56,
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                              horizontalInset, 8, horizontalInset, 0),
                          scrollDirection: Axis.horizontal,
                          itemCount: _dates.length,
                          itemBuilder: (context, index) =>
                              _buildDateChip(_dates[index]),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            horizontalInset, 8, horizontalInset, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Times are shown in your local timezone. Booking policy timezone: @_bookingTimezone.'.trParams({'_bookingTimezone': _bookingTimezone}),
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 11,
                              fontColor: AppColors.redesignMutedText,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _isLoading
                            ? _buildSlotsLoading(
                                horizontalInset: horizontalInset,
                                contentWidth: contentWidth,
                              )
                            : _slots.isEmpty
                                ? _buildSlotsEmpty(
                                    horizontalInset: horizontalInset)
                                : GridView.builder(
                                    padding: EdgeInsets.fromLTRB(
                                        horizontalInset,
                                        10,
                                        horizontalInset,
                                        10),
                                    itemCount: _slots.length,
                                    gridDelegate: _buildSlotsGridDelegate(
                                      availableWidth: slotAvailableWidth,
                                      isTablet: isTablet,
                                    ),
                                    itemBuilder: (context, index) {
                                      final slot = (_slots[index]
                                              is Map<String, dynamic>)
                                          ? _slots[index]
                                              as Map<String, dynamic>
                                          : <String, dynamic>{};
                                      final isBooked = _isSlotBooked(slot);
                                      final isSelected = _selectedSlot == slot;

                                      final slotStatusLabel = isBooked
                                          ? 'Booked'
                                          : isSelected
                                              ? 'Selected'
                                              : 'Available';

                                      return Material(
                                        color: AppColors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          onTap: isBooked
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _selectedSlot = slot;
                                                  });
                                                },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 150),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: isBooked
                                                    ? AppColors.red
                                                        .withValues(alpha: 0.6)
                                                    : isSelected
                                                        ? AppColors
                                                            .redesignBrandDark
                                                        : AppColors.green
                                                            .withValues(
                                                                alpha: 0.45),
                                              ),
                                              color: isBooked
                                                  ? AppColors.lightRed
                                                  : isSelected
                                                      ? AppColors
                                                          .redesignBrandDark
                                                      : AppColors.green
                                                          .withValues(
                                                              alpha: 0.08),
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    _formatSlotLabel(slot),
                                                    style: AppFontStyle
                                                        .fontStyleW700(
                                                      fontSize: 12,
                                                      fontColor: isBooked
                                                          ? AppColors.red
                                                          : isSelected
                                                              ? AppColors.white
                                                              : AppColors
                                                                  .redesignBrandDark,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    slotStatusLabel,
                                                    style: AppFontStyle
                                                        .fontStyleW600(
                                                      fontSize: 10,
                                                      fontColor: isBooked
                                                          ? AppColors.red
                                                          : isSelected
                                                              ? AppColors.white
                                                              : AppColors.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
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
