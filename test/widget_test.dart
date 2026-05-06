import 'package:flutter_test/flutter_test.dart';

import 'package:smart_event_checkin/main.dart';

void main() {
  testWidgets('EVENTLY landing screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const EVENTLYApp());

    expect(find.text('EVENTLY'), findsOneWidget);
    expect(find.text('Create your event'), findsOneWidget);
    expect(find.text('Event Name'), findsOneWidget);
    expect(find.text('Create Event'), findsOneWidget);
  });
}
