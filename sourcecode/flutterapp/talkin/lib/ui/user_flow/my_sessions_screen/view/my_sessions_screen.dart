import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/services/permission_handler/permission_handler.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/ui/common/session_booking/session_booking_service.dart';
import 'package:talk_in/ui/user_flow/call_cut_screen/api/submit_call_rate_api.dart';
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
  final Set<String> _reviewSubmittedKeys = <String>{};
  final GetStorage _storage = GetStorage();
  static const String _storageKeyReviews = 'submitted_reviews_keys';

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandRedDark = AppColors.redesignBrandRedDark;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _screenBackground = AppColors.redesignScreenBackground;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _chipSurface = AppColors.redesignSurfaceSoft;

  @override
  void initState() {
    super.initState();
    _loadReviewsFromStorage();
    _fetchSessions();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) {
        _fetchSessions();
      }
    });
  }

  Future<void> _loadReviewsFromStorage() async {
    try {
      final List<dynamic>? storedKeys =
          _storage.read(_storageKeyReviews) as List<dynamic>?;
      if (storedKeys != null) {
        _reviewSubmittedKeys.addAll(
          storedKeys.whereType<String>(),
        );
        Utils.showLog(
            'Loaded ${_reviewSubmittedKeys.length} submitted reviews from storage');
      }
    } catch (e) {
      Utils.showLog('Error loading reviews from storage: $e');
    }
  }

  Future<void> _saveReviewsToStorage() async {
    try {
      await _storage.write(
        _storageKeyReviews,
        _reviewSubmittedKeys.toList(),
      );
      Utils.showLog('Saved ${_reviewSubmittedKeys.length} reviews to storage');
    } catch (e) {
      Utils.showLog('Error saving reviews to storage: $e');
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchSessions() async {
    final userId =
        (Database.fetchLoginUserProfileModel?.user?.id ?? '').toString();

    if (!mounted) {
      return;
    }

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
      // _reviewSubmittedKeys is NOT cleared - it persists across refreshes
    });

    if (response['status'] != true) {
      Utils.showToast(context,
          (response['message'] ?? 'Failed to fetch sessions.').toString());
    }
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

  Future<void> _triggerDirectSessionCall({
    required String callType,
    required String receiverId,
    required String receiverName,
    required String receiverImage,
    required String sessionId,
    required String bookingId,
  }) async {
    final normalizedCallType = callType.trim().toLowerCase();
    if (normalizedCallType != 'audio' && normalizedCallType != 'video') {
      Utils.showToast(context, 'Unsupported call type for this session.');
      return;
    }

    final callerId = Database.loginUserId.trim();
    final sanitizedReceiverId = receiverId.trim();

    if (callerId.isEmpty || sanitizedReceiverId.isEmpty) {
      Utils.showToast(
        context,
        'Unable to start session call. Missing caller/receiver details.',
      );
      return;
    }

    void emitCall() {
      SocketEmit.emitCallOutgoingRinging(
        callerId: callerId,
        receiverId: sanitizedReceiverId,
        callType: normalizedCallType,
        callerRole: 'user',
        receiverRole: 'listener',
        receiverName: receiverName,
        receiverImage: receiverImage,
        callerName: (Database.fetchLoginUserProfileModel?.user?.fullName ?? '')
            .toString(),
        callerImage:
            (Database.fetchLoginUserProfileModel?.user?.profilePic ?? '')
                .toString(),
        sessionId: sessionId,
        bookingId: bookingId,
      );
      _fetchSessions();
    }

    if (normalizedCallType == 'video') {
      PermissionHandler.onGetCameraPermission(
        onGranted: () {
          PermissionHandler.onGetMicrophonePermission(
            onGranted: emitCall,
          );
        },
      );
      return;
    }

    PermissionHandler.onGetMicrophonePermission(
      onGranted: emitCall,
    );
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

    final sessionType =
        (session['sessionType'] ?? '').toString().trim().toLowerCase();
    if (sessionType == 'group') {
      Utils.showToast(context, 'Group session access granted.');
      return;
    }

    final listenerId = (expert['legacyListenerId'] ?? '').toString();
    if (listenerId.isEmpty) {
      Utils.showToast(
          context, 'Unable to start session. Expert is unavailable.');
      return;
    }

    final expertName =
        (expert['displayName'] ?? expert['name'] ?? 'Expert').toString();
    final expertImage =
        (expert['image'] ?? expert['imageUrl'] ?? expert['profilePic'] ?? '')
            .toString();
    final sessionCallType =
        (session['callType'] ?? '').toString().trim().toLowerCase();

    await _triggerDirectSessionCall(
      callType: sessionCallType,
      receiverId: listenerId,
      receiverName: expertName,
      receiverImage: expertImage,
      sessionId: sessionId,
      bookingId: bookingId,
    );
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

  String _extractListenerId(Map<String, dynamic> expert) {
    final candidates = [
      (expert['legacyListenerId'] ?? '').toString().trim(),
      (expert['listenerId'] ?? '').toString().trim(),
      (expert['_id'] ?? '').toString().trim(),
      (expert['id'] ?? '').toString().trim(),
    ];

    for (final value in candidates) {
      if (value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  bool _containsDangerousScript(String input) {
    final scriptTagRegex = RegExp(r'<\s*script[^>]*>', caseSensitive: false);
    return scriptTagRegex.hasMatch(input);
  }

  bool _isReviewAlreadyPresent(
    Map<String, dynamic> booking,
    Map<String, dynamic> session,
  ) {
    final reviewFlags = [
      booking['isReviewed'],
      booking['reviewSubmitted'],
      booking['hasReview'],
      session['isReviewed'],
      session['reviewSubmitted'],
      session['hasReview'],
    ];

    for (final flag in reviewFlags) {
      if (flag == true) {
        return true;
      }
      if (flag is String && flag.trim().toLowerCase() == 'true') {
        return true;
      }
      if (flag is num && flag == 1) {
        return true;
      }
    }

    final ratingCandidates = [
      booking['rating'],
      booking['reviewRating'],
    ];

    for (final rating in ratingCandidates) {
      if (rating is num && rating > 0) {
        return true;
      }
      final text = (rating ?? '').toString().trim();
      if (text.isNotEmpty && text != '0' && text != '0.0') {
        return true;
      }
    }

    final reviewCandidates = [
      booking['review'],
      booking['reviewText'],
    ];

    for (final review in reviewCandidates) {
      if ((review ?? '').toString().trim().isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  Future<Map<String, dynamic>> _submitSessionReview({
    required String reviewKey,
    required String listenerId,
    required int rating,
    required String review,
  }) async {
    final normalizedListenerId = listenerId.trim();
    if (normalizedListenerId.isEmpty) {
      return {
        'success': false,
        'message': 'Unable to submit review. Expert id missing.',
      };
    }

    final response = await SubmitCallRateApi.callApi(
      listenerId: normalizedListenerId,
      review: review,
      rating: rating.toString(),
    );

    if (!mounted) {
      return {
        'success': false,
        'message': 'Screen is not active.',
      };
    }

    final rawMessage =
        (response?.message ?? 'Failed to submit review.').toString();
    final normalizedMessage = rawMessage.toLowerCase();
    final alreadyReviewed = normalizedMessage.contains('already') &&
        (normalizedMessage.contains('review') ||
            normalizedMessage.contains('rated') ||
            normalizedMessage.contains('rating'));
    final isSuccess = response?.status == true || alreadyReviewed;
    final message = rawMessage.trim().isEmpty
        ? (isSuccess
            ? 'Review submitted successfully.'
            : 'Failed to submit review.')
        : rawMessage;

    return {
      'success': isSuccess,
      'message': message,
      'reviewKey': reviewKey,
    };
  }

  Future<void> _showReviewBottomSheet({
    required String reviewKey,
    required Map<String, dynamic> expert,
  }) async {
    final listenerId = _extractListenerId(expert);
    if (listenerId.isEmpty) {
      Utils.showToast(context, 'Unable to submit review for this expert.');
      return;
    }

    final expertName =
        (expert['displayName'] ?? expert['name'] ?? 'Expert').toString();
    final reviewController = TextEditingController();
    int selectedRating = 5;
    bool isSubmitting = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return WillPopScope(
              onWillPop: () async => !isSubmitting,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                ),
                child: Dialog(
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Review $expertName',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 17,
                                    fontColor: _brandDark,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () {
                                        FocusScope.of(modalContext).unfocus();
                                        Navigator.of(modalContext).pop();
                                      },
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'How was your session experience?',
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 12,
                              fontColor: _mutedText,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final active = index < selectedRating;
                              return IconButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () {
                                        setModalState(() {
                                          selectedRating = index + 1;
                                        });
                                      },
                                icon: Icon(
                                  Icons.star_rounded,
                                  size: 34,
                                  color: active
                                      ? AppColors.rateStarColor
                                      : AppColors.lightGrey,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: reviewController,
                            enabled: !isSubmitting,
                            minLines: 3,
                            maxLines: 5,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: 'Write your review here...',
                              hintStyle: AppFontStyle.fontStyleW500(
                                fontSize: 12,
                                fontColor: _mutedText,
                              ),
                              filled: true,
                              fillColor: AppColors.redesignSurfaceSoft,
                              contentPadding: const EdgeInsets.all(12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: _softBorder, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: _softBorder, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _brandRed.withValues(alpha: 0.6),
                                  width: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      final review =
                                          reviewController.text.trim();
                                      if (review.isEmpty) {
                                        Utils.showToast(
                                          context,
                                          'Please enter a review.',
                                        );
                                        return;
                                      }

                                      if (_containsDangerousScript(review)) {
                                        Utils.showToast(
                                          context,
                                          'Script tags are not allowed in the review.',
                                        );
                                        reviewController.clear();
                                        return;
                                      }

                                      if (!mounted) return;

                                      setModalState(() {
                                        isSubmitting = true;
                                      });
                                      FocusScope.of(modalContext).unfocus();

                                      final submitResult =
                                          await _submitSessionReview(
                                        reviewKey: reviewKey,
                                        listenerId: listenerId,
                                        rating: selectedRating,
                                        review: review,
                                      );

                                      if (!mounted || !modalContext.mounted) {
                                        return;
                                      }

                                      final isSuccess =
                                          submitResult['success'] == true;
                                      final message =
                                          (submitResult['message'] ?? '')
                                              .toString();

                                      if (isSuccess) {
                                        Navigator.of(modalContext)
                                            .pop(submitResult);
                                        return;
                                      }

                                      if (message.isNotEmpty) {
                                        Utils.showToast(context, message);
                                      }

                                      setModalState(() {
                                        isSubmitting = false;
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: _brandRed,
                                foregroundColor: AppColors.white,
                                disabledBackgroundColor: _softBorder,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: isSubmitting
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send_rounded,
                                      size: 16,
                                    ),
                              label: Text(
                                isSubmitting
                                    ? 'Submitting...'
                                    : 'Submit Review',
                                style: AppFontStyle.fontStyleW600(
                                  fontSize: 14,
                                  fontColor: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    reviewController.dispose();

    if (!mounted || result == null) {
      return;
    }

    final submitted = result['success'] == true;
    if (!submitted) {
      return;
    }

    setState(() {
      _reviewSubmittedKeys.add(reviewKey);
    });
    await _saveReviewsToStorage();
    await _fetchSessions();

    if (!mounted) {
      return;
    }

    final message = (result['message'] ?? '').toString().trim();
    final dialogMessage = message.isEmpty
        ? 'Your review has been successfully recorded.'
        : message;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Review Submitted',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(dialogMessage),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandRed,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
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
          _fetchSessions();
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

  Widget _buildMetaChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _chipSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _softBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _mutedText),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppFontStyle.fontStyleW500(
              fontSize: 11,
              fontColor: _mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard({double bottomMargin = 12}) {
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: 180,
            decoration: BoxDecoration(
              color: AppColors.lightGrey1,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 90,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 12,
            width: 220,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 170,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard({
    required Map<String, dynamic> item,
    required double cardWidth,
  }) {
    final session = item['session'] is Map<String, dynamic>
        ? item['session'] as Map<String, dynamic>
        : item['sessionId'] is Map<String, dynamic>
            ? item['sessionId'] as Map<String, dynamic>
            : <String, dynamic>{};
    final expert = session['expertId'] is Map<String, dynamic>
        ? session['expertId'] as Map<String, dynamic>
        : <String, dynamic>{};

    final callTypeRaw = (session['callType'] ?? '').toString().trim();
    final callTypeLabel =
        callTypeRaw.isEmpty ? 'Unknown' : callTypeRaw.toUpperCase();
    final status =
        (session['sessionStatus'] ?? session['status'] ?? '').toString();
    final statusLower = status.trim().toLowerCase();
    final statusLabel = _toTitleCase(status);
    final isCompletedSession = statusLower == 'completed';
    final canStart = item['canStartSession'] == true;
    final showStartSession = _view == 'upcoming';
    final showReviewAction = _view == 'completed' && isCompletedSession;
    final bookingId = (item['_id'] ?? '').toString();
    final sessionId = (session['_id'] ?? '').toString();
    final reviewKey = bookingId.isNotEmpty ? bookingId : sessionId;
    final hasSubmittedReview = _reviewSubmittedKeys.contains(reviewKey) ||
        _isReviewAlreadyPresent(item, session);
    final isCancellingThis = _cancellingBookingId == bookingId;
    final title = (session['title'] ?? 'Session').toString();
    final expertName = (expert['displayName'] ?? 'Unknown').toString();
    final startAt = _formatDateTime((session['startAt'] ?? '').toString());
    final isNarrowActionLayout = cardWidth < 430;

    return Container(
      padding: const EdgeInsets.all(12),
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
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 14,
                    fontColor: _brandDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusBackground(status),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 10,
                    fontColor: _statusTextColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            expertName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFontStyle.fontStyleW600(
              fontSize: 13,
              fontColor: _brandDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
          if (showStartSession) ...[
            const SizedBox(height: 12),
            if (isNarrowActionLayout)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: canStart
                          ? () => _onStartSession(item, session, expert)
                          : null,
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
                        canStart
                            ? Icons.play_circle_outline_rounded
                            : Icons.schedule_rounded,
                        size: 16,
                      ),
                      label: Text(
                        canStart ? 'Start Session' : 'Not Live Yet',
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 13,
                          fontColor: canStart ? AppColors.white : _mutedText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: isCancellingThis
                          ? null
                          : () => _onCancelBooking(item, session),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _brandRed.withValues(alpha: 0.45),
                        ),
                        foregroundColor: _brandRedDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: isCancellingThis
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.close_rounded, size: 16),
                      label: Text(
                        isCancellingThis ? 'Cancelling' : 'Cancel Slot',
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 13,
                          fontColor: _brandRedDark,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: canStart
                            ? () => _onStartSession(item, session, expert)
                            : null,
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
                          canStart
                              ? Icons.play_circle_outline_rounded
                              : Icons.schedule_rounded,
                          size: 16,
                        ),
                        label: Text(
                          canStart ? 'Start Session' : 'Not Live Yet',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 13,
                            fontColor: canStart ? AppColors.white : _mutedText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton.icon(
                        onPressed: isCancellingThis
                            ? null
                            : () => _onCancelBooking(item, session),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _brandRed.withValues(alpha: 0.45),
                          ),
                          foregroundColor: _brandRedDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: isCancellingThis
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.close_rounded, size: 16),
                        label: Text(
                          isCancellingThis ? 'Cancelling' : 'Cancel Slot',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 13,
                            fontColor: _brandRedDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
          if (showReviewAction) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: hasSubmittedReview
                  ? OutlinedButton.icon(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.redesignStatusSuccessDark
                              .withValues(alpha: 0.4),
                        ),
                        foregroundColor: AppColors.redesignStatusSuccessDark,
                        disabledForegroundColor:
                            AppColors.redesignStatusSuccessDark,
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded,
                          size: 16),
                      label: Text(
                        'Review Submitted',
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 13,
                          fontColor: AppColors.redesignStatusSuccessDark,
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _showReviewBottomSheet(
                        reviewKey: reviewKey,
                        expert: expert,
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
                      icon: const Icon(
                        Icons.rate_review_outlined,
                        size: 16,
                      ),
                      label: Text(
                        'Give Review',
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 13,
                          fontColor: AppColors.white,
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionsList({
    required double horizontalInset,
  }) {
    if (_isLoading) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = (constraints.maxWidth - (horizontalInset * 2))
              .clamp(0.0, double.infinity)
              .toDouble();
          final isTablet = constraints.maxWidth >= 760;
          final columns = constraints.maxWidth >= 1200
              ? 3
              : isTablet
                  ? 2
                  : 1;
          const spacing = 14.0;
          final cardWidth = columns == 1
              ? availableWidth
              : ((availableWidth - (spacing * (columns - 1))) / columns)
                  .toDouble();

          return Shimmer.fromColors(
            baseColor: AppColors.redesignShimmerBase,
            highlightColor: AppColors.white,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding:
                  EdgeInsets.fromLTRB(horizontalInset, 6, horizontalInset, 20),
              children: [
                if (columns == 1)
                  ...List.generate(4, (index) => _buildLoadingCard())
                else
                  Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: List.generate(
                      4,
                      (index) => SizedBox(
                        width: cardWidth,
                        child: _buildLoadingCard(bottomMargin: 0),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }

    if (_sessions.isEmpty) {
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
                  Icons.calendar_month_rounded,
                  size: 32,
                  color: _brandRed,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No sessions found',
                style: AppFontStyle.fontStyleW700(
                  fontSize: 15,
                  fontColor: _brandDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _view == 'upcoming'
                    ? 'Your upcoming bookings will appear here.'
                    : 'Completed sessions will appear here.',
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 12,
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
          final availableWidth = (constraints.maxWidth - (horizontalInset * 2))
              .clamp(0.0, double.infinity)
              .toDouble();
          final isTablet = constraints.maxWidth >= 760;
          final columns = constraints.maxWidth >= 1200
              ? 3
              : isTablet
                  ? 2
                  : 1;
          const spacing = 14.0;
          final cardWidth = columns == 1
              ? availableWidth
              : ((availableWidth - (spacing * (columns - 1))) / columns)
                  .toDouble();

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding:
                EdgeInsets.fromLTRB(horizontalInset, 6, horizontalInset, 20),
            children: [
              if (columns == 1)
                ..._sessions.map((rawItem) {
                  final item = rawItem is Map<String, dynamic>
                      ? rawItem
                      : <String, dynamic>{};

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildSessionCard(
                      item: item,
                      cardWidth: cardWidth,
                    ),
                  );
                })
              else
                Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: _sessions.map((rawItem) {
                    final item = rawItem is Map<String, dynamic>
                        ? rawItem
                        : <String, dynamic>{};

                    return SizedBox(
                      width: cardWidth,
                      child: _buildSessionCard(
                        item: item,
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
    return Scaffold(
      backgroundColor: _screenBackground,
      body: LayoutBuilder(
        builder: (context, viewportConstraints) {
          final viewportWidth = viewportConstraints.maxWidth;
          final maxContentWidth = viewportWidth >= 760 ? 980.0 : viewportWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: LayoutBuilder(
                builder: (context, contentConstraints) {
                  final width = contentConstraints.maxWidth;
                  final isTablet = width >= 760;
                  final canPop = Navigator.of(context).canPop();
                  final horizontalInset = width >= 1100
                      ? 28.0
                      : isTablet
                          ? 22.0
                          : 16.0;
                  final heroSubtitle = _view == 'upcoming'
                      ? 'Track and manage your upcoming bookings'
                      : 'View your completed sessions in one place';

                  return SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalInset,
                            8,
                            horizontalInset,
                            6,
                          ),
                          child: Row(
                            children: [
                              if (canPop)
                                Material(
                                  color: AppColors.transparent,
                                  child: InkWell(
                                    onTap: () =>
                                        Navigator.of(context).maybePop(),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      height: isTablet ? 42 : 38,
                                      width: isTablet ? 42 : 38,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: _softBorder),
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: isTablet ? 20 : 18,
                                        color: _brandDark,
                                      ),
                                    ),
                                  ),
                                ),
                              if (canPop) const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'My Sessions',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: isTablet ? 22 : 18,
                                    fontColor: _brandDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalInset,
                            6,
                            horizontalInset,
                            10,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(isTablet ? 14 : 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _brandRed,
                                  _brandRedDark,
                                ],
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
                                  height: isTablet ? 40 : 36,
                                  width: isTablet ? 40 : 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.calendar_month_rounded,
                                    color: _brandRed,
                                    size: isTablet ? 22 : 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Session Center',
                                        style: AppFontStyle.fontStyleW700(
                                          fontSize: isTablet ? 15 : 14,
                                          fontColor: AppColors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        heroSubtitle,
                                        style: AppFontStyle.fontStyleW500(
                                          fontSize: isTablet ? 12 : 11,
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
                                    horizontal: 10,
                                    vertical: 7,
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
                                        '${_sessions.length}',
                                        style: AppFontStyle.fontStyleW700(
                                          fontSize: isTablet ? 16 : 14,
                                          fontColor: AppColors.white,
                                        ),
                                      ),
                                      Text(
                                        _view == 'upcoming'
                                            ? 'Upcoming'
                                            : 'Done',
                                        style: AppFontStyle.fontStyleW500(
                                          fontSize: 9,
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
                            10,
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
