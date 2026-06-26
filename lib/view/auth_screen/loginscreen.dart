import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/routes/approutesname.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view_models/authprovider/authprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController    = TextEditingController();
  final _otpController      = TextEditingController();

  bool _isPasswordVisible = false;
  bool _usePhone          = false;
  bool _otpSent           = false;

  late AnimationController _animController;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }


  Future<void> _onSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    final auth    = context.read<Authprovider>();
    final success = await auth.login(
      context,
      email:    _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context, AppRoutesName.entry, (route) => false,
      );
    }
  }


  Future<void> _onSendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<Authprovider>().sendLoginOtp(
      context,
      phone: _phoneController.text.trim(),
    );
    if (success && mounted) {
      setState(() => _otpSent = true);
    }
  }

  Future<void> _onVerifyOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<Authprovider>().verifyLoginOtp(
      context,
      phone: _phoneController.text.trim(),
      otp:   _otpController.text.trim(),
    );
    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context, AppRoutesName.entry, (route) => false,
      );
    }
  }

  // ─────────────────────── SWITCH MODE ─────────────────────────────

  void _switchToPhone() {
    context.read<Authprovider>().resetOtpState();
    setState(() {
      _usePhone = true;
      _otpSent  = false;
      _otpController.clear();
      _phoneController.clear();
    });
  }

  void _switchToEmail() {
    context.read<Authprovider>().resetOtpState();
    setState(() {
      _usePhone = false;
      _otpSent  = false;
      _otpController.clear();
      _phoneController.clear();
    });
  }

  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width:  double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              drawerColor,
              drawerColor.withOpacity(0.8),
              const Color(0xFF1A237E),
            ],
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),
                  _buildHeader(),
                  SizedBox(height: 50.h),
                  _buildForm(),
                  SizedBox(height: 16.h),
                  _buildBottomActions(),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────── HEADER ──────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withOpacity(0.1),
                blurRadius: 20.r,
                offset:     Offset(0, 10.h),
              ),
            ],
          ),
          child: Icon(Icons.school_rounded, color: drawerColor, size: 40.sp),
        ),
        SizedBox(height: 24.h),
        const CustomText(
          text:   "Welcome Back!",
          size:   32,
          weight: FontWeight.w800,
          color:  Colors.white,
        ),
        SizedBox(height: 8.h),
        CustomText(
          text:  "Sign in to continue your learning journey",
          size:  15,
          color: Colors.white.withOpacity(0.9),
        ),
      ],
    );
  }

  // ─────────────────────── FORM CARD ───────────────────────────────

  Widget _buildForm() {
    final isLoginLoading = context.select<Authprovider, bool>(
      (p) => p.isLoginLoading,
    );
    final isSendLoading = context.select<Authprovider, bool>(
      (p) => p.isSendOtpLoading,
    );
    final isVerifyLoading = context.select<Authprovider, bool>(
      (p) => p.isVerifyOtpLoading,
    );

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.1),
            blurRadius: 30.r,
            offset:     Offset(0, 15.h),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── MODE LABEL ─────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Align(
                key:       ValueKey(_usePhone),
                alignment: Alignment.centerLeft,
                child: CustomText(
                  text:   _usePhone ? "Phone Login" : "Email Login",
                  size:   18,
                  weight: FontWeight.w700,
                  color:  Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // ══════════════ EMAIL MODE ═════════════════════════════
            if (!_usePhone) ...[

              const CustomText(
                text:   "Email Address",
                size:   14,
                weight: FontWeight.w600,
                color:  Colors.black87,
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller:   _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
                decoration: _inputDecoration(
                  hint:       "your.email@example.com",
                  prefixIcon: Icons.email_outlined,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter your email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              const CustomText(
                text:   "Password",
                size:   14,
                weight: FontWeight.w600,
                color:  Colors.black87,
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller:  _passwordController,
                obscureText: !_isPasswordVisible,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
                decoration: _inputDecoration(
                  hint:       "Enter your password",
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey.shade600,
                      size:  22.sp,
                    ),
                    onPressed: () =>
                        setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter your password';
                  if (v.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutesName.otp),
                    child: const CustomText(
                      text:   "Forgot Password?",
                      size:   13,
                      weight: FontWeight.w600,
                      color:  drawerColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              CustomButton(
                title:           isLoginLoading ? "Signing In..." : "Sign In",
                onTap:           isLoginLoading ? () {} : _onSignIn,
                backgroundColor: isLoginLoading
                    ? drawerColor.withOpacity(0.6)
                    : drawerColor,
                textColor: Colors.white,
                height:    54.h,
              ),

            ] else ...[

              // ══════════════ PHONE MODE ═════════════════════════════

              const CustomText(
                text:   "Phone Number",
                size:   14,
                weight: FontWeight.w600,
                color:  Colors.black87,
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller:   _phoneController,
                keyboardType: TextInputType.phone,
                enabled:      !_otpSent,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
                decoration: _inputDecoration(
                  hint:       "Enter your phone number",
                  prefixIcon: Icons.phone_android_outlined,
                  suffixIcon: _otpSent
                      ? GestureDetector(
                          onTap: () => setState(() {
                            _otpSent = false;
                            _otpController.clear();
                            context.read<Authprovider>().resetOtpState();
                          }),
                          child: Icon(Icons.edit_outlined,
                              color: drawerColor, size: 20.sp),
                        )
                      : null,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (v.trim().length < 10) {
                    return 'Enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              // ── OTP field — appears after OTP is sent ─────────────
              if (_otpSent) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomText(
                      text:   "Enter OTP",
                      size:   14,
                      weight: FontWeight.w600,
                      color:  Colors.black87,
                    ),
                    GestureDetector(
                      onTap: isSendLoading ? null : _onSendOtp,
                      child: CustomText(
                        text:   isSendLoading ? "Sending..." : "Resend OTP",
                        size:   13,
                        weight: FontWeight.w600,
                        color:  isSendLoading ? Colors.grey : drawerColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller:   _otpController,
                  keyboardType: TextInputType.number,
                  textAlign:    TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4), // ✅ 4-digit OTP
                  ],
                  style: TextStyle(
                    fontSize:      22.sp,
                    fontWeight:    FontWeight.w700,
                    letterSpacing: 14,               // ✅ adjusted for 4 digits
                  ),
                  decoration: _inputDecoration(
                    hint:       "· · · ·",           // ✅ 4 dots
                    prefixIcon: Icons.verified_outlined,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter the OTP';
                    if (v.trim().length < 4) return 'Enter a valid 4-digit OTP';
                    return null;
                  },
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.green.shade600, size: 14.sp),
                    SizedBox(width: 6.w),
                    CustomText(
                      text:  "OTP sent to +91 ${_phoneController.text.trim()}",
                      size:  12,
                      color: Colors.green.shade600,
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                CustomButton(
                  title: isVerifyLoading ? "Verifying..." : "Verify & Sign In",
                  onTap: isVerifyLoading ? () {} : _onVerifyOtp,
                  backgroundColor: isVerifyLoading
                      ? drawerColor.withOpacity(0.6)
                      : drawerColor,
                  textColor: Colors.white,
                  height:    54.h,
                ),
              ] else ...[
                CustomButton(
                  title: isSendLoading ? "Sending OTP..." : "Send OTP",
                  onTap: isSendLoading ? () {} : _onSendOtp,
                  backgroundColor: isSendLoading
                      ? drawerColor.withOpacity(0.6)
                      : drawerColor,
                  textColor: Colors.white,
                  height:    54.h,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────── BOTTOM ACTIONS ──────────────────────────

  Widget _buildBottomActions() {
    return Column(
      children: [
        if (!_usePhone)
          _buildOutlineButton(
            icon:  Icons.phone_android_outlined,
            label: "Continue with Phone Number",
            onTap: _switchToPhone,
          )
        else
          GestureDetector(
            onTap: _switchToEmail,
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: "Want to use email? ",
                  style: TextStyle(
                    color:      Colors.white.withOpacity(0.8),
                    fontSize:   14.sp,
                    fontFamily: 'Poppins',
                  ),
                  children: const [
                    TextSpan(
                      text: "Sign in with Email",
                      style: TextStyle(
                        color:      Colors.white,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        SizedBox(height: 20.h),

        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutesName.signup),
          child: Center(
            child: RichText(
              text: TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(
                  color:      Colors.white.withOpacity(0.9),
                  fontSize:   14.sp,
                  fontFamily: 'Poppins',
                ),
                children: const [
                  TextSpan(
                    text: "Sign Up",
                    style: TextStyle(
                      color:      Colors.white,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutlineButton({
    required IconData    icon,
    required String      label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54.h,
        decoration: BoxDecoration(
          color:        Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
              color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                color:      Colors.white,
                fontSize:   14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── INPUT DECORATION ────────────────────────

  InputDecoration _inputDecoration({
    required String   hint,
    required IconData prefixIcon,
    Widget?           suffixIcon,
  }) {
    return InputDecoration(
      hintText:   hint,
      hintStyle:  TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
      prefixIcon: Icon(prefixIcon, color: drawerColor, size: 22.sp),
      suffixIcon: suffixIcon,
      filled:     true,
      fillColor:  Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide:   BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide:   BorderSide(color: Colors.grey.shade200),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide:   BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide:   BorderSide(color: drawerColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide:   const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide:   const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    );
  }
}