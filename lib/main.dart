import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/map_screen.dart';
import 'screens/list_screen.dart';
import 'screens/new_entry_screen.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	runApp(const LandmarkApp());
}

class LandmarkApp extends StatelessWidget {
	const LandmarkApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Bangladesh Landmarks',
			theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF006E7F)),
			home: const HomeScreen(),
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
	final List<Widget> _pages = const [MapScreen(), ListScreen(), NewEntryScreen()];

	@override
	Widget build(BuildContext context) {
		return Scaffold(
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
