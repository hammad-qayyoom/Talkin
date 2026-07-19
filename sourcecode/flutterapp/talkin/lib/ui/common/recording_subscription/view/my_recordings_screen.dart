import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/ui/common/recording_subscription/api/recording_subscription_api.dart';
import 'package:notisboard/ui/common/recording_subscription/model/recording_subscription_model.dart';
import 'package:notisboard/ui/common/recording_subscription/view/recording_subscription_screen.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/ui/common/recording_subscription/view/recording_playback_screen.dart';
import 'package:notisboard/custom/dialog/recording_consent_dialog.dart';

class MyRecordingsScreen extends StatefulWidget {
  const MyRecordingsScreen({super.key});

  @override
  State<MyRecordingsScreen> createState() => _MyRecordingsScreenState();
}

class _MyRecordingsScreenState extends State<MyRecordingsScreen> {
  bool isLoading = true;
  bool isLocked = false;
  String lockReason = "";
  String lockMessage = "";
  List<ConsultationRecordingModel> recordings = [];
  Map<String, dynamic>? subscriptionStatus;
  bool hasActiveSubscription = false;
  String subscriptionInfo = "";
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);

    // Fetch recordings and subscription status in parallel
    final results = await Future.wait([
      RecordingSubscriptionApi.getMyRecordings(),
      RecordingSubscriptionApi.getSubscriptionStatus(),
    ]);

    final res = results[0];
    final subRes = results[1];

    if (res != null && res['status'] == true) {
      isLocked = res['isLocked'] ?? false;
      lockReason = res['lockReason'] ?? "";
      lockMessage = res['message'] ?? "";

      final list = res['recordings'] as List?;
      if (list != null) {
        recordings = list.map((e) => ConsultationRecordingModel.fromJson(e)).toList();
      }
    }

    if (subRes != null && subRes['status'] == true) {
      hasActiveSubscription = subRes['hasSubscription'] ?? false;
      subscriptionStatus = subRes;

      if (hasActiveSubscription) {
        final sub = subRes['subscription'];
        if (sub != null && sub['endsAt'] != null) {
          final endsAt = DateTime.tryParse(sub['endsAt'].toString());
          if (endsAt != null) {
            final daysLeft = endsAt.difference(DateTime.now()).inDays;
            subscriptionInfo = "Active - $daysLeft day${daysLeft == 1 ? '' : 's'} remaining";
          } else {
            subscriptionInfo = "Active Subscription";
          }
        } else {
          subscriptionInfo = "Active Subscription";
        }
      } else {
        subscriptionInfo = "No active subscription";
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> _deleteRecording(ConsultationRecordingModel rec) async {
    final confirmed = await RecordingConsentDialog.show<bool>(
      context: context,
      title: "Delete Recording",
      description: "Are you sure you want to permanently delete this recording? This action cannot be undone.",
      confirmText: "Delete",
      cancelText: "Cancel",
      icon: Icons.delete_rounded,
      onConfirm: () => Navigator.pop(context, true),
      onCancel: () => Navigator.pop(context, false),
    );

    if (confirmed != true || rec.id == null) return;

    setState(() => isDeleting = true);
    final success = await RecordingSubscriptionApi.deleteRecording(rec.id!);
    setState(() => isDeleting = false);

    if (success) {
      setState(() {
        recordings.removeWhere((r) => r.id == rec.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Recording deleted permanently."),
            backgroundColor: AppColors.redesignBrandRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete recording. Please try again."),
            backgroundColor: AppColors.redesignBrandDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.redesignScreenBackground,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.redesignBrandDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Recordings",
          style: AppFontStyle.fontStyleW700(
            fontSize: 18,
            fontColor: AppColors.redesignBrandDark,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.redesignBrandRed))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Subscription status card
        _buildSubscriptionCard(),
        if (isLocked) _buildLockBanner(),
        // Recordings list
        Expanded(
          child: recordings.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic_none_rounded, size: 56, color: AppColors.redesignMutedText),
                        const SizedBox(height: 16),
                        Text(
                          "No recordings yet",
                          style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.redesignBrandDark),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Your consultation recordings will appear here once a session is recorded.",
                          textAlign: TextAlign.center,
                          style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: AppColors.redesignMutedText),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: recordings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final rec = recordings[index];
                    return _buildRecordingCard(rec);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordingSubscriptionScreen()))
            .then((_) => _fetchData());
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.redesignSoftBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasActiveSubscription
                    ? AppColors.redesignBrandRed.withValues(alpha: 0.1)
                    : AppColors.redesignSurfaceInput,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasActiveSubscription ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                color: hasActiveSubscription ? AppColors.redesignBrandRed : AppColors.redesignMutedText,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recording Storage",
                    style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.redesignBrandDark),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subscriptionInfo,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 13,
                      fontColor: hasActiveSubscription ? AppColors.redesignBrandRed : AppColors.redesignMutedText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.redesignBrandRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hasActiveSubscription ? "Manage" : "Subscribe",
                style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.redesignAccentSoftBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.redesignBrandRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_rounded, color: AppColors.redesignBrandRed, size: 20),
              const SizedBox(width: 8),
              Text(
                "Access Locked",
                style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: AppColors.redesignBrandRed),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            lockMessage,
            style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: AppColors.redesignBrandDark, height: 1.4),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redesignBrandRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordingSubscriptionScreen()))
                  .then((_) => _fetchData());
            },
            child: const Text("Renew Subscription", style: TextStyle(color: Colors.white, fontSize: 13)),
          )
        ],
      ),
    );
  }

  Widget _buildRecordingCard(ConsultationRecordingModel rec) {
    final dateStr = rec.recordedAt != null ? DateFormat('MMM dd, yyyy - hh:mm a').format(rec.recordedAt!) : "Unknown Date";
    final isVideo = (rec.callType ?? 'audio').toLowerCase() == 'video';
    final hasUrl = rec.cloudStorageUrl != null && rec.cloudStorageUrl!.isNotEmpty;

    return Opacity(
      opacity: isLocked ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.redesignSoftBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isVideo ? AppColors.redesignStatusInfoBg : AppColors.redesignSurfaceChipAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                color: isVideo ? AppColors.redesignStatusInfoText : AppColors.redesignBrandDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVideo ? "Video Consultation" : "Audio Consultation",
                    style: AppFontStyle.fontStyleW600(fontSize: 15, fontColor: AppColors.redesignBrandDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: AppColors.redesignMutedText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${rec.durationSeconds ?? 0} seconds",
                    style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.redesignMutedText),
                  ),
                ],
              ),
            ),
            // Action buttons
            if (!isLocked && hasUrl)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.play_circle_fill_rounded, color: AppColors.redesignBrandRed, size: 32),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => RecordingPlaybackScreen(
                        title: isVideo ? "Video Consultation" : "Audio Consultation",
                        url: rec.cloudStorageUrl!,
                        isVideo: isVideo,
                      )));
                    },
                  ),
                  IconButton(
                    icon: isDeleting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.redesignMutedText),
                          )
                        : Icon(Icons.delete_outline_rounded, color: AppColors.redesignMutedText, size: 24),
                    onPressed: isDeleting ? null : () => _deleteRecording(rec),
                  ),
                ],
              )
            else if (isLocked)
              Icon(Icons.lock, color: AppColors.redesignMutedText, size: 28)
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message: "Recording not yet uploaded",
                    child: Icon(Icons.cloud_off_rounded, color: AppColors.redesignMutedText, size: 24),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: isDeleting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.redesignMutedText),
                          )
                        : Icon(Icons.delete_outline_rounded, color: AppColors.redesignMutedText, size: 24),
                    onPressed: isDeleting ? null : () => _deleteRecording(rec),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
