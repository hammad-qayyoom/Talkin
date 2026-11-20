import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    if (selectedCity.value == null) {
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Active city hub is not selected');
      }
      return false;
    }

    isSubmittingApply.value = true;
    try {
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
