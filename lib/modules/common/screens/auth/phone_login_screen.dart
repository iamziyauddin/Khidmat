import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../routing/app_router.dart';
import '../../../../ui/theme/app_theme.dart';
import '../../../../services/database_service.dart';
import '../../../../local_db/models/user_model.dart';
import '../../../../utils/sample_data.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();

  String _selectedCountryCode = '+91';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    // Hide keyboard
    _phoneFocus.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate OTP sending delay
      await Future.delayed(const Duration(seconds: 1));

      final role =
          GoRouterState.of(context).uri.queryParameters['role'] ?? 'applicant';
      final phoneNumber = '$_selectedCountryCode${_phoneController.text}';

      // Create or get existing user
      final db = DatabaseService.instance;

      // Ensure sample data is loaded
      await SampleDataSeeder.seedSampleData();

      // Try to find existing user by phone
      final existingUsers = db.getAllUsers();
      UserModel? user = existingUsers
          .where((u) => u.phone == phoneNumber)
          .firstOrNull;

      // If no user found, create a new one
      if (user == null) {
        final userRole = role == 'donor' ? UserRole.donor : UserRole.applicant;
        user = UserModel(
          id: const Uuid().v4(),
          name: role == 'donor' ? 'Donor User' : 'Help Seeker',
          phone: phoneNumber,
          age: 25,
          city: 'Mumbai',
          role: userRole,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await db.saveUser(user);
      }

      // Set as current user
      await db.setCurrentUser(user.id);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Debug prints
        print('Navigating with role: $role');
        print('User created: ${user.name} (${user.role})');
        print('Current route: ${GoRouterState.of(context).uri}');

        // BYPASS OTP - Go directly to appropriate dashboard
        if (role == 'donor') {
          print('Going to donor dashboard: ${AppRouter.donorDashboard}');

          // Try multiple navigation approaches
          try {
            context.go(AppRouter.donorDashboard);
            print('Navigation successful with context.go()');
          } catch (e) {
            print('Error with context.go(): $e');
            // Fallback to test route
            context.go('/test-donor');
          }
        } else {
          print(
            'Going to applicant dashboard: ${AppRouter.applicantDashboard}',
          );
          context.go(AppRouter.applicantDashboard);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Verification'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go(AppRouter.roleSelection),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Header
                  Text(
                    'Enter Your Phone Number',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Enter your phone number to continue to the app.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.7,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Phone input
                  Text(
                    'Phone Number',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(
                        10,
                      ), // Common for many regions
                    ],
                    decoration: InputDecoration(
                      hintText: '98765 43210',
                      prefixIcon: CountryCodePicker(
                        onChanged: (countryCode) {
                          setState(() {
                            _selectedCountryCode =
                                countryCode.dialCode ?? '+91';
                          });
                        },
                        initialSelection: 'IN',
                        favorite: const ['+91', 'IN'],
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                      ),
                      enabled: !_isLoading,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length < 7) {
                        // A more generic check
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _sendOtp(),
                  ),

                  const SizedBox(height: 40),

                  // Send OTP Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendOtp,
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
                                Text('Logging in...'),
                              ],
                            )
                          : const Text('Continue'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryTeal.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.shieldCheck,
                          color: AppTheme.primaryTeal,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your phone number is kept confidential and is only used for verification.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Terms and Privacy
                  Text(
                    'By continuing, you agree to our Terms of Service and acknowledge that you have read our Privacy Policy.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
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
