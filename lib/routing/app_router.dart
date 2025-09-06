import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../modules/common/screens/splash_screen.dart';
import '../modules/common/screens/role_selection_screen.dart';
import '../modules/common/screens/auth/phone_login_screen.dart';
import '../modules/common/screens/auth/otp_verification_screen.dart';
import '../modules/common/screens/auth/kyc_screen.dart';
import '../modules/applicant/screens/applicant_dashboard.dart';
import '../modules/applicant/screens/apply_help_screen.dart';
import '../modules/applicant/screens/application_status_screen.dart';
import '../modules/applicant/screens/applicant_profile_screen.dart';
import '../modules/donor/screens/donor_dashboard.dart';
import '../modules/donor/screens/browse_applicants_screen.dart';
import '../modules/donor/screens/applicant_detail_screen.dart';
import '../modules/donor/screens/donation_history_screen.dart';
import '../modules/donor/screens/donor_profile_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String roleSelection = '/role-selection';
  static const String phoneLogin = '/phone-login';
  static const String otpVerification = '/otp-verification';
  static const String kyc = '/kyc';

  // Applicant routes
  static const String applicantDashboard = '/applicant-dashboard';
  static const String applyHelp = '/apply-help';
  static const String applicationStatus = '/application-status';
  static const String applicantProfile = '/applicant-profile';

  // Donor routes
  static const String donorDashboard = '/donor-dashboard';
  static const String browseApplicants = '/browse-applicants';
  static const String applicantDetail = '/applicant-detail';
  static const String donationHistory = '/donation-history';
  static const String donorProfile = '/donor-profile';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: roleSelection,
        name: 'role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: phoneLogin,
        name: 'phone-login',
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: otpVerification,
        name: 'otp-verification',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpVerificationScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: kyc,
        name: 'kyc',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? '';
          return KycScreen(userRole: role);
        },
      ),

      // Applicant Routes
      GoRoute(
        path: applicantDashboard,
        name: 'applicant-dashboard',
        builder: (context, state) => const ApplicantDashboard(),
        routes: [
          GoRoute(
            path: 'apply-help',
            name: 'apply-help',
            builder: (context, state) => const ApplyHelpScreen(),
          ),
          GoRoute(
            path: 'application-status',
            name: 'application-status',
            builder: (context, state) => const ApplicationStatusScreen(),
          ),
          GoRoute(
            path: 'profile',
            name: 'applicant-profile',
            builder: (context, state) => const ApplicantProfileScreen(),
          ),
        ],
      ),

      // Donor Routes
      GoRoute(
        path: donorDashboard,
        name: 'donor-dashboard',
        builder: (context, state) => const DonorDashboard(),
      ),
      GoRoute(
        path: '/browse-applicants',
        name: 'browse-applicants',
        builder: (context, state) => const BrowseApplicantsScreen(),
      ),
      GoRoute(
        path: '/applicant-detail/:id',
        name: 'applicant-detail',
        builder: (context, state) {
          final applicationId = state.pathParameters['id'] ?? '';
          return ApplicantDetailScreen(applicationId: applicationId);
        },
      ),
      GoRoute(
        path: '/donation-history',
        name: 'donation-history',
        builder: (context, state) => const DonationHistoryScreen(),
      ),
      GoRoute(
        path: '/donor-profile',
        name: 'donor-profile',
        builder: (context, state) => const DonorProfileScreen(),
      ),

      // Test route for debugging
      GoRoute(
        path: '/test-donor',
        name: 'test-donor',
        builder: (context, state) => const DonorDashboard(),
      ),
    ],
    errorBuilder: (context, state) {
      print('Router Error: ${state.error}');
      print('Attempted path: ${state.matchedLocation}');
      print('Full URI: ${state.uri}');

      return Scaffold(
        appBar: AppBar(
          title: const Text('Navigation Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Path: ${state.matchedLocation}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              if (state.error != null)
                Text(
                  'Error: ${state.error}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(splash),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
