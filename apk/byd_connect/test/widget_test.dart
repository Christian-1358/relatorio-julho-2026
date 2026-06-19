import 'package:flutter_test/flutter_test.dart';
import 'package:byd_connect/app.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const BYDConnectApp());
    expect(find.text('BYD Connect'), findsAny);
  });
}
