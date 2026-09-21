import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_plus/main.dart';

void main() {
  testWidgets('MediCareApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MediCareApp(),
      ),
    );

    expect(find.text('MediCare'), findsWidgets);

    // Pump timer to navigate to onboarding
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Consult the Best Doctors Anytime, Anywhere'), findsOneWidget);
  });
}
