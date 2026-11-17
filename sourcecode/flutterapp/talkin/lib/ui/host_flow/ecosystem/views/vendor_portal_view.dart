import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notisboard/ui/host_flow/ecosystem/controllers/ecosystem_controller.dart';
import 'package:notisboard/ui/host_flow/ecosystem/models/ecosystem_items_model.dart';
import 'package:notisboard/utils/font_style.dart';

class VendorPortalView extends StatefulWidget {
  const VendorPortalView({super.key});

  @override
  State<VendorPortalView> createState() => _VendorPortalViewState();
}

class _VendorPortalViewState extends State<VendorPortalView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedPageIndex = 1; // Default to Dashboard (Page 1)

  // ══════════════════════════════════════════════════════════════
  // 9-STEP PRODUCT WIZARD STATE
  // ══════════════════════════════════════════════════════════════
  int _wizardStep = 1; // 1 to 9
  EcosystemProduct? _editingProduct; // null = create mode, not null = edit mode

  // Step 1: Basic Info
  final _prodTitleCtrl = TextEditingController();
  final _prodBrandCtrl = TextEditingController();
  String _prodCategory = "Official Foundation Merch";
  String _prodProductType = "PHYSICAL";
  String _prodBadge = "Artisan Made";
  final _prodTagsCtrl = TextEditingController(text: "handcrafted, sustainable");

  // Step 2: Media
  String? _prodImagePath;
  final _prodImageUrlCtrl = TextEditingController();
  final List<String> _prodGalleryUrls = [];
  final _newGalleryUrlCtrl = TextEditingController();

  // Step 3: Description & Story
  final _prodDescCtrl = TextEditingController();
  final _prodImpactCtrl = TextEditingController();
  final List<String> _prodHighlights = [
    "Sustainably sourced materials",
    "100% fair-trade certified",
  ];
  final _newHighlightCtrl = TextEditingController();
  final List<MapEntry<String, String>> _prodSpecs = [
    const MapEntry("Material", "Organic Cotton / Natural Wood"),
    const MapEntry("Origin", "Handcrafted in Artisan Workshop"),
  ];
  final _newSpecKeyCtrl = TextEditingController();
  final _newSpecValCtrl = TextEditingController();

  // Step 4: Pricing & Net Earnings
  final _prodPriceCtrl = TextEditingController(text: "45.00");
  final _prodComparePriceCtrl = TextEditingController(text: "60.00");
  final _prodCostPriceCtrl = TextEditingController(text: "20.00");

  // Step 5: Inventory & SKU
  final _prodSkuCtrl = TextEditingController();
  final _prodInventoryCtrl = TextEditingController(text: "50");
  final _prodLowStockCtrl = TextEditingController(text: "5");
  bool _prodTrackInventory = true;

  // Step 6: Variants
  bool _hasVariants = false;
  final List<Map<String, dynamic>> _variantsList = [];
  final _variantNameCtrl = TextEditingController();
  final _variantSkuCtrl = TextEditingController();
  final _variantPriceCtrl = TextEditingController();
  final _variantInvCtrl = TextEditingController(text: "20");

  // Step 7: Shipping & Packaging
  String _shippingClassification = "standard";
  final _prodWeightCtrl = TextEditingController(text: "0.5");
  final _prodLengthCtrl = TextEditingController(text: "10");
  final _prodWidthCtrl = TextEditingController(text: "10");
  final _prodHeightCtrl = TextEditingController(text: "5");
  String _processingTime = "1-3 business days";
  bool _freeShipping = true;

  // Step 8: Returns & Policies
  String _prodReturnPolicy = "30-Day Charitable Return Policy";
  final _prodWarrantyCtrl = TextEditingController(text: "1-year artisan craftsmanship guarantee");

  // KYC Page switcher state
  String _kycDossierType = "individual"; // 'individual' or 'business'

  // Store Profile Controllers
  final _storeNameCtrl = TextEditingController();
  final _storeBioCtrl = TextEditingController();
  final _storeWebsiteCtrl = TextEditingController();
  final _storeEmailCtrl = TextEditingController();
  final _storePhoneCtrl = TextEditingController();
  final _storeAddressCtrl = TextEditingController();
  final _shippingPolicyCtrl = TextEditingController();
  final _refundPolicyCtrl = TextEditingController();
  final _supportInfoCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final _facebookCtrl = TextEditingController();
  final _twitterCtrl = TextEditingController();
  bool _profileInitialized = false;

  // Settings Controllers
  String _payoutMethod = "Direct Bank Transfer";
  final _bankNameCtrl = TextEditingController();
  final _accountHolderCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _routingNumberCtrl = TextEditingController();
  int _handlingDays = 2;
  bool _notifyOrder = true;
  bool _notifyPayout = true;
  bool _notifyStock = true;
  bool _settingsInitialized = false;

  // Filters & Search
  String _productFilter = "ALL";
  String _orderStatusFilter = "ALL";
  String _orderSearchQuery = "";
  String _productSearchQuery = "";

  final List<String> _productCategories = [
    "Official Foundation Merch",
    "Apparel & Clothing",
    "Handmade & Artisan Crafts",
    "Art & Collectibles",
    "Books & Literature",
    "Home & Living",
    "Charity Gifts & Souvenirs",
  ];

  final List<String> _productTypes = [
    "PHYSICAL",
    "DIGITAL",
    "SERVICE",
    "BUNDLE",
  ];

  final List<String> _highlightBadges = [
    "Artisan Made",
    "Handcrafted",
    "Fair Trade Certified",
    "Bestseller",
    "100% Organic",
    "Sustainable",
    "Official Merch",
  ];

  final List<String> _returnPolicies = [
    "30-Day Charitable Return Policy",
    "14-Day Standard Return Policy",
    "Exchange Only Policy",
    "All Sales Final (Non-refundable)",
  ];

  final List<String> _dispatchTimes = [
    "Same day dispatch",
    "1-2 business days",
    "1-3 business days",
    "3-5 business days",
    "1-2 weeks (Made to Order)",
  ];

  @override
  void dispose() {
    _prodTitleCtrl.dispose();
    _prodBrandCtrl.dispose();
    _prodTagsCtrl.dispose();
    _prodImageUrlCtrl.dispose();
    _newGalleryUrlCtrl.dispose();
    _prodDescCtrl.dispose();
    _prodImpactCtrl.dispose();
    _newHighlightCtrl.dispose();
    _newSpecKeyCtrl.dispose();
    _newSpecValCtrl.dispose();
    _prodPriceCtrl.dispose();
    _prodComparePriceCtrl.dispose();
    _prodCostPriceCtrl.dispose();
    _prodSkuCtrl.dispose();
    _prodInventoryCtrl.dispose();
    _prodLowStockCtrl.dispose();
    _variantNameCtrl.dispose();
    _variantSkuCtrl.dispose();
    _variantPriceCtrl.dispose();
    _variantInvCtrl.dispose();
    _prodWeightCtrl.dispose();
    _prodLengthCtrl.dispose();
    _prodWidthCtrl.dispose();
    _prodHeightCtrl.dispose();
    _prodWarrantyCtrl.dispose();

    _storeNameCtrl.dispose();
    _storeBioCtrl.dispose();
    _storeWebsiteCtrl.dispose();
    _storeEmailCtrl.dispose();
    _storePhoneCtrl.dispose();
    _storeAddressCtrl.dispose();
    _shippingPolicyCtrl.dispose();
    _refundPolicyCtrl.dispose();
    _supportInfoCtrl.dispose();
    _instagramCtrl.dispose();
    _facebookCtrl.dispose();
    _twitterCtrl.dispose();

    _bankNameCtrl.dispose();
    _accountHolderCtrl.dispose();
    _accountNumberCtrl.dispose();
    _routingNumberCtrl.dispose();
    super.dispose();
  }

  void _initProfileData(VendorPortalData data) {
    if (_profileInitialized) return;
    final p = data.profile;
    _storeNameCtrl.text = p?.storeName ?? data.storeName;
    _storeBioCtrl.text = p?.description ?? "";
    _storeWebsiteCtrl.text = p?.website ?? "";
    _storeEmailCtrl.text = p?.storeEmail ?? "";
    _storePhoneCtrl.text = p?.storePhone ?? "";
    _storeAddressCtrl.text = p?.storeAddress ?? "";
    _shippingPolicyCtrl.text = p?.shippingPolicy ?? "";
    _refundPolicyCtrl.text = p?.refundPolicy ?? "";
    _supportInfoCtrl.text = p?.supportInfo ?? "";
    _instagramCtrl.text = p?.socialLinks['instagram']?.toString() ?? "";
    _facebookCtrl.text = p?.socialLinks['facebook']?.toString() ?? "";
    _twitterCtrl.text = p?.socialLinks['twitter']?.toString() ?? "";
    _profileInitialized = true;
  }

  void _initSettingsData(VendorPortalData data) {
    if (_settingsInitialized) return;
    final s = data.settings;
    if (s != null) {
      _payoutMethod = s.payoutMethod;
      _bankNameCtrl.text = s.bankName;
      _accountHolderCtrl.text = s.accountHolder;
      _accountNumberCtrl.text = s.accountNumber;
      _routingNumberCtrl.text = s.routingNumber;
      _handlingDays = s.handlingDays;
      _notifyOrder = s.notifyOrderAlert;
      _notifyPayout = s.notifyPayoutAlert;
      _notifyStock = s.notifyStockAlert;
    }
    _settingsInitialized = true;
  }

  void _navigateToPage(int index) {
    setState(() => _selectedPageIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  void _initWizardForNew() {
    setState(() {
      _editingProduct = null;
      _wizardStep = 1;
      _prodTitleCtrl.clear();
      _prodBrandCtrl.clear();
      _prodCategory = "Official Foundation Merch";
      _prodProductType = "PHYSICAL";
      _prodBadge = "Artisan Made";
      _prodTagsCtrl.text = "handcrafted, sustainable";
      _prodImagePath = null;
      _prodImageUrlCtrl.clear();
      _prodGalleryUrls.clear();
      _newGalleryUrlCtrl.clear();
      _prodDescCtrl.clear();
      _prodImpactCtrl.clear();
      _prodHighlights.clear();
      _prodHighlights.addAll(["Sustainably sourced materials", "100% fair-trade certified"]);
      _prodSpecs.clear();
      _prodSpecs.addAll([
        const MapEntry("Material", "Organic Cotton / Natural Wood"),
        const MapEntry("Origin", "Handcrafted in Artisan Workshop"),
      ]);
      _prodPriceCtrl.text = "45.00";
      _prodComparePriceCtrl.text = "60.00";
      _prodCostPriceCtrl.text = "20.00";
      _prodSkuCtrl.clear();
      _prodInventoryCtrl.text = "50";
      _prodLowStockCtrl.text = "5";
      _prodTrackInventory = true;
      _hasVariants = false;
      _variantsList.clear();
      _shippingClassification = "standard";
      _prodWeightCtrl.text = "0.5";
      _prodLengthCtrl.text = "10";
      _prodWidthCtrl.text = "10";
      _prodHeightCtrl.text = "5";
      _processingTime = "1-3 business days";
      _freeShipping = true;
      _prodReturnPolicy = "30-Day Charitable Return Policy";
      _prodWarrantyCtrl.text = "1-year artisan craftsmanship guarantee";
    });
  }

  void _initWizardForEdit(EcosystemProduct p) {
    setState(() {
      _editingProduct = p;
      _wizardStep = 1;
      _prodTitleCtrl.text = p.title;
      _prodBrandCtrl.text = p.brand ?? "";
      if (p.categoryName != null && p.categoryName!.isNotEmpty) {
        _prodCategory = p.categoryName!;
      }
      _prodProductType = p.productType ?? "PHYSICAL";
      _prodBadge = p.badge ?? "Artisan Made";
      _prodTagsCtrl.text = p.tags.join(", ");
      _prodImagePath = null;
      _prodImageUrlCtrl.text = p.featuredImage ?? "";
      _prodGalleryUrls.clear();
      _prodGalleryUrls.addAll(p.images);
      _prodDescCtrl.text = p.description ?? "";
      _prodImpactCtrl.text = p.impact ?? "";
      _prodHighlights.clear();
      if (p.features.isNotEmpty) {
        _prodHighlights.addAll(p.features);
      } else {
        _prodHighlights.addAll(["Sustainably sourced materials", "100% fair-trade certified"]);
      }
      _prodSpecs.clear();
      if (p.specifications.isNotEmpty) {
        _prodSpecs.addAll(p.specifications.entries);
      } else {
        _prodSpecs.addAll([
          const MapEntry("Material", "Organic Cotton / Natural Wood"),
          const MapEntry("Origin", "Handcrafted in Artisan Workshop"),
        ]);
      }
      _prodPriceCtrl.text = p.price.toStringAsFixed(2);
      _prodComparePriceCtrl.text = p.compareAtPrice != null ? p.compareAtPrice!.toStringAsFixed(2) : "";
      _prodCostPriceCtrl.text = p.costPrice != null ? p.costPrice!.toStringAsFixed(2) : "";
      _prodSkuCtrl.text = p.sku ?? "";
      _prodInventoryCtrl.text = p.inventory.toString();
      _prodLowStockCtrl.text = p.lowStockThreshold.toString();
      _prodTrackInventory = p.trackInventory;
      _hasVariants = p.variants.isNotEmpty;
      _variantsList.clear();
      _variantsList.addAll(p.variants);
      _prodWeightCtrl.text = p.weight != null ? p.weight!.toString() : "0.5";
      _prodLengthCtrl.text = "10";
      _prodWidthCtrl.text = "10";
      _prodHeightCtrl.text = "5";
      _processingTime = "1-3 business days";
      _freeShipping = true;
      if (p.returnPolicy != null && p.returnPolicy!.isNotEmpty) {
        _prodReturnPolicy = p.returnPolicy!;
      }
      _prodWarrantyCtrl.text = "1-year artisan craftsmanship guarantee";
    });
  }

  Future<void> _submitWizard(EcosystemController controller, {required bool isDraft}) async {
    final title = _prodTitleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _wizardStep = 1);
      Get.snackbar("Missing Field", "Product title is required.", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final price = double.tryParse(_prodPriceCtrl.text.trim()) ?? 0.0;
    if (price <= 0) {
      setState(() => _wizardStep = 4);
      Get.snackbar("Invalid Price", "Price must be greater than 0.", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final comparePrice = double.tryParse(_prodComparePriceCtrl.text.trim());
    final costPrice = double.tryParse(_prodCostPriceCtrl.text.trim());
    final inventory = int.tryParse(_prodInventoryCtrl.text.trim()) ?? 10;
    final lowStock = int.tryParse(_prodLowStockCtrl.text.trim()) ?? 5;
    final weight = double.tryParse(_prodWeightCtrl.text.trim()) ?? 0.5;
    final length = double.tryParse(_prodLengthCtrl.text.trim()) ?? 10.0;
    final width = double.tryParse(_prodWidthCtrl.text.trim()) ?? 10.0;
    final height = double.tryParse(_prodHeightCtrl.text.trim()) ?? 5.0;

    final tags = _prodTagsCtrl.text
        .split(",")
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final specsMap = <String, String>{};
    for (final s in _prodSpecs) {
      if (s.key.trim().isNotEmpty) {
        specsMap[s.key.trim()] = s.value.trim();
      }
    }

    final dimensions = {
      "length": length,
      "width": width,
      "height": height,
    };

    final galleryUrls = List<String>.from(_prodGalleryUrls);
    if (_prodImageUrlCtrl.text.trim().isNotEmpty && !galleryUrls.contains(_prodImageUrlCtrl.text.trim())) {
      galleryUrls.insert(0, _prodImageUrlCtrl.text.trim());
    }

    double shippingSurcharge = 0.0;
    switch (_shippingClassification) {
      case "liquid":
        shippingSurcharge = 3.50;
        break;
      case "fragile":
        shippingSurcharge = 4.50;
        break;
      case "perishable":
        shippingSurcharge = 6.00;
        break;
      case "electronics":
        shippingSurcharge = 5.00;
        break;
      case "bulky":
        shippingSurcharge = 15.00;
        break;
      default:
        shippingSurcharge = 0.0;
    }

    final ok = await controller.saveProduct(
      productId: _editingProduct?.id,
      title: title,
      brand: _prodBrandCtrl.text.trim(),
      categoryName: _prodCategory,
      productType: _prodProductType,
      badge: _prodBadge,
      tags: tags,
      price: price,
      compareAtPrice: comparePrice,
      costPrice: costPrice,
      inventory: inventory,
      sku: _prodSkuCtrl.text.trim(),
      lowStockThreshold: lowStock,
      trackInventory: _prodTrackInventory,
      description: _prodDescCtrl.text.trim().isNotEmpty
          ? _prodDescCtrl.text.trim()
          : "Handcrafted artisan product listed on the Notisboard Foundation Marketplace.",
      impact: _prodImpactCtrl.text.trim(),
      features: _prodHighlights,
      specifications: specsMap,
      variants: _hasVariants ? _variantsList : [],
      weight: weight,
      dimensions: dimensions,
      shippingClassification: _shippingClassification,
      shippingSurcharge: shippingSurcharge,
      returnPolicy: "${_prodReturnPolicy}. Warranty: ${_prodWarrantyCtrl.text.trim()}".trim(),
      isDraft: isDraft,
      imagePath: _prodImagePath,
      galleryImageUrls: galleryUrls,
    );

    if (ok) {
      _initWizardForNew();
      _navigateToPage(2);
    }
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return "KYC Verification";
      case 1:
        return "Vendor Dashboard";
      case 2:
        return "My Products";
      case 3:
        return _editingProduct != null ? "Edit Product" : "+ Add Product";
      case 4:
        return "Customer Orders";
      case 5:
        return "Earnings & Payouts";
      case 6:
        return "Store Profile";
      case 7:
        return "Notifications";
      case 8:
        return "Store Settings";
      default:
        return "Vendor Merchant Portal";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EcosystemController>(
      builder: (controller) {
        final data = controller.vendorPortalData;
        if (data != null) {
          _initProfileData(data);
          _initSettingsData(data);
        }

        final unreadNotifs = data?.notifications.where((n) => !n.isRead).length ?? 0;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF0F172A), size: 24),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPageTitle(_selectedPageIndex),
                  style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: const Color(0xFF0F172A)),
                ),
                Text(
                  data?.storeName ?? "Foundation Merchant Portal",
                  style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: const Color(0xFF64748B)),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1E293B)),
                onPressed: () => controller.loadVendorPortal(),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1E293B)),
                    onPressed: () => _navigateToPage(7),
                  ),
                  if (unreadNotifs > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                        child: Text(
                          "$unreadNotifs",
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          drawer: _buildWebMatchingSidebarDrawer(context, data, unreadNotifs),
          bottomNavigationBar: _buildBottomQuickBar(),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
              : IndexedStack(
                  index: _selectedPageIndex,
                  children: [
                    _buildPage0KycVerification(context, data),
                    _buildPage1Dashboard(context, controller, data),
                    _buildPage2MyProducts(context, controller, data),
                    _buildPage3AddProduct(context, controller, data),
                    _buildPage4Orders(context, controller, data),
                    _buildPage5Earnings(context, controller, data),
                    _buildPage6StoreProfile(context, controller, data),
                    _buildPage7Notifications(context, data),
                    _buildPage8Settings(context, controller, data),
                  ],
                ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // DRAWER: SIDEBAR NAVIGATION
  // ══════════════════════════════════════════════════════════════
  Widget _buildWebMatchingSidebarDrawer(BuildContext context, VendorPortalData? data, int unreadNotifs) {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "N",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Notisboard",
                          style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: Colors.white),
                        ),
                        Text(
                          "VENDOR PORTAL",
                          style: AppFontStyle.fontStyleW600(fontSize: 10, fontColor: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                children: [
                  _buildDrawerNavItem(
                    index: 0,
                    icon: Icons.verified_user_outlined,
                    title: "KYC Verification",
                    badgeText: "VERIFIED",
                    badgeColor: const Color(0xFF10B981),
                  ),
                  _buildDrawerNavItem(
                    index: 1,
                    icon: Icons.dashboard_outlined,
                    title: "Dashboard",
                  ),
                  _buildDrawerNavItem(
                    index: 2,
                    icon: Icons.inventory_2_outlined,
                    title: "My Products",
                    badgeText: "${data?.products.length ?? 0}",
                    badgeColor: const Color(0xFF334155),
                  ),
                  _buildDrawerNavItem(
                    index: 3,
                    icon: Icons.add_box_outlined,
                    title: "+ Add Product",
                    highlight: true,
                    onTapOverride: () {
                      _initWizardForNew();
                      _navigateToPage(3);
                    },
                  ),
                  _buildDrawerNavItem(
                    index: 4,
                    icon: Icons.receipt_long_outlined,
                    title: "Orders",
                    badgeText: "${data?.orders.length ?? 0}",
                    badgeColor: const Color(0xFF334155),
                  ),
                  _buildDrawerNavItem(
                    index: 5,
                    icon: Icons.account_balance_wallet_outlined,
                    title: "Earnings",
                  ),
                  _buildDrawerNavItem(
                    index: 6,
                    icon: Icons.storefront_outlined,
                    title: "Store Profile",
                  ),
                  _buildDrawerNavItem(
                    index: 7,
                    icon: Icons.notifications_outlined,
                    title: "Notifications",
                    badgeText: unreadNotifs > 0 ? "$unreadNotifs" : null,
                    badgeColor: const Color(0xFFEF4444),
                  ),
                  _buildDrawerNavItem(
                    index: 8,
                    icon: Icons.settings_outlined,
                    title: "Settings",
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF2563EB),
                    child: Text(
                      (data?.storeName.isNotEmpty ?? false) ? data!.storeName[0].toUpperCase() : "V",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data?.storeName ?? "Official Merchant",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: Colors.white),
                        ),
                        Text(
                          "Foundation Vendor",
                          style: AppFontStyle.fontStyleW400(fontSize: 10, fontColor: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF94A3B8), size: 16),
                    onPressed: () => Get.back(),
                    tooltip: "Exit Portal",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerNavItem({
    required int index,
    required IconData icon,
    required String title,
    String? badgeText,
    Color? badgeColor,
    bool highlight = false,
    VoidCallback? onTapOverride,
  }) {
    final isSelected = _selectedPageIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTapOverride ?? () => _navigateToPage(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : (highlight ? const Color(0xFF1E293B) : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: isSelected
                      ? Colors.white
                      : (highlight ? const Color(0xFF60A5FA) : const Color(0xFF94A3B8)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 13,
                      fontColor: isSelected
                          ? Colors.white
                          : (highlight ? const Color(0xFF93C5FD) : const Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor ?? const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomQuickBar() {
    int currentNavIndex = 0;
    if (_selectedPageIndex == 1) {
      currentNavIndex = 0;
    } else if (_selectedPageIndex == 2 || _selectedPageIndex == 3) {
      currentNavIndex = 1;
    } else if (_selectedPageIndex == 4) {
      currentNavIndex = 2;
    } else if (_selectedPageIndex == 5) {
      currentNavIndex = 3;
    } else if (_selectedPageIndex == 6) {
      currentNavIndex = 4;
    } else {
      currentNavIndex = 0;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: BottomNavigationBar(
        currentIndex: currentNavIndex,
        onTap: (tabIdx) {
          if (tabIdx == 0) _navigateToPage(1); // Dashboard
          if (tabIdx == 1) _navigateToPage(2); // Products
          if (tabIdx == 2) _navigateToPage(4); // Orders
          if (tabIdx == 3) _navigateToPage(5); // Earnings
          if (tabIdx == 4) _navigateToPage(6); // Store Profile
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2_rounded), label: "Products"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long_rounded), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet_rounded), label: "Earnings"),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront_rounded), label: "Profile"),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE 0: KYC VERIFICATION
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage0KycVerification(BuildContext context, VendorPortalData? data) {
    final dossier = data?.dossier;
    final isIndiv = _kycDossierType == "individual";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF2563EB)),
              const SizedBox(width: 6),
              Text(
                "COMPLIANCE & VERIFICATION",
                style: AppFontStyle.fontStyleW700(fontSize: 11, fontColor: const Color(0xFF2563EB)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Vendor KYC Document Verification",
            style: AppFontStyle.fontStyleW700(fontSize: 20, fontColor: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          Text(
            "In accordance with international non-profit marketplace guidelines, vendors must submit authentic identity and legal registration documentation before storefront features are unlocked.",
            style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 18),

          // Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("CURRENT STATUS: ", style: AppFontStyle.fontStyleW700(fontSize: 12, fontColor: const Color(0xFF0F172A))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: const Text(
                              "VERIFIED & UNLOCKED",
                              style: TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Your merchant account is approved! All Vendor Portal features, product listings, orders, and sales ledgers are active.",
                        style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Green Privileges Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Full Storefront Privileges Unlocked!",
                      style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF166534)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Your KYC documentation has been officially verified by Foundation Administration. You have unrestricted access to all vendor features.",
                  style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF15803D)),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.dashboard_rounded, size: 16),
                  label: const Text("Go to Vendor Dashboard →", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => _navigateToPage(1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Locked Read-Only Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Verified Compliance Dossier (Locked) — READ-ONLY",
                    style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: const Color(0xFF334155)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text("LOCKED", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Certified Dossier Card with Switcher
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Certified Verification Dossier", style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A))),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _kycDossierType = "individual"),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isIndiv ? const Color(0xFF2563EB) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Individual Artisan",
                                style: TextStyle(
                                  color: isIndiv ? Colors.white : const Color(0xFF64748B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _kycDossierType = "business"),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: !isIndiv ? const Color(0xFF2563EB) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Business Vendor",
                                style: TextStyle(
                                  color: !isIndiv ? Colors.white : const Color(0xFF64748B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isIndiv) ...[
                  _buildReadOnlyRow("First Name *", dossier?.firstName.isNotEmpty == true ? dossier!.firstName : "Hammad"),
                  _buildReadOnlyRow("Middle Name", dossier?.middleName ?? "-"),
                  _buildReadOnlyRow("Last Name *", dossier?.lastName.isNotEmpty == true ? dossier!.lastName : "Artisan"),
                  _buildReadOnlyRow("Citizenship Country *", dossier?.citizenship.isNotEmpty == true ? dossier!.citizenship : "Verified Citizen"),
                  _buildReadOnlyRow("Date of Birth *", dossier?.dateOfBirth.isNotEmpty == true ? dossier!.dateOfBirth : "13/11/2000"),
                  _buildReadOnlyRow("Place of Birth (City, Country) *", dossier?.placeOfBirth.isNotEmpty == true ? dossier!.placeOfBirth : "Verified Registry"),
                  _buildReadOnlyRow("Residential Address", dossier?.residentialAddress.isNotEmpty == true ? dossier!.residentialAddress : "Verified Residential Address"),
                  _buildReadOnlyRow("Government ID Document", "Driver's License / Official ID", verified: true),
                  _buildReadOnlyRow("Proof of Address Document", "Bank Statement (Last 3 Months)", verified: true),
                ] else ...[
                  _buildReadOnlyRow("Registered Business Name *", dossier?.registeredBusinessName.isNotEmpty == true ? dossier!.registeredBusinessName : (data?.storeName ?? "Commercial Entity")),
                  _buildReadOnlyRow("Business Type *", dossier?.businessType.isNotEmpty == true ? dossier!.businessType : "Limited Liability Company (LLC)"),
                  _buildReadOnlyRow("Primary Contact Person", "${dossier?.firstName ?? ''} ${dossier?.lastName ?? ''}".trim()),
                  _buildReadOnlyRow("Commercial Tax ID (EIN / Tax ID) *", dossier?.taxId.isNotEmpty == true ? dossier!.taxId : "Verified Commercial Tax ID", verified: true),
                  _buildReadOnlyRow("Corporate Filing Documentation", "Official Articles of Incorporation", verified: true),
                  _buildReadOnlyRow("Operating Address", dossier?.residentialAddress.isNotEmpty == true ? dossier!.residentialAddress : "Official Headquarters"),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value, {bool verified = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: const Color(0xFF94A3B8))),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: Text(value, style: AppFontStyle.fontStyleW600(fontSize: 13, fontColor: const Color(0xFF1E293B))),
              ),
              if (verified)
                const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 16),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE 1: VENDOR DASHBOARD
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage1Dashboard(BuildContext context, EcosystemController controller, VendorPortalData? data) {
    final balance = data?.balance ?? 0.0;
    final totalRevenue = data?.totalRevenue ?? 0.0;
    final netEarnings = data?.netEarnings ?? 0.0;
    final totalOrders = data?.totalOrders ?? (data?.orders.length ?? 0);
    final totalCustomers = data?.totalCustomers ?? 0;
    final recentOrders = data?.orders.take(5).toList() ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available Balance Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Available Settlement Balance", style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: Colors.white70)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        children: [
                          Icon(Icons.sync_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text("Live Sync", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  controller.formatCurrency(balance),
                  style: AppFontStyle.fontStyleW700(fontSize: 32, fontColor: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.account_balance_wallet_outlined, size: 16),
                  label: const Text("Request Payout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => _showPayoutRequestDialog(context, controller, balance, data?.minWithdrawalAmount ?? 20.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4 Main Performance Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricTile("Total Sales", controller.formatCurrency(totalRevenue), Icons.payments_outlined, const Color(0xFF10B981)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile("Net Earnings", controller.formatCurrency(netEarnings), Icons.account_balance_outlined, const Color(0xFF2563EB)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile("Total Orders", "$totalOrders", Icons.shopping_bag_outlined, const Color(0xFF8B5CF6)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile("Total Customers", "$totalCustomers", Icons.people_outline_rounded, const Color(0xFFF59E0B)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Setup & Policy Checklist Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Store Setup & Policy Checklist", style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                      child: const Text("Active Merchant", style: TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildChecklistItem("Store Status", "Active on Public Foundation Marketplace", true),
                _buildChecklistItem(
                  "Store Profile Completed",
                  (data?.checklistProfileCompleted ?? true) ? "Branding & Contact Info Verified" : "Incomplete (Add Policies & Bio)",
                  data?.checklistProfileCompleted ?? true,
                ),
                _buildChecklistItem(
                  "Marketplace Products Added",
                  (data?.checklistProductAdded ?? (data?.products.isNotEmpty ?? false)) ? "Products Live in Catalog" : "No Products Added Yet",
                  data?.checklistProductAdded ?? (data?.products.isNotEmpty ?? false),
                ),
                _buildChecklistItem(
                  "Payout Settlement Method",
                  (data?.checklistPayoutConnected ?? true) ? "Direct Bank Account Connected" : "Not Configured",
                  data?.checklistPayoutConnected ?? true,
                ),
                _buildChecklistItem(
                  "Marketplace Compliance",
                  (data?.checklistPolicyViolations ?? 0) == 0 ? "0 Violations (Good Standing)" : "${data?.checklistPolicyViolations} Policy Warnings",
                  (data?.checklistPolicyViolations ?? 0) == 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Action Pills
          Text("Quick Actions", style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.add_circle_outline_rounded,
                  label: "Add Product",
                  color: const Color(0xFF2563EB),
                  onTap: () {
                    _initWizardForNew();
                    _navigateToPage(3);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.inventory_2_outlined,
                  label: "Manage Items",
                  color: const Color(0xFF8B5CF6),
                  onTap: () => _navigateToPage(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.receipt_long_outlined,
                  label: "View Orders",
                  color: const Color(0xFF10B981),
                  onTap: () => _navigateToPage(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.account_balance_wallet_outlined,
                  label: "Request Payout",
                  color: const Color(0xFFF59E0B),
                  onTap: () => _showPayoutRequestDialog(context, controller, balance, data?.minWithdrawalAmount ?? 20.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Orders Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recent Customer Orders", style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A))),
              TextButton(
                onPressed: () => _navigateToPage(4),
                child: Text("View All →", style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: const Color(0xFF2563EB))),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (recentOrders.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.inbox_outlined, size: 40, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 8),
                  Text("No orders placed yet", style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text(
                    "Customer orders from the Foundation marketplace will appear here in real-time.",
                    textAlign: TextAlign.center,
                    style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          else
            ...recentOrders.map((order) => _buildOrderTile(context, controller, order)),

          const SizedBox(height: 20),

          // Need Help Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.help_outline_rounded, color: Color(0xFF2563EB), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Need Merchant Assistance?", style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Text("Access Foundation catalog guides or contact dedicated vendor support.", style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF64748B))),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.snackbar("Foundation Support", "Email vendor-support@notisboardglobalfoundation.org for assistance.", backgroundColor: const Color(0xFF0F172A), colorText: Colors.white);
                  },
                  child: const Text("Support →", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String title, String subtitle, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: isDone ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: const Color(0xFF1E293B))),
                Text(subtitle, style: AppFontStyle.fontStyleW400(fontSize: 10, fontColor: const Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: const Color(0xFF64748B))),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: AppFontStyle.fontStyleW700(fontSize: 17, fontColor: const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE 2: MY PRODUCTS (CATALOG MANAGEMENT)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage2MyProducts(BuildContext context, EcosystemController controller, VendorPortalData? data) {
    var prods = data?.products ?? controller.products;

    final totalCount = prods.length;
    final activeCount = prods.where((p) => (p.status == "ACTIVE" || p.status == "APPROVED") && p.isActive).length;
    final underReviewCount = prods.where((p) => p.status == "PENDING_REVIEW" || p.status == "UNDER_REVIEW" || p.status == "PENDING").length;
    final draftCount = prods.where((p) => p.status == "DRAFT").length;

    if (_productFilter == "ACTIVE") {
      prods = prods.where((p) => (p.status == "ACTIVE" || p.status == "APPROVED") && p.isActive).toList();
    } else if (_productFilter == "UNDER_REVIEW") {
      prods = prods.where((p) => p.status == "PENDING_REVIEW" || p.status == "UNDER_REVIEW" || p.status == "PENDING").toList();
    } else if (_productFilter == "DRAFT") {
      prods = prods.where((p) => p.status == "DRAFT").toList();
    } else if (_productFilter == "OUT_OF_STOCK") {
      prods = prods.where((p) => p.inventory <= 0).toList();
    }

    if (_productSearchQuery.isNotEmpty) {
      prods = prods
          .where((p) =>
              p.title.toLowerCase().contains(_productSearchQuery.toLowerCase()) ||
              (p.sku != null && p.sku!.toLowerCase().contains(_productSearchQuery.toLowerCase())) ||
              (p.categoryName != null && p.categoryName!.toLowerCase().contains(_productSearchQuery.toLowerCase())))
          .toList();
    }

    return Column(
      children: [
        // Top 4 Statistics
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(child: _buildSmallProductStat("Total Listed", "$totalCount", const Color(0xFF2563EB))),
              const SizedBox(width: 8),
              Expanded(child: _buildSmallProductStat("Active / Live", "$activeCount", const Color(0xFF10B981))),
              const SizedBox(width: 8),
              Expanded(child: _buildSmallProductStat("Under Review", "$underReviewCount", const Color(0xFFF59E0B))),
              const SizedBox(width: 8),
              Expanded(child: _buildSmallProductStat("Drafts", "$draftCount", const Color(0xFF64748B))),
            ],
          ),
        ),

        // Search & Filter Bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _productSearchQuery = val),
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: "Search products by title, SKU, category...",
                          prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("New", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () {
                      _initWizardForNew();
                      _navigateToPage(3);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip("ALL", "All ($totalCount)"),
                    _buildFilterChip("ACTIVE", "Active ($activeCount)"),
                    _buildFilterChip("UNDER_REVIEW", "Under Review ($underReviewCount)"),
                    _buildFilterChip("DRAFT", "Drafts ($draftCount)"),
                    _buildFilterChip("OUT_OF_STOCK", "Out of Stock"),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Product List
        Expanded(
          child: prods.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 12),
                      Text("No Products Found", style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: const Color(0xFF0F172A))),
                      const SizedBox(height: 6),
                      Text("Start listing merchandise in your Foundation store.", style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF64748B))),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: const Text("Create First Product", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          _initWizardForNew();
                          _navigateToPage(3);
                        },
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: prods.length,
                  itemBuilder: (ctx, i) => _buildProductCard(context, controller, prods[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildSmallProductStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _productFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF2563EB),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF475569),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        onSelected: (val) {
          if (val) setState(() => _productFilter = value);
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, EcosystemController controller, EcosystemProduct product) {
    final isDraft = product.status == "DRAFT";
    final isUnderReview = product.status == "PENDING_REVIEW" || product.status == "UNDER_REVIEW" || product.status == "PENDING";
    final isChangesRequested = product.status == "CHANGES_REQUESTED";
    final isRejected = product.status == "REJECTED";

    Color badgeBg;
    Color badgeText;
    String badgeLabel;

    if (isDraft) {
      badgeBg = const Color(0xFFF1F5F9);
      badgeText = const Color(0xFF64748B);
      badgeLabel = "DRAFT";
    } else if (isUnderReview) {
      badgeBg = const Color(0xFFFEF3C7);
      badgeText = const Color(0xFFD97706);
      badgeLabel = "UNDER REVIEW";
    } else if (isChangesRequested) {
      badgeBg = const Color(0xFFFFFBEB);
      badgeText = const Color(0xFFB45309);
      badgeLabel = "CHANGES REQUESTED";
    } else if (isRejected) {
      badgeBg = const Color(0xFFFEE2E2);
      badgeText = const Color(0xFFDC2626);
      badgeLabel = "REJECTED";
    } else {
      badgeBg = const Color(0xFFECFDF5);
      badgeText = const Color(0xFF059669);
      badgeLabel = "ACTIVE / LIVE";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 76,
              height: 76,
              color: const Color(0xFFF1F5F9),
              child: product.featuredImage != null && product.featuredImage!.isNotEmpty
                  ? Image.network(
                      product.featuredImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: Color(0xFF94A3B8)),
                    )
                  : const Icon(Icons.image_outlined, color: Color(0xFF94A3B8)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          color: badgeText,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      controller.formatCurrency(product.price),
                      style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF2563EB)),
                    ),
                    if (product.compareAtPrice != null && product.compareAtPrice! > product.price) ...[
                      const SizedBox(width: 6),
                      Text(
                        controller.formatCurrency(product.compareAtPrice!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.inventory > 0 ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.inventory > 0 ? "${product.inventory} in stock" : "Out of Stock",
                        style: TextStyle(
                          color: product.inventory > 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.sku != null && product.sku!.isNotEmpty ? "SKU: ${product.sku}" : (product.categoryName ?? "Marketplace"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW400(fontSize: 10, fontColor: const Color(0xFF94A3B8)),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: "Edit Product",
                          onPressed: () {
                            _initWizardForEdit(product);
                            _navigateToPage(3);
                          },
                        ),
                        const SizedBox(width: 14),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: "Delete Product",
                          onPressed: () => _confirmDeleteProduct(context, controller, product.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProduct(BuildContext context, EcosystemController controller, String productId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Product?"),
        content: const Text("Are you sure you want to remove this item from your Foundation store?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.removeProduct(productId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE 3: + ADD NEW PRODUCT – COMPLETE 9-STEP WIZARD
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage3AddProduct(BuildContext context, EcosystemController controller, VendorPortalData? data) {
    final isEdit = _editingProduct != null;

    final categoriesList = (data?.categories.isNotEmpty ?? false)
        ? data!.categories
        : _productCategories;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wizard Top Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? "Edit Marketplace Product" : "Create Marketplace Product",
                    style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: const Color(0xFF0F172A)),
                  ),
                  Text(
                    "Complete the 9-step wizard to list your item in the Foundation Marketplace.",
                    style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Actions Header: Cancel, Save Draft, Submit
          Row(
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  _initWizardForNew();
                  _navigateToPage(2);
                },
                child: const Text("Cancel", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ),
              const Spacer(),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.save_outlined, size: 14, color: Color(0xFF475569)),
                label: const Text("Save Draft", style: TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.bold)),
                onPressed: () => _submitWizard(controller, isDraft: true),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 14),
                label: Text(isEdit ? "Update" : "Submit", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () => _submitWizard(controller, isDraft: false),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Horizontal 9-Step Stepper Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildWizardStepTab(1, "Basic Info", Icons.edit_note_rounded),
                _buildWizardStepTab(2, "Media", Icons.photo_library_outlined),
                _buildWizardStepTab(3, "Story", Icons.article_outlined),
                _buildWizardStepTab(4, "Pricing", Icons.attach_money_rounded),
                _buildWizardStepTab(5, "Inventory", Icons.inventory_2_outlined),
                _buildWizardStepTab(6, "Variants", Icons.tune_rounded),
                _buildWizardStepTab(7, "Shipping", Icons.local_shipping_outlined),
                _buildWizardStepTab(8, "Returns", Icons.verified_user_outlined),
                _buildWizardStepTab(9, "Review", Icons.fact_check_outlined),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Render Active Step Form Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActiveStepContent(controller, categoriesList),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bottom Stepper Navigation Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text("Back"),
                onPressed: _wizardStep > 1 ? () => setState(() => _wizardStep--) : null,
              ),
              Text(
                "Step $_wizardStep of 9",
                style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: const Color(0xFF64748B)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: Icon(_wizardStep < 9 ? Icons.arrow_forward_rounded : Icons.check_circle_rounded, size: 16),
                label: Text(_wizardStep < 9 ? "Next Step →" : (isEdit ? "Update Product" : "Submit for Approval")),
                onPressed: () {
                  if (_wizardStep < 9) {
                    setState(() => _wizardStep++);
                  } else {
                    _submitWizard(controller, isDraft: false);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWizardStepTab(int stepNumber, String title, IconData icon) {
    final isActive = _wizardStep == stepNumber;
    final isPassed = _wizardStep > stepNumber;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => _wizardStep = stepNumber),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2563EB) : (isPassed ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? const Color(0xFF2563EB) : (isPassed ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0)),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isPassed ? Icons.check_circle_rounded : icon,
                size: 14,
                color: isActive ? Colors.white : (isPassed ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 6),
              Text(
                "$stepNumber. $title",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : (isPassed ? const Color(0xFF1E3A8A) : const Color(0xFF475569)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveStepContent(EcosystemController controller, List<String> categoriesList) {
    switch (_wizardStep) {
      case 1:
        return _buildWizardStep1Basic(categoriesList);
      case 2:
        return _buildWizardStep2Media();
      case 3:
        return _buildWizardStep3Story();
      case 4:
        return _buildWizardStep4Pricing(controller);
      case 5:
        return _buildWizardStep5Inventory();
      case 6:
        return _buildWizardStep6Variants(controller);
      case 7:
        return _buildWizardStep7Shipping();
      case 8:
        return _buildWizardStep8Returns();
      case 9:
        return _buildWizardStep9Review(controller);
      default:
        return const SizedBox();
    }
  }

  // Step 1: Basic Information
  Widget _buildWizardStep1Basic(List<String> categoriesList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("Step 1: Basic Information", "Essential product identification and marketplace classification."),
        const SizedBox(height: 14),
        _buildFormLabel("Product Title *"),
        TextField(
          controller: _prodTitleCtrl,
          decoration: _buildInputDec("e.g. Handmade Organic Cotton Tote"),
        ),
        const SizedBox(height: 14),
        _buildFormLabel("Brand or Maker"),
        TextField(
          controller: _prodBrandCtrl,
          decoration: _buildInputDec("e.g. EcoCraft Global / Artisan Collective"),
        ),
        const SizedBox(height: 14),
        _buildFormLabel("Primary Category *"),
        DropdownButtonFormField<String>(
          initialValue: categoriesList.contains(_prodCategory) ? _prodCategory : categoriesList.first,
          decoration: _buildInputDec(""),
          items: categoriesList.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _prodCategory = v);
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormLabel("Product Type"),
                  DropdownButtonFormField<String>(
                    initialValue: _prodProductType,
                    decoration: _buildInputDec(""),
                    items: _productTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _prodProductType = v);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormLabel("Highlight Badge"),
                  DropdownButtonFormField<String>(
                    initialValue: _highlightBadges.contains(_prodBadge) ? _prodBadge : _highlightBadges.first,
                    decoration: _buildInputDec(""),
                    items: _highlightBadges.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _prodBadge = v);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildFormLabel("Search Tags (comma-separated)"),
        TextField(
          controller: _prodTagsCtrl,
          decoration: _buildInputDec("e.g. handcrafted, sustainable, organic, fair-trade"),
        ),
      ],
    );
  }

  // Step 2: Media
  Widget _buildWizardStep2Media() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("Step 2: Media & Visual Assets", "Featured cover image and supporting gallery photos (up to 30MB)."),
        const SizedBox(height: 14),
        _buildFormLabel("Featured Cover Image *"),
        GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            final img = await picker.pickImage(source: ImageSource.gallery);
            if (img != null) {
              setState(() => _prodImagePath = img.path);
            }
          },
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
              image: _prodImagePath != null
                  ? DecorationImage(image: FileImage(File(_prodImagePath!)), fit: BoxFit.cover)
                  : (_prodImageUrlCtrl.text.isNotEmpty
                      ? DecorationImage(image: NetworkImage(_prodImageUrlCtrl.text), fit: BoxFit.cover)
                      : null),
            ),
            child: _prodImagePath == null && _prodImageUrlCtrl.text.isEmpty
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 38, color: Color(0xFF2563EB)),
                      SizedBox(height: 8),
                      Text("Tap to choose featured cover image", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                      SizedBox(height: 2),
                      Text("JPG, PNG, WEBP up to 30 MB", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    ],
                  )
                : Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircleAvatar(
                        backgroundColor: Colors.white70,
                        radius: 16,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.black),
                          onPressed: () => setState(() {
                            _prodImagePath = null;
                            _prodImageUrlCtrl.clear();
                          }),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        _buildFormLabel("Or Enter Direct Featured Image URL"),
        TextField(
          controller: _prodImageUrlCtrl,
          onChanged: (_) => setState(() {}),
          decoration: _buildInputDec("https://images.unsplash.com/..."),
        ),
        const SizedBox(height: 18),
        _buildFormLabel("Additional Gallery Photos"),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newGalleryUrlCtrl,
                decoration: _buildInputDec("Paste image URL..."),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              onPressed: () {
                final url = _newGalleryUrlCtrl.text.trim();
                if (url.isNotEmpty && !_prodGalleryUrls.contains(url)) {
                  setState(() {
                    _prodGalleryUrls.add(url);
                    _newGalleryUrlCtrl.clear();
                  });
                }
              },
              child: const Text("Add URL"),
            ),
          ],
        ),
        if (_prodGalleryUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _prodGalleryUrls.length,
              itemBuilder: (ctx, i) => Container(
                margin: const EdgeInsets.only(right: 8),
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  image: DecorationImage(image: NetworkImage(_prodGalleryUrls[i]), fit: BoxFit.cover),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => setState(() => _prodGalleryUrls.removeAt(i)),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(Icons.close, color: Colors.white, size: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Step 3: Description & Ethical Story
  Widget _buildWizardStep3Story() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("Step 3: Description & Ethical Story", "Connect customers with your artisan heritage and sustainable sourcing mission."),
        const SizedBox(height: 14),
        _buildFormLabel("Full Description *"),
        TextField(
          controller: _prodDescCtrl,
          maxLines: 4,
          decoration: _buildInputDec("Describe materials, artisan craftsmanship, provenance, and care instructions..."),
        ),
        const SizedBox(height: 14),
        _buildFormLabel("Ethical Provenance & Impact Story"),
        TextField(
          controller: _prodImpactCtrl,
          maxLines: 2,
          decoration: _buildInputDec("Explain fair wages, artisan heritage, charitable impact, or eco materials..."),
        ),
        const SizedBox(height: 16),
        _buildFormLabel("Key Product Highlights (Bullet points)"),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newHighlightCtrl,
                decoration: _buildInputDec("e.g. 100% GOTS Certified Organic Cotton"),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              onPressed: () {
                final h = _newHighlightCtrl.text.trim();
                if (h.isNotEmpty) {
                  setState(() {
                    _prodHighlights.add(h);
                    _newHighlightCtrl.clear();
                  });
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._prodHighlights.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.value, style: const TextStyle(fontSize: 12, color: Color(0xFF334155)))),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _prodHighlights.removeAt(e.key)),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
        _buildFormLabel("Technical Specifications"),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _newSpecKeyCtrl,
                decoration: _buildInputDec("Key (e.g. Material)"),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 3,
              child: TextField(
                controller: _newSpecValCtrl,
                decoration: _buildInputDec("Value (e.g. 100% Linen)"),
              ),
            ),
            const SizedBox(width: 6),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              onPressed: () {
                final k = _newSpecKeyCtrl.text.trim();
                final v = _newSpecValCtrl.text.trim();
                if (k.isNotEmpty && v.isNotEmpty) {
                  setState(() {
                    _prodSpecs.add(MapEntry(k, v));
                    _newSpecKeyCtrl.clear();
                    _newSpecValCtrl.clear();
                  });
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._prodSpecs.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text("${e.value.key}: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF334155))),
                  Expanded(child: Text(e.value.value, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _prodSpecs.removeAt(e.key)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // Step 4: Pricing & Net Earnings
  Widget _buildWizardStep4Pricing(EcosystemController controller) {
    final numPrice = double.tryParse(_prodPriceCtrl.text.trim()) ?? 0.0;
    final fee = numPrice * 0.10;
    final payout = numPrice - fee;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("Step 4: Pricing & Net Earnings", "Transparent marketplace pricing with automated commission breakdown."),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormLabel("Retail Price (${controller.currencySymbol}) *"),
                  TextField(
                    controller: _prodPriceCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: _buildInputDec("45.00"),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormLabel("Compare-at Price (${controller.currencySymbol})"),
                  TextField(
                    controller: _prodComparePriceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDec("60.00"),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text("Shows strike-through original price to attract buyers.", style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        const SizedBox(height: 14),
        _buildFormLabel("Cost of Goods (${controller.currencySymbol})"),
        TextField(
          controller: _prodCostPriceCtrl,
          keyboardType: TextInputType.number,
          decoration: _buildInputDec("20.00"),
        ),
        Text("Private to you for margin tracking.", style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        const SizedBox(height: 18),

        // Payout Calculator Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.calculate_outlined, size: 16, color: Color(0xFF166534)),
                  SizedBox(width: 6),
                  Text(
                    "ESTIMATED PAYOUT CALCULATOR (PER UNIT SOLD)",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534), letterSpacing: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Sale Price", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      const SizedBox(height: 2),
                      Text(controller.formatCurrency(numPrice), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Est. Platform Fee (10%)", style: TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                      const SizedBox(height: 2),
                      Text("-${controller.formatCurrency(fee)}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Your Net Payout", style: TextStyle(fontSize: 11, color: Color(0xFF16A34A))),
                      const SizedBox(height: 2),
                      Text(controller.formatCurrency(payout), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Workflow Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: const [
              Icon(Icons.info_outline, size: 16, color: Color(0xFFB45309)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Marketplace Approval Workflow: Submitting updates places them in Pending Admin Review status. You will receive an instant notification once approved.",
                  style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step 5: Inventory & SKU
  Widget _buildWizardStep5Inventory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("Step 5: Inventory & SKU", "Manage warehouse stocks, barcode identifiers, and depletion thresholds."),
        const SizedBox(height: 14),
        _buildFormLabel("SKU Code (Stock Keeping Unit)"),
        TextField(
          controller: _prodSkuCtrl,
          decoration: _buildInputDec("e.g. ART-TOTE-IND-01"),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormLabel("Available Stock Quantity *"),
                  TextField(
                    controller: _prodInventoryCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDec("50"),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormLabel("Low Stock Alert Threshold"),
                  TextField(
                    controller: _prodLowStockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDec("5"),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Track Inventory Automatically", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: const Text("Automatically decrement stock upon completed orders and trigger low-stock alerts.", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          value: _prodTrackInventory,
          activeColor: const Color(0xFF2563EB),
          onChanged: (v) => setState(() => _prodTrackInventory = v),
        ),
      ],
    );
  }

  // Step 6: Variants
  Widget _buildWizardStep6Variants(EcosystemController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("Step 6: Product Variants", "Offer multiple sizes, colors, or material configurations."),
        const SizedBox(height: 14),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("This product has multiple options", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: const Text("e.g. Size (S, M, L), Color (Blue, Black), or Finish (Matte, Gloss).", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          value: _hasVariants,
          activeColor: const Color(0xFF2563EB),
          onChanged: (v) => setState(() => _hasVariants = v),
        ),
        if (_hasVariants) ...[
          const Divider(height: 24),
          Text("Add Variant Option", style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A))),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _variantNameCtrl,
                  decoration: _buildInputDec("Name (e.g. Large / Indigo)"),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _variantSkuCtrl,
                  decoration: _buildInputDec("SKU"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _variantPriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDec("Price (${controller.currencySymbol})"),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _variantInvCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDec("Stock (e.g. 20)"),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                onPressed: () {
                  final name = _variantNameCtrl.text.trim();
                  if (name.isNotEmpty) {
                    setState(() {
                      _variantsList.add({
                        "name": name,
                        "sku": _variantSkuCtrl.text.trim(),
                        "price": double.tryParse(_variantPriceCtrl.text.trim()) ?? (double.tryParse(_prodPriceCtrl.text.trim()) ?? 45.0),
                        "inventory": int.tryParse(_variantInvCtrl.text.trim()) ?? 20,
                      });
                      _variantNameCtrl.clear();
                      _variantSkuCtrl.clear();
                      _variantPriceCtrl.clear();
                      _variantInvCtrl.text = "20";
                    });
                  }
                },
                child: const Text("Add Option"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_variantsList.isNotEmpty) ...[
            Text("Configured Variants (${_variantsList.length})", style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: const Color(0xFF475569))),
            const SizedBox(height: 8),
            ..._variantsList.asMap().entries.map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.value['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text("SKU: ${e.value['sku']} | Stock: ${e.value['inventory']}", style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        ],
                      ),
                      Row(
                        children: [
                          Text(controller.formatCurrency(double.tryParse(e.value['price'].toString()) ?? 0.0), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                            onPressed: () => setState(() => _variantsList.removeAt(e.key)),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ],
    );
  }

  // Step 7: Shipping & Packaging
  Widget _buildWizardStep7Shipping() {
    final w = double.tryParse(_prodWeightCtrl.text.trim()) ?? 0.5;
    final l = double.tryParse(_prodLengthCtrl.text.trim()) ?? 10.0;
    final wi = double.tryParse(_prodWidthCtrl.text.trim()) ?? 10.0;
    final h = double.tryParse(_prodHeightCtrl.text.trim()) ?? 5.0;
    final volW = (l * wi * h) / 5000.0;
    final billable = volW > w ? volW : w;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("Step 7: Shipping & Packaging", "Configure dimensions, weight tiers, and specialized handling classifications."),
        const SizedBox(height: 14),
        _buildFormLabel("Shipping Classification *"),
        const SizedBox(height: 6),
        _buildClassificationCard("standard", "Standard / Solid Products", "Apparel, textiles, books, crafts, woodcrafts", 0.0),
        _buildClassificationCard("liquid", "Liquid & Fluids", "Lotions, oils, bottled tonics, perfumes, syrups", 3.5),
        _buildClassificationCard("fragile", "Fragile / Glassware / Ceramics", "Glassware, ceramics, delicate pottery, jewelry", 4.5),
        _buildClassificationCard("perishable", "Perishable / Temp-Sensitive", "Organic honey, confectionery, botanical preserves", 6.0),
        _buildClassificationCard("electronics", "Hazardous / Batteries / Electronics", "Electronic instruments, solar gadgets, battery goods", 5.0),
        _buildClassificationCard("bulky", "Heavy / Bulky Cargo", "Handcrafted furniture, oversized wall art, heavy gear", 15.0),
        const SizedBox(height: 14),
        _buildFormLabel("Package Dimensions (cm)"),
        Row(
          children: [
            Expanded(child: TextField(controller: _prodLengthCtrl, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: _buildInputDec("Length"))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _prodWidthCtrl, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: _buildInputDec("Width"))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _prodHeightCtrl, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: _buildInputDec("Height"))),
          ],
        ),
        const SizedBox(height: 14),
        _buildFormLabel("Actual Weight (kg)"),
        TextField(
          controller: _prodWeightCtrl,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          decoration: _buildInputDec("0.5"),
        ),
        const SizedBox(height: 12),

        // Volumetric Weight Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Volumetric Weight", style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  Text("${volW.toStringAsFixed(2)} kg", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Billable Carrier Weight", style: TextStyle(fontSize: 10, color: Color(0xFF2563EB))),
                  Text("${billable.toStringAsFixed(2)} kg", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2563EB))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildFormLabel("Dispatch & Handling Time"),
        DropdownButtonFormField<String>(
          initialValue: _dispatchTimes.contains(_processingTime) ? _processingTime : _dispatchTimes[2],
          decoration: _buildInputDec(""),
          items: _dispatchTimes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _processingTime = v);
          },
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Offer Free Shipping", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: const Text("Cover shipping costs to increase conversion rates across the marketplace.", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          value: _freeShipping,
          activeColor: const Color(0xFF2563EB),
          onChanged: (v) => setState(() => _freeShipping = v),
        ),
      ],
    );
  }

  Widget _buildClassificationCard(String id, String title, String desc, double surcharge) {
    final controller = Get.find<EcosystemController>();
    final isSelected = _shippingClassification == id;
    return GestureDetector(
      onTap: () => setState(() => _shippingClassification = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 16,
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF1E293B))),
                      if (surcharge > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                          child: Text("+${controller.currencySymbol}${surcharge.toStringAsFixed(2)}", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                        ),
                      ],
                    ],
                  ),
                  Text(desc, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 8: Compliance, Returns & Warranty
  Widget _buildWizardStep8Returns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("Step 8: Compliance, Returns & Warranty", "Establish clear consumer protections and guarantee terms."),
        const SizedBox(height: 14),
        _buildFormLabel("Return & Refund Policy *"),
        DropdownButtonFormField<String>(
          initialValue: _returnPolicies.contains(_prodReturnPolicy) ? _prodReturnPolicy : _returnPolicies.first,
          decoration: _buildInputDec(""),
          items: _returnPolicies.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _prodReturnPolicy = v);
          },
        ),
        const SizedBox(height: 14),
        _buildFormLabel("Craftsmanship Warranty"),
        TextField(
          controller: _prodWarrantyCtrl,
          decoration: _buildInputDec("e.g. 1-Year Artisan Craftsmanship Guarantee"),
        ),
      ],
    );
  }

  // Step 9: Review & Submit
  Widget _buildWizardStep9Review(EcosystemController controller) {
    final isEdit = _editingProduct != null;
    final numPrice = double.tryParse(_prodPriceCtrl.text.trim()) ?? 0.0;
    final fee = numPrice * 0.10;
    final payout = numPrice - fee;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("Step 9: Review & Submit", "Confirm all parameters before submitting to the Multi-Vendor Marketplace."),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: const Color(0xFFE2E8F0),
                      child: _prodImagePath != null
                          ? Image.file(File(_prodImagePath!), fit: BoxFit.cover)
                          : (_prodImageUrlCtrl.text.isNotEmpty
                              ? Image.network(_prodImageUrlCtrl.text, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))
                              : const Icon(Icons.image)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_prodTitleCtrl.text.isNotEmpty ? _prodTitleCtrl.text : "Untitled Product", style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
                        Text("${_prodCategory} • ${_prodBadge}", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              _buildReviewRow("Retail Price", controller.formatCurrency(numPrice)),
              _buildReviewRow("Net Vendor Payout (90%)", controller.formatCurrency(payout), color: const Color(0xFF10B981)),
              _buildReviewRow("Initial Inventory", "${_prodInventoryCtrl.text} units"),
              _buildReviewRow("SKU Code", _prodSkuCtrl.text.isNotEmpty ? _prodSkuCtrl.text : "Auto-generated"),
              _buildReviewRow("Shipping Classification", _shippingClassification.toUpperCase()),
              _buildReviewRow("Product Variants", _hasVariants ? "${_variantsList.length} options configured" : "Single SKU item"),
              _buildReviewRow("Return Policy", _prodReturnPolicy),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFFD97706)),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Marketplace Approval Workflow",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF92400E)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Submitting for review places your listing in Under Review status. A platform administrator will review and approve the product before it goes live on the Foundation marketplace.",
                      style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _submitWizard(controller, isDraft: true),
                child: const Text("Save Draft", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _submitWizard(controller, isDraft: false),
                child: Text(isEdit ? "Update Product" : "Submit for Approval", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color ?? const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A))),
        const SizedBox(height: 2),
        Text(subtitle, style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildFormLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: const Color(0xFF334155)),
      ),
    );
  }

  InputDecoration _buildInputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE 4: ORDERS (Status tabs, customer details, fulfillment modal)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage4Orders(BuildContext context, EcosystemController controller, VendorPortalData? data) {
    var orders = data?.orders ?? [];

    if (_orderStatusFilter != "ALL") {
      orders = orders.where((o) => o.status.toUpperCase() == _orderStatusFilter).toList();
    }

    if (_orderSearchQuery.isNotEmpty) {
      orders = orders
          .where((o) =>
              o.orderNumber.toLowerCase().contains(_orderSearchQuery.toLowerCase()) ||
              o.customerName.toLowerCase().contains(_orderSearchQuery.toLowerCase()))
          .toList();
    }

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  onChanged: (v) => setState(() => _orderSearchQuery = v),
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: "Search by sub-order # or customer...",
                    prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildOrderFilterChip("ALL", "All (${data?.orders.length ?? 0})"),
                    _buildOrderFilterChip("PENDING", "Pending"),
                    _buildOrderFilterChip("PROCESSING", "Processing"),
                    _buildOrderFilterChip("SHIPPED", "Shipped"),
                    _buildOrderFilterChip("DELIVERED", "Delivered"),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 12),
                      Text("No Orders Found", style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: const Color(0xFF0F172A))),
                      const SizedBox(height: 6),
                      Text("Customer purchases will appear here with fulfillment actions.", style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF64748B))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (ctx, i) => _buildOrderTile(context, controller, orders[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildOrderFilterChip(String value, String label) {
    final isSelected = _orderStatusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF2563EB),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF475569),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        onSelected: (val) {
          if (val) setState(() => _orderStatusFilter = value);
        },
      ),
    );
  }

  Widget _buildOrderTile(BuildContext context, EcosystemController controller, EcosystemVendorOrder order) {
    Color badgeColor = const Color(0xFFF59E0B);
    if (order.status.toUpperCase() == "DELIVERED") badgeColor = const Color(0xFF10B981);
    if (order.status.toUpperCase() == "SHIPPED") badgeColor = const Color(0xFF2563EB);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderNumber.isNotEmpty ? order.orderNumber : "Order #${order.id.substring(0, 8)}",
                style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("Customer: ${order.customerName}", style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: const Color(0xFF334155))),
          if (order.shippingAddress != null && order.shippingAddress!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text("Ship to: ${order.shippingAddress}", style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF64748B))),
          ],
          const SizedBox(height: 8),
          ...order.items.map((it) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${it.quantity}x ${it.productName}", style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                    Text(controller.formatCurrency(it.total), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total: ${controller.formatCurrency(order.total)}", style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
                  Text("Net Earnings: ${controller.formatCurrency(order.vendorEarnings)}", style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: const Color(0xFF10B981))),
                ],
              ),
              if (order.status.toUpperCase() == "DELIVERED")
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF059669),
                    side: const BorderSide(color: Color(0xFF10B981)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF059669)),
                  label: const Text("Delivered", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () => _showFulfillmentModal(context, controller, order),
                )
              else
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.local_shipping_outlined, size: 14),
                  label: const Text("Fulfill", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () => _showFulfillmentModal(context, controller, order),
                ),
            ],
          ),
          if (order.status.toUpperCase() == "DELIVERED") ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: order.isCleared ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: order.isCleared ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  Icon(
                    order.isCleared ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                    size: 14,
                    color: order.isCleared ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.isCleared
                          ? "Funds Cleared & Available for Payout"
                          : (order.clearanceStatus.isNotEmpty
                              ? order.clearanceStatus
                              : "${order.daysRemaining} days remaining in clearance"),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: order.isCleared ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (order.trackingNumber != null && order.trackingNumber!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_rounded, size: 14, color: Color(0xFF2563EB)),
                  const SizedBox(width: 6),
                  Text("${order.trackingCarrier ?? 'Carrier'}: ${order.trackingNumber}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFulfillmentModal(BuildContext context, EcosystemController controller, EcosystemVendorOrder order) {
    String selectedStatus = "SHIPPED";
    final trackingCtrl = TextEditingController(text: order.trackingNumber ?? "");
    String selectedCarrier = order.trackingCarrier ?? "Canada Post";

    final carriers = ["Canada Post", "UPS", "FedEx", "DHL Express", "USPS", "Royal Mail", "Other Carrier"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Fulfill Order", style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: const Color(0xFF0F172A))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              _buildFormLabel("Fulfillment Status"),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: _buildInputDec(""),
                items: const [
                  DropdownMenuItem(value: "PROCESSING", child: Text("Processing")),
                  DropdownMenuItem(value: "SHIPPED", child: Text("Shipped")),
                  DropdownMenuItem(value: "DELIVERED", child: Text("Delivered")),
                ],
                onChanged: (v) {
                  if (v != null) setModalState(() => selectedStatus = v);
                },
              ),
              const SizedBox(height: 12),
              _buildFormLabel("Shipping Carrier"),
              DropdownButtonFormField<String>(
                value: selectedCarrier,
                decoration: _buildInputDec(""),
                items: carriers.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) {
                  if (v != null) setModalState(() => selectedCarrier = v);
                },
              ),
              const SizedBox(height: 12),
              _buildFormLabel("Tracking Number"),
              TextField(
                controller: trackingCtrl,
                decoration: _buildInputDec("e.g. 7023 9120 4810 2931"),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await controller.fulfillVendorOrder(
                      subOrderId: order.id,
                      status: selectedStatus,
                      trackingNumber: trackingCtrl.text.trim(),
                      carrier: selectedCarrier,
                    );
                  },
                  child: const Text("Update Shipment & Notify Customer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE 5: EARNINGS & PAYOUTS
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage5Earnings(BuildContext context, EcosystemController controller, VendorPortalData? data) {
    final balance = data?.balance ?? 0.0;
    final gross = data?.grossSales ?? 0.0;
    final net = data?.netEarnings ?? 0.0;
    final commissionRate = data?.commissionRate ?? 10.0;
    final commissionAmt = data?.platformCommission ?? 0.0;
    final escrow = data?.escrowHolding ?? (data?.escrowPending ?? 0.0);
    final holdDays = data?.payoutHoldDays ?? 7;
    final minPayout = data?.minWithdrawalAmount ?? 20.0;
    final withdrawals = data?.withdrawals ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Available Settlement Balance", style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: const Color(0xFF94A3B8))),
                const SizedBox(height: 6),
                Text(controller.formatCurrency(balance), style: AppFontStyle.fontStyleW700(fontSize: 32, fontColor: Colors.white)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                    label: const Text("Withdraw Available Funds", style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _showPayoutRequestDialog(context, controller, balance, minPayout),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Dynamic Escrow Clearance Policy Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: holdDays == 0 ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: holdDays == 0 ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  holdDays == 0 ? Icons.bolt_rounded : Icons.shield_outlined,
                  size: 18,
                  color: holdDays == 0 ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    holdDays == 0
                        ? "Instant Clearance Active (0 Days Hold): Earnings clear immediately upon order delivery."
                        : "Escrow Protection Policy: Delivered order earnings are held for $holdDays days before releasing to Available Settlement Balance.",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: holdDays == 0 ? const Color(0xFF16A34A) : const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4-Stat Financial Breakdown
          Row(
            children: [
              Expanded(child: _buildMetricTile("Gross Marketplace Sales", controller.formatCurrency(gross), Icons.payments_outlined, const Color(0xFF10B981))),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricTile("Net Vendor Earnings", controller.formatCurrency(net), Icons.account_balance_outlined, const Color(0xFF2563EB))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  "Platform Commission",
                  commissionAmt > 0
                      ? "${commissionRate.toStringAsFixed(0)}% (-${controller.formatCurrency(commissionAmt)})"
                      : "${commissionRate.toStringAsFixed(0)}%",
                  Icons.pie_chart_outline_rounded,
                  const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  holdDays == 0 ? "Escrow Holding (Instant)" : "Escrow Holding ($holdDays-Day)",
                  controller.formatCurrency(escrow),
                  Icons.lock_clock_outlined,
                  const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text("Settlement & Payout History", style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A))),
          const SizedBox(height: 10),

          if (withdrawals.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text("No payout settlements requested yet.", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            )
          else
            ...withdrawals.map((w) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(controller.formatCurrency(w.amount), style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A))),
                          Text(w.method ?? "Direct Bank Transfer", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: w.status == "PROCESSED" || w.status == "COMPLETED" ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          w.status.toUpperCase(),
                          style: TextStyle(
                            color: w.status == "PROCESSED" || w.status == "COMPLETED" ? const Color(0xFF059669) : const Color(0xFFD97706),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  void _showPayoutRequestDialog(BuildContext context, EcosystemController controller, double availableBalance, [double minPayout = 20.0]) {
    final amountCtrl = TextEditingController(text: availableBalance >= minPayout ? availableBalance.toStringAsFixed(2) : "");
    final bankCtrl = TextEditingController(text: _bankNameCtrl.text);
    final accountCtrl = TextEditingController(text: _accountNumberCtrl.text);
    final holderCtrl = TextEditingController(text: _accountHolderCtrl.text);
    final routingCtrl = TextEditingController(text: _routingNumberCtrl.text);
    String selectedMethod = "Direct Bank Transfer";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Request Payout Settlement", style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: const Color(0xFF0F172A))),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                Text(
                  "Available for payout: ${controller.formatCurrency(availableBalance)} (Min. ${controller.currencySymbol}${minPayout.toStringAsFixed(2)})",
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),
                _buildFormLabel("Withdrawal Amount (${controller.currencySymbol}) *"),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDec(minPayout.toStringAsFixed(2)),
                ),
                const SizedBox(height: 12),
                _buildFormLabel("Settlement Method"),
                DropdownButtonFormField<String>(
                  value: selectedMethod,
                  decoration: _buildInputDec(""),
                  items: const [
                    DropdownMenuItem(value: "Direct Bank Transfer", child: Text("Direct Bank Transfer")),
                    DropdownMenuItem(value: "ACH / Wire Transfer", child: Text("ACH / Wire Transfer")),
                    DropdownMenuItem(value: "PayPal", child: Text("PayPal")),
                    DropdownMenuItem(value: "Wise", child: Text("Wise")),
                  ],
                  onChanged: (v) {
                    if (v != null) setModalState(() => selectedMethod = v);
                  },
                ),
                const SizedBox(height: 12),
                _buildFormLabel("Bank Name"),
                TextField(controller: bankCtrl, decoration: _buildInputDec("e.g. Royal Bank of Canada / Chase")),
                const SizedBox(height: 12),
                _buildFormLabel("Account Holder Name"),
                TextField(controller: holderCtrl, decoration: _buildInputDec("Legal name on account")),
                const SizedBox(height: 12),
                _buildFormLabel("Account Number / IBAN"),
                TextField(controller: accountCtrl, decoration: _buildInputDec("Account / IBAN number")),
                const SizedBox(height: 12),
                _buildFormLabel("Routing / SWIFT / Transit Number"),
                TextField(controller: routingCtrl, decoration: _buildInputDec("Transit or SWIFT code")),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final reqAmt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                      if (reqAmt < minPayout) {
                        Get.snackbar(
                          "Minimum Threshold",
                          "Minimum payout request amount is ${controller.currencySymbol}${minPayout.toStringAsFixed(2)}.",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      if (reqAmt > availableBalance) {
                        Get.snackbar(
                          "Insufficient Funds",
                          "Amount exceeds available balance.",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      Navigator.pop(ctx);
                      await controller.submitVendorPayout(
                        amount: reqAmt,
                        method: selectedMethod,
                        bankDetails: {
                          "bankName": bankCtrl.text.trim(),
                          "accountHolder": holderCtrl.text.trim(),
                          "accountNumber": accountCtrl.text.trim(),
                          "routingNumber": routingCtrl.text.trim(),
                        },
                      );
                    },
                    child: const Text("Confirm & Submit Withdrawal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE 6: STORE PROFILE
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage6StoreProfile(BuildContext context, EcosystemController controller, VendorPortalData? data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Storefront Branding & Identity", style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                      child: const Text("Storefront Active", style: TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildFormLabel("Store Display Name *"),
                TextField(controller: _storeNameCtrl, decoration: _buildInputDec("Store Name")),
                const SizedBox(height: 12),
                _buildFormLabel("Store Biography & Mission"),
                TextField(controller: _storeBioCtrl, maxLines: 3, decoration: _buildInputDec("Tell customers about your mission and artisan origins...")),
                const SizedBox(height: 12),
                _buildFormLabel("Official Website"),
                TextField(controller: _storeWebsiteCtrl, decoration: _buildInputDec("https://...")),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel("Store Contact Email"),
                          TextField(controller: _storeEmailCtrl, decoration: _buildInputDec("orders@store.org")),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel("Store Phone"),
                          TextField(controller: _storePhoneCtrl, decoration: _buildInputDec("+1 (555) 000-0000")),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFormLabel("Physical Operating / Workshop Address"),
                TextField(controller: _storeAddressCtrl, decoration: _buildInputDec("Street address, city, country")),
                const SizedBox(height: 18),
                Text("Storefront Policies", style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
                const SizedBox(height: 10),
                _buildFormLabel("Shipping & Dispatch Policy"),
                TextField(controller: _shippingPolicyCtrl, maxLines: 2, decoration: _buildInputDec("Describe handling windows and carriers...")),
                const SizedBox(height: 10),
                _buildFormLabel("Returns & Exchange Policy"),
                TextField(controller: _refundPolicyCtrl, maxLines: 2, decoration: _buildInputDec("Describe return acceptance conditions...")),
                const SizedBox(height: 10),
                _buildFormLabel("Customer Support & Inquiries"),
                TextField(controller: _supportInfoCtrl, decoration: _buildInputDec("e.g. Email support@domain.org within 24 hours")),
                const SizedBox(height: 18),
                Text("Social Media Channels", style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
                const SizedBox(height: 10),
                TextField(controller: _instagramCtrl, decoration: _buildInputDec("Instagram handle (e.g. @artisanstore)")),
                const SizedBox(height: 8),
                TextField(controller: _facebookCtrl, decoration: _buildInputDec("Facebook page URL")),
                const SizedBox(height: 8),
                TextField(controller: _twitterCtrl, decoration: _buildInputDec("Twitter / X handle")),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await controller.saveVendorProfile(
                        storeName: _storeNameCtrl.text.trim(),
                        description: _storeBioCtrl.text.trim(),
                        website: _storeWebsiteCtrl.text.trim(),
                        storeEmail: _storeEmailCtrl.text.trim(),
                        storePhone: _storePhoneCtrl.text.trim(),
                        storeAddress: _storeAddressCtrl.text.trim(),
                        shippingPolicy: _shippingPolicyCtrl.text.trim(),
                        refundPolicy: _refundPolicyCtrl.text.trim(),
                        supportInfo: _supportInfoCtrl.text.trim(),
                        socialLinks: {
                          "instagram": _instagramCtrl.text.trim(),
                          "facebook": _facebookCtrl.text.trim(),
                          "twitter": _twitterCtrl.text.trim(),
                        },
                      );
                    },
                    child: const Text("Save Store Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE 7: NOTIFICATIONS
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage7Notifications(BuildContext context, VendorPortalData? data) {
    final notifs = data?.notifications ?? [];

    return notifs.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.notifications_none_rounded, size: 48, color: Color(0xFF94A3B8)),
                const SizedBox(height: 12),
                Text("No New Notifications", style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: const Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text("Order updates and admin approvals will appear here.", style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF64748B))),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifs.length,
            itemBuilder: (ctx, i) {
              final n = notifs[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: n.isRead ? Colors.white : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: n.isRead ? const Color(0xFFE2E8F0) : const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: n.isRead ? const Color(0xFFF1F5F9) : const Color(0xFFDBEAFE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        n.type == "ORDER" ? Icons.receipt_long : (n.type == "PAYOUT" ? Icons.payments : Icons.notifications),
                        size: 16,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.title, style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text(n.message, style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF475569))),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE 8: SETTINGS
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage8Settings(BuildContext context, EcosystemController controller, VendorPortalData? data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Settlement & Banking Settings", style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A))),
                const SizedBox(height: 14),
                _buildFormLabel("Preferred Payout Method"),
                DropdownButtonFormField<String>(
                  value: _payoutMethod,
                  decoration: _buildInputDec(""),
                  items: const [
                    DropdownMenuItem(value: "Direct Bank Transfer", child: Text("Direct Bank Transfer")),
                    DropdownMenuItem(value: "ACH / Wire", child: Text("ACH / Wire")),
                    DropdownMenuItem(value: "PayPal", child: Text("PayPal")),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _payoutMethod = v);
                  },
                ),
                const SizedBox(height: 12),
                _buildFormLabel("Bank Institution Name"),
                TextField(controller: _bankNameCtrl, decoration: _buildInputDec("e.g. Royal Bank of Canada")),
                const SizedBox(height: 12),
                _buildFormLabel("Account Holder"),
                TextField(controller: _accountHolderCtrl, decoration: _buildInputDec("Legal name on account")),
                const SizedBox(height: 12),
                _buildFormLabel("Account Number / IBAN"),
                TextField(controller: _accountNumberCtrl, decoration: _buildInputDec("Bank account number")),
                const SizedBox(height: 12),
                _buildFormLabel("Routing / SWIFT / Transit Code"),
                TextField(controller: _routingNumberCtrl, decoration: _buildInputDec("Routing code")),
                const SizedBox(height: 20),
                Text("Notification Preferences", style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Customer Order Alerts", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  value: _notifyOrder,
                  activeColor: const Color(0xFF2563EB),
                  onChanged: (v) => setState(() => _notifyOrder = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Settlement Payout Confirmations", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  value: _notifyPayout,
                  activeColor: const Color(0xFF2563EB),
                  onChanged: (v) => setState(() => _notifyPayout = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Low Stock Warnings", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  value: _notifyStock,
                  activeColor: const Color(0xFF2563EB),
                  onChanged: (v) => setState(() => _notifyStock = v),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await controller.saveVendorSettings({
                        "payoutMethod": _payoutMethod,
                        "bankName": _bankNameCtrl.text.trim(),
                        "accountHolder": _accountHolderCtrl.text.trim(),
                        "accountNumber": _accountNumberCtrl.text.trim(),
                        "routingNumber": _routingNumberCtrl.text.trim(),
                        "handlingDays": _handlingDays,
                        "notifyOrderAlert": _notifyOrder,
                        "notifyPayoutAlert": _notifyPayout,
                        "notifyStockAlert": _notifyStock,
                      });
                    },
                    child: const Text("Save Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
