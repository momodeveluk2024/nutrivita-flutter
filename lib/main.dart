import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'theme.dart';
import 'screens/splash.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const NutriVitaApp(),
    ),
  );
}

class NutriVitaApp extends StatelessWidget {
  const NutriVitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'NutriVita',
      debugShowCheckedModeBanner: false,
      theme: NVTheme.light(),
      darkTheme: NVTheme.dark(),
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
