import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:opendevlog/app.dart';

void main() {
  testWidgets('App loads setup screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const OpenDevLogApp());
    await tester.pumpAndSettle();

    expect(find.text('First-time setup'), findsOneWidget);
  });
}
