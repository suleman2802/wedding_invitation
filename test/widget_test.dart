import 'package:flutter_test/flutter_test.dart';

import 'package:wedding_invitation_app/main.dart';

void main() {
  testWidgets('app builds and shows the envelope intro',
      (WidgetTester tester) async {
    await tester.pumpWidget(const WeddingInvitationApp());
    // Let the loading veil's minimum-delay and network-timeout timers
    // elapse (fake time), then settle the veil fade-out.
    await tester.pump(const Duration(seconds: 13));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('TAP TO OPEN'), findsOneWidget);
  });
}
