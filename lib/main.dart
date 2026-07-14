import 'package:flutter/material.dart';

import 'screens/envelope_screen.dart';
import 'screens/invitation_page.dart';
import 'theme.dart';
import 'wedding_config.dart';

void main() {
  runApp(const WeddingInvitationApp());
}

class WeddingInvitationApp extends StatelessWidget {
  const WeddingInvitationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:
          '${WeddingConfig.groomShort} & ${WeddingConfig.brideShort} — Wedding Invitation',
      debugShowCheckedModeBanner: false,
      theme: buildWeddingTheme(),
      home: const _Root(),
    );
  }
}

/// Invitation page with the envelope overlay on top; the overlay removes
/// itself once its opening animation completes.
class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool _opened = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const InvitationPage(),
        if (!_opened)
          EnvelopeOverlay(
            onOpened: () => setState(() => _opened = true),
          ),
      ],
    );
  }
}
