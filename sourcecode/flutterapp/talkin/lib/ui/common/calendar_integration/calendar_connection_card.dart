import 'package:flutter/material.dart';
import 'package:notisboard/ui/common/calendar_integration/calendar_service.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class CalendarConnectionCard extends StatefulWidget {
  final Function(List<dynamic>)? onConnectionsLoaded;

  const CalendarConnectionCard({super.key, this.onConnectionsLoaded});

  @override
  State<CalendarConnectionCard> createState() => _CalendarConnectionCardState();
}

class _CalendarConnectionCardState extends State<CalendarConnectionCard> {
  bool _isLoading = true;
  bool _isSyncing = false;
  List<dynamic> _connections = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await CalendarService.getConnections();
    if (!mounted) return;

    if (result['status'] == true) {
      final data = result['data'] ?? {};
      setState(() {
        _isLoading = false;
        _connections = data['connections'] ?? [];
      });
      widget.onConnectionsLoaded?.call(_connections);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = (result['message'] ?? 'Failed to load.').toString();
      });
    }
  }

  Future<void> _syncConnection(String connectionId) async {
    setState(() => _isSyncing = true);
    final result = await CalendarService.triggerSync(connectionId);
    if (!mounted) return;
    setState(() => _isSyncing = false);

    if (result['status'] != true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Sync failed.'),
          backgroundColor: AppColors.redesignBrandRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    _loadConnections();
  }

  Future<void> _disconnect(String connectionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: AppColors.redesignAccentSoftBg,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(Icons.link_off, color: AppColors.redesignBrandRed, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Disconnect Calendar',
                      style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: AppColors.redesignBrandDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to disconnect this calendar? External calendar events will no longer block your availability.',
                style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: AppColors.redesignMutedText, height: 1.45),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.redesignSoftBorder),
                        foregroundColor: AppColors.redesignBrandDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Cancel', style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.redesignBrandDark)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.redesignBrandRed,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Disconnect', style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      final result = await CalendarService.disconnect(connectionId);
      if (!mounted) return;

      if (result['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Calendar disconnected.'),
              backgroundColor: AppColors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']?.toString() ?? 'Failed to disconnect.'),
            backgroundColor: AppColors.redesignBrandRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      _loadConnections();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.redesignSoftBorder),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CircularProgressIndicator(color: AppColors.redesignBrandRed),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.redesignSoftBorder),
        ),
        child: Text(_errorMessage!, style: AppFontStyle.fontStyleW400(fontSize: 13, fontColor: AppColors.redesignBrandRed)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: AppColors.redesignAccentSoftBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calendar_month, size: 16, color: AppColors.redesignBrandRed),
              ),
              const SizedBox(width: 8),
              Text(
                'Calendar Integration',
                style: AppFontStyle.fontStyleW700(fontSize: 17, fontColor: AppColors.redesignBrandDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_connections.isEmpty) ...[
            Text(
              'No calendars connected. Connect a calendar to prevent scheduling conflicts.',
              style: AppFontStyle.fontStyleW400(fontSize: 13, fontColor: AppColors.redesignMutedText, height: 1.4),
            ),
          ] else ...[
            ..._connections.map((conn) => _buildConnectionTile(conn)),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionTile(dynamic connection) {
    final provider = (connection['provider'] ?? '').toString();
    final calendarName = (connection['calendarName'] ?? 'Calendar').toString();
    final syncStatus = (connection['syncStatus'] ?? 'idle').toString();
    final lastSyncedAt = connection['lastSyncedAt']?.toString();
    final connectionId = (connection['_id'] ?? '').toString();

    final isGoogle = provider == 'google';
    final icon = isGoogle ? Icons.g_mobiledata : Icons.apple;
    final statusColor = syncStatus == 'error'
        ? AppColors.redesignBrandRed
        : syncStatus == 'syncing'
            ? AppColors.orange
            : AppColors.redesignStatusSuccess;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.redesignSurfaceSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.redesignBrandDark),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  calendarName,
                  style: AppFontStyle.fontStyleW600(fontSize: 13, fontColor: AppColors.redesignBrandDark),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      height: 6,
                      width: 6,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      syncStatus[0].toUpperCase() + syncStatus.substring(1),
                      style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: AppColors.redesignMutedText),
                    ),
                    if (lastSyncedAt != null) ...[
                      Text(
                        ' · Last sync: ${_formatTimeAgo(lastSyncedAt)}',
                        style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: AppColors.redesignMutedText),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (_isSyncing)
            SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.redesignBrandRed),
            )
          else
            IconButton(
              onPressed: () => _syncConnection(connectionId),
              icon: Icon(Icons.sync, size: 18, color: AppColors.redesignBrandDark),
              tooltip: 'Sync now',
            ),
          IconButton(
            onPressed: () => _disconnect(connectionId),
            icon: Icon(Icons.link_off, size: 18, color: AppColors.redesignBrandRed),
            tooltip: 'Disconnect',
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }
}
