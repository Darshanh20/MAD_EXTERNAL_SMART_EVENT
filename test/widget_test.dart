import 'package:flutter_test/flutter_test.dart';

import 'package:mad/main.dart';

void main() {
  testWidgets('Welcome screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('MyApp'), findsOneWidget);
    expect(find.text('Your journey starts here'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('View Profile'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });
}
