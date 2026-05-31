import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

/// Application entry point.
///
/// Sets the status bar to transparent for seamless gradient backgrounds,
/// and wraps the app in Riverpod's [ProviderScope].
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Make the status bar transparent so the gradient extends to the top
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: AtmosApp(),
    ),
  );
}
