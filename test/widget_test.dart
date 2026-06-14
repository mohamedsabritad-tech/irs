import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_app/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NexusApp());
    expect(find.text('Nexus WoS'), findsOneWidget);
  });
}
