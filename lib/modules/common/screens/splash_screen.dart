import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/app_router.dart';
import '../../../services/database_service.dart';
import '../../../local_db/models/user_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _taglineController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _taglineFadeAnimation;
  late Animation<Offset> _taglineSlideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateBasedOnAuth();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _taglineController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeInOut),
    );

    _taglineSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _taglineController,
            curve: Curves.easeOutBack,
          ),
        );

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      _taglineController.forward();
    });
  }

  Future<void> _navigateBasedOnAuth() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final currentUser = DatabaseService.instance.getCurrentUser();

    if (currentUser != null) {
      // User is logged in, navigate to appropriate dashboard
      if (currentUser.role == UserRole.applicant) {
        context.go(AppRouter.applicantDashboard);
      } else {
        context.go(AppRouter.donorDashboard);
      }
    } else {
      // No user logged in, go to role selection
      context.go(AppRouter.roleSelection);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Animation
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 60,
                        color: Color(0xFF2C7A7B),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Name
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: Text(
                      'Khidmat',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tagline
                  SlideTransition(
                    position: _taglineSlideAnimation,
                    child: FadeTransition(
                      opacity: _taglineFadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Connecting Hearts,\nTransforming Lives',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                height: 1.4,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loading indicator
            Padding(
              padding: const EdgeInsets.all(32),
              child: FadeTransition(
                opacity: _taglineFadeAnimation,
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
