import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/common/session_booking/session_booking_service.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class UserGroupSessionsScreen extends StatefulWidget {
  const UserGroupSessionsScreen({super.key});

  @override
  State<UserGroupSessionsScreen> createState() => _UserGroupSessionsScreenState();
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
    return (Database.fetchLoginUserProfileModel?.user?.id ?? '').toString().trim();
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

    final fetchedSessions = response['data'] is List<dynamic>
        ? response['data'] as List<dynamic>
        : <dynamic>[];

    setState(() {
      _sessions = fetchedSessions;
      _isLoading = false;
    });

    if (response['status'] != true) {
      Utils.showToast(context, (response['message'] ?? 'Failed to fetch group sessions.').toString());
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

  bool _isJoinedByCurrentUser(Map<String, dynamic> session) {
    return session['isBookedByCurrentUser'] == true;
  }

  String _pricingLabel(Map<String, dynamic> session) {
    final pricingMode = (session['groupPricingMode'] ?? '').toString().trim().toLowerCase();
    final sessionCredits = _toInt(session['groupSessionCreditsRequired'], -1);
    final fallbackPrice = _toInt(session['price'], 0);
    final effectiveCredits = sessionCredits >= 0 ? sessionCredits : fallbackPrice;

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

  List<Map<String, dynamic>> get _activeSessions {
    final now = DateTime.now();

    return _sessions.whereType<Map<String, dynamic>>().where((session) {
      final status =
          (session['sessionStatus'] ?? session['status'] ?? '').toString().trim().toLowerCase();

      if (!['scheduled', 'live'].contains(status)) {
        return false;
      }

      final endAt = DateTime.tryParse((session['endAt'] ?? '').toString())?.toLocal();
      if (endAt != null && endAt.isBefore(now)) {
        return false;
      }

      return true;
    }).toList();
  }

  void _openGroupCallRoom(Map<String, dynamic> session, {String? bookingId}) {
    final sessionId = (session['_id'] ?? '').toString().trim();
    final roomId = (session['channelName'] ?? sessionId).toString().trim();
    final callType = (session['callType'] ?? 'audio').toString().trim().toLowerCase() == 'video'
        ? 'video'
        : 'audio';

    final expert = session['expertId'] is Map<String, dynamic>
        ? session['expertId'] as Map<String, dynamic>
        : <String, dynamic>{};

    final expertId =
        (expert['userId'] ?? expert['_id'] ?? session['expertId'] ?? '').toString().trim();
    final expertName = (expert['displayName'] ?? session['title'] ?? 'Group Host').toString().trim();
    final expertImage = (expert['profilePic'] ?? '').toString();

    final route = callType == 'video' ? AppRoutes.videoCallScreen : AppRoutes.voiceCallScreen;

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
        await SessionBookingService.getGroupSessionParticipants(sessionId: sessionId);

    if (participantsResponse['status'] != true) {
      return null;
    }

    final data = participantsResponse['data'];
    final participants = data is Map<String, dynamic> && data['participants'] is List<dynamic>
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

    Utils.showToast(context, (response['message'] ?? 'Join request processed.').toString());

    if (response['status'] == true) {
      final booking = response['data'];
      if (booking is Map<String, dynamic>) {
        final bookingId = (booking['_id'] ?? '').toString().trim();
        if (bookingId.isNotEmpty) {
          _bookingIdBySessionId[sessionId] = bookingId;
        }
      }

      final sessionStatus =
          (session['sessionStatus'] ?? session['status'] ?? '').toString().trim().toLowerCase();
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

    Utils.showToast(context, (response['message'] ?? 'Leave request processed.').toString());

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
      _openGroupCallRoom(session, bookingId: bookingId);
      return;
    }

    Utils.showToast(context, (accessResponse['message'] ?? 'Session access denied.').toString());
  }

  Widget _buildCallTypeFilterChip(String value, String label) {
    final isSelected = _selectedCallType == value;

    return GestureDetector(
      onTap: () {
        if (_selectedCallType == value) {
          return;
        }

        setState(() {
          _selectedCallType = value;
        });

        _fetchSessions();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? AppColors.appColor : AppColors.profileOptionColor,
        ),
        child: Text(
          label,
          style: AppFontStyle.fontStyleW600(
            fontSize: 12,
            fontColor: isSelected ? AppColors.white : AppColors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Group Sessions',
          style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: AppColors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  _buildCallTypeFilterChip('all', 'All'),
                  _buildCallTypeFilterChip('audio', 'Audio'),
                  _buildCallTypeFilterChip('video', 'Video'),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _activeSessions.isEmpty
                      ? Center(
                          child: Text(
                            'No active group sessions found.',
                            style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: AppColors.grey),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchSessions,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _activeSessions.length,
                            itemBuilder: (context, index) {
                              final dynamic raw = _activeSessions[index];
                              final session = raw is Map<String, dynamic>
                                  ? raw
                                  : <String, dynamic>{};

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

                              final sessionStatus =
                                  (session['sessionStatus'] ?? session['status'] ?? '').toString().trim().toLowerCase();
                                final isJoinable = ['scheduled', 'live'].contains(sessionStatus) && !isFull;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: AppColors.profileOptionColor,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (session['title'] ?? 'Group Session').toString(),
                                      style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Expert: ${(expert['displayName'] ?? 'Unknown').toString()}',
                                      style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Start: ${_formatDateTime((session['startAt'] ?? '').toString())}',
                                      style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Type: ${((session['callType'] ?? 'audio').toString()).toUpperCase()}',
                                      style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Price: ${_pricingLabel(session)}',
                                      style: AppFontStyle.fontStyleW600(
                                        fontSize: 12,
                                        fontColor: _pricingLabel(session) == 'FREE' ? Colors.green : AppColors.appColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Available Seats: $availableSeats',
                                      style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Status: ${sessionStatus.isEmpty ? '-' : sessionStatus}',
                                      style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 10),
                                    if (!joined)
                                      SizedBox(
                                        width: double.infinity,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: joining || !isJoinable ? null : () => _onJoinSession(session),
                                          child: joining
                                              ? const SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                )
                                              : Text(isJoinable ? 'Join Session' : 'Session Unavailable'),
                                        ),
                                      )
                                    else
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 40,
                                              child: ElevatedButton(
                                                onPressed: accessing ? null : () => _onAccessSession(session),
                                                child: accessing
                                                    ? const SizedBox(
                                                        height: 18,
                                                        width: 18,
                                                        child: CircularProgressIndicator(strokeWidth: 2),
                                                      )
                                                    : const Text('Access Session'),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: SizedBox(
                                              height: 40,
                                              child: OutlinedButton(
                                                onPressed: leaving ? null : () => _onLeaveSession(session),
                                                child: leaving
                                                    ? const SizedBox(
                                                        height: 18,
                                                        width: 18,
                                                        child: CircularProgressIndicator(strokeWidth: 2),
                                                      )
                                                    : const Text('Leave'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
