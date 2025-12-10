import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/clerk_config.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _tokenCtl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _tokenCtl.dispose();
    super.dispose();
  }

  Future<void> _openClerkHosted() async {
    final uri = Uri.parse('${ClerkConfig.frontendApiUrl}/sign-in');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        setState(() => _error = 'Could not launch Clerk sign-in. Copying URL to clipboard.');
        await Clipboard.setData(ClipboardData(text: uri.toString()));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clerk sign-in URL copied. Open in browser.')));
      }
    } catch (_) {
      if (!mounted) return;
      await Clipboard.setData(ClipboardData(text: uri.toString()));
      setState(() => _error = 'Could not launch Clerk sign-in. URL copied to clipboard.');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clerk sign-in URL copied. Open in browser.')));
    }
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
                     Text('Sign in with Clerk (Google) to manage landmarks.', style: theme.textTheme.bodyMedium),
                     const SizedBox(height: 20),
                     ElevatedButton.icon(
                       onPressed: _loading ? null : _openClerkHosted,
                       icon: const Icon(Icons.login),
                       label: const Text('Sign in with Clerk (opens browser)'),
                     ),
                     const SizedBox(height: 12),
                     Text('After signing in, paste the Clerk session/JWT here. Backend must verify this token.', style: theme.textTheme.bodySmall),
                     const SizedBox(height: 8),
                     TextField(
                       controller: _tokenCtl,
                       decoration: const InputDecoration(labelText: 'Clerk session/JWT'),
                     ),
                     const SizedBox(height: 8),
                     ElevatedButton.icon(
                       onPressed: _loading
                           ? null
                           : () async {
                               if (_tokenCtl.text.trim().isEmpty) return;
                               setState(() {
                                 _loading = true;
                                 _error = null;
                               });
                               await AuthService().setExternalToken(_tokenCtl.text.trim());
                               if (!mounted) return;
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clerk token applied')));
                               setState(() => _loading = false);
                             },
                       icon: const Icon(Icons.vpn_key),
                       label: const Text('Apply Clerk Token'),
                     ),
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
