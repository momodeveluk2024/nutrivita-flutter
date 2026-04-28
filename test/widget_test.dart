import 'package:flutter_test/flutter_test.dart';

import 'package:myapplication/core/api/api_client.dart';
import 'package:myapplication/core/providers/auth_provider.dart';
import 'package:myapplication/core/providers/food_provider.dart';
import 'package:myapplication/core/providers/nutrition_provider.dart';
import 'package:myapplication/core/providers/reminder_provider.dart';
import 'package:myapplication/core/storage/secure_storage.dart';
import 'package:myapplication/main.dart';

void main() {
  testWidgets('Nutrimate boots to splash', (WidgetTester tester) async {
    const storage = SecureTokenStorage();
    final api = ApiClient(tokenStorage: storage);
    await tester.pumpWidget(
      NutrimateApp(
        authProvider: AuthProvider(api: api, storage: storage),
        foodProvider: FoodProvider(api: api),
        nutritionProvider: NutritionProvider(api: api),
        reminderProvider: ReminderProvider(api: api),
      ),
    );
    expect(find.text('Nutrimate'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });
}
