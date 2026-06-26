// lib/view/indexscreen/profile_view/edit_profile_screen.dart

import 'dart:io';

import 'package:firstedu/data/models/api_models/profile/profileandeditmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/view_models/profile_provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

// ─── Design tokens (matches ProfileScreen palette) ───────────────────────────
const _bg = Color(0xFFF6F7FB);
const _white = Colors.white;
const _ink = Color(0xFF0F172A);
const _slate = Color(0xFF64748B);
const _border = Color(0xFFE2E8F0);
const _red = Color(0xFFEF4444);

class EditProfileScreen extends StatefulWidget {
  final ProfileModel profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // ── Profile controllers ────────────────────────────────────────────────────
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _schoolCtrl;
  late final TextEditingController _gradeCtrl;

  // ── Password controllers ───────────────────────────────────────────────────
  final _oldPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();

  bool _oldPwVisible = false;
  bool _newPwVisible = false;
  bool _confirmPwVisible = false;

  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _phoneCtrl = TextEditingController(text: widget.profile.phone ?? '');
    _schoolCtrl = TextEditingController(
      text: widget.profile.schoolOrCollege ?? '',
    );
    _gradeCtrl = TextEditingController(text: widget.profile.classOrGrade ?? '');
  }

  @override
  void dispose() {
    _tab.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _schoolCtrl.dispose();
    _gradeCtrl.dispose();
    _oldPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

File? _selectedImage;

Future<void> _pickImage() async {
  final picker = ImagePicker();

  final pickedFile = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 70,
  );

  if (pickedFile != null) {
    setState(() {
      _selectedImage = File(pickedFile.path);
    });
  }
}

  // ── Save profile ───────────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;
      print("SELECTED IMAGE: $_selectedImage");
    final ok = await context.read<ProfileProvider>().updateProfile(
      context,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      schoolOrCollege: _schoolCtrl.text.trim(),
      classOrGrade: _gradeCtrl.text.trim(),
      profileImage: _selectedImage,
    );
    if (ok && mounted) Navigator.pop(context, true);
  }

  // ── Change password ────────────────────────────────────────────────────────
  Future<void> _changePassword() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;
    final ok = await context.read<ProfileProvider>().changePassword(
      context,
      oldPassword: _oldPwCtrl.text,
      newPassword: _newPwCtrl.text,
      confirmPassword: _confirmPwCtrl.text,
    );
    if (ok && mounted) {
      _oldPwCtrl.clear();
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pv = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: _ink,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tab,
          labelColor: accentOrange,
          unselectedLabelColor: _slate,
          indicatorColor: accentOrange,
          indicatorWeight: 2.5,
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
          tabs: const [
            Tab(text: "Profile Info"),
            Tab(text: "Change Password"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_profileTab(pv), _passwordTab(pv)],
      ),
    );
  }

  // ── Profile tab ────────────────────────────────────────────────────────────
  Widget _profileTab(ProfileProvider pv) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Form(
        key: _profileFormKey,
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
  children: [
    Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            accentOrange.withOpacity(0.6),
            accentOrange.withOpacity(0.1),
          ],
        ),
      ),
      child: CircleAvatar(
        radius: 46,
        backgroundImage: _selectedImage != null
            ? FileImage(_selectedImage!)
            : (widget.profile.profileImage?.isNotEmpty == true
                ? NetworkImage(widget.profile.profileImage!)
                : null) as ImageProvider?,
        backgroundColor: accentOrange.withOpacity(0.15),
        child: widget.profile.profileImage?.isEmpty == true &&
                _selectedImage == null
            ? Text(
                widget.profile.name[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: accentOrange,
                ),
              )
            : null,
      ),
    ),

    // ✨ ADD THIS EDIT BUTTON
    Positioned(
      bottom: 0,
      right: 0,
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: accentOrange,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.camera_alt,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    ),
  ],
)
            ),

            const SizedBox(height: 28),

            _card(
              children: [
                _field(
                  ctrl: _nameCtrl,
                  label: "Full Name",
                  hint: "e.g. John Doe",
                  icon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? "Name is required"
                      : null,
                ),
                const SizedBox(height: 16),
                _field(
                  ctrl: _emailCtrl,
                  label: "Email",
                  hint: "e.g. john@example.com",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return "Email is required";
                    if (!RegExp(r'^[\w\.\+\-]+@\w+\.\w+$').hasMatch(v.trim())) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _field(
                  ctrl: _phoneCtrl,
                  label: "Phone",
                  hint: "e.g. +919876543210",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _field(
                  ctrl: _schoolCtrl,
                  label: "School / College",
                  hint: "e.g. ABC School",
                  icon: Icons.school_outlined,
                ),
                const SizedBox(height: 16),
                _field(
                  ctrl: _gradeCtrl,
                  label: "Class / Grade",
                  hint: "e.g. 10",
                  icon: Icons.class_outlined,
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: pv.isUpdating ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: drawerColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  disabledBackgroundColor: drawerColor.withOpacity(0.5),
                ),
                child: pv.isUpdating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _white,
                        ),
                      )
                    : Text(
                        "Save Changes",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Password tab ───────────────────────────────────────────────────────────
  Widget _passwordTab(ProfileProvider pv) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          children: [
            _card(
              children: [
                _pwField(
                  ctrl: _oldPwCtrl,
                  label: "Current Password",
                  visible: _oldPwVisible,
                  onToggle: () =>
                      setState(() => _oldPwVisible = !_oldPwVisible),
                  validator: (v) => (v == null || v.isEmpty)
                      ? "Enter your current password"
                      : null,
                ),
                const SizedBox(height: 16),
                _pwField(
                  ctrl: _newPwCtrl,
                  label: "New Password",
                  visible: _newPwVisible,
                  onToggle: () =>
                      setState(() => _newPwVisible = !_newPwVisible),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Enter a new password";
                    if (v.length < 6) return "Minimum 6 characters";
                    if (v == _oldPwCtrl.text)
                      return "Must differ from current password";
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _pwField(
                  ctrl: _confirmPwCtrl,
                  label: "Confirm New Password",
                  visible: _confirmPwVisible,
                  onToggle: () =>
                      setState(() => _confirmPwVisible = !_confirmPwVisible),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return "Please confirm your password";
                    if (v != _newPwCtrl.text) return "Passwords do not match";
                    return null;
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // hints
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _hint("At least 6 characters"),
                  _hint("Must be different from current password"),
                  _hint("New password and confirm must match"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: pv.isChangingPw ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: drawerColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  disabledBackgroundColor: drawerColor.withOpacity(0.5),
                ),
                child: pv.isChangingPw
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _white,
                        ),
                      )
                    : Text(
                        "Change Password",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared sub-widgets ─────────────────────────────────────────────────────
  Widget _card({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _slate,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14, color: _ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: _slate.withOpacity(0.5),
            ),
            prefixIcon: Icon(icon, size: 18, color: _slate),
            filled: true,
            fillColor: _bg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentOrange, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pwField({
    required TextEditingController ctrl,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _slate,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          obscureText: !visible,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14, color: _ink),
          decoration: InputDecoration(
            hintText: "••••••••",
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: _slate.withOpacity(0.4),
            ),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: _slate,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                visible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: _slate,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: _bg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentOrange, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _hint(String text) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 13,
          color: _slate.withOpacity(0.6),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: _slate.withOpacity(0.7),
          ),
        ),
      ],
    ),
  );
}
