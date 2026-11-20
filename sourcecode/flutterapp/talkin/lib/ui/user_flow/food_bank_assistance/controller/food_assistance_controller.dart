import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/food_bank_assistance/api/food_assistance_api.dart';
import 'package:notisboard/ui/user_flow/food_bank_assistance/model/food_assistance_model.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

class FoodAssistanceController extends GetxController {
  // Loading states
  var isLoadingLocations = false.obs;
  var isLoadingProducts = false.obs;
  var isLoadingRequests = false.obs;
  var isSubmittingApply = false.obs;
  var isSubmittingCheckout = false.obs;

  // Master Location & Operations Data
  var countries = <FoodBankCountry>[].obs;
  var selectedCity = Rxn<FoodBankCity>();
  var settings = Rxn<FoodBankOperationSettings>();

  // Products & Filter state
  var products = <FoodBankProduct>[].obs;
  var selectedCategory = 'ALL'.obs;
  var selectedDietary = 'ALL'.obs;
  var searchQuery = ''.obs;

  // Parcel builder / cart (productId -> quantity)
  var parcel = <String, int>{}.obs;

  void selectCity(FoodBankCity city) {
    selectedCity.value = city;
    if (city.zones.isNotEmpty) {
      applyZoneId.value = city.zones.first.id;
      checkoutZoneId.value = city.zones.first.id;
    } else {
      applyZoneId.value = '';
      checkoutZoneId.value = '';
    }
    if (city.pickupLocations.isNotEmpty) {
      checkoutPickupLocationId.value = city.pickupLocations.first.id;
    } else {
      checkoutPickupLocationId.value = '';
    }
    clearParcel();
    fetchProductsForCity(city.id);
  }

  // Beneficiary Profile & History
  var beneficiaryProfile = Rxn<BeneficiaryProfile>();
  var myRequests = <FoodBankOrderRecord>[].obs;

  // Beneficiary Apply Form Controllers
  final applyNameController = TextEditingController();
  final applyEmailController = TextEditingController();
  final applyPhoneController = TextEditingController();
  final applyStreetController = TextEditingController();
  final applyUnitController = TextEditingController();
  final applyPostalController = TextEditingController();
  final applyNotesController = TextEditingController();
  var applyZoneId = ''.obs;
  var applyAdults = 1.obs;
  var applyChildren = 0.obs;
  var applySeniors = 0.obs;
  var applyDietaryTags = <String>[].obs;
  var applyIdType = 'GOVERNMENT_PHOTO_ID'.obs;
  var applyIdDocumentPath = ''.obs;
  var applyIdDocumentUrl = ''.obs;
  var isUploadingDocument = false.obs;

  Future<void> pickIdDocument() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        applyIdDocumentPath.value = picked.path;
        isUploadingDocument.value = true;
        final url = await FoodAssistanceApi.uploadDocument(picked.path);
        isUploadingDocument.value = false;
        if (url != null) {
          applyIdDocumentUrl.value = url;
          if (Get.context != null) {
            Utils.showToast(Get.context!, 'Document uploaded successfully!');
          }
        } else {
          if (Get.context != null) {
            Utils.showToast(Get.context!, 'Document selected (will upload on submit)');
          }
        }
      }
    } catch (e) {
      isUploadingDocument.value = false;
      Utils.showLog('pickIdDocument error: $e');
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Image picker error: $e');
      }
    }
  }

  void removeIdDocument() {
    applyIdDocumentPath.value = '';
    applyIdDocumentUrl.value = '';
  }

  // Free Checkout Form Controllers
  final checkoutNameController = TextEditingController();
  final checkoutEmailController = TextEditingController();
  final checkoutPhoneController = TextEditingController();
  final checkoutStreetController = TextEditingController();
  final checkoutUnitController = TextEditingController();
  final checkoutPostalController = TextEditingController();
  final checkoutNotesController = TextEditingController();
  final checkoutDietaryNotesController = TextEditingController();
  var checkoutDeliveryType = 'HOME_DELIVERY'.obs; // HOME_DELIVERY or PICKUP_POINT
  var checkoutZoneId = ''.obs;
  var checkoutPickupLocationId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    prefillUserData();
    fetchLocationsAndProducts();
  }

  void prefillUserData() {
    final user = Database.fetchLoginUserProfileModel?.user;
    if (user != null) {
      final name = user.fullName ?? '';
      final email = user.email ?? '';
      final phone = user.phoneNumber ?? '';

      if (applyNameController.text.isEmpty && name.isNotEmpty) applyNameController.text = name;
      if (applyEmailController.text.isEmpty && email.isNotEmpty) applyEmailController.text = email;
      if (applyPhoneController.text.isEmpty && phone.isNotEmpty) applyPhoneController.text = phone;

      if (checkoutNameController.text.isEmpty && name.isNotEmpty) checkoutNameController.text = name;
      if (checkoutEmailController.text.isEmpty && email.isNotEmpty) checkoutEmailController.text = email;
      if (checkoutPhoneController.text.isEmpty && phone.isNotEmpty) checkoutPhoneController.text = phone;
    }
  }

  Future<void> fetchLocationsAndProducts() async {
    isLoadingLocations.value = true;
    try {
      final res = await FoodAssistanceApi.fetchLocations();
      if (res != null) {
        countries.value = res['countries'] as List<FoodBankCountry>;
        settings.value = res['settings'] as FoodBankOperationSettings?;

        // Locate Toronto, Ontario, Canada as premier active hub
        FoodBankCity? defaultCity;
        for (final country in countries) {
          for (final province in country.provinces) {
            for (final city in province.cities) {
              if (city.isActive) {
                defaultCity = city;
                break;
              }
            }
            if (defaultCity != null) break;
          }
          if (defaultCity != null) break;
        }

        if (defaultCity != null) {
          selectedCity.value = defaultCity;
          if (defaultCity.zones.isNotEmpty) {
            applyZoneId.value = defaultCity.zones.first.id;
            checkoutZoneId.value = defaultCity.zones.first.id;
          }
          if (defaultCity.pickupLocations.isNotEmpty) {
            checkoutPickupLocationId.value = defaultCity.pickupLocations.first.id;
          }
          await fetchProductsForCity(defaultCity.id);
        }
      }
    } catch (e) {
      Utils.showLog('fetchLocationsAndProducts error: $e');
    } finally {
      isLoadingLocations.value = false;
    }

    // Auto-check existing beneficiary status if user email is present
    final userEmail = Database.fetchLoginUserProfileModel?.user?.email;
    if (userEmail != null && userEmail.isNotEmpty) {
      loadMyRequests(userEmail);
    }
  }

  Future<void> fetchProductsForCity(String cityId) async {
    isLoadingProducts.value = true;
    try {
      final list = await FoodAssistanceApi.fetchProducts(cityId: cityId);
      products.value = list;
    } catch (e) {
      Utils.showLog('fetchProductsForCity error: $e');
    } finally {
      isLoadingProducts.value = false;
    }
  }

  // City limit
  int get maxItemsLimit => selectedCity.value?.maxItemsPerRequest ?? settings.value?.maxProductTypesPerOrder ?? 4;

  // Filtered products list
  List<FoodBankProduct> get filteredProducts {
    return products.where((p) {
      if (selectedCategory.value != 'ALL' && p.category != selectedCategory.value) {
        return false;
      }
      if (selectedDietary.value != 'ALL' &&
          !p.dietaryTags.any((t) => t.toLowerCase().contains(selectedDietary.value.toLowerCase()))) {
        return false;
      }
      if (searchQuery.value.trim().isNotEmpty) {
        final q = searchQuery.value.toLowerCase();
        final matchName = p.name.toLowerCase().contains(q);
        final matchDesc = p.description?.toLowerCase().contains(q) ?? false;
        final matchDiet = p.dietaryTags.any((t) => t.toLowerCase().contains(q));
        if (!matchName && !matchDesc && !matchDiet) return false;
      }
      return true;
    }).toList();
  }

  // Total parcel items count
  int get totalParcelItemsCount => parcel.values.fold(0, (sum, count) => sum + count);

  // Number of distinct food types in parcel
  int get distinctParcelTypesCount => parcel.length;

  bool isInParcel(String productId) => parcel.containsKey(productId) && parcel[productId]! > 0;

  int getProductQuantity(String productId) => parcel[productId] ?? 0;

  void addToParcel(FoodBankProduct product, BuildContext context) {
    if (parcel.containsKey(product.id)) {
      final current = parcel[product.id]!;
      if (current >= product.maxPerRequest) {
        Utils.showToast(context, 'Maximum allowed for ${product.name} is ${product.maxPerRequest}');
        return;
      }
      parcel[product.id] = current + 1;
    } else {
      if (distinctParcelTypesCount >= maxItemsLimit) {
        Utils.showToast(context, 'City limit reached: You can select up to $maxItemsLimit staple types per parcel.');
        return;
      }
      parcel[product.id] = 1;
    }
    parcel.refresh();
  }

  void removeFromParcel(String productId) {
    if (parcel.containsKey(productId)) {
      final current = parcel[productId]!;
      if (current > 1) {
        parcel[productId] = current - 1;
      } else {
        parcel.remove(productId);
      }
      parcel.refresh();
    }
  }

  void deleteFromParcel(String productId) {
    parcel.remove(productId);
    parcel.refresh();
  }

  void clearParcel() {
    parcel.clear();
    parcel.refresh();
  }

  // Guard for Free Checkout: Only approved beneficiaries can proceed
  Future<void> handleProceedToCheckout() async {
    final user = Database.fetchLoginUserProfileModel?.user;
    final userEmail = user?.email ?? '';

    if (userEmail.isEmpty) {
      _showKycDialog(
        title: 'Sign In Required',
        message: 'Please sign in to your Notisboard account to request a food parcel.',
        buttonText: 'Sign In →',
        onConfirm: () => Get.toNamed(AppRoutes.mobileLogIn),
      );
      return;
    }

    // If beneficiaryProfile is not loaded yet, fetch status from API
    if (beneficiaryProfile.value == null) {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Color(0xFFE11D48))),
        barrierDismissible: false,
      );
      try {
        final profile = await FoodAssistanceApi.checkBeneficiaryStatus(userEmail);
        if (Get.isDialogOpen == true) Get.back();
        if (profile != null) {
          beneficiaryProfile.value = profile;
        }
      } catch (_) {
        if (Get.isDialogOpen == true) Get.back();
      }
    }

    final profile = beneficiaryProfile.value;

    // 1. Not registered at all
    if (profile == null) {
      _showKycDialog(
        title: 'KYC Verification Required',
        message: 'You have not registered as an authorized beneficiary yet. Please complete a quick household KYC application to unlock free grocery parcel orders.',
        buttonText: 'Complete KYC Application →',
        onConfirm: () => Get.toNamed(AppRoutes.foodAssistanceApplyScreen),
      );
      return;
    }

    // 2. Pending admin review
    if (profile.status == 'PENDING') {
      _showKycDialog(
        title: 'Verification In Review',
        message: 'Your household registration is currently pending review by food bank administrators. Free food parcel checkout will unlock as soon as your account is approved.',
        buttonText: 'Check Application Status →',
        onConfirm: () => Get.toNamed(AppRoutes.foodAssistanceRequestsScreen),
      );
      return;
    }

    // 3. Rejected
    if (profile.status == 'REJECTED') {
      _showKycDialog(
        title: 'Application Not Approved',
        message: 'Your household KYC verification was not approved. Please review and update your registration details.',
        buttonText: 'Update KYC Application →',
        onConfirm: () => Get.toNamed(AppRoutes.foodAssistanceApplyScreen),
      );
      return;
    }

    // 4. Approved -> proceed to checkout!
    if (profile.status == 'APPROVED') {
      Get.toNamed(AppRoutes.foodAssistanceCheckoutScreen);
    } else {
      _showKycDialog(
        title: 'Account Status: ${profile.status}',
        message: 'Your beneficiary account status is ${profile.status}. Please contact relief support.',
        buttonText: 'View Status',
        onConfirm: () => Get.toNamed(AppRoutes.foodAssistanceRequestsScreen),
      );
    }
  }

  void _showKycDialog({
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined, color: Color(0xFFE11D48), size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  minimumSize: const Size(double.infinity, 44),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                ),
                child: const Text('Back to Catalogue', style: TextStyle(fontSize: 12.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Submit Beneficiary KYC Application
  Future<bool> submitBeneficiaryApplication() async {
    final name = applyNameController.text.trim();
    final email = applyEmailController.text.trim();
    final phone = applyPhoneController.text.trim();
    final street = applyStreetController.text.trim();
    final postal = applyPostalController.text.trim().toUpperCase();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || street.isEmpty || postal.isEmpty) {
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Please complete all required fields marked with *');
      }
      return false;
    }

    if (applyIdDocumentPath.value.isEmpty && applyIdDocumentUrl.value.isEmpty) {
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Please upload a photo of your identity document (KYC).');
      }
      return false;
    }

    if (selectedCity.value == null) {
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Active city hub is not selected');
      }
      return false;
    }

    isSubmittingApply.value = true;
    try {
      // If document file was picked but url not ready, upload now
      if (applyIdDocumentUrl.value.isEmpty && applyIdDocumentPath.value.isNotEmpty) {
        final uploaded = await FoodAssistanceApi.uploadDocument(applyIdDocumentPath.value);
        if (uploaded != null) {
          applyIdDocumentUrl.value = uploaded;
        }
      }

      final city = selectedCity.value!;
      // Dynamically resolve parent province and country from selected city
      FoodBankProvince? matchedProvince;
      FoodBankCountry? matchedCountry;
      for (final c in countries) {
        for (final p in c.provinces) {
          if (p.cities.any((ci) => ci.id == city.id)) {
            matchedProvince = p;
            matchedCountry = c;
            break;
          }
        }
        if (matchedCountry != null) break;
      }
      final resolvedCountryId = matchedCountry?.id ?? (countries.isNotEmpty ? countries.first.id : '');
      final resolvedProvinceId = matchedProvince?.id ?? (matchedCountry?.provinces.isNotEmpty == true ? matchedCountry!.provinces.first.id : '');

      final result = await FoodAssistanceApi.applyBeneficiary(
        fullName: name,
        email: email,
        phone: phone,
        countryId: resolvedCountryId,
        provinceId: resolvedProvinceId,
        cityId: city.id,
        zoneId: applyZoneId.value.isNotEmpty ? applyZoneId.value : (city.zones.isNotEmpty ? city.zones.first.id : ''),
        streetAddress: street,
        unit: applyUnitController.text.trim().isNotEmpty ? applyUnitController.text.trim() : null,
        postalCode: postal,
        householdAdults: applyAdults.value,
        householdChildren: applyChildren.value,
        householdSeniors: applySeniors.value,
        dietaryRestrictions: applyDietaryTags.toList(),
        idDocumentType: applyIdType.value,
        idDocumentUrl: applyIdDocumentUrl.value.isNotEmpty ? applyIdDocumentUrl.value : null,
        specialNotes: applyNotesController.text.trim().isNotEmpty ? applyNotesController.text.trim() : null,
      );

      if (result['success'] == true) {
        if (Get.context != null) {
          Utils.showToast(Get.context!, 'Beneficiary application submitted successfully!');
        }
        await loadMyRequests(email);
        return true;
      } else {
        if (Get.context != null) {
          Utils.showToast(Get.context!, result['error']?.toString() ?? 'Application failed');
        }
        return false;
      }
    } catch (e) {
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Failed to submit application: $e');
      }
      return false;
    } finally {
      isSubmittingApply.value = false;
    }
  }

  // Load Beneficiary Profile and Request History
  Future<void> loadMyRequests(String email) async {
    if (email.trim().isEmpty) return;
    isLoadingRequests.value = true;
    try {
      final data = await FoodAssistanceApi.fetchMyRequests(email);
      if (data != null) {
        beneficiaryProfile.value = data['beneficiary'] as BeneficiaryProfile?;
        myRequests.value = data['orders'] as List<FoodBankOrderRecord>;
      }
    } catch (e) {
      Utils.showLog('loadMyRequests error: $e');
    } finally {
      isLoadingRequests.value = false;
    }
  }

  // Submit Free Food Assistance Checkout ($0.00)
  Future<Map<String, dynamic>> submitFreeOrderCheckout() async {
    if (parcel.isEmpty) {
      return {'success': false, 'error': 'Your food parcel is empty'};
    }

    final email = checkoutEmailController.text.trim();
    final name = checkoutNameController.text.trim();
    final phone = checkoutPhoneController.text.trim();

    if (email.isEmpty || name.isEmpty || phone.isEmpty) {
      return {'success': false, 'error': 'Please fill recipient name, email, and phone number'};
    }

    if (selectedCity.value == null) {
      return {'success': false, 'error': 'City hub not selected'};
    }

    if (checkoutDeliveryType.value == 'HOME_DELIVERY') {
      if (checkoutStreetController.text.trim().isEmpty || checkoutPostalController.text.trim().isEmpty) {
        return {'success': false, 'error': 'Please provide street address and postal code for delivery'};
      }
    }

    isSubmittingCheckout.value = true;
    try {
      final itemsPayload = parcel.entries.map((entry) {
        return {
          'productId': entry.key,
          'quantity': entry.value,
        };
      }).toList();

      final res = await FoodAssistanceApi.submitCheckout(
        cityId: selectedCity.value!.id,
        beneficiaryEmail: email,
        beneficiaryName: name,
        beneficiaryPhone: phone,
        deliveryType: checkoutDeliveryType.value,
        pickupLocationId: checkoutDeliveryType.value == 'PICKUP_POINT' ? checkoutPickupLocationId.value : null,
        zoneId: checkoutDeliveryType.value == 'HOME_DELIVERY' ? checkoutZoneId.value : null,
        deliveryStreet: checkoutDeliveryType.value == 'HOME_DELIVERY' ? checkoutStreetController.text.trim() : null,
        deliveryUnit: checkoutDeliveryType.value == 'HOME_DELIVERY' && checkoutUnitController.text.trim().isNotEmpty
            ? checkoutUnitController.text.trim()
            : null,
        deliveryPostalCode: checkoutDeliveryType.value == 'HOME_DELIVERY' ? checkoutPostalController.text.trim().toUpperCase() : null,
        deliveryNotes: checkoutNotesController.text.trim().isNotEmpty ? checkoutNotesController.text.trim() : null,
        specialDietaryNotes: checkoutDietaryNotesController.text.trim().isNotEmpty
            ? checkoutDietaryNotesController.text.trim()
            : null,
        items: itemsPayload,
      );

      if (res['success'] == true) {
        clearParcel();
        await loadMyRequests(email);
        return {'success': true, 'data': res['data']};
      } else {
        return {'success': false, 'error': res['error'] ?? 'Checkout failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    } finally {
      isSubmittingCheckout.value = false;
    }
  }

  @override
  void onClose() {
    applyNameController.dispose();
    applyEmailController.dispose();
    applyPhoneController.dispose();
    applyStreetController.dispose();
    applyUnitController.dispose();
    applyPostalController.dispose();
    applyNotesController.dispose();

    checkoutNameController.dispose();
    checkoutEmailController.dispose();
    checkoutPhoneController.dispose();
    checkoutStreetController.dispose();
    checkoutUnitController.dispose();
    checkoutPostalController.dispose();
    checkoutNotesController.dispose();
    checkoutDietaryNotesController.dispose();
    super.onClose();
  }
}
