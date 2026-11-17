import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:notisboard/ui/host_flow/ecosystem/controllers/ecosystem_controller.dart';
import 'package:notisboard/ui/host_flow/ecosystem/models/ecosystem_items_model.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class OrganizerPortalView extends StatefulWidget {
  const OrganizerPortalView({super.key});

  @override
  State<OrganizerPortalView> createState() => _OrganizerPortalViewState();
}

class _OrganizerPortalViewState extends State<OrganizerPortalView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedPageIndex = 1; // Default to Dashboard (Page 1)
  String _globalSearchQuery = "";
  bool _isSubmittingEvent = false;
  bool _isSubmittingCampaign = false;

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

  // Campaign Form Controllers
  final _campTitleCtrl = TextEditingController();
  final _campTaglineCtrl = TextEditingController();
  final _campStoryCtrl = TextEditingController();
  final _campGoalCtrl = TextEditingController();
  String _campCategory = "Education & Scholarships";
  bool _campAllowCustomDonations = true;
  DateTime _campStartDate = DateTime.now();
  DateTime _campEndDate = DateTime.now().add(const Duration(days: 30));
  String? _campImagePath;
  final _campImageUrlCtrl = TextEditingController();

  // Profile Form Controllers
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
  String? _profileImagePath;
  bool _profileInitialized = false;

  // Settings & Payout Controllers
  String _payoutMethod = "Direct Bank Wire / Local Transfer";
  String _settlementSchedule = "Weekly Auto-Settlement (Recommended)";
  final _bankNameCtrl = TextEditingController();
  final _accountHolderCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _routingNumberCtrl = TextEditingController();
  int _defaultCheckInWindow = 30;
  String _defaultTimezone = "UTC";
  String _defaultRefundPolicy = "30-Day Policy";
  bool _notifyTicketSold = true;
  bool _notifyCheckIn = true;
  bool _notifyPayout = true;
  bool _settings2fa = false;
  bool _settingsInitialized = false;

  // KYC Verification Form
  String _kycDossierType = "organization";
  final _kycLegalNameCtrl = TextEditingController();
  final _kycDobCtrl = TextEditingController();
  final _kycPhoneCtrl = TextEditingController();
  final _kycCountryCtrl = TextEditingController();
  final _kycAddressCtrl = TextEditingController();
  String _kycDocType = "International Passport";
  String? _kycFrontPath;
  String? _kycBackPath;

  // Filter & Search states
  String _eventFilter = "ALL"; // ALL, PUBLISHED, PENDING_REVIEW, DRAFT, CHANGES_REQUESTED, COMPLETED
  String _eventSearchQuery = "";
  String _eventSort = "NEWEST"; // NEWEST, OLDEST, TITLE, PRICE
  int _eventCurrentPage = 1;
  final int _eventsPerPage = 5;

  String _payoutHistoryFilter = "ALL";
  String _payoutSearchQuery = "";
  int _earningsCategoryTab = 0; // 0: Event Ticketing, 1: Fundraising, 2: Charity Ledger
  int _payoutTypeTab = 0; // 0: Event Tickets, 1: Fundraising, 2: Charity Ledger

  String _notifFilter = "ALL";
  String _notifSearchQuery = "";
  String _financialPeriod = "30D"; // 30D, 90D, 1Y, ALL
  int _dashboardActivityTab = 0; // 0: Recent Activity, 1: Notifications
  int _settingsTab = 0; // 0: Payout & Banking, 1: Event Defaults, 2: Notifications, 3: Security & Access

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

    _campTitleCtrl.dispose();
    _campTaglineCtrl.dispose();
    _campStoryCtrl.dispose();
    _campGoalCtrl.dispose();
    _campImageUrlCtrl.dispose();

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

    _kycLegalNameCtrl.dispose();
    _kycDobCtrl.dispose();
    _kycPhoneCtrl.dispose();
    _kycCountryCtrl.dispose();
    _kycAddressCtrl.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
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
    _eventCategory = "Official Events";
    _eventTimezone = "UTC";
    _eventCheckInWindow = 30;
    _eventIsOnline = false;
    _eventStartDate = DateTime.now().add(const Duration(days: 7, hours: 2));
    _eventEndDate = DateTime.now().add(const Duration(days: 7, hours: 6));
    _eventImagePath = null;
    _eventExistingImageUrl = null;
    _resetEventTickets();
  }

  void _initEventFormForEdit(EcosystemEvent event) {
    _editingEventId = event.id;
    _eventTitleCtrl.text = event.title;
    _eventDescCtrl.text = event.description ?? "";
    _eventVenueCtrl.text = event.venue ?? "";
    _eventCityCtrl.text = event.city ?? "";
    _eventCountryCtrl.text = event.country ?? "";
    _eventOnlineUrlCtrl.text = event.onlineUrl ?? "";
    _eventMaxAttendeesCtrl.text = event.maxAttendees > 0 ? event.maxAttendees.toString() : "";
    _eventMetaTitleCtrl.text = event.metaTitle ?? "";
    _eventMetaDescCtrl.text = event.metaDescription ?? "";
    _eventCategory = (event.category != null && event.category!.isNotEmpty) ? event.category! : "Official Events";
    _eventTimezone = (event.timezone != null && event.timezone!.isNotEmpty) ? event.timezone! : "UTC";
    _eventCheckInWindow = event.checkInWindowMinutes > 0 ? event.checkInWindowMinutes : 30;
    _eventIsOnline = event.isOnline;
    _eventStartDate = DateTime.tryParse(event.startDateTime) ?? DateTime.now();
    _eventEndDate = DateTime.tryParse(event.endDateTime) ?? DateTime.now().add(const Duration(hours: 3));
    _eventExistingImageUrl = event.featuredImage;
    _eventImagePath = null;

    if (event.tickets.isNotEmpty) {
      _eventTickets = event.tickets.map((t) => EventTicketTier(
        name: t.name,
        price: t.price,
        quantity: t.quantity,
        description: t.description,
      )).toList();
    } else {
      _eventTickets = [
        EventTicketTier(name: "Standard Ticket", price: event.priceFrom, quantity: event.maxAttendees, description: "General Admission")
      ];
    }
  }

  void _initProfileFromData(OrganizerPortalData data) {
    if (_profileInitialized) return;
    _profileInitialized = true;
    final profile = data.profileData;
    _orgNameCtrl.text = profile?.organizationName ?? data.organizationName;
    _orgTypeCtrl.text = profile?.organizationType ?? data.organizationType;
    _orgDescCtrl.text = profile?.description ?? "";
    _orgWebsiteCtrl.text = profile?.website ?? "";
    _orgEmailCtrl.text = profile?.email ?? "";
    _orgPhoneCtrl.text = profile?.phone ?? "";
    if (profile?.socialLinks != null) {
      _fbCtrl.text = profile!.socialLinks['facebook']?.toString() ?? "";
      _twCtrl.text = profile.socialLinks['twitter']?.toString() ?? "";
      _igCtrl.text = profile.socialLinks['instagram']?.toString() ?? "";
      _liCtrl.text = profile.socialLinks['linkedin']?.toString() ?? "";
    }
  }

  void _initSettingsFromData(OrganizerPortalData data) {
    if (_settingsInitialized) return;
    _settingsInitialized = true;
    final settings = data.settings;
    if (settings != null) {
      _payoutMethod = settings.payoutMethod.isNotEmpty ? settings.payoutMethod : "Direct Bank Wire / Local Transfer";
      _settlementSchedule = settings.settlementSchedule.isNotEmpty ? settings.settlementSchedule : "Weekly Auto-Settlement (Recommended)";
      _bankNameCtrl.text = settings.bankName;
      _accountHolderCtrl.text = settings.accountHolder;
      _accountNumberCtrl.text = settings.accountNumber;
      _routingNumberCtrl.text = settings.routingNumber;
      _defaultCheckInWindow = settings.defaultCheckInWindow;
      _defaultRefundPolicy = settings.defaultRefundPolicy;
      _notifyTicketSold = settings.notifyRegistrationAlert;
      _notifyCheckIn = settings.notifyEventReminder;
      _notifyPayout = settings.notifyDonationAlert;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // MAIN SCAFFOLD BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return GetBuilder<EcosystemController>(
      builder: (controller) {
        final data = controller.organizerPortalData;
        if (data != null) {
          _initProfileFromData(data);
          _initSettingsFromData(data);
        }

        final unreadNotifs = data?.notifications.where((n) => !n.isRead).length ?? 0;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: _buildTopHeaderBar(context, controller, data, unreadNotifs),
          drawer: _buildWebMatchingSidebarDrawer(context, controller, data, unreadNotifs),
          bottomNavigationBar: _buildBottomQuickBar(),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
              : IndexedStack(
                  index: _selectedPageIndex,
                  children: [
                    _buildPage0KycVerification(context, controller, data),
                    _buildPage1Dashboard(context, controller, data),
                    _buildPage2MyEvents(context, controller, data),
                    _buildPage3CreateEvent(context, controller, data),
                    _buildPage4FundraisingConsole(context, controller, data),
                    _buildPage5EarningsAndRevenue(context, controller, data),
                    _buildPage6PayoutsAndSettlements(context, controller, data),
                    _buildPage7Notifications(context, controller, data),
                    _buildPage8OrganizerProfile(context, controller, data),
                    _buildPage9OrganizerSettings(context, controller, data),
                  ],
                ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SECTION 1-D: TOP HEADER BAR (SEARCH, SHORTCUT, VIEW SITE, PROFILE DROPDOWN)
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
      title: GestureDetector(
        onTap: () => _showGlobalSearchModal(context, controller, data),
        child: Container(
          height: 38,
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  "Search events, tickets, users...",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Text("⌘K", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // View Site Button
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
          ),
          onPressed: () {
            Get.snackbar("Public Foundation Portal", "Opening public events portal in browser: notisboardglobalfoundation.org/events",
                backgroundColor: const Color(0xFF0F172A), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.open_in_new, size: 13, color: Color(0xFF2563EB)),
              SizedBox(width: 4),
              Text("View Site", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            ],
          ),
        ),

        // Notifications Bell
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Color(0xFF475569), size: 21),
              onPressed: () => _navigateToPage(7),
            ),
            if (unreadNotifs > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                  child: Text(
                    unreadNotifs > 9 ? "9+" : "$unreadNotifs",
                    style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),

        // Organizer Profile Dropdown Menu
        PopupMenuButton<String>(
          offset: const Offset(0, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: const Color(0xFF2563EB),
              child: Text(
                (data?.organizationName.isNotEmpty ?? false) ? data!.organizationName[0].toUpperCase() : "O",
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          itemBuilder: (ctx) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data?.organizationName ?? "Official Organizer",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.shield, size: 11, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text("Organizer • ${data?.referenceId ?? 'ORG-FOUNDATION-9281'}",
                          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            ),
            PopupMenuItem(
              value: "profile",
              child: const Row(children: [Icon(Icons.person_outline, size: 18), SizedBox(width: 8), Text("Organizer Profile")]),
            ),
            PopupMenuItem(
              value: "settings",
              child: const Row(children: [Icon(Icons.settings_outlined, size: 18), SizedBox(width: 8), Text("Settings & Payouts")]),
            ),
            PopupMenuItem(
              value: "switch_portal",
              child: const Row(children: [Icon(Icons.swap_horiz, size: 18, color: Color(0xFF2563EB)), SizedBox(width: 8), Text("Switch to User Portal")]),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: "logout",
              child: const Row(children: [Icon(Icons.logout, size: 18, color: Color(0xFFDC2626)), SizedBox(width: 8), Text("Sign Out", style: TextStyle(color: Color(0xFFDC2626)))]),
            ),
          ],
          onSelected: (val) {
            if (val == "profile") _navigateToPage(8);
            if (val == "settings") _navigateToPage(9);
            if (val == "switch_portal") Get.back();
            if (val == "logout") Get.back();
          },
        ),
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
        return "Fundraising Console";
      case 5:
        return "Earnings & Revenue";
      case 6:
        return "Payouts & Settlements";
      case 7:
        return "Notifications & Announcements";
      case 8:
        return "Organizer Profile";
      case 9:
        return "Organizer Settings";
      default:
        return "Organizer Portal";
    }
  }

  // ══════════════════════════════════════════════════════════════
  // SECTION 1-A, 1-B, 1-C: SIDEBAR NAVIGATION DRAWER
  // ══════════════════════════════════════════════════════════════
  Widget _buildWebMatchingSidebarDrawer(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
    int unreadNotifs,
  ) {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: SafeArea(
        child: Column(
          children: [
            // Top Branding
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
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
                        Text("ORGANIZER PORTAL", style: AppFontStyle.fontStyleW600(fontSize: 9.5, fontColor: const Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 10 Left Sidebar Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                children: [
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
                    title: "Create Event",
                    highlight: true,
                    onTapOverride: () {
                      _resetEventForm();
                      _navigateToPage(3);
                    },
                  ),
                  _buildDrawerNavItem(
                    index: 4,
                    icon: Icons.volunteer_activism_outlined,
                    title: "Fundraising",
                    badgeText: "${data?.campaigns.length ?? 0}",
                    badgeColor: const Color(0xFF334155),
                  ),
                  _buildDrawerNavItem(
                    index: 5,
                    icon: Icons.account_balance_wallet_outlined,
                    title: "Earnings",
                  ),
                  _buildDrawerNavItem(
                    index: 6,
                    icon: Icons.payments_outlined,
                    title: "Payouts",
                  ),
                  _buildDrawerNavItem(
                    index: 0,
                    icon: Icons.verified_user_outlined,
                    title: "KYC Verification",
                    badgeText: (data?.isApproved ?? true) ? "VERIFIED" : "ACTION REQUIRED",
                    badgeColor: (data?.isApproved ?? true) ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
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
                    icon: Icons.person_outline,
                    title: "Profile",
                  ),
                  _buildDrawerNavItem(
                    index: 9,
                    icon: Icons.settings_outlined,
                    title: "Settings",
                  ),

                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF1E293B)),

                  // Section 1-B: MY PORTALS SECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("MY PORTALS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: const Color(0xFF64748B))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
                          child: const Text("2", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    leading: const Icon(Icons.person_pin_outlined, color: Color(0xFF94A3B8), size: 18),
                    title: const Text("User Portal", style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, size: 16, color: Color(0xFF64748B)),
                    onTap: () {
                      Get.back();
                      Get.back(); // Switch back to host/user view
                    },
                  ),
                  ListTile(
                    dense: true,
                    selected: true,
                    selectedTileColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    leading: const Icon(Icons.confirmation_number_outlined, color: Color(0xFF38BDF8), size: 18),
                    title: const Text("Organizer Portal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    trailing: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(color: Color(0xFF38BDF8), shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ),

            // Section 1-C: SIDEBAR BOTTOM
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 17,
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
                              "Organizer",
                              style: AppFontStyle.fontStyleW400(fontSize: 10, fontColor: const Color(0xFF10B981)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF475569)),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: () {
                            Get.snackbar("Public Foundation Portal", "Opening public events portal in browser: notisboardglobalfoundation.org/events",
                                backgroundColor: const Color(0xFF0F172A), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                          },
                          child: const Text("Visit Site", style: TextStyle(fontSize: 10, color: Color(0xFFCBD5E1))),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626).withValues(alpha: 0.2),
                            foregroundColor: const Color(0xFFF87171),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: () => Get.back(),
                          child: const Text("Logout", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF2563EB)
            : (highlight ? const Color(0xFF1E293B) : Colors.transparent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: isSelected ? Colors.white : (highlight ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8)), size: 18),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : (highlight ? const Color(0xFF38BDF8) : const Color(0xFFE2E8F0)),
            fontWeight: isSelected || highlight ? FontWeight.bold : FontWeight.w500,
            fontSize: 12.5,
          ),
        ),
        trailing: badgeText != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: badgeColor ?? const Color(0xFF334155), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  badgeText,
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              )
            : null,
        onTap: onTapOverride ?? () => _navigateToPage(index),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // BOTTOM BAR: QUICK ACCESS
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
              : (_selectedPageIndex == 4 ? 2 : (_selectedPageIndex == 5 ? 3 : (_selectedPageIndex == 8 ? 4 : 0)))),
      onTap: (index) {
        if (index == 0) _navigateToPage(1); // Dashboard
        if (index == 1) _navigateToPage(2); // Events
        if (index == 2) _navigateToPage(4); // Fundraising
        if (index == 3) _navigateToPage(5); // Earnings
        if (index == 4) _navigateToPage(8); // Profile
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.event_outlined), label: "Events"),
        BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism_outlined), label: "Fundraising"),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: "Earnings"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SECTION 2: ORGANIZER DASHBOARD
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
    final draftEvents = data?.draftEvents ?? events.where((e) => e.status == "DRAFT").length;
    final pendingEvents = data?.pendingEvents ?? events.where((e) => e.status == "PENDING_REVIEW").length;
    final completedEvents = data?.completedEvents ?? events.where((e) => e.status == "COMPLETED").length;
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
          // 2.A Dashboard Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
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
                                "Organizer Dashboard",
                                style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.verified, size: 16, color: Color(0xFF38BDF8)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data?.organizationName ?? "Host conferences, summits, and charity ticketing on Foundation.",
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
                      label: const Text("Create Event", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
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

          // 2.B Overview Statistics (4 Primary Cards)
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
          const SizedBox(height: 10),

          // 2.B Secondary Overview Information (Drafts, Pending, Completed, Capacity, Commission)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubStatText("Drafts", "$draftEvents", const Color(0xFF64748B)),
                const Text("•", style: TextStyle(color: Color(0xFFCBD5E1))),
                _buildSubStatText("Pending", "$pendingEvents", const Color(0xFFD97706)),
                const Text("•", style: TextStyle(color: Color(0xFFCBD5E1))),
                _buildSubStatText("Completed", "$completedEvents", const Color(0xFF059669)),
                const Text("•", style: TextStyle(color: Color(0xFFCBD5E1))),
                _buildSubStatText("Platform Fee", "10.0%", const Color(0xFF2563EB)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2.E Financial Summary with Date Filter
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
                      child: _buildFinancialMetric("Commission", "-${controller.formatCurrency(commission)}", const Color(0xFFDC2626)),
                    ),
                    Expanded(
                      child: _buildFinancialMetric("Net Earnings", controller.formatCurrency(netEarnings), const Color(0xFF059669)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.trending_up, size: 14, color: Color(0xFF10B981)),
                    const SizedBox(width: 4),
                    const Text("+14.2% vs previous period", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                    const Spacer(),
                    Text("Currency: ${controller.currencyCode}", style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
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
                    icon: const Icon(Icons.account_balance_wallet_outlined, size: 16),
                    label: const Text("View Detailed Earnings & Escrow Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    onPressed: () => _navigateToPage(5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // 2.C Upcoming & Recent Events
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

          // 2.D Recent Registrations
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recent Registrations", style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A))),
              TextButton(
                onPressed: () {
                  if (events.isNotEmpty) {
                    _showAttendeeRosterModal(context, controller, events.first, attendees);
                  }
                },
                child: const Text("View All →", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (attendees.isEmpty)
            _buildEmptyState(
              icon: Icons.people_outline,
              title: "No Attendee Registrations Yet",
              subtitle: "When attendees register for your events, they will appear here in real-time.",
            )
          else
            ...attendees.take(3).map((a) => _buildAttendeeRegistrationTile(context, controller, a)),

          const SizedBox(height: 22),

          // 2.F Recent Activity / Event Stream Tabs
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
                    _buildSmallTabPill("Recent Activity", _dashboardActivityTab == 0, () => setState(() => _dashboardActivityTab = 0)),
                    const SizedBox(width: 8),
                    _buildSmallTabPill("Notifications", _dashboardActivityTab == 1, () => setState(() => _dashboardActivityTab = 1)),
                  ],
                ),
                const SizedBox(height: 12),
                if (_dashboardActivityTab == 0) ...[
                  _buildActivityStreamItem(
                    icon: Icons.payments,
                    color: const Color(0xFF10B981),
                    title: "Settlement Escrow Initialized",
                    subtitle: "Auto-clearing configured for 0–5 days post-event delivery",
                    time: "Automated",
                  ),
                  _buildActivityStreamItem(
                    icon: Icons.confirmation_number,
                    color: const Color(0xFF2563EB),
                    title: "Ticketing Engine Online",
                    subtitle: "Multi-tier tickets active governed by ${controller.currencyCode}",
                    time: "Platform Live",
                  ),
                  _buildActivityStreamItem(
                    icon: Icons.security,
                    color: const Color(0xFF8B5CF6),
                    title: "KYC Dossier Synchronized",
                    subtitle: "Full hosting and revenue privileges unlocked",
                    time: "Verified",
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () => _navigateToPage(2),
                      child: const Text("View all hosted events and rosters →", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                    ),
                  ),
                ] else ...[
                  if (data?.notifications.isEmpty ?? true)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: Text("No alerts at this time.", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)))),
                    )
                  else
                    ...data!.notifications.take(3).map((n) => _buildNotificationSummaryTile(n)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSubStatText(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color)),
        Text(label, style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppFontStyle.fontStyleW600(fontSize: 11, fontColor: const Color(0xFF64748B))),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: const Color(0xFF0F172A))),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppFontStyle.fontStyleW400(fontSize: 9.5, fontColor: const Color(0xFF94A3B8))),
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
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  Widget _buildDashboardEventCard(BuildContext context, EcosystemController controller, EcosystemEvent event) {
    final dt = DateTime.tryParse(event.startDateTime);
    final fmtDate = dt != null ? DateFormat("EEE, MMM d, yyyy • h:mm a").format(dt) : event.startDateTime;
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 58,
              height: 58,
              color: const Color(0xFFF1F5F9),
              child: event.featuredImage != null && event.featuredImage!.isNotEmpty
                  ? Image.network(event.featuredImage!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.event, color: Color(0xFF94A3B8)))
                  : const Icon(Icons.event, color: Color(0xFF94A3B8)),
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
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A)),
                      ),
                    ),
                    _buildStatusPill(event.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(fmtDate, style: const TextStyle(fontSize: 10, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  event.isOnline ? "Virtual Event" : (event.venue ?? "Venue TBD"),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeeRegistrationTile(BuildContext context, EcosystemController controller, EcosystemAttendee a) {
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
            radius: 17,
            backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
            child: Text(
              a.firstName.isNotEmpty ? a.firstName[0].toUpperCase() : "A",
              style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${a.firstName} ${a.lastName}", style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Text(controller.formatCurrency(a.totalAmount), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                  ],
                ),
                Text("${a.eventTitle} • Ticket #${a.ticketNumber.substring(0, a.ticketNumber.length > 8 ? 8 : a.ticketNumber.length)}",
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              a.checkedIn ? Icons.check_circle : Icons.radio_button_unchecked,
              color: a.checkedIn ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
              size: 20,
            ),
            tooltip: a.checkedIn ? "Checked in" : "Mark as checked in",
            onPressed: () {
              controller.checkInAttendee(a.id, !a.checkedIn);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTabPill(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityStreamItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 14),
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

  Widget _buildNotificationSummaryTile(EcosystemNotificationItem n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: n.isRead ? Colors.transparent : const Color(0xFFEF4444), shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                Text(n.message, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Text(n.createdAt, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
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
      child: Text(s.replaceAll("_", " "), style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SECTION 3: MY EVENTS MODULE (/organizer/events)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage2MyEvents(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    var events = data?.events ?? controller.events;

    // Search Filter (by title, venue, or city)
    if (_eventSearchQuery.isNotEmpty) {
      final q = _eventSearchQuery.toLowerCase();
      events = events.where((e) =>
          e.title.toLowerCase().contains(q) ||
          (e.venue?.toLowerCase().contains(q) ?? false) ||
          (e.city?.toLowerCase().contains(q) ?? false)).toList();
    }

    // Status Tab Filter (6 Filters)
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

    // Sort Dropdown
    if (_eventSort == "NEWEST") {
      events.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
    } else if (_eventSort == "OLDEST") {
      events.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    } else if (_eventSort == "TITLE") {
      events.sort((a, b) => a.title.compareTo(b.title));
    } else if (_eventSort == "PRICE") {
      events.sort((a, b) => b.priceFrom.compareTo(a.priceFrom));
    }

    final rawAllEvents = data?.events ?? controller.events;
    final totalCount = rawAllEvents.length;
    final pubCount = rawAllEvents.where((e) => e.status == "PUBLISHED").length;
    final pendingCount = rawAllEvents.where((e) => e.status == "PENDING_REVIEW").length;
    final draftCount = rawAllEvents.where((e) => e.status == "DRAFT").length;
    final changesCount = rawAllEvents.where((e) => e.status == "CHANGES_REQUESTED" || e.status == "REJECTED").length;
    final completedCount = rawAllEvents.where((e) => e.status == "COMPLETED").length;

    // Pagination
    final totalFiltered = events.length;
    final totalPages = (totalFiltered / _eventsPerPage).ceil();
    final safePage = _eventCurrentPage > totalPages ? 1 : _eventCurrentPage;
    final startIdx = (safePage - 1) * _eventsPerPage;
    final endIdx = (startIdx + _eventsPerPage) > totalFiltered ? totalFiltered : (startIdx + _eventsPerPage);
    final pagedEvents = (startIdx < totalFiltered) ? events.sublist(startIdx, endIdx) : <EcosystemEvent>[];

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

              // Search Bar & Create Button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        onChanged: (v) => setState(() {
                          _eventSearchQuery = v;
                          _eventCurrentPage = 1;
                        }),
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          hintText: "Search events by title, venue, city...",
                          prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _eventSort,
                      icon: const Icon(Icons.sort, size: 18, color: Color(0xFF2563EB)),
                      items: const [
                        DropdownMenuItem(value: "NEWEST", child: Text("Newest First", style: TextStyle(fontSize: 11))),
                        DropdownMenuItem(value: "OLDEST", child: Text("Oldest First", style: TextStyle(fontSize: 11))),
                        DropdownMenuItem(value: "TITLE", child: Text("Title A-Z", style: TextStyle(fontSize: 11))),
                        DropdownMenuItem(value: "PRICE", child: Text("Price: High-Low", style: TextStyle(fontSize: 11))),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _eventSort = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("New", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      _resetEventForm();
                      _navigateToPage(3);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 6 Status Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildEventFilterChip("ALL", "All ($totalCount)"),
                    _buildEventFilterChip("PUBLISHED", "Published ($pubCount)"),
                    _buildEventFilterChip("PENDING_REVIEW", "Pending Review ($pendingCount)"),
                    _buildEventFilterChip("DRAFT", "Drafts ($draftCount)"),
                    _buildEventFilterChip("CHANGES_REQUESTED", "Changes ($changesCount)"),
                    _buildEventFilterChip("COMPLETED", "Completed ($completedCount)"),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Events List
        Expanded(
          child: events.isEmpty
              ? _buildEmptyState(
                  icon: Icons.event_busy,
                  title: "No Events Found",
                  subtitle: "No events match your current filter or search criteria.",
                  buttonLabel: "+ Create Your First Event",
                  onTap: () {
                    _resetEventForm();
                    _navigateToPage(3);
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  itemCount: pagedEvents.length,
                  itemBuilder: (ctx, i) => _buildFullEventCard(context, controller, pagedEvents[i], data?.attendees ?? []),
                ),
        ),

        // 3.F Pagination Bar
        if (totalFiltered > 0)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Showing ${startIdx + 1}–$endIdx of $totalFiltered events", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      iconSize: 20,
                      onPressed: safePage > 1 ? () => setState(() => _eventCurrentPage--) : null,
                    ),
                    Text("$safePage / ${totalPages == 0 ? 1 : totalPages}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      iconSize: 20,
                      onPressed: safePage < totalPages ? () => setState(() => _eventCurrentPage++) : null,
                    ),
                  ],
                ),
              ],
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
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildEventFilterChip(String value, String label) {
    final isSelected = _eventFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF2563EB),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF475569),
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
        onSelected: (val) {
          if (val) setState(() {
            _eventFilter = value;
            _eventCurrentPage = 1;
          });
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
    final dt = DateTime.tryParse(event.startDateTime);
    final fmtDate = dt != null ? DateFormat("EEE, MMM d, yyyy • h:mm a").format(dt) : event.startDateTime;
    final tierCount = event.tickets.isNotEmpty ? event.tickets.length : 1;
    final isPending = event.status == "PENDING_REVIEW";
    final isChanges = event.status == "CHANGES_REQUESTED" || event.status == "REJECTED";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 68,
                  height: 68,
                  color: const Color(0xFFF1F5F9),
                  child: event.featuredImage != null && event.featuredImage!.isNotEmpty
                      ? Image.network(event.featuredImage!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.event, color: Color(0xFF94A3B8)))
                  : const Icon(Icons.event, color: Color(0xFF94A3B8)),
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
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A)),
                          ),
                        ),
                        _buildStatusPill(event.status),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(fmtDate, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                    const SizedBox(height: 2),
                    Text(
                      event.isOnline ? "Virtual Event • Global Stream" : "${event.venue ?? 'Venue TBD'}, ${event.city ?? ''}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tiers & Attendee Summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$tierCount Ticket Tier(s)", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Text(
                  event.priceFrom == 0.0 ? "FREE" : "From ${controller.formatCurrency(event.priceFrom)}",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                ),
                Text(
                  event.maxAttendees > 0 ? "Cap: ${event.maxAttendees}" : "Unlimited Cap",
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          if (isChanges) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFDC2626)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Changes requested by Foundation administrator. Edit and re-submit for approval.",
                      style: TextStyle(fontSize: 10, color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (isPending) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Color(0xFFD97706)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Pending administrator compliance review before appearing live on Foundation.",
                      style: TextStyle(fontSize: 10, color: Color(0xFFD97706)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Divider(height: 16),

          // Action Buttons: Attendees & Check-In, Scan QR Passes, Copy Event Link, Actions Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.people_outline, size: 15),
                label: const Text("Attendees & Check-In", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF2563EB)),
                onPressed: () {
                  final eventAttendees = allAttendees.where((a) => a.eventId == event.id || a.eventTitle == event.title).toList();
                  _showAttendeeRosterModal(context, controller, event, eventAttendees);
                },
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 18, color: Color(0xFF10B981)),
                tooltip: "Scan QR Passes",
                onPressed: () => _showQrFastScannerModal(context, controller, event),
              ),
              IconButton(
                icon: const Icon(Icons.link_rounded, size: 18, color: Color(0xFF64748B)),
                tooltip: "Copy Event Link",
                onPressed: () {
                  final link = "https://notisboardglobalfoundation.org/events/${event.id}";
                  Clipboard.setData(ClipboardData(text: link));
                  Utils.showToast(context, "Event link copied to clipboard!");
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF64748B)),
                onSelected: (v) {
                  if (v == "preview") {
                    _showEventPreviewModal(context, controller, event);
                  } else if (v == "edit") {
                    _initEventFormForEdit(event);
                    _navigateToPage(3);
                  } else if (v == "delete") {
                    _confirmDeleteEvent(context, controller, event);
                  } else if (v == "qr") {
                    _showQrFastScannerModal(context, controller, event);
                  } else if (v == "link") {
                    final link = "https://notisboardglobalfoundation.org/events/${event.id}";
                    Clipboard.setData(ClipboardData(text: link));
                    Utils.showToast(context, "Event link copied to clipboard!");
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: "preview", child: Text("Preview Event", style: TextStyle(fontSize: 12))),
                  const PopupMenuItem(value: "qr", child: Text("Scan QR Passes", style: TextStyle(fontSize: 12))),
                  const PopupMenuItem(value: "link", child: Text("Copy Event Link", style: TextStyle(fontSize: 12))),
                  const PopupMenuItem(value: "edit", child: Text("Edit Event", style: TextStyle(fontSize: 12))),
                  const PopupMenuItem(value: "delete", child: Text("Delete Event", style: TextStyle(fontSize: 12, color: Color(0xFFDC2626)))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SECTION 4: CREATE / EDIT EVENT SYSTEM (/organizer/create)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage3CreateEvent(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    final isEditing = _editingEventId != null;
    final categories = (data?.categories.isNotEmpty ?? false)
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
          // 4.A Page Actions Top Banner (Preview, Save as Draft, Submit)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? "Editing Event #${_editingEventId!.substring(0, 6)}" : "Create Marketplace Event",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                      ),
                      Text("Multi-tier ticketing with 10% auto-commission", style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF475569)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => _showCurrentEventFormPreview(context, controller),
                  child: const Text("Preview", style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4.C Event Image
          _buildFormSection(
            title: "Featured Event Image",
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
                          Text("PNG, JPG, WebP support • Max 30MB • 1200x630 recommended", style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
                        ],
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4.B Event Details
          _buildFormSection(
            title: "Event Details",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormLabel("Event Title *"),
                TextField(controller: _eventTitleCtrl, decoration: _buildInputDec("e.g. Annual Global Gala 2026")),
                const SizedBox(height: 12),
                _buildFormLabel("Event Category *"),
                DropdownButtonFormField<String>(
                  value: _eventCategory,
                  decoration: _buildInputDec(""),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _eventCategory = v);
                  },
                ),
                const SizedBox(height: 12),
                _buildFormLabel("Event Description *"),
                TextField(
                  controller: _eventDescCtrl,
                  maxLines: 4,
                  decoration: _buildInputDec("Describe itinerary, guest speakers, keynotes, and cause impact..."),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4.E Date, Time & Check-In Window
          _buildFormSection(
            title: "Schedule & Check-In Window",
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
                            onPick: (dt) => setState(() => _eventStartDate = dt),
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
                            onPick: (dt) => setState(() => _eventEndDate = dt),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFormLabel("Event Timezone"),
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
                  initialValue: _eventCheckInWindow,
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

          // 4.G Location & Venue
          _buildFormSection(
            title: "Location / Venue Configuration",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Virtual / Online Event", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text("Attendees join remotely via streaming URL", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  value: _eventIsOnline,
                  activeThumbColor: const Color(0xFF2563EB),
                  onChanged: (v) => setState(() => _eventIsOnline = v),
                ),
                if (_eventIsOnline) ...[
                  const SizedBox(height: 8),
                  _buildFormLabel("Virtual Meeting / Streaming URL"),
                  TextField(controller: _eventOnlineUrlCtrl, decoration: _buildInputDec("https://meet.google.com/... or zoom.us/...")),
                ] else ...[
                  const SizedBox(height: 8),
                  _buildFormLabel("Venue Name"),
                  TextField(controller: _eventVenueCtrl, decoration: _buildInputDec("e.g. Foundation Grand Hall")),
                  const SizedBox(height: 10),
                  _buildFormLabel("Street Address"),
                  TextField(controller: _eventStreetCtrl, decoration: _buildInputDec("e.g. 100 University Avenue")),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel("City"),
                            TextField(controller: _eventCityCtrl, decoration: _buildInputDec("e.g. Toronto")),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel("Country"),
                            TextField(controller: _eventCountryCtrl, decoration: _buildInputDec("e.g. Canada")),
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

          // 4.D Multi-Tier Ticket Management
          _buildFormSection(
            title: "Ticketing & Registration Tiers",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Configure multiple tiers & pricing", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
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
                _buildFormLabel("Overall Event Capacity (Max Attendees)"),
                TextField(
                  controller: _eventMaxAttendeesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDec("Leave empty for unlimited capacity"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4.H SEO Settings
          _buildFormSection(
            title: "Search Engine Optimization (SEO)",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormLabel("SEO Meta Title"),
                TextField(controller: _eventMetaTitleCtrl, decoration: _buildInputDec("Meta title for Google and social previews")),
                const SizedBox(height: 10),
                _buildFormLabel("SEO Meta Description"),
                TextField(controller: _eventMetaDescCtrl, maxLines: 2, decoration: _buildInputDec("Meta description snippet...")),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Approval Workflow Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFD97706)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Event Review Workflow: Submitting for review places this event in Under Review status until approved by Foundation administrators.",
                    style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 4.A Form Action Buttons: Preview, Save as Draft, Submit for Review
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF64748B)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: (_isSubmittingEvent || controller.isActionLoading)
                      ? null
                      : () => _submitEventForm(controller, isDraft: true),
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
                  onPressed: (_isSubmittingEvent || controller.isActionLoading)
                      ? null
                      : () => _submitEventForm(controller, isDraft: false),
                  child: _isSubmittingEvent
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: tier.name,
                  decoration: const InputDecoration(labelText: "Tier Name", isDense: true, border: OutlineInputBorder()),
                  onChanged: (v) => tier.name = v,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: tier.price.toStringAsFixed(2),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Price (${controller.currencyCode})",
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) => tier.price = double.tryParse(v) ?? 0.0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: tier.quantity.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Quantity", isDense: true, border: OutlineInputBorder()),
                  onChanged: (v) => tier.quantity = int.tryParse(v) ?? 0,
                ),
              ),
              if (_eventTickets.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFDC2626), size: 20),
                  onPressed: () {
                    setState(() => _eventTickets.removeAt(index));
                  },
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: tier.description ?? "",
            decoration: const InputDecoration(
              labelText: "Description / Tier Inclusions (Optional)",
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => tier.description = v,
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker({required DateTime date, required Function(DateTime) onPick}) {
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
        );
        if (d != null && mounted) {
          final t = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(date),
          );
          if (t != null) {
            onPick(DateTime(d.year, d.month, d.day, t.hour, t.minute));
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat("MMM d, yyyy h:mm a").format(date), style: const TextStyle(fontSize: 11)),
            const Icon(Icons.calendar_today, size: 14, color: Color(0xFF2563EB)),
          ],
        ),
      ),
    );
  }

  Future<void> _submitEventForm(EcosystemController controller, {required bool isDraft}) async {
    if (_isSubmittingEvent || controller.isActionLoading) return;
    final title = _eventTitleCtrl.text.trim();
    if (title.isEmpty) {
      Get.snackbar("Missing Field", "Event Title is required.", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    setState(() => _isSubmittingEvent = true);
    try {
      final double priceFrom = _eventTickets.isNotEmpty
          ? _eventTickets.map((t) => t.price).reduce((a, b) => a < b ? a : b)
          : 0.0;
      final int maxAttendees = int.tryParse(_eventMaxAttendeesCtrl.text.trim()) ?? 0;

      final success = await controller.saveEvent(
        eventId: _editingEventId,
        title: title,
        description: _eventDescCtrl.text.trim(),
        venue: _eventIsOnline ? "Online Virtual Event" : _eventVenueCtrl.text.trim(),
        city: _eventCityCtrl.text.trim(),
        country: _eventCountryCtrl.text.trim(),
        isOnline: _eventIsOnline,
        onlineUrl: _eventOnlineUrlCtrl.text.trim(),
        priceFrom: priceFrom,
        startDateTime: _eventStartDate,
        endDateTime: _eventEndDate,
        maxAttendees: maxAttendees,
        category: _eventCategory,
        imagePath: _eventImagePath,
        tickets: _eventTickets,
        timezone: _eventTimezone,
        checkInWindowMinutes: _eventCheckInWindow,
        metaTitle: _eventMetaTitleCtrl.text.trim(),
        metaDescription: _eventMetaDescCtrl.text.trim(),
        status: isDraft ? "DRAFT" : "PENDING_REVIEW",
      );

      if (success) {
        _resetEventForm();
        _navigateToPage(2); // Go to My Events
      }
    } finally {
      if (mounted) setState(() => _isSubmittingEvent = false);
    }
  }

  // ══════════════════════════════════════════════════════════════
  // SECTION 5: FUNDRAISING CONSOLE (/organizer/campaigns)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage4FundraisingConsole(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    final campaigns = data?.campaigns ?? controller.campaigns;
    final totalCampaigns = campaigns.length;
    final publicLive = campaigns.where((c) => c.status == "ACTIVE" || c.status == "PUBLISHED").length;
    final underReview = campaigns.where((c) => c.status == "PENDING_REVIEW").length;
    final drafts = campaigns.where((c) => c.status == "DRAFT").length;
    final double totalRaised = data?.totalRaised ?? campaigns.fold(0.0, (acc, c) => acc + c.raisedAmount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 5.A Fundraiser Verification Status Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 13, color: Color(0xFF10B981)),
                          SizedBox(width: 4),
                          Text("Verified Fundraiser Organizer", style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Text("Ref: ${data?.fundraiserReferenceId ?? 'FR-ORG-7781'}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Fundraising Console", style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: Colors.white)),
                const SizedBox(height: 2),
                const Text(
                  "Manage humanitarian causes, scholarship drives, and transparent charitable contributions.",
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 12),

                // 5.B Fundraising Action Buttons
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.add, size: 15),
                      label: const Text("Create New Campaign", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      onPressed: () => _showCreateCampaignDialog(context, controller),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE2E8F0),
                        side: const BorderSide(color: Color(0xFF475569)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      icon: const Icon(Icons.account_balance_wallet_outlined, size: 15),
                      label: const Text("Financials & Payouts", style: TextStyle(fontSize: 11)),
                      onPressed: () => _navigateToPage(5),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 5.C Fundraising Statistics (5 Cards)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: [
              _buildStatCard("Total Campaigns", "$totalCampaigns", "All initiatives", Icons.campaign, const Color(0xFF3B82F6)),
              _buildStatCard("Total Raised", controller.formatCurrency(totalRaised), "Donor capital", Icons.volunteer_activism, const Color(0xFF10B981)),
              _buildStatCard("Public & Live", "$publicLive", "Accepting donations", Icons.public, const Color(0xFF059669)),
              _buildStatCard("Under Review", "$underReview", "Admin inspection", Icons.schedule, const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 18),

          // 5.D Campaign Management Listing
          Text("Active & Hosted Campaigns", style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A))),
          const SizedBox(height: 8),

          if (campaigns.isEmpty)
            _buildEmptyState(
              icon: Icons.volunteer_activism_outlined,
              title: "No Campaigns Listed",
              subtitle: "Start a community or emergency drive to gather verified donations on Foundation.",
              buttonLabel: "+ Create New Campaign",
              onTap: () => _showCreateCampaignDialog(context, controller),
            )
          else
            ...campaigns.map((c) => _buildCampaignCard(context, controller, c)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, EcosystemController controller, EcosystemCampaign c) {
    final double pct = c.goalAmount > 0 ? (c.raisedAmount / c.goalAmount).clamp(0.0, 1.0) : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                child: Text(c.beneficiary ?? "Community Drive", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              ),
              _buildStatusPill(c.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(c.title, style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(c.description ?? "", maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${controller.formatCurrency(c.raisedAmount)} raised of ${controller.formatCurrency(c.goalAmount)}",
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              Text("${(pct * 100).toStringAsFixed(1)}% funded", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 4),
          Text("${c.totalDonors} donations received", style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          const Divider(height: 16),

          // 5.E Campaign Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.open_in_new, size: 14),
                label: const Text("Public Page", style: TextStyle(fontSize: 11)),
                onPressed: () {
                  Get.snackbar("Campaign Public Page", "Opening campaign link: notisboardglobalfoundation.org/campaigns/${c.id}",
                      backgroundColor: const Color(0xFF0F172A), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                },
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.payments_outlined, size: 14),
                label: const Text("Request Payout", style: TextStyle(fontSize: 11)),
                onPressed: () => _showPayoutRequestModal(context, controller),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SECTION 6: CREATE NEW FUNDRAISING CAMPAIGN (MODAL DIALOG)
  // ══════════════════════════════════════════════════════════════
  void _showCreateCampaignDialog(BuildContext context, EcosystemController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Create New Fundraising Campaign", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                      ],
                    ),
                    const Text("Set campaign parameters, funding goal, and donor stories.", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    const SizedBox(height: 14),

                    // 6.A Campaign Information
                    _buildFormLabel("Campaign Title *"),
                    TextField(controller: _campTitleCtrl, decoration: _buildInputDec("e.g. Clean Water Wells in Remote Villages")),
                    const SizedBox(height: 12),

                    _buildFormLabel("Campaign Category *"),
                    DropdownButtonFormField<String>(
                      value: _campCategory,
                      decoration: _buildInputDec(""),
                      items: const [
                        DropdownMenuItem(value: "Education & Scholarships", child: Text("Education & Scholarships")),
                        DropdownMenuItem(value: "Healthcare & Medical Relief", child: Text("Healthcare & Medical Relief")),
                        DropdownMenuItem(value: "Emergency Food & Shelter", child: Text("Emergency Food & Shelter")),
                        DropdownMenuItem(value: "Community Infrastructure", child: Text("Community Infrastructure")),
                        DropdownMenuItem(value: "Women & Youth Empowerment", child: Text("Women & Youth Empowerment")),
                      ],
                      onChanged: (v) {
                        if (v != null) setModalState(() => _campCategory = v);
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildFormLabel("Funding Goal in ${controller.currencyCode} *"),
                    TextField(
                      controller: _campGoalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDec("e.g. 10000 (${controller.currencySymbol})"),
                    ),
                    const SizedBox(height: 12),

                    _buildFormLabel("Short Summary / Tagline *"),
                    TextField(controller: _campTaglineCtrl, decoration: _buildInputDec("Brief 1-line mission impact...")),
                    const SizedBox(height: 12),

                    _buildFormLabel("Campaign Story & Beneficiary Details"),
                    TextField(
                      controller: _campStoryCtrl,
                      maxLines: 4,
                      decoration: _buildInputDec("Describe the cause, budget breakdown, and distribution plan..."),
                    ),
                    const SizedBox(height: 14),

                    // 6.B Cover Image (Upload or Paste URL)
                    _buildFormLabel("Cover Image (PNG, JPG, WebP up to 30MB)"),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: const Color(0xFF1E293B),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.upload_file, size: 16),
                          label: const Text("Choose Image", style: TextStyle(fontSize: 11)),
                          onPressed: () async {
                            final picker = ImagePicker();
                            final img = await picker.pickImage(source: ImageSource.gallery);
                            if (img != null) {
                              setModalState(() => _campImagePath = img.path);
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _campImageUrlCtrl,
                            decoration: _buildInputDec("Or paste image URL..."),
                            onChanged: (v) => setModalState(() {}),
                          ),
                        ),
                      ],
                    ),
                    if (_campImagePath != null) ...[
                      const SizedBox(height: 6),
                      Text("Selected: ${_campImagePath!.split('/').last}", style: const TextStyle(fontSize: 10, color: Color(0xFF10B981))),
                    ],
                    const SizedBox(height: 14),

                    // 6.C Campaign Duration
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFormLabel("Start Date"),
                              _buildDateSelector(
                                date: _campStartDate,
                                onPick: (d) => setModalState(() => _campStartDate = d),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFormLabel("End Date"),
                              _buildDateSelector(
                                date: _campEndDate,
                                onPick: (d) => setModalState(() => _campEndDate = d),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 6.D Donation Configuration
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _campAllowCustomDonations,
                      activeColor: const Color(0xFF2563EB),
                      title: const Text("Allow donors to enter custom donation amounts", style: TextStyle(fontSize: 12)),
                      onChanged: (v) => setModalState(() => _campAllowCustomDonations = v ?? true),
                    ),
                    const SizedBox(height: 18),

                    // 6.E Form Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                            onPressed: _isSubmittingCampaign ? null : () => Get.back(),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                            onPressed: _isSubmittingCampaign
                                ? null
                                : () async {
                                    final ok = await _submitCampaign(controller, isDraft: true);
                                    if (ok && mounted) Get.back();
                                  },
                            child: const Text("Save Draft", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _isSubmittingCampaign
                                ? null
                                : () async {
                                    final ok = await _submitCampaign(controller, isDraft: false);
                                    if (ok && mounted) Get.back();
                                  },
                            child: _isSubmittingCampaign
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text("Submit for Review", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateSelector({required DateTime date, required Function(DateTime) onPick}) {
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
        );
        if (d != null) onPick(d);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat("MMM d, yyyy").format(date), style: const TextStyle(fontSize: 11)),
            const Icon(Icons.calendar_today, size: 14, color: Color(0xFF2563EB)),
          ],
        ),
      ),
    );
  }

  Future<bool> _submitCampaign(EcosystemController controller, {required bool isDraft}) async {
    if (_isSubmittingCampaign || controller.isActionLoading) return false;
    final title = _campTitleCtrl.text.trim();
    final goal = double.tryParse(_campGoalCtrl.text.trim()) ?? 0.0;
    if (title.isEmpty || goal <= 0) {
      Get.snackbar("Missing Field", "Title and a valid funding goal are required.", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    }

    setState(() => _isSubmittingCampaign = true);
    try {
      final success = await controller.addCampaign(
        title: title,
        description: "${_campTaglineCtrl.text.trim()}\n\n${_campStoryCtrl.text.trim()}",
        goalAmount: goal,
        beneficiary: _campCategory,
        startDate: _campStartDate,
        endDate: _campEndDate,
        status: isDraft ? "DRAFT" : "PENDING_REVIEW",
        imagePath: _campImagePath,
      );

      if (success) {
        _campTitleCtrl.clear();
        _campTaglineCtrl.clear();
        _campStoryCtrl.clear();
        _campGoalCtrl.clear();
        _campImageUrlCtrl.clear();
        _campImagePath = null;
        return true;
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSubmittingCampaign = false);
    }
  }

  // ══════════════════════════════════════════════════════════════
  // SECTION 7: EARNINGS & REVENUE MODULE (/organizer/earnings)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage5EarningsAndRevenue(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    final gross = data?.grossRevenue ?? 0.0;
    final commission = data?.commission ?? 0.0;
    final net = data?.netEarnings ?? 0.0;
    final available = data?.availableBalance ?? data?.balance ?? 0.0;
    final escrow = data?.escrowHolding ?? 0.0;
    final totalPaid = data?.totalPaidOut ?? 0.0;
    final processing = data?.processingWithdrawals ?? 0.0;
    final events = data?.events ?? controller.events;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 7.A Page Header with Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Earnings & Revenue", style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: const Color(0xFF0F172A))),
                  Text("Currency Standard: ${controller.currencyCode} (${controller.currencySymbol})", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF2563EB)),
                    onPressed: () => controller.loadOrganizerPortal(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _earningsCategoryTab == 1 ? const Color(0xFF7C3AED) : const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () => _showPayoutRequestModal(context, controller, isFundraising: _earningsCategoryTab == 1),
                    child: Text(_earningsCategoryTab == 1 ? "Request Campaign Payout" : "Request Payout", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 7.B Earnings Categories Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Expanded(child: _buildCategoryTabBtn("Event Ticketing", 0, _earningsCategoryTab, (i) => setState(() => _earningsCategoryTab = i))),
                const SizedBox(width: 4),
                Expanded(child: _buildCategoryTabBtn("Fundraising", 1, _earningsCategoryTab, (i) => setState(() => _earningsCategoryTab = i), badge: "Charity Ledger")),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (_earningsCategoryTab == 0) ...[
            // 7.C Escrow Protection Policy Banner (Dynamic from Admin Settlement Policy)
            Builder(
              builder: (ctx) {
                final policy = data?.settlementPolicy;
                final isImmediate = policy?.isImmediateBooking ?? false;
                final isZeroHold = !isImmediate && ((policy?.payoutHoldDays ?? 7) == 0);

                final bgColor = isImmediate
                    ? const Color(0xFFECFDF5)
                    : (isZeroHold ? const Color(0xFFEFF6FF) : const Color(0xFFEFF6FF));
                final borderColor = isImmediate
                    ? const Color(0xFFA7F3D0)
                    : (isZeroHold ? const Color(0xFFBFDBFE) : const Color(0xFFBFDBFE));
                final iconColor = isImmediate
                    ? const Color(0xFF059669)
                    : (isZeroHold ? const Color(0xFF2563EB) : const Color(0xFF2563EB));
                final titleColor = isImmediate
                    ? const Color(0xFF065F46)
                    : (isZeroHold ? const Color(0xFF1E40AF) : const Color(0xFF1E40AF));
                final textColor = isImmediate
                    ? const Color(0xFF047857)
                    : (isZeroHold ? const Color(0xFF1E3A8A) : const Color(0xFF1E3A8A));

                final title = isImmediate
                    ? "Instant Release Policy Active (0 Days Hold)"
                    : (isZeroHold
                        ? "Immediate Clearance on Event Completion (0 Days Hold)"
                        : "Escrow Active (${policy?.payoutHoldDays ?? 7} Days Hold)");

                final description = isImmediate
                    ? "Ticket revenues are cleared immediately upon attendee ticket booking (0 days hold). Escrow protection delay is bypassed."
                    : (isZeroHold
                        ? "Ticket revenues are held in escrow until the event concludes, then release immediately to available balance (0 days hold)."
                        : "Ticket revenues are securely held in escrow until event completion. Once the host delivers the event, funds automatically release to available balance within ${policy?.payoutHoldDays ?? 7} days post-event.");

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(isImmediate ? Icons.bolt_rounded : Icons.shield_outlined, color: iconColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: titleColor)),
                            const SizedBox(height: 2),
                            Text(description, style: TextStyle(fontSize: 10.5, color: textColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 7.D 5 Financial Statistics
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.45,
              children: [
                _buildStatCard("Gross Ticket Sales", controller.formatCurrency(gross), "Total gross tickets", Icons.sell_outlined, const Color(0xFF3B82F6)),
                _buildStatCard("Platform Commission", "-${controller.formatCurrency(commission)}", "10% Platform fee", Icons.percent, const Color(0xFFDC2626)),
                _buildStatCard("Total Net Earned", controller.formatCurrency(net), "Post-commission net", Icons.verified_outlined, const Color(0xFF059669)),
                _buildStatCard("Available for Payout", controller.formatCurrency(available), "Cleared for bank wire", Icons.account_balance_wallet_outlined, const Color(0xFF10B981)),
              ],
            ),
            const SizedBox(height: 10),
            _buildWideEscrowCard(controller, escrow, processing, totalPaid),
            const SizedBox(height: 18),

            // 7.F Commission & Fee Deductions Breakdown
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Admin-Configured Commission & Fee Deductions", style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A))),
                  const SizedBox(height: 10),
                  _buildFeeRow("Standard Event Platform Commission", "10.0%", "-${controller.formatCurrency(commission)}"),
                  const Divider(height: 16),
                  _buildFeeRow("Escrow Protection & Dispute Coverage", "FREE (0.0%)", controller.formatCurrency(0.0)),
                  const Divider(height: 16),
                  _buildFeeRow("Net Settlement Yield", "90.0%", controller.formatCurrency(net), color: const Color(0xFF059669)),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 7.G Revenue & Clearance by Event
            Text("Revenue & Clearance by Event", style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
            const SizedBox(height: 8),

            if (events.isEmpty)
              _buildEmptyState(
                icon: Icons.event_note,
                title: "No Event Revenue Records",
                subtitle: "Revenue entries will generate automatically as ticket sales conclude.",
              )
            else
              ...events.map((e) => _buildEventClearanceCard(context, controller, e)),

            const SizedBox(height: 18),

            // 7.H Monthly Breakdown
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Monthly Financial Breakdown", style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A))),
                  const SizedBox(height: 10),
                  _buildMonthlyRow("Current Billing Cycle (Month-to-Date)", controller.formatCurrency(gross), controller.formatCurrency(net)),
                  const Divider(height: 14),
                  _buildMonthlyRow("All-Time Historical Settlement", controller.formatCurrency(gross), controller.formatCurrency(net)),
                ],
              ),
            ),
          ] else ...[
            _buildFundraisingSettlementsView(context, controller, data),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategoryTabBtn(String title, int index, int current, Function(int) onSelect, {String? badge}) {
    final isSelected = index == current;
    final isPurpleTab = index == 1 && isSelected;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelect(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isPurpleTab ? const Color(0xFF7C3AED) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [BoxShadow(color: (isPurpleTab ? const Color(0xFF7C3AED) : Colors.black).withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 1))]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? (isPurpleTab ? Colors.white : const Color(0xFF1E293B))
                      : const Color(0xFF64748B),
                ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isPurpleTab ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFEDE9FE))
                      : const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isPurpleTab ? Colors.white : const Color(0xFF7C3AED),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWideEscrowCard(EcosystemController controller, double escrow, double processing, double totalPaid) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.lock_outline, color: Color(0xFF8B5CF6), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Held in Escrow Protection", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  Text("Awaiting event completions (${controller.currencyCode})", style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          Text(
            controller.formatCurrency(escrow),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF8B5CF6)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String rate, String amount, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Text("Configured Rate: $rate", style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
            ],
          ),
        ),
        Text(amount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color ?? const Color(0xFF0F172A))),
      ],
    );
  }

  Widget _buildMonthlyRow(String period, String gross, String net) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(period, style: const TextStyle(fontSize: 11, color: Color(0xFF334155))),
        Row(
          children: [
            Text("Gross: $gross", style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            const SizedBox(width: 10),
            Text("Net: $net", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
          ],
        ),
      ],
    );
  }

  Widget _buildEventClearanceCard(BuildContext context, EcosystemController controller, EcosystemEvent event) {
    final isCleared = event.isCleared ||
        event.payoutStatus == "AVAILABLE" ||
        event.clearanceStatus == "CLEARED & AVAILABLE" ||
        event.clearanceStatus == "CLEARED" ||
        event.status == "COMPLETED";
    final isClearing = !isCleared && (event.payoutStatus == "CLEARING" || event.clearanceStatus.startsWith("CLEARING"));

    final badgeText = isCleared
        ? "CLEARED & AVAILABLE"
        : (isClearing ? "CLEARING (${event.daysUntilClearance}d)" : "HELD IN ESCROW");
    final badgeBg = isCleared
        ? const Color(0xFFECFDF5)
        : (isClearing ? const Color(0xFFEFF6FF) : const Color(0xFFFEF3C7));
    final badgeColor = isCleared
        ? const Color(0xFF059669)
        : (isClearing ? const Color(0xFF2563EB) : const Color(0xFFD97706));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildClearanceMetric("Gross Sales", controller.formatCurrency(event.grossRevenue)),
              _buildClearanceMetric("Fee (-10%)", "-${controller.formatCurrency(event.commission)}", color: const Color(0xFFDC2626)),
              _buildClearanceMetric("Net Settlement", controller.formatCurrency(event.netEarnings), color: const Color(0xFF059669)),
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
  // SECTION 8: PAYOUTS & SETTLEMENTS MODULE (/organizer/payouts)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage6PayoutsAndSettlements(
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

    final events = data?.events ?? controller.events;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 8.A Page Header with Request Payout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Payouts & Withdrawals", style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: const Color(0xFF0F172A))),
                  Text("Settlement standard: ${controller.currencyCode}", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF2563EB)),
                    onPressed: () => controller.loadOrganizerPortal(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _payoutTypeTab == 1 ? const Color(0xFF7C3AED) : const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () => _showPayoutRequestModal(context, controller, isFundraising: _payoutTypeTab == 1),
                    child: Text(_payoutTypeTab == 1 ? "Request Campaign Payout" : "Request Payout", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 8.B Payout Type Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Expanded(child: _buildCategoryTabBtn("Event Ticket Payouts", 0, _payoutTypeTab, (i) => setState(() => _payoutTypeTab = i))),
                const SizedBox(width: 4),
                Expanded(child: _buildCategoryTabBtn("Fundraising", 1, _payoutTypeTab, (i) => setState(() => _payoutTypeTab = i), badge: "Charity Ledger")),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (_payoutTypeTab == 0) ...[
            // 8.C Escrow Hold Indicator Banner (Dynamic from Admin Settlement Policy)
            Builder(
              builder: (ctx) {
                final policy = data?.settlementPolicy;
                final isImmediate = policy?.isImmediateBooking ?? false;
                final isZeroHold = !isImmediate && ((policy?.payoutHoldDays ?? 7) == 0);

                final bannerBg = isImmediate
                    ? const Color(0xFFECFDF5)
                    : (isZeroHold ? const Color(0xFFEFF6FF) : const Color(0xFFFEF3C7));
                final bannerBorder = isImmediate
                    ? const Color(0xFFA7F3D0)
                    : (isZeroHold ? const Color(0xFFBFDBFE) : const Color(0xFFFDE68A));
                final bannerIconColor = isImmediate
                    ? const Color(0xFF059669)
                    : (isZeroHold ? const Color(0xFF2563EB) : const Color(0xFFD97706));
                final bannerTextColor = isImmediate
                    ? const Color(0xFF065F46)
                    : (isZeroHold ? const Color(0xFF1E40AF) : const Color(0xFF92400E));

                final bannerMsg = isImmediate
                    ? "Instant Release Active: Funds cleared immediately upon ticket booking (0 days hold). Available for immediate payout."
                    : (isZeroHold
                        ? "Immediate Clearance on Event End: Funds release to available payout balance as soon as the event concludes (0 days hold)."
                        : "Escrow Active: Funds held until event completion. Releasing automatically ${policy?.payoutHoldDays ?? 7} days post-event.");

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bannerBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: bannerBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(isImmediate ? Icons.bolt_rounded : Icons.lock_clock, size: 18, color: bannerIconColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bannerMsg,
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: bannerTextColor),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            // 8.D 4 Payout Statistics
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard("Available Payout", controller.formatCurrency(available), "Cleared funds", Icons.account_balance_wallet, const Color(0xFF10B981)),
                _buildStatCard("Total Paid Out", controller.formatCurrency(totalPaid), "Settled to bank", Icons.verified, const Color(0xFF3B82F6)),
                _buildStatCard("Processing", controller.formatCurrency(processing), "In review", Icons.hourglass_top, const Color(0xFFF59E0B)),
                _buildStatCard("Held in Escrow", controller.formatCurrency(escrow), "Awaiting events", Icons.lock_outline, const Color(0xFF8B5CF6)),
              ],
            ),
            const SizedBox(height: 18),

            // 8.E Withdrawal Request History with Status Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Withdrawal Request History", style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _payoutHistoryFilter,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                    items: const [
                      DropdownMenuItem(value: "ALL", child: Text("All Statuses")),
                      DropdownMenuItem(value: "PENDING", child: Text("Pending")),
                      DropdownMenuItem(value: "PROCESSING", child: Text("Processing")),
                      DropdownMenuItem(value: "COMPLETED", child: Text("Completed")),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _payoutHistoryFilter = v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (withdrawals.isEmpty)
              _buildEmptyState(
                icon: Icons.history,
                title: "No Withdrawal Requests",
                subtitle: "When you request a payout, status and bank dispatch details will appear here.",
              )
            else
              ...withdrawals.map((w) => _buildWithdrawalTile(context, controller, w)),

            const SizedBox(height: 18),

            // 8.F Event Revenue & Clearance Breakdown
            Text("Event Settlement & Clearance Breakdown", style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
            const SizedBox(height: 8),

            if (events.isEmpty)
              _buildEmptyState(icon: Icons.event, title: "No Events To Settle", subtitle: "Host events and tickets to begin settlements.")
            else
              ...events.map((e) => _buildEventClearanceCard(context, controller, e)),
          ] else ...[
            _buildFundraisingSettlementsView(context, controller, data),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWithdrawalTile(BuildContext context, EcosystemController controller, EcosystemWithdrawal w) {
    Color badgeColor = const Color(0xFFF59E0B);
    final s = w.status.toUpperCase();
    if (s == "COMPLETED" || s == "APPROVED") badgeColor = const Color(0xFF10B981);
    if (s == "REJECTED") badgeColor = const Color(0xFFDC2626);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.account_balance, color: Color(0xFF2563EB), size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(controller.formatCurrency(w.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  Text((w.method != null && w.method!.isNotEmpty) ? w.method! : "Direct Bank Wire", style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  Text(w.createdAt ?? "", style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(s, style: TextStyle(color: badgeColor, fontSize: 9.5, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Fundraising Settlements View (Matches Website /organizer/payouts and /organizer/earnings)
  Widget _buildFundraisingSettlementsView(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    final fund = data?.fundraising;
    final campaigns = fund?.campaigns ?? [];
    final totalRaised = fund?.totalGrossCollected ?? (data?.totalRaised ?? 0.0);
    final platformCommission = fund?.totalCommissionDeducted ?? (totalRaised * 0.02);
    final processingFees = fund?.totalGatewayFees ?? 0.0;
    final netEarnings = fund?.totalNetEarnings ?? (totalRaised - platformCommission);
    final pendingHold = fund?.pendingSettlement ?? 0.0;
    final availablePayout = fund?.availableForWithdrawal ?? 0.0;
    final reservedPayouts = fund?.reservedWithdrawals ?? 0.0;
    final totalPaidOut = fund?.totalWithdrawn ?? 0.0;
    final holdDays = fund?.payoutHoldDays ?? 0;
    final minPayout = fund?.minWithdrawalAmount ?? 20.0;
    final isKycApproved = fund?.kycApproved ?? (data?.isApproved ?? false);

    // Filter withdrawals strictly where source is FUNDRAISING
    final fundraisingWithdrawals = (data?.withdrawals ?? [])
        .where((w) => (w.source?.toUpperCase() == "FUNDRAISING" || (w.campaignTitle != null && w.campaignTitle!.isNotEmpty)))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Purple Header Banner with Restricted Charity Ledger badge
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE9D5FF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            const Text(
                              "Fundraising Earnings & Settlements",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF581C87)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDE9FE),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "Restricted Charity Ledger",
                                style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isKycApproved ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, size: 5, color: isKycApproved ? const Color(0xFF16A34A) : const Color(0xFFD97706)),
                                  const SizedBox(width: 3),
                                  Text(
                                    isKycApproved ? "KYC Verified" : "KYC Pending",
                                    style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: isKycApproved ? const Color(0xFF16A34A) : const Color(0xFFD97706)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Campaign donations are strictly segregated from event ticket sales in a secure charity escrow ledger. Proceeds clear after a $holdDays-day settlement holding period to ensure donor compliance and fraud protection.",
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B21A8), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: (availablePayout > 0)
                      ? () => _showPayoutRequestModal(context, controller, isFundraising: true)
                      : null,
                  child: Text(
                    availablePayout > 0
                        ? "Request Campaign Payout (${controller.formatCurrency(availablePayout)})"
                        : "Request Campaign Payout",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. 8 Financial Statistics Cards
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.45,
          children: [
            _buildStatCard("TOTAL RAISED", controller.formatCurrency(totalRaised), "Gross donor gifts", Icons.payments_outlined, const Color(0xFF2563EB)),
            _buildStatCard("PLATFORM COMMISSION", controller.formatCurrency(platformCommission), "Foundation operational fee (${fund?.commissionRate ?? 2}%)", Icons.percent, const Color(0xFFDC2626)),
            _buildStatCard("PROCESSING FEES", controller.formatCurrency(processingFees), "Absorbed by Foundation", Icons.check_circle_outline, const Color(0xFF64748B)),
            _buildStatCard("NET EARNINGS", controller.formatCurrency(netEarnings), "Net entitlement", Icons.account_balance, const Color(0xFF7C3AED)),
            _buildStatCard("PENDING HOLD", controller.formatCurrency(pendingHold), "${holdDays}d Escrow • Releases rolling", Icons.hourglass_empty, const Color(0xFFF59E0B)),
            _buildStatCard("AVAILABLE PAYOUT", controller.formatCurrency(availablePayout), "Cleared for bank transfer", Icons.check_circle, const Color(0xFF10B981)),
            _buildStatCard("RESERVED PAYOUTS", controller.formatCurrency(reservedPayouts), "Under admin review", Icons.lock_clock, const Color(0xFF64748B)),
            _buildStatCard("TOTAL PAID OUT", controller.formatCurrency(totalPaidOut), "Settled to bank account", Icons.verified, const Color(0xFF059669)),
          ],
        ),
        const SizedBox(height: 18),

        // 3. Campaign-Level Financial Breakdown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Campaign-Level Financial Breakdown (${campaigns.length})",
              style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A)),
            ),
            Text(
              "Hold period: $holdDays days rolling after donation",
              style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (campaigns.isEmpty)
          _buildEmptyState(
            icon: Icons.volunteer_activism_outlined,
            title: "No Campaigns Listed",
            subtitle: "Start a fundraising campaign to track donations and charity settlements.",
          )
        else
          ...campaigns.map((c) => _buildCampaignFinancialCard(context, controller, c, minPayout: minPayout)),

        const SizedBox(height: 18),

        // 4. Fundraising Payout Requests History
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Fundraising Payout Requests History (${fundraisingWithdrawals.length})",
              style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          "Review all past and processing fundraising campaign payout requests.",
          style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 8),

        if (fundraisingWithdrawals.isEmpty)
          _buildEmptyState(
            icon: Icons.history,
            title: "No Fundraising Payout Requests",
            subtitle: "When you request a campaign payout, status and bank dispatch details will appear here.",
          )
        else
          ...fundraisingWithdrawals.map((w) => _buildFundraisingWithdrawalTile(context, controller, w)),
      ],
    );
  }

  Widget _buildFundraisingWithdrawalTile(BuildContext context, EcosystemController controller, EcosystemWithdrawal w) {
    Color badgeColor = const Color(0xFFF59E0B);
    final s = w.status.toUpperCase();
    if (s == "COMPLETED" || s == "APPROVED") badgeColor = const Color(0xFF10B981);
    if (s == "REJECTED") badgeColor = const Color(0xFFDC2626);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(color: const Color(0xFFFAF5FF), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.receipt_long, color: Color(0xFF7C3AED), size: 16),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(w.reference ?? (w.id.length > 12 ? w.id.substring(0, 12).toUpperCase() : w.id), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF0F172A))),
                      Text(w.campaignTitle ?? "Charity Campaign", style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(controller.formatCurrency(w.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                  Text(w.method ?? "Bank Transfer", style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          const Divider(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Requested: ${w.createdAt ?? ''}", style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(s, style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignFinancialCard(
    BuildContext context,
    EcosystemController controller,
    FundraisingCampaignFinancialItem c, {
    double minPayout = 20.0,
  }) {
    final isCleared = c.pendingSettlement <= 0;
    final canWithdraw = c.availableBalance >= minPayout;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(
                      "Goal: ${controller.formatCurrency(c.goalAmount)} • ${c.donationsCount} donations",
                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isCleared ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isCleared ? Icons.check : Icons.hourglass_top, size: 10, color: isCleared ? const Color(0xFF16A34A) : const Color(0xFFD97706)),
                    const SizedBox(width: 3),
                    Text(
                      isCleared ? "All Cleared" : "Pending Hold (${c.payoutHoldDays}d)",
                      style: TextStyle(color: isCleared ? const Color(0xFF16A34A) : const Color(0xFFD97706), fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniCol("GROSS RAISED", controller.formatCurrency(c.grossCollected)),
              _buildMiniCol("COMMISSION", "-${controller.formatCurrency(c.commissionDeducted)}"),
              _buildMiniCol("AVAILABLE", controller.formatCurrency(c.availableBalance), isGreen: c.availableBalance > 0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canWithdraw ? const Color(0xFF7C3AED) : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(60, 28),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: canWithdraw ? () => _showPayoutRequestModal(context, controller, isFundraising: true, preselectedCampaignId: c.campaignId) : null,
                child: const Text("Request Payout", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCol(String label, String value, {bool isGreen = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 8.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isGreen ? const Color(0xFF10B981) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // Payout Request Modal (Unified for Events and Fundraising)
  void _showPayoutRequestModal(
    BuildContext context,
    EcosystemController controller, {
    bool isFundraising = false,
    String? preselectedCampaignId,
  }) {
    final fund = controller.organizerPortalData?.fundraising;
    final fundCampaigns = fund?.campaigns ?? [];

    String? selectedCampaignId = preselectedCampaignId;
    if (isFundraising && (selectedCampaignId == null || selectedCampaignId.isEmpty)) {
      if (fundCampaigns.isNotEmpty) {
        selectedCampaignId = fundCampaigns.first.campaignId;
      }
    }

    final initialSelectedCamp = isFundraising
        ? fundCampaigns.firstWhereOrNull((c) => c.campaignId == selectedCampaignId) ?? (fundCampaigns.isNotEmpty ? fundCampaigns.first : null)
        : null;

    final double available = isFundraising
        ? (initialSelectedCamp?.availableBalance ?? fund?.availableForWithdrawal ?? 0.0)
        : (controller.organizerPortalData?.availableBalance ?? controller.organizerPortalData?.balance ?? 0.0);

    final double minPayout = isFundraising
        ? (fund?.minWithdrawalAmount ?? 20.0)
        : (controller.organizerPortalData?.settlementPolicy?.minWithdrawalAmount ??
            (fund?.minWithdrawalAmount ?? 20.0));

    final amountCtrl = TextEditingController(text: available >= minPayout ? available.toStringAsFixed(2) : "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final currentSelectedCamp = isFundraising
                ? fundCampaigns.firstWhereOrNull((c) => c.campaignId == selectedCampaignId) ?? (fundCampaigns.isNotEmpty ? fundCampaigns.first : null)
                : null;
            final currentAvailable = isFundraising
                ? (currentSelectedCamp?.availableBalance ?? fund?.availableForWithdrawal ?? 0.0)
                : (controller.organizerPortalData?.availableBalance ?? controller.organizerPortalData?.balance ?? 0.0);

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              isFundraising ? "Request Campaign Payout" : "Request Settlement Withdrawal",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            if (isFundraising) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFEDE9FE), borderRadius: BorderRadius.circular(4)),
                                child: const Text("Charity Ledger", style: TextStyle(color: Color(0xFF7C3AED), fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                      ],
                    ),
                    Text(
                      isFundraising
                          ? "Disburse cleared donations directly to your settlement account"
                          : "Available to withdraw: ${controller.formatCurrency(currentAvailable)} (Escrow-held funds are locked until event ends)",
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 14),

                    if (isFundraising && fundCampaigns.isNotEmpty) ...[
                      _buildFormLabel("Select Fundraising Campaign *"),
                      DropdownButtonFormField<String>(
                        value: selectedCampaignId,
                        decoration: _buildInputDec(""),
                        isExpanded: true,
                        items: fundCampaigns.map((camp) {
                          return DropdownMenuItem<String>(
                            value: camp.campaignId,
                            child: Text(
                              "${camp.title} — Cleared Available: ${controller.formatCurrency(camp.availableBalance)}",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedCampaignId = val;
                              final c = fundCampaigns.firstWhereOrNull((item) => item.campaignId == val);
                              if (c != null && c.availableBalance > 0) {
                                amountCtrl.text = c.availableBalance.toStringAsFixed(2);
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFormLabel("Withdrawal Amount (${controller.currencyCode}) *"),
                        Text(
                          "Available: ${controller.formatCurrency(currentAvailable)}",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: amountCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDec("Min ${controller.formatCurrency(minPayout)}"),
                          ),
                        ),
                        if (currentAvailable > 0) ...[
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFundraising ? const Color(0xFFEDE9FE) : const Color(0xFFEFF6FF),
                              foregroundColor: isFundraising ? const Color(0xFF7C3AED) : const Color(0xFF2563EB),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              setModalState(() {
                                amountCtrl.text = currentAvailable.toStringAsFixed(2);
                              });
                            },
                            child: const Text("MAX", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Minimum payout limit is ${controller.formatCurrency(minPayout)}. Funds held in rolling escrow cannot be withdrawn until cleared.",
                      style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 12),

                    _buildFormLabel("Payout Method"),
                    DropdownButtonFormField<String>(
                      initialValue: _payoutMethod,
                      decoration: _buildInputDec(""),
                      items: const [
                        DropdownMenuItem(value: "Direct Bank Wire / Local Transfer", child: Text("Direct Bank Wire / Local Transfer")),
                        DropdownMenuItem(value: "Stripe Connect", child: Text("Stripe Connect")),
                        DropdownMenuItem(value: "PayPal Merchant", child: Text("PayPal Merchant")),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _payoutMethod = v);
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildFormLabel("Bank Name *"),
                    TextField(
                      controller: _bankNameCtrl,
                      decoration: _buildInputDec("e.g. JPMorgan Chase, Royal Bank, Barclays"),
                    ),
                    const SizedBox(height: 12),

                    _buildFormLabel("Account Holder Legal Name *"),
                    TextField(
                      controller: _accountHolderCtrl,
                      decoration: _buildInputDec("Full legal name on bank account"),
                    ),
                    const SizedBox(height: 12),

                    _buildFormLabel("Account Number / IBAN *"),
                    TextField(
                      controller: _accountNumberCtrl,
                      decoration: _buildInputDec("Account / IBAN"),
                    ),
                    const SizedBox(height: 12),

                    _buildFormLabel("Routing / SWIFT Code"),
                    TextField(
                      controller: _routingNumberCtrl,
                      decoration: _buildInputDec("Routing / SWIFT"),
                    ),
                    const SizedBox(height: 14),

                    if (isFundraising) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE9D5FF)),
                        ),
                        child: const Text(
                          "Charitable Escrow Protection: Campaign funds are isolated in a restricted ledger. Submitting this request reserves the amount against the campaign's cleared balance and does NOT affect your event ticket revenues. Payouts require Admin review.",
                          style: TextStyle(fontSize: 9.5, color: Color(0xFF6B21A8), height: 1.3),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFundraising ? const Color(0xFF7C3AED) : const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final reqAmt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                          if (reqAmt < minPayout) {
                            Get.snackbar("Minimum Limit", "Minimum payout limit is ${controller.formatCurrency(minPayout)}",
                                backgroundColor: Colors.redAccent, colorText: Colors.white);
                            return;
                          }
                          if (reqAmt > currentAvailable) {
                            Get.snackbar("Insufficient Available Funds",
                                "Amount exceeds cleared balance (${controller.formatCurrency(currentAvailable)}). Escrowed funds clear after holding period.",
                                backgroundColor: Colors.redAccent, colorText: Colors.white);
                            return;
                          }

                          Get.back();
                          await controller.submitOrganizerPayout(
                            amount: reqAmt,
                            method: _payoutMethod,
                            source: isFundraising ? "FUNDRAISING" : "EVENTS",
                            campaignId: selectedCampaignId,
                            bankDetails: {
                              "source": isFundraising ? "FUNDRAISING" : "EVENTS",
                              if (selectedCampaignId != null) "campaignId": selectedCampaignId,
                              if (currentSelectedCamp != null) "campaignTitle": currentSelectedCamp.title,
                              "bankName": _bankNameCtrl.text.trim(),
                              "accountHolder": _accountHolderCtrl.text.trim(),
                              "accountNumber": _accountNumberCtrl.text.trim(),
                              "routingNumber": _routingNumberCtrl.text.trim(),
                            },
                          );
                        },
                        child: Text(
                          isFundraising ? "Submit Campaign Payout" : "Confirm & Submit Payout Request",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SECTION 9: ORGANIZER KYC VERIFICATION MODULE (/organizer/verification)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage0KycVerification(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    final dossier = data?.dossier;
    final isVerified = dossier?.isApproved ?? (data?.isApproved ?? true);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 9.A Verification Header
          Text("EVENT HOST COMPLIANCE", style: AppFontStyle.fontStyleW600(fontSize: 11, fontColor: const Color(0xFF2563EB))),
          const SizedBox(height: 4),
          Text("Organizer KYC Verification", style: AppFontStyle.fontStyleW700(fontSize: 20, fontColor: const Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(
            "In accordance with international charitable and non-profit marketplace guidelines, event organizers must verify identity and banking details to unlock ticket sales.",
            style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 18),

          // 9.H Verified Dossier View vs Form Submission
          if (isVerified) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF059669), size: 22),
                      const SizedBox(width: 8),
                      Text("CURRENT STATUS: VERIFIED & UNLOCKED", style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF065F46))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your organizer dossier has been officially verified by Foundation Compliance. Full event ticketing, registration management, and bank settlements are unlocked.",
                    style: TextStyle(fontSize: 11, color: Color(0xFF047857)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: () {
                      _resetEventForm();
                      _navigateToPage(3);
                    },
                    child: const Text("Create Your First Event →", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Read-Only Compliance Dossier
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
                      Row(
                        children: [
                          const Icon(Icons.lock, size: 16, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Text("Verified Compliance Dossier", style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                        child: const Text("READ-ONLY", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  _buildDossierField("Applicant Entity Type", (dossier?.applicantType ?? "organization").toUpperCase()),
                  _buildDossierField("Primary Legal Contact", "${dossier?.firstName ?? 'Organizer'} ${dossier?.lastName ?? 'Official'}"),
                  _buildDossierField("Contact Email", dossier?.email ?? data?.profileData?.email ?? "organizer@notisboard.org"),
                  _buildDossierField("Contact Phone", dossier?.phone ?? "+1 (555) 019-2834"),
                  _buildDossierField("Organization Name", dossier?.organizationName ?? data?.organizationName ?? "Official Foundation Host"),
                  _buildDossierField("Official Website", dossier?.website ?? "https://notisboardglobalfoundation.org"),
                  _buildDossierField("Jurisdiction / Location", "${dossier?.city ?? 'Toronto'}, ${dossier?.country ?? 'Canada'}"),
                  _buildDossierField("Government ID Verification", "International Passport • Verified & Certified"),
                  _buildDossierField("Settlement Payout Account", "Direct Bank Wire • RBC Bank • ****7890"),
                ],
              ),
            ),
          ] else ...[
            // 9.B Entity Type Switcher & Form Submission
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
                  _buildFormLabel("Organizer Entity Type"),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _kycDossierType == "individual" ? const Color(0xFF2563EB) : Colors.transparent,
                            foregroundColor: _kycDossierType == "individual" ? Colors.white : const Color(0xFF334155),
                          ),
                          onPressed: () => setState(() => _kycDossierType = "individual"),
                          child: const Text("Individual Organizer"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _kycDossierType == "organization" ? const Color(0xFF2563EB) : Colors.transparent,
                            foregroundColor: _kycDossierType == "organization" ? Colors.white : const Color(0xFF334155),
                          ),
                          onPressed: () => setState(() => _kycDossierType = "organization"),
                          child: const Text("Business / Non-profit"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildFormLabel("Full Legal Name *"),
                  TextField(controller: _kycLegalNameCtrl, decoration: _buildInputDec("Legal name as on passport / government ID")),
                  const SizedBox(height: 12),

                  _buildFormLabel("Date of Birth *"),
                  TextField(controller: _kycDobCtrl, decoration: _buildInputDec("YYYY-MM-DD")),
                  const SizedBox(height: 12),

                  _buildFormLabel("Contact Phone"),
                  TextField(controller: _kycPhoneCtrl, decoration: _buildInputDec("+1 555-019-2834")),
                  const SizedBox(height: 12),

                  _buildFormLabel("Country of Residence / Operation"),
                  TextField(controller: _kycCountryCtrl, decoration: _buildInputDec("Canada, United States, etc.")),
                  const SizedBox(height: 12),

                  _buildFormLabel("Government Identification Document"),
                  DropdownButtonFormField<String>(
                    value: _kycDocType,
                    decoration: _buildInputDec(""),
                    items: const [
                      DropdownMenuItem(value: "International Passport", child: Text("International Passport")),
                      DropdownMenuItem(value: "National Identity Card", child: Text("National Identity Card")),
                      DropdownMenuItem(value: "Driver's License", child: Text("Driver's License")),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _kycDocType = v);
                    },
                  ),
                  const SizedBox(height: 14),

                  _buildFormLabel("Upload ID Front / Photo Page (Max 30MB) *"),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9), foregroundColor: const Color(0xFF1E293B), elevation: 0),
                    icon: const Icon(Icons.upload_file, size: 16),
                    label: Text(_kycFrontPath != null ? "Selected: ${_kycFrontPath!.split('/').last}" : "Click to Upload Document"),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final img = await picker.pickImage(source: ImageSource.gallery);
                      if (img != null) setState(() => _kycFrontPath = img.path);
                    },
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Get.snackbar("KYC Submitted", "Your verification documents have been submitted to Foundation Compliance.",
                            backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
                      },
                      child: const Text("Submit KYC Verification", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDossierField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)))),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SECTION 10: NOTIFICATIONS & ANNOUNCEMENTS (/organizer/notifications)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage7Notifications(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    var notifs = data?.notifications ?? [];

    if (_notifSearchQuery.isNotEmpty) {
      final q = _notifSearchQuery.toLowerCase();
      notifs = notifs.where((n) => n.title.toLowerCase().contains(q) || n.message.toLowerCase().contains(q)).toList();
    }

    if (_notifFilter == "UNREAD") {
      notifs = notifs.where((n) => !n.isRead).toList();
    } else if (_notifFilter == "EVENTS") {
      notifs = notifs.where((n) => n.type == "EVENT" || n.title.toLowerCase().contains("event")).toList();
    } else if (_notifFilter == "FINANCIAL") {
      notifs = notifs.where((n) => n.type == "FINANCIAL" || n.type == "PAYOUT" || n.title.toLowerCase().contains("payout")).toList();
    } else if (_notifFilter == "SYSTEM") {
      notifs = notifs.where((n) => n.type == "SYSTEM" || n.type == "COMPLIANCE").toList();
    }

    final totalAlerts = data?.notifications.length ?? 0;
    final unreadCount = data?.notifications.where((n) => !n.isRead).length ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 10.A Header with Mark All Read & Clear All
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Notifications & Announcements", style: AppFontStyle.fontStyleW700(fontSize: 17, fontColor: const Color(0xFF0F172A))),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      for (var n in data?.notifications ?? []) {
                        n.isRead = true;
                      }
                      setState(() {});
                      Get.snackbar("Marked as Read", "All alerts marked as read.", backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
                    },
                    child: const Text("Mark All Read", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 10.B Notification Stats
          Row(
            children: [
              Expanded(child: _buildMiniStatTile("Total Alerts", "$totalAlerts", Icons.notifications, const Color(0xFF2563EB))),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniStatTile("Unread Notices", "$unreadCount", Icons.mark_email_unread, const Color(0xFFEF4444))),
            ],
          ),
          const SizedBox(height: 12),

          // Search Notifications
          Container(
            height: 38,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: TextField(
              onChanged: (v) => setState(() => _notifSearchQuery = v),
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                hintText: "Search notifications...",
                prefixIcon: Icon(Icons.search, size: 16, color: Color(0xFF64748B)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 10.C Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildNotifFilterChip("ALL", "All ($totalAlerts)"),
                _buildNotifFilterChip("UNREAD", "Unread ($unreadCount)"),
                _buildNotifFilterChip("EVENTS", "Events"),
                _buildNotifFilterChip("FINANCIAL", "Financial & Payouts"),
                _buildNotifFilterChip("SYSTEM", "System & Security"),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (notifs.isEmpty)
            _buildEmptyState(icon: Icons.notifications_off_outlined, title: "No Notifications", subtitle: "You are all caught up!")
          else
            ...notifs.map((n) => _buildFullNotificationCard(n)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNotifFilterChip(String value, String label) {
    final isSelected = _notifFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF2563EB),
        labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.bold),
        onSelected: (val) {
          if (val) setState(() => _notifFilter = value);
        },
      ),
    );
  }

  Widget _buildFullNotificationCard(EcosystemNotificationItem n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: n.isRead ? Colors.white : const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: n.isRead ? const Color(0xFFE2E8F0) : const Color(0xFFBAE6FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(4)),
                child: Text(n.type, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF3730A3))),
              ),
              Text(n.createdAt, style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 6),
          Text(n.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: n.isRead ? const Color(0xFF0F172A) : const Color(0xFF0369A1))),
          const SizedBox(height: 3),
          Text(n.message, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
          const Divider(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!n.isRead)
                TextButton(
                  onPressed: () => setState(() => n.isRead = true),
                  child: const Text("Mark Read", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),

            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SECTION 11: ORGANIZER PROFILE MODULE (/organizer/profile)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage8OrganizerProfile(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    final totalEvents = data?.totalEvents ?? 0;
    final gross = data?.grossRevenue ?? 0.0;
    final attendees = data?.attendees.length ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 11.A Profile Header with Save Changes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Organizer Profile", style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: const Color(0xFF0F172A))),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.save, size: 15),
                label: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                onPressed: () => _saveProfile(controller),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 11.B Organizer Information Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final img = await picker.pickImage(source: ImageSource.gallery);
                    if (img != null) setState(() => _profileImagePath = img.path);
                  },
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF2563EB),
                    backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
                    child: _profileImagePath == null
                        ? Text(
                            (data?.organizationName.isNotEmpty ?? false) ? data!.organizationName[0].toUpperCase() : "O",
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          )
                        : null,
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
                              _orgNameCtrl.text.isNotEmpty ? _orgNameCtrl.text : (data?.organizationName ?? "Official Organizer"),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4)),
                            child: const Text("VERIFIED", style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                          ),
                        ],
                      ),
                      Text("Ref: ${data?.referenceId ?? 'ORG-FOUNDATION-9281'}", style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                      Text(_orgEmailCtrl.text.isNotEmpty ? _orgEmailCtrl.text : "organizer@notisboard.org", style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 11.C Profile Statistics
          Row(
            children: [
              Expanded(child: _buildMiniStatTile("Total Events", "$totalEvents", Icons.event, const Color(0xFF2563EB))),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniStatTile("Platform Rate", "10.0%", Icons.percent, const Color(0xFFF59E0B))),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniStatTile("Gross Sales", controller.formatCurrency(gross), Icons.sell, const Color(0xFF10B981))),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniStatTile("Supporters", "$attendees", Icons.people, const Color(0xFF8B5CF6))),
            ],
          ),
          const SizedBox(height: 16),

          // 11.D Organization & Brand Details
          _buildFormSection(
            title: "Organization & Brand Details",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormLabel("Organization / Stage Name *"),
                TextField(controller: _orgNameCtrl, decoration: _buildInputDec("Official Organization Name")),
                const SizedBox(height: 10),
                _buildFormLabel("Organization Category"),
                TextField(controller: _orgTypeCtrl, decoration: _buildInputDec("e.g. Registered Non-Profit / Charity Event Host")),
                const SizedBox(height: 10),
                _buildFormLabel("Official Website"),
                TextField(controller: _orgWebsiteCtrl, decoration: _buildInputDec("https://yourorganization.org")),
                const SizedBox(height: 10),
                _buildFormLabel("About Your Organization & Mission"),
                TextField(controller: _orgDescCtrl, maxLines: 3, decoration: _buildInputDec("Mission statement, background, community impact...")),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 11.G Contact Information
          _buildFormSection(
            title: "Contact Information",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormLabel("Primary Email *"),
                TextField(controller: _orgEmailCtrl, decoration: _buildInputDec("contact@yourorganization.org")),
                const SizedBox(height: 10),
                _buildFormLabel("Phone Number"),
                TextField(controller: _orgPhoneCtrl, decoration: _buildInputDec("+1 (555) 000-0000")),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 11.E Social Links
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _saveProfile(EcosystemController controller) async {
    final ok = await controller.saveOrganizerProfile({
      "organizationName": _orgNameCtrl.text.trim(),
      "organizationType": _orgTypeCtrl.text.trim(),
      "description": _orgDescCtrl.text.trim(),
      "website": _orgWebsiteCtrl.text.trim(),
      "email": _orgEmailCtrl.text.trim(),
      "phone": _orgPhoneCtrl.text.trim(),
      "socialLinks": {
        "facebook": _fbCtrl.text.trim(),
        "twitter": _twCtrl.text.trim(),
        "instagram": _igCtrl.text.trim(),
        "linkedin": _liCtrl.text.trim(),
      },
    });
    if (ok) {
      Get.snackbar("Profile Saved", "Organizer profile updated successfully.", backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
    }
  }

  // ══════════════════════════════════════════════════════════════
  // SECTION 12: ORGANIZER SETTINGS MODULE (/organizer/settings)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPage9OrganizerSettings(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Organizer Settings", style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: const Color(0xFF0F172A))),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.save, size: 15),
                label: const Text("Save Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                onPressed: () => _saveSettings(controller),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 12.A Settings Tabs (Payout & Banking, Event Defaults, Notifications, Security & Access)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSettingsTabBtn("Payout & Banking", 0),
                  _buildSettingsTabBtn("Event Defaults", 1),
                  _buildSettingsTabBtn("Notifications", 2),
                  _buildSettingsTabBtn("Security & Access", 3),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_settingsTab == 0) ...[
            // 12.B, 12.C, 12.D, 12.E: Financial Payout Account
            _buildFormSection(
              title: "Financial Payout Account",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Color(0xFF059669)),
                        SizedBox(width: 8),
                        Text("Automatic Net Settlement Active (0–5 Days Post-Event)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildFormLabel("Payout Method"),
                  DropdownButtonFormField<String>(
                    value: _payoutMethod,
                    decoration: _buildInputDec(""),
                    items: const [
                      DropdownMenuItem(value: "Direct Bank Wire / Local Transfer", child: Text("Direct Bank Wire / Local Transfer")),
                      DropdownMenuItem(value: "Stripe Connect", child: Text("Stripe Connect")),
                      DropdownMenuItem(value: "PayPal Merchant Settlement", child: Text("PayPal Merchant Settlement")),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _payoutMethod = v);
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildFormLabel("Payout Settlement Schedule"),
                  DropdownButtonFormField<String>(
                    value: _settlementSchedule,
                    decoration: _buildInputDec(""),
                    items: const [
                      DropdownMenuItem(value: "Weekly Auto-Settlement (Recommended)", child: Text("Weekly Auto-Settlement (Recommended)")),
                      DropdownMenuItem(value: "Bi-Weekly Settlement", child: Text("Bi-Weekly Settlement")),
                      DropdownMenuItem(value: "Monthly Settlement", child: Text("Monthly Settlement")),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _settlementSchedule = v);
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildFormLabel("Bank / Institution Name"),
                  TextField(controller: _bankNameCtrl, decoration: _buildInputDec("e.g. Royal Bank of Canada")),
                  const SizedBox(height: 12),

                  _buildFormLabel("Legal Beneficiary / Account Name"),
                  TextField(controller: _accountHolderCtrl, decoration: _buildInputDec("Official Account Holder Legal Name")),
                  const SizedBox(height: 12),

                  _buildFormLabel("Account Number / IBAN"),
                  TextField(controller: _accountNumberCtrl, decoration: _buildInputDec("Bank Account Number or IBAN")),
                  const SizedBox(height: 12),

                  _buildFormLabel("Routing / SWIFT / BIC Code"),
                  TextField(controller: _routingNumberCtrl, decoration: _buildInputDec("Routing transit code or SWIFT")),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 12.F Financial Processing Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: const Row(
                children: [
                  Icon(Icons.lock, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Secure Banking: All bank parameters are encrypted and used solely for direct deposit of net event ticket revenues.",
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_settingsTab == 1) ...[
            // Event Defaults Tab
            _buildFormSection(
              title: "Event Defaults & Check-In",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormLabel("Default Check-In Window"),
                  DropdownButtonFormField<int>(
                    initialValue: _defaultCheckInWindow,
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

                  _buildFormLabel("Default Timezone"),
                  DropdownButtonFormField<String>(
                    value: _defaultTimezone,
                    decoration: _buildInputDec(""),
                    items: _timezoneOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _defaultTimezone = v);
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildFormLabel("Default Ticket Refund Policy"),
                  DropdownButtonFormField<String>(
                    value: _defaultRefundPolicy,
                    decoration: _buildInputDec(""),
                    items: const [
                      DropdownMenuItem(value: "30-Day Policy", child: Text("30-Day Charitable Return Policy")),
                      DropdownMenuItem(value: "No Refunds", child: Text("Strictly Non-Refundable / Donation")),
                      DropdownMenuItem(value: "7-Day Policy", child: Text("7-Day Prior Cancellation Only")),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _defaultRefundPolicy = v);
                    },
                  ),
                ],
              ),
            ),
          ] else if (_settingsTab == 2) ...[
            // Notifications Tab
            _buildFormSection(
              title: "Notification Preferences",
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("Ticket Sale Alerts", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    subtitle: const Text("Receive instant push & email alerts when an attendee purchases a ticket", style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                    value: _notifyTicketSold,
                    activeThumbColor: const Color(0xFF2563EB),
                    onChanged: (v) => setState(() => _notifyTicketSold = v),
                  ),
                  SwitchListTile(
                    title: const Text("Gate Check-In Updates", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    subtitle: const Text("Real-time attendee check-in notifications", style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                    value: _notifyCheckIn,
                    activeThumbColor: const Color(0xFF2563EB),
                    onChanged: (v) => setState(() => _notifyCheckIn = v),
                  ),
                  SwitchListTile(
                    title: const Text("Payout & Settlement Disbursed", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    subtitle: const Text("Get notified when funds are released and wired to your bank", style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                    value: _notifyPayout,
                    activeThumbColor: const Color(0xFF2563EB),
                    onChanged: (v) => setState(() => _notifyPayout = v),
                  ),
                ],
              ),
            ),
          ] else if (_settingsTab == 3) ...[
            // Security & Access Tab
            _buildFormSection(
              title: "Security & Access",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text("Two-Factor Authentication (2FA)", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    subtitle: const Text("Require verification code on organizer portal logins", style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                    value: _settings2fa,
                    activeThumbColor: const Color(0xFF2563EB),
                    onChanged: (v) => setState(() => _settings2fa = v),
                  ),
                  const Divider(),
                  const ListTile(
                    dense: true,
                    leading: Icon(Icons.devices, size: 20),
                    title: Text("Active Device Session", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    subtitle: Text("Current Mobile Session • Foundation Token Authenticated", style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsTabBtn(String title, int index) {
    final isSelected = _settingsTab == index;
    return GestureDetector(
      onTap: () => setState(() => _settingsTab = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Future<void> _saveSettings(EcosystemController controller) async {
    final ok = await controller.saveOrganizerSettings({
      "payoutMethod": _payoutMethod,
      "settlementSchedule": _settlementSchedule,
      "bankName": _bankNameCtrl.text.trim(),
      "accountHolder": _accountHolderCtrl.text.trim(),
      "accountNumber": _accountNumberCtrl.text.trim(),
      "routingNumber": _routingNumberCtrl.text.trim(),
      "defaultCheckInWindow": _defaultCheckInWindow,
      "defaultRefundPolicy": _defaultRefundPolicy,
      "notifyRegistrationAlert": _notifyTicketSold,
      "notifyEventReminder": _notifyCheckIn,
      "notifyDonationAlert": _notifyPayout,
    });
    if (ok) {
      Get.snackbar("Settings Saved", "Organizer preferences and settlement account updated.",
          backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
    }
  }

  // ══════════════════════════════════════════════════════════════
  // MODALS: GLOBAL SEARCH, PREVIEW, ROSTER, DELETE CONFIRMATION
  // ══════════════════════════════════════════════════════════════
  void _showGlobalSearchModal(
    BuildContext context,
    EcosystemController controller,
    OrganizerPortalData? data,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final events = data?.events ?? controller.events;
            final attendees = data?.attendees ?? [];
            final campaigns = data?.campaigns ?? controller.campaigns;

            final q = _globalSearchQuery.toLowerCase();
            final matchedEvents = q.isEmpty
                ? <EcosystemEvent>[]
                : events.where((e) => e.title.toLowerCase().contains(q) || (e.venue?.toLowerCase().contains(q) ?? false)).toList();
            final matchedAttendees = q.isEmpty
                ? <EcosystemAttendee>[]
                : attendees.where((a) => "${a.firstName} ${a.lastName}".toLowerCase().contains(q) || a.ticketNumber.toLowerCase().contains(q)).toList();
            final matchedCampaigns = q.isEmpty
                ? <EcosystemCampaign>[]
                : campaigns.where((c) => c.title.toLowerCase().contains(q)).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: "Search events, tickets, attendees, campaigns...",
                            prefixIcon: const Icon(Icons.search, size: 18),
                            suffixIcon: _globalSearchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () => setModalState(() => _globalSearchQuery = ""),
                                  )
                                : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onChanged: (v) => setModalState(() => _globalSearchQuery = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(onPressed: () => Get.back(), child: const Text("Close")),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (q.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text("Type any keyword or ticket number to search across the portal...", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView(
                        children: [
                          if (matchedEvents.isNotEmpty) ...[
                            Text("EVENTS (${matchedEvents.length})", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                            ...matchedEvents.map((e) => ListTile(
                                  dense: true,
                                  title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  subtitle: Text(e.venue ?? "Venue TBD", style: const TextStyle(fontSize: 10)),
                                  trailing: Text(controller.formatCurrency(e.priceFrom), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  onTap: () {
                                    Get.back();
                                    _initEventFormForEdit(e);
                                    _navigateToPage(3);
                                  },
                                )),
                            const Divider(),
                          ],
                          if (matchedAttendees.isNotEmpty) ...[
                            Text("ATTENDEES (${matchedAttendees.length})", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                            ...matchedAttendees.map((a) => ListTile(
                                  dense: true,
                                  title: Text("${a.firstName} ${a.lastName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  subtitle: Text("Ticket #${a.ticketNumber} • ${a.eventTitle}", style: const TextStyle(fontSize: 10)),
                                  trailing: Icon(a.checkedIn ? Icons.check_circle : Icons.circle_outlined, size: 16, color: a.checkedIn ? Colors.green : Colors.grey),
                                )),
                            const Divider(),
                          ],
                          if (matchedCampaigns.isNotEmpty) ...[
                            Text("CAMPAIGNS (${matchedCampaigns.length})", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6))),
                            ...matchedCampaigns.map((c) => ListTile(
                                  dense: true,
                                  title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  subtitle: Text("${controller.formatCurrency(c.raisedAmount)} raised of ${controller.formatCurrency(c.goalAmount)}", style: const TextStyle(fontSize: 10)),
                                  onTap: () {
                                    Get.back();
                                    _navigateToPage(4);
                                  },
                                )),
                          ],
                          if (matchedEvents.isEmpty && matchedAttendees.isEmpty && matchedCampaigns.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Center(child: Text("No records found matching your query.", style: TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 4.A Event Preview Modal
  void _showCurrentEventFormPreview(BuildContext context, EcosystemController controller) {
    final previewEvent = EcosystemEvent(
      id: _editingEventId ?? "PREVIEW",
      title: _eventTitleCtrl.text.isNotEmpty ? _eventTitleCtrl.text : "Untitled Event",
      description: _eventDescCtrl.text.isNotEmpty ? _eventDescCtrl.text : "Event description preview...",
      venue: _eventIsOnline ? "Virtual Online Event" : (_eventVenueCtrl.text.isNotEmpty ? _eventVenueCtrl.text : "Venue TBD"),
      city: _eventCityCtrl.text.isNotEmpty ? _eventCityCtrl.text : "City",
      country: _eventCountryCtrl.text.isNotEmpty ? _eventCountryCtrl.text : "Country",
      priceFrom: _eventTickets.isNotEmpty ? _eventTickets.map((t) => t.price).reduce((a, b) => a < b ? a : b) : 0.0,
      startDateTime: _eventStartDate.toIso8601String(),
      endDateTime: _eventEndDate.toIso8601String(),
      isOnline: _eventIsOnline,
      maxAttendees: int.tryParse(_eventMaxAttendeesCtrl.text) ?? 100,
      category: _eventCategory,
      status: "DRAFT",
      featuredImage: _eventExistingImageUrl,
      tickets: _eventTickets,
      timezone: _eventTimezone,
      checkInWindowMinutes: _eventCheckInWindow,
      metaTitle: _eventMetaTitleCtrl.text,
      metaDescription: _eventMetaDescCtrl.text,
    );
    _showEventPreviewModal(context, controller, previewEvent, localImagePath: _eventImagePath);
  }

  void _showEventPreviewModal(BuildContext context, EcosystemController controller, EcosystemEvent event, {String? localImagePath}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final dt = DateTime.tryParse(event.startDateTime);
        final fmtDate = dt != null ? DateFormat("EEEE, MMMM d, yyyy • h:mm a").format(dt) : event.startDateTime;
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Public Event Preview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    color: const Color(0xFFF1F5F9),
                    child: localImagePath != null
                        ? Image.file(File(localImagePath), fit: BoxFit.cover)
                        : (event.featuredImage != null && event.featuredImage!.isNotEmpty
                            ? Image.network(event.featuredImage!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.event, size: 40))
                            : const Icon(Icons.event, size: 40)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                      child: Text(event.category ?? "Official Event", style: const TextStyle(color: Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(event.timezone != null ? "Timezone: ${event.timezone}" : "UTC", style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 6),
                Text(event.title, style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: const Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    Text(fmtDate, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      event.isOnline ? "Virtual Online Event (Link shared after registration)" : "${event.venue ?? 'Venue TBD'}, ${event.city ?? ''}",
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const Divider(height: 20),
                const Text("About This Event", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(event.description ?? "No description provided.", style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569))),
                const SizedBox(height: 16),
                const Text("Available Ticket Tiers", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                if (event.tickets.isEmpty)
                  Text("General Admission: ${controller.formatCurrency(event.priceFrom)}", style: const TextStyle(fontSize: 11))
                else
                  ...event.tickets.map((t) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                if (t.description != null && t.description!.isNotEmpty)
                                  Text(t.description!, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                              ],
                            ),
                            Text(
                              t.price == 0.0 ? "FREE" : controller.formatCurrency(t.price),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF059669)),
                            ),
                          ],
                        ),
                      )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SECTION 10: TICKET BUYERS & ATTENDEES ROSTER MODAL
  // 100% Exact Parity with Foundation Website /organizer/events Roster
  // ══════════════════════════════════════════════════════════════
  void _showAttendeeRosterModal(
    BuildContext context,
    EcosystemController controller,
    EcosystemEvent event,
    List<EcosystemAttendee> attendees,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String rosterFilter = "ALL"; // ALL, CONFIRMED, CHECKED_IN, PENDING
        String searchQuery = "";

        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            // Metrics Calculations matching Website
            final totalBuyers = attendees.map((a) => a.email.toLowerCase().trim()).toSet().length;
            final totalSold = attendees.fold<int>(0, (acc, a) => acc + (a.quantity > 0 ? a.quantity : 1));
            final grossSales = attendees.fold<double>(0.0, (acc, a) => acc + a.totalAmount);
            final platformFee = grossSales * 0.04;
            final netPayout = grossSales - platformFee;
            final checkedInCount = attendees.where((a) => a.checkedIn).length;
            final confirmedCount = attendees.where((a) => a.status.toUpperCase() == "CONFIRMED" || a.checkedIn).length;
            final pendingCount = attendees.where((a) => a.status.toUpperCase() == "PENDING").length;

            // Formatted Date matching Website Subtitle
            String eventDateStr = "";
            try {
              if (event.startDateTime.isNotEmpty) {
                final dt = DateTime.parse(event.startDateTime);
                eventDateStr = DateFormat("EEE, MMM d, yyyy").format(dt);
              }
            } catch (_) {
              eventDateStr = event.startDateTime;
            }

            // Attendees Filtering
            var filtered = attendees.where((a) {
              if (rosterFilter == "CONFIRMED" && (!a.checkedIn && a.status.toUpperCase() != "CONFIRMED")) return false;
              if (rosterFilter == "CHECKED_IN" && !a.checkedIn) return false;
              if (rosterFilter == "PENDING" && a.status.toUpperCase() != "PENDING") return false;
              if (searchQuery.isNotEmpty) {
                final q = searchQuery.toLowerCase();
                final matchName = "${a.firstName} ${a.lastName}".toLowerCase().contains(q);
                final matchEmail = a.email.toLowerCase().contains(q);
                final matchTicket = a.ticketNumber.toLowerCase().contains(q);
                final matchPhone = a.phone.toLowerCase().contains(q);
                if (!matchName && !matchEmail && !matchTicket && !matchPhone) return false;
              }
              return true;
            }).toList();

            // Strict Check-in Window Calculation
            final windowMins = event.checkInWindowMinutes;
            final isCheckInOpen = event.isCheckInOpen;
            final openTime = event.checkInOpensAt;
            final openTimeStr = DateFormat("hh:mm a").format(openTime);

            return Container(
              height: MediaQuery.of(context).size.height * 0.92,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                  ),

                  // Header (Matches Screenshot 10)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.confirmation_number_outlined, color: Color(0xFF4F46E5), size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      "Ticket Buyers & Attendees Roster",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: const Text("Organizer Roster", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${event.title} • $eventDateStr",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.qr_code_scanner_rounded, size: 14),
                              label: const Text("Scan QR Pass", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                _showQrFastScannerModal(context, controller, event);
                              },
                            ),
                            const SizedBox(width: 6),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF334155),
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.download_rounded, size: 14),
                              label: const Text("Export CSV", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                final buffer = StringBuffer();
                                buffer.writeln("Name,Email,Phone,TicketNumber,Tier,Quantity,Amount,Date,Status,CheckedIn");
                                for (final a in attendees) {
                                  buffer.writeln('"${a.firstName} ${a.lastName}","${a.email}","${a.phone}","${a.ticketNumber}","${a.ticketName}",${a.quantity},${a.totalAmount},"${a.createdAt}","${a.status}",${a.checkedIn}');
                                }
                                Clipboard.setData(ClipboardData(text: buffer.toString()));
                                Utils.showToast(context, "Attendee roster exported! CSV data copied to clipboard.");
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                              onPressed: () => Get.back(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 6 Metric Summary Cards (Matches Screenshot 10)
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.6,
                            children: [
                              _buildRosterMetricCard("TOTAL BUYERS", "$totalBuyers", const Color(0xFF0F172A)),
                              _buildRosterMetricCard("TICKETS SOLD", "$totalSold", const Color(0xFF0F172A)),
                              _buildRosterMetricCard("GROSS SALES", controller.formatCurrency(grossSales), const Color(0xFF0F172A)),
                              _buildRosterMetricCard("PLATFORM FEE (4.0%)", "-${controller.formatCurrency(platformFee)}", const Color(0xFFDC2626)),
                              _buildRosterMetricCard("YOUR NET PAYOUT", controller.formatCurrency(netPayout), const Color(0xFF10B981)),
                              _buildRosterMetricCard("CHECKED IN", "$checkedInCount / $totalSold", const Color(0xFF0F172A)),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Settlement Formula Banner (Matches Screenshot 10)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFBBF7D0)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Event Settlement: Total sales ${controller.formatCurrency(grossSales)}. After platform fee (4.0% / -${controller.formatCurrency(platformFee)}), your net earnings are ${controller.formatCurrency(netPayout)}.",
                                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF166534)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Net Payout: ${controller.formatCurrency(netPayout)}",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Filter Tabs (Matches Screenshot 10)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildRosterFilterTab("All (${attendees.length})", "ALL", rosterFilter, (v) => setModalState(() => rosterFilter = v)),
                                const SizedBox(width: 6),
                                _buildRosterFilterTab("Confirmed ($confirmedCount)", "CONFIRMED", rosterFilter, (v) => setModalState(() => rosterFilter = v)),
                                const SizedBox(width: 6),
                                _buildRosterFilterTab("Checked In ($checkedInCount)", "CHECKED_IN", rosterFilter, (v) => setModalState(() => rosterFilter = v)),
                                const SizedBox(width: 6),
                                _buildRosterFilterTab("Pending ($pendingCount)", "PENDING", rosterFilter, (v) => setModalState(() => rosterFilter = v)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Search Bar + Scan QR Code Button (Matches Screenshot 10)
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFCBD5E1)),
                                  ),
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: "Search name, email, phone, or ticket...",
                                      hintStyle: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                                      prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    onChanged: (v) => setModalState(() => searchQuery = v),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.qr_code_scanner, size: 16),
                                label: const Text("Scan QR Code", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  _showQrFastScannerModal(context, controller, event);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Attendee List (Matches Screenshot 10 Table Rows)
                          if (filtered.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              alignment: Alignment.center,
                              child: const Column(
                                children: [
                                  Icon(Icons.people_outline, size: 36, color: Color(0xFF94A3B8)),
                                  SizedBox(height: 8),
                                  Text("No registered attendees found matching filters.", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                ],
                              ),
                            )
                          else
                            ...filtered.map((a) {
                              return _buildAttendeeRowCard(context, controller, event, a, isCheckInOpen, openTimeStr, windowMins, () {
                                setModalState(() {});
                              });
                            }),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Bar (Matches Screenshot 10)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Showing ${filtered.length} total registrations",
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Get.back(),
                          child: const Text("Close Roster", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRosterMetricCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildRosterFilterTab(String label, String value, String current, Function(String) onSelect) {
    final isSelected = value == current;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendeeRowCard(
    BuildContext context,
    EcosystemController controller,
    EcosystemEvent event,
    EcosystemAttendee a,
    bool isCheckInOpen,
    String openTimeStr,
    int windowMins,
    VoidCallback onUpdate,
  ) {
    String initials = "CI";
    if (a.firstName.isNotEmpty && a.lastName.isNotEmpty) {
      initials = "${a.firstName[0]}${a.lastName[0]}".toUpperCase();
    } else if (a.firstName.isNotEmpty) {
      initials = a.firstName.substring(0, a.firstName.length >= 2 ? 2 : 1).toUpperCase();
    }

    final isAdmitted = a.checkedIn;
    final isCancelled = a.status.toUpperCase() == "CANCELLED";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Avatar, Name, Email, Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF0F172A),
                child: Text(
                  initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${a.firstName} ${a.lastName}".trim().isNotEmpty ? "${a.firstName} ${a.lastName}".trim() : "Attendee",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      a.email,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAdmitted
                      ? const Color(0xFFEDE9FE)
                      : (isCancelled ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isAdmitted
                      ? "✓ CHECKED IN"
                      : (isCancelled ? "CANCELLED" : "✓ CONFIRMED"),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isAdmitted
                        ? const Color(0xFF7C3AED)
                        : (isCancelled ? const Color(0xFFDC2626) : const Color(0xFF16A34A)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Ticket Number with Copy Button & Contact
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          a.ticketNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10.5, fontFamily: "monospace", color: Color(0xFF334155)),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: a.ticketNumber));
                          Utils.showToast(context, "Ticket ID copied!");
                        },
                        child: const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF2563EB)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (a.phone.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 3),
                    Text(a.phone, style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569))),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Row 3: Tier, Qty, Amount, Purchase Date
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.ticketName.isNotEmpty ? a.ticketName : "General Admission",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      "${controller.formatCurrency(a.ticketPrice)} / ticket",
                      style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                Text("${a.quantity}x", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                Text(
                  controller.formatCurrency(a.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF0F172A)),
                ),
                if (a.createdAt != null && a.createdAt!.isNotEmpty) ...[
                  Text(
                    a.createdAt!.length > 10 ? a.createdAt!.substring(0, 10) : a.createdAt!,
                    style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Row 4: Exact Action Buttons (Matches Screenshot 10 & Website Logic)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isAdmitted) ...[
                // Checked in -> Purple Admitted Button (allows revoking)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 15),
                  label: const Text("✓ Admitted", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                  onPressed: () async {
                    Get.defaultDialog(
                      title: "Revoke Check-In",
                      content: Text("Are you sure you want to revoke check-in for ${a.firstName} ${a.lastName}?",
                          textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                      textConfirm: "Revoke",
                      confirmTextColor: Colors.white,
                      buttonColor: const Color(0xFFDC2626),
                      textCancel: "Cancel",
                      onConfirm: () async {
                        Get.back();
                        a.checkedIn = false;
                        onUpdate();
                        await controller.checkInAttendee(a.id, false);
                      },
                    );
                  },
                ),
              ] else if (isCheckInOpen) ...[
                // Check-in Window Open -> Active Green Check In Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.confirmation_number_outlined, size: 15),
                  label: const Text("Check In", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                  onPressed: () async {
                    a.checkedIn = true;
                    onUpdate();
                    final res = await controller.checkInAttendee(a.id, true);
                    if (res["success"] != true) {
                      a.checkedIn = false;
                      onUpdate();
                    }
                  },
                ),
              ] else ...[
                // Check-in Window Locked -> Grey Button with Clock Icon "Opens [Time]"
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E8F0),
                    foregroundColor: const Color(0xFF64748B),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF64748B)),
                  label: Text("Opens $openTimeStr", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF64748B))),
                  onPressed: () {
                    Utils.showToast(
                      context,
                      "Check-in is not open yet. Check-in opens $windowMins minutes before the event (at $openTimeStr).",
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SECTION 11: QR FAST CHECK-IN LIVE SCANNER MODAL
  // ══════════════════════════════════════════════════════════════
  void _showQrFastScannerModal(
    BuildContext context,
    EcosystemController controller,
    EcosystemEvent event,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OrganizerQrLiveScannerSheet(
        controller: controller,
        event: event,
        buildResultBanner: _buildQrScanResultBanner,
      ),
    );
  }

  Widget _buildQrScanResultBanner(
    BuildContext context,
    EcosystemController controller,
    EcosystemEvent event,
    Map<String, dynamic> res,
    VoidCallback onRefresh,
  ) {
    final data = (res["data"] is Map<String, dynamic>) ? res["data"] as Map<String, dynamic> : res;
    final success = res["success"] == true || data["success"] == true;
    final isAlready = res["alreadyCheckedIn"] == true || data["alreadyCheckedIn"] == true;
    final isWrongEvent = res["wrongEvent"] == true || data["wrongEvent"] == true;
    final isWindowNotOpen = res["windowNotOpen"] == true || data["windowNotOpen"] == true;
    final isCancelled = res["isCancelled"] == true || data["isCancelled"] == true;
    final message = res["message"]?.toString() ?? data["message"]?.toString() ?? res["error"]?.toString() ?? data["error"]?.toString() ?? "";
    final reg = data["registration"] ?? res["registration"];
    final attendee = data["attendee"] ?? res["attendee"];

    Color bgColor = const Color(0xFFF0FDF4);
    Color borderColor = const Color(0xFFBBF7D0);
    Color textColor = const Color(0xFF166534);
    IconData icon = Icons.check_circle_rounded;
    String headerTitle = "✓ Valid Pass - Attendee Admitted!";

    if (isWrongEvent) {
      bgColor = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFFECACA);
      textColor = const Color(0xFF991B1B);
      icon = Icons.error_outline_rounded;
      headerTitle = "Wrong Event Pass!";
    } else if (isCancelled) {
      bgColor = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFFECACA);
      textColor = const Color(0xFF991B1B);
      icon = Icons.cancel_outlined;
      headerTitle = "Admission Denied!";
    } else if (isAlready) {
      bgColor = const Color(0xFFFFFBEB);
      borderColor = const Color(0xFFFDE68A);
      textColor = const Color(0xFF92400E);
      icon = Icons.info_outline_rounded;
      headerTitle = "Already Checked In";
    } else if (isWindowNotOpen) {
      bgColor = const Color(0xFFFEF9C3);
      borderColor = const Color(0xFFFEF08A);
      textColor = const Color(0xFF854D0E);
      icon = Icons.access_time_rounded;
      headerTitle = "Check-In Window Not Open";
    } else if (!success) {
      bgColor = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFFECACA);
      textColor = const Color(0xFF991B1B);
      icon = Icons.error_outline_rounded;
      headerTitle = "Verification Failed";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  headerTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(message, style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.9))),
          if (reg != null || attendee != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF0F172A),
                    child: Text(
                      ((attendee?["name"] ?? reg?["firstName"] ?? "A").toString().trim().isNotEmpty)
                          ? (attendee?["name"] ?? reg?["firstName"] ?? "A").toString().trim()[0].toUpperCase()
                          : "A",
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (attendee?["name"] ?? "${reg?["firstName"] ?? ""} ${reg?["lastName"] ?? ""}").toString().trim(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                        Text(
                          "${attendee?["email"] ?? reg?["email"] ?? ""} • ${attendee?["ticketTier"] ?? reg?["ticket"]?["name"] ?? "General Pass"} #${attendee?["reference"] ?? reg?["paymentId"] ?? reg?["id"] ?? ""}",
                          style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isWindowNotOpen && reg != null) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final overrideRes = await controller.verifyTicketQr(
                  eventId: event.id,
                  code: (reg["paymentId"] ?? reg["id"]).toString(),
                  autoCheckIn: true,
                  forceOverride: true,
                );
                res.clear();
                res.addAll(overrideRes);
                onRefresh();
              },
              child: const Text("Override & Force Admit", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  // Delete Event Confirmation
  void _confirmDeleteEvent(BuildContext context, EcosystemController controller, EcosystemEvent event) {
    Get.defaultDialog(
      title: "Delete Event",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFDC2626)),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text("Are you sure you want to permanently delete \"${event.title}\"? This action cannot be undone.",
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      ),
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFDC2626),
      textCancel: "Cancel",
      onConfirm: () async {
        Get.back();
        await controller.removeEvent(event.id);
      },
    );
  }

  // Common UI Helpers
  Widget _buildFormSection({required String title, required Widget child}) {
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
          Text(title, style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A))),
          const Divider(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF334155))),
    );
  }

  InputDecoration _buildInputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? buttonLabel,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
            child: Icon(icon, size: 32, color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          if (buttonLabel != null && onTap != null) ...[
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: onTap,
              child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrganizerQrLiveScannerSheet extends StatefulWidget {
  final EcosystemController controller;
  final EcosystemEvent event;
  final Widget Function(
    BuildContext context,
    EcosystemController controller,
    EcosystemEvent event,
    Map<String, dynamic> res,
    VoidCallback onRefresh,
  ) buildResultBanner;

  const _OrganizerQrLiveScannerSheet({
    required this.controller,
    required this.event,
    required this.buildResultBanner,
  });

  @override
  State<_OrganizerQrLiveScannerSheet> createState() => _OrganizerQrLiveScannerSheetState();
}

class _OrganizerQrLiveScannerSheetState extends State<_OrganizerQrLiveScannerSheet> {
  late final MobileScannerController _scannerController;
  final TextEditingController _codeCtrl = TextEditingController();
  bool _autoConfirm = true;
  bool _isProcessing = false;
  int _sessionScanned = 0;
  Map<String, dynamic>? _scanResult;
  String? _lastScannedCode;
  DateTime? _lastScannedTime;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      returnImage: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  String _extractTicketCode(String raw) {
    String text = raw.trim();
    if (text.isEmpty) return text;

    // 1. If it's a ticket-pass URL (e.g. https://.../ticket-pass/XYZ?print=true)
    if (text.contains("/ticket-pass/")) {
      final parts = text.split("/ticket-pass/");
      if (parts.length > 1) {
        String slug = parts[1].split("?").first.split("#").first.split("/").first.trim();
        if (slug.isNotEmpty) return Uri.decodeComponent(slug);
      }
    }

    // 2. If it's any http/https URL, check params or last path segment
    if (text.startsWith("http://") || text.startsWith("https://")) {
      try {
        final uri = Uri.parse(text);
        if (uri.queryParameters.containsKey("pass")) {
          return uri.queryParameters["pass"]!.trim();
        }
        if (uri.queryParameters.containsKey("id")) {
          return uri.queryParameters["id"]!.trim();
        }
        if (uri.queryParameters.containsKey("ticket")) {
          return uri.queryParameters["ticket"]!.trim();
        }
        if (uri.queryParameters.containsKey("ref")) {
          return uri.queryParameters["ref"]!.trim();
        }
        final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
        if (segments.isNotEmpty) {
          return Uri.decodeComponent(segments.last).trim();
        }
      } catch (_) {}
    }

    return text;
  }

  Future<void> _handleVerification(String rawCode) async {
    final cleanCode = _extractTicketCode(rawCode);
    if (cleanCode.isEmpty || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final res = await widget.controller.verifyTicketQr(
        eventId: widget.event.id,
        code: cleanCode,
        autoCheckIn: _autoConfirm,
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _scanResult = res;
          if (res["success"] == true) {
            _sessionScanned++;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _scanResult = {"success": false, "message": "$e"};
        });
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue ?? barcodes.first.displayValue;
    if (code == null || code.trim().isEmpty) return;

    final now = DateTime.now();
    if (_lastScannedCode == code &&
        _lastScannedTime != null &&
        now.difference(_lastScannedTime!).inSeconds < 3) {
      return; // prevent duplicate rapid scans
    }

    _lastScannedCode = code;
    _lastScannedTime = now;
    HapticFeedback.mediumImpact();
    _handleVerification(code);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF16A34A), size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "QR Fast Check-In",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "LIVE CAMERA",
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${widget.event.title} • Fast Attendee Scanner",
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "⚡ Auto",
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    Switch(
                      value: _autoConfirm,
                      activeThumbColor: const Color(0xFF10B981),
                      onChanged: (v) => setState(() => _autoConfirm = v),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Viewfinder Box with Live Camera Preview
                  Container(
                    height: 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155), width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Live Camera Feed
                          MobileScanner(
                            controller: _scannerController,
                            onDetect: _onDetect,
                            errorBuilder: (ctx, err) => Container(
                              color: const Color(0xFF0F172A),
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 36),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Camera unavailable: ${err.errorCode.name}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Targeting Frame Overlay
                          Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _isProcessing ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),

                          // Top-right controls: Torch & Camera flip
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ValueListenableBuilder<MobileScannerState>(
                                  valueListenable: _scannerController,
                                  builder: (ctx, state, _) {
                                    final isOn = state.torchState == TorchState.on;
                                    return InkWell(
                                      onTap: () => _scannerController.toggleTorch(),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: isOn ? const Color(0xFFF59E0B) : Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isOn ? Icons.flash_on : Icons.flash_off,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _scannerController.switchCamera(),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.flip_camera_ios_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bottom Status / Instruction
                          Positioned(
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: _isProcessing
                                  ? const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Verifying pass...",
                                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  : const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.qr_code_scanner, color: Color(0xFF10B981), size: 14),
                                        SizedBox(width: 6),
                                        Text(
                                          "Point camera at attendee ticket QR code",
                                          style: TextStyle(color: Colors.white70, fontSize: 11),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Fallback Manual Code Input
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Manual Pass Lookup",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _codeCtrl,
                                style: const TextStyle(fontSize: 12),
                                decoration: const InputDecoration(
                                  hintText: "Can't scan? Type Ticket Ref / ID (e.g. pi_3Uc...)",
                                  hintStyle: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                onSubmitted: (v) => _handleVerification(v),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _handleVerification(_codeCtrl.text),
                              child: const Text("Verify", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Verification Feedback Result Card
                  if (_scanResult != null) ...[
                    widget.buildResultBanner(context, widget.controller, widget.event, _scanResult!, () {
                      setState(() {});
                    }),
                    const SizedBox(height: 14),
                  ],

                  // Session Stats
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Session Statistics",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                        ),
                        Text(
                          "Session Scanned: $_sessionScanned",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
