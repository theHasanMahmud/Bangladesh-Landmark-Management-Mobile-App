import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/clerk_config.dart';
import '../services/auth_service.dart';
import 'clerk_webview_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _tokenCtl = TextEditingController();
  late final TextEditingController _urlCtl;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _tokenCtl.dispose();
    _urlCtl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _urlCtl = TextEditingController(text: ClerkConfig.defaultSignInUrl);
  }

  Future<void> _openClerkHosted() async {
    // Prefer in-app webview to capture callback token.
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClerkWebViewScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   crossAxisAlignment: CrossAxisAlignment.stretch,
                   children: [
                     Text('Bangladesh Landmarks', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                     const SizedBox(height: 12),
                     Text('Sign in with Google (Clerk) to manage landmarks.', style: theme.textTheme.bodyMedium),
                     const SizedBox(height: 20),
                     ElevatedButton.icon(
                       onPressed: _loading ? null : _openClerkHosted,
                       icon: const Icon(Icons.login),
                       label: const Text('Sign in with Google'),
                     ),
                     const SizedBox(height: 8),
                     const SizedBox(height: 12),
                     Text('This button opens an in-app sign-in page. Configure Clerk to redirect to com.example.vangti_chai://clerk-callback?token=YOUR_JWT so the app can capture your session automatically.', style: theme.textTheme.bodySmall),
                     if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
                   ],
                 ),
               ),
             ),
           ),
         ),
       ),
    );
  }
}
