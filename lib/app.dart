import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/weather/presentation/providers/theme_provider.dart';
import 'features/weather/presentation/screens/home_screen.dart';

/// Root application widget.
///
/// Wraps the app in a [ProviderScope] for Riverpod state management,
/// and switches between dark and light themes based on user preference.
class AtmosApp extends ConsumerWidget {
  const AtmosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Atmos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
