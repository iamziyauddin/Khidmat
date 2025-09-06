import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'ui/theme/app_theme.dart';
import 'routing/app_router.dart';
import 'services/database_service.dart';
import 'utils/sample_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseService.instance.initialize();

  // Seed sample data for testing
  await SampleDataSeeder.seedSampleData();

  runApp(const ProviderScope(child: KhidmatApp()));
}

class KhidmatApp extends StatelessWidget {
  const KhidmatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 13 size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Khidmat - Help & Donate',
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: widget!,
            );
          },
        );
      },
    );
  }
}
