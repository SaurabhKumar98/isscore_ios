import 'dart:async';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/routes/approutesname.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/authprovider/forgotpassword.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// ─── Step Enum ───────────────────────────────────────────────────────────────
enum ForgotStep { email, otp, newPassword }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  ForgotStep _currentStep = ForgotStep.email;

  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();

  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  int _remainingSeconds = 60;
  Timer? _timer;
  bool _canResend = false;

  // ── Step 3 – New Password ─────────────────────────────────────────────────
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var n in _otpFocusNodes) {
      n.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Timer (OTP countdown) ─────────────────────────────────────────────────
  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }



  Future<void> _sendOTP() async {
    if (!_emailFormKey.currentState!.validate()) return;

    final provider = context.read<ForgotPasswordProvider>();
    final success = await provider.requestOtp(
      context,
      email: _emailController.text.trim(),
    );

    if (success && mounted) {
      setState(() => _currentStep = ForgotStep.otp);
      _startTimer();
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    final provider = context.read<ForgotPasswordProvider>();
    final success = await provider.requestOtp(
      context,
      email: _emailController.text.trim(),
    );

    if (success && mounted) {
      _startTimer();
      AppToast.success(
        context,
        title: "OTP Resent",
        message: "A new code has been sent to your email.",
      );
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      AppToast.success(context, title: "", message: "");
      return;
    }

    final provider = context.read<ForgotPasswordProvider>();
    final success = await provider.verifyOtp(
      context,
      email: _emailController.text.trim(),
      otp: otp,
    );

    if (success && mounted) {
      setState(() => _currentStep = ForgotStep.newPassword);
    }
  }

  Future<void> _resetPassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    final otp = _otpControllers.map((c) => c.text).join();
    final provider = context.read<ForgotPasswordProvider>();

    final success = await provider.resetPassword(
      context,
      email: _emailController.text.trim(),
      otp: otp,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (success && mounted) {
      AppToast.success(
        context,
        title: "",
        message: "Password Reset Successfully",
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted)
          Navigator.pushReplacementNamed(context, AppRoutesName.login);
      });
    }
  }

  // ── Back button logic per step ─────────────────────────────────────────────
  void _handleBack() {
    if (_currentStep == ForgotStep.email) {
      Navigator.pushReplacementNamed(context, AppRoutesName.login);
    } else if (_currentStep == ForgotStep.otp) {
      _timer?.cancel();
      setState(() => _currentStep = ForgotStep.email);
    } else {
      setState(() => _currentStep = ForgotStep.otp);
    }
  }

  // ── Header title & subtitle per step ──────────────────────────────────────
  String get _headerTitle {
    switch (_currentStep) {
      case ForgotStep.email:
        return "Forgot Password";
      case ForgotStep.otp:
        return "Verification";
      case ForgotStep.newPassword:
        return "New Password";
    }
  }

  String get _headerSubtitle {
    switch (_currentStep) {
      case ForgotStep.email:
        return "Enter your registered email address";
      case ForgotStep.otp:
        return "Enter the code sent to your email";
      case ForgotStep.newPassword:
        return "Create a strong new password";
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: drawerColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
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
                        SizedBox(height: 20.h),
                        _buildStepContent(),
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

  // ── Fixed Header ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      color: drawerColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: _handleBack,
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
          SizedBox(height: 20.h),
          // Step indicator dots
          _buildStepIndicator(),
          SizedBox(height: 16.h),
          Text(
            _headerTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _headerSubtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14.sp,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (i) {
        final isActive = i == _currentStep.index;
        final isDone = i < _currentStep.index;
        return Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 28.w : 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: isDone || isActive
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        );
      }),
    );
  }

  // ── Step content switcher ─────────────────────────────────────────────────
  Widget _buildStepContent() {
    switch (_currentStep) {
      case ForgotStep.email:
        return _buildEmailStep();
      case ForgotStep.otp:
        return _buildOTPStep();
      case ForgotStep.newPassword:
        return _buildNewPasswordStep();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  //  STEP 1 – EMAIL
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildEmailStep() {
    return Form(
      key: _emailFormKey,
      child: Column(
        children: [
          // Illustration
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: primaryButtonColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_reset_rounded,
              size: 60.sp,
              color: primaryButtonColor,
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            "Find Your Account",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "We'll send a 6-digit verification code\nto reset your password.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14.sp,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 32.h),
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.sp,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: "Email Address",
              labelStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              prefixIcon: Icon(
                Icons.email_rounded,
                color: primaryButtonColor,
                size: 20.sp,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: primaryButtonColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email address';
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          SizedBox(height: 32.h),
          // Send OTP button
          Consumer<ForgotPasswordProvider>(
            builder: (context, provider, _) => SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: provider.isRequestOtpLoading ? () {} : _sendOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: provider.isRequestOtpLoading
                      ? drawerBgColor.withOpacity(0.6)
                      : drawerBgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Send Verification Code",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),
          // Back to login
          GestureDetector(
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutesName.login),
            child: RichText(
              text: TextSpan(
                text: "Remember your password? ",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                ),
                children: const [
                  TextSpan(
                    text: "Log In",
                    style: TextStyle(
                      color: primaryButtonColor,
                      fontWeight: FontWeight.w700,
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

  // ────────────────────────────────────────────────────────────────────────────
  //  STEP 2 – OTP
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildOTPStep() {
    return Column(
      children: [
        // Illustration
        Container(
          width: 120.w,
          height: 120.h,
          decoration: BoxDecoration(
            color: primaryButtonColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_rounded,
            size: 60.sp,
            color: primaryButtonColor,
          ),
        ),
        SizedBox(height: 32.h),
        Text(
          "Enter Verification Code",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 8.h),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: "We've sent a 6-digit code to\n",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14.sp,
              fontFamily: 'Poppins',
            ),
            children: [
              TextSpan(
                text: _emailController.text.isNotEmpty
                    ? _emailController.text
                    : "your email",
                style: const TextStyle(
                  color: primaryButtonColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),
        // OTP boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, _buildOTPBox),
        ),
        SizedBox(height: 32.h),
        // Resend section
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive code? ",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.sp,
                fontFamily: 'Poppins',
              ),
            ),
            if (_canResend)
              GestureDetector(
                onTap: _resendOTP,
                child: Text(
                  "Resend",
                  style: TextStyle(
                    color: primaryButtonColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              )
            else
              Text(
                "Resend in $_remainingSeconds s",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                ),
              ),
          ],
        ),
        SizedBox(height: 32.h),
        // Verify button
        Consumer<ForgotPasswordProvider>(
          builder: (context, provider, _) => SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: provider.isVerifyOtpLoading ? () {} : _verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.isVerifyOtpLoading
                    ? primaryButtonColor.withOpacity(0.6)
                    : primaryButtonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: provider.isVerifyOtpLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      "Verify & Continue",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPBox(int index) {
    return Container(
      width: 50.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _otpControllers[index].text.isEmpty
              ? Colors.grey.shade300
              : primaryButtonColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          color: drawerColor,
          fontFamily: 'Poppins',
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          setState(() {}); // Rebuild border color
          if (value.isNotEmpty && index < 5) {
            _otpFocusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
          if (index == 5 && value.isNotEmpty) {
            String otp = _otpControllers.map((c) => c.text).join();
            if (otp.length == 6) FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  //  STEP 3 – NEW PASSWORD
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildNewPasswordStep() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        children: [
          // Illustration
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: primaryButtonColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_rounded,
              size: 60.sp,
              color: primaryButtonColor,
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            "Set New Password",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Your new password must be different\nfrom your previous password.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14.sp,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 32.h),

          // New Password field
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNew,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.sp,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: "New Password",
              labelStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: primaryButtonColor,
                size: 20.sp,
              ),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscureNew = !_obscureNew),
                child: Icon(
                  _obscureNew
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.grey.shade500,
                  size: 20.sp,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: primaryButtonColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a new password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Confirm Password field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.sp,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: "Confirm Password",
              labelStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: primaryButtonColor,
                size: 20.sp,
              ),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                child: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.grey.shade500,
                  size: 20.sp,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: primaryButtonColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          SizedBox(height: 32.h),

          // Reset Password button
          Consumer<ForgotPasswordProvider>(
            builder: (context, provider, _) => SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: provider.isResetPasswordLoading
                    ? () {}
                    : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: provider.isResetPasswordLoading
                      ? primaryButtonColor.withOpacity(0.6)
                      : primaryButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: provider.isResetPasswordLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Reset Password",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
