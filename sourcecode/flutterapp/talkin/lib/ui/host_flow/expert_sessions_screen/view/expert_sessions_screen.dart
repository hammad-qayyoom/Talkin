import 'package:notisboard/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/services/permission_handler/permission_handler.dart';
import 'package:notisboard/socket/socket_emit.dart';
import 'package:notisboard/ui/common/session_booking/session_booking_service.dart';
import 'package:notisboard/ui/common/recording_subscription/view/my_recordings_screen.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class ExpertSessionsScreen extends StatefulWidget {
  const ExpertSessionsScreen({super.key});

  @override
  State<ExpertSessionsScreen> createState() => _ExpertSessionsScreenState();
}

class _ExpertSessionsScreenState extends State<ExpertSessionsScreen> {
  String _view = 'upcoming';
  bool _isLoading = false;
  List<dynamic> _sessions = [];
  String? _cancellingSessionId;

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandRedDark = AppColors.redesignBrandRedDark;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _screenBackground = AppColors.redesignScreenBackground;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _chipSurface = AppColors.redesignSurfaceSoft;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
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

  String _readFirstNonEmptyString(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    String normalizeValue(dynamic raw) {
      if (raw == null) {
        return '';
      }

      if (raw is String) {
        return raw.trim();
      }

      if (raw is num || raw is bool) {
        return raw.toString().trim();
      }

      if (raw is Map<String, dynamic>) {
        for (final nestedKey in const <String>[
          '_id',
          'id',
          'userId',
          'listenerId',
          'legacyListenerId',
        ]) {
          final nestedValue = normalizeValue(raw[nestedKey]);
          if (nestedValue.isNotEmpty) {
            return nestedValue;
          }
        }
      }

      return '';
    }

    for (final key in keys) {
      final value = normalizeValue(source[key]);
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  Future<void> _fetchSessions() async {
    setState(() {
      _isLoading = true;
    });

    final response = await SessionBookingService.getExpertSessions(
      listenerId: _listenerId.isEmpty ? null : _listenerId,
      view: _view,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _sessions = response['data'] as List<dynamic>? ?? [];
    });

    if (response['status'] != true) {
      Utils.showToast(context,
          (response['message'] ?? 'Failed to fetch sessions.').toString());
    }
  }

  String _formatDateTime(String value) {
    final parsed = DateTime.tryParse(value)?.toLocal();
    if (parsed == null) {
      return '-';
    }

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final year = parsed.year.toString();
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  String _toTitleCase(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return 'Unknown';
    }

    return normalized
        .split(RegExp(r'[_\s]+'))
        .where((word) => word.isNotEmpty)
        .map((word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  Color _statusBackground(String status) {
    switch (status.trim().toLowerCase()) {
      case 'completed':
        return AppColors.redesignStatusSuccessBg;
      case 'cancelled':
      case 'canceled':
        return AppColors.redesignStatusDangerBg;
      case 'live':
      case 'in-progress':
        return AppColors.redesignStatusInfoBg;
      case 'scheduled':
      default:
        return AppColors.redesignAccentSoftBg;
    }
  }

  Color _statusTextColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'completed':
        return AppColors.redesignStatusSuccessDark;
      case 'cancelled':
      case 'canceled':
        return _brandRed;
      case 'live':
      case 'in-progress':
        return AppColors.redesignStatusInfoText;
      case 'scheduled':
      default:
        return _brandRedDark;
    }
  }

  Future<void> _triggerDirectSessionCall({
    required String callType,
    required String receiverId,
    required String receiverName,
    required String receiverImage,
    required String sessionId,
    required String bookingId,
  }) async {
    final normalizedCallType = callType.trim().toLowerCase();
    if (normalizedCallType != 'audio' && normalizedCallType != 'video') {
      Utils.showToast(context, 'Unsupported call type for this session.');
      return;
    }

    final callerId = _listenerId.trim();
    final sanitizedReceiverId = receiverId.trim();

    if (callerId.isEmpty || sanitizedReceiverId.isEmpty) {
      Utils.showToast(
        context,
        'Unable to start session call. Missing caller/receiver details.',
      );
      return;
    }

    Future<void> emitCall() async {
      final isSent = await SocketEmit.emitCallOutgoingRinging(
        callerId: callerId,
        receiverId: sanitizedReceiverId,
        callType: normalizedCallType,
        callerRole: 'listener',
        receiverRole: 'user',
        receiverName: receiverName,
        receiverImage: receiverImage,
        callerName: (Database.fetchListenerProfileModel?.data?.name ??
                Database.fetchLoginUserProfileModel?.user?.fullName ??
                'Expert')
            .toString(),
        callerImage: (Database.fetchListenerProfileModel?.data?.image ??
                Database.fetchLoginUserProfileModel?.user?.profilePic ??
                '')
            .toString(),
        sessionId: sessionId,
        bookingId: bookingId,
      );
      if (isSent) {
        _fetchSessions();
      }
    }

    if (normalizedCallType == 'video') {
      PermissionHandler.onGetCameraPermission(
        onGranted: () {
          PermissionHandler.onGetMicrophonePermission(
            onGranted: () {
              emitCall();
            },
          );
        },
      );
      return;
    }

    PermissionHandler.onGetMicrophonePermission(
      onGranted: () {
        emitCall();
      },
    );
  }

  Widget _buildSegment(String value, String label) {
    final selected = value == _view;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_view == value) return;
          setState(() {
            _view = value;
          });
          _fetchSessions();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected ? _brandDark : AppColors.transparent,
            border: Border.all(
              color: selected ? _brandDark : AppColors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppFontStyle.fontStyleW600(
                fontSize: 13,
                fontColor: selected ? AppColors.white : _brandDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onCancelSession(Map<String, dynamic> session) async {
    final sessionId = (session['_id'] ?? '').toString();
    if (sessionId.isEmpty) {
      Utils.showToast(context, 'Unable to cancel session. Missing session id.');
      return;
    }

    setState(() {
      _cancellingSessionId = sessionId;
    });

    final response = await SessionBookingService.cancelSessionBooking(
      sessionId: sessionId,
      cancelReason: 'Canceled by expert from app.',
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _cancellingSessionId = null;
    });

    Utils.showToast(
      context,
      (response['message'] ?? 'Session cancellation updated.').toString(),
    );

    if (response['status'] == true) {
      _fetchSessions();
    }
  }

  Future<void> _onStartSession(Map<String, dynamic> session) async {
    final sessionId = (session['_id'] ?? '').toString();
    if (sessionId.isEmpty) {
      Utils.showToast(context, 'Unable to start session. Missing session id.');
      return;
    }

    final bookings = session['bookings'] is List<dynamic>
        ? session['bookings'] as List<dynamic>
        : const <dynamic>[];

    final firstBooking =
        bookings.isNotEmpty && bookings.first is Map<String, dynamic>
            ? bookings.first as Map<String, dynamic>
            : <String, dynamic>{};

    final bookingId =
        (firstBooking['bookingId'] ?? firstBooking['_id'] ?? '').toString();
    final bookingUser = firstBooking['user'] is Map<String, dynamic>
        ? firstBooking['user'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final userId = _readFirstNonEmptyString(
      firstBooking,
      const <String>['userId', 'receiverId', 'memberId', '_id', 'id'],
    );
    final fallbackUserId = _readFirstNonEmptyString(
      bookingUser,
      const <String>['_id', 'id', 'userId'],
    );
    final resolvedUserId = userId.isNotEmpty ? userId : fallbackUserId;
    final userName = (firstBooking['userName'] ??
            firstBooking['name'] ??
            bookingUser['displayName'] ??
            bookingUser['fullName'] ??
            bookingUser['name'] ??
            '')
        .toString()
        .trim();
    final userProfilePic = (firstBooking['userProfilePic'] ??
            firstBooking['profilePic'] ??
            bookingUser['profilePic'] ??
            bookingUser['image'] ??
            bookingUser['imageUrl'] ??
            '')
        .toString()
        .trim();
    final sessionCallType = (session['callType'] ?? '').toString();

    if (bookingId.isEmpty || resolvedUserId.isEmpty) {
      Utils.showToast(
          context, 'No confirmed user booking found for this session.');
      return;
    }

    final accessResponse = await SessionBookingService.getSessionAccess(
      sessionId: sessionId,
      bookingId: bookingId,
    );

    if (!mounted) {
      return;
    }

    if (accessResponse['status'] != true) {
      Utils.showToast(
        context,
        (accessResponse['message'] ?? 'Session not started yet').toString(),
      );
      return;
    }

    await _triggerDirectSessionCall(
      callType: sessionCallType,
      receiverId: resolvedUserId,
      receiverName: userName.isEmpty ? 'User' : userName,
      receiverImage: userProfilePic,
      sessionId: sessionId,
      bookingId: bookingId,
    );
  }

  Widget _buildMetaChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _chipSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _softBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _mutedText),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppFontStyle.fontStyleW500(
              fontSize: 10,
              fontColor: _mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection({
    required double horizontalInset,
    required bool isTablet,
  }) {
    final heroSubtitle = _view == 'upcoming'
        ? 'Track and manage your upcoming expert bookings'
        : 'Review completed sessions and outcomes';

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalInset, 4, horizontalInset, 8),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 13 : 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_brandRed, _brandRedDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: _brandRed.withValues(alpha: 0.24),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: isTablet ? 38 : 34,
                  width: isTablet ? 38 : 34,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: _brandRed,
                    size: isTablet ? 21 : 19,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        EnumLocale.txtSessionCenter.name.tr,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: isTablet ? 14 : 13,
                          fontColor: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        heroSubtitle,
                        style: AppFontStyle.fontStyleW500(
                          fontSize: isTablet ? 11 : 10,
                          fontColor: AppColors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        EnumLocale.txtSessionCount.name.trParams({
                          'count': '${_sessions.length}',
                        }),
                        style: AppFontStyle.fontStyleW700(
                          fontSize: isTablet ? 15 : 13,
                          fontColor: AppColors.white,
                        ),
                      ),
                      Text(
                        _view == 'upcoming'
                            ? EnumLocale.txtUpcoming.name.tr
                            : EnumLocale.txtDone.name.tr,
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 8,
                          fontColor: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _softBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 460;

                final button = SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed(AppRoutes.hostGroupSessionsScreen);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _brandDark,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.groups_rounded, size: 16),
                    label: Text(
                      EnumLocale.txtOpenGroupSessions.name.tr,
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 12,
                        fontColor: AppColors.white,
                      ),
                    ),
                  ),
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: AppColors.redesignAccentSoftBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.groups_rounded,
                              size: 16,
                              color: _brandRed,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  EnumLocale.txtGroupSessionsHub.name.tr,
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 13,
                                    fontColor: _brandDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  EnumLocale.txtManageLiveRoomsAndParticipantsFromOnePlace.name.tr,
                                  style: AppFontStyle.fontStyleW500(
                                    fontSize: 10,
                                    fontColor: _mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(width: double.infinity, child: button),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: AppColors.redesignAccentSoftBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.groups_rounded,
                              size: 16,
                              color: _brandRed,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  EnumLocale.txtGroupSessionsHub.name.tr,
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 13,
                                    fontColor: _brandDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  EnumLocale.txtManageLiveRoomsAndParticipantsFromOnePlace.name.tr,
                                  style: AppFontStyle.fontStyleW500(
                                    fontSize: 10,
                                    fontColor: _mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(width: 194, child: button),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _softBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SizedBox(
              height: 42,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyRecordingsScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _softBorder),
                  foregroundColor: _brandDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.cloud_rounded, size: 16),
                label: Text(
                  "My Recordings",
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 12,
                    fontColor: _brandDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard({
    required Map<String, dynamic> session,
    required double cardWidth,
  }) {
    final bookings = session['bookings'] is List<dynamic>
        ? session['bookings'] as List<dynamic>
        : const <dynamic>[];
    final firstBooking =
        bookings.isNotEmpty && bookings.first is Map<String, dynamic>
            ? bookings.first as Map<String, dynamic>
            : <String, dynamic>{};

    final bookedUser = (firstBooking['userName'] ?? '-').toString();
    final bookingStatus = (firstBooking['bookingStatus'] ?? '-').toString();
    final bookingStatusLower = bookingStatus.toLowerCase();
    final bookingStatusLabel = _toTitleCase(bookingStatus);

    final sessionId = (session['_id'] ?? '').toString();
    final rawSessionStatus =
        (session['sessionStatus'] ?? session['status'] ?? '').toString();
    final sessionStatusLower = rawSessionStatus.toLowerCase();
    final sessionStatusLabel = _toTitleCase(rawSessionStatus);

    final canCancel = _view == 'upcoming' && sessionStatusLower != 'canceled';
    final canStartSession = _view == 'upcoming' &&
        bookingStatusLower == 'confirmed' &&
        !['completed', 'canceled', 'cancelled'].contains(sessionStatusLower);
    final showStartControl = _view == 'upcoming';
    final isCancellingThis = _cancellingSessionId == sessionId;
    final callTypeRaw = (session['callType'] ?? '').toString().trim();
    final callTypeLabel =
        callTypeRaw.isEmpty ? 'Unknown' : callTypeRaw.toUpperCase();
    final startAt = _formatDateTime((session['startAt'] ?? '').toString());
    final isNarrowActionLayout = cardWidth < 430;

    final startLabel = bookingStatusLower != 'confirmed'
        ? 'Awaiting Confirmation'
        : 'Start Session';

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _softBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  (session['title'] ?? 'Session').toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 13,
                    fontColor: _brandDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBackground(rawSessionStatus),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  sessionStatusLabel,
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 9,
                    fontColor: _statusTextColor(rawSessionStatus),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            bookedUser,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFontStyle.fontStyleW600(
              fontSize: 12,
              fontColor: _brandDark,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildMetaChip(
                icon: Icons.schedule_rounded,
                text: startAt,
              ),
              _buildMetaChip(
                icon: callTypeRaw.toLowerCase() == 'video'
                    ? Icons.videocam_outlined
                    : Icons.call_outlined,
                text: callTypeLabel,
              ),
              _buildMetaChip(
                icon: Icons.verified_user_outlined,
                text: bookingStatusLabel,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            EnumLocale.txtConfirmedBookingsCount.name.trParams({
              'count': (session['confirmedBookings'] ?? 0).toString(),
            }),
            style: AppFontStyle.fontStyleW500(
              fontSize: 10,
              fontColor: _mutedText,
            ),
          ),
          if (showStartControl || canCancel) ...[
            const SizedBox(height: 10),
            if (isNarrowActionLayout)
              Column(
                children: [
                  if (showStartControl)
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: canStartSession
                            ? () => _onStartSession(session)
                            : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          disabledBackgroundColor: AppColors.redesignSoftBorder,
                          disabledForegroundColor: _mutedText,
                          backgroundColor: _brandDark,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          canStartSession
                              ? Icons.play_circle_outline_rounded
                              : Icons.schedule_rounded,
                          size: 16,
                        ),
                        label: Text(
                          startLabel,
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 12,
                            fontColor:
                                canStartSession ? AppColors.white : _mutedText,
                          ),
                        ),
                      ),
                    ),
                  if (showStartControl && canCancel) const SizedBox(height: 6),
                  if (canCancel)
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: OutlinedButton.icon(
                        onPressed: isCancellingThis
                            ? null
                            : () => _onCancelSession(session),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _brandRed.withValues(alpha: 0.45),
                          ),
                          foregroundColor: _brandRedDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: isCancellingThis
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.close_rounded, size: 16),
                        label: Text(
                          isCancellingThis ? 'Cancelling' : 'Cancel Slot',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 12,
                            fontColor: _brandRedDark,
                          ),
                        ),
                      ),
                    ),
                ],
              )
            else
              Row(
                children: [
                  if (showStartControl)
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: canStartSession
                              ? () => _onStartSession(session)
                              : null,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            disabledBackgroundColor:
                                AppColors.redesignSoftBorder,
                            disabledForegroundColor: _mutedText,
                            backgroundColor: _brandDark,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            canStartSession
                                ? Icons.play_circle_outline_rounded
                                : Icons.schedule_rounded,
                            size: 16,
                          ),
                          label: Text(
                            startLabel,
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 12,
                              fontColor: canStartSession
                                  ? AppColors.white
                                  : _mutedText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (showStartControl && canCancel) const SizedBox(width: 6),
                  if (canCancel)
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: isCancellingThis
                              ? null
                              : () => _onCancelSession(session),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _brandRed.withValues(alpha: 0.45),
                            ),
                            foregroundColor: _brandRedDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: isCancellingThis
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.close_rounded, size: 16),
                          label: Text(
                            isCancellingThis ? 'Cancelling' : 'Cancel Slot',
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 12,
                              fontColor: _brandRedDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionsList({required double horizontalInset}) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: _brandRed),
      );
    }

    if (_sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _softBorder),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 32,
                  color: _brandRed,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                EnumLocale.txtNoSessionsFound.name.tr,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 14,
                  fontColor: _brandDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _view == 'upcoming'
                    ? 'Your upcoming expert sessions will appear here.'
                    : 'Completed sessions will appear here.',
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 11,
                  fontColor: _mutedText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: _brandRed,
      backgroundColor: AppColors.white,
      onRefresh: _fetchSessions,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 760;
          final columns = constraints.maxWidth >= 1200
              ? 3
              : isTablet
                  ? 2
                  : 1;
          const spacing = 12.0;
          final cardWidth = columns == 1
              ? constraints.maxWidth
              : ((constraints.maxWidth - (spacing * (columns - 1))) / columns)
                  .toDouble();

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding:
                EdgeInsets.fromLTRB(horizontalInset, 4, horizontalInset, 18),
            children: [
              if (columns == 1)
                ..._sessions.map((rawSession) {
                  final session = rawSession is Map<String, dynamic>
                      ? rawSession
                      : <String, dynamic>{};

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildSessionCard(
                      session: session,
                      cardWidth: cardWidth,
                    ),
                  );
                })
              else
                Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: _sessions.map((rawSession) {
                    final session = rawSession is Map<String, dynamic>
                        ? rawSession
                        : <String, dynamic>{};

                    return SizedBox(
                      width: cardWidth,
                      child: _buildSessionCard(
                        session: session,
                        cardWidth: cardWidth,
                      ),
                    );
                  }).toList(),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: _screenBackground,
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
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          EnumLocale.txtMySessions.name.tr,
                          style: AppFontStyle.fontStyleW700(
                            fontSize: isTablet ? 22 : 16,
                            fontColor: _brandDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, viewportConstraints) {
          final maxContentWidth = viewportConstraints.maxWidth >= 760
              ? 980.0
              : viewportConstraints.maxWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: LayoutBuilder(
                builder: (context, contentConstraints) {
                  final width = contentConstraints.maxWidth;
                  final isTablet = width >= 760;
                  final horizontalInset = isTablet ? 16.0 : 12.0;

                  return SafeArea(
                    child: Column(
                      children: [
                        _buildHeaderSection(
                          horizontalInset: horizontalInset,
                          isTablet: isTablet,
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalInset,
                            0,
                            horizontalInset,
                            8,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.redesignPanelBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _softBorder),
                            ),
                            child: Row(
                              children: [
                                _buildSegment('upcoming', 'Upcoming'),
                                const SizedBox(width: 6),
                                _buildSegment('completed', 'Completed'),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildSessionsList(
                            horizontalInset: horizontalInset,
                          ),
                        ),
                      ],
                    ),
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
