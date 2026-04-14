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
  ListenerReviewModel? listenerReviewModel;
  List<Review>? reviews = [];

  ListenerProfileModel? listenerProfileModel;
  final List<Map<String, String>> statsList = [
    {
      'image': AppAsset.callGradiant,
      'title': 'Completed Sessions',
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

      final completedSessionsCount = await _fetchCompletedSessionCount(
        listenerCandidate: listenerCandidate,
        expertCandidate: expertCandidate,
        resolvedListenerId: resolvedListenerId,
      );

      statsList[0]['count'] = completedSessionsCount.toString();
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

  Future<void> onRefresh() async {
    await listenerProfile();
    await listenerReview();
  }

  Future<int> _fetchCompletedSessionCount({
    required String listenerCandidate,
    required String expertCandidate,
    required String resolvedListenerId,
  }) async {
    final profileFallback = listenerProfileModel?.data?.completedSessionCount ??
        listenerProfileModel?.data?.callCount ??
        0;

    final candidateListenerIds = <String>{
      resolvedListenerId.trim(),
      listenerCandidate.trim(),
      (listenerId ?? '').trim(),
    }..removeWhere((value) => value.isEmpty);

    final candidateExpertIds = <String>{
      expertCandidate.trim(),
      (expertId ?? '').trim(),
    }..removeWhere((value) => value.isEmpty);

    for (final candidate in candidateListenerIds) {
      final response = await SessionBookingService.getExpertSessions(
        listenerId: candidate,
        view: 'completed',
      );

      final parsed = _extractCompletedSessionCount(response);
      if (parsed != null) {
        return parsed;
      }
    }

    for (final candidate in candidateExpertIds) {
      final response = await SessionBookingService.getExpertSessions(
        expertId: candidate,
        view: 'completed',
      );

      final parsed = _extractCompletedSessionCount(response);
      if (parsed != null) {
        return parsed;
      }
    }

    return profileFallback;
  }

  int? _extractCompletedSessionCount(Map<String, dynamic> response) {
    int? parse(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    final topLevelCount = parse(response['completedSessionCount']) ??
        parse(response['totalCompletedSessions']) ??
        parse(response['completedSessions']) ??
        parse(response['totalCount']) ??
        parse(response['count']);

    if (topLevelCount != null) {
      return topLevelCount;
    }

    final data = response['data'];

    if (data is List) {
      return data.length;
    }

    if (data is Map<String, dynamic>) {
      final nestedCount = parse(data['completedSessionCount']) ??
          parse(data['totalCompletedSessions']) ??
          parse(data['completedSessions']) ??
          parse(data['totalCount']) ??
          parse(data['count']) ??
          parse(data['total']);

      if (nestedCount != null) {
        return nestedCount;
      }

      final nestedList = data['sessions'] ?? data['items'] ?? data['list'];
      if (nestedList is List) {
        return nestedList.length;
      }
    }

    return null;
  }
}
