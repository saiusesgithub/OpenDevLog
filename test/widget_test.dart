import 'package:flutter_test/flutter_test.dart';
import 'package:opendevlog/app.dart';

void main() {
  testWidgets('App loads setup screen', (WidgetTester tester) async {
    await tester.pumpWidget(const OpenDevLogApp());

    expect(find.text('Open DevLog'), findsWidgets);
    expect(find.text('First-time setup'), findsOneWidget);
  });
}
