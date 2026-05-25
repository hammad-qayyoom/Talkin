class ReferralSummaryModel {
  ReferralSummaryModel({
    this.status,
    this.message,
    this.data,
  });

  final bool? status;
  final String? message;
  final ReferralSummaryData? data;

  factory ReferralSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReferralSummaryModel(
      status: json['status'] == true,
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? ReferralSummaryData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ReferralSummaryData {
  ReferralSummaryData({
    required this.isEnabled,
    required this.referralCode,
    required this.referralLink,
    required this.totalReferrals,
    required this.pendingRewards,
    required this.approvedRewards,
    required this.paidRewards,
    required this.rejectedRewards,
    required this.rewardSettings,
    required this.records,
  });

  final bool isEnabled;
  final String referralCode;
  final String referralLink;
  final int totalReferrals;
  final num pendingRewards;
  final num approvedRewards;
  final num paidRewards;
  final num rejectedRewards;
  final ReferralRewardSettings rewardSettings;
  final List<ReferralRecordItem> records;

  factory ReferralSummaryData.fromJson(Map<String, dynamic> json) {
    return ReferralSummaryData(
      isEnabled: json['isEnabled'] == true || json['programEnabled'] == true,
      referralCode: (json['referralCode'] ?? '').toString(),
      referralLink: (json['referralLink'] ?? '').toString(),
      totalReferrals: _toInt(json['totalReferrals']),
      pendingRewards: _toNum(json['pendingRewards']),
      approvedRewards: _toNum(json['approvedRewards']),
      paidRewards: _toNum(json['paidRewards']),
      rejectedRewards: _toNum(json['rejectedRewards']),
      rewardSettings: json['rewardSettings'] is Map<String, dynamic>
          ? ReferralRewardSettings.fromJson(
              json['rewardSettings'] as Map<String, dynamic>,
            )
          : ReferralRewardSettings.fromJson(json),
      records: (json['records'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ReferralRecordItem.fromJson)
          .toList(),
    );
  }
}

class ReferralRewardSettings {
  ReferralRewardSettings({
    required this.triggerType,
    required this.amount,
    required this.currency,
  });

  final String triggerType;
  final num amount;
  final String currency;

  factory ReferralRewardSettings.empty() {
    return ReferralRewardSettings(
      triggerType: 'subscription',
      amount: 0,
      currency: 'credits',
    );
  }

  factory ReferralRewardSettings.fromJson(Map<String, dynamic> json) {
    return ReferralRewardSettings(
      triggerType:
          (json['triggerType'] ?? json['rewardTriggerType'] ?? 'subscription')
              .toString(),
      amount: _toNum(json['amount'] ?? json['rewardAmount']),
      currency:
          (json['currency'] ?? json['rewardCurrency'] ?? 'credits').toString(),
    );
  }
}

class ReferralRecordItem {
  ReferralRecordItem({
    required this.referredUserName,
    required this.referredUserEmail,
    required this.rewardAmount,
    required this.rewardCurrency,
    required this.rewardStatus,
    required this.rewardTriggerType,
    required this.createdAt,
  });

  final String referredUserName;
  final String referredUserEmail;
  final num rewardAmount;
  final String rewardCurrency;
  final String rewardStatus;
  final String rewardTriggerType;
  final DateTime? createdAt;

  factory ReferralRecordItem.fromJson(Map<String, dynamic> json) {
    final referredUserPayload = json['referredUser'] ?? json['referredUserId'];
    final referredUser = referredUserPayload is Map<String, dynamic>
        ? referredUserPayload
        : <String, dynamic>{};

    return ReferralRecordItem(
      referredUserName: (referredUser['fullName'] ?? 'New user').toString(),
      referredUserEmail: (referredUser['email'] ?? '').toString(),
      rewardAmount: _toNum(json['rewardAmount']),
      rewardCurrency: (json['rewardCurrency'] ?? 'credits').toString(),
      rewardStatus: (json['rewardStatus'] ?? 'pending').toString(),
      rewardTriggerType:
          (json['rewardTriggerType'] ?? 'subscription').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

num _toNum(dynamic value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '') ?? 0;
}
