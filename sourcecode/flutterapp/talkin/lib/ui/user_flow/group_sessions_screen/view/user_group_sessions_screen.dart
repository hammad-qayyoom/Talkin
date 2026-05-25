import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/custom/verified_badge/verified_badge.dart';
import 'package:notisboard/ui/common/session_booking/session_booking_service.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/auth_guard.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class UserGroupSessionsScreen extends StatefulWidget {
  const UserGroupSessionsScreen({super.key});

  @override
  State<UserGroupSessionsScreen> createState() =>
      _UserGroupSessionsScreenState();
}

class _UserGroupSessionsScreenState extends State<UserGroupSessionsScreen> {
  bool _isLoading = false;
  String _selectedCallType = 'all';
  List<dynamic> _sessions = [];

  String? _joiningSessionId;
  String? _leavingSessionId;
  String? _accessingSessionId;

  final Map<String, String> _bookingIdBySessionId = {};

  String get _currentUserId {
    return (Database.fetchLoginUserProfileModel?.user?.id ?? '')
        .toString()
        .trim();
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

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    setState(() {
      _isLoading = true;
    });

    final response = await SessionBookingService.getGroupSessions(
      includePast: true,
      status: 'all',
      callType: _selectedCallType == 'all' ? null : _selectedCallType,
      start: 1,
      limit: 50,
    );

    if (!mounted) {
      return;
    }

    final fetchedSessions = _extractGroupSessions(response['data']);

    setState(() {
      _sessions = fetchedSessions;
      _isLoading = false;
    });

    if (response['status'] != true) {
      Utils.showToast(
          context,
          (response['message'] ?? 'Failed to fetch group sessions.')
              .toString());
    }
  }

  List<dynamic> _extractGroupSessions(dynamic payload) {
    if (payload is List<dynamic>) {
      return payload
          .map(_normalizeSessionMap)
          .where((session) => session.isNotEmpty)
          .toList();
    }

    if (payload is Map<String, dynamic>) {
      const listKeys = <String>[
        'sessions',
        'items',
        'docs',
        'results',
        'records',
        'rows',
        'list',
        'data',
      ];

      for (final key in listKeys) {
        final value = payload[key];
        if (value is List<dynamic>) {
          return value
              .map(_normalizeSessionMap)
              .where((session) => session.isNotEmpty)
              .toList();
        }

        if (value is Map<String, dynamic>) {
          final nestedSessions = _extractGroupSessions(value);
          if (nestedSessions.isNotEmpty) {
            return nestedSessions;
          }
        }
      }

      for (final value in payload.values) {
        if (value is List<dynamic>) {
          return value
              .map(_normalizeSessionMap)
              .where((session) => session.isNotEmpty)
              .toList();
        }
      }
    }

    return <dynamic>[];
  }

  Map<String, dynamic> _normalizeSessionMap(dynamic rawSession) {
    if (rawSession is! Map<String, dynamic>) {
      return <String, dynamic>{};
    }

    if (rawSession['session'] is Map<String, dynamic>) {
      return rawSession['session'] as Map<String, dynamic>;
    }

    if (rawSession['sessionId'] is Map<String, dynamic>) {
      return rawSession['sessionId'] as Map<String, dynamic>;
    }

    return rawSession;
  }

  String _normalizeStatusValue(String rawStatus) {
    final status = rawStatus.trim().toLowerCase();

    switch (status) {
      case 'upcoming':
      case 'pending':
      case 'booked':
      case 'confirmed':
      case 'created':
      case 'not_started':
      case 'not-started':
      case 'ready':
        return 'scheduled';
      case 'active':
      case 'ongoing':
      case 'started':
      case 'running':
      case 'in_progress':
      case 'in-progress':
        return 'live';
      case 'ended':
      case 'finished':
      case 'done':
      case 'settled':
      case 'closed':
      case 'expired':
        return 'completed';
      case 'cancelled':
        return 'canceled';
      default:
        return status;
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

  int _toInt(dynamic value, int fallback) {
    final parsed = int.tryParse((value ?? '').toString());
    return parsed ?? fallback;
  }

  bool _toBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    final normalized = (value ?? '').toString().trim().toLowerCase();
    if (['true', '1', 'yes'].contains(normalized)) return true;
    if (['false', '0', 'no'].contains(normalized)) return false;
    return fallback;
  }

  bool _isJoinedByCurrentUser(Map<String, dynamic> session) {
    return session['isBookedByCurrentUser'] == true;
  }

  String _pricingLabel(Map<String, dynamic> session) {
    final pricingMode =
        (session['groupPricingMode'] ?? '').toString().trim().toLowerCase();
    final sessionCredits = _toInt(session['groupSessionCreditsRequired'], -1);
    final fallbackPrice = _toInt(session['price'], 0);
    final effectiveCredits =
        sessionCredits >= 0 ? sessionCredits : fallbackPrice;

    if (pricingMode == 'free' || effectiveCredits <= 0) {
      return 'FREE';
    }

    return '$effectiveCredits credits';
  }

  int _availableSeats(Map<String, dynamic> session) {
    final available = _toInt(session['availableSlots'], -1);
    if (available >= 0) {
      return available;
    }

    final maxParticipants = _toInt(session['maxParticipants'], 0);
    final currentParticipants = _toInt(session['currentParticipants'], 0);

    return (maxParticipants - currentParticipants).clamp(0, 999999);
  }

  String _sessionStatus(Map<String, dynamic> session) {
    final rawStatus =
        (session['sessionStatus'] ?? session['status'] ?? '').toString().trim();
    return _normalizeStatusValue(rawStatus);
  }

  bool _isLiveStatus(String sessionStatus) {
    return ['live', 'active', 'ongoing', 'started'].contains(sessionStatus);
  }

  bool _isJoinableStatus(String sessionStatus) {
    return sessionStatus == 'scheduled' || _isLiveStatus(sessionStatus);
  }

  bool _isClosedStatus(String sessionStatus) {
    return ['completed', 'canceled', 'cancelled'].contains(sessionStatus);
  }

  String? _joinBlockedReason(Map<String, dynamic> session) {
    if (AuthGuard.isGuest) {
      return 'Please log in to join this session.';
    }

    if (_currentUserId.isEmpty) {
      return 'Please login again to join this session.';
    }

    final status = _sessionStatus(session);
    if (_isClosedStatus(status)) {
      return 'Session is no longer open for joining.';
    }

    if (!_isJoinableStatus(status)) {
      return 'Session is not open for joining right now.';
    }

    if (_availableSeats(session) <= 0) {
      return 'Session participant limit is full.';
    }

    return null;
  }

  String? _accessBlockedReason(Map<String, dynamic> session) {
    if (AuthGuard.isGuest) {
      return 'Please log in to access this session.';
    }

    if (_currentUserId.isEmpty) {
      return 'Please login again to access this session.';
    }

    final status = _sessionStatus(session);
    if (_isClosedStatus(status)) {
      return 'Session is no longer active.';
    }

    if (!_isLiveStatus(status)) {
      return 'Session host has not started live stream yet.';
    }

    return null;
  }

  String _joinButtonLabel(Map<String, dynamic> session) {
    final status = _sessionStatus(session);
    if (_availableSeats(session) <= 0) {
      return 'Session Full';
    }

    if (_isClosedStatus(status)) {
      return 'Session Closed';
    }

    if (!_isJoinableStatus(status)) {
      return 'Unavailable';
    }

    return 'Join Session';
  }

  Future<void> _onJoinSessionTap(Map<String, dynamic> session) async {
    final blockedReason = _joinBlockedReason(session);
    if (blockedReason != null) {
      if (AuthGuard.isGuest) {
        AuthGuard.showLoginPrompt(message: blockedReason);
        return;
      }
      Utils.showToast(context, blockedReason);
      return;
    }

    await _onJoinSession(session);
  }

  Future<void> _onAccessSessionTap(Map<String, dynamic> session) async {
    final blockedReason = _accessBlockedReason(session);
    if (blockedReason != null) {
      if (AuthGuard.isGuest) {
        AuthGuard.showLoginPrompt(message: blockedReason);
        return;
      }
      Utils.showToast(context, blockedReason);
      return;
    }

    await _onAccessSession(session);
  }

  List<Map<String, dynamic>> get _activeSessions {
    final now = DateTime.now();

    return _sessions.whereType<Map<String, dynamic>>().where((session) {
      final status = _sessionStatus(session);

      if (_isClosedStatus(status)) {
        return false;
      }

      final endAt =
          DateTime.tryParse((session['endAt'] ?? '').toString())?.toLocal();
      if (endAt != null && endAt.isBefore(now)) {
        return false;
      }

      return _isJoinableStatus(status);
    }).toList();
  }

  void _openGroupCallRoom(Map<String, dynamic> session, {String? bookingId}) {
    final sessionId = _resolveSessionId(session);
    final roomId = _resolveGroupRoomId(
      session,
      fallbackSessionId: sessionId,
    );
    final roomToken = _resolveGroupRoomToken(session);

    if (roomId.isEmpty) {
      Utils.showToast(
        context,
        'Unable to access group session. Missing room details.',
      );
      return;
    }

    final callType =
        (session['callType'] ?? 'audio').toString().trim().toLowerCase() ==
                'video'
            ? 'video'
            : 'audio';

    final expert = session['expertId'] is Map<String, dynamic>
        ? session['expertId'] as Map<String, dynamic>
        : <String, dynamic>{};

    final expertId =
        (expert['userId'] ?? expert['_id'] ?? session['expertId'] ?? '')
            .toString()
            .trim();
    final expertName =
        (expert['displayName'] ?? session['title'] ?? 'Group Host')
            .toString()
            .trim();
    final expertImage = (expert['profilePic'] ?? '').toString();

    final route = callType == 'video'
        ? AppRoutes.videoCallScreen
        : AppRoutes.voiceCallScreen;

    Get.toNamed(
      route,
      arguments: {
        'callerId': expertId,
        'receiverId': _currentUserId,
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

  Future<String?> _resolveBookingIdForCurrentUser(String sessionId) async {
    final existing = _bookingIdBySessionId[sessionId];
    if ((existing ?? '').trim().isNotEmpty) {
      return existing;
    }

    final participantsResponse =
        await SessionBookingService.getGroupSessionParticipants(
            sessionId: sessionId);

    if (participantsResponse['status'] != true) {
      return null;
    }

    final data = participantsResponse['data'];
    final participants =
        data is Map<String, dynamic> && data['participants'] is List<dynamic>
            ? data['participants'] as List<dynamic>
            : <dynamic>[];

    for (final participant in participants) {
      if (participant is! Map<String, dynamic>) {
        continue;
      }

      final participantUserId = (participant['userId'] ?? '').toString().trim();
      if (participantUserId == _currentUserId) {
        final bookingId = (participant['bookingId'] ?? '').toString().trim();
        if (bookingId.isNotEmpty) {
          _bookingIdBySessionId[sessionId] = bookingId;
          return bookingId;
        }
      }
    }

    return null;
  }

  Future<void> _onJoinSession(Map<String, dynamic> session) async {
    final sessionId = (session['_id'] ?? '').toString().trim();
    if (sessionId.isEmpty) {
      Utils.showToast(context, 'Invalid session.');
      return;
    }

    setState(() {
      _joiningSessionId = sessionId;
    });

    final response = await SessionBookingService.joinGroupSession(
      sessionId: sessionId,
      userId: _currentUserId.isEmpty ? null : _currentUserId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _joiningSessionId = null;
    });

    Utils.showToast(
        context, (response['message'] ?? 'Join request processed.').toString());

    if (response['status'] == true) {
      final booking = response['data'];
      if (booking is Map<String, dynamic>) {
        final bookingId = (booking['_id'] ?? '').toString().trim();
        if (bookingId.isNotEmpty) {
          _bookingIdBySessionId[sessionId] = bookingId;
        }
      }

      final sessionStatus =
          (session['sessionStatus'] ?? session['status'] ?? '')
              .toString()
              .trim()
              .toLowerCase();
      if (sessionStatus == 'live') {
        await _onAccessSession(session);
        return;
      }

      _fetchSessions();

      return;
    }

    final normalizedMessage =
        (response['message'] ?? '').toString().trim().toLowerCase();
    if (normalizedMessage.contains('already joined')) {
      final blockedReason = _accessBlockedReason(session);
      if (blockedReason != null) {
        Utils.showToast(context, blockedReason);
        _fetchSessions();
        return;
      }

      await _onAccessSession(session);
    }
  }

  Future<void> _onLeaveSession(Map<String, dynamic> session) async {
    final sessionId = (session['_id'] ?? '').toString().trim();
    if (sessionId.isEmpty) {
      Utils.showToast(context, 'Invalid session.');
      return;
    }

    setState(() {
      _leavingSessionId = sessionId;
    });

    final response = await SessionBookingService.leaveGroupSession(
      sessionId: sessionId,
      userId: _currentUserId.isEmpty ? null : _currentUserId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _leavingSessionId = null;
    });

    Utils.showToast(context,
        (response['message'] ?? 'Leave request processed.').toString());

    if (response['status'] == true) {
      _fetchSessions();
    }
  }

  Future<void> _onAccessSession(Map<String, dynamic> session) async {
    final sessionId = (session['_id'] ?? '').toString().trim();
    if (sessionId.isEmpty) {
      Utils.showToast(context, 'Invalid session.');
      return;
    }

    final blockedReason = _accessBlockedReason(session);
    if (blockedReason != null) {
      Utils.showToast(context, blockedReason);
      return;
    }

    setState(() {
      _accessingSessionId = sessionId;
    });

    final bookingId = await _resolveBookingIdForCurrentUser(sessionId);

    if (!mounted) {
      return;
    }

    if ((bookingId ?? '').trim().isEmpty) {
      setState(() {
        _accessingSessionId = null;
      });
      Utils.showToast(context, 'Booking not found for this session.');
      return;
    }

    final accessResponse = await SessionBookingService.getSessionAccess(
      sessionId: sessionId,
      bookingId: bookingId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _accessingSessionId = null;
    });

    if (accessResponse['status'] == true) {
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

      _openGroupCallRoom(
        effectiveSession,
        bookingId: bookingId,
      );
      return;
    }

    Utils.showToast(context,
        (accessResponse['message'] ?? 'Session access denied.').toString());
  }

  String _statusLabel(String rawStatus) {
    final normalized = rawStatus.trim().toLowerCase();
    if (normalized.isEmpty) {
      return '-';
    }

    final words =
        normalized.split('_').where((word) => word.isNotEmpty).map((word) {
      if (word.length == 1) {
        return word.toUpperCase();
      }
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).toList();

    return words.join(' ');
  }

  Color _statusTextColor(String rawStatus) {
    final status = _normalizeStatusValue(rawStatus);
    if (status == 'live') {
      return AppColors.redesignBrandRed;
    }
    if (status == 'scheduled') {
      return AppColors.redesignStatusInfoText;
    }
    return AppColors.redesignMutedText;
  }

  Color _statusBackgroundColor(String rawStatus) {
    final status = _normalizeStatusValue(rawStatus);
    if (status == 'live') {
      return AppColors.redesignAccentSoftBg;
    }
    if (status == 'scheduled') {
      return AppColors.redesignStatusInfoBg;
    }
    return AppColors.redesignSurfaceNeutral;
  }

  Widget _buildAppHeader(int totalSessions) {
    final selectedTypeLabel = _selectedCallType == 'all'
        ? 'All Types'
        : _selectedCallType[0].toUpperCase() + _selectedCallType.substring(1);

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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              Row(
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
                          'Group Sessions',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 20,
                            fontColor: AppColors.redesignBrandDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Join live conversations with experts',
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
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: AppColors.white,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$totalSessions Active Sessions',
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 13,
                              fontColor: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Filter: $selectedTypeLabel',
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 11,
                              fontColor: AppColors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
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

  Widget _buildCallTypeFilterChip(String value, String label) {
    final isSelected = _selectedCallType == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (_selectedCallType == value) {
              return;
            }

            setState(() {
              _selectedCallType = value;
            });

            _fetchSessions();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minWidth: 92),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected ? AppColors.redesignBrandDark : AppColors.white,
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
            child: Text(
              label,
              textAlign: TextAlign.center,
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

  Widget _buildInfoPill({
    required IconData icon,
    required String label,
    required Color textColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppFontStyle.fontStyleW600(
              fontSize: 11,
              fontColor: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 14,
                width: 150,
                decoration: BoxDecoration(
                  color: AppColors.redesignSoftBorder,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 12,
                width: 210,
                decoration: BoxDecoration(
                  color: AppColors.redesignSoftBorder,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: 180,
                decoration: BoxDecoration(
                  color: AppColors.redesignSoftBorder,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                height: 44,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.redesignSoftBorder,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      children: [
        const SizedBox(height: 50),
        Icon(
          Icons.event_busy_outlined,
          size: 54,
          color: AppColors.redesignSoftBorder,
        ),
        const SizedBox(height: 12),
        Text(
          'No active sessions',
          textAlign: TextAlign.center,
          style: AppFontStyle.fontStyleW700(
            fontSize: 20,
            fontColor: AppColors.redesignBrandDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'New group sessions will appear here once experts schedule them.',
          textAlign: TextAlign.center,
          style: AppFontStyle.fontStyleW500(
            fontSize: 13,
            fontColor: AppColors.redesignMutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final sessionId = (session['_id'] ?? '').toString();
    final joined = _isJoinedByCurrentUser(session);
    final joining = _joiningSessionId == sessionId;
    final leaving = _leavingSessionId == sessionId;
    final accessing = _accessingSessionId == sessionId;
    final availableSeats = _availableSeats(session);
    final isFull = availableSeats <= 0;

    final expert = session['expertId'] is Map<String, dynamic>
        ? session['expertId'] as Map<String, dynamic>
        : <String, dynamic>{};

    final sessionStatus = _sessionStatus(session);
    final canJoinNow = _joinBlockedReason(session) == null;
    final canAccessNow = _accessBlockedReason(session) == null;

    final title = (session['title'] ?? 'Group Session').toString().trim();
    final expertName = (expert['displayName'] ?? 'Unknown').toString().trim();
    final isVerifiedExpert = _toBool(expert['isVerifiedBadge']);
    final startDate = _formatDateTime((session['startAt'] ?? '').toString());
    final callType =
        ((session['callType'] ?? 'audio').toString()).trim().toUpperCase();
    final pricingText = _pricingLabel(session);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.isEmpty ? 'Group Session' : title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 15,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusBackgroundColor(sessionStatus),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(sessionStatus),
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 11,
                    fontColor: _statusTextColor(sessionStatus),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: AppColors.redesignMutedText,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Expert: $expertName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 13,
                          fontColor: AppColors.redesignTextMeta,
                        ),
                      ),
                    ),
                    VerifiedBadge(
                      isVerified: isVerifiedExpert,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: AppColors.redesignMutedText,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Start: $startDate',
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 13,
                    fontColor: AppColors.redesignTextMeta,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoPill(
                icon: callType == 'VIDEO'
                    ? Icons.videocam_outlined
                    : Icons.mic_none_rounded,
                label: callType,
                textColor: AppColors.redesignBrandDark,
                backgroundColor: AppColors.redesignSurfaceNeutral,
              ),
              _buildInfoPill(
                icon: Icons.local_activity_outlined,
                label: pricingText,
                textColor: pricingText == 'FREE'
                    ? AppColors.redesignStatusSuccessDark
                    : AppColors.redesignBrandDark,
                backgroundColor: pricingText == 'FREE'
                    ? AppColors.redesignStatusSuccessBg
                    : AppColors.redesignSurfaceNeutral,
              ),
              _buildInfoPill(
                icon: Icons.event_seat_outlined,
                label: '$availableSeats seats',
                textColor: isFull
                    ? AppColors.redesignBrandRed
                    : AppColors.redesignBrandDark,
                backgroundColor: isFull
                    ? AppColors.redesignAccentSoftBg
                    : AppColors.redesignSurfaceNeutral,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!joined)
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: joining ? null : () => _onJoinSessionTap(session),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: canJoinNow
                      ? AppColors.redesignBrandDark
                      : AppColors.redesignSoftBorder,
                  disabledBackgroundColor: AppColors.redesignSoftBorder,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: joining
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _joinButtonLabel(session),
                            maxLines: 1,
                            softWrap: false,
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 14,
                              fontColor: canJoinNow
                                  ? AppColors.white
                                  : AppColors.redesignMutedText,
                            ),
                          ),
                        ),
                      ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed:
                          accessing ? null : () => _onAccessSessionTap(session),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: canAccessNow
                            ? AppColors.redesignBrandDark
                            : AppColors.redesignSoftBorder,
                        disabledBackgroundColor: AppColors.redesignSoftBorder,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: accessing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Access Session',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 13,
                                    fontColor: canAccessNow
                                        ? AppColors.white
                                        : AppColors.redesignMutedText,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed:
                          leaving ? null : () => _onLeaveSession(session),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.redesignBrandDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: leaving
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.redesignBrandDark,
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Leave',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 13,
                                    fontColor: AppColors.redesignBrandDark,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _activeSessions;

    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth =
              constraints.maxWidth >= 760 ? 980.0 : constraints.maxWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                children: [
                  _buildAppHeader(sessions.length),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildCallTypeFilterChip('all', 'All'),
                          _buildCallTypeFilterChip('audio', 'Audio'),
                          _buildCallTypeFilterChip('video', 'Video'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState()
                        : RefreshIndicator(
                            color: AppColors.redesignBrandRed,
                            backgroundColor: AppColors.white,
                            onRefresh: _fetchSessions,
                            child: sessions.isEmpty
                                ? _buildEmptyState()
                                : ListView.separated(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(
                                      parent: BouncingScrollPhysics(),
                                    ),
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 4, 16, 20),
                                    itemCount: sessions.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final dynamic raw = sessions[index];
                                      final session =
                                          raw is Map<String, dynamic>
                                              ? raw
                                              : <String, dynamic>{};

                                      return _buildSessionCard(session);
                                    },
                                  ),
                          ),
                  ),
                ],
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
