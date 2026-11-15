import 'package:flutter_test/flutter_test.dart';
import 'package:latres/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(const RickAndMortyApp(isLoggedIn: false));
    expect(find.text('Rick & Morty'), findsOneWidget);
  });
}
