import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config/clerk_config.dart';
import '../services/auth_service.dart';

class ClerkWebViewScreen extends StatefulWidget {
  const ClerkWebViewScreen({super.key});

  @override
  State<ClerkWebViewScreen> createState() => _ClerkWebViewScreenState();
}

class _ClerkWebViewScreenState extends State<ClerkWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  String _currentUrl = ClerkConfig.defaultSignInUrl;
  final _callbackScheme = 'com.example.vangti_chai';

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) => setState(() {
          _currentUrl = url;
          _loading = true;
        }),
        onPageFinished: (_) => setState(() => _loading = false),
        onNavigationRequest: (req) {
          if (req.url.startsWith('$_callbackScheme://clerk-callback')) {
            final uri = Uri.parse(req.url);
            final token = uri.queryParameters['token'];
            if (token != null) {
              AuthService().setExternalToken(token);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed in with Clerk')));
                Navigator.of(context).pop();
              }
              return NavigationDecision.prevent;
            }
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(ClerkConfig.defaultSignInUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in with Google'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.05),
              padding: const EdgeInsets.all(8),
              child: Text(
                _currentUrl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          )
        ],
      ),
    );
  }
}
