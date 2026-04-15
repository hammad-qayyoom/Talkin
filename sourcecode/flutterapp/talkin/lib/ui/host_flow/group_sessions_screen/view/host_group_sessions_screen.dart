import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/common/session_booking/session_booking_service.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class HostGroupSessionsScreen extends StatefulWidget {
  const HostGroupSessionsScreen({super.key});

  @override
  State<HostGroupSessionsScreen> createState() =>
      _HostGroupSessionsScreenState();
}

class _HostGroupSessionsScreenState extends State<HostGroupSessionsScreen> {
  bool _isLoading = false;
  bool _isCreating = false;

  String _view = 'upcoming';
  String _callTypeFilter = 'all';

  String? _busySessionId;
  List<dynamic> _sessions = [];

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandRedDark = AppColors.redesignBrandRedDark;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _screenBackground = AppColors.redesignScreenBackground;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _chipSurface = AppColors.redesignSurfaceSoft;

  String get _currentUserId {
    return (Database.fetchLoginUserProfileModel?.user?.id ?? '')
        .toString()
        .trim();
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
      mine: true,
      includePast: true,
      status: 'all',
      callType: _callTypeFilter == 'all' ? null : _callTypeFilter,
      start: 1,
      limit: 100,
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
      Utils.showToast(
          context,
          (response['message'] ?? 'Failed to fetch group sessions.')
              .toString());
    }
  }

  List<Map<String, dynamic>> get _filteredSessions {
    final now = DateTime.now();

    return _sessions.whereType<Map<String, dynamic>>().where((session) {
      final status = (session['sessionStatus'] ?? session['status'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

      final endAt =
          DateTime.tryParse((session['endAt'] ?? '').toString())?.toLocal();

      if (_view == 'completed') {
        if (['completed', 'canceled'].contains(status)) {
          return true;
        }

        if (endAt != null && endAt.isBefore(now)) {
          return true;
        }

        return false;
      }

      if (['scheduled', 'live'].contains(status)) {
        if (endAt == null) {
          return true;
        }

        return endAt.isAfter(now);
      }

      return false;
    }).toList();
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

  String _pricingLabel(Map<String, dynamic> session) {
    final pricingMode =
        (session['groupPricingMode'] ?? '').toString().trim().toLowerCase();
    final credits = _toInt(
        session['groupSessionCreditsRequired'], _toInt(session['price'], 0));

    if (pricingMode == 'free' || credits <= 0) {
      return 'FREE';
    }

    return '$credits credits';
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

  Future<void> _onGoLiveSession(Map<String, dynamic> session) async {
    final sessionId = (session['_id'] ?? '').toString().trim();
    if (sessionId.isEmpty) {
      Utils.showToast(context, 'Invalid session.');
      return;
    }

    setState(() {
      _busySessionId = sessionId;
    });

    final joinPresenceResponse =
        await SessionBookingService.markGroupSessionExpertPresence(
      sessionId: sessionId,
      action: 'join',
    );

    if (!mounted) {
      return;
    }

    if (joinPresenceResponse['status'] != true) {
      setState(() {
        _busySessionId = null;
      });
      Utils.showToast(
        context,
        (joinPresenceResponse['message'] ?? 'Failed to start live session.')
            .toString(),
      );
      return;
    }

    final callType =
        (session['callType'] ?? 'audio').toString().trim().toLowerCase() ==
                'video'
            ? 'video'
            : 'audio';
    final route = callType == 'video'
        ? AppRoutes.videoCallScreen
        : AppRoutes.voiceCallScreen;
    final roomId = (session['channelName'] ?? sessionId).toString().trim();
    final sessionTitle = (session['title'] ?? 'Group Session').toString();
    final expertImage =
        (Database.fetchLoginUserProfileModel?.user?.profilePic ?? '')
            .toString();

    setState(() {
      _busySessionId = null;
    });

    await Get.toNamed(
      route,
      arguments: {
        'callerId': _currentUserId,
        'receiverId': sessionId,
        'callType': callType,
        'callerRole': 'listener',
        'receiverRole': 'group',
        'callId': roomId,
        'receiverName': sessionTitle,
        'callerfullName': Database.loginUserName,
        'callerName': Database.loginUserName,
        'receiverImage': '',
        'callerImage': expertImage,
        'isAccept': true,
        'callMode': 'group_session',
        'sessionId': sessionId,
      },
    );

    await SessionBookingService.markGroupSessionExpertPresence(
      sessionId: sessionId,
      action: 'leave',
    );

    if (!mounted) {
      return;
    }

    _fetchSessions();
  }

  Future<void> _createGroupSession() async {
    if (_isCreating) {
      return;
    }

    final payload = await _showCreateGroupSessionDialog();
    if (!mounted || payload == null) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    final response = await SessionBookingService.createGroupSession(
      title: payload.title,
      description: payload.description,
      startAt: payload.startAt,
      durationMinutes: payload.durationMinutes,
      callType: payload.callType,
      maxParticipants: payload.maxParticipants,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isCreating = false;
    });

    Utils.showToast(
      context,
      (response['message'] ?? 'Create group session request processed.')
          .toString(),
    );

    if (response['status'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _fetchSessions();
      });
    }
  }

  Future<_CreateGroupSessionPayload?> _showCreateGroupSessionDialog() async {
    return showDialog<_CreateGroupSessionPayload>(
      context: context,
      builder: (_) {
        return const _CreateGroupSessionDialog();
      },
    );
  }

  Future<void> _onMarkExpertPresence(
    Map<String, dynamic> session, {
    required String action,
  }) async {
    final sessionId = (session['_id'] ?? '').toString().trim();
    if (sessionId.isEmpty) {
      Utils.showToast(context, 'Invalid session.');
      return;
    }

    setState(() {
      _busySessionId = sessionId;
    });

    final response = await SessionBookingService.markGroupSessionExpertPresence(
      sessionId: sessionId,
      action: action,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _busySessionId = null;
    });

    Utils.showToast(context,
        (response['message'] ?? 'Session presence updated.').toString());

    if (response['status'] == true) {
      _fetchSessions();
    }
  }

  Future<void> _onCancelSession(Map<String, dynamic> session) async {
    final sessionId = (session['_id'] ?? '').toString().trim();
    if (sessionId.isEmpty) {
      Utils.showToast(context, 'Invalid session.');
      return;
    }

    setState(() {
      _busySessionId = sessionId;
    });

    final response = await SessionBookingService.cancelGroupSession(
      sessionId: sessionId,
      cancelReason: 'Canceled by expert from app.',
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _busySessionId = null;
    });

    Utils.showToast(context,
        (response['message'] ?? 'Session cancellation updated.').toString());

    if (response['status'] == true) {
      _fetchSessions();
    }
  }

  Future<void> _onViewParticipants(Map<String, dynamic> session) async {
    final sessionId = (session['_id'] ?? '').toString().trim();
    if (sessionId.isEmpty) {
      Utils.showToast(context, 'Invalid session.');
      return;
    }

    final response = await SessionBookingService.getGroupSessionParticipants(
        sessionId: sessionId);

    if (!mounted) {
      return;
    }

    if (response['status'] != true) {
      Utils.showToast(context,
          (response['message'] ?? 'Failed to fetch participants.').toString());
      return;
    }

    final data = response['data'];
    final participants =
        data is Map<String, dynamic> && data['participants'] is List<dynamic>
            ? data['participants'] as List<dynamic>
            : <dynamic>[];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: participants.isEmpty
              ? const SizedBox(
                  height: 180,
                  child: Center(child: Text('No participants yet.')),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final participant =
                        participants[index] is Map<String, dynamic>
                            ? participants[index] as Map<String, dynamic>
                            : <String, dynamic>{};
                    final name = (participant['fullName'] ??
                            participant['nickName'] ??
                            '-')
                        .toString();
                    final status =
                        (participant['bookingStatus'] ?? '').toString();

                    return ListTile(
                      title: Text(name),
                      subtitle: Text('Status: $status'),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: participants.length,
                ),
        );
      },
    );
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

  Widget _buildSegment(String value, String label) {
    final selected = value == _view;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_view == value) return;
          setState(() {
            _view = value;
          });
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

  Widget _buildCallTypeFilterChip(String value, String label) {
    final isSelected = _callTypeFilter == value;

    return GestureDetector(
      onTap: () {
        if (_callTypeFilter == value) {
          return;
        }

        setState(() {
          _callTypeFilter = value;
        });

        _fetchSessions();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: isSelected ? _brandDark : AppColors.redesignPanelBg,
          border: Border.all(
            color: isSelected ? _brandDark : _softBorder,
          ),
        ),
        child: Text(
          label,
          style: AppFontStyle.fontStyleW600(
            fontSize: 11,
            fontColor: isSelected ? AppColors.white : _brandDark,
          ),
        ),
      ),
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

  Widget _buildSessionCard({
    required Map<String, dynamic> session,
    required double cardWidth,
  }) {
    final sessionId = (session['_id'] ?? '').toString();
    final statusRaw =
        (session['sessionStatus'] ?? session['status'] ?? '').toString();
    final status = statusRaw.toLowerCase();
    final statusLabel = _toTitleCase(statusRaw);
    final busy = _busySessionId == sessionId;
    final canCancel = ['scheduled', 'live'].contains(status);
    final canGoLive = ['scheduled', 'live'].contains(status);
    final canEndSettle = ['scheduled', 'live'].contains(status);
    final priceLabel = _pricingLabel(session);
    final isFree = priceLabel == 'FREE';
    final callTypeRaw = (session['callType'] ?? 'audio').toString();
    final callTypeLabel = callTypeRaw.toUpperCase();
    final startAt = _formatDateTime((session['startAt'] ?? '').toString());
    final availableSeats = _availableSeats(session);
    final isNarrowActionLayout = cardWidth < 430;

    Widget participantsButton({bool fullWidth = false}) {
      final button = OutlinedButton.icon(
        onPressed: busy ? null : () => _onViewParticipants(session),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _softBorder),
          foregroundColor: _brandDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.groups_2_outlined, size: 16),
        label: Text(
          'Participants',
          style: AppFontStyle.fontStyleW600(
            fontSize: 12,
            fontColor: _brandDark,
          ),
        ),
      );

      if (!fullWidth) return button;
      return SizedBox(width: double.infinity, height: 42, child: button);
    }

    Widget goLiveButton({bool fullWidth = false}) {
      final button = ElevatedButton.icon(
        onPressed: busy ? null : () => _onGoLiveSession(session),
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
          status == 'live'
              ? Icons.podcasts_rounded
              : Icons.wifi_tethering_rounded,
          size: 16,
        ),
        label: Text(
          status == 'live' ? 'Join Live Room' : 'Go Live',
          style: AppFontStyle.fontStyleW600(
            fontSize: 12,
            fontColor: AppColors.white,
          ),
        ),
      );

      if (!fullWidth) return button;
      return SizedBox(width: double.infinity, height: 42, child: button);
    }

    Widget endSettleButton({bool fullWidth = false}) {
      final button = ElevatedButton.icon(
        onPressed: busy
            ? null
            : () => _onMarkExpertPresence(
                  session,
                  action: 'end',
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
        icon: busy
            ? const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Icon(Icons.task_alt_rounded, size: 16),
        label: Text(
          'End & Settle',
          style: AppFontStyle.fontStyleW600(
            fontSize: 12,
            fontColor: AppColors.white,
          ),
        ),
      );

      if (!fullWidth) return button;
      return SizedBox(width: double.infinity, height: 42, child: button);
    }

    Widget cancelButton({bool fullWidth = false}) {
      final button = OutlinedButton.icon(
        onPressed: busy ? null : () => _onCancelSession(session),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _brandRed.withValues(alpha: 0.5)),
          foregroundColor: _brandRedDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.close_rounded, size: 16),
        label: Text(
          'Cancel',
          style: AppFontStyle.fontStyleW600(
            fontSize: 12,
            fontColor: _brandRedDark,
          ),
        ),
      );

      if (!fullWidth) return button;
      return SizedBox(width: double.infinity, height: 42, child: button);
    }

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
                  (session['title'] ?? 'Group Session').toString(),
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
                  color: _statusBackground(statusRaw),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 9,
                    fontColor: _statusTextColor(statusRaw),
                  ),
                ),
              ),
            ],
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
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Price: $priceLabel',
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 11,
                    fontColor: isFree
                        ? AppColors.redesignStatusSuccessDark
                        : _brandDark,
                  ),
                ),
              ),
              Text(
                'Seats: $availableSeats',
                style: AppFontStyle.fontStyleW500(
                  fontSize: 11,
                  fontColor: _mutedText,
                ),
              ),
            ],
          ),
          if (canGoLive || canEndSettle || canCancel) ...[
            const SizedBox(height: 10),
            if (isNarrowActionLayout)
              Column(
                children: [
                  participantsButton(fullWidth: true),
                  if (canGoLive) ...[
                    const SizedBox(height: 6),
                    goLiveButton(fullWidth: true),
                  ],
                  if (canEndSettle) ...[
                    const SizedBox(height: 6),
                    endSettleButton(fullWidth: true),
                  ],
                  if (canCancel) ...[
                    const SizedBox(height: 6),
                    cancelButton(fullWidth: true),
                  ],
                ],
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(height: 42, child: participantsButton()),
                  if (canGoLive) SizedBox(height: 42, child: goLiveButton()),
                  if (canEndSettle)
                    SizedBox(height: 42, child: endSettleButton()),
                  if (canCancel) SizedBox(height: 42, child: cancelButton()),
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
                  Icons.groups_rounded,
                  size: 32,
                  color: _brandRed,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No group sessions found',
                style: AppFontStyle.fontStyleW700(
                  fontSize: 14,
                  fontColor: _brandDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _view == 'upcoming'
                    ? 'Create a group session to start hosting your audience.'
                    : 'Completed group sessions will appear here.',
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
                ..._filteredSessions.map((session) {
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
                  children: _filteredSessions.map((session) {
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
    final appBarWidth = MediaQuery.sizeOf(context).width;
    final isTabletAppBar = appBarWidth >= 760;

    return Scaffold(
      backgroundColor: _screenBackground,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _screenBackground,
        title: Text(
          'Group Sessions',
          style: AppFontStyle.fontStyleW700(
            fontSize: isTabletAppBar ? 22 : 16,
            fontColor: _brandDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton.icon(
              onPressed: _isCreating ? null : _createGroupSession,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: _brandDark,
              ),
              icon: _isCreating
                  ? const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(
                      Icons.add_rounded,
                      color: AppColors.white,
                      size: 16,
                    ),
              label: Text(
                'Create',
                style: AppFontStyle.fontStyleW600(
                  fontSize: 12,
                  fontColor: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, viewportConstraints) {
          final viewportWidth = viewportConstraints.maxWidth;
          final maxContentWidth =
              viewportWidth >= 1400 ? 1280.0 : double.infinity;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: LayoutBuilder(
                builder: (context, contentConstraints) {
                  final width = contentConstraints.maxWidth;
                  final isTablet = width >= 760;
                  final horizontalInset = width >= 1100
                      ? 28.0
                      : isTablet
                          ? 22.0
                          : 16.0;
                  final heroSubtitle = _view == 'upcoming'
                      ? 'Track and control your upcoming group sessions'
                      : 'Review completed group sessions';

                  return SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalInset,
                            4,
                            horizontalInset,
                            8,
                          ),
                          child: Container(
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
                                    Icons.groups_rounded,
                                    color: _brandRed,
                                    size: isTablet ? 21 : 19,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Group Session Desk',
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
                                    horizontal: 9,
                                    vertical: 6,
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
                                        '${_filteredSessions.length}',
                                        style: AppFontStyle.fontStyleW700(
                                          fontSize: isTablet ? 15 : 13,
                                          fontColor: AppColors.white,
                                        ),
                                      ),
                                      Text(
                                        _view == 'upcoming'
                                            ? 'Upcoming'
                                            : 'Done',
                                        style: AppFontStyle.fontStyleW500(
                                          fontSize: 8,
                                          fontColor: AppColors.white
                                              .withValues(alpha: 0.9),
                                        ),
                                      ),
                                    ],
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
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalInset,
                            0,
                            horizontalInset,
                            6,
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
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

class _CreateGroupSessionPayload {
  final String title;
  final String description;
  final DateTime startAt;
  final int durationMinutes;
  final String callType;
  final int maxParticipants;

  const _CreateGroupSessionPayload({
    required this.title,
    required this.description,
    required this.startAt,
    required this.durationMinutes,
    required this.callType,
    required this.maxParticipants,
  });
}

class _CreateGroupSessionDialog extends StatefulWidget {
  const _CreateGroupSessionDialog();

  @override
  State<_CreateGroupSessionDialog> createState() =>
      _CreateGroupSessionDialogState();
}

class _CreateGroupSessionDialogState extends State<_CreateGroupSessionDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;
  late final TextEditingController _maxParticipantsController;

  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  String _selectedCallType = 'audio';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _durationController = TextEditingController(text: '30');
    _maxParticipantsController = TextEditingController(text: '10');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      useRootNavigator: true,
    );

    if (!mounted || pickedDate == null) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (!mounted || pickedTime == null) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final durationMinutes = int.tryParse(_durationController.text.trim()) ?? 30;
    final maxParticipants =
        int.tryParse(_maxParticipantsController.text.trim()) ?? 10;

    if (title.isEmpty) {
      Utils.showToast(context, 'Title is required.');
      return;
    }

    Navigator.of(context).pop(
      _CreateGroupSessionPayload(
        title: title,
        description: description,
        startAt: _selectedDateTime,
        durationMinutes: durationMinutes,
        callType: _selectedCallType,
        maxParticipants: maxParticipants,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppFontStyle.fontStyleW500(
        fontSize: 12,
        fontColor: AppColors.redesignMutedText,
      ),
      filled: true,
      fillColor: AppColors.redesignSurfaceInput,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.redesignSoftBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.redesignBrandRed),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.redesignSoftBorder),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: AppFontStyle.fontStyleW600(
          fontSize: 12,
          fontColor: AppColors.redesignMutedText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.redesignSoftBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.12),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: AppColors.redesignAccentSoftBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.add_box_outlined,
                        size: 20,
                        color: AppColors.redesignBrandRed,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Group Session',
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 20,
                              fontColor: AppColors.redesignBrandDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Set title, type, duration and start time',
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 11,
                              fontColor: AppColors.redesignMutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 18,
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.redesignMutedText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _fieldLabel('Title'),
                TextField(
                  controller: _titleController,
                  decoration: _inputDecoration('Session title'),
                ),
                const SizedBox(height: 10),
                _fieldLabel('Description'),
                TextField(
                  controller: _descriptionController,
                  decoration: _inputDecoration('Write short description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                _fieldLabel('Session Type'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCallType,
                  isExpanded: true,
                  decoration: _inputDecoration('Select type'),
                  items: const [
                    DropdownMenuItem(
                      value: 'audio',
                      child: Text('Audio'),
                    ),
                    DropdownMenuItem(
                      value: 'video',
                      child: Text('Video'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCallType = value == 'video' ? 'video' : 'audio';
                    });
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Duration (minutes)'),
                          TextField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('30'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Max Participants'),
                          TextField(
                            controller: _maxParticipantsController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('10'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _pickDateTime,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.redesignSoftBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: Icon(
                      Icons.event_rounded,
                      size: 16,
                      color: AppColors.redesignBrandDark,
                    ),
                    label: Text(
                      _formatDateTime(_selectedDateTime),
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 13,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.redesignBrandRed
                                  .withValues(alpha: 0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 14,
                              fontColor: AppColors.redesignBrandRedDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.redesignBrandDark,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Create',
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 14,
                              fontColor: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
