import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/map_screen.dart';
import 'screens/list_screen.dart';
import 'screens/new_entry_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await AuthService().init();
	const publishableKey = String.fromEnvironment('CLERK_PUBLISHABLE_KEY', defaultValue: 'pk_test_c3VtbWFyeS1lZnQtMTkuY2xlcmsuYWNjb3VudHMuZGV2JA');
	runApp(LandmarkApp(publishableKey: publishableKey));
}

class LandmarkApp extends StatelessWidget {
	const LandmarkApp({super.key, required this.publishableKey});

	final String publishableKey;

	@override
	Widget build(BuildContext context) {
		return ClerkAuth(
			config: ClerkAuthConfig(publishableKey: publishableKey),
			child: ClerkErrorListener(
				child: MaterialApp(
					title: 'Bangladesh Landmarks',
					localizationsDelegates: const [
						ClerkSdkLocalizations.delegate,
						GlobalMaterialLocalizations.delegate,
						GlobalWidgetsLocalizations.delegate,
						GlobalCupertinoLocalizations.delegate,
					],
					supportedLocales: ClerkSdkLocalizations.supportedLocales,
					theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF006E7F)),
					darkTheme: ThemeData.dark().copyWith(
						colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006E7F), brightness: Brightness.dark),
						useMaterial3: true,
					),
					themeMode: ThemeMode.system,
					home: const AuthGate(),
				),
			),
		);
	}
}

class AuthGate extends StatelessWidget {
	const AuthGate({super.key});

	@override
	Widget build(BuildContext context) {
		return ClerkAuthBuilder(
			builder: (context, _) => const Center(child: CircularProgressIndicator()),
			signedOutBuilder: (_, __) => const LoginScreen(),
			signedInBuilder: (_, authState) => _SessionTokenSync(authState: authState, child: const HomeScreen()),
		);
	}
}

class HomeScreen extends StatefulWidget {
	const HomeScreen({super.key});

	@override
	State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
	int _index = 0;
	final List<Widget> _pages = [const MapScreen(), const ListScreen(embedded: true), const NewEntryScreen(embedded: true)];

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Bangladesh Landmarks'),
				actions: [
					IconButton(
						icon: const Icon(Icons.logout),
						tooltip: 'Sign out',
						onPressed: () async {
							await ClerkAuth.of(context).signOut();
							await AuthService().logout();
							if (mounted) {
								ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed out')));
							}
						},
					),
				],
			),
			body: SafeArea(child: _pages[_index]),
			bottomNavigationBar: NavigationBar(
				selectedIndex: _index,
				onDestinationSelected: (i) => setState(() => _index = i),
				destinations: const [
					NavigationDestination(icon: Icon(Icons.map), label: 'Overview'),
					NavigationDestination(icon: Icon(Icons.list), label: 'Records'),
					NavigationDestination(icon: Icon(Icons.add), label: 'New Entry'),
				],
			),
		);
	}
}

class _SessionTokenSync extends StatefulWidget {
	const _SessionTokenSync({required this.authState, required this.child});
	final ClerkAuthState authState;
	final Widget child;

	@override
	State<_SessionTokenSync> createState() => _SessionTokenSyncState();
}

class _SessionTokenSyncState extends State<_SessionTokenSync> {
	String? _appliedToken;
	late final StreamSubscription _sub;

	@override
	void initState() {
		super.initState();
		_applyInitial();
		_sub = widget.authState.sessionTokenStream.listen((token) => _applyToken(token.jwt));
	}

	Future<void> _applyInitial() async {
		final token = await widget.authState.sessionToken();
		_applyToken(token.jwt);
	}

	Future<void> _applyToken(String jwt) async {
		if (AuthService().token == jwt) {
			if (mounted) setState(() => _appliedToken = jwt);
			return;
		}
		await AuthService().setExternalToken(jwt);
		if (mounted) setState(() => _appliedToken = jwt);
	}

	@override
	void dispose() {
		_sub.cancel();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		if (_appliedToken == null) {
			return const Scaffold(body: Center(child: CircularProgressIndicator()));
		}
		return widget.child;
	}
}
