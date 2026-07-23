import 'package:notisboard/utils/enums.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:shimmer/shimmer.dart';
import 'package:notisboard/services/permission_handler/permission_handler.dart';
import 'package:notisboard/socket/socket_emit.dart';
import 'package:notisboard/ui/common/session_booking/session_booking_service.dart';
import 'package:notisboard/ui/user_flow/call_cut_screen/api/submit_call_rate_api.dart';
import 'package:notisboard/ui/common/recording_subscription/view/my_recordings_screen.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class UserMySessionsScreen extends StatefulWidget {
  const UserMySessionsScreen({super.key});

  @override
  State<UserMySessionsScreen> createState() => _UserMySessionsScreenState();
}

class _UserMySessionsScreenState extends State<UserMySessionsScreen> {
  String _view = 'upcoming';
  String _modeFilter = 'all';
  bool _isLoading = false;
  List<dynamic> _sessions = [];
  Timer? _autoRefreshTimer;
  String? _cancellingBookingId;
  final Set<String> _reviewSubmittedKeys = <String>{};
  final GetStorage _storage = GetStorage();
  static const String _storageKeyReviews = 'submitted_reviews_keys';

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
    _loadReviewsFromStorage();
    _fetchSessions();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) {
        _fetchSessions();
      }
    });
  }

  Future<void> _loadReviewsFromStorage() async {
    try {
      final List<dynamic>? storedKeys =
          _storage.read(_storageKeyReviews) as List<dynamic>?;
      if (storedKeys != null) {
        _reviewSubmittedKeys.addAll(
          storedKeys.whereType<String>(),
        );
        Utils.showLog(
            'Loaded ${_reviewSubmittedKeys.length} submitted reviews from storage');
      }
    } catch (e) {
      Utils.showLog('Error loading reviews from storage: $e');
    }
  }

  Future<void> _saveReviewsToStorage() async {
    try {
      await _storage.write(
        _storageKeyReviews,
        _reviewSubmittedKeys.toList(),
      );
      Utils.showLog('Saved ${_reviewSubmittedKeys.length} reviews to storage');
    } catch (e) {
      Utils.showLog('Error saving reviews to storage: $e');
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchSessions() async {
    final userId =
        (Database.fetchLoginUserProfileModel?.user?.id ?? '').toString();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await SessionBookingService.getUserSessions(
      userId: userId.isEmpty ? null : userId,
      view: _view,
    );

    if (!mounted) {
      return;
    }

    final fetchedSessions = (response['data'] as List<dynamic>? ?? []);
    final visibleSessions = _applyMySessionsVisibilityRules(fetchedSessions);

    setState(() {
      _isLoading = false;
      _sessions = visibleSessions;
      // _reviewSubmittedKeys is NOT cleared - it persists across refreshes
    });

    if (response['status'] != true) {
      Utils.showToast(context,
          (response['message'] ?? 'Failed to fetch sessions.').toString());
    }
  }

  List<dynamic> _applyMySessionsVisibilityRules(List<dynamic> sessions) {
    if (_view != 'upcoming') {
      return sessions;
    }

    return sessions.where((rawItem) {
      if (rawItem is! Map<String, dynamic>) {
        return false;
      }

      final session = _extractSession(rawItem);
      if (session.isEmpty) {
        return false;
      }

      if (!_isGroupSessionType(session)) {
        return true;
      }

      final status = _sessionStatus(session);
      return _isLiveStatus(status);
    }).toList();
  }

  Map<String, dynamic> _extractSession(Map<String, dynamic> item) {
    if (item['session'] is Map<String, dynamic>) {
      return item['session'] as Map<String, dynamic>;
    }

    if (item['sessionId'] is Map<String, dynamic>) {
      return item['sessionId'] as Map<String, dynamic>;
    }

    return <String, dynamic>{};
  }

  Map<String, dynamic> _extractExpert(Map<String, dynamic> session) {
    if (session['expertId'] is Map<String, dynamic>) {
      return session['expertId'] as Map<String, dynamic>;
    }

    return <String, dynamic>{};
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
          'sessionId',
          'channelName',
          'channelId',
          'roomId',
          'roomID',
          'callId',
          'zegoRoomId',
          'zegoToken',
          'roomToken',
          'token',
          'zego_room_token',
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

  String _resolveSessionId(Map<String, dynamic> session) {
    return _readFirstNonEmptyString(
      session,
      const <String>['_id', 'sessionId', 'id'],
    );
  }

  String _resolveGroupRoomId(
    Map<String, dynamic> session, {
    String? fallbackSessionId,
  }) {
    final roomId = _readFirstNonEmptyString(
      session,
      const <String>[
        'channelName',
        'channelId',
        'roomId',
        'roomID',
        'callId',
        'zegoRoomId',
      ],
    );

    if (roomId.isNotEmpty) {
      return roomId;
    }

    return (fallbackSessionId ?? '').trim();
  }

  String _resolveGroupRoomToken(Map<String, dynamic> session) {
    return _readFirstNonEmptyString(
      session,
      const <String>[
        'zegoToken',
        'roomToken',
        'token',
        'zego_room_token',
      ],
    );
  }

  String _resolveListenerSocketId({
    required Map<String, dynamic> session,
    required Map<String, dynamic> expert,
  }) {
    final fromExpert = _readFirstNonEmptyString(
      expert,
      const <String>[
        'legacyListenerId',
        'listenerId',
        '_id',
        'id',
        'userId',
      ],
    );
    if (fromExpert.isNotEmpty) {
      return fromExpert;
    }

    return _readFirstNonEmptyString(
      session,
      const <String>[
        'legacyListenerId',
        'listenerId',
        'expertListenerId',
        'expertId',
      ],
    );
  }

  String _sessionStatus(Map<String, dynamic> session) {
    return (session['sessionStatus'] ?? session['status'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
  }

  bool _isLiveStatus(String status) {
    return ['live', 'active', 'ongoing', 'started'].contains(status);
  }

  bool _isGroupSessionType(Map<String, dynamic> session) {
    final sessionType =
        (session['sessionType'] ?? '').toString().trim().toLowerCase();

    return sessionType == 'group' ||
        sessionType == 'group_audio' ||
        sessionType == 'group_video';
  }

  String? _startBlockedReason({
    required Map<String, dynamic> item,
    required Map<String, dynamic> session,
  }) {
    final sessionStatus = _sessionStatus(session);
    final bookingStatus =
        (item['bookingStatus'] ?? '').toString().trim().toLowerCase();
    final isConfirmedBooking = bookingStatus.isNotEmpty
        ? bookingStatus == 'confirmed'
        : item['canStartSession'] == true;

    if (!isConfirmedBooking) {
      return 'Your booking is awaiting confirmation.';
    }

    if (['completed', 'canceled', 'cancelled'].contains(sessionStatus)) {
      return 'Session is no longer active.';
    }

    if (_isGroupSessionType(session) && !_isLiveStatus(sessionStatus)) {
      return 'Session host has not started live stream yet.';
    }

    return null;
  }

  String _startButtonLabel({
    required bool canStart,
    required bool isGroupSession,
    required bool isConfirmedBooking,
    required String sessionStatus,
    required bool isInPerson,
  }) {
    if (isInPerson) {
      if (sessionStatus == 'requested') return 'Awaiting Expert';
      if (sessionStatus == 'live') return 'Session Active';
      if (sessionStatus == 'pending_verification') return 'Verify & Complete';
      if (sessionStatus == 'completed') return 'Completed';
    }

    if (canStart) {
      return isInPerson ? 'Start Physical Session' : 'Start Session';
    }

    if (!isConfirmedBooking) {
      return 'Awaiting Confirmation';
    }

    if (isGroupSession &&
        !['completed', 'canceled', 'cancelled'].contains(sessionStatus)) {
      return 'Waiting for Expert';
    }

    return 'Unavailable';
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

    final callerId = Database.loginUserId.trim();
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
        callerRole: 'user',
        receiverRole: 'listener',
        receiverName: receiverName,
        receiverImage: receiverImage,
        callerName: (Database.fetchLoginUserProfileModel?.user?.fullName ?? '')
            .toString(),
        callerImage:
            (Database.fetchLoginUserProfileModel?.user?.profilePic ?? '')
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

  void _openGroupCallRoom({
    required Map<String, dynamic> session,
    required Map<String, dynamic> expert,
    String? bookingId,
  }) {
    final sessionId = _resolveSessionId(session);
    final roomId = _resolveGroupRoomId(
      session,
      fallbackSessionId: sessionId,
    );
    final roomToken = _resolveGroupRoomToken(session);
    final callType =
        (session['callType'] ?? 'audio').toString().trim().toLowerCase() ==
                'video'
            ? 'video'
            : 'audio';

    final expertId = (expert['userId'] ??
            expert['legacyListenerId'] ??
            expert['_id'] ??
            session['expertId'] ??
            '')
        .toString()
        .trim();
    if (sessionId.isEmpty || roomId.isEmpty || expertId.isEmpty) {
      Utils.showToast(
        context,
        'Unable to access group session. Missing room details.',
      );
      return;
    }

    final expertName =
        (expert['displayName'] ?? expert['name'] ?? session['title'] ?? 'Host')
            .toString()
            .trim();
    final expertImage =
        (expert['image'] ?? expert['imageUrl'] ?? expert['profilePic'] ?? '')
            .toString()
            .trim();
    final currentUserId =
        (Database.fetchLoginUserProfileModel?.user?.id ?? Database.loginUserId)
            .toString()
            .trim();
    if (currentUserId.isEmpty) {
      Utils.showToast(context, 'Please login again to access this session.');
      return;
    }

    final route = callType == 'video'
        ? AppRoutes.videoCallScreen
        : AppRoutes.voiceCallScreen;

    Get.toNamed(
      route,
      arguments: {
        'callerId': expertId,
        'receiverId': currentUserId,
        'callType': callType,
        'callerRole': 'listener',
        'receiverRole': 'user',
        'callId': roomId,
        'receiverName': Database.loginUserName,
        'callerfullName': expertName,
        'callerName': expertName,
        'receiverImage': '',
        'callerImage': expertImage,
        'isAccept': true,
        'callMode': 'group_session',
        'sessionId': sessionId,
        if (roomToken.isNotEmpty) 'zegoToken': roomToken,
        if ((bookingId ?? '').trim().isNotEmpty) 'bookingId': bookingId,
      },
    );
  }

  Future<void> _onVerifyCompletion(
    Map<String, dynamic> item,
    Map<String, dynamic> session,
  ) async {
    final bookingId = (item['_id'] ?? '').toString();
    if (bookingId.isEmpty) {
      Utils.showToast(context, 'Unable to verify session. Booking id is missing.');
      return;
    }

    final response = await SessionBookingService.verifySessionCompletion(
      bookingId: bookingId,
    );

    if (!mounted) return;

    if (response['status'] == true) {
      Utils.showToast(context, 'Session verified and completed. Credits released to expert.');
      _fetchSessions();
    } else {
      Utils.showToast(
        context,
        (response['message'] ?? 'Failed to verify session.').toString(),
      );
    }
  }

  Future<void> _onStartSessionTap(
    Map<String, dynamic> booking,
    Map<String, dynamic> session,
    Map<String, dynamic> expert,
  ) async {
    final blockedReason = _startBlockedReason(item: booking, session: session);
    if (blockedReason != null) {
      Utils.showToast(context, blockedReason);
      return;
    }

    await _onStartSession(booking, session, expert);
  }

  Future<void> _onStartSession(
    Map<String, dynamic> booking,
    Map<String, dynamic> session,
    Map<String, dynamic> expert,
  ) async {
    final sessionId = (session['_id'] ?? '').toString();
    if (sessionId.isEmpty) {
      Utils.showToast(
          context, 'Unable to start session. Session id is missing.');
      return;
    }

    final bookingId = (booking['_id'] ?? '').toString();
    final consultationMode =
        (booking['consultationMode'] ?? session['consultationMode'] ?? 'online')
            .toString()
            .trim();
    final isInPerson = consultationMode == 'in_person';

    if (isInPerson) {
      final arrivalResponse = await SessionBookingService.requestPhysicalSession(
        bookingId: bookingId,
      );
      if (!mounted) return;
      if (arrivalResponse['status'] == true) {
        Utils.showToast(context, 'Physical session request sent. Waiting for expert to accept.');
        _fetchSessions();
      } else {
        Utils.showToast(
          context,
          (arrivalResponse['message'] ?? 'Failed to send request.').toString(),
        );
      }
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

    final accessData = accessResponse['data'] is Map<String, dynamic>
        ? accessResponse['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    final grantedSession = accessData['session'] is Map<String, dynamic>
        ? accessData['session'] as Map<String, dynamic>
        : <String, dynamic>{};
    final effectiveSession = <String, dynamic>{
      ...session,
      ...grantedSession,
    };
    for (final tokenKey in const <String>[
      'zegoToken',
      'roomToken',
      'token',
      'zego_room_token',
    ]) {
      final tokenValue = (accessData[tokenKey] ?? '').toString().trim();
      if (tokenValue.isNotEmpty) {
        effectiveSession[tokenKey] = tokenValue;
      }
    }
    final grantedExpert = grantedSession['expertId'] is Map<String, dynamic>
        ? grantedSession['expertId'] as Map<String, dynamic>
        : <String, dynamic>{};
    final effectiveExpert = grantedExpert.isNotEmpty ? grantedExpert : expert;

    final sessionType =
        (effectiveSession['sessionType'] ?? '').toString().trim().toLowerCase();
    if (sessionType == 'group' ||
        sessionType == 'group_audio' ||
        sessionType == 'group_video') {
      _openGroupCallRoom(
        session: effectiveSession,
        expert: effectiveExpert,
        bookingId: bookingId,
      );
      return;
    }

    final listenerId = _resolveListenerSocketId(
      session: effectiveSession,
      expert: effectiveExpert,
    );
    if (listenerId.isEmpty) {
      Utils.showToast(
          context, 'Unable to start session. Expert is unavailable.');
      return;
    }

    final expertName =
        (effectiveExpert['displayName'] ?? effectiveExpert['name'] ?? 'Expert')
            .toString();
    final expertImage = (effectiveExpert['image'] ??
            effectiveExpert['imageUrl'] ??
            effectiveExpert['profilePic'] ??
            '')
        .toString();
    final sessionCallType =
        (effectiveSession['callType'] ?? '').toString().trim().toLowerCase();

    await _triggerDirectSessionCall(
      callType: sessionCallType,
      receiverId: listenerId,
      receiverName: expertName,
      receiverImage: expertImage,
      sessionId: (effectiveSession['_id'] ?? sessionId).toString(),
      bookingId: bookingId,
    );
  }

  Future<void> _onCancelBooking(
      Map<String, dynamic> booking, Map<String, dynamic> session) async {
    final bookingId = (booking['_id'] ?? '').toString();
    final sessionId = (session['_id'] ?? '').toString();

    if (bookingId.isEmpty && sessionId.isEmpty) {
      Utils.showToast(
          context, 'Unable to cancel booking. Missing booking details.');
      return;
    }

    setState(() {
      _cancellingBookingId = bookingId;
    });

    final response = await SessionBookingService.cancelSessionBooking(
      bookingId: bookingId,
      sessionId: sessionId,
      cancelReason: 'Canceled by user from app.',
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _cancellingBookingId = null;
    });

    Utils.showToast(
      context,
      (response['message'] ?? 'Booking cancellation updated.').toString(),
    );

    if (response['status'] == true) {
      _fetchSessions();
    }
  }

  String _extractListenerId(Map<String, dynamic> expert) {
    final candidates = [
      (expert['legacyListenerId'] ?? '').toString().trim(),
      (expert['listenerId'] ?? '').toString().trim(),
      (expert['_id'] ?? '').toString().trim(),
      (expert['id'] ?? '').toString().trim(),
    ];

    for (final value in candidates) {
      if (value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  bool _containsDangerousScript(String input) {
    final scriptTagRegex = RegExp(r'<\s*script[^>]*>', caseSensitive: false);
    return scriptTagRegex.hasMatch(input);
  }

  bool _isReviewAlreadyPresent(
    Map<String, dynamic> booking,
    Map<String, dynamic> session,
  ) {
    final reviewFlags = [
      booking['isReviewed'],
      booking['reviewSubmitted'],
      booking['hasReview'],
      session['isReviewed'],
      session['reviewSubmitted'],
      session['hasReview'],
    ];

    for (final flag in reviewFlags) {
      if (flag == true) {
        return true;
      }
      if (flag is String && flag.trim().toLowerCase() == 'true') {
        return true;
      }
      if (flag is num && flag == 1) {
        return true;
      }
    }

    final ratingCandidates = [
      booking['rating'],
      booking['reviewRating'],
    ];

    for (final rating in ratingCandidates) {
      if (rating is num && rating > 0) {
        return true;
      }
      final text = (rating ?? '').toString().trim();
      if (text.isNotEmpty && text != '0' && text != '0.0') {
        return true;
      }
    }

    final reviewCandidates = [
      booking['review'],
      booking['reviewText'],
    ];

    for (final review in reviewCandidates) {
      if ((review ?? '').toString().trim().isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  Future<Map<String, dynamic>> _submitSessionReview({
    required String reviewKey,
    required String listenerId,
    required int rating,
    required String review,
  }) async {
    final normalizedListenerId = listenerId.trim();
    if (normalizedListenerId.isEmpty) {
      return {
        'success': false,
        'message': 'Unable to submit review. Expert id missing.',
      };
    }

    final response = await SubmitCallRateApi.callApi(
      listenerId: normalizedListenerId,
      review: review,
      rating: rating.toString(),
    );

    if (!mounted) {
      return {
        'success': false,
        'message': 'Screen is not active.',
      };
    }

    final rawMessage =
        (response?.message ?? 'Failed to submit review.').toString();
    final normalizedMessage = rawMessage.toLowerCase();
    final alreadyReviewed = normalizedMessage.contains('already') &&
        (normalizedMessage.contains('review') ||
            normalizedMessage.contains('rated') ||
            normalizedMessage.contains('rating'));
    final isSuccess = response?.status == true || alreadyReviewed;
    final message = rawMessage.trim().isEmpty
        ? (isSuccess
            ? 'Review submitted successfully.'
            : 'Failed to submit review.')
        : rawMessage;

    return {
      'success': isSuccess,
      'message': message,
      'reviewKey': reviewKey,
    };
  }

  Future<void> _showReviewBottomSheet({
    required String reviewKey,
    required Map<String, dynamic> expert,
  }) async {
    final listenerId = _extractListenerId(expert);
    if (listenerId.isEmpty) {
      Utils.showToast(context, 'Unable to submit review for this expert.');
      return;
    }

    final expertName =
        (expert['displayName'] ?? expert['name'] ?? 'Expert').toString();
    final reviewController = TextEditingController();
    int selectedRating = 5;
    bool isSubmitting = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return PopScope(
              canPop: !isSubmitting,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                ),
                child: Dialog(
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Review @expertName'.trParams({'expertName': expertName}),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 17,
                                    fontColor: _brandDark,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () {
                                        FocusScope.of(modalContext).unfocus();
                                        Navigator.of(modalContext).pop();
                                      },
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            EnumLocale.txtHowWasYourSessionExperience.name.tr,
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 12,
                              fontColor: _mutedText,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final active = index < selectedRating;
                              return IconButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () {
                                        setModalState(() {
                                          selectedRating = index + 1;
                                        });
                                      },
                                icon: Icon(
                                  Icons.star_rounded,
                                  size: 34,
                                  color: active
                                      ? AppColors.rateStarColor
                                      : AppColors.lightGrey,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: reviewController,
                            enabled: !isSubmitting,
                            minLines: 3,
                            maxLines: 5,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: EnumLocale.txtWriteYourReviewHere.name.tr,
                              hintStyle: AppFontStyle.fontStyleW500(
                                fontSize: 12,
                                fontColor: _mutedText,
                              ),
                              filled: true,
                              fillColor: AppColors.redesignSurfaceSoft,
                              contentPadding: const EdgeInsets.all(12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: _softBorder, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: _softBorder, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _brandRed.withValues(alpha: 0.6),
                                  width: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      final review =
                                          reviewController.text.trim();
                                      if (review.isEmpty) {
                                        Utils.showToast(
                                          context,
                                          'Please enter a review.',
                                        );
                                        return;
                                      }

                                      if (_containsDangerousScript(review)) {
                                        Utils.showToast(
                                          context,
                                          'Script tags are not allowed in the review.',
                                        );
                                        reviewController.clear();
                                        return;
                                      }

                                      if (!mounted) return;

                                      setModalState(() {
                                        isSubmitting = true;
                                      });
                                      FocusScope.of(modalContext).unfocus();

                                      final submitResult =
                                          await _submitSessionReview(
                                        reviewKey: reviewKey,
                                        listenerId: listenerId,
                                        rating: selectedRating,
                                        review: review,
                                      );

                                      if (!mounted || !modalContext.mounted) {
                                        return;
                                      }

                                      final isSuccess =
                                          submitResult['success'] == true;
                                      final message =
                                          (submitResult['message'] ?? '')
                                              .toString();

                                      if (isSuccess) {
                                        Navigator.of(modalContext)
                                            .pop(submitResult);
                                        return;
                                      }

                                      if (message.isNotEmpty) {
                                        Utils.showToast(context, message);
                                      }

                                      setModalState(() {
                                        isSubmitting = false;
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: _brandRed,
                                foregroundColor: AppColors.white,
                                disabledBackgroundColor: _softBorder,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: isSubmitting
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send_rounded,
                                      size: 16,
                                    ),
                              label: Text(
                                isSubmitting
                                    ? 'Submitting...'
                                    : 'Submit Review',
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
                ),
              ),
            );
          },
        );
      },
    );

    reviewController.dispose();

    if (!mounted || result == null) {
      return;
    }

    final submitted = result['success'] == true;
    if (!submitted) {
      return;
    }

    setState(() {
      _reviewSubmittedKeys.add(reviewKey);
    });
    await _saveReviewsToStorage();
    await _fetchSessions();

    if (!mounted) {
      return;
    }

    final message = (result['message'] ?? '').toString().trim();
    final dialogMessage = message.isEmpty
        ? 'Your review has been successfully recorded.'
        : message;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            EnumLocale.txtReviewSubmitted.name.tr,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(dialogMessage),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandRed,
                  foregroundColor: AppColors.white,
                ),
                child: Text(EnumLocale.txtClose.name.tr),
              ),
            ),
          ],
        );
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

  Widget _buildModeFilterChip(String value, String label, IconData icon) {
    final selected = value == _modeFilter;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          if (_modeFilter == value) return;
          setState(() {
            _modeFilter = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: selected ? _brandDark : AppColors.white,
            border: Border.all(
              color: selected ? _brandDark : _softBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: selected ? AppColors.white : _mutedText,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppFontStyle.fontStyleW600(
                  fontSize: 11,
                  fontColor: selected ? AppColors.white : _mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _chipSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _softBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _mutedText),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppFontStyle.fontStyleW500(
              fontSize: 11,
              fontColor: _mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF43A047)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFontStyle.fontStyleW500(
              fontSize: 11,
              fontColor: const Color(0xFF2E7D32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard({double bottomMargin = 12}) {
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: 180,
            decoration: BoxDecoration(
              color: AppColors.lightGrey1,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 90,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 12,
            width: 220,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 170,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard({
    required Map<String, dynamic> item,
    required double cardWidth,
  }) {
    final session = _extractSession(item);
    final expert = _extractExpert(session);

    final callTypeRaw = (session['callType'] ?? '').toString().trim();
    final consultationModeRaw = (item['consultationMode'] ?? session['consultationMode'] ?? '').toString().trim();
    final isInPersonSession = consultationModeRaw == 'in_person';
    final callTypeLabel = isInPersonSession
        ? 'IN-PERSON'
        : (callTypeRaw.isEmpty ? 'Unknown' : callTypeRaw.toUpperCase());
    final status = _sessionStatus(session);
    final statusLower = status;
    final statusLabel = _toTitleCase(status);
    final isCompletedSession = statusLower == 'completed';
    final bookingStatus =
        (item['bookingStatus'] ?? '').toString().trim().toLowerCase();
    final isConfirmedBooking = bookingStatus.isNotEmpty
        ? bookingStatus == 'confirmed'
        : item['canStartSession'] == true;
    final isGroupSession = _isGroupSessionType(session);
    final canStart = _startBlockedReason(item: item, session: session) == null;
    final startButtonLabel = _startButtonLabel(
      canStart: canStart,
      isGroupSession: isGroupSession,
      isConfirmedBooking: isConfirmedBooking,
      sessionStatus: statusLower,
      isInPerson: isInPersonSession,
    );
    final showStartSession = _view == 'upcoming';
    final showReviewAction = _view == 'completed' && isCompletedSession;
    final bookingId = (item['_id'] ?? '').toString();
    final sessionId = (session['_id'] ?? '').toString();
    final reviewKey = bookingId.isNotEmpty ? bookingId : sessionId;
    final hasSubmittedReview = _reviewSubmittedKeys.contains(reviewKey) ||
        _isReviewAlreadyPresent(item, session);
    final isCancellingThis = _cancellingBookingId == bookingId;
    final title = (session['title'] ?? 'Session').toString();
    final expertName = (expert['displayName'] ?? 'Unknown').toString();
    final startAt = _formatDateTime((session['startAt'] ?? '').toString());
    final isNarrowActionLayout = cardWidth < 430;

    // In-Person consultation fields
    final consultationMode = (item['consultationMode'] ?? session['consultationMode'] ?? 'online').toString().trim();
    final isInPerson = consultationMode == 'in_person';
    final inPersonDetails = session['inPersonDetails'] is Map<String, dynamic> ? session['inPersonDetails'] as Map<String, dynamic> : <String, dynamic>{};
    final clinicSnapshot = inPersonDetails['clinicSnapshot'] is Map<String, dynamic> ? inPersonDetails['clinicSnapshot'] as Map<String, dynamic> : <String, dynamic>{};
    final clinicName = (clinicSnapshot['clinicName'] ?? '').toString().trim();
    final clinicAddress = clinicSnapshot['address'];
    final clinicStreet = (clinicAddress?['street'] ?? '').toString().trim();
    final clinicCity = (clinicAddress?['city'] ?? '').toString().trim();
    final clinicState = (clinicAddress?['state'] ?? '').toString().trim();
    final clinicCountry = (clinicAddress?['country'] ?? '').toString().trim();
    final clinicPostalCode = (clinicAddress?['postalCode'] ?? '').toString().trim();
    final clinicFullAddress = [clinicStreet, clinicCity, clinicState, clinicCountry]
        .where((s) => s.trim().isNotEmpty)
        .join(', ');
    final clinicFloorSuite = (clinicSnapshot['floorSuite'] ?? '').toString().trim();
    final clinicLandmark = (clinicSnapshot['landmark'] ?? '').toString().trim();
    final clinicParkingInfo = (clinicSnapshot['parkingInfo'] ?? '').toString().trim();
    final clinicContactPhone = (clinicSnapshot['contactPhone'] ?? '').toString().trim();
    final clinicContactEmail = (clinicSnapshot['contactEmail'] ?? '').toString().trim();
    final clinicInstructions = (clinicSnapshot['consultationInstructions'] ?? '').toString().trim();
    final arrivalStatus = (item['arrivalStatus'] ?? '').toString().trim().toLowerCase();
    final hasCheckedIn = arrivalStatus == 'arrived';
    final isLive = ['live', 'active', 'ongoing', 'started'].contains(statusLower);

    return Container(
      padding: const EdgeInsets.all(12),
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
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 14,
                    fontColor: _brandDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusBackground(status),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 10,
                    fontColor: _statusTextColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            expertName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFontStyle.fontStyleW600(
              fontSize: 13,
              fontColor: _brandDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetaChip(
                icon: Icons.schedule_rounded,
                text: startAt,
              ),
              _buildMetaChip(
                icon: isInPersonSession
                    ? Icons.location_on_rounded
                    : (callTypeRaw.toLowerCase() == 'video'
                        ? Icons.videocam_outlined
                        : Icons.call_outlined),
                text: callTypeLabel,
              ),
              _buildMetaChip(
                icon: isInPerson ? Icons.location_on_rounded : Icons.videocam_rounded,
                text: isInPerson ? 'In-Person' : 'Online',
              ),
            ],
          ),
          if (isInPerson && clinicName.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_hospital_rounded,
                          size: 16,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clinicName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 13,
                                fontColor: const Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              expertName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.fontStyleW500(
                                fontSize: 11,
                                fontColor: const Color(0xFF558B2F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (clinicFullAddress.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildClinicDetailRow(Icons.place_rounded, clinicFullAddress),
                  ],
                  if (clinicPostalCode.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildClinicDetailRow(Icons.markunread_mailbox_rounded, 'Postal Code: $clinicPostalCode'),
                  ],
                  if (clinicFloorSuite.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildClinicDetailRow(Icons.layers_rounded, 'Floor / Suite: $clinicFloorSuite'),
                  ],
                  if (clinicLandmark.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildClinicDetailRow(Icons.signpost_rounded, 'Landmark: $clinicLandmark'),
                  ],
                  if (clinicParkingInfo.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildClinicDetailRow(Icons.local_parking_rounded, 'Parking: $clinicParkingInfo'),
                  ],
                  if (clinicContactPhone.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildClinicDetailRow(Icons.phone_rounded, clinicContactPhone),
                  ],
                  if (clinicContactEmail.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildClinicDetailRow(Icons.email_rounded, clinicContactEmail),
                  ],
                  if (clinicInstructions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 13, color: Color(0xFF558B2F)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              clinicInstructions,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.fontStyleW500(
                                fontSize: 11,
                                fontColor: const Color(0xFF558B2F),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (showStartSession) ...[
            if (isInPerson) const SizedBox(height: 12),
            if (isNarrowActionLayout)
              Column(
                children: [
                  if (isInPerson && statusLower == 'requested')
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: OutlinedButton.icon(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: const Color(0xFFFFA726).withValues(alpha: 0.5)),
                          foregroundColor: const Color(0xFFE65100),
                          disabledBackgroundColor: const Color(0xFFFFF3E0),
                          disabledForegroundColor: const Color(0xFFE65100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.hourglass_top_rounded, size: 16),
                        label: Text(
                          'Awaiting Expert',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 13,
                            fontColor: const Color(0xFFE65100),
                          ),
                        ),
                      ),
                    )
                  else if (isInPerson && hasCheckedIn)
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: OutlinedButton.icon(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: const Color(0xFF2E7D32).withValues(alpha: 0.5)),
                          foregroundColor: const Color(0xFF2E7D32),
                          disabledBackgroundColor: const Color(0xFFE8F5E9),
                          disabledForegroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                        label: Text(
                          isLive ? 'Session In Progress' : 'Checked In',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 13,
                            fontColor: const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    )
                  else if (isInPerson && statusLower == 'pending_verification')
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () => _onVerifyCompletion(item, session),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.verified_rounded, size: 16),
                        label: Text(
                          'Verify & Complete',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 13,
                            fontColor: AppColors.white,
                          ),
                        ),
                      ),
                    )
                  else if (!isInPerson && isLive)
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _onStartSessionTap(item, session, expert),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          callTypeRaw.toLowerCase() == 'video'
                              ? Icons.videocam_outlined
                              : Icons.call_outlined,
                          size: 16,
                        ),
                        label: Text(
                          callTypeRaw.toLowerCase() == 'video'
                              ? 'Join Video Call'
                              : 'Join Audio Call',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 13,
                            fontColor: AppColors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _onStartSessionTap(item, session, expert),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          disabledBackgroundColor: AppColors.redesignSoftBorder,
                          disabledForegroundColor: _mutedText,
                          backgroundColor: canStart
                              ? _brandDark
                              : AppColors.redesignSoftBorder,
                          foregroundColor:
                              canStart ? AppColors.white : _mutedText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          canStart
                              ? (isInPerson ? Icons.location_on_outlined : Icons.play_circle_outline_rounded)
                              : Icons.schedule_rounded,
                          size: 16,
                        ),
                        label: Text(
                          startButtonLabel,
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 13,
                            fontColor: canStart ? AppColors.white : _mutedText,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: isCancellingThis
                          ? null
                          : () => _onCancelBooking(item, session),
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
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.close_rounded, size: 16),
                      label: Text(
                        isCancellingThis ? 'Cancelling' : 'Cancel Slot',
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 13,
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
                  if (isInPerson && statusLower == 'requested')
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: const Color(0xFFFFA726).withValues(alpha: 0.5)),
                            foregroundColor: const Color(0xFFE65100),
                            disabledBackgroundColor: const Color(0xFFFFF3E0),
                            disabledForegroundColor: const Color(0xFFE65100),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.hourglass_top_rounded, size: 16),
                          label: Text(
                            'Awaiting Expert',
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 13,
                              fontColor: const Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (isInPerson && hasCheckedIn)
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: const Color(0xFF2E7D32).withValues(alpha: 0.5)),
                            foregroundColor: const Color(0xFF2E7D32),
                            disabledBackgroundColor: const Color(0xFFE8F5E9),
                            disabledForegroundColor: const Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                          label: Text(
                            isLive ? 'Session In Progress' : 'Checked In',
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 13,
                              fontColor: const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (isInPerson && statusLower == 'pending_verification')
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () => _onVerifyCompletion(item, session),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.verified_rounded, size: 16),
                          label: Text(
                            'Verify & Complete',
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 13,
                              fontColor: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (!isInPerson && isLive)
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _onStartSessionTap(item, session, expert),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            callTypeRaw.toLowerCase() == 'video'
                                ? Icons.videocam_outlined
                                : Icons.call_outlined,
                            size: 16,
                          ),
                          label: Text(
                            callTypeRaw.toLowerCase() == 'video'
                                ? 'Join Video Call'
                                : 'Join Audio Call',
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 13,
                              fontColor: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _onStartSessionTap(item, session, expert),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            disabledBackgroundColor: AppColors.redesignSoftBorder,
                            disabledForegroundColor: _mutedText,
                            backgroundColor: canStart
                                ? _brandDark
                                : AppColors.redesignSoftBorder,
                            foregroundColor:
                                canStart ? AppColors.white : _mutedText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            canStart
                                ? (isInPerson ? Icons.location_on_outlined : Icons.play_circle_outline_rounded)
                                : Icons.schedule_rounded,
                            size: 16,
                          ),
                          label: Text(
                            startButtonLabel,
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 13,
                              fontColor: canStart ? AppColors.white : _mutedText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton.icon(
                        onPressed: isCancellingThis
                            ? null
                            : () => _onCancelBooking(item, session),
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
                            fontSize: 13,
                            fontColor: _brandRedDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
          if (showReviewAction) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: hasSubmittedReview
                  ? OutlinedButton.icon(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.redesignStatusSuccessDark
                              .withValues(alpha: 0.4),
                        ),
                        foregroundColor: AppColors.redesignStatusSuccessDark,
                        disabledForegroundColor:
                            AppColors.redesignStatusSuccessDark,
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded,
                          size: 16),
                      label: Text(
                        EnumLocale.txtReviewSubmitted.name.tr,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 13,
                          fontColor: AppColors.redesignStatusSuccessDark,
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _showReviewBottomSheet(
                        reviewKey: reviewKey,
                        expert: expert,
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        disabledBackgroundColor: AppColors.redesignSoftBorder,
                        disabledForegroundColor: _mutedText,
                        backgroundColor: _brandRed,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.rate_review_outlined,
                        size: 16,
                      ),
                      label: Text(
                        EnumLocale.txtGiveReview.name.tr,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 13,
                          fontColor: AppColors.white,
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  List<dynamic> get _filteredSessions {
    if (_modeFilter == 'all') return _sessions;
    return _sessions.where((rawItem) {
      if (rawItem is! Map<String, dynamic>) return false;
      final session = _extractSession(rawItem);
      final consultationMode = (rawItem['consultationMode'] ?? session['consultationMode'] ?? 'online').toString().trim();
      if (_modeFilter == 'in_person') return consultationMode == 'in_person';
      if (_modeFilter == 'online') return consultationMode != 'in_person';
      return true;
    }).toList();
  }

  Widget _buildSessionsList({
    required double horizontalInset,
  }) {
    if (_isLoading) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = (constraints.maxWidth - (horizontalInset * 2))
              .clamp(0.0, double.infinity)
              .toDouble();
          final isTablet = constraints.maxWidth >= 760;
          final columns = constraints.maxWidth >= 1200
              ? 3
              : isTablet
                  ? 2
                  : 1;
          const spacing = 14.0;
          final cardWidth = columns == 1
              ? availableWidth
              : ((availableWidth - (spacing * (columns - 1))) / columns)
                  .toDouble();

          return Shimmer.fromColors(
            baseColor: AppColors.redesignShimmerBase,
            highlightColor: AppColors.white,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding:
                  EdgeInsets.fromLTRB(horizontalInset, 6, horizontalInset, 20),
              children: [
                if (columns == 1)
                  ...List.generate(4, (index) => _buildLoadingCard())
                else
                  Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: List.generate(
                      4,
                      (index) => SizedBox(
                        width: cardWidth,
                        child: _buildLoadingCard(bottomMargin: 0),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }

    if (_filteredSessions.isEmpty) {
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
                  fontSize: 15,
                  fontColor: _brandDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _view == 'upcoming'
                    ? 'Your upcoming bookings will appear here.'
                    : 'Completed sessions will appear here.',
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 12,
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
          final availableWidth = (constraints.maxWidth - (horizontalInset * 2))
              .clamp(0.0, double.infinity)
              .toDouble();
          final isTablet = constraints.maxWidth >= 760;
          final columns = constraints.maxWidth >= 1200
              ? 3
              : isTablet
                  ? 2
                  : 1;
          const spacing = 14.0;
          final cardWidth = columns == 1
              ? availableWidth
              : ((availableWidth - (spacing * (columns - 1))) / columns)
                  .toDouble();

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding:
                EdgeInsets.fromLTRB(horizontalInset, 6, horizontalInset, 20),
            children: [
              if (columns == 1)
                ..._filteredSessions.map((rawItem) {
                  final item = rawItem is Map<String, dynamic>
                      ? rawItem
                      : <String, dynamic>{};

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildSessionCard(
                      item: item,
                      cardWidth: cardWidth,
                    ),
                  );
                })
              else
                Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: _filteredSessions.map((rawItem) {
                    final item = rawItem is Map<String, dynamic>
                        ? rawItem
                        : <String, dynamic>{};

                    return SizedBox(
                      width: cardWidth,
                      child: _buildSessionCard(
                        item: item,
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
      body: LayoutBuilder(
        builder: (context, viewportConstraints) {
          final viewportWidth = viewportConstraints.maxWidth;
          final maxContentWidth = viewportWidth >= 760 ? 980.0 : viewportWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: LayoutBuilder(
                builder: (context, contentConstraints) {
                  final width = contentConstraints.maxWidth;
                  final isTablet = width >= 760;
                  final canPop = Navigator.of(context).canPop();
                  final horizontalInset = width >= 1100
                      ? 28.0
                      : isTablet
                          ? 22.0
                          : 16.0;
                  final heroSubtitle = _view == 'upcoming'
                      ? 'Track and manage your upcoming bookings'
                      : 'View your completed sessions in one place';

                  return SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalInset,
                            8,
                            horizontalInset,
                            6,
                          ),
                          child: Row(
                            children: [
                              if (canPop)
                                Material(
                                  color: AppColors.transparent,
                                  child: InkWell(
                                    onTap: () =>
                                        Navigator.of(context).maybePop(),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      height: isTablet ? 42 : 38,
                                      width: isTablet ? 42 : 38,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: _softBorder),
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: isTablet ? 20 : 18,
                                        color: _brandDark,
                                      ),
                                    ),
                                  ),
                                ),
                              if (canPop) const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  EnumLocale.txtMySessions.name.tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: isTablet ? 22 : 18,
                                    fontColor: _brandDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalInset,
                            6,
                            horizontalInset,
                            10,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(isTablet ? 14 : 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _brandRed,
                                  _brandRedDark,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _brandRed.withValues(alpha: 0.24),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: isTablet ? 40 : 36,
                                      width: isTablet ? 40 : 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.calendar_month_rounded,
                                        color: _brandRed,
                                        size: isTablet ? 22 : 20,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            EnumLocale.txtSessionCenter.name.tr,
                                            style: AppFontStyle.fontStyleW700(
                                              fontSize: isTablet ? 15 : 14,
                                              fontColor: AppColors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            heroSubtitle,
                                            style: AppFontStyle.fontStyleW500(
                                              fontSize: isTablet ? 12 : 11,
                                              fontColor: AppColors.white
                                                  .withValues(alpha: 0.88),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColors.white
                                              .withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            EnumLocale.txtSessionCount.name.trParams({
                                              'count': '${_filteredSessions.length}',
                                            }),
                                            style: AppFontStyle.fontStyleW700(
                                              fontSize: isTablet ? 16 : 14,
                                              fontColor: AppColors.white,
                                            ),
                                          ),
                                          Text(
                                            _view == 'upcoming'
                                                ? EnumLocale.txtUpcoming.name.tr
                                                : EnumLocale.txtDone.name.tr,
                                            style: AppFontStyle.fontStyleW500(
                                              fontSize: 9,
                                              fontColor: AppColors.white
                                                  .withValues(alpha: 0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: isTablet ? 46.0 : 42.0,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.toNamed(AppRoutes.userGroupSessionsScreen);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: AppColors.white,
                                      foregroundColor: _brandRedDark,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.groups_rounded,
                                          size: isTablet ? 20 : 18,
                                          color: _brandRedDark,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          EnumLocale.txtGroupSessions.name.tr,
                                          style: AppFontStyle.fontStyleW700(
                                            fontSize: isTablet ? 14 : 13,
                                            fontColor: _brandDark,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: isTablet ? 16 : 14,
                                          color: _brandDark,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: isTablet ? 46.0 : 42.0,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const MyRecordingsScreen(),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: AppColors.white.withValues(alpha: 0.5)),
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.cloud_rounded,
                                          size: isTablet ? 20 : 18,
                                          color: AppColors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "My Recordings",
                                          style: AppFontStyle.fontStyleW700(
                                            fontSize: isTablet ? 14 : 13,
                                            fontColor: AppColors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: isTablet ? 16 : 14,
                                          color: AppColors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalInset,
                            0,
                            horizontalInset,
                            10,
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
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalInset,
                            6,
                            horizontalInset,
                            6,
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _buildModeFilterChip('all', 'All', Icons.filter_list_rounded),
                                _buildModeFilterChip('online', 'Audio/Video', Icons.headset_rounded),
                                _buildModeFilterChip('in_person', 'In-Person', Icons.location_on_rounded),
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
