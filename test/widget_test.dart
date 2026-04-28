import 'package:flutter_test/flutter_test.dart';

import 'package:myapplication/core/api/api_client.dart';
import 'package:myapplication/core/providers/auth_provider.dart';
import 'package:myapplication/core/providers/food_provider.dart';
import 'package:myapplication/core/providers/nutrition_provider.dart';
import 'package:myapplication/core/providers/reminder_provider.dart';
import 'package:myapplication/core/storage/secure_storage.dart';
import 'package:myapplication/main.dart';

class _InitializedAuthProvider extends AuthProvider {
  _InitializedAuthProvider({required super.api, required super.storage});

  @override
  bool get initialized => true;

  @override
  bool get isAuthenticated => false;
}

void main() {
  testWidgets('Nutrimate boots to splash', (WidgetTester tester) async {
    const storage = SecureTokenStorage();
    final api = ApiClient(tokenStorage: storage);
    await tester.pumpWidget(
      NutrimateApp(
        authProvider: _InitializedAuthProvider(api: api, storage: storage),
        foodProvider: FoodProvider(api: api),
        nutritionProvider: NutritionProvider(api: api),
        reminderProvider: ReminderProvider(api: api),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Skip'), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Nutrimate'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });
}
