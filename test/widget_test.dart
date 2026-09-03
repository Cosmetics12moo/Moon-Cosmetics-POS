import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cosmetics_pos/app.dart';

void main() {
  testWidgets('Moon Cosmetics POS app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const MoonCosmeticsApp());
    expect(find.text('POS / Sales'), findsOneWidget);
  });
}
