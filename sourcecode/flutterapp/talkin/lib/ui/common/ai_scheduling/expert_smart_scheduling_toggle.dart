import 'package:flutter/material.dart';
import 'package:notisboard/ui/common/session_booking/ai_scheduling_service.dart';

class ExpertSmartSchedulingToggle extends StatefulWidget {
  final String expertId;
  final bool initialEnabled;
  final ValueChanged<bool>? onChanged;

  const ExpertSmartSchedulingToggle({
    super.key,
    required this.expertId,
    this.initialEnabled = true,
    this.onChanged,
  });

  @override
  State<ExpertSmartSchedulingToggle> createState() => _ExpertSmartSchedulingToggleState();
}

class _ExpertSmartSchedulingToggleState extends State<ExpertSmartSchedulingToggle> {
  late bool _isEnabled;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.initialEnabled;
  }

  Future<void> _toggle(bool value) async {
    setState(() {
      _isLoading = true;
    });

    final result = await AiSchedulingService.toggleExpertSmartScheduling(
      expertId: widget.expertId,
      enabled: value,
    );

    if (!mounted) return;

    if (result['status'] == true) {
      setState(() {
        _isEnabled = value;
        _isLoading = false;
      });
      widget.onChanged?.call(value);
    } else {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((result['message'] ?? 'Failed to update setting.').toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text(
        'Allow AI-Scheduled Appointments',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        _isEnabled
            ? 'Users can see AI-suggested appointment slots when you are offline.'
            : 'Users will see "Expert is offline" when you are not available.',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      value: _isEnabled,
      onChanged: _isLoading ? null : _toggle,
      secondary: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              _isEnabled ? Icons.auto_awesome : Icons.auto_awesome_outlined,
              color: _isEnabled ? Colors.purple : Colors.grey,
            ),
      activeThumbColor: Colors.purple,
    );
  }
}
