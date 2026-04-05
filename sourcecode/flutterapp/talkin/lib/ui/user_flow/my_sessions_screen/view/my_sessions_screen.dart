import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/common/session_booking/session_booking_service.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class UserMySessionsScreen extends StatefulWidget {
  const UserMySessionsScreen({super.key});

  @override
  State<UserMySessionsScreen> createState() => _UserMySessionsScreenState();
}

class _UserMySessionsScreenState extends State<UserMySessionsScreen> {
  String _view = 'upcoming';
  bool _isLoading = false;
  List<dynamic> _sessions = [];
  Timer? _autoRefreshTimer;
  String? _cancellingBookingId;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) {
        _fetchSessions();
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchSessions() async {
    final userId =
        (Database.fetchLoginUserProfileModel?.user?.id ?? '').toString();

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

    setState(() {
      _isLoading = false;
      _sessions = (response['data'] as List<dynamic>? ?? []);
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
    final sessionEndAt = (session['endAt'] ?? '').toString();
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

    final listenerId = (expert['legacyListenerId'] ?? '').toString();
    if (listenerId.isEmpty) {
      Utils.showToast(
          context, 'Unable to start session. Expert is unavailable.');
      return;
    }

    final expertName = (expert['displayName'] ?? 'Expert').toString();
    final sessionCallType =
        (session['callType'] ?? '').toString().trim().toLowerCase();
    final isVideoSession = sessionCallType == 'video';
    final sessionPrice = num.tryParse((session['price'] ?? 0).toString()) ?? 0;

    await Get.toNamed(
      AppRoutes.personalChatScreen,
      arguments: [
        listenerId,
        expertName,
        'Available',
        '',
        isVideoSession ? 0 : sessionPrice,
        isVideoSession ? sessionPrice : 0,
        false,
        const [],
        isVideoSession,
        !isVideoSession,
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                _buildSegment('upcoming', 'Upcoming'),
                const SizedBox(width: 8),
                _buildSegment('completed', 'Completed'),
              ],
            ).paddingAll(12),
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
                            padding: const EdgeInsets.all(12),
                            itemCount: _sessions.length,
                            itemBuilder: (context, index) {
                              final item =
                                  _sessions[index] is Map<String, dynamic>
                                      ? _sessions[index] as Map<String, dynamic>
                                      : <String, dynamic>{};
                              final session = item['session']
                                      is Map<String, dynamic>
                                  ? item['session'] as Map<String, dynamic>
                                  : item['sessionId'] is Map<String, dynamic>
                                      ? item['sessionId']
                                          as Map<String, dynamic>
                                      : <String, dynamic>{};
                              final expert = session['expertId']
                                      is Map<String, dynamic>
                                  ? session['expertId'] as Map<String, dynamic>
                                  : <String, dynamic>{};

                              final callType = (session['callType'] ?? '')
                                  .toString()
                                  .toUpperCase();
                              final status = (session['sessionStatus'] ??
                                      session['status'] ??
                                      '')
                                  .toString();
                              final canStart = item['canStartSession'] == true;
                              final showStartSession = _view == 'upcoming';
                              final bookingId = (item['_id'] ?? '').toString();
                              final isCancellingThis =
                                  _cancellingBookingId == bookingId;

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
                                      'Expert: ${(expert['displayName'] ?? 'Unknown').toString()}',
                                      style: AppFontStyle.fontStyleW500(
                                          fontSize: 12,
                                          fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Start: ${_formatDateTime((session['startAt'] ?? '').toString())}',
                                      style: AppFontStyle.fontStyleW500(
                                          fontSize: 12,
                                          fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Type: $callType',
                                      style: AppFontStyle.fontStyleW500(
                                          fontSize: 12,
                                          fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Status: $status',
                                      style: AppFontStyle.fontStyleW600(
                                          fontSize: 12,
                                          fontColor: AppColors.appColor),
                                    ),
                                    if (showStartSession) ...[
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 40,
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    _onStartSession(
                                                        item, session, expert),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: canStart
                                                      ? AppColors.appColor
                                                      : AppColors.lightGrey1,
                                                  foregroundColor:
                                                      AppColors.white,
                                                ),
                                                child: Text(canStart
                                                    ? 'Start Session'
                                                    : 'Session not started yet'),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: SizedBox(
                                              height: 40,
                                              child: OutlinedButton(
                                                onPressed: isCancellingThis
                                                    ? null
                                                    : () => _onCancelBooking(
                                                        item, session),
                                                child: isCancellingThis
                                                    ? const SizedBox(
                                                        height: 18,
                                                        width: 18,
                                                        child:
                                                            CircularProgressIndicator(
                                                                strokeWidth: 2),
                                                      )
                                                    : const Text(
                                                        'Cancel Booking'),
                                              ),
                                            ),
                                          ),
                                        ],
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
