import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:notisboard/ui/host_flow/ecosystem/models/ecosystem_items_model.dart';
import 'package:notisboard/ui/host_flow/ecosystem/models/ecosystem_status_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class EcosystemApi {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await FirebaseAccessToken.onGet();
    final uid = Database.loginUserFirebaseId;
    return {
      "key": Api.secretKey,
      "x-auth-token": "Bearer $token",
      "x-auth-uid": uid,
    };
  }

  // 0. Fetch Platform Operating Currency (Admin single source of truth)
  static Future<PlatformCurrency> getPlatformCurrency() async {
    try {
      final response = await http.get(
        Uri.parse(Api.expertEcosystemCurrency),
        headers: {"key": Api.secretKey},
      );
      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        if (jsonResult['data'] is Map<String, dynamic>) {
          return PlatformCurrency.fromJson(jsonResult['data']);
        }
      }
    } catch (e) {
      Utils.showLog("EcosystemApi.getPlatformCurrency Error: $e");
    }
    return PlatformCurrency();
  }

  // 1. Fetch Ecosystem Status
  static Future<EcosystemStatusModel?> getStatus() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(Api.expertEcosystemStatus),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        return EcosystemStatusModel.fromJson(jsonResult);
      }
    } catch (e) {
      Utils.showLog("EcosystemApi.getStatus Error: $e");
    }
    return null;
  }

  // 2. Submit Vendor Application (Full Fields matching Foundation Website)
  static Future<Map<String, dynamic>?> applyVendor({
    required String applicantType, // 'individual' or 'business'
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
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Api.expertEcosystemApplyVendor),
      );

      request.headers.addAll(headers);
      request.fields['applicantType'] = applicantType;
      request.fields['firstName'] = firstName;
      request.fields['middleName'] = middleName;
      request.fields['lastName'] = lastName;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['citizenship'] = citizenship;
      request.fields['dateOfBirth'] = dateOfBirth;
      request.fields['placeOfBirth'] = placeOfBirth;
      request.fields['countryOfResidence'] = countryOfResidence;
      request.fields['residentialAddress'] = residentialAddress;
      request.fields['city'] = city;
      request.fields['state'] = state;
      request.fields['postalCode'] = postalCode;
      request.fields['registeredBusinessName'] = registeredBusinessName;
      request.fields['businessName'] = businessName;
      request.fields['businessType'] = businessType;
      request.fields['taxId'] = taxId;
      request.fields['governmentIdType'] = governmentIdType;
      request.fields['governmentIdExpirationDate'] = governmentIdExpirationDate;
      request.fields['proofOfAddressType'] = proofOfAddressType;
      request.fields['password'] = password;
      request.fields['confirmPassword'] = confirmPassword;
      request.fields['description'] = description;
      request.fields['website'] = website;
      request.fields['motivation'] = motivation;

      for (final entry in documentFilePaths.entries) {
        if (entry.value.isNotEmpty) {
          request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value));
        }
      }

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      Utils.showLog("EcosystemApi.applyVendor Error: $e");
      return null;
    }
  }

  // 3. Submit Organizer Application (Full Fields matching Foundation Website)
  static Future<Map<String, dynamic>?> applyOrganizer({
    required String applicantType, // 'individual' or 'organization'
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
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Api.expertEcosystemApplyOrganizer),
      );

      request.headers.addAll(headers);
      request.fields['applicantType'] = applicantType;
      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['city'] = city;
      request.fields['country'] = country;
      request.fields['organizationName'] = organizationName;
      request.fields['organizationType'] = organizationType;
      request.fields['website'] = website;
      request.fields['password'] = password;
      request.fields['confirmPassword'] = confirmPassword;
      request.fields['legalName'] = legalName;
      request.fields['dateOfBirth'] = dateOfBirth;
      request.fields['address'] = address;
      request.fields['idDocumentType'] = idDocumentType;
      request.fields['taxId'] = taxId;
      request.fields['bankName'] = bankName;
      request.fields['bankAccountName'] = bankAccountName;
      request.fields['bankAccountNumber'] = bankAccountNumber;
      request.fields['bankRoutingNumber'] = bankRoutingNumber;
      request.fields['experience'] = experience;
      request.fields['description'] = description;
      request.fields['motivation'] = motivation;

      for (final entry in documentFilePaths.entries) {
        if (entry.value.isNotEmpty) {
          request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value));
        }
      }

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      Utils.showLog("EcosystemApi.applyOrganizer Error: $e");
      return null;
    }
  }

  // 4. Vendor Portal: Data, Payout, Order Status
  static Future<VendorPortalData?> getVendorPortalData() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(Api.expertEcosystemVendorPortalData),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        if (jsonResult['data'] != null) {
          return VendorPortalData.fromJson(jsonResult['data']);
        }
      }
    } catch (e) {
      Utils.showLog("EcosystemApi.getVendorPortalData Error: $e");
    }
    return null;
  }

  static Future<bool> updateVendorOrderStatus({
    required String subOrderId,
    required String status,
    String? trackingNumber,
    String? trackingCarrier,
  }) async {
    try {
      final headers = await _getHeaders();
      headers["Content-Type"] = "application/json";
      final response = await http.patch(
        Uri.parse("${Api.expertEcosystemVendorOrderStatus}$subOrderId/status"),
        headers: headers,
        body: jsonEncode({
          "status": status,
          "trackingNumber": trackingNumber,
          "trackingCarrier": trackingCarrier,
        }),
      );
      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        return jsonResult["status"] == true || jsonResult["success"] == true;
      } else {
        try {
          final jsonResult = jsonDecode(response.body);
          final msg = jsonResult["message"] ?? jsonResult["error"];
          if (msg != null && msg.toString().isNotEmpty) {
            Utils.showToast(Get.context!, msg.toString());
            return false;
          }
        } catch (_) {}
        return false;
      }
    } catch (e) {
      Utils.showLog("EcosystemApi.updateVendorOrderStatus Error: $e");
      return false;
    }
  }

  static Future<bool> requestVendorPayout({
    required double amount,
    String? method,
    Map<String, dynamic>? bankDetails,
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders();
      headers["Content-Type"] = "application/json";
      final response = await http.post(
        Uri.parse(Api.expertEcosystemVendorPayouts),
        headers: headers,
        body: jsonEncode({
          "amount": amount,
          if (method != null) "method": method,
          if (bankDetails != null) "bankDetails": bankDetails,
          if (notes != null) "notes": notes,
        }),
      );
      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        return jsonResult["status"] == true || jsonResult["success"] == true;
      } else {
        try {
          final jsonResult = jsonDecode(response.body);
          final msg = jsonResult["message"] ?? jsonResult["error"];
          if (msg != null && msg.toString().isNotEmpty) {
            Utils.showToast(Get.context!, msg.toString());
            return false;
          }
        } catch (_) {}
        return false;
      }
    } catch (e) {
      Utils.showLog("EcosystemApi.requestVendorPayout Error: $e");
      return false;
    }
  }

  // 5. Organizer Portal: Data, Payout
  static Future<OrganizerPortalData?> getOrganizerPortalData() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(Api.expertEcosystemOrganizerPortalData),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        if (jsonResult['data'] != null) {
          return OrganizerPortalData.fromJson(jsonResult['data']);
        }
      }
    } catch (e) {
      Utils.showLog("EcosystemApi.getOrganizerPortalData Error: $e");
    }
    return null;
  }

  static Future<bool> requestOrganizerPayout({
    required double amount,
    String method = "Direct Bank Transfer",
    required Map<String, dynamic> bankDetails,
    String? notes,
    String source = "EVENTS",
    String? campaignId,
  }) async {
    try {
      final headers = await _getHeaders();
      headers["Content-Type"] = "application/json";
      final response = await http.post(
        Uri.parse(Api.expertEcosystemOrganizerPayouts),
        headers: headers,
        body: jsonEncode({
          "amount": amount,
          "method": method,
          "bankDetails": {
            ...bankDetails,
            "source": source,
            if (campaignId != null) "campaignId": campaignId,
          },
          "source": source,
          if (campaignId != null) "campaignId": campaignId,
          "notes": notes ?? "Organizer settlement request from Mobile App",
        }),
      );
      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        return jsonResult["status"] == true || jsonResult["success"] == true;
      } else {
        try {
          final jsonResult = jsonDecode(response.body);
          final msg = jsonResult["message"] ?? jsonResult["error"];
          if (msg != null && msg.toString().isNotEmpty) {
            Utils.showToast(Get.context!, msg.toString());
            return false;
          }
        } catch (_) {}
        Utils.showToast(Get.context!, "Failed to submit payout request");
        return false;
      }
    } catch (e) {
      Utils.showLog("EcosystemApi.requestOrganizerPayout Error: $e");
      Utils.showToast(Get.context!, "Network error submitting payout request");
      return false;
    }
  }

  // 6. Products: List & Create
  static Future<List<EcosystemProduct>> listVendorProducts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(Api.expertEcosystemProducts),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        if (jsonResult['data'] is List) {
          return (jsonResult['data'] as List)
              .map((item) => EcosystemProduct.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      Utils.showLog("EcosystemApi.listVendorProducts Error: $e");
    }
    return [];
  }

  static Future<bool> createVendorProduct({
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
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Api.expertEcosystemProducts),
      );

      request.headers.addAll(headers);
      request.fields['title'] = title;
      if (brand != null && brand.isNotEmpty) request.fields['brand'] = brand;
      if (categoryId != null && categoryId.isNotEmpty) request.fields['categoryId'] = categoryId;
      if (categoryName != null && categoryName.isNotEmpty) request.fields['categoryName'] = categoryName;
      if (productType != null && productType.isNotEmpty) request.fields['productType'] = productType;
      if (badge != null && badge.isNotEmpty) request.fields['badge'] = badge;
      if (tags != null && tags.isNotEmpty) request.fields['tags'] = jsonEncode(tags);
      request.fields['price'] = price.toString();
      if (compareAtPrice != null) request.fields['compareAtPrice'] = compareAtPrice.toString();
      if (costPrice != null) request.fields['costPrice'] = costPrice.toString();
      request.fields['inventory'] = inventory.toString();
      if (sku != null && sku.isNotEmpty) request.fields['sku'] = sku;
      if (lowStockThreshold != null) request.fields['lowStockThreshold'] = lowStockThreshold.toString();
      request.fields['trackInventory'] = trackInventory.toString();
      request.fields['description'] = description;
      if (impact != null && impact.isNotEmpty) request.fields['impact'] = impact;
      if (features != null && features.isNotEmpty) request.fields['features'] = jsonEncode(features);
      if (specifications != null && specifications.isNotEmpty) request.fields['specifications'] = jsonEncode(specifications);
      if (variants != null && variants.isNotEmpty) request.fields['variants'] = jsonEncode(variants);
      if (weight != null) request.fields['weight'] = weight.toString();
      if (dimensions != null) request.fields['dimensions'] = jsonEncode(dimensions);
      if (shippingClassification != null && shippingClassification.isNotEmpty) {
        request.fields['shippingClassification'] = shippingClassification;
      }
      if (shippingSurcharge != null) request.fields['shippingSurcharge'] = shippingSurcharge.toString();
      if (returnPolicy != null && returnPolicy.isNotEmpty) request.fields['returnPolicy'] = returnPolicy;
      request.fields['isDraft'] = isDraft.toString();
      if (galleryImageUrls != null && galleryImageUrls.isNotEmpty) {
        request.fields['images'] = jsonEncode(galleryImageUrls);
      }

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final streamedResponse = await request.send();
      return streamedResponse.statusCode == 200;
    } catch (e) {
      Utils.showLog("EcosystemApi.createVendorProduct Error: $e");
      return false;
    }
  }

  // 7. Events: List & Create
  static Future<List<EcosystemEvent>> listOrganizerEvents() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(Api.expertEcosystemEvents),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        if (jsonResult['data'] is List) {
          return (jsonResult['data'] as List)
              .map((item) => EcosystemEvent.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      Utils.showLog("EcosystemApi.listOrganizerEvents Error: $e");
    }
    return [];
  }

  static Future<bool> createOrganizerEvent({
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
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Api.expertEcosystemEvents),
      );

      request.headers.addAll(headers);
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['venue'] = venue;
      request.fields['city'] = city;
      request.fields['country'] = country;
      request.fields['isOnline'] = isOnline.toString();
      if (onlineUrl != null) request.fields['onlineUrl'] = onlineUrl;
      request.fields['priceFrom'] = priceFrom.toString();
      request.fields['startDateTime'] = startDateTime.toIso8601String();
      request.fields['endDateTime'] = endDateTime.toIso8601String();
      request.fields['maxAttendees'] = maxAttendees.toString();
      if (category != null && category.isNotEmpty) request.fields['categoryName'] = category;
      if (timezone != null && timezone.isNotEmpty) request.fields['timezone'] = timezone;
      if (checkInWindowMinutes != null) request.fields['checkInWindowMinutes'] = checkInWindowMinutes.toString();
      if (address != null && address.isNotEmpty) request.fields['address'] = address;
      if (metaTitle != null && metaTitle.isNotEmpty) request.fields['metaTitle'] = metaTitle;
      if (metaDescription != null && metaDescription.isNotEmpty) request.fields['metaDescription'] = metaDescription;
      if (status != null && status.isNotEmpty) request.fields['status'] = status;

      if (tickets != null && tickets.isNotEmpty) {
        request.fields['tickets'] = jsonEncode(tickets.map((t) => t.toJson()).toList());
      }

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final streamedResponse = await request.send();
      return streamedResponse.statusCode == 200;
    } catch (e) {
      Utils.showLog("EcosystemApi.createOrganizerEvent Error: $e");
      return false;
    }
  }

  static Future<bool> updateOrganizerEvent({
    required String eventId,
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
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse("${Api.expertEcosystemEvents}/$eventId"),
      );

      request.headers.addAll(headers);
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['venue'] = venue;
      request.fields['city'] = city;
      request.fields['country'] = country;
      request.fields['isOnline'] = isOnline.toString();
      if (onlineUrl != null) request.fields['onlineUrl'] = onlineUrl;
      request.fields['priceFrom'] = priceFrom.toString();
      request.fields['startDateTime'] = startDateTime.toIso8601String();
      request.fields['endDateTime'] = endDateTime.toIso8601String();
      request.fields['maxAttendees'] = maxAttendees.toString();
      if (category != null && category.isNotEmpty) request.fields['categoryName'] = category;
      if (timezone != null && timezone.isNotEmpty) request.fields['timezone'] = timezone;
      if (checkInWindowMinutes != null) request.fields['checkInWindowMinutes'] = checkInWindowMinutes.toString();
      if (address != null && address.isNotEmpty) request.fields['address'] = address;
      if (metaTitle != null && metaTitle.isNotEmpty) request.fields['metaTitle'] = metaTitle;
      if (metaDescription != null && metaDescription.isNotEmpty) request.fields['metaDescription'] = metaDescription;
      if (status != null && status.isNotEmpty) request.fields['status'] = status;

      if (tickets != null && tickets.isNotEmpty) {
        request.fields['tickets'] = jsonEncode(tickets.map((t) => t.toJson()).toList());
      }

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final streamedResponse = await request.send();
      return streamedResponse.statusCode == 200;
    } catch (e) {
      Utils.showLog("EcosystemApi.updateOrganizerEvent Error: $e");
      return false;
    }
  }

  // 8. Campaigns: List & Create
  static Future<List<EcosystemCampaign>> listOrganizerCampaigns() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(Api.expertEcosystemCampaigns),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        if (jsonResult['data'] is List) {
          return (jsonResult['data'] as List)
              .map((item) => EcosystemCampaign.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      Utils.showLog("EcosystemApi.listOrganizerCampaigns Error: $e");
    }
    return [];
  }

  static Future<bool> createOrganizerCampaign({
    required String title,
    required String description,
    required String beneficiary,
    required double goalAmount,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? imagePath,
  }) async {
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Api.expertEcosystemCampaigns),
      );

      request.headers.addAll(headers);
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['beneficiary'] = beneficiary;
      request.fields['goalAmount'] = goalAmount.toString();
      request.fields['status'] = status ?? "PENDING_REVIEW";
      if (startDate != null) request.fields['startDate'] = startDate.toIso8601String();
      if (endDate != null) request.fields['endDate'] = endDate.toIso8601String();

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final streamedResponse = await request.send();
      return streamedResponse.statusCode == 200;
    } catch (e) {
      Utils.showLog("EcosystemApi.createOrganizerCampaign Error: $e");
      return false;
    }
  }

  // 9. Vendor: Profile & Settings & Product Mutations
  static Future<bool> updateVendorProfile({
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
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(Api.expertEcosystemVendorProfile),
      );
      request.headers.addAll(headers);

      if (storeName != null) request.fields['storeName'] = storeName;
      if (description != null) request.fields['description'] = description;
      if (website != null) request.fields['website'] = website;
      if (storeEmail != null) request.fields['storeEmail'] = storeEmail;
      if (storePhone != null) request.fields['storePhone'] = storePhone;
      if (storeAddress != null) request.fields['storeAddress'] = storeAddress;
      if (shippingPolicy != null) request.fields['shippingPolicy'] = shippingPolicy;
      if (refundPolicy != null) request.fields['refundPolicy'] = refundPolicy;
      if (supportInfo != null) request.fields['supportInfo'] = supportInfo;
      if (socialLinks != null) request.fields['socialLinks'] = jsonEncode(socialLinks);

      if (logoPath != null && logoPath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('logo', logoPath));
      }
      if (bannerPath != null && bannerPath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('banner', bannerPath));
      }

      final res = await request.send();
      return res.statusCode == 200;
    } catch (e) {
      Utils.showLog("EcosystemApi.updateVendorProfile Error: $e");
      return false;
    }
  }

  static Future<bool> updateVendorSettings(Map<String, dynamic> settings) async {
    try {
      final headers = await _getHeaders();
      headers["Content-Type"] = "application/json";
      final res = await http.put(
        Uri.parse(Api.expertEcosystemVendorSettings),
        headers: headers,
        body: jsonEncode(settings),
      );
      return res.statusCode == 200;
    } catch (e) {
      Utils.showLog("EcosystemApi.updateVendorSettings Error: $e");
      return false;
    }
  }

  static Future<bool> updateVendorProduct({
    required String productId,
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
    bool isActive = false,
    String? imagePath,
    List<String>? galleryImageUrls,
  }) async {
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse("${Api.expertEcosystemProducts}/$productId"),
      );
      request.headers.addAll(headers);

      request.fields['title'] = title;
      if (brand != null && brand.isNotEmpty) request.fields['brand'] = brand;
      if (categoryId != null && categoryId.isNotEmpty) request.fields['categoryId'] = categoryId;
      if (categoryName != null && categoryName.isNotEmpty) request.fields['categoryName'] = categoryName;
      if (productType != null && productType.isNotEmpty) request.fields['productType'] = productType;
      if (badge != null && badge.isNotEmpty) request.fields['badge'] = badge;
      if (tags != null && tags.isNotEmpty) request.fields['tags'] = jsonEncode(tags);
      request.fields['price'] = price.toString();
      if (compareAtPrice != null) request.fields['compareAtPrice'] = compareAtPrice.toString();
      if (costPrice != null) request.fields['costPrice'] = costPrice.toString();
      request.fields['inventory'] = inventory.toString();
      if (sku != null && sku.isNotEmpty) request.fields['sku'] = sku;
      if (lowStockThreshold != null) request.fields['lowStockThreshold'] = lowStockThreshold.toString();
      request.fields['trackInventory'] = trackInventory.toString();
      request.fields['description'] = description;
      if (impact != null && impact.isNotEmpty) request.fields['impact'] = impact;
      if (features != null && features.isNotEmpty) request.fields['features'] = jsonEncode(features);
      if (specifications != null && specifications.isNotEmpty) request.fields['specifications'] = jsonEncode(specifications);
      if (variants != null && variants.isNotEmpty) request.fields['variants'] = jsonEncode(variants);
      if (weight != null) request.fields['weight'] = weight.toString();
      if (dimensions != null) request.fields['dimensions'] = jsonEncode(dimensions);
      if (shippingClassification != null && shippingClassification.isNotEmpty) {
        request.fields['shippingClassification'] = shippingClassification;
      }
      if (shippingSurcharge != null) request.fields['shippingSurcharge'] = shippingSurcharge.toString();
      if (returnPolicy != null && returnPolicy.isNotEmpty) request.fields['returnPolicy'] = returnPolicy;
      request.fields['isDraft'] = isDraft.toString();
      request.fields['status'] = isDraft ? "DRAFT" : "PENDING_REVIEW";
      request.fields['isActive'] = isActive.toString();
      if (galleryImageUrls != null && galleryImageUrls.isNotEmpty) {
        request.fields['images'] = jsonEncode(galleryImageUrls);
      }

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final res = await request.send();
      return res.statusCode == 200;
    } catch (e) {
      Utils.showLog("EcosystemApi.updateVendorProduct Error: $e");
      return false;
    }
  }

  static Future<bool> deleteVendorProduct(String productId) async {
    try {
      final headers = await _getHeaders();
      final res = await http.delete(
        Uri.parse("${Api.expertEcosystemProducts}/$productId"),
        headers: headers,
      );
      return res.statusCode == 200;
    } catch (e) {
      Utils.showLog("EcosystemApi.deleteVendorProduct Error: $e");
      return false;
    }
  }

  // 10. Organizer: Profile & Settings & Attendees Mutations
  static Future<bool> updateOrganizerProfile(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      headers["Content-Type"] = "application/json";
      final res = await http.put(
        Uri.parse(Api.expertEcosystemOrganizerProfile),
        headers: headers,
        body: jsonEncode(data),
      );
      return res.statusCode == 200;
    } catch (e) {
      Utils.showLog("EcosystemApi.updateOrganizerProfile Error: $e");
      return false;
    }
  }

  static Future<bool> updateOrganizerSettings(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      headers["Content-Type"] = "application/json";
      final res = await http.put(
        Uri.parse(Api.expertEcosystemOrganizerSettings),
        headers: headers,
        body: jsonEncode(data),
      );
      return res.statusCode == 200;
    } catch (e) {
      Utils.showLog("EcosystemApi.updateOrganizerSettings Error: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> checkInOrganizerAttendee({
    required String registrationId,
    bool checkedIn = true,
    bool forceOverride = false,
  }) async {
    try {
      final headers = await _getHeaders();
      headers["Content-Type"] = "application/json";
      final res = await http.patch(
        Uri.parse("${Api.expertEcosystemOrganizerCheckIn}$registrationId/checkin"),
        headers: headers,
        body: jsonEncode({
          "checkedIn": checkedIn,
          "forceOverride": forceOverride,
        }),
      );
      final json = jsonDecode(res.body);
      return {
        "success": res.statusCode == 200 && json["status"] != false,
        "message": json["message"] ?? json["error"] ?? (res.statusCode == 200 ? "Updated" : "Check-in failed"),
        "windowNotOpen": json["windowNotOpen"] == true,
        "data": json["data"],
      };
    } catch (e) {
      Utils.showLog("EcosystemApi.checkInOrganizerAttendee Error: $e");
      return {"success": false, "message": "$e"};
    }
  }

  static Future<Map<String, dynamic>> lookupOrganizerTicket({
    required String eventId,
    required String code,
    bool autoCheckIn = false,
    bool forceOverride = false,
  }) async {
    try {
      final headers = await _getHeaders();
      headers["Content-Type"] = "application/json";
      final res = await http.post(
        Uri.parse("${Api.expertEcosystemEvents}/$eventId/qr-lookup"),
        headers: headers,
        body: jsonEncode({
          "code": code,
          "autoCheckIn": autoCheckIn,
          "forceOverride": forceOverride,
        }),
      );
      final json = jsonDecode(res.body);
      final dataMap = (json is Map && json["data"] is Map<String, dynamic>)
          ? json["data"] as Map<String, dynamic>
          : <String, dynamic>{};
      final bool isSuccess = res.statusCode == 200 &&
          json["status"] != false &&
          json["success"] != false &&
          dataMap["success"] != false;
      return {
        ...dataMap,
        if (json is Map<String, dynamic>) ...json,
        "success": isSuccess,
        "message": dataMap["message"] ??
            json["message"] ??
            dataMap["error"] ??
            json["error"] ??
            (isSuccess ? "Ticket verified" : "Verification failed"),
        "data": dataMap.isNotEmpty ? dataMap : json,
      };
    } catch (e) {
      Utils.showLog("EcosystemApi.lookupOrganizerTicket Error: $e");
      return {"success": false, "message": "$e"};
    }
  }

  static Future<bool> deleteOrganizerEvent(String eventId) async {
    try {
      final headers = await _getHeaders();
      final res = await http.delete(
        Uri.parse("${Api.expertEcosystemEvents}/$eventId"),
        headers: headers,
      );
      return res.statusCode == 200;
    } catch (e) {
      Utils.showLog("EcosystemApi.deleteOrganizerEvent Error: $e");
      return false;
    }
  }
}
