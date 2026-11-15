import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/host_flow/ecosystem/controllers/ecosystem_controller.dart';
import 'package:notisboard/utils/font_style.dart';

class OrganizerApplicationView extends StatefulWidget {
  const OrganizerApplicationView({super.key});

  @override
  State<OrganizerApplicationView> createState() => _OrganizerApplicationViewState();
}

class _OrganizerApplicationViewState extends State<OrganizerApplicationView> {
  final _formKey = GlobalKey<FormState>();

  String _applicantType = "organization"; // Default to organization as seen in screenshot 1
  bool _agreedToTerms = false;
  bool _obscurePassword = true;

  // 1. Primary Contact Information
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // 2. Organization & Entity Details (Screenshot 1)
  final _organizationNameController = TextEditingController();
  String _organizationType = "Registered Non-Profit / NGO";
  final _websiteController = TextEditingController();

  // 3. Location Information
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  // 4. Password Creation
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final List<String> _organizationTypes = [
    "Registered Non-Profit / NGO",
    "Community Group",
    "Educational Institution",
    "Corporate / Enterprise",
    "Cultural / Religious",
    "Other",
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _organizationNameController.dispose();
    _websiteController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      Get.snackbar(
        "Terms Required",
        "Please agree to the Terms of Service and Event Hosting Policies.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      Get.snackbar(
        "Password Mismatch",
        "Password and Confirm Password must match.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final controller = Get.find<EcosystemController>();
    final isIndividual = _applicantType == "individual";

    final success = await controller.submitOrganizerApplication(
      applicantType: _applicantType,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      country: _countryController.text.trim(),
      organizationName: isIndividual
          ? "${_firstNameController.text.trim()} Events"
          : _organizationNameController.text.trim(),
      organizationType: isIndividual ? "Individual Host" : _organizationType,
      website: isIndividual ? "" : _websiteController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      legalName: "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
      dateOfBirth: "",
      address: _cityController.text.trim(),
      idDocumentType: "Passport",
      taxId: "",
      bankName: "",
      bankAccountName: "",
      bankAccountNumber: "",
      bankRoutingNumber: "",
      documentFilePaths: {},
    );

    if (success && mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIndividual = _applicantType == "individual";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Organizer Account Registration",
          style: AppFontStyle.fontStyleW700(fontSize: 17, fontColor: const Color(0xFF1E293B)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dark Header Container matching website screenshot 1 & 2
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      "Organizer Account Registration",
                      textAlign: TextAlign.center,
                      style: AppFontStyle.fontStyleW700(fontSize: 20, fontColor: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Create your password now. Complete verification in your portal after confirming your email.",
                      textAlign: TextAlign.center,
                      style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 20),

                    // Top Segmented Switcher (Screenshot 1 & 2)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _applicantType = "individual"),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isIndividual ? const Color(0xFF2563EB) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Individual Host",
                                  textAlign: TextAlign.center,
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 13,
                                    fontColor: isIndividual ? Colors.white : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _applicantType = "organization"),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !isIndividual ? const Color(0xFF2563EB) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Organization / Non-profit",
                                  textAlign: TextAlign.center,
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 13,
                                    fontColor: !isIndividual ? Colors.white : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // White Content Card with Form Fields
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. PRIMARY CONTACT INFORMATION
                    _buildSectionHeader("1", "PRIMARY CONTACT INFORMATION"),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _firstNameController,
                            label: "First Name *",
                            hint: "e.g. Eleanor",
                            validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: _lastNameController,
                            label: "Last Name *",
                            hint: "e.g. Vance",
                            validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _emailController,
                      label: "Email Address *",
                      hint: "adsfcxcsd@gmail.in",
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@')) ? "Valid email required" : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _phoneController,
                      label: "Phone Number",
                      hint: "+1 (555) 000-0000",
                      keyboardType: TextInputType.phone,
                    ),

                    if (!isIndividual) ...[
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 16),

                      // 2. ORGANIZATION & ENTITY DETAILS (Screenshot 1)
                      _buildSectionHeader("2", "ORGANIZATION & ENTITY DETAILS"),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _organizationNameController,
                        label: "Organization / Company Name *",
                        hint: "e.g. Hope International Foundation",
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Organization name required" : null,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        label: "Organization Type",
                        value: _organizationType,
                        items: _organizationTypes,
                        onChanged: (val) {
                          if (val != null) setState(() => _organizationType = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _websiteController,
                        label: "Official Website",
                        hint: "https://yourorganization.org",
                      ),
                    ],

                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 16),

                    // 2/3. LOCATION INFORMATION (Screenshot 1 & 2)
                    _buildSectionHeader(isIndividual ? "2" : "3", "LOCATION INFORMATION"),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _cityController,
                            label: "City / Region",
                            hint: "e.g. New York, Toronto, London, Nairobi",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: _countryController,
                            label: "Country",
                            hint: "e.g. United States, Canada, Kenya, etc.",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 16),

                    // 3/4. PASSWORD CREATION (Screenshot 1 & 2)
                    _buildSectionHeader(isIndividual ? "3" : "4", "PASSWORD CREATION"),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _passwordController,
                            label: "Account Password *",
                            hint: "••••••••",
                            obscureText: _obscurePassword,
                            validator: (v) => (v == null || v.length < 6) ? "Min 6 chars" : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: _confirmPasswordController,
                            label: "Confirm Password *",
                            hint: "Repeat your password",
                            obscureText: _obscurePassword,
                            validator: (v) => (v == null || v.isEmpty) ? "Confirm password" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Password strength indicator bar matching screenshot
                    Row(
                      children: [
                        Expanded(child: Container(height: 4, decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(2)))),
                        const SizedBox(width: 4),
                        Expanded(child: Container(height: 4, decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(2)))),
                        const SizedBox(width: 4),
                        Expanded(child: Container(height: 4, decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(2)))),
                        const SizedBox(width: 4),
                        Expanded(child: Container(height: 4, decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(2)))),
                        const SizedBox(width: 8),
                        Text("Strong", style: AppFontStyle.fontStyleW600(fontSize: 10, fontColor: const Color(0xFF10B981))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Checkbox(
                          value: !_obscurePassword,
                          activeColor: const Color(0xFF2563EB),
                          onChanged: (val) => setState(() => _obscurePassword = !val!),
                        ),
                        Text(
                          "Show password characters",
                          style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: const Color(0xFF475569)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 16),

                    // Terms Checkbox (Screenshot 1 & 2)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _agreedToTerms,
                            activeColor: const Color(0xFF2563EB),
                            onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "I agree to the Terms of Service, Event Hosting Policies, and understand that official government KYC documents will be required inside the Organizer Portal before publishing events.",
                            style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF475569)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button matching website
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4338CA),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: _submit,
                        child: const Text(
                          "Complete Registration →",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        "Already have an organizer account? Sign in here",
                        style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String number, String title) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppFontStyle.fontStyleW700(fontSize: 12, fontColor: const Color(0xFF0F172A)),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: const Color(0xFF334155)),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: const Color(0xFF334155)),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : items.first,
          items: items.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
          ),
        ),
      ],
    );
  }
}
