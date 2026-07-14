import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/ui/common/recording_subscription/api/recording_subscription_api.dart';
import 'package:notisboard/ui/common/recording_subscription/model/recording_subscription_model.dart';
import 'package:notisboard/ui/common/recording_subscription/view/recording_subscription_screen.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class MyRecordingsScreen extends StatefulWidget {
  const MyRecordingsScreen({Key? key}) : super(key: key);

  @override
  State<MyRecordingsScreen> createState() => _MyRecordingsScreenState();
}

class _MyRecordingsScreenState extends State<MyRecordingsScreen> {
  bool isLoading = true;
  bool isLocked = false;
  String lockReason = "";
  String lockMessage = "";
  List<ConsultationRecordingModel> recordings = [];

  @override
  void initState() {
    super.initState();
    _fetchRecordings();
  }

  Future<void> _fetchRecordings() async {
    setState(() => isLoading = true);
    final res = await RecordingSubscriptionApi.getMyRecordings();
    if (res != null && res['status'] == true) {
      isLocked = res['isLocked'] ?? false;
      lockReason = res['lockReason'] ?? "";
      lockMessage = res['message'] ?? "";
      
      final list = res['recordings'] as List?;
      if (list != null) {
        recordings = list.map((e) => ConsultationRecordingModel.fromJson(e)).toList();
      }
    }
    setState(() => isLoading = false);
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
          style: AppFontStyle.redesignTextMeta.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.redesignBrandDark),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordingSubscriptionScreen()))
                  .then((_) => _fetchRecordings());
            },
          )
        ],
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: AppColors.redesignBrandRed))
        : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (recordings.isEmpty) {
      return Center(
        child: Text(
          "No recordings found.",
          style: AppFontStyle.redesignMutedText.copyWith(fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        if (isLocked) _buildLockBanner(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
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

  Widget _buildLockBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16).copyWith(bottom: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.redesignAccentSoftBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.redesignBrandRed.withOpacity(0.3)),
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
                style: AppFontStyle.redesignTextStrong.copyWith(color: AppColors.redesignBrandRed, fontWeight: FontWeight.bold),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            lockMessage,
            style: AppFontStyle.redesignTextMeta.copyWith(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redesignBrandRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordingSubscriptionScreen()))
                  .then((_) => _fetchRecordings());
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
                    style: AppFontStyle.redesignTextStrong.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: AppFontStyle.redesignMutedText.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${rec.durationSeconds ?? 0} seconds",
                    style: AppFontStyle.redesignMutedText.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            if (!isLocked && rec.cloudStorageUrl != null)
              IconButton(
                icon: Icon(Icons.play_circle_fill_rounded, color: AppColors.redesignBrandRed, size: 36),
                onPressed: () {
                  // TODO: Implement video/audio playback view
                },
              )
            else if (isLocked)
              Icon(Icons.lock, color: AppColors.redesignMutedText, size: 28),
          ],
        ),
      ),
    );
  }
}
