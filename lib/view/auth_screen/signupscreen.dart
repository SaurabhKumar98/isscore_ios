import 'dart:io';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/routes/approutesname.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/authprovider/authprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _schoolOrCollegeController;
  late TextEditingController _gradeOrPercentageController;
  late TextEditingController _referralCodeController;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  File? _profileImage;
  late ImagePicker _picker;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _schoolOrCollegeController = TextEditingController();
    _gradeOrPercentageController = TextEditingController();
    _referralCodeController = TextEditingController();
    _picker = ImagePicker();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _schoolOrCollegeController.dispose();
    _gradeOrPercentageController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: drawerColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildFixedHeader(),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32.r),
                    topRight: Radius.circular(32.r),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),
                        _buildProfileSection(),
                        SizedBox(height: 24.h),
                        _buildFormCard(),
                        SizedBox(height: 24.h),
                        _buildLoginLink(),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      color: drawerColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, AppRoutesName.login),
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Join thousands of learners today",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14.sp,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return GestureDetector(
      onTap: _pickProfileImage,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _profileImage != null
                      ? Colors.grey.shade200
                      : drawerColor.withOpacity(0.1),
                  border: Border.all(
                    color: drawerColor.withOpacity(0.2),
                    width: 3,
                  ),
                ),
                child: _profileImage != null
                    ? ClipOval(
                        child: Image.file(
                          _profileImage!,
                          width: 100.w,
                          height: 100.h,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40.sp,
                        color: drawerColor.withOpacity(0.5),
                      ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryButtonColor, Color(0xFFFF8C42)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            _profileImage != null ? "Change Photo" : "Add Photo",
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: primaryButtonColor,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _nameController,
              label: "Full Name",
              hint: "John Doe",
              icon: Icons.person_outline_rounded,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Name is required' : null,
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              controller: _emailController,
              label: "Email Address",
              hint: "you@example.com",
              icon: Icons.mail_outline_rounded,
              keyboard: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v))
                  return 'Enter a valid email';
                return null;
              },
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              controller: _phoneController,
              label: "Phone Number",
              hint: "+91 7903886623",
              icon: Icons.phone_outlined,
              keyboard: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Phone is required';
                if (v.length < 10) return 'Enter valid phone';
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // ── NEW: School / College ──
            _buildTextField(
              controller: _schoolOrCollegeController,
              label: "School / College",
              hint: "e.g. Delhi Public School",
              icon: Icons.school_outlined,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'School/College is required'
                  : null,
            ),
            SizedBox(height: 16.h),

            // ── NEW: Grade / Percentage ──
            _buildTextField(
              controller: _gradeOrPercentageController,
              label: "Grade / Percentage",
              hint: "e.g. Class 10 or 85%",
              icon: Icons.bar_chart_rounded,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Grade/Percentage is required'
                  : null,
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              controller: _passwordController,
              label: "Password",
              hint: "Min. 8 characters",
              icon: Icons.lock_outline_rounded,
              obscure: !_isPasswordVisible,
              suffix: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade400,
                  size: 20.sp,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 8) return 'Min 8 characters';
                return null;
              },
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              controller: _confirmPasswordController,
              label: "Confirm Password",
              hint: "Re-enter password",
              icon: Icons.lock_outline_rounded,
              obscure: !_isConfirmPasswordVisible,
              suffix: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey.shade400,
                  size: 20.sp,
                ),
                onPressed: () => setState(
                  () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirm password';
                if (v != _passwordController.text)
                  return 'Passwords do not match';
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // ── NEW: Referral Code (optional) ──
            _buildTextField(
              controller: _referralCodeController,
              label: "Referral Code (Optional)",
              hint: "Enter referral code if you have one",
              icon: Icons.card_giftcard_outlined,
              validator: null, // optional — no validation
            ),
            SizedBox(height: 20.h),

            _buildTermsCheckbox(),
            SizedBox(height: 24.h),

            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboard,
    bool obscure = false,
    Widget? suffix,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: drawerColor,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          inputFormatters: inputFormatters,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
            prefixIcon: Icon(icon, color: primaryButtonColor, size: 20.sp),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: primaryButtonColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            errorStyle: TextStyle(fontSize: 11.sp, fontFamily: 'Poppins'),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: _agreeToTerms ? primaryButtonColor : Colors.transparent,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(
                color: _agreeToTerms
                    ? primaryButtonColor
                    : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: _agreeToTerms
                ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "I agree to the ",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12.sp,
                  fontFamily: 'Poppins',
                ),
                children: const [
                  TextSpan(
                    text: "Terms & Conditions",
                    style: TextStyle(
                      color: primaryButtonColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: " and "),
                  TextSpan(
                    text: "Privacy Policy",
                    style: TextStyle(
                      color: primaryButtonColor,
                      fontWeight: FontWeight.w600,
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

  Widget _buildSignUpButton() {
    return Consumer<Authprovider>(
      builder: (context, authProvider, _) {
        final isLoading = authProvider.isRegisterLoading;
        return SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryButtonColor,
              disabledBackgroundColor: primaryButtonColor.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? SizedBox(
                    width: 22.w,
                    height: 22.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward_rounded, size: 20.sp),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () =>
            Navigator.pushReplacementNamed(context, AppRoutesName.login),
        child: RichText(
          text: TextSpan(
            text: "Already have an account? ",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14.sp,
              fontFamily: 'Poppins',
            ),
            children: const [
              TextSpan(
                text: "Sign In",
                style: TextStyle(
                  color: drawerColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Image Picker ──────────────────────────────────────────────────────────

  Future<void> _pickProfileImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  // ── Sign-up Handler ───────────────────────────────────────────────────────

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
    
      AppToast.error(context, message:'Please accept Terms & Conditions' );
      return;
    }

    final success = await context.read<Authprovider>().register(
      context,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      schoolOrCollege: _schoolOrCollegeController.text.trim(),
      classOrGrade: _gradeOrPercentageController.text.trim(),
      referralCode: _referralCodeController.text.trim().isEmpty
          ? null
          : _referralCodeController.text.trim(),
      profileImage: _profileImage,
    );

    // ✅ On success navigate to login — token is only available after login
    if (success && mounted) {
      AppToast.success(context, message:"Account created! Please sign in." );
      Navigator.pushReplacementNamed(context, AppRoutesName.login);
    }
  }
}
