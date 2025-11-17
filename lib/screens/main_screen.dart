import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'movies/movies_screen.dart';
import 'tv_shows/tv_shows_screen.dart';
import 'search/search_screen.dart';
import 'favorites/favorites_screen.dart';
import 'profile/profile_screen.dart';
import 'user_management/user_management_screen.dart';
import 'auth/login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  late TabController _moviesTabController;
  late TabController _tvTabController;

  @override
  void initState() {
    super.initState();
    // Debug logging to help diagnose freeze after login
    // Remove or adjust later when issue is resolved
    if (kDebugMode) {
      debugPrint('MainScreen: initState called');
    }
    _moviesTabController = TabController(length: 3, vsync: this);
    _tvTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _moviesTabController.dispose();
    _tvTabController.dispose();
    super.dispose();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return MoviesScreen(tabController: _moviesTabController);
      case 1:
        return TVShowsScreen(tabController: _tvTabController);
      case 2:
        return const SearchScreen();
      case 3:
        return const FavoritesScreen();
      default:
        return const SizedBox();
    }
  }

  PreferredSizeWidget? _getAppBarBottom() {
    switch (_currentIndex) {
      case 0:
        return TabBar(
          controller: _moviesTabController,
          tabs: const [
            Tab(text: 'Popular'),
            Tab(text: 'Top Rated'),
            Tab(text: 'Trending'),
          ],
        );
      case 1:
        return TabBar(
          controller: _tvTabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Popular'),
            Tab(text: 'Top Rated'),
            Tab(text: 'Trending'),
            Tab(text: 'Anime'),
          ],
        );
      default:
        return null;
    }
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Movies';
      case 1:
        return 'TV Shows & Anime';
      case 2:
        return 'Search';
      case 3:
        return 'Favorites';
      default:
        return 'App';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('MainScreen: build - currentIndex=$_currentIndex');
    }
    // TabControllers are initialized in initState -- no re-init here to avoid
    // repeated creation/dispose cycles that can freeze the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        centerTitle: true,
        bottom: _getAppBarBottom(),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    backgroundImage: user?.photoPath != null
                        ? FileImage(File(user!.photoPath!))
                        : null,
                    child: user?.photoPath == null
                        ? Icon(
                            Icons.person,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  ),
                  accountName: Text(
                    user?.name ?? 'User',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(
                    user?.email ?? '',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile Saya'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Kelola Data User'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserManagementScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleLogout();
                  },
                ),
              ],
            ),
          );
        },
      ),
      body: _getCurrentScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'Movies',
          ),
          NavigationDestination(
            icon: Icon(Icons.tv_outlined),
            selectedIcon: Icon(Icons.tv),
            label: 'TV Shows',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
