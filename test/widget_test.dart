import 'package:flutter_test/flutter_test.dart';
import 'package:stoxy/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    // 1. Change 'StoxyApp' to 'MyApp' (or whatever your class is named in main.dart)
    // 2. Remove 'const' because Firebase apps are dynamic
    await tester.pumpWidget(MyApp());

    // Note: This default counter test will likely fail now because
    // your app starts with a Login screen, not a counter.
    // This is normal!
  });
}
