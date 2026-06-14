import 'package:flutter/material.dart';
import 'core/preferences.dart';
import 'screens/login_screen.dart';
import 'screens/accounts_screen.dart';
import 'screens/transfer_screen.dart';
import 'screens/redeem_screen.dart';
import 'screens/history_screen.dart';
import 'screens/activity_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.init();
  runApp(const NexusApp());
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus WoS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: Preferences.isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;

  final _screens = [
    const AccountsScreen(),
    const TransferScreen(),
    const RedeemScreen(),
    const HistoryScreen(),
    const ActivityScreen(),
    const AdminScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _page, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _page,
        onDestinationSelected: (i) => setState(() => _page = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.people), label: 'Accounts'),
          NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Transfer'),
          NavigationDestination(icon: Icon(Icons.redeem), label: 'Redeem'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.timeline), label: 'Activity'),
          NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
