import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/ui/host_flow/ecosystem/controllers/ecosystem_controller.dart';
import 'package:notisboard/utils/font_style.dart';

class VendorApplicationView extends StatefulWidget {
  const VendorApplicationView({super.key});

  @override
  State<VendorApplicationView> createState() => _VendorApplicationViewState();
}

class _VendorApplicationViewState extends State<VendorApplicationView> {
  final _formKey = GlobalKey<FormState>();

  String _applicantType = "individual"; // 'individual' or 'business'
  bool _obscurePassword = true;

  // Individual Vendor Fields (Screenshot 3)
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _citizenshipController = TextEditingController();
  final _dobController = TextEditingController();
  final _placeOfBirthController = TextEditingController();

  // Business Vendor Fields (Screenshot 4)
  final _registeredBusinessNameController = TextEditingController();
  String _selectedBusinessType = "Limited Liability Company (LLC)";

  // Password Fields
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final List<String> _businessTypes = [
    "Limited Liability Company (LLC)",
    "Corporation",
    "Sole Proprietorship",
    "Partnership",
    "Non-profit Organization",
    "Other Commercial Entity",
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _citizenshipController.dispose();
    _dobController.dispose();
    _placeOfBirthController.dispose();
    _registeredBusinessNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 18, 12, 31),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      Get.snackbar("Password Mismatch", "Password and Confirm Password must match.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final controller = Get.find<EcosystemController>();
    final isIndividual = _applicantType == "individual";

    final success = await controller.submitVendorApplication(
      applicantType: _applicantType,
      firstName: _firstNameController.text.trim(),
      middleName: isIndividual ? _middleNameController.text.trim() : "",
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      citizenship: isIndividual ? _citizenshipController.text.trim() : "",
      dateOfBirth: isIndividual ? _dobController.text.trim() : "",
      placeOfBirth: isIndividual ? _placeOfBirthController.text.trim() : "",
      countryOfResidence: isIndividual ? _citizenshipController.text.trim() : "",
      residentialAddress: "",
      city: isIndividual ? _placeOfBirthController.text.trim() : "",
      state: "",
      postalCode: "",
      registeredBusinessName: isIndividual ? "" : _registeredBusinessNameController.text.trim(),
      businessName: isIndividual
          ? "${_firstNameController.text.trim()}'s Store"
          : _registeredBusinessNameController.text.trim(),
      businessType: isIndividual ? "Individual Artisan" : _selectedBusinessType,
      taxId: "",
      governmentIdType: "Passport",
      governmentIdExpirationDate: "",
      proofOfAddressType: "Bank Statement",
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      description: "",
      website: "",
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
          "Vendor Merchant Application",
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
              // Header title matching website
              Center(
                child: Column(
                  children: [
                    Text(
                      "Vendor Merchant Application",
                      textAlign: TextAlign.center,
                      style: AppFontStyle.fontStyleW700(fontSize: 22, fontColor: const Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Select your seller category below to load your personalized verification and registration dossier.",
                      textAlign: TextAlign.center,
                      style: AppFontStyle.fontStyleW400(fontSize: 13, fontColor: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Two category cards matching website (Screenshot 3 & 4)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      isSelected: isIndividual,
                      title: "Individual Vendor",
                      badge: "Personal & Artisan",
                      badgeColor: const Color(0xFF3B82F6),
                      description: "For individuals who want to sell products under their personal identity or individual artisan activities.",
                      footerText: "Personal & Address Verification",
                      icon: Icons.person_outline_rounded,
                      onTap: () => setState(() => _applicantType = "individual"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCategoryCard(
                      isSelected: !isIndividual,
                      title: "Business Vendor",
                      badge: "Commercial Entity",
                      badgeColor: const Color(0xFFF59E0B),
                      description: "For registered businesses, companies, organizations, and other commercial entities selling through the Foundation.",
                      footerText: "EIN & Corporate Dossier",
                      icon: Icons.business_outlined,
                      onTap: () => setState(() => _applicantType = "business"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Main Form Container matching website exactly
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
                    if (isIndividual) ...[
                      // SECTION A: PERSONAL INFORMATION (Screenshot 3)
                      _buildSectionHeader("A", "PERSONAL INFORMATION"),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _firstNameController,
                              label: "First Name *",
                              hint: "e.g. Maya",
                              validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              controller: _middleNameController,
                              label: "Middle Name",
                              hint: "e.g. Jane",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _lastNameController,
                        label: "Last Name *",
                        hint: "e.g. Jenkins",
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
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
                        label: "Phone Number *",
                        hint: "+1 (555) 019-2834",
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Phone required" : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _citizenshipController,
                        label: "Citizenship *",
                        hint: "e.g. United States, Canada, Nigeria",
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Citizenship required" : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              controller: _dobController,
                              label: "Date of Birth * (18+ only)",
                              hint: "dd/mm/yyyy",
                              onTap: () => _pickDate(_dobController),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              controller: _placeOfBirthController,
                              label: "Place of Birth *",
                              hint: "e.g. Seattle, Washington",
                              validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 16),

                      // SECTION B: ACCOUNT ACCESS PASSWORD (Screenshot 3)
                      _buildSectionHeader("B", "ACCOUNT ACCESS PASSWORD"),
                      const SizedBox(height: 6),
                      Text(
                        "Set a strong password for logging into your Vendor Portal and tracking your verification progress.",
                        style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _passwordController,
                        label: "Create Password *",
                        hint: "••••••••",
                        obscureText: _obscurePassword,
                        validator: (v) => (v == null || v.length < 6) ? "Min 6 chars" : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: "Confirm Password *",
                        hint: "Re-enter your password",
                        obscureText: _obscurePassword,
                        validator: (v) => (v == null || v.isEmpty) ? "Confirm password" : null,
                      ),
                      const SizedBox(height: 8),
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
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: _submit,
                          child: const Text(
                            "Create Individual Vendor Account & Proceed to KYC Verification →",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ] else ...[
                      // SECTION A: PRIMARY CONTACT INFORMATION (Screenshot 4)
                      _buildSectionHeader("A", "PRIMARY CONTACT INFORMATION"),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _firstNameController,
                              label: "First Name *",
                              hint: "e.g. Marcus",
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
                        hint: "corporate@entity.com",
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || !v.contains('@')) ? "Valid email required" : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _phoneController,
                        label: "Business Phone Number *",
                        hint: "+1 (555) 789-0123",
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                      ),
                      const SizedBox(height: 20),

                      // SECTION B: BUSINESS ENTITY INFORMATION (Screenshot 4)
                      _buildSectionHeader("B", "BUSINESS ENTITY INFORMATION"),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _registeredBusinessNameController,
                        label: "Registered Business Name *",
                        hint: "e.g. EcoCraft Global Ventures LLC",
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Business name required" : null,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        label: "Business Type *",
                        value: _selectedBusinessType,
                        items: _businessTypes,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedBusinessType = val);
                        },
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 16),

                      // SECTION C: ACCOUNT ACCESS PASSWORD (Screenshot 4)
                      _buildSectionHeader("C", "ACCOUNT ACCESS PASSWORD"),
                      const SizedBox(height: 6),
                      Text(
                        "Set a strong password for logging into your Corporate Vendor Portal and tracking your verification progress.",
                        style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _passwordController,
                        label: "Create Password *",
                        hint: "••••••••",
                        obscureText: _obscurePassword,
                        validator: (v) => (v == null || v.length < 6) ? "Min 6 chars" : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: "Confirm Password *",
                        hint: "Re-enter your password",
                        obscureText: _obscurePassword,
                        validator: (v) => (v == null || v.isEmpty) ? "Confirm password" : null,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: !_obscurePassword,
                            activeColor: const Color(0xFFF59E0B),
                            onChanged: (val) => setState(() => _obscurePassword = !val!),
                          ),
                          Text(
                            "Show password characters",
                            style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: const Color(0xFF475569)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: _submit,
                          child: const Text(
                            "Create Business Vendor Account & Proceed to KYC Verification →",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required bool isSelected,
    required String title,
    required String badge,
    required Color badgeColor,
    required String description,
    required String footerText,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFF1F5F9),
                  child: Icon(icon, color: const Color(0xFF1E293B), size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    footerText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String letter, String title) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            letter,
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

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidCallback onTap,
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
          readOnly: true,
          onTap: onTap,
          validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF64748B)),
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
