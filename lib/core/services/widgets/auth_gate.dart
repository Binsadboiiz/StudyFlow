import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/features/auth/presentation/screens/login_screen.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:studyflow/features/home/presentation/screens/main_screen.dart';

/// A widget that acts as an entry point gatekeeper.
/// It checks the authentication status and navigates the user to the appropriate screen.
class AuthGate extends StatelessWidget {
  /// Constructor for [AuthGate].
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the authentication view model to respond to auth state changes.
    final authVM = context.watch<AuthViewmodel>();

    // Show a loading indicator while checking the authentication status.
    if(authVM.isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Navigate to the main screen if the user is authenticated.
    if(authVM.isAuthenticated) {
      return const MainScreen();
    }
    
    // Default to the login screen for unauthenticated users.
    return const LoginScreen();
  }
}