import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:studyflow/core/di/injection.dart';
import 'package:studyflow/core/services/notification/notification_service.dart';
import 'package:studyflow/core/services/widgets/auth_gate.dart';
import 'package:studyflow/core/services/widgets/global_snackbar.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure the Flutter framework is initialized before calling native or async code.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data for the intl package (to format dates based on device language).
  await initializeDateFormatting();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("STEP 1");

  // Initialize all dependencies (database, repositories, etc.) before running the UI.
  await DependencyInjection.init();
  print("STEP 2");

  // Start rendering the application.
  runApp(const StudyFlowApp());

  print("STEP 3");
}

/// The root widget of the application.
/// Uses `MultiProvider` to inject state (ViewModels) down the entire widget tree.
class StudyFlowApp extends StatelessWidget {
  /// Constructor for StudyFlowApp.
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Retrieve the list of Providers from DependencyInjection
      providers: DependencyInjection.getProviders(),
      // Consumer listens to ThemeProvider changes to automatically update the theme (Light/Dark/System)
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'StudyFlow',
            // Configure default light theme
            theme: AppTheme.lightTheme,
            // Configure dark theme
            darkTheme: AppTheme.darkTheme,
            // The currently selected theme mode (retrieved from ThemeProvider)
            themeMode: themeProvider.themeMode,
            scaffoldMessengerKey:
                NotificationService.instance.scaffoldMessengerKey,
            // This builder wraps the entire app with GlobalSnackbar to display notifications anywhere
            builder: (context, child) {
              return GlobalSnackbar(child: child!);
            },
            // The initial screen loaded is AuthGate to check authentication status
            home: const AuthGate(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
