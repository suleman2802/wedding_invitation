import 'package:flutter_test/flutter_test.dart';

import 'package:wedding_invitation_app/main.dart';

void main() {
  testWidgets('app builds and shows the envelope intro',
      (WidgetTester tester) async {
    await tester.pumpWidget(const WeddingInvitationApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('TAP TO OPEN'), findsOneWidget);
  });
}
