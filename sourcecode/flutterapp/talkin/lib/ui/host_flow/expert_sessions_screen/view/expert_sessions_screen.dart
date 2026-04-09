import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/common/session_booking/session_booking_service.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

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
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected ? AppColors.appColor : AppColors.profileOptionColor,
          ),
          child: Center(
            child: Text(
              label,
              style: AppFontStyle.fontStyleW600(
                fontSize: 12,
                fontColor: selected ? AppColors.white : AppColors.black,
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

    final firstBooking = bookings.isNotEmpty && bookings.first is Map<String, dynamic>
        ? bookings.first as Map<String, dynamic>
        : <String, dynamic>{};

    final bookingId = (firstBooking['bookingId'] ?? '').toString();
    final userId = (firstBooking['userId'] ?? '').toString();
    final userName = (firstBooking['userName'] ?? 'User').toString();
    final userProfilePic = (firstBooking['userProfilePic'] ?? '').toString();
    final sessionCallType = (session['callType'] ?? '').toString();
    final sessionEndAt = (session['endAt'] ?? '').toString();

    if (bookingId.isEmpty || userId.isEmpty) {
      Utils.showToast(context, 'No confirmed user booking found for this session.');
      return;
    }

    await Get.toNamed(
      AppRoutes.hostPersonalChatScreen,
      arguments: [
        userId,
        userName,
        'Available',
        userProfilePic,
        sessionId,
        bookingId,
        sessionCallType,
        sessionEndAt,
      ],
    );

    if (mounted) {
      _fetchSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'My Sessions',
          style: AppFontStyle.fontStyleW700(
              fontSize: 18, fontColor: AppColors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(AppRoutes.hostGroupSessionsScreen);
            },
            icon: const Icon(Icons.groups_outlined),
            tooltip: 'Group Sessions',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildSegment('upcoming', 'Upcoming'),
                  const SizedBox(width: 8),
                  _buildSegment('completed', 'Completed'),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _sessions.isEmpty
                      ? Center(
                          child: Text(
                            'No sessions found.',
                            style: AppFontStyle.fontStyleW500(
                                fontSize: 13, fontColor: AppColors.grey),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchSessions,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _sessions.length,
                            itemBuilder: (context, index) {
                              final session =
                                  _sessions[index] is Map<String, dynamic>
                                      ? _sessions[index] as Map<String, dynamic>
                                      : <String, dynamic>{};
                              final bookings =
                                  session['bookings'] is List<dynamic>
                                      ? session['bookings'] as List<dynamic>
                                      : const <dynamic>[];
                              final firstBooking = bookings.isNotEmpty &&
                                      bookings.first is Map<String, dynamic>
                                  ? bookings.first as Map<String, dynamic>
                                  : <String, dynamic>{};
                              final bookedUser =
                                  (firstBooking['userName'] ?? '-').toString();
                              final bookingStatus =
                                  (firstBooking['bookingStatus'] ?? '-')
                                      .toString();
                              final sessionId =
                                  (session['_id'] ?? '').toString();
                              final sessionStatus = (session['sessionStatus'] ??
                                      session['status'] ??
                                      '')
                                  .toString();
                              final canCancel = _view == 'upcoming' &&
                                  sessionStatus.toLowerCase() != 'canceled';
                                final accessWindow =
                                  session['accessWindow'] is Map<String, dynamic>
                                    ? session['accessWindow']
                                      as Map<String, dynamic>
                                    : const <String, dynamic>{};
                                final canStartSession = _view == 'upcoming' &&
                                  bookingStatus.toLowerCase() == 'confirmed' &&
                                  accessWindow['allowed'] == true;
                              final isCancellingThis =
                                  _cancellingSessionId == sessionId;

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
                                      (session['title'] ?? 'Session')
                                          .toString(),
                                      style: AppFontStyle.fontStyleW700(
                                          fontSize: 14,
                                          fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Start: ${_formatDateTime((session['startAt'] ?? '').toString())}',
                                      style: AppFontStyle.fontStyleW500(
                                          fontSize: 12,
                                          fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Type: ${((session['callType'] ?? '').toString()).toUpperCase()}',
                                      style: AppFontStyle.fontStyleW500(
                                          fontSize: 12,
                                          fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Confirmed Bookings: ${(session['confirmedBookings'] ?? 0).toString()}',
                                      style: AppFontStyle.fontStyleW500(
                                          fontSize: 12,
                                          fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Booked User: $bookedUser',
                                      style: AppFontStyle.fontStyleW500(
                                          fontSize: 12,
                                          fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Booking Status: $bookingStatus',
                                      style: AppFontStyle.fontStyleW500(
                                          fontSize: 12,
                                          fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Status: $sessionStatus',
                                      style: AppFontStyle.fontStyleW600(
                                          fontSize: 12,
                                          fontColor: AppColors.appColor),
                                    ),
                                    if (canStartSession) ...[
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: () => _onStartSession(session),
                                          child: const Text('Start Session'),
                                        ),
                                      ),
                                    ],
                                    if (canCancel) ...[
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 40,
                                        child: OutlinedButton(
                                          onPressed: isCancellingThis
                                              ? null
                                              : () => _onCancelSession(session),
                                          child: isCancellingThis
                                              ? const SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                )
                                              : const Text('Cancel Session'),
                                        ),
                                      ),
                                    ],
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
