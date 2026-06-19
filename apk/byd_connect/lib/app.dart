import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/car_repository.dart';
import 'data/connection/connection_manager.dart';
import 'presentation/screens/home/dashboard_screen.dart';
import 'presentation/screens/cameras/cameras_screen.dart';
import 'presentation/screens/status/car_status_screen.dart';
import 'presentation/screens/climate/climate_screen.dart';
import 'presentation/screens/commands/commands_screen.dart';
import 'presentation/screens/commands/windows_screen.dart';
import 'presentation/screens/commands/trunk_screen.dart';
import 'presentation/screens/seats/seats_screen.dart';
import 'presentation/screens/media/media_screen.dart';
import 'presentation/screens/battery/battery_screen.dart';
import 'presentation/screens/location/location_screen.dart';
import 'presentation/screens/sentinel/sentinel_screen.dart';
import 'presentation/screens/connection/connection_screen.dart';
import 'core/theme/app_colors.dart';

class BYDConnectApp extends StatelessWidget {
  const BYDConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CarRepository()),
        ChangeNotifierProvider(create: (_) => ConnectionManager()),
      ],
      child: MaterialApp(
        title: 'BYD Connect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigation(),
        routes: {
          '/commands/windows': (_) => const WindowsScreen(),
          '/commands/trunk': (_) => const TrunkScreen(),
          '/sentinel': (_) => const SentinelScreen(),
          '/seats': (_) => const SeatsScreen(),
          '/climate': (_) => const ClimateScreen(),
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    CamerasScreen(),
    CarStatusScreen(),
    ClimateScreen(),
    CommandsScreen(),
    SeatsScreen(),
    MediaScreen(),
    BatteryScreen(),
    LocationScreen(),
    SentinelScreen(),
    ConnectionScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Início',
    ),
    NavigationDestination(
      icon: Icon(Icons.videocam_outlined),
      selectedIcon: Icon(Icons.videocam),
      label: 'Câmeras',
    ),
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Status',
    ),
    NavigationDestination(
      icon: Icon(Icons.location_on_outlined),
      selectedIcon: Icon(Icons.location_on),
      label: 'Local',
    ),
    NavigationDestination(
      icon: Icon(Icons.shield_outlined),
      selectedIcon: Icon(Icons.shield),
      label: 'Sentinela',
    ),
    NavigationDestination(
      icon: Icon(Icons.cloud_outlined),
      selectedIcon: Icon(Icons.cloud),
      label: 'Ajustes',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.glassBorder, width: 0.5),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: _destinations,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
    );
  }
}
