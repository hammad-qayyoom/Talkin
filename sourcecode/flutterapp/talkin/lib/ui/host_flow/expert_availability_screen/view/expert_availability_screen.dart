import 'package:flutter/material.dart';
import 'package:talk_in/ui/common/session_booking/session_booking_service.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class ExpertAvailabilityScreen extends StatefulWidget {
  const ExpertAvailabilityScreen({super.key});

  @override
  State<ExpertAvailabilityScreen> createState() =>
      _ExpertAvailabilityScreenState();
}

class _ExpertAvailabilityScreenState extends State<ExpertAvailabilityScreen> {
  bool _isLoading = false;
  bool _isSaving = false;

  int _selectedDay = DateTime.now().weekday % 7;
  TimeOfDay _selectedStart = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _selectedEnd = const TimeOfDay(hour: 10, minute: 0);

  List<Map<String, dynamic>> _slots = [];

  @override
  void initState() {
    super.initState();
    _loadAvailability();
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

  bool get _isAudioServiceEnabled =>
      Database
          .fetchListenerProfileModel?.data?.isAvailableForPrivateAudioCall !=
      false;

  bool get _isVideoServiceEnabled =>
      Database
          .fetchListenerProfileModel?.data?.isAvailableForPrivateVideoCall !=
      false;

  int get _configuredSlotDurationMinutes {
    final raw = Database.settingApiModel?.data?.sessionSlotDurationMinutes;
    final parsed = int.tryParse((raw ?? 30).toString()) ?? 30;

    if (parsed < 10) {
      return 30;
    }

    if (parsed > 240) {
      return 240;
    }

    return parsed;
  }

  String get _configuredBookingTimezone {
    final raw = (Database.settingApiModel?.data?.sessionBookingTimezone ?? '')
        .toString()
        .trim();
    return raw.isEmpty ? 'UTC' : raw;
  }

  String _buildNormalizedSlotKey(Map<String, dynamic> slot) {
    final day = int.tryParse((slot['dayOfWeek'] ?? '0').toString()) ?? 0;
    final start = int.tryParse((slot['startMinutes'] ?? '0').toString()) ?? 0;
    final end = int.tryParse((slot['endMinutes'] ?? '0').toString()) ?? 0;
    final duration = int.tryParse(
        (slot['slotDurationMinutes'] ?? _configuredSlotDurationMinutes)
          .toString()) ??
      _configuredSlotDurationMinutes;
    final timezone = (slot['timezone'] ?? _configuredBookingTimezone)
      .toString()
      .trim();

    return '${day}_${start}_${end}_${duration}_$timezone';
  }

  Future<void> _loadAvailability() async {
    setState(() {
      _isLoading = true;
    });

    final response = await SessionBookingService.getExpertAvailability(
      listenerId: _listenerId.isEmpty ? null : _listenerId,
    );
    final data = response['data'] as List<dynamic>? ?? [];

    final mergedSlots = <String, Map<String, dynamic>>{};

    for (final slot in data.whereType<Map<String, dynamic>>()) {
      final key = _buildNormalizedSlotKey(slot);
      final existing = mergedSlots[key] ??
          {
            'dayOfWeek':
                int.tryParse((slot['dayOfWeek'] ?? '0').toString()) ?? 0,
            'startMinutes':
                int.tryParse((slot['startMinutes'] ?? '0').toString()) ?? 0,
            'endMinutes':
                int.tryParse((slot['endMinutes'] ?? '0').toString()) ?? 0,
            'slotDurationMinutes': int.tryParse(
                (slot['slotDurationMinutes'] ??
                    _configuredSlotDurationMinutes)
                  .toString()) ??
              _configuredSlotDurationMinutes,
            'timezone':
              (slot['timezone'] ?? _configuredBookingTimezone).toString(),
            'isActive': true,
          };

      mergedSlots[key] = existing;
    }

    final normalized = mergedSlots.values.toList()
      ..sort((a, b) {
        final dayCompare =
            (a['dayOfWeek'] as int).compareTo((b['dayOfWeek'] as int));
        if (dayCompare != 0) {
          return dayCompare;
        }

        return (a['startMinutes'] as int).compareTo((b['startMinutes'] as int));
      });

    if (!mounted) {
      return;
    }

    setState(() {
      _slots = normalized;
      _isLoading = false;
    });

    if (response['status'] != true) {
      Utils.showToast(context,
          (response['message'] ?? 'Failed to fetch availability.').toString());
    }
  }

  int _timeToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  String _dayLabel(int day) {
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return labels[day.clamp(0, 6)];
  }

  String _minutesToTime(int minutes) {
    final hour = (minutes ~/ 60).clamp(0, 23);
    final minute = (minutes % 60).clamp(0, 59);
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  Future<void> _addSlot() async {
    if (!_isAudioServiceEnabled && !_isVideoServiceEnabled) {
      Utils.showToast(
        context,
        'Enable Audio or Video from home screen before adding slots.',
      );
      return;
    }

    final startMinutes = _timeToMinutes(_selectedStart);
    final endMinutes = _timeToMinutes(_selectedEnd);

    if (startMinutes >= endMinutes) {
      Utils.showToast(context, 'End time must be after start time.');
      return;
    }

    final proposedSlot = {
      'dayOfWeek': _selectedDay,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'slotDurationMinutes': _configuredSlotDurationMinutes,
      'timezone': _configuredBookingTimezone,
      'isActive': true,
    };

    final alreadyExists = _slots.any((slot) =>
        _buildNormalizedSlotKey(slot) == _buildNormalizedSlotKey(proposedSlot));

    if (alreadyExists) {
      Utils.showToast(context, 'Same day and time slot already exists.');
      return;
    }

    setState(() {
      _slots.add(proposedSlot);

      _slots.sort((a, b) {
        final dayCompare =
            (a['dayOfWeek'] as int).compareTo((b['dayOfWeek'] as int));
        if (dayCompare != 0) {
          return dayCompare;
        }
        return (a['startMinutes'] as int).compareTo((b['startMinutes'] as int));
      });
    });
  }

  Future<void> _saveAvailability() async {
    if (!_isAudioServiceEnabled && !_isVideoServiceEnabled) {
      Utils.showToast(
        context,
        'Enable Audio or Video from home screen before saving availability.',
      );
      return;
    }

    if (_slots.isEmpty) {
      Utils.showToast(context, 'Add at least one slot before saving.');
      return;
    }

    final payloadSlots = <Map<String, dynamic>>[];

    for (final slot in _slots) {
      if (_isAudioServiceEnabled) {
        payloadSlots.add({
          ...slot,
          'sessionType': 'one_to_one',
          'callType': 'audio',
        });
      }

      if (_isVideoServiceEnabled) {
        payloadSlots.add({
          ...slot,
          'sessionType': 'one_to_one',
          'callType': 'video',
        });
      }
    }

    if (payloadSlots.isEmpty) {
      Utils.showToast(context, 'No valid service type available for slots.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final response = await SessionBookingService.setExpertAvailability(
      listenerId: _listenerId.isEmpty ? null : _listenerId,
      slots: payloadSlots,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    Utils.showToast(
        context, (response['message'] ?? 'Availability updated.').toString());

    if (response['status'] == true) {
      _loadAvailability();
    }
  }

  Future<void> _pickStartTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: _selectedStart);
    if (picked == null) {
      return;
    }

    setState(() {
      _selectedStart = picked;
    });
  }

  Future<void> _pickEndTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: _selectedEnd);
    if (picked == null) {
      return;
    }

    setState(() {
      _selectedEnd = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Manage Availability',
          style: AppFontStyle.fontStyleW700(
              fontSize: 18, fontColor: AppColors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.profileOptionColor,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            key: ValueKey<int>(_selectedDay),
                            initialValue: _selectedDay,
                            decoration: const InputDecoration(labelText: 'Day'),
                            items: List.generate(
                              7,
                              (index) => DropdownMenuItem(
                                value: index,
                                child: Text(_dayLabel(index)),
                              ),
                            ),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _selectedDay = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _isAudioServiceEnabled && _isVideoServiceEnabled
                            ? 'Service Type: General (Audio + Video enabled)'
                            : _isAudioServiceEnabled
                                ? 'Service Type: General (Audio only enabled)'
                                : _isVideoServiceEnabled
                                    ? 'Service Type: General (Video only enabled)'
                                    : 'Service Type: General (enable Audio/Video from home)',
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 12,
                          fontColor: AppColors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Slot duration: $_configuredSlotDurationMinutes min | Booking timezone: $_configuredBookingTimezone',
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 11,
                          fontColor: AppColors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _pickStartTime,
                            child: Text(
                                'Start: ${_selectedStart.format(context)}'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _pickEndTime,
                            child: Text('End: ${_selectedEnd.format(context)}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addSlot,
                        child: const Text('Add Slot'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _slots.isEmpty
                      ? Center(
                          child: Text(
                            'No availability slots yet.',
                            style: AppFontStyle.fontStyleW500(
                                fontSize: 13, fontColor: AppColors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _slots.length,
                          itemBuilder: (context, index) {
                            final slot = _slots[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.profileOptionColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${_dayLabel(slot['dayOfWeek'] as int)} | ${_minutesToTime(slot['startMinutes'] as int)}-${_minutesToTime(slot['endMinutes'] as int)}',
                                      style: AppFontStyle.fontStyleW600(
                                          fontSize: 12,
                                          fontColor: AppColors.black),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _slots.removeAt(index);
                                      });
                                    },
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
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
                  onPressed: _isSaving ? null : _saveAvailability,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Availability'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
