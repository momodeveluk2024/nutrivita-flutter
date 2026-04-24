import 'package:flutter_test/flutter_test.dart';

import 'package:myapplication/main.dart';

void main() {
  testWidgets('NutriVita boots to splash', (WidgetTester tester) async {
    await tester.pumpWidget(const NutriVitaApp());
    expect(find.text('NutriVita'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });
}
