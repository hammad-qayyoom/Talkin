import 'dart:developer';

import 'package:get/get.dart';
import 'package:talk_in/ui/common/session_booking/session_booking_service.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/api/listener_profile_api.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/api/listener_review_api.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/model/listener_profile_response_model.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/model/listener_review_model.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';

class ProfileDetailScreenController extends GetxController {
  String? listenerId;
  String? expertId;
  bool isLoading = false;
  bool isBackProfile = true;
  bool isToastVisible = false;
  bool isSlotsPreviewLoading = false;
  ListenerReviewModel? listenerReviewModel;
  List<Review>? reviews = [];
  List<Map<String, dynamic>> audioSlotsPreview = [];
  List<Map<String, dynamic>> videoSlotsPreview = [];

  ListenerProfileModel? listenerProfileModel;
  final List<Map<String, String>> statsList = [
    {
      'image': AppAsset.callGradiant,
      'title': EnumLocale.txtTotalCall.name.tr,
      'count': '',
    },
    {
      'image': AppAsset.starRating,
      'title': EnumLocale.txtRating.name.tr,
      'count': '',
    },
    {
      'image': AppAsset.experience,
      'title': EnumLocale.txtExperience.name.tr,
      'count': '',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      listenerId =
          (args['listenerId'] ?? args['id'] ?? args['_id'] ?? '').toString();
      expertId = (args['expertId'] ?? '').toString();
    } else {
      final routeId = (args ?? '').toString();
      listenerId = routeId;
      expertId = routeId;
    }
    listenerId = listenerId?.trim();
    expertId = expertId?.trim();
    log("Received listenerId: $listenerId");
    log("Received expertId: $expertId");
    listenerProfile();
    listenerReview();
    fetchAvailabilityPreview();
  }

  /// listener profile
  Future<void> listenerProfile() async {
    try {
      isLoading = true;
      update([Constant.listenerProfile]);

      final listenerCandidate = (listenerId ?? '').trim();
      final expertCandidate = (expertId ?? '').trim();

      ListenerProfileModel? data;

      if (listenerCandidate.isNotEmpty) {
        data = await ListenerProfileApi.callApi(listenerId: listenerCandidate);
      }

      var hasResolvedData = data?.status == true && data?.data != null;

      if (!hasResolvedData && expertCandidate.isNotEmpty) {
        data = await ListenerProfileApi.callApi(expertId: expertCandidate);
      }

      hasResolvedData = data?.status == true && data?.data != null;

      // If route ID source is unknown, try the opposite interpretation.
      if (!hasResolvedData && listenerCandidate.isNotEmpty) {
        data = await ListenerProfileApi.callApi(expertId: listenerCandidate);
      }

      hasResolvedData = data?.status == true && data?.data != null;

      if (!hasResolvedData && expertCandidate.isNotEmpty) {
        data = await ListenerProfileApi.callApi(listenerId: expertCandidate);
      }

      listenerProfileModel = data;

      final resolvedListenerId =
          (listenerProfileModel?.data?.id ?? '').toString().trim();
      if (resolvedListenerId.isNotEmpty) {
        listenerId = resolvedListenerId;
      }

      statsList[0]['count'] =
          listenerProfileModel?.data?.callCount?.toString() ?? '0';
      statsList[1]['count'] =
          listenerProfileModel?.data?.rating?.toStringAsFixed(1) ?? '0.0';
      statsList[2]['count'] = listenerProfileModel?.data?.experience == null
          ? '0+'
          : '${listenerProfileModel?.data?.experience}+';
    } catch (e) {
      log('Error fetching Listener profile api: $e');
    } finally {
      isLoading = false;
      update([Constant.listenerProfile]);
    }
  }

  /// get listener review
  Future<void> listenerReview() async {
    isLoading = true;
    update([Constant.idGetListenerReview]);

    final listenerCandidate = (listenerId ?? '').trim();
    final expertCandidate = (expertId ?? '').trim();

    listenerReviewModel = await ListenerReviewApi.callApi(
      listenerId: listenerCandidate,
      expertId: expertCandidate,
    );

    if ((listenerReviewModel?.status != true) && expertCandidate.isNotEmpty) {
      listenerReviewModel = await ListenerReviewApi.callApi(
        listenerId: '',
        expertId: expertCandidate,
      );
    }

    reviews?.clear();
    reviews?.addAll(listenerReviewModel?.reviews ?? []);

    isLoading = false;
    update([Constant.idGetListenerReview]);
  }

  Future<void> fetchAvailabilityPreview() async {
    final id = (listenerId ?? '').toString().trim();
    if (id.isEmpty) {
      return;
    }

    isSlotsPreviewLoading = true;
    update([Constant.listenerProfile]);

    try {
      audioSlotsPreview = await _collectSlotsForType(
        listenerId: id,
        callType: 'audio',
      );
      videoSlotsPreview = await _collectSlotsForType(
        listenerId: id,
        callType: 'video',
      );
    } catch (_) {
      audioSlotsPreview = [];
      videoSlotsPreview = [];
    } finally {
      isSlotsPreviewLoading = false;
      update([Constant.listenerProfile]);
    }
  }

  Future<List<Map<String, dynamic>>> _collectSlotsForType({
    required String listenerId,
    required String callType,
  }) async {
    final List<Map<String, dynamic>> collected = [];

    for (int dayOffset = 0;
        dayOffset < 7 && collected.length < 4;
        dayOffset++) {
      final date = DateTime.now().add(Duration(days: dayOffset));
      final response = await SessionBookingService.getAvailableSlots(
        listenerId: listenerId,
        date: DateTime(date.year, date.month, date.day),
        callType: callType,
      );

      if (response['status'] != true) {
        continue;
      }

      final data = response['data'];
      final slotsRaw = data is Map<String, dynamic>
          ? (data['slots'] as List<dynamic>? ?? [])
          : <dynamic>[];

      for (final slot in slotsRaw) {
        if (slot is! Map<String, dynamic>) {
          continue;
        }

        collected.add(slot);
        if (collected.length >= 4) {
          break;
        }
      }
    }

    return collected;
  }

  String formatSlotLabel(Map<String, dynamic> slot) {
    final startAt =
        DateTime.tryParse((slot['startAt'] ?? '').toString())?.toLocal();
    final endAt =
        DateTime.tryParse((slot['endAt'] ?? '').toString())?.toLocal();

    if (startAt == null || endAt == null) {
      return 'No slot';
    }

    String twoDigit(int value) => value.toString().padLeft(2, '0');

    return '${twoDigit(startAt.day)}/${twoDigit(startAt.month)} ${twoDigit(startAt.hour)}:${twoDigit(startAt.minute)} - ${twoDigit(endAt.hour)}:${twoDigit(endAt.minute)}';
  }

  Future<void> onRefresh() async {
    await listenerProfile();
    await listenerReview();
    await fetchAvailabilityPreview();
  }
}
