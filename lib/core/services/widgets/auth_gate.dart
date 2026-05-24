import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/features/auth/presentation/screens/login_screen.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:studyflow/features/home/presentation/screens/main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewmodel>();

    if(authVM.isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if(authVM.isAuthenticated) {
      return const MainScreen();
    }
    
    return const LoginScreen();
  }
}