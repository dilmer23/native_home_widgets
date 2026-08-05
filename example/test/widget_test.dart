import 'package:flutter_test/flutter_test.dart';

import 'package:native_home_widgets_example/main.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const NativeHomeWidgetsExampleApp());
    expect(find.text('Native Home Widgets'), findsOneWidget);
  });
}
