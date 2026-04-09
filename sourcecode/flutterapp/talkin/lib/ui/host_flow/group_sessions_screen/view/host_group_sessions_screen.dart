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
          style: AppFontStyle.fontStyleW700(
              fontSize: 18, fontColor: AppColors.black),
        ),
        actions: [
          IconButton(
            onPressed: _isCreating ? null : _createGroupSession,
            icon: _isCreating
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_circle_outline),
            tooltip: 'Create Group Session',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildCallTypeFilterChip('all', 'All'),
                  _buildCallTypeFilterChip('audio', 'Audio'),
                  _buildCallTypeFilterChip('video', 'Video'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredSessions.isEmpty
                      ? Center(
                          child: Text(
                            'No group sessions found.',
                            style: AppFontStyle.fontStyleW500(
                                fontSize: 13, fontColor: AppColors.grey),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchSessions,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _filteredSessions.length,
                            itemBuilder: (context, index) {
                              final session = _filteredSessions[index];
                              final sessionId =
                                  (session['_id'] ?? '').toString();
                              final status = (session['sessionStatus'] ??
                                      session['status'] ??
                                      '')
                                  .toString()
                                  .toLowerCase();
                              final busy = _busySessionId == sessionId;
                              final canCancel =
                                  ['scheduled', 'live'].contains(status);

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
                                      (session['title'] ?? 'Group Session')
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
                                      'Type: ${((session['callType'] ?? 'audio').toString()).toUpperCase()}',
                                      style: AppFontStyle.fontStyleW500(
                                          fontSize: 12,
                                          fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Price: ${_pricingLabel(session)}',
                                      style: AppFontStyle.fontStyleW600(
                                        fontSize: 12,
                                        fontColor:
                                            _pricingLabel(session) == 'FREE'
                                                ? Colors.green
                                                : AppColors.appColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Available Seats: ${_availableSeats(session)}',
                                      style: AppFontStyle.fontStyleW500(
                                          fontSize: 12,
                                          fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Status: $status',
                                      style: AppFontStyle.fontStyleW500(
                                          fontSize: 12,
                                          fontColor: AppColors.black),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        SizedBox(
                                          height: 36,
                                          child: OutlinedButton(
                                            onPressed: busy
                                                ? null
                                                : () => _onViewParticipants(
                                                    session),
                                            child: const Text('Participants'),
                                          ),
                                        ),
                                        if (status == 'scheduled' ||
                                            status == 'live')
                                          SizedBox(
                                            height: 36,
                                            child: ElevatedButton(
                                              onPressed: busy
                                                  ? null
                                                  : () =>
                                                      _onGoLiveSession(session),
                                              child: Text(
                                                status == 'live'
                                                    ? 'Join Live Room'
                                                    : 'Go Live',
                                              ),
                                            ),
                                          ),
                                        if (status == 'live' ||
                                            status == 'scheduled')
                                          SizedBox(
                                            height: 36,
                                            child: ElevatedButton(
                                              onPressed: busy
                                                  ? null
                                                  : () => _onMarkExpertPresence(
                                                        session,
                                                        action: 'end',
                                                      ),
                                              child: busy
                                                  ? const SizedBox(
                                                      height: 16,
                                                      width: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2),
                                                    )
                                                  : const Text('End & Settle'),
                                            ),
                                          ),
                                        if (canCancel)
                                          SizedBox(
                                            height: 36,
                                            child: OutlinedButton(
                                              onPressed: busy
                                                  ? null
                                                  : () =>
                                                      _onCancelSession(session),
                                              child: const Text('Cancel'),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Group Session'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _selectedCallType,
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
              decoration: const InputDecoration(labelText: 'Session Type'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Duration (minutes)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _maxParticipantsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Max Participants'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _pickDateTime,
                child: Text(
                  'Date & Time: ${_formatDateTime(_selectedDateTime)}',
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
