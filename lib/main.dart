import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/movie_provider.dart';
import 'providers/tv_provider.dart';
import 'providers/search_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => TvProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'Movie Recommendation',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0097A7), // Vibrant Teal/Cyan
            brightness: Brightness.light,
            primary: const Color(0xFF00838F),
            secondary: const Color(0xFFFF6F00), // Orange accent
            tertiary: const Color(0xFF7B1FA2), // Purple tertiary
            surface: const Color(0xFFFAFAFA),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
            shadowColor: Colors.black26,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00BCD4), // Bright Cyan for dark
            brightness: Brightness.dark,
            primary: const Color(0xFF00ACC1),
            secondary: const Color(0xFFFFB300), // Amber accent
            tertiary: const Color(0xFFAB47BC), // Lighter purple
            surface: const Color(0xFF1E1E1E),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
            shadowColor: Colors.black45,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
      ),
    );
  }
}
