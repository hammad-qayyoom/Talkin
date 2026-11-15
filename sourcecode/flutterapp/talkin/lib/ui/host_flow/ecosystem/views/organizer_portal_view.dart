import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/ui/host_flow/ecosystem/controllers/ecosystem_controller.dart';
import 'package:notisboard/ui/host_flow/ecosystem/models/ecosystem_items_model.dart';
import 'package:notisboard/utils/font_style.dart';

class OrganizerPortalView extends StatefulWidget {
  const OrganizerPortalView({super.key});

  @override
  State<OrganizerPortalView> createState() => _OrganizerPortalViewState();
}

class _OrganizerPortalViewState extends State<OrganizerPortalView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedPageIndex = 1; // Default to Dashboard (Page 1)

  // Event Creation & Edit State
  String? _editingEventId;
  final _eventTitleCtrl = TextEditingController();
  final _eventDescCtrl = TextEditingController();
  final _eventVenueCtrl = TextEditingController();
  final _eventStreetCtrl = TextEditingController();
  final _eventCityCtrl = TextEditingController();
  final _eventCountryCtrl = TextEditingController();
  final _eventOnlineUrlCtrl = TextEditingController();
  final _eventMaxAttendeesCtrl = TextEditingController(text: "100");
  final _eventMetaTitleCtrl = TextEditingController();
  final _eventMetaDescCtrl = TextEditingController();
  String _eventCategory = "Official Events";
  String _eventTimezone = "UTC";
  int _eventCheckInWindow = 30; // minutes
  bool _eventIsOnline = false;
  DateTime _eventStartDate = DateTime.now().add(const Duration(days: 7, hours: 2));
  DateTime _eventEndDate = DateTime.now().add(const Duration(days: 7, hours: 6));
  String? _eventImagePath;
  String? _eventExistingImageUrl;
  List<EventTicketTier> _eventTickets = [];

  // Campaign Controllers
  final _campTitleCtrl = TextEditingController();
  final _campDescCtrl = TextEditingController();
  final _campBeneficiaryCtrl = TextEditingController();
  final _campGoalCtrl = TextEditingController();
  String? _campImagePath;

  // Profile Controllers
  final _orgNameCtrl = TextEditingController();
  final _orgTypeCtrl = TextEditingController();
  final _orgDescCtrl = TextEditingController();
  final _orgWebsiteCtrl = TextEditingController();
  final _orgEmailCtrl = TextEditingController();
  final _orgPhoneCtrl = TextEditingController();
  final _fbCtrl = TextEditingController();
  final _twCtrl = TextEditingController();
  final _igCtrl = TextEditingController();
  final _liCtrl = TextEditingController();
  bool _profileInitialized = false;

  // Settings & Payout Controllers
  String _payoutMethod = "Direct Bank Transfer";
  final _bankNameCtrl = TextEditingController();
  final _accountHolderCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _routingNumberCtrl = TextEditingController();
  int _defaultCheckInWindow = 30;
  String _defaultTimezone = "UTC";
  bool _notifyTicketSold = true;
  bool _notifyCheckIn = true;
  bool _notifyPayout = true;
  bool _settingsInitialized = false;

  // KYC Dossier switch (Individual Host vs Organization)
  String _kycDossierType = "organization";

  // Filter & Search states
  String _eventFilter = "ALL"; // ALL, PUBLISHED, PENDING_REVIEW, DRAFT, CHANGES_REQUESTED, COMPLETED
  String _eventSearchQuery = "";
  final _eventSearchCtrl = TextEditingController();

  String _payoutHistoryFilter = "ALL";
  String _notifFilter = "ALL";
  String _financialPeriod = "30D"; // 30D, 90D, 1Y, ALL
  int _dashboardActivityTab = 0; // 0: Recent Activity, 1: Notifications
  int _settingsSubTab = 0; // 0: Profile, 1: Payout & Banking, 2: Event Defaults, 3: Security & Access

  final List<String> _timezoneOptions = [
    "UTC",
    "America/New_York (EST)",
    "America/Chicago (CST)",
    "America/Los_Angeles (PST)",
    "America/Toronto (EDT)",
    "Europe/London (GMT)",
    "Europe/Paris (CET)",
    "Asia/Karachi (PKT)",
    "Asia/Dubai (GST)",
    "Asia/Kolkata (IST)",
  ];

  @override
  void initState() {
    super.initState();
    _resetEventTickets();
  }

  void _resetEventTickets() {
    _eventTickets = [
      EventTicketTier(name: "General Admission", price: 0.0, quantity: 100, description: "Standard event access"),
    ];
  }

  @override
  void dispose() {
    _eventTitleCtrl.dispose();
    _eventDescCtrl.dispose();
    _eventVenueCtrl.dispose();
    _eventStreetCtrl.dispose();
    _eventCityCtrl.dispose();
    _eventCountryCtrl.dispose();
    _eventOnlineUrlCtrl.dispose();
    _eventMaxAttendeesCtrl.dispose();
    _eventMetaTitleCtrl.dispose();
    _eventMetaDescCtrl.dispose();
    _eventSearchCtrl.dispose();

    _campTitleCtrl.dispose();
    _campDescCtrl.dispose();
    _campBeneficiaryCtrl.dispose();
    _campGoalCtrl.dispose();

    _orgNameCtrl.dispose();
    _orgTypeCtrl.dispose();
    _orgDescCtrl.dispose();
    _orgWebsiteCtrl.dispose();
    _orgEmailCtrl.dispose();
    _orgPhoneCtrl.dispose();
    _fbCtrl.dispose();
    _twCtrl.dispose();
    _igCtrl.dispose();
    _liCtrl.dispose();

    _bankNameCtrl.dispose();
    _accountHolderCtrl.dispose();
    _accountNumberCtrl.dispose();
    _routingNumberCtrl.dispose();
    super.dispose();
  }

  void _initProfileData(OrganizerPortalData data) {
    if (_profileInitialized) return;
    final p = data.profileData;
    _orgNameCtrl.text = p?.organizationName ?? data.organizationName;
    _orgTypeCtrl.text = p?.organizationType ?? data.organizationType;
    _orgDescCtrl.text = p?.description ?? "";
    _orgWebsiteCtrl.text = p?.website ?? "";
    _orgEmailCtrl.text = p?.email ?? "";
    _orgPhoneCtrl.text = p?.phone ?? "";
    _fbCtrl.text = p?.socialLinks['facebook']?.toString() ?? "";
    _twCtrl.text = p?.socialLinks['twitter']?.toString() ?? "";
    _igCtrl.text = p?.socialLinks['instagram']?.toString() ?? "";
    _liCtrl.text = p?.socialLinks['linkedin']?.toString() ?? "";
    _profileInitialized = true;
  }

  void _initSettingsData(OrganizerPortalData data) {
    if (_settingsInitialized) return;
    final s = data.settings;
    if (s != null) {
      _payoutMethod = s.payoutMethod.isNotEmpty ? s.payoutMethod : "Direct Bank Transfer";
      _bankNameCtrl.text = s.bankName;
      _accountHolderCtrl.text = s.accountHolder;
      _accountNumberCtrl.text = s.accountNumber;
      _routingNumberCtrl.text = s.routingNumber;
      _notifyTicketSold = s.notifyRegistrationAlert;
      _notifyCheckIn = s.notifyEventReminder;
      _notifyPayout = s.notifyDonationAlert;
    }
    _settingsInitialized = true;
  }

  void _navigateToPage(int index) {
    setState(() => _selectedPageIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Get.back();
    }
  }

  void _resetEventForm() {
    _editingEventId = null;
    _eventTitleCtrl.clear();
    _eventDescCtrl.clear();
    _eventVenueCtrl.clear();
    _eventStreetCtrl.clear();
    _eventCityCtrl.clear();
    _eventCountryCtrl.clear();
    _eventOnlineUrlCtrl.clear();
    _eventMaxAttendeesCtrl.text = "100";
    _eventMetaTitleCtrl.clear();
    _eventMetaDescCtrl.clear();
    _eventIsOnline = false;
    _eventStartDate = DateTime.now().add(const Duration(days: 7, hours: 2));
    _eventEndDate = DateTime.now().add(const Duration(days: 7, hours: 6));
    _eventImagePath = null;
    _eventExistingImageUrl = null;
    _resetEventTickets();
  }

  void _populateEventForEdit(EcosystemEvent event) {
    _editingEventId = event.id;
    _eventTitleCtrl.text = event.title;
    _eventDescCtrl.text = event.description;
    _eventVenueCtrl.text = event.venue ?? "";
    _eventStreetCtrl.text = event.address ?? "";
    _eventCityCtrl.text = event.city ?? "";
    _eventCountryCtrl.text = event.country ?? "";
    _eventOnlineUrlCtrl.text = event.onlineUrl ?? "";
    _eventMaxAttendeesCtrl.text = event.maxAttendees.toString();
    _eventMetaTitleCtrl.text = event.metaTitle ?? "";
    _eventMetaDescCtrl.text = event.metaDescription ?? "";
    _eventCategory = (event.category != null && event.category!.isNotEmpty) ? event.category! : "Official Events";
    _eventTimezone = event.timezone.isNotEmpty ? event.timezone : "UTC";
    _eventCheckInWindow = event.checkInWindowMinutes > 0 ? event.checkInWindowMinutes : 30;
    _eventIsOnline = event.isOnline;
    _eventStartDate = DateTime.tryParse(event.startDateTime) ?? DateTime.now().add(const Duration(days: 7));
    _eventEndDate = DateTime.tryParse(event.endDateTime) ?? DateTime.now().add(const Duration(days: 7, hours: 4));
    _eventImagePath = null;
    _eventExistingImageUrl = event.featuredImage;

    if (event.tickets.isNotEmpty) {
      _eventTickets = event.tickets.map((t) => EventTicketTier(
        id: t.id,
        name: t.name,
        price: t.price,
        quantity: t.quantity,
        soldCount: t.soldCount,
        description: t.description,
      )).toList();
    } else {
      _eventTickets = [
        EventTicketTier(name: "General Admission", price: event.priceFrom, quantity: event.maxAttendees, description: "Standard event admission"),
      ];
    }

    _navigateToPage(3); // Navigate to Create/Edit Event
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EcosystemController>(
      builder: (controller) {
        final data = controller.organizerPortalData;
        if (data != null) {
          _initProfileData(data);
          _initSettingsData(data);
        }

        final unreadNotifs = data?.notifications.where((n) => !n.isRead).length ?? 0;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: _buildTopHeaderBar(context, controller, data, unreadNotifs),
          drawer: _buildWebMatchingSidebarDrawer(context, data, unreadNotifs),
          bottomNavigationBar: _buildBottomQuickBar(),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
              : IndexedStack(
                  index: _selectedPageIndex,
                  children: [
                    _buildPage0KycVerification(context, data),
                    _buildPage1Dashboard(context, controller, data),
                    _buildPage2MyEvents(context, controller, data),
                    _buildPage3CreateEvent(context, controller, data),
                    _buildPage4Earnings(context, controller, data),
                    _buildPage5Payouts(context, controller, data),
                    _buildPage6Campaigns(context, controller, data),
                    _buildPage7Notifications(context, controller, data),
                    _buildPage8ProfileAndSettings(context, controller, data),
                  ],
                ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TOP BAR: BRANDING, SEARCH, NOTIFICATIONS, PORTAL SWITCHER
  // ══════════════════════════════════════════════════════════════
  PreferredSizeWidget _buildTopHeaderBar(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
    int unreadNotifs,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Color(0xFF1E293B)),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.confirmation_number_outlined, size: 14, color: Color(0xFF2563EB)),
                const SizedBox(width: 4),
                Text(
                  "ORGANIZER",
                  style: AppFontStyle.fontStyleW700(fontSize: 10, fontColor: const Color(0xFF2563EB)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getPageTitle(_selectedPageIndex),
              overflow: TextOverflow.ellipsis,
              style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF475569), size: 20),
          tooltip: "Sync with Foundation",
          onPressed: () => controller.loadOrganizerPortal(),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Color(0xFF475569)),
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
                    unreadNotifs > 9 ? "9+" : "$unreadNotifs",
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return "KYC Verification";
      case 1:
        return "Organizer Dashboard";
      case 2:
        return "My Events";
      case 3:
        return _editingEventId != null ? "Edit Event" : "Create Event";
      case 4:
        return "Earnings & Revenue";
      case 5:
        return "Payouts & Settlements";
      case 6:
        return "Campaigns & Causes";
      case 7:
        return "Notifications";
      case 8:
        return "Profile & Settings";
      default:
        return "Organizer Portal";
    }
  }

  // ══════════════════════════════════════════════════════════════
  // DRAWER: SIDEBAR MATCHING organizer.notisboardglobalfoundation.org
  // ══════════════════════════════════════════════════════════════
  Widget _buildWebMatchingSidebarDrawer(BuildContext context, OrganizerPortalData? data, int unreadNotifs) {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: SafeArea(
        child: Column(
          children: [
            // Top Header Branding
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
                    child: const Text("N", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Notisboard", style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: Colors.white)),
                        Text("ORGANIZER PORTAL", style: AppFontStyle.fontStyleW600(fontSize: 10, fontColor: const Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 9 Menu Items
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
                    icon: Icons.event_outlined,
                    title: "My Events",
                    badgeText: "${data?.events.length ?? 0}",
                    badgeColor: const Color(0xFF334155),
                  ),
                  _buildDrawerNavItem(
                    index: 3,
                    icon: Icons.add_circle_outline,
                    title: "+ Create Event",
                    highlight: true,
                    onTapOverride: () {
                      _resetEventForm();
                      _navigateToPage(3);
                    },
                  ),
                  _buildDrawerNavItem(
                    index: 4,
                    icon: Icons.account_balance_wallet_outlined,
                    title: "Earnings & Revenue",
                  ),
                  _buildDrawerNavItem(
                    index: 5,
                    icon: Icons.payments_outlined,
                    title: "Payouts & Settlements",
                  ),
                  _buildDrawerNavItem(
                    index: 6,
                    icon: Icons.volunteer_activism_outlined,
                    title: "Fundraising Campaigns",
                    badgeText: "${data?.campaigns.length ?? 0}",
                    badgeColor: const Color(0xFF334155),
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
                    title: "Profile & Settings",
                  ),
                ],
              ),
            ),

            // Bottom Profile Box
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
                      (data?.organizationName.isNotEmpty ?? false) ? data!.organizationName[0].toUpperCase() : "O",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data?.organizationName ?? "Official Organizer",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: Colors.white),
                        ),
                        Text(
                          "Verified Event Host",
                          style: AppFontStyle.fontStyleW400(fontSize: 10, fontColor: const Color(0xFF10B981)),
                        ),
                      ],
                    ),
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
    Color badgeColor = const Color(0xFF2563EB),
    bool highlight = false,
    VoidCallback? onTapOverride,
  }) {
    final isSelected = _selectedPageIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF1E293B)
            : (highlight ? const Color(0xFF2563EB).withValues(alpha: 0.15) : Colors.transparent),
        borderRadius: BorderRadius.circular(10),
        border: isSelected ? Border.all(color: const Color(0xFF2563EB)) : null,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          size: 20,
          color: isSelected
              ? const Color(0xFF38BDF8)
              : (highlight ? const Color(0xFF60A5FA) : const Color(0xFF94A3B8)),
        ),
        title: Text(
          title,
          style: AppFontStyle.fontStyleW600(
            fontSize: 13,
            fontColor: isSelected ? Colors.white : const Color(0xFFCBD5E1),
          ),
        ),
        trailing: badgeText != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  badgeText,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            : null,
        onTap: onTapOverride ?? () => _navigateToPage(index),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // BOTTOM BAR: DASHBOARD, EVENTS, EARNINGS, PROFILE
  // ══════════════════════════════════════════════════════════════
  Widget _buildBottomQuickBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF2563EB),
      unselectedItemColor: const Color(0xFF64748B),
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedPageIndex == 1
          ? 0
          : (_selectedPageIndex == 2
              ? 1
              : (_selectedPageIndex == 4 ? 2 : (_selectedPageIndex == 8 ? 3 : 0))),
      onTap: (index) {
        if (index == 0) _navigateToPage(1);
        if (index == 1) _navigateToPage(2);
        if (index == 2) _navigateToPage(4);
        if (index == 3) _navigateToPage(8);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.event_outlined), label: "Events"),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: "Earnings"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE 0: ORGANIZER KYC VERIFICATION MODULE (/organizer/verification)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage0KycVerification(BuildContext context, OrganizerPortalData? data) {
    final dossier = data?.dossier;
    final isOrg = _kycDossierType == "organization";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("COMPLIANCE & VERIFICATION", style: AppFontStyle.fontStyleW600(fontSize: 11, fontColor: const Color(0xFF2563EB))),
          const SizedBox(height: 4),
          Text("Organizer KYC Document Verification", style: AppFontStyle.fontStyleW700(fontSize: 20, fontColor: const Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Text(
            "In accordance with international non-profit and event compliance guidelines, organizers must hold verified identity records prior to ticket sales payout unlocking.",
            style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 18),

          // Green Verified Banner matching Screenshot 7
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      "CURRENT STATUS: VERIFIED & UNLOCKED",
                      style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF065F46)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Full Event Creation & Ticketing Privileges Unlocked! Your official compliance documentation has been approved by Foundation Administration. You have unrestricted access to all organizer features.",
                  style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF047857)),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text("Go to Organizer Dashboard", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => _navigateToPage(1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Locked Compliance Dossier notice
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded, color: Color(0xFF475569), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Verified Compliance Dossier (Locked)",
                        style: AppFontStyle.fontStyleW700(fontSize: 12, fontColor: const Color(0xFF1E293B)),
                      ),
                      Text(
                        "In compliance with charity regulatory standards, verified organizer identity and entity records are permanently locked against modifications.",
                        style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(6)),
                  child: const Text("READ-ONLY", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Dossier Switcher: Individual Host vs Organization
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _kycDossierType = "individual"),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !isOrg ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Individual Host",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: !isOrg ? const Color(0xFF0F172A) : const Color(0xFF64748B)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _kycDossierType = "organization"),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isOrg ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Organization / Non-profit",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isOrg ? const Color(0xFF0F172A) : const Color(0xFF64748B)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Dossier Fields Card
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
                if (!isOrg) ...[
                  _buildDossierRow("Legal Full Name", "${dossier?.firstName ?? 'Eleanor'} ${dossier?.lastName ?? 'Vance'}", isVerified: true),
                  _buildDossierRow("Contact Phone", dossier?.phone.isNotEmpty == true ? dossier!.phone : "+1 (555) 000-0000", isVerified: true),
                  _buildDossierRow("Primary Email", dossier?.email.isNotEmpty == true ? dossier!.email : "organizer@domain.org", isVerified: true),
                  _buildDossierRow("City / Region", dossier?.city.isNotEmpty == true ? dossier!.city : "Toronto, ON", isVerified: true),
                  _buildDossierRow("Country", dossier?.country.isNotEmpty == true ? dossier!.country : "Canada", isVerified: true),
                  _buildDossierRow("Government ID Type", "Passport / Driver's License", isVerified: true),
                ] else ...[
                  _buildDossierRow("Organization Name", dossier?.organizationName.isNotEmpty == true ? dossier!.organizationName : data?.organizationName ?? "Hope Foundation", isVerified: true),
                  _buildDossierRow("Organization Category", dossier?.organizationType.isNotEmpty == true ? dossier!.organizationType : "Registered Non-Profit / NGO", isVerified: true),
                  _buildDossierRow("Official Website", dossier?.website.isNotEmpty == true ? dossier!.website : "https://notisboardglobalfoundation.org", isVerified: true),
                  _buildDossierRow("Primary Contact", "${dossier?.firstName ?? 'Eleanor'} ${dossier?.lastName ?? 'Vance'}", isVerified: true),
                  _buildDossierRow("Entity Location", "${dossier?.city ?? 'Toronto'}, ${dossier?.country ?? 'Canada'}", isVerified: true),
                  _buildDossierRow("Tax ID / EIN Dossier", "Official Non-Profit Certification on Record", isVerified: true),
                ],
                const Divider(height: 28, color: Color(0xFFE2E8F0)),
                Text("SETTLEMENT BANKING ON RECORD", style: AppFontStyle.fontStyleW700(fontSize: 11, fontColor: const Color(0xFF2563EB))),
                const SizedBox(height: 10),
                _buildDossierRow("Settlement Bank", data?.settings?.bankName.isNotEmpty == true ? data!.settings!.bankName : "Royal Bank of Canada / Chase", isVerified: true),
                _buildDossierRow("Account Legal Holder", data?.settings?.accountHolder.isNotEmpty == true ? data!.settings!.accountHolder : "Eleanor Vance", isVerified: true),
                _buildDossierRow("Account / IBAN", data?.settings?.accountNumber.isNotEmpty == true ? data!.settings!.accountNumber : "•••••••• 4829", isVerified: true),
                _buildDossierRow("Transit / SWIFT", data?.settings?.routingNumber.isNotEmpty == true ? data!.settings!.routingNumber : "•••• 0210", isVerified: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDossierRow(String label, String value, {bool isVerified = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ),
                if (isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 10, color: Color(0xFF059669)),
                        SizedBox(width: 2),
                        Text("Certified", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                      ],
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
  // PAGE 1: ORGANIZER DASHBOARD
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage1Dashboard(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    final events = data?.events ?? controller.events;
    final attendees = data?.attendees ?? [];
    final totalEvents = data?.totalEvents ?? events.length;
    final publishedEvents = data?.publishedEvents ?? events.where((e) => e.status == "PUBLISHED").length;
    final totalTicketsSold = data?.totalTicketsSold ?? 0;
    final netEarnings = data?.netEarnings ?? 0.0;
    final grossRevenue = data?.grossRevenue ?? 0.0;
    final commission = data?.commission ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                data?.organizationName ?? "Organizer Portal",
                                style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.verified, size: 16, color: Color(0xFF38BDF8)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Foundation Event Ecosystem Active • Real-time Sync",
                            style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text("Create", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      onPressed: () {
                        _resetEventForm();
                        _navigateToPage(3);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 1.1 Dashboard Statistics (4 Summary Cards)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _buildStatCard("Total Events", "$totalEvents", "All created events", Icons.event_note_rounded, const Color(0xFF3B82F6)),
              _buildStatCard("Published Events", "$publishedEvents", "Live on Foundation", Icons.check_circle_outline, const Color(0xFF10B981)),
              _buildStatCard("Tickets Sold", "$totalTicketsSold", "Attendees registered", Icons.confirmation_number_outlined, const Color(0xFFF59E0B)),
              _buildStatCard("Net Earnings", controller.formatCurrency(netEarnings), "Available & cleared", Icons.account_balance_wallet_outlined, const Color(0xFF8B5CF6)),
            ],
          ),
          const SizedBox(height: 22),

          // 1.4 Financial Summary with Date Filter
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
                    Text("Financial Summary", style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A))),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _financialPeriod,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                        items: const [
                          DropdownMenuItem(value: "30D", child: Text("Last 30 Days")),
                          DropdownMenuItem(value: "90D", child: Text("Last 90 Days")),
                          DropdownMenuItem(value: "1Y", child: Text("This Year")),
                          DropdownMenuItem(value: "ALL", child: Text("All Time")),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _financialPeriod = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFinancialMetric("Gross Revenue", controller.formatCurrency(grossRevenue), const Color(0xFF0F172A)),
                    ),
                    Expanded(
                      child: _buildFinancialMetric("Platform Fee", "-${controller.formatCurrency(commission)}", const Color(0xFFDC2626)),
                    ),
                    Expanded(
                      child: _buildFinancialMetric("Net Settlement", controller.formatCurrency(netEarnings), const Color(0xFF059669)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.trending_up, size: 16),
                    label: const Text("View Detailed Earnings & Escrow Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    onPressed: () => _navigateToPage(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // 1.2 Upcoming & Recent Events
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Upcoming & Recent Events", style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A))),
              TextButton(
                onPressed: () => _navigateToPage(2),
                child: const Text("View All →", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (events.isEmpty)
            _buildEmptyState(
              icon: Icons.event_busy_outlined,
              title: "No Events Created Yet",
              subtitle: "Start hosting summits, webinars, and charity galas on Foundation.",
              buttonLabel: "+ Create First Event",
              onTap: () {
                _resetEventForm();
                _navigateToPage(3);
              },
            )
          else
            ...events.take(3).map((e) => _buildDashboardEventCard(context, controller, e)),

          const SizedBox(height: 22),

          // 1.3 Recent Registrations (with live attendee updates)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recent Registrations", style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A))),
              if (attendees.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                  child: Text("${attendees.length} Attendees", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (attendees.isEmpty)
            _buildEmptyState(
              icon: Icons.people_outline,
              title: "No Registrations Yet",
              subtitle: "Attendees who RSVP or buy tickets will appear here with live check-in.",
            )
          else
            ...attendees.take(4).map((a) => _buildAttendeeTile(context, controller, a)),

          const SizedBox(height: 22),

          // 1.5 Recent Activity & Notifications (Two Tabs)
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
                  children: [
                    _buildActivityTabButton(0, "Recent Activity"),
                    const SizedBox(width: 8),
                    _buildActivityTabButton(1, "Notifications (${data?.notifications.where((n) => !n.isRead).length ?? 0})"),
                  ],
                ),
                const SizedBox(height: 14),
                if (_dashboardActivityTab == 0) ...[
                  if (attendees.isEmpty && events.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text("No recent event activity recorded.", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    )
                  else ...[
                    if (attendees.isNotEmpty)
                      _buildActivityItem(
                        icon: Icons.person_add_alt_1_outlined,
                        color: const Color(0xFF10B981),
                        title: "New attendee registration",
                        subtitle: "${attendees.first.firstName} registered for ${attendees.first.eventTitle}",
                        time: attendees.first.createdAt != null ? DateFormat('dd MMM, hh:mm a').format(DateTime.parse(attendees.first.createdAt!)) : "Just now",
                      ),
                    if (events.isNotEmpty)
                      _buildActivityItem(
                        icon: Icons.event_available,
                        color: const Color(0xFF3B82F6),
                        title: "Event published to Foundation",
                        subtitle: "${events.first.title} is now active",
                        time: "Recent",
                      ),
                    _buildActivityItem(
                      icon: Icons.shield_outlined,
                      color: const Color(0xFF8B5CF6),
                      title: "Compliance dossier verified",
                      subtitle: "All organizer privileges unlocked",
                      time: "System",
                    ),
                  ],
                ] else ...[
                  if (data?.notifications.isEmpty ?? true)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text("No organizer notifications yet.", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    )
                  else
                    ...data!.notifications.take(3).map((n) => _buildActivityItem(
                          icon: Icons.notifications_active_outlined,
                          color: const Color(0xFFF59E0B),
                          title: n.title,
                          subtitle: n.message,
                          time: n.createdAt.isNotEmpty ? DateFormat('dd MMM').format(DateTime.tryParse(n.createdAt) ?? DateTime.now()) : "Alert",
                        )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              CircleAvatar(
                radius: 14,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, size: 14, color: color),
              ),
            ],
          ),
          Text(value, style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: const Color(0xFF0F172A))),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildFinancialMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildDashboardEventCard(BuildContext context, EcosystemController controller, EcosystemEvent e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              image: e.featuredImage != null && e.featuredImage!.isNotEmpty
                  ? DecorationImage(image: NetworkImage(e.featuredImage!), fit: BoxFit.cover)
                  : null,
            ),
            child: e.featuredImage == null || e.featuredImage!.isEmpty
                ? const Icon(Icons.event, color: Color(0xFF2563EB))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  e.isOnline ? "Virtual Streaming Event" : (e.venue ?? "Venue TBA"),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatusPill(e.status),
                    const SizedBox(width: 8),
                    Text(
                      "${e.registeredAttendees} RSVP",
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
            onPressed: () => _populateEventForEdit(e),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeeTile(BuildContext context, EcosystemController controller, EcosystemAttendee a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: a.checkedIn ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
            child: Text(
              a.firstName.isNotEmpty ? a.firstName[0].toUpperCase() : "A",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: a.checkedIn ? const Color(0xFF059669) : const Color(0xFF2563EB)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${a.firstName} ${a.lastName}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                Text("${a.eventTitle} • #${a.ticketNumber}", style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => controller.checkInAttendee(a.id, !a.checkedIn),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: a.checkedIn ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: a.checkedIn ? const Color(0xFFA7F3D0) : const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(a.checkedIn ? Icons.check_circle : Icons.radio_button_unchecked, size: 12, color: a.checkedIn ? const Color(0xFF059669) : const Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    a.checkedIn ? "Checked In" : "Check In",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: a.checkedIn ? const Color(0xFF059669) : const Color(0xFF475569)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTabButton(int tabIndex, String label) {
    final isSelected = _dashboardActivityTab == tabIndex;
    return GestureDetector(
      onTap: () => setState(() => _dashboardActivityTab = tabIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = const Color(0xFF475569);
    final s = status.toUpperCase();

    if (s == "PUBLISHED") {
      bg = const Color(0xFFECFDF5);
      fg = const Color(0xFF059669);
    } else if (s == "PENDING_REVIEW") {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
    } else if (s == "DRAFT") {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF2563EB);
    } else if (s == "CHANGES_REQUESTED" || s == "REJECTED") {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFDC2626);
    } else if (s == "COMPLETED") {
      bg = const Color(0xFFF3F4F6);
      fg = const Color(0xFF4B5563);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(s, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE 2: MY EVENTS MODULE (/organizer/events)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage2MyEvents(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    var events = data?.events ?? controller.events;

    // Filter by Search
    if (_eventSearchQuery.isNotEmpty) {
      final q = _eventSearchQuery.toLowerCase();
      events = events.where((e) =>
          e.title.toLowerCase().contains(q) ||
          (e.venue?.toLowerCase().contains(q) ?? false) ||
          (e.city?.toLowerCase().contains(q) ?? false)).toList();
    }

    // Filter by Status Tab (6 Filters)
    if (_eventFilter == "PUBLISHED") {
      events = events.where((e) => e.status == "PUBLISHED").toList();
    } else if (_eventFilter == "PENDING_REVIEW") {
      events = events.where((e) => e.status == "PENDING_REVIEW").toList();
    } else if (_eventFilter == "DRAFT") {
      events = events.where((e) => e.status == "DRAFT").toList();
    } else if (_eventFilter == "CHANGES_REQUESTED") {
      events = events.where((e) => e.status == "CHANGES_REQUESTED" || e.status == "REJECTED").toList();
    } else if (_eventFilter == "COMPLETED") {
      events = events.where((e) => e.status == "COMPLETED").toList();
    }

    final rawAllEvents = data?.events ?? controller.events;
    final totalCount = rawAllEvents.length;
    final pubCount = rawAllEvents.where((e) => e.status == "PUBLISHED").length;
    final pendingCount = rawAllEvents.where((e) => e.status == "PENDING_REVIEW").length;
    final draftCount = rawAllEvents.where((e) => e.status == "DRAFT").length;
    final changesCount = rawAllEvents.where((e) => e.status == "CHANGES_REQUESTED" || e.status == "REJECTED").length;
    final completedCount = rawAllEvents.where((e) => e.status == "COMPLETED").length;

    return Column(
      children: [
        // Top 4 Stat Cards
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildMiniStatTile("Total Events", "$totalCount", Icons.event, const Color(0xFF2563EB))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMiniStatTile("Published", "$pubCount", Icons.check_circle, const Color(0xFF10B981))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMiniStatTile("Pending", "$pendingCount", Icons.schedule, const Color(0xFFF59E0B))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMiniStatTile("Drafts", "$draftCount", Icons.edit_note, const Color(0xFF64748B))),
                ],
              ),
              const SizedBox(height: 12),
              // Search input
              TextField(
                controller: _eventSearchCtrl,
                onChanged: (v) => setState(() => _eventSearchQuery = v),
                decoration: InputDecoration(
                  hintText: "Search events by title, venue, or city...",
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                  suffixIcon: _eventSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _eventSearchCtrl.clear();
                            setState(() => _eventSearchQuery = "");
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
            ],
          ),
        ),

        // 6 Status Filter Chips (Scrollable)
        Container(
          color: Colors.white,
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              _buildFilterTabChip("ALL", "All ($totalCount)"),
              _buildFilterTabChip("PUBLISHED", "Published ($pubCount)"),
              _buildFilterTabChip("PENDING_REVIEW", "Pending ($pendingCount)"),
              _buildFilterTabChip("DRAFT", "Drafts ($draftCount)"),
              _buildFilterTabChip("CHANGES_REQUESTED", "Changes ($changesCount)"),
              _buildFilterTabChip("COMPLETED", "Completed ($completedCount)"),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Event List
        Expanded(
          child: events.isEmpty
              ? _buildEmptyState(
                  icon: Icons.event_busy_outlined,
                  title: "No Events Matching Filter",
                  subtitle: "Try clearing search or filters to see all events.",
                  buttonLabel: "+ Create New Event",
                  onTap: () {
                    _resetEventForm();
                    _navigateToPage(3);
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: events.length,
                  itemBuilder: (ctx, i) => _buildFullEventCard(context, controller, events[i], data?.attendees ?? []),
                ),
        ),
      ],
    );
  }

  Widget _buildMiniStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildFilterTabChip(String key, String label) {
    final isSelected = _eventFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
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
          if (val) setState(() => _eventFilter = key);
        },
      ),
    );
  }

  Widget _buildFullEventCard(
    BuildContext context,
    EcosystemController controller,
    EcosystemEvent event,
    List<EcosystemAttendee> allAttendees,
  ) {
    final capacity = event.maxAttendees > 0 ? event.maxAttendees : 100;
    final registered = event.registeredAttendees;
    final progress = (registered / capacity).clamp(0.0, 1.0);
    final eventAttendees = allAttendees.where((a) => a.eventId == event.id || a.eventTitle == event.title).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image & Status Header
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  image: event.featuredImage != null && event.featuredImage!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(event.featuredImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: event.featuredImage == null || event.featuredImage!.isEmpty
                    ? const Center(child: Icon(Icons.confirmation_number_outlined, size: 36, color: Color(0xFF2563EB)))
                    : null,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: _buildStatusPill(event.status),
              ),
              if (event.category != null && event.category!.isNotEmpty)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      event.category!,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),

          // Content body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      event.startDateTime.isNotEmpty
                          ? DateFormat('EEE, dd MMM yyyy • hh:mm a').format(DateTime.tryParse(event.startDateTime) ?? DateTime.now())
                          : "Scheduled",
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(event.isOnline ? Icons.videocam_outlined : Icons.place_outlined, size: 14, color: const Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.isOnline ? "Virtual / Online Stream" : "${event.venue ?? 'Physical Venue'}, ${event.city ?? ''}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),

                // Changes Requested banner if any
                if (event.changesRequested != null && event.changesRequested!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFCA5A5))),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFFDC2626), size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Admin Note: ${event.changesRequested}",
                            style: const TextStyle(fontSize: 10, color: Color(0xFF991B1B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                // Capacity Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Attendee Registrations", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    Text("$registered / $capacity seats", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                ),
                const SizedBox(height: 14),

                // Card Action Buttons (Edit, Delete, View Attendees)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFF2563EB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        icon: const Icon(Icons.people_outline, size: 15),
                        label: Text("Roster (${eventAttendees.length})", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () => _showAttendeesDialog(context, controller, event, eventAttendees),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 19, color: Color(0xFF2563EB)),
                      tooltip: "Edit Event",
                      onPressed: () => _populateEventForEdit(event),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 19, color: Color(0xFFDC2626)),
                      tooltip: "Delete Event",
                      onPressed: () => _showDeleteEventConfirm(context, controller, event),
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

  // ══════════════════════════════════════════════════════════════
  // PAGE 3: CREATE / EDIT EVENT MODULE (/organizer/create)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage3CreateEvent(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    final isEditing = _editingEventId != null;
    final categories = data?.categories.isNotEmpty == true
        ? data!.categories
        : ["Official Events", "Charity Galas", "Conferences", "Workshops", "Global Summits"];

    if (!categories.contains(_eventCategory)) {
      _eventCategory = categories.first;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditing)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFBFDBFE))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_note, color: Color(0xFF2563EB)),
                      const SizedBox(width: 8),
                      Text("Editing Event: #${_editingEventId!.substring(0, 6)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E40AF))),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _resetEventForm());
                    },
                    child: const Text("Cancel Edit", style: TextStyle(color: Color(0xFFDC2626), fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          Text(isEditing ? "Edit Event" : "Create New Event", style: AppFontStyle.fontStyleW700(fontSize: 20, fontColor: const Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(
            "Configure tickets, schedule, venue, and ticketing tiers for Foundation audiences.",
            style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 18),

          // 1. Featured Image Upload
          _buildFormSection(
            title: "Featured Event Banner",
            child: GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final img = await picker.pickImage(source: ImageSource.gallery);
                if (img != null) {
                  setState(() => _eventImagePath = img.path);
                }
              },
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  image: _eventImagePath != null
                      ? DecorationImage(image: FileImage(File(_eventImagePath!)), fit: BoxFit.cover)
                      : (_eventExistingImageUrl != null && _eventExistingImageUrl!.isNotEmpty
                          ? DecorationImage(image: NetworkImage(_eventExistingImageUrl!), fit: BoxFit.cover)
                          : null),
                ),
                child: _eventImagePath == null && (_eventExistingImageUrl == null || _eventExistingImageUrl!.isEmpty)
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 36, color: Color(0xFF2563EB)),
                          SizedBox(height: 6),
                          Text("Click to upload featured event image", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E293B))),
                          SizedBox(height: 2),
                          Text("PNG, JPG, WEBP up to 30MB", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        ],
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Event Basic Details
          _buildFormSection(
            title: "Event Details",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormLabel("Event Title *"),
                TextField(controller: _eventTitleCtrl, decoration: _buildInputDec("e.g. Annual Global Gala 2026")),
                const SizedBox(height: 12),
                _buildFormLabel("Event Description *"),
                TextField(controller: _eventDescCtrl, maxLines: 4, decoration: _buildInputDec("Agenda, mission statement, keynote speakers...")),
                const SizedBox(height: 12),
                _buildFormLabel("Category *"),
                DropdownButtonFormField<String>(
                  value: _eventCategory,
                  decoration: _buildInputDec(""),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _eventCategory = v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Schedule & Timing
          _buildFormSection(
            title: "Date & Time",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel("Start Date & Time *"),
                          _buildDateTimePicker(
                            date: _eventStartDate,
                            onChanged: (newDate) => setState(() => _eventStartDate = newDate),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel("End Date & Time *"),
                          _buildDateTimePicker(
                            date: _eventEndDate,
                            onChanged: (newDate) => setState(() => _eventEndDate = newDate),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFormLabel("Timezone"),
                DropdownButtonFormField<String>(
                  value: _eventTimezone,
                  decoration: _buildInputDec(""),
                  items: _timezoneOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _eventTimezone = v);
                  },
                ),
                const SizedBox(height: 12),
                _buildFormLabel("Attendee Check-In Window"),
                DropdownButtonFormField<int>(
                  value: _eventCheckInWindow,
                  decoration: _buildInputDec(""),
                  items: const [
                    DropdownMenuItem(value: 15, child: Text("15 Minutes Before Event")),
                    DropdownMenuItem(value: 30, child: Text("30 Minutes Before Event (Default)")),
                    DropdownMenuItem(value: 60, child: Text("1 Hour Before Event")),
                    DropdownMenuItem(value: 120, child: Text("2 Hours Before Event")),
                    DropdownMenuItem(value: 1440, child: Text("24 Hours Before Event")),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _eventCheckInWindow = v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Location Details
          _buildFormSection(
            title: "Location & Delivery",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Online / Virtual Streaming Event", style: AppFontStyle.fontStyleW600(fontSize: 13, fontColor: const Color(0xFF0F172A))),
                        Text("Host via Zoom, Google Meet, or live stream", style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF64748B))),
                      ],
                    ),
                    Switch(
                      value: _eventIsOnline,
                      activeThumbColor: const Color(0xFF2563EB),
                      onChanged: (v) => setState(() => _eventIsOnline = v),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_eventIsOnline) ...[
                  _buildFormLabel("Streaming URL"),
                  TextField(controller: _eventOnlineUrlCtrl, decoration: _buildInputDec("https://zoom.us/j/9876543210")),
                ] else ...[
                  _buildFormLabel("Venue Name *"),
                  TextField(controller: _eventVenueCtrl, decoration: _buildInputDec("Grand Ballroom / Centre Hall")),
                  const SizedBox(height: 12),
                  _buildFormLabel("Street Address"),
                  TextField(controller: _eventStreetCtrl, decoration: _buildInputDec("100 King Street West, Suite 400")),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel("City *"),
                            TextField(controller: _eventCityCtrl, decoration: _buildInputDec("Toronto")),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel("Country *"),
                            TextField(controller: _eventCountryCtrl, decoration: _buildInputDec("Canada")),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 5. Multi-tier Ticket Management (3.6)
          _buildFormSection(
            title: "Ticket Tiers & Pricing",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Ticket Types", style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: const Color(0xFF334155))),
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF2563EB)),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text("+ Add Ticket Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      onPressed: () {
                        setState(() {
                          _eventTickets.add(EventTicketTier(
                            name: "VIP Admission",
                            price: 49.99,
                            quantity: 50,
                            description: "Includes VIP reception",
                          ));
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ..._eventTickets.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final ticket = entry.value;
                  return _buildTicketTierEditor(idx, ticket, controller);
                }),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel("Overall Event Capacity"),
                          TextField(
                            controller: _eventMaxAttendeesCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDec("100 (0 = unlimited)"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 6. SEO Metadata Settings
          _buildFormSection(
            title: "Search Engine Optimization (SEO)",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormLabel("SEO Meta Title"),
                TextField(controller: _eventMetaTitleCtrl, decoration: _buildInputDec("Meta title for Google and social previews")),
                const SizedBox(height: 12),
                _buildFormLabel("SEO Meta Description"),
                TextField(controller: _eventMetaDescCtrl, maxLines: 2, decoration: _buildInputDec("Meta description snippet...")),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Form Actions: Save as Draft vs Submit for Review
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF64748B)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _submitEventForm(controller, isDraft: true),
                  child: const Text("Save as Draft", style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _submitEventForm(controller, isDraft: false),
                  child: Text(
                    isEditing ? "Update Event" : "Submit for Review",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTicketTierEditor(int index, EventTicketTier tier, EcosystemController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tier #${index + 1}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              if (_eventTickets.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFDC2626)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() => _eventTickets.removeAt(index));
                  },
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: tier.name,
                  decoration: _buildInputDec("Ticket Name"),
                  style: const TextStyle(fontSize: 12),
                  onChanged: (v) => tier.name = v,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: tier.price.toStringAsFixed(2),
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDec("${controller.currencySymbol} Price"),
                  style: const TextStyle(fontSize: 12),
                  onChanged: (v) => tier.price = double.tryParse(v) ?? 0.0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: tier.quantity.toString(),
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDec("Qty"),
                  style: const TextStyle(fontSize: 12),
                  onChanged: (v) => tier.quantity = int.tryParse(v) ?? 100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker({
    required DateTime date,
    required ValueChanged<DateTime> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 730)),
        );
        if (pickedDate != null) {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(date),
          );
          if (pickedTime != null) {
            onChanged(DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            ));
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                DateFormat('dd MMM, hh:mm a').format(date),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitEventForm(EcosystemController controller, {required bool isDraft}) async {
    if (_eventTitleCtrl.text.trim().isEmpty) {
      Get.snackbar("Required", "Event title is required.", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final priceFrom = _eventTickets.isNotEmpty
        ? _eventTickets.map((t) => t.price).reduce((a, b) => a < b ? a : b)
        : 0.0;
    final totalCapacity = int.tryParse(_eventMaxAttendeesCtrl.text.trim()) ?? 100;

    final success = await controller.saveEvent(
      eventId: _editingEventId,
      title: _eventTitleCtrl.text.trim(),
      description: _eventDescCtrl.text.trim(),
      venue: _eventIsOnline ? "Online Virtual Stream" : _eventVenueCtrl.text.trim(),
      address: _eventStreetCtrl.text.trim(),
      city: _eventCityCtrl.text.trim().isNotEmpty ? _eventCityCtrl.text.trim() : (_eventIsOnline ? "Online" : "Global"),
      country: _eventCountryCtrl.text.trim().isNotEmpty ? _eventCountryCtrl.text.trim() : "Global",
      isOnline: _eventIsOnline,
      onlineUrl: _eventOnlineUrlCtrl.text.trim(),
      priceFrom: priceFrom,
      startDateTime: _eventStartDate,
      endDateTime: _eventEndDate,
      maxAttendees: totalCapacity,
      category: _eventCategory,
      timezone: _eventTimezone,
      checkInWindowMinutes: _eventCheckInWindow,
      metaTitle: _eventMetaTitleCtrl.text.trim(),
      metaDescription: _eventMetaDescCtrl.text.trim(),
      status: isDraft ? "DRAFT" : "PUBLISHED",
      tickets: _eventTickets,
      imagePath: _eventImagePath,
    );

    if (success) {
      _resetEventForm();
      _navigateToPage(2); // Return to My Events
    }
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE 4: EARNINGS & REVENUE MODULE (/organizer/earnings)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage4Earnings(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    final gross = data?.grossRevenue ?? 0.0;
    final commission = data?.commission ?? 0.0;
    final net = data?.netEarnings ?? 0.0;
    final available = data?.availableBalance ?? data?.balance ?? 0.0;
    final escrow = data?.escrowHolding ?? 0.0;
    final events = data?.events ?? controller.events;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4.1 Escrow Protection Policy Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: Color(0xFF38BDF8), size: 20),
                        const SizedBox(width: 8),
                        Text("Escrow Protection Standard", style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: Colors.white)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFF059669), borderRadius: BorderRadius.circular(6)),
                      child: const Row(
                        children: [
                          Icon(Icons.lock, size: 10, color: Colors.white),
                          SizedBox(width: 3),
                          Text("Escrow Active", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "In accordance with Foundation attendee safety rules, ticket funds remain held in escrow until the event concludes + a 5-day safety dispute window. Once cleared, funds automatically move to Available Settlement Balance.",
                  style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 4.2 5 Financial Stat Cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard("Gross Ticket Sales", controller.formatCurrency(gross), "Total receipts", Icons.receipt_long, const Color(0xFF3B82F6)),
              _buildStatCard("Foundation Fee", "-${controller.formatCurrency(commission)}", "10% Platform rate", Icons.account_balance, const Color(0xFFEF4444)),
              _buildStatCard("Total Net Earned", controller.formatCurrency(net), "Gross minus fee", Icons.savings_outlined, const Color(0xFF8B5CF6)),
              _buildStatCard("Held in Escrow", controller.formatCurrency(escrow), "Pending event clearance", Icons.lock_clock_outlined, const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 10),

          // Available for Payout Main Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Available for Immediate Settlement", style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(controller.formatCurrency(available), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E3A8A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.payments_outlined, size: 16),
                  label: const Text("Request Payout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => _navigateToPage(5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4.3 Revenue & Clearance by Event Breakdown Table/Cards
          Text("Revenue & Clearance by Event", style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Text("Event-by-event escrow status and funds clearance release schedule.", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 12),

          if (events.isEmpty)
            _buildEmptyState(icon: Icons.event_note, title: "No events recorded yet")
          else
            ...events.map((e) => _buildEventClearanceCard(context, controller, e)),
        ],
      ),
    );
  }

  Widget _buildEventClearanceCard(BuildContext context, EcosystemController controller, EcosystemEvent event) {
    final isCleared = event.clearanceStatus == "CLEARED & AVAILABLE";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Expanded(
                child: Text(
                  event.title,
                  style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCleared ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  event.clearanceStatus,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isCleared ? const Color(0xFF059669) : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildClearanceMetric("Gross", controller.formatCurrency(event.grossRevenue)),
              _buildClearanceMetric("10% Fee", "-${controller.formatCurrency(event.commission)}"),
              _buildClearanceMetric("Net", controller.formatCurrency(event.netEarnings), color: const Color(0xFF059669)),
              _buildClearanceMetric("Escrow", controller.formatCurrency(event.escrowAmount), color: const Color(0xFFD97706)),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFF1F5F9)),
          Row(
            children: [
              const Icon(Icons.schedule, size: 12, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  isCleared
                      ? "Funds fully cleared and settled into balance."
                      : "Release Timeline: Clears 5 days after event conclusion.",
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClearanceMetric(String label, String value, {Color color = const Color(0xFF0F172A)}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE 5: PAYOUTS & SETTLEMENTS MODULE (/organizer/payouts)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage5Payouts(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    final available = data?.availableBalance ?? data?.balance ?? 0.0;
    final totalPaid = data?.totalPaidOut ?? 0.0;
    final processing = data?.processingWithdrawals ?? 0.0;
    final escrow = data?.escrowHolding ?? 0.0;
    var withdrawals = data?.withdrawals ?? [];

    if (_payoutHistoryFilter != "ALL") {
      withdrawals = withdrawals.where((w) => w.status.toUpperCase() == _payoutHistoryFilter).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 5.1 4 Summary Cards
          Row(
            children: [
              Expanded(child: _buildStatCard("Available Payout", controller.formatCurrency(available), "Cleared funds", Icons.account_balance_wallet, const Color(0xFF10B981))),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard("Total Paid Out", controller.formatCurrency(totalPaid), "Settled to bank", Icons.verified, const Color(0xFF3B82F6))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStatCard("Processing", controller.formatCurrency(processing), "In review", Icons.hourglass_top, const Color(0xFFF59E0B))),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard("Held in Escrow", controller.formatCurrency(escrow), "Awaiting events", Icons.lock_outline, const Color(0xFF8B5CF6))),
            ],
          ),
          const SizedBox(height: 18),

          // Request Settlement Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.payments_outlined, size: 18),
              label: const Text("Request Settlement Payout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () => _showPayoutDialog(context, controller, available),
            ),
          ),
          const SizedBox(height: 24),

          // 5.2 Withdrawal History & Filters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Withdrawal Request History", style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A))),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _payoutHistoryFilter,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                  items: const [
                    DropdownMenuItem(value: "ALL", child: Text("All Statuses")),
                    DropdownMenuItem(value: "PENDING", child: Text("Pending")),
                    DropdownMenuItem(value: "PROCESSED", child: Text("Completed")),
                    DropdownMenuItem(value: "REJECTED", child: Text("Rejected")),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _payoutHistoryFilter = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (withdrawals.isEmpty)
            _buildEmptyState(
              icon: Icons.history_outlined,
              title: "No Payout Requests",
              subtitle: "Settlement payouts requested from Foundation will appear here.",
            )
          else
            ...withdrawals.map((w) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(controller.formatCurrency(w.amount), style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text("${w.method ?? 'Bank Wire'} • ${w.createdAt != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(w.createdAt!)) : ''}", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                      _buildStatusPill(w.status),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE 6: FUNDRAISING CAMPAIGNS MODULE (/organizer/campaigns)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage6Campaigns(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    final campaigns = data?.campaigns ?? controller.campaigns;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Fundraising Campaigns", style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: const Color(0xFF0F172A))),
                  Text("Raise donor capital for humanitarian & community initiatives", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Create", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                onPressed: () => _showCreateCampaignDialog(context, controller),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (campaigns.isEmpty)
            _buildEmptyState(
              icon: Icons.volunteer_activism_outlined,
              title: "No Fundraising Campaigns",
              subtitle: "Launch causes, emergency relief appeals, and charitable funds.",
              buttonLabel: "+ Launch First Campaign",
              onTap: () => _showCreateCampaignDialog(context, controller),
            )
          else
            ...campaigns.map((c) {
              final progress = c.goalAmount > 0 ? (c.raisedAmount / c.goalAmount).clamp(0.0, 1.0) : 0.0;
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
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
                        Expanded(
                          child: Text(c.title, style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
                        ),
                        _buildStatusPill(c.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(c.beneficiary != null ? "Beneficiary: ${c.beneficiary}" : "Community Foundation Fund", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Raised: ${controller.formatCurrency(c.raisedAmount)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                        Text("Goal: ${controller.formatCurrency(c.goalAmount)}", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE 7: NOTIFICATIONS MODULE (/organizer/notifications)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage7Notifications(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    var notifs = data?.notifications ?? [];
    if (_notifFilter == "UNREAD") {
      notifs = notifs.where((n) => !n.isRead).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Notifications & Notices", style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: const Color(0xFF0F172A))),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text("All"),
                    selected: _notifFilter == "ALL",
                    selectedColor: const Color(0xFF2563EB),
                    labelStyle: TextStyle(color: _notifFilter == "ALL" ? Colors.white : const Color(0xFF475569), fontSize: 11),
                    onSelected: (val) => setState(() => _notifFilter = "ALL"),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text("Unread"),
                    selected: _notifFilter == "UNREAD",
                    selectedColor: const Color(0xFF2563EB),
                    labelStyle: TextStyle(color: _notifFilter == "UNREAD" ? Colors.white : const Color(0xFF475569), fontSize: 11),
                    onSelected: (val) => setState(() => _notifFilter = "UNREAD"),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (notifs.isEmpty)
            _buildEmptyState(
              icon: Icons.notifications_off_outlined,
              title: "No Notifications",
              subtitle: "All system alerts, ticket purchase notices, and clearance confirmations will appear here.",
            )
          else
            ...notifs.map((n) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: n.isRead ? Colors.white : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: n.isRead ? const Color(0xFFE2E8F0) : const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                        child: const Icon(Icons.notifications_active_outlined, size: 16, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.title, style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A))),
                            const SizedBox(height: 2),
                            Text(n.message, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                            const SizedBox(height: 4),
                            Text(
                              n.createdAt.isNotEmpty ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.tryParse(n.createdAt) ?? DateTime.now()) : "Recent",
                              style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE 8: PROFILE & SETTINGS MODULE (/organizer/profile & /organizer/settings)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage8ProfileAndSettings(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF2563EB),
                  child: Text(
                    data?.organizationName.isNotEmpty == true ? data!.organizationName[0].toUpperCase() : "O",
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data?.organizationName ?? "Organization Profile",
                              style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: const Color(0xFF0F172A)),
                            ),
                          ),
                          const Icon(Icons.verified, size: 16, color: Color(0xFF2563EB)),
                        ],
                      ),
                      Text(data?.organizationType ?? "Registered Event Host", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      const SizedBox(height: 4),
                      Text("Platform Commission Rate: 10%", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4 Sub-Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                _buildSubTabButton(0, "Profile"),
                _buildSubTabButton(1, "Banking"),
                _buildSubTabButton(2, "Defaults"),
                _buildSubTabButton(3, "Security"),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // SUB-TAB 0: Profile Info
          if (_settingsSubTab == 0) ...[
            _buildFormSection(
              title: "Organization Details",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormLabel("Organization Name"),
                  TextField(controller: _orgNameCtrl, decoration: _buildInputDec("")),
                  const SizedBox(height: 12),
                  _buildFormLabel("Organization Type"),
                  TextField(controller: _orgTypeCtrl, decoration: _buildInputDec("")),
                  const SizedBox(height: 12),
                  _buildFormLabel("Official Website"),
                  TextField(controller: _orgWebsiteCtrl, decoration: _buildInputDec("https://yourorganization.org")),
                  const SizedBox(height: 12),
                  _buildFormLabel("Mission & Bio"),
                  TextField(controller: _orgDescCtrl, maxLines: 3, decoration: _buildInputDec("Organization purpose...")),
                  const SizedBox(height: 12),
                  _buildFormLabel("Contact Email"),
                  TextField(controller: _orgEmailCtrl, decoration: _buildInputDec("contact@domain.com")),
                  const SizedBox(height: 12),
                  _buildFormLabel("Contact Phone"),
                  TextField(controller: _orgPhoneCtrl, decoration: _buildInputDec("+1 (555) 000-0000")),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildFormSection(
              title: "Social Links",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormLabel("Facebook URL"),
                  TextField(controller: _fbCtrl, decoration: _buildInputDec("https://facebook.com/...")),
                  const SizedBox(height: 10),
                  _buildFormLabel("Twitter / X URL"),
                  TextField(controller: _twCtrl, decoration: _buildInputDec("https://x.com/...")),
                  const SizedBox(height: 10),
                  _buildFormLabel("Instagram URL"),
                  TextField(controller: _igCtrl, decoration: _buildInputDec("https://instagram.com/...")),
                  const SizedBox(height: 10),
                  _buildFormLabel("LinkedIn URL"),
                  TextField(controller: _liCtrl, decoration: _buildInputDec("https://linkedin.com/company/...")),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  await controller.saveOrganizerProfile({
                    "organizationName": _orgNameCtrl.text.trim(),
                    "organizationType": _orgTypeCtrl.text.trim(),
                    "website": _orgWebsiteCtrl.text.trim(),
                    "description": _orgDescCtrl.text.trim(),
                    "email": _orgEmailCtrl.text.trim(),
                    "phone": _orgPhoneCtrl.text.trim(),
                    "socialLinks": {
                      "facebook": _fbCtrl.text.trim(),
                      "twitter": _twCtrl.text.trim(),
                      "instagram": _igCtrl.text.trim(),
                      "linkedin": _liCtrl.text.trim(),
                    },
                  });
                },
                child: const Text("Save Organization Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],

          // SUB-TAB 1: Payout & Banking
          if (_settingsSubTab == 1) ...[
            _buildFormSection(
              title: "Settlement Payout Settings",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormLabel("Settlement Method"),
                  DropdownButtonFormField<String>(
                    value: _payoutMethod,
                    decoration: _buildInputDec(""),
                    items: const [
                      DropdownMenuItem(value: "Direct Bank Transfer", child: Text("Direct Bank Transfer")),
                      DropdownMenuItem(value: "ACH / Wire Transfer", child: Text("ACH / Wire Transfer")),
                      DropdownMenuItem(value: "PayPal", child: Text("PayPal")),
                      DropdownMenuItem(value: "Wise", child: Text("Wise")),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _payoutMethod = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildFormLabel("Settlement Bank Name"),
                  TextField(controller: _bankNameCtrl, decoration: _buildInputDec("Royal Bank of Canada / Chase")),
                  const SizedBox(height: 12),
                  _buildFormLabel("Account Holder Legal Name"),
                  TextField(controller: _accountHolderCtrl, decoration: _buildInputDec("Legal name on bank account")),
                  const SizedBox(height: 12),
                  _buildFormLabel("Account Number / IBAN"),
                  TextField(controller: _accountNumberCtrl, decoration: _buildInputDec("Account or IBAN number")),
                  const SizedBox(height: 12),
                  _buildFormLabel("Routing / SWIFT Code"),
                  TextField(controller: _routingNumberCtrl, decoration: _buildInputDec("Routing or SWIFT code")),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFA7F3D0))),
                    child: const Row(
                      children: [
                        Icon(Icons.lock, color: Color(0xFF059669), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Net Settlement Standard: Ticket receipts minus 10% platform fee are deposited automatically to your verified banking details.",
                            style: TextStyle(fontSize: 10, color: Color(0xFF065F46)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  await controller.saveOrganizerSettings({
                    "payout": {
                      "method": _payoutMethod,
                      "bankName": _bankNameCtrl.text.trim(),
                      "accountHolder": _accountHolderCtrl.text.trim(),
                      "accountNumber": _accountNumberCtrl.text.trim(),
                      "routingCode": _routingNumberCtrl.text.trim(),
                    },
                  });
                },
                child: const Text("Save Banking Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],

          // SUB-TAB 2: Event Defaults
          if (_settingsSubTab == 2) ...[
            _buildFormSection(
              title: "Global Event Defaults",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormLabel("Default Check-In Window"),
                  DropdownButtonFormField<int>(
                    value: _defaultCheckInWindow,
                    decoration: _buildInputDec(""),
                    items: const [
                      DropdownMenuItem(value: 15, child: Text("15 Minutes Before Event")),
                      DropdownMenuItem(value: 30, child: Text("30 Minutes Before Event (Default)")),
                      DropdownMenuItem(value: 60, child: Text("1 Hour Before Event")),
                      DropdownMenuItem(value: 120, child: Text("2 Hours Before Event")),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _defaultCheckInWindow = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildFormLabel("Default Operating Timezone"),
                  DropdownButtonFormField<String>(
                    value: _defaultTimezone,
                    decoration: _buildInputDec(""),
                    items: _timezoneOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _defaultTimezone = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildFormLabel("Platform Operating Currency"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${controller.platformCurrency.code} (${controller.currencySymbol})", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        const Text("Central Single Source of Truth", style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // SUB-TAB 3: Security & Access
          if (_settingsSubTab == 3) ...[
            _buildFormSection(
              title: "Notification Preferences",
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("Ticket Sale Alerts", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: const Text("Receive email on every attendee registration", style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    value: _notifyTicketSold,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (v) => setState(() => _notifyTicketSold = v),
                  ),
                  SwitchListTile(
                    title: const Text("Live Check-In Alerts", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: const Text("Alert when attendees scan tickets at the gate", style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    value: _notifyCheckIn,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (v) => setState(() => _notifyCheckIn = v),
                  ),
                  SwitchListTile(
                    title: const Text("Payout Confirmations", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: const Text("Notices when bank transfers clear and deposit", style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    value: _notifyPayout,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (v) => setState(() => _notifyPayout = v),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubTabButton(int idx, String title) {
    final isSelected = _settingsSubTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _settingsSubTab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // DIALOGS: PAYOUT MODAL, ATTENDEES ROSTER, DELETE CONFIRM, CAMPAIGN
  // ══════════════════════════════════════════════════════════════
  void _showPayoutDialog(BuildContext context, EcosystemController controller, double availableBalance) {
    final amountCtrl = TextEditingController(text: availableBalance >= 50 ? "50.00" : "0.00");
    final bankCtrl = TextEditingController(text: _bankNameCtrl.text);
    final holderCtrl = TextEditingController(text: _accountHolderCtrl.text);
    final accountCtrl = TextEditingController(text: _accountNumberCtrl.text);
    final routingCtrl = TextEditingController(text: _routingNumberCtrl.text);
    final notesCtrl = TextEditingController();
    String selectedMethod = _payoutMethod;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Request Payout Settlement", style: AppFontStyle.fontStyleW700(fontSize: 17, fontColor: const Color(0xFF0F172A))),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                Text(
                  "Available cleared balance: ${controller.formatCurrency(availableBalance)} (Min. ${controller.currencySymbol}50.00)",
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                _buildFormLabel("Withdrawal Amount (${controller.currencySymbol}) *"),
                TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: _buildInputDec("50.00")),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                _buildFormLabel("Bank Name"),
                TextField(controller: bankCtrl, decoration: _buildInputDec("e.g. Royal Bank of Canada / Chase")),
                const SizedBox(height: 10),
                _buildFormLabel("Account Holder Name"),
                TextField(controller: holderCtrl, decoration: _buildInputDec("Legal name on account")),
                const SizedBox(height: 10),
                _buildFormLabel("Account Number / IBAN"),
                TextField(controller: accountCtrl, decoration: _buildInputDec("Account / IBAN number")),
                const SizedBox(height: 10),
                _buildFormLabel("Routing / SWIFT Number"),
                TextField(controller: routingCtrl, decoration: _buildInputDec("Transit or SWIFT code")),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      final reqAmt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                      if (reqAmt < 50.0) {
                        Get.snackbar("Minimum Threshold", "Minimum payout request amount is ${controller.currencySymbol}50.00.", backgroundColor: Colors.redAccent, colorText: Colors.white);
                        return;
                      }
                      if (reqAmt > availableBalance) {
                        Get.snackbar("Insufficient Funds", "Amount exceeds available balance.", backgroundColor: Colors.redAccent, colorText: Colors.white);
                        return;
                      }

                      Navigator.pop(ctx);
                      await controller.submitOrganizerPayout(
                        amount: reqAmt,
                        method: selectedMethod,
                        bankDetails: {
                          "bankName": bankCtrl.text.trim(),
                          "accountHolder": holderCtrl.text.trim(),
                          "accountNumber": accountCtrl.text.trim(),
                          "routingNumber": routingCtrl.text.trim(),
                        },
                        notes: notesCtrl.text.trim(),
                      );
                    },
                    child: const Text("Submit Payout Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showAttendeesDialog(BuildContext context, EcosystemController controller, EcosystemEvent event, List<EcosystemAttendee> attendees) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Attendee Roster & Gate Check-In", style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: const Color(0xFF0F172A))),
                        Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(color: Color(0xFFE2E8F0)),
              Expanded(
                child: attendees.isEmpty
                    ? _buildEmptyState(
                        icon: Icons.people_outline,
                        title: "No Attendees Yet",
                        subtitle: "When users register or buy tickets, they appear here.",
                      )
                    : ListView.builder(
                        itemCount: attendees.length,
                        itemBuilder: (ctx, i) => _buildAttendeeTile(context, controller, attendees[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteEventConfirm(BuildContext context, EcosystemController controller, EcosystemEvent event) {
    Get.defaultDialog(
      title: "Delete Event?",
      titleStyle: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: const Color(0xFF0F172A)),
      middleText: "Are you sure you want to permanently delete '${event.title}'? This action cannot be undone.",
      middleTextStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
      textConfirm: "Delete Permanently",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFDC2626),
      cancelTextColor: const Color(0xFF64748B),
      onConfirm: () async {
        Get.back();
        await controller.removeEvent(event.id);
      },
    );
  }

  void _showCreateCampaignDialog(BuildContext context, EcosystemController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Create Fundraising Campaign", style: AppFontStyle.fontStyleW700(fontSize: 17, fontColor: const Color(0xFF0F172A))),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 10),
                _buildFormLabel("Campaign Title *"),
                TextField(controller: _campTitleCtrl, decoration: _buildInputDec("e.g. Clean Water Wells for East Africa")),
                const SizedBox(height: 10),
                _buildFormLabel("Beneficiary / Cause *"),
                TextField(controller: _campBeneficiaryCtrl, decoration: _buildInputDec("e.g. Village Water Project")),
                const SizedBox(height: 10),
                _buildFormLabel("Target Goal Amount (${controller.currencySymbol}) *"),
                TextField(controller: _campGoalCtrl, keyboardType: TextInputType.number, decoration: _buildInputDec("10000.00")),
                const SizedBox(height: 10),
                _buildFormLabel("Description & Mission"),
                TextField(controller: _campDescCtrl, maxLines: 3, decoration: _buildInputDec("Explain project milestones and impact...")),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      if (_campTitleCtrl.text.trim().isEmpty || _campGoalCtrl.text.trim().isEmpty) {
                        Get.snackbar("Required", "Title and goal amount are required.", backgroundColor: Colors.redAccent, colorText: Colors.white);
                        return;
                      }
                      Navigator.pop(ctx);
                      await controller.addCampaign(
                        title: _campTitleCtrl.text.trim(),
                        description: _campDescCtrl.text.trim(),
                        beneficiary: _campBeneficiaryCtrl.text.trim(),
                        goalAmount: double.tryParse(_campGoalCtrl.text.trim()) ?? 1000.0,
                        imagePath: _campImagePath,
                      );
                    },
                    child: const Text("Launch Campaign", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  // SHARED FORM BUILDERS & EMPTY STATES
  // ══════════════════════════════════════════════════════════════
  Widget _buildFormSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(label, style: AppFontStyle.fontStyleW600(fontSize: 11, fontColor: const Color(0xFF334155))),
    );
  }

  InputDecoration _buildInputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    String subtitle = "",
    String? buttonLabel,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFF1F5F9),
            child: Icon(icon, size: 28, color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A))),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
          if (buttonLabel != null && onTap != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onTap,
              child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}
