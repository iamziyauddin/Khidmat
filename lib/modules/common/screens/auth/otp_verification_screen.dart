import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pinput/pinput.dart';
import '../../../../routing/app_router.dart';
import '../../../../ui/theme/app_theme.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
    _otpFocus.requestFocus();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 30;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        _resendCountdown--;
      });

      return _resendCountdown > 0;
    });
  }

  void _verifyOtp() async {
    _otpFocus.unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate OTP verification delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // On successful verification (mocked)
      final role =
          GoRouterState.of(context).uri.queryParameters['role'] ?? 'applicant';
      context.go('${AppRouter.kyc}?role=$role&phone=${widget.phoneNumber}');
    }
  }

  void _resendOtp() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResending = true;
    });

    // Simulate resend delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isResending = false;
      });
      _startResendCountdown();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new OTP has been sent successfully'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppTheme.primaryTeal, width: 2),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: AppTheme.primaryTeal.withOpacity(0.1),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppTheme.error, width: 2),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Header icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.messageCircle,
                      size: 40,
                      color: AppTheme.primaryTeal,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Header
                  Text(
                    'Enter Verification Code',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text.rich(
                    TextSpan(
                      text: 'Enter the 6-digit code sent to ',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      children: [
                        TextSpan(
                          text: widget.phoneNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // OTP Input
                  Pinput(
                    controller: _otpController,
                    focusNode: _otpFocus,
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    errorPinTheme: errorPinTheme,
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    showCursor: true,
                    onCompleted: (pin) => _verifyOtp(),
                    validator: (s) {
                      if (s == null || s.length < 6) {
                        return 'Please enter the complete OTP';
                      }
                      // Mock validation: correct OTP is '123456'
                      if (s != '123456') {
                        return 'The OTP entered is incorrect';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Resend OTP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: _resendCountdown == 0 && !_isResending
                            ? _resendOtp
                            : null,
                        child: Text(
                          _isResending
                              ? 'Sending...'
                              : _resendCountdown > 0
                              ? 'Resend in ${_resendCountdown}s'
                              : 'Resend Code',
                          style: TextStyle(
                            color: _resendCountdown == 0 && !_isResending
                                ? AppTheme.primaryTeal
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Verifying...'),
                              ],
                            )
                          : const Text('Verify & Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
