import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';
import 'core/api/api_client.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/food_provider.dart';
import 'core/providers/nutrition_provider.dart';
import 'core/router.dart';
import 'core/storage/secure_storage.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const storage = SecureTokenStorage();
  final api = ApiClient(tokenStorage: storage);
  final authProvider = AuthProvider(api: api, storage: storage);
  await authProvider.initialize();

  final app = NutriVitaApp(
    authProvider: authProvider,
    foodProvider: FoodProvider(api: api),
    nutritionProvider: NutritionProvider(api: api),
  );

  runApp(kDebugMode ? DevicePreview(builder: (_) => app) : app);
}

class NutriVitaApp extends StatelessWidget {
  const NutriVitaApp({
    super.key,
    required this.authProvider,
    required this.foodProvider,
    required this.nutritionProvider,
  });

  final AuthProvider authProvider;
  final FoodProvider foodProvider;
  final NutritionProvider nutritionProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<FoodProvider>.value(value: foodProvider),
        ChangeNotifierProvider<NutritionProvider>.value(value: nutritionProvider),
      ],
      child: Builder(
        builder: (context) {
          final router = buildRouter(authProvider);
          return MaterialApp.router(
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            title: 'NutriVita',
            debugShowCheckedModeBanner: false,
            theme: NVTheme.light(),
            darkTheme: NVTheme.dark(),
            themeMode: ThemeMode.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
