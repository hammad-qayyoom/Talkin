import 'package:get/get.dart';
import 'package:notisboard/ui/host_flow/ecosystem/api/ecosystem_api.dart';
import 'package:notisboard/ui/host_flow/ecosystem/models/ecosystem_items_model.dart';
import 'package:notisboard/ui/host_flow/ecosystem/models/ecosystem_status_model.dart';
import 'package:notisboard/utils/utils.dart';

class EcosystemController extends GetxController {
  bool isLoading = true;
  bool isActionLoading = false;

  EcosystemStatusModel? statusModel;
  VendorPortalData? vendorPortalData;
  OrganizerPortalData? organizerPortalData;
  PlatformCurrency platformCurrency = PlatformCurrency();

  List<EcosystemProduct> products = [];
  List<EcosystemEvent> events = [];
  List<EcosystemCampaign> campaigns = [];

  String formatCurrency(num amount) => platformCurrency.format(amount);
  String get currencySymbol => platformCurrency.symbol;
  String get currencyCode => platformCurrency.code;

  EcosystemRoleStatus get vendorStatus =>
      statusModel?.data?.vendor ?? EcosystemRoleStatus(status: 'not_applied');

  EcosystemRoleStatus get organizerStatus =>
      statusModel?.data?.organizer ?? EcosystemRoleStatus(status: 'not_applied');

  bool get isVendorUnlocked => vendorStatus.isUnlocked || vendorStatus.status == 'approved';
  bool get isOrganizerUnlocked => organizerStatus.isUnlocked || organizerStatus.status == 'approved';

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    isLoading = true;
    update();

    final results = await Future.wait([
      EcosystemApi.getStatus(),
      EcosystemApi.getPlatformCurrency(),
    ]);

    statusModel = results[0] as EcosystemStatusModel?;
    if (results[1] is PlatformCurrency) {
      platformCurrency = results[1] as PlatformCurrency;
    }

    if (isVendorUnlocked) {
      await loadVendorPortal();
    }

    if (isOrganizerUnlocked) {
      await loadOrganizerPortal();
    }

    isLoading = false;
    update();
  }

  Future<void> loadVendorPortal() async {
    final vData = await EcosystemApi.getVendorPortalData();
    if (vData != null) {
      vendorPortalData = vData;
      platformCurrency = vData.currency;
      products = vData.products;
    } else {
      products = await EcosystemApi.listVendorProducts();
    }
    update();
  }

  Future<void> loadOrganizerPortal() async {
    final oData = await EcosystemApi.getOrganizerPortalData();
    if (oData != null) {
      organizerPortalData = oData;
      platformCurrency = oData.currency;
      events = oData.events;
      campaigns = oData.campaigns;
    } else {
      final results = await Future.wait([
        EcosystemApi.listOrganizerEvents(),
        EcosystemApi.listOrganizerCampaigns(),
      ]);
      events = results[0] as List<EcosystemEvent>;
      campaigns = results[1] as List<EcosystemCampaign>;
    }
    update();
  }

  Future<bool> submitVendorApplication({
    required String applicantType,
    required String firstName,
    String middleName = '',
    required String lastName,
    required String email,
    required String phone,
    String citizenship = '',
    String dateOfBirth = '',
    String placeOfBirth = '',
    String countryOfResidence = '',
    String residentialAddress = '',
    String city = '',
    String state = '',
    String postalCode = '',
    String registeredBusinessName = '',
    String businessName = '',
    String businessType = 'Limited Liability Company (LLC)',
    String taxId = '',
    String governmentIdType = "Driver's License",
    String governmentIdExpirationDate = '',
    String proofOfAddressType = 'Bank Statement (Last 3 Months)',
    String password = '',
    String confirmPassword = '',
    String description = '',
    String website = '',
    String motivation = '',
    Map<String, String> documentFilePaths = const {},
  }) async {
    isActionLoading = true;
    update();

    final res = await EcosystemApi.applyVendor(
      applicantType: applicantType,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      email: email,
      phone: phone,
      citizenship: citizenship,
      dateOfBirth: dateOfBirth,
      placeOfBirth: placeOfBirth,
      countryOfResidence: countryOfResidence,
      residentialAddress: residentialAddress,
      city: city,
      state: state,
      postalCode: postalCode,
      registeredBusinessName: registeredBusinessName,
      businessName: businessName,
      businessType: businessType,
      taxId: taxId,
      governmentIdType: governmentIdType,
      governmentIdExpirationDate: governmentIdExpirationDate,
      proofOfAddressType: proofOfAddressType,
      password: password,
      confirmPassword: confirmPassword,
      description: description,
      website: website,
      motivation: motivation,
      documentFilePaths: documentFilePaths,
    );

    isActionLoading = false;
    if (res != null && res['status'] == true) {
      Utils.showToast(Get.context!, res['message'] ?? 'Application submitted successfully');
      await refreshAll();
      return true;
    } else {
      Utils.showToast(Get.context!, res?['message'] ?? 'Failed to submit application');
      update();
      return false;
    }
  }

  Future<bool> submitOrganizerApplication({
    required String applicantType,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String city = '',
    String country = '',
    String organizationName = '',
    String organizationType = 'Registered Non-Profit / NGO',
    String website = '',
    String password = '',
    String confirmPassword = '',
    String legalName = '',
    String dateOfBirth = '',
    String address = '',
    String idDocumentType = 'Passport',
    String taxId = '',
    String bankName = '',
    String bankAccountName = '',
    String bankAccountNumber = '',
    String bankRoutingNumber = '',
    String experience = '',
    String description = '',
    String motivation = '',
    Map<String, String> documentFilePaths = const {},
  }) async {
    isActionLoading = true;
    update();

    final res = await EcosystemApi.applyOrganizer(
      applicantType: applicantType,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      city: city,
      country: country,
      organizationName: organizationName,
      organizationType: organizationType,
      website: website,
      password: password,
      confirmPassword: confirmPassword,
      legalName: legalName,
      dateOfBirth: dateOfBirth,
      address: address,
      idDocumentType: idDocumentType,
      taxId: taxId,
      bankName: bankName,
      bankAccountName: bankAccountName,
      bankAccountNumber: bankAccountNumber,
      bankRoutingNumber: bankRoutingNumber,
      experience: experience,
      description: description,
      motivation: motivation,
      documentFilePaths: documentFilePaths,
    );

    isActionLoading = false;
    if (res != null && res['status'] == true) {
      Utils.showToast(Get.context!, res['message'] ?? 'Organizer application submitted successfully');
      await refreshAll();
      return true;
    } else {
      Utils.showToast(Get.context!, res?['message'] ?? 'Failed to submit application');
      update();
      return false;
    }
  }

  Future<bool> fulfillVendorOrder({
    required String subOrderId,
    required String status,
    String? trackingNumber,
    String? carrier,
  }) {
    return updateOrderStatus(
      orderId: subOrderId,
      status: status,
      trackingNumber: trackingNumber,
      trackingCarrier: carrier,
    );
  }

  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
    String? trackingNumber,
    String? trackingCarrier,
  }) async {
    isActionLoading = true;
    update();

    final ok = await EcosystemApi.updateVendorOrderStatus(
      subOrderId: orderId,
      status: status,
      trackingNumber: trackingNumber,
      trackingCarrier: trackingCarrier,
    );

    isActionLoading = false;
    if (ok) {
      Utils.showToast(Get.context!, "Order status updated to $status");
      await loadVendorPortal();
      return true;
    } else {
      Utils.showToast(Get.context!, "Failed to update order status");
      update();
      return false;
    }
  }

  Future<bool> requestVendorPayout(double amount, Map<String, dynamic> bankDetails) async {
    isActionLoading = true;
    update();

    final ok = await EcosystemApi.requestVendorPayout(amount: amount, bankDetails: bankDetails);
    isActionLoading = false;
    if (ok) {
      Utils.showToast(Get.context!, "Payout request submitted to Foundation Finance!");
      await loadVendorPortal();
      return true;
    } else {
      Utils.showToast(Get.context!, "Failed to request payout");
      update();
      return false;
    }
  }

  Future<bool> requestOrganizerPayout(double amount, Map<String, dynamic> bankDetails) async {
    isActionLoading = true;
    update();

    final ok = await EcosystemApi.requestOrganizerPayout(amount: amount, bankDetails: bankDetails);
    isActionLoading = false;
    if (ok) {
      Utils.showToast(Get.context!, "Payout request submitted to Foundation Finance!");
      await loadOrganizerPortal();
      return true;
    } else {
      Utils.showToast(Get.context!, "Failed to request payout");
      update();
      return false;
    }
  }

  Future<bool> saveProduct({
    String? productId,
    required String title,
    String? brand,
    String? categoryId,
    String? categoryName,
    String? productType,
    String? badge,
    List<String>? tags,
    required double price,
    double? compareAtPrice,
    double? costPrice,
    required int inventory,
    String? sku,
    int? lowStockThreshold,
    bool trackInventory = true,
    required String description,
    String? impact,
    List<String>? features,
    Map<String, String>? specifications,
    List<Map<String, dynamic>>? variants,
    double? weight,
    Map<String, dynamic>? dimensions,
    String? shippingClassification,
    double? shippingSurcharge,
    String? returnPolicy,
    bool isDraft = false,
    String? imagePath,
    List<String>? galleryImageUrls,
  }) async {
    isActionLoading = true;
    update();

    bool success;
    if (productId != null && productId.isNotEmpty) {
      success = await EcosystemApi.updateVendorProduct(
        productId: productId,
        title: title,
        brand: brand,
        categoryId: categoryId,
        categoryName: categoryName,
        productType: productType,
        badge: badge,
        tags: tags,
        price: price,
        compareAtPrice: compareAtPrice,
        costPrice: costPrice,
        inventory: inventory,
        sku: sku,
        lowStockThreshold: lowStockThreshold,
        trackInventory: trackInventory,
        description: description,
        impact: impact,
        features: features,
        specifications: specifications,
        variants: variants,
        weight: weight,
        dimensions: dimensions,
        shippingClassification: shippingClassification,
        shippingSurcharge: shippingSurcharge,
        returnPolicy: returnPolicy,
        isDraft: isDraft,
        isActive: false,
        imagePath: imagePath,
        galleryImageUrls: galleryImageUrls,
      );
    } else {
      success = await EcosystemApi.createVendorProduct(
        title: title,
        brand: brand,
        categoryId: categoryId,
        categoryName: categoryName,
        productType: productType,
        badge: badge,
        tags: tags,
        price: price,
        compareAtPrice: compareAtPrice,
        costPrice: costPrice,
        inventory: inventory,
        sku: sku,
        lowStockThreshold: lowStockThreshold,
        trackInventory: trackInventory,
        description: description,
        impact: impact,
        features: features,
        specifications: specifications,
        variants: variants,
        weight: weight,
        dimensions: dimensions,
        shippingClassification: shippingClassification,
        shippingSurcharge: shippingSurcharge,
        returnPolicy: returnPolicy,
        isDraft: isDraft,
        imagePath: imagePath,
        galleryImageUrls: galleryImageUrls,
      );
    }

    isActionLoading = false;
    if (success) {
      Utils.showToast(
        Get.context!,
        productId != null
            ? "Product updated successfully!"
            : (isDraft ? "Product saved as draft!" : "Product submitted for Foundation approval!"),
      );
      await loadVendorPortal();
      return true;
    } else {
      Utils.showToast(Get.context!, "Failed to save product");
      update();
      return false;
    }
  }

  Future<bool> addProduct({
    required String title,
    required double price,
    required String description,
    required int inventory,
    String? imagePath,
  }) async {
    return saveProduct(
      title: title,
      price: price,
      description: description,
      inventory: inventory,
      imagePath: imagePath,
    );
  }

  Future<bool> addEvent({
    required String title,
    required String description,
    required String venue,
    required String city,
    required String country,
    required bool isOnline,
    String? onlineUrl,
    required double priceFrom,
    required DateTime startDateTime,
    required DateTime endDateTime,
    required int maxAttendees,
    String? category,
    String? timezone,
    int? checkInWindowMinutes,
    String? address,
    String? metaTitle,
    String? metaDescription,
    String? status,
    List<EventTicketTier>? tickets,
    String? imagePath,
  }) async {
    return saveEvent(
      title: title,
      description: description,
      venue: venue,
      city: city,
      country: country,
      isOnline: isOnline,
      onlineUrl: onlineUrl,
      priceFrom: priceFrom,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      maxAttendees: maxAttendees,
      category: category,
      timezone: timezone,
      checkInWindowMinutes: checkInWindowMinutes,
      address: address,
      metaTitle: metaTitle,
      metaDescription: metaDescription,
      status: status,
      tickets: tickets,
      imagePath: imagePath,
    );
  }

  Future<bool> saveEvent({
    String? eventId,
    required String title,
    required String description,
    required String venue,
    required String city,
    required String country,
    required bool isOnline,
    String? onlineUrl,
    required double priceFrom,
    required DateTime startDateTime,
    required DateTime endDateTime,
    required int maxAttendees,
    String? category,
    String? timezone,
    int? checkInWindowMinutes,
    String? address,
    String? metaTitle,
    String? metaDescription,
    String? status,
    List<EventTicketTier>? tickets,
    String? imagePath,
  }) async {
    isActionLoading = true;
    update();

    bool success;
    if (eventId != null && eventId.isNotEmpty) {
      success = await EcosystemApi.updateOrganizerEvent(
        eventId: eventId,
        title: title,
        description: description,
        venue: venue,
        city: city,
        country: country,
        isOnline: isOnline,
        onlineUrl: onlineUrl,
        priceFrom: priceFrom,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        maxAttendees: maxAttendees,
        category: category,
        timezone: timezone,
        checkInWindowMinutes: checkInWindowMinutes,
        address: address,
        metaTitle: metaTitle,
        metaDescription: metaDescription,
        status: status,
        tickets: tickets,
        imagePath: imagePath,
      );
    } else {
      success = await EcosystemApi.createOrganizerEvent(
        title: title,
        description: description,
        venue: venue,
        city: city,
        country: country,
        isOnline: isOnline,
        onlineUrl: onlineUrl,
        priceFrom: priceFrom,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        maxAttendees: maxAttendees,
        category: category,
        timezone: timezone,
        checkInWindowMinutes: checkInWindowMinutes,
        address: address,
        metaTitle: metaTitle,
        metaDescription: metaDescription,
        status: status,
        tickets: tickets,
        imagePath: imagePath,
      );
    }

    isActionLoading = false;
    if (success) {
      Utils.showToast(Get.context!, eventId != null ? "Event updated successfully!" : "Event published to Foundation Events page!");
      await loadOrganizerPortal();
      return true;
    } else {
      Utils.showToast(Get.context!, "Failed to save event");
      update();
      return false;
    }
  }

  Future<bool> addCampaign({
    required String title,
    required String description,
    required String beneficiary,
    required double goalAmount,
    DateTime? startDate,
    DateTime? endDate,
    String? imagePath,
  }) async {
    isActionLoading = true;
    update();

    final success = await EcosystemApi.createOrganizerCampaign(
      title: title,
      description: description,
      beneficiary: beneficiary,
      goalAmount: goalAmount,
      startDate: startDate,
      endDate: endDate,
      imagePath: imagePath,
    );

    isActionLoading = false;
    if (success) {
      Utils.showToast(Get.context!, "Campaign published to Foundation Fundraising page!");
      await loadOrganizerPortal();
      return true;
    } else {
      Utils.showToast(Get.context!, "Failed to create campaign");
      update();
      return false;
    }
  }

  // Vendor Action Helpers
  Future<bool> saveVendorProfile({
    String? storeName,
    String? description,
    String? logoPath,
    String? bannerPath,
    String? website,
    String? storeEmail,
    String? storePhone,
    String? storeAddress,
    String? shippingPolicy,
    String? refundPolicy,
    String? supportInfo,
    Map<String, dynamic>? socialLinks,
  }) async {
    isActionLoading = true;
    update();
    final ok = await EcosystemApi.updateVendorProfile(
      storeName: storeName,
      description: description,
      logoPath: logoPath,
      bannerPath: bannerPath,
      website: website,
      storeEmail: storeEmail,
      storePhone: storePhone,
      storeAddress: storeAddress,
      shippingPolicy: shippingPolicy,
      refundPolicy: refundPolicy,
      supportInfo: supportInfo,
      socialLinks: socialLinks,
    );
    isActionLoading = false;
    if (ok) {
      Utils.showToast(Get.context!, "Storefront profile saved successfully!");
      await loadVendorPortal();
    } else {
      Utils.showToast(Get.context!, "Failed to update profile");
      update();
    }
    return ok;
  }

  Future<bool> saveVendorSettings(Map<String, dynamic> settings) async {
    isActionLoading = true;
    update();
    final ok = await EcosystemApi.updateVendorSettings(settings);
    isActionLoading = false;
    if (ok) {
      Utils.showToast(Get.context!, "Vendor settings updated successfully!");
      await loadVendorPortal();
    } else {
      Utils.showToast(Get.context!, "Failed to save settings");
      update();
    }
    return ok;
  }

  Future<bool> submitVendorPayout({
    required double amount,
    String? method,
    Map<String, dynamic>? bankDetails,
    String? notes,
  }) async {
    isActionLoading = true;
    update();
    final ok = await EcosystemApi.requestVendorPayout(
      amount: amount,
      method: method,
      bankDetails: bankDetails,
      notes: notes,
    );
    isActionLoading = false;
    if (ok) {
      Utils.showToast(Get.context!, "Payout request submitted!");
      await loadVendorPortal();
    } else {
      Utils.showToast(Get.context!, "Failed to submit payout request");
      update();
    }
    return ok;
  }

  Future<bool> removeProduct(String productId) async {
    isActionLoading = true;
    update();
    final ok = await EcosystemApi.deleteVendorProduct(productId);
    isActionLoading = false;
    if (ok) {
      Utils.showToast(Get.context!, "Product removed");
      await loadVendorPortal();
    } else {
      Utils.showToast(Get.context!, "Failed to delete product");
      update();
    }
    return ok;
  }

  // Organizer Action Helpers
  Future<bool> saveOrganizerProfile(Map<String, dynamic> data) async {
    isActionLoading = true;
    update();
    final ok = await EcosystemApi.updateOrganizerProfile(data);
    isActionLoading = false;
    if (ok) {
      Utils.showToast(Get.context!, "Organization profile updated!");
      await loadOrganizerPortal();
    } else {
      Utils.showToast(Get.context!, "Failed to update organization profile");
      update();
    }
    return ok;
  }

  Future<bool> saveOrganizerSettings(Map<String, dynamic> data) async {
    isActionLoading = true;
    update();
    final ok = await EcosystemApi.updateOrganizerSettings(data);
    isActionLoading = false;
    if (ok) {
      Utils.showToast(Get.context!, "Organizer settings updated!");
      await loadOrganizerPortal();
    } else {
      Utils.showToast(Get.context!, "Failed to update settings");
      update();
    }
    return ok;
  }

  Future<bool> checkInAttendee(String attendeeId, bool checkedIn) async {
    isActionLoading = true;
    update();
    final ok = await EcosystemApi.checkInOrganizerAttendee(registrationId: attendeeId, checkedIn: checkedIn);
    isActionLoading = false;
    if (ok) {
      Utils.showToast(Get.context!, checkedIn ? "Attendee checked in!" : "Check-in undone");
      await loadOrganizerPortal();
    } else {
      Utils.showToast(Get.context!, "Failed to update attendee check-in");
      update();
    }
    return ok;
  }

  Future<bool> removeEvent(String eventId) async {
    isActionLoading = true;
    update();
    final ok = await EcosystemApi.deleteOrganizerEvent(eventId);
    isActionLoading = false;
    if (ok) {
      Utils.showToast(Get.context!, "Event deleted");
      await loadOrganizerPortal();
    } else {
      Utils.showToast(Get.context!, "Failed to delete event");
      update();
    }
    return ok;
  }

  Future<bool> submitOrganizerPayout({
    required double amount,
    String method = "Direct Bank Transfer",
    required Map<String, dynamic> bankDetails,
    String? notes,
  }) async {
    isActionLoading = true;
    update();
    final ok = await EcosystemApi.requestOrganizerPayout(
      amount: amount,
      method: method,
      bankDetails: bankDetails,
      notes: notes,
    );
    isActionLoading = false;
    if (ok) {
      Utils.showToast(Get.context!, "Payout request submitted!");
      await loadOrganizerPortal();
    } else {
      Utils.showToast(Get.context!, "Failed to submit payout request");
      update();
    }
    return ok;
  }
}
