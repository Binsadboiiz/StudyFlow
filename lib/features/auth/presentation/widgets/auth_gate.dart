import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/features/auth/presentation/screens/login_screen.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:studyflow/features/home/presentation/screens/main_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool isChecking = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final authVM = context.read<AuthViewmodel>();

    await authVM.CheckAuthStatus();

    setState(() {
      isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final authVM = context.watch<AuthViewmodel>();

    if(authVM.isAuthenticated) {
      return const MainScreen();
    }
    return const LoginScreen();
  }
}