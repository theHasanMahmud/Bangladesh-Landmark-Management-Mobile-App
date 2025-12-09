import 'package:flutter/material.dart';
import 'screens/map_screen.dart';
import 'screens/list_screen.dart';
import 'screens/new_entry_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await AuthService().init();
	runApp(const LandmarkApp());
}

class LandmarkApp extends StatelessWidget {
	const LandmarkApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Bangladesh Landmarks',
			theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF006E7F)),
			darkTheme: ThemeData.dark().copyWith(
				colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006E7F), brightness: Brightness.dark),
				useMaterial3: true,
			),
			themeMode: ThemeMode.system,
			home: const AuthGate(),
		);
	}
}

class AuthGate extends StatelessWidget {
	const AuthGate({super.key});

	@override
	Widget build(BuildContext context) {
		return ValueListenableBuilder<bool>(
			valueListenable: AuthService().isLoggedIn,
			builder: (_, loggedIn, __) => loggedIn ? const HomeScreen() : const LoginScreen(),
>>>>>>> 63889ed (feat: add login gate and secured API headers)
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
							await AuthService().logout();
							if (!mounted) return;
							ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed out')));
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
