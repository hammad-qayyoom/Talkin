double _toDouble(dynamic val, [double fallback = 0.0]) {
  if (val == null) return fallback;
  if (val is num) return val.toDouble();
  if (val is String) {
    return double.tryParse(val.trim()) ?? fallback;
  }
  return fallback;
}

int _toInt(dynamic val, [int fallback = 0]) {
  if (val == null) return fallback;
  if (val is num) return val.toInt();
  if (val is String) {
    return int.tryParse(val.trim()) ?? fallback;
  }
  return fallback;
}

class FundraisingCategory {
  final String id;
  final String name;
  final String slug;
  final String? icon;
  final int activeCampaignsCount;

  FundraisingCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.activeCampaignsCount = 0,
  });

  factory FundraisingCategory.fromJson(Map<String, dynamic> json) {
    return FundraisingCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString(),
      activeCampaignsCount: _toInt(json['activeCampaignsCount']),
    );
  }
}

class CampaignCreator {
  final String id;
  final String firstName;
  final String lastName;
  final String? avatar;

  CampaignCreator({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatar,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory CampaignCreator.fromJson(Map<String, dynamic> json) {
    return CampaignCreator(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
    );
  }
}

class CampaignTier {
  final String id;
  final double amount;
  final String title;
  final String? description;
  final int backersCount;

  CampaignTier({
    required this.id,
    required this.amount,
    required this.title,
    this.description,
    this.backersCount = 0,
  });

  factory CampaignTier.fromJson(Map<String, dynamic> json) {
    return CampaignTier(
      id: json['id']?.toString() ?? '',
      amount: _toDouble(json['amount']),
      title: json['name']?.toString() ?? json['title']?.toString() ?? 'Support Tier',
      description: json['description']?.toString(),
      backersCount: _toInt(json['backersCount'] ?? json['sortOrder']),
    );
  }
}

class CampaignUpdate {
  final String id;
  final String title;
  final String content;
  final String? createdAt;

  CampaignUpdate({
    required this.id,
    required this.title,
    required this.content,
    this.createdAt,
  });

  factory CampaignUpdate.fromJson(Map<String, dynamic> json) {
    return CampaignUpdate(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class CampaignSupporter {
  final String id;
  final String name;
  final double amount;
  final String currency;
  final bool isAnonymous;
  final String? message;
  final String? createdAt;

  CampaignSupporter({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    this.isAnonymous = false,
    this.message,
    this.createdAt,
  });

  factory CampaignSupporter.fromJson(Map<String, dynamic> json) {
    return CampaignSupporter(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? (json['isAnonymous'] == true ? 'Anonymous Supporter' : 'Supporter'),
      amount: _toDouble(json['amount']),
      currency: json['currency']?.toString() ?? 'CAD',
      isAnonymous: json['isAnonymous'] == true,
      message: json['message']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class FundraisingCampaign {
  final String id;
  final String title;
  final String slug;
  final String? description;
  final String? content;
  final String? featuredImage;
  final List<String> images;
  final double goalAmount;
  final double raisedAmount;
  final String currency;
  final double percentage;
  final String status;
  final bool isFeatured;
  final String? startDate;
  final String? endDate;
  final FundraisingCategory? category;
  final CampaignCreator? creator;
  final String? location;
  final String? beneficiary;
  final int totalDonations;
  final int donorCount;
  final List<CampaignTier> tiers;
  final List<CampaignUpdate> updates;
  final List<CampaignSupporter> recentSupporters;
  final String? createdAt;

  FundraisingCampaign({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.content,
    this.featuredImage,
    this.images = const [],
    this.goalAmount = 0.0,
    this.raisedAmount = 0.0,
    this.currency = 'CAD',
    this.percentage = 0.0,
    this.status = 'ACTIVE',
    this.isFeatured = false,
    this.startDate,
    this.endDate,
    this.category,
    this.creator,
    this.location,
    this.beneficiary,
    this.totalDonations = 0,
    this.donorCount = 0,
    this.tiers = const [],
    this.updates = const [],
    this.recentSupporters = const [],
    this.createdAt,
  });

  factory FundraisingCampaign.fromJson(Map<String, dynamic> json) {
    final imagesRaw = json['images'];
    List<String> parsedImages = [];
    if (imagesRaw is List) {
      parsedImages = imagesRaw.map((e) => e.toString()).toList();
    }

    final tiersRaw = json['tiers'];
    List<CampaignTier> parsedTiers = [];
    if (tiersRaw is List) {
      for (final t in tiersRaw) {
        if (t is Map<String, dynamic>) {
          try {
            parsedTiers.add(CampaignTier.fromJson(t));
          } catch (_) {}
        }
      }
    }

    final updatesRaw = json['updates'];
    List<CampaignUpdate> parsedUpdates = [];
    if (updatesRaw is List) {
      for (final u in updatesRaw) {
        if (u is Map<String, dynamic>) {
          try {
            parsedUpdates.add(CampaignUpdate.fromJson(u));
          } catch (_) {}
        }
      }
    }

    final supportersRaw = json['recentSupporters'];
    List<CampaignSupporter> parsedSupporters = [];
    if (supportersRaw is List) {
      for (final s in supportersRaw) {
        if (s is Map<String, dynamic>) {
          try {
            parsedSupporters.add(CampaignSupporter.fromJson(s));
          } catch (_) {}
        }
      }
    }

    return FundraisingCampaign(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      content: json['content']?.toString(),
      featuredImage: json['featuredImage']?.toString(),
      images: parsedImages,
      goalAmount: _toDouble(json['goalAmount']),
      raisedAmount: _toDouble(json['raisedAmount']),
      currency: json['currency']?.toString() ?? 'CAD',
      percentage: _toDouble(json['percentage']),
      status: json['status']?.toString() ?? 'ACTIVE',
      isFeatured: json['isFeatured'] == true,
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      category: json['category'] is Map<String, dynamic>
          ? FundraisingCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      creator: json['creator'] is Map<String, dynamic>
          ? CampaignCreator.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
      location: json['location']?.toString(),
      beneficiary: json['beneficiary']?.toString(),
      totalDonations: _toInt(json['totalDonations']),
      donorCount: _toInt(json['donorCount'] ?? json['totalDonations']),
      tiers: parsedTiers,
      updates: parsedUpdates,
      recentSupporters: parsedSupporters,
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class FoundationProgram {
  final String id;
  final String title;
  final String slug;
  final String? description;
  final String? content;
  final String? featuredImage;
  final String? icon;
  final String? impact;
  final String? region;
  final String? location;
  final String? budget;
  final String currency;
  final String status;
  final int sortOrder;

  FoundationProgram({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.content,
    this.featuredImage,
    this.icon,
    this.impact,
    this.region,
    this.location,
    this.budget,
    this.currency = 'USD',
    this.status = 'ACTIVE',
    this.sortOrder = 0,
  });

  factory FoundationProgram.fromJson(Map<String, dynamic> json) {
    return FoundationProgram(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      content: json['content']?.toString(),
      featuredImage: json['featuredImage']?.toString(),
      icon: json['icon']?.toString(),
      impact: json['impact']?.toString(),
      region: json['region']?.toString() ?? json['location']?.toString(),
      location: json['location']?.toString(),
      budget: json['budget']?.toString(),
      currency: json['currency']?.toString() ?? 'USD',
      status: json['status']?.toString() ?? 'ACTIVE',
      sortOrder: _toInt(json['sortOrder']),
    );
  }
}

class FundraisingHeroConfig {
  final bool isActive;
  final String badgeIcon;
  final String badgeText;
  final String heading;
  final String highlightedHeading;
  final String description;
  final String primaryButtonText;
  final String primaryButtonUrl;
  final String secondaryButtonText;
  final String secondaryButtonUrl;
  final FundraisingCampaign? featuredCampaign;

  FundraisingHeroConfig({
    this.isActive = true,
    this.badgeIcon = '🎯',
    this.badgeText = 'DIRECT IMPACT FUNDRAISING',
    this.heading = 'Verified Causes.',
    this.highlightedHeading = 'Measurable Impact.',
    this.description =
        'Discover active community initiatives and verified humanitarian missions. Every dollar is tracked with 100% direct allocation and transparent audit reports.',
    this.primaryButtonText = '❤️ General Foundation Donation',
    this.primaryButtonUrl = '/donate',
    this.secondaryButtonText = 'Explore Active Campaigns ↓',
    this.secondaryButtonUrl = '#campaigns-directory',
    this.featuredCampaign,
  });

  factory FundraisingHeroConfig.fromJson(Map<String, dynamic>? json, [FundraisingCampaign? featured]) {
    if (json == null) return FundraisingHeroConfig();
    return FundraisingHeroConfig(
      isActive: json['isActive'] != false,
      badgeIcon: json['badgeIcon']?.toString() ?? '🎯',
      badgeText: json['badgeText']?.toString() ?? 'DIRECT IMPACT FUNDRAISING',
      heading: json['heading']?.toString() ?? 'Verified Causes.',
      highlightedHeading: json['highlightedHeading']?.toString() ?? 'Measurable Impact.',
      description: json['description']?.toString() ??
          'Discover active community initiatives and verified humanitarian missions. Every dollar is tracked with 100% direct allocation and transparent audit reports.',
      primaryButtonText: json['primaryButtonText']?.toString() ?? '❤️ General Foundation Donation',
      primaryButtonUrl: json['primaryButtonUrl']?.toString() ?? '/donate',
      secondaryButtonText: json['secondaryButtonText']?.toString() ?? 'Explore Active Campaigns ↓',
      secondaryButtonUrl: json['secondaryButtonUrl']?.toString() ?? '#campaigns-directory',
      featuredCampaign: featured,
    );
  }
}

class FundraisingPromotionBanner {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? linkUrl;
  final String? ctaText;
  final String? category;

  FundraisingPromotionBanner({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.linkUrl,
    this.ctaText,
    this.category,
  });

  factory FundraisingPromotionBanner.fromJson(Map<String, dynamic> json) {
    return FundraisingPromotionBanner(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      linkUrl: json['linkUrl']?.toString(),
      ctaText: json['ctaText']?.toString() ?? 'Learn More',
      category: json['category']?.toString() ?? 'Foundation Announcement',
    );
  }
}

class DonationRecord {
  final String id;
  final String receiptNumber;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final bool isAnonymous;
  final bool isRecurring;
  final String? message;
  final String donationType; // GENERAL_FOUNDATION, PROGRAM, CAMPAIGN
  final String? causeTitle;
  final String? createdAt;

  DonationRecord({
    required this.id,
    required this.receiptNumber,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.isAnonymous = false,
    this.isRecurring = false,
    this.message,
    required this.donationType,
    this.causeTitle,
    this.createdAt,
  });

  factory DonationRecord.fromJson(Map<String, dynamic> json) {
    String? title;
    if (json['campaign'] is Map<String, dynamic>) {
      title = (json['campaign'] as Map<String, dynamic>)['title']?.toString();
    } else if (json['program'] is Map<String, dynamic>) {
      title = (json['program'] as Map<String, dynamic>)['title']?.toString();
    } else {
      title = 'General Foundation Fund';
    }

    return DonationRecord(
      id: json['id']?.toString() ?? '',
      receiptNumber: json['receiptNumber']?.toString() ?? 'DON-${json['id']?.toString().substring(0, 8)}',
      amount: _toDouble(json['amount']),
      currency: json['currency']?.toString() ?? 'CAD',
      paymentMethod: json['paymentMethod']?.toString() ?? 'ONLINE',
      status: json['status']?.toString() ?? 'COMPLETED',
      isAnonymous: json['isAnonymous'] == true,
      isRecurring: json['isRecurring'] == true,
      message: json['message']?.toString(),
      donationType: json['donationType']?.toString() ?? 'GENERAL_FOUNDATION',
      causeTitle: title,
      createdAt: json['createdAt']?.toString(),
    );
  }
}
