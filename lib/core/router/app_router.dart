import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/main_screen.dart';
import '../../presentation/screens/details/movie_detail_screen.dart';
import '../../presentation/screens/home/content_list_screen.dart';
import '../../presentation/screens/watchlist/watchlist_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/admin/admin_user_list_screen.dart';
import '../../presentation/providers/auth_provider.dart';

// We need a provider for the router to handle redirects based on auth state
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: ValueNotifier(authNotifier),
    redirect: (context, state) {
      final isLoggedIn = authNotifier.user != null;
      final isLoggingIn = state.uri.toString() == '/login';
      final isSigningUp = state.uri.toString() == '/signup';
      final isForgotPassword = state.uri.toString() == '/forgot-password';

      if (!isLoggedIn && !isLoggingIn && !isSigningUp && !isForgotPassword) {
        return '/login';
      }
      if (isLoggedIn && (isLoggingIn || isSigningUp || isForgotPassword)) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];
          final initialTab = int.tryParse(tabParam ?? '0') ?? 0;
          return MainScreen(initialTab: initialTab);
        },
        routes: [
          GoRoute(
            path: 'watchlist',
            name: 'watchlist',
            builder: (context, state) => const WatchlistScreen(),
          ),
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: 'admin',
            name: 'admin',
            builder: (context, state) => const AdminUserListScreen(),
          ),
          GoRoute(
            path: 'movie/:id',
            name: 'movie-detail',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              final type = state.uri.queryParameters['type'] ?? 'movie';
              return MovieDetailScreen(movieId: id, mediaType: type);
            },
          ),
          GoRoute(
            path: 'list',
            name: 'content-list',
            builder: (context, state) {
              final title = state.uri.queryParameters['title'] ?? 'List';
              final category = state.uri.queryParameters['category'] ?? '';
              return ContentListScreen(title: title, category: category);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
    ],
  );
});
