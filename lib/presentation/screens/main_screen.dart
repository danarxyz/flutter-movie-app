import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/responsive/responsive_layout.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'watchlist/watchlist_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialTab;
  
  const MainScreen({super.key, this.initialTab = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _currentIndex = widget.initialTab;
      });
    }
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    WatchlistScreen(),
    ProfileScreen(),
  ];

  List<NavigationDestination> get _mobileDestinations => [
    NavigationDestination(
      icon: Icon(Icons.home_outlined, color: AppTheme.textSecondary),
      selectedIcon: const Icon(Icons.home, color: Colors.white),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.search_outlined, color: AppTheme.textSecondary),
      selectedIcon: const Icon(Icons.search, color: Colors.white),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(Icons.bookmark_outline, color: AppTheme.textSecondary),
      selectedIcon: const Icon(Icons.bookmark, color: Colors.white),
      label: 'Watchlist',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline, color: AppTheme.textSecondary),
      selectedIcon: const Icon(Icons.person, color: Colors.white),
      label: 'Profile',
    ),
  ];

  List<NavigationRailDestination> get _desktopDestinations => [
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined, color: AppTheme.textSecondary),
      selectedIcon: const Icon(Icons.home, color: Colors.white),
      label: const Text('Home'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.search_outlined, color: AppTheme.textSecondary),
      selectedIcon: const Icon(Icons.search, color: Colors.white),
      label: const Text('Search'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.bookmark_outline, color: AppTheme.textSecondary),
      selectedIcon: const Icon(Icons.bookmark, color: Colors.white),
      label: const Text('Watchlist'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outline, color: AppTheme.textSecondary),
      selectedIcon: const Icon(Icons.person, color: Colors.white),
      label: const Text('Profile'),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onItemTapped,
          destinations: _mobileDestinations,
          backgroundColor: const Color(0xFF1A0D0E).withValues(alpha: 0.95),
          indicatorColor: AppTheme.primary,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
      desktopBody: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              destinations: _desktopDestinations,
              backgroundColor: const Color(0xFF1A0D0E),
              indicatorColor: AppTheme.primary,
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedIconTheme: IconThemeData(color: AppTheme.textSecondary),
              selectedLabelTextStyle: const TextStyle(color: Colors.white, fontSize: 10),
              unselectedLabelTextStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


