import 'package:flutter/material.dart';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: ClerkAuthentication(),
          ),
        ),
      ),
    );
  }
}
