import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';
import '../wedding_config.dart';
import '../widgets/countdown.dart';
import '../widgets/couple_illustration.dart';
import '../widgets/floral.dart';
import '../widgets/flower_band.dart';
import '../widgets/gentle_float.dart';
import '../widgets/map_preview.dart';
import '../widgets/petal_rain.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/torn_edge.dart';

/// The scrolling invitation, laid out as a phone-width column centred on a
/// deep burgundy page — sections alternate cream / burgundy with torn edges.
class InvitationPage extends StatelessWidget {
  const InvitationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WeddingColors.darkestBurgundy,
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Container(
              color: WeddingColors.cream,
              child: Column(
                children: [
                  const _HeroSection(),
                  const _IslamicSection(),
                  TornSection(
                    color: WeddingColors.burgundy,
                    seed: 3,
                    child: const _WelcomeMessage(),
                  ),
                  const _CountdownSection(),
                  TornSection(
                    color: WeddingColors.burgundy,
                    seed: 5,
                    child: const _EventsIntro(),
                  ),
                  for (var i = 0; i < WeddingConfig.events.length; i++) ...[
                    _EventSection(
                      event: WeddingConfig.events[i],
                      index: i,
                    ),
                  ],
                  const _DetailsSection(),
                  TornSection(
                    color: WeddingColors.burgundy,
                    tearBottom: false,
                    seed: 17,
                    padding: const EdgeInsets.fromLTRB(28, 72, 28, 56),
                    child: const _ClosingSection(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

class _HeroSection extends StatefulWidget {
  const _HeroSection();

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _position = Scrollable.maybeOf(context)?.position;
  }

  double get _scroll => (_position?.pixels ?? 0).clamp(0.0, 900.0);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: (height * 0.92).clamp(560.0, 820.0),
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dusk-sky watercolour gradient.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6D7FA3),
                  Color(0xFF93A0BC),
                  Color(0xFFC5B6BC),
                  Color(0xFFE8D3C3),
                ],
                stops: [0.0, 0.38, 0.72, 1.0],
              ),
            ),
          ),
          // Soft breathing glow behind the names.
          Align(
            alignment: const Alignment(0, -0.1),
            child: GentleFloat(
              dy: 0,
              scale: 0.08,
              period: const Duration(seconds: 6),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.30),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const PetalRain(count: 18),
          // Text layers drift at different speeds while scrolling away,
          // giving the hero a sense of depth.
          AnimatedBuilder(
            animation: _position ?? const AlwaysStoppedAnimation<double>(0),
            builder: (context, _) => Column(
              children: [
                const SizedBox(height: 48),
                Transform.translate(
                  offset: Offset(0, _scroll * 0.42),
                  child: Column(
                    children: [
                      Text(
                        'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
                        textDirection: TextDirection.rtl,
                        style: WeddingType.arabic(
                            size: 24,
                            color: Colors.white,
                            shadows: _textShadow),
                      ),
                      const SizedBox(height: 10),
                      Text('Wedding Days',
                          style: WeddingType.script(
                              size: 34, shadows: _textShadow)),
                      const SizedBox(height: 6),
                      Text(
                        '22 · 24 · 25 OCTOBER 2026',
                        style: WeddingType.caps(
                            size: 14, color: Colors.white, letterSpacing: 4),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Transform.translate(
                  offset: Offset(0, _scroll * 0.26),
                  child: Column(
                    children: [
                      _heroName(WeddingConfig.groomName),
                      const SizedBox(height: 6),
                      _parentLine('SON OF ${WeddingConfig.groomFatherName}'),
                      const SizedBox(height: 10),
                      Text('&',
                          style: WeddingType.script(
                              size: 36, shadows: _textShadow)),
                      const SizedBox(height: 10),
                      _heroName(WeddingConfig.brideName),
                      const SizedBox(height: 6),
                      _parentLine(
                          'DAUGHTER OF ${WeddingConfig.brideFatherName}'),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
          // Floral band anchored to the bottom edge.
          const Align(
            alignment: Alignment.bottomCenter,
            child: FlowerBand(height: 170),
          ),
        ],
      ),
    );
  }

  /// "Son of / Daughter of" line under each name.
  Widget _parentLine(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: WeddingType.caps(
        size: 12,
        color: Colors.white.withValues(alpha: 0.92),
        letterSpacing: 3,
      ).copyWith(shadows: _textShadow),
    );
  }

  /// Full name in script, scaled down if it is too wide for the screen.
  Widget _heroName(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(name,
            maxLines: 1,
            style: WeddingType.script(size: 58, shadows: _textShadow)),
      ),
    );
  }

  static final List<Shadow> _textShadow = [
    Shadow(
      color: const Color(0xFF2E3A55).withValues(alpha: 0.55),
      offset: const Offset(0, 2),
      blurRadius: 10,
    ),
  ];
}

// ---------------------------------------------------------------------------
// Marriage in Islam
// ---------------------------------------------------------------------------

class _IslamicSection extends StatelessWidget {
  const _IslamicSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 30),
      child: RevealOnScroll(
        child: Column(
          children: [
            Text(
              'Marriage in Islam',
              style: WeddingType.script(size: 34, color: WeddingColors.burgundy),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            const OrnamentDivider(),
            const SizedBox(height: 26),
            Text(
              'وَمِنْ آيَاتِهِ أَنْ خَلَقَ لَكُم مِّنْ أَنفُسِكُمْ أَزْوَاجًا لِّتَسْكُنُوا إِلَيْهَا وَجَعَلَ بَيْنَكُم مَّوَدَّةً وَرَحْمَةً ۚ إِنَّ فِي ذَٰلِكَ لَآيَاتٍ لِّقَوْمٍ يَتَفَكَّرُونَ',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: WeddingType.arabic(
                size: 22,
                color: WeddingColors.burgundy,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '"And among His signs is that He created for you spouses from '
              'among yourselves, so that you may find tranquillity in them; '
              'and He placed between you love and mercy. Indeed, in that are '
              'signs for people who reflect."',
              style: WeddingType.serif(size: 17.5).copyWith(
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'SURAH AR-RUM · 30:21',
              style: WeddingType.caps(
                size: 11,
                color: WeddingColors.gold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 26),
            const OrnamentDivider(),
            const SizedBox(height: 26),
            Text(
              'Nikkah is a sacred covenant and a beautiful Sunnah — with the '
              'blessings of Allah and the prayers of our loved ones, we begin '
              'this journey of love, mercy and tranquillity together.',
              style: WeddingType.serif(size: 17),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Welcome message
// ---------------------------------------------------------------------------

class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    return RevealOnScroll(
      child: Column(
        children: [
          Text('Dear Friends and Family,',
              style: WeddingType.script(size: 36), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Text(
            'With hearts full of joy, and by the grace of Allah, '
            'we invite you to celebrate the beginning of our new life together.',
            style: WeddingType.serif(size: 19, color: WeddingColors.softCream),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Text(
            'Your presence and prayers mean the world to us, and we would be '
            'honoured to share these three days of celebration with you.',
            style: WeddingType.serif(size: 19, color: WeddingColors.softCream),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Countdown
// ---------------------------------------------------------------------------

class _CountdownSection extends StatelessWidget {
  const _CountdownSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: RevealOnScroll(
        child: Column(
          children: [
            Text(
              'The Celebration Begins In',
              style: WeddingType.script(
                  size: 34, color: WeddingColors.burgundy),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            CountdownTimer(target: WeddingConfig.countdownTarget),
            const SizedBox(height: 18),
            const OrnamentDivider(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

class _EventsIntro extends StatelessWidget {
  const _EventsIntro();

  @override
  Widget build(BuildContext context) {
    return RevealOnScroll(
      child: Column(
        children: [
          Text('Three Days of Celebration',
              style: WeddingType.script(size: 36), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text(
            'From the colours of the Mehndi to the elegance of the Walima — '
            'here is everything you need to know.',
            style: WeddingType.serif(size: 18, color: WeddingColors.softCream),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EventSection extends StatelessWidget {
  final WeddingEvent event;
  final int index;
  const _EventSection({required this.event, required this.index});

  @override
  Widget build(BuildContext context) {
    final onBurgundy = index.isOdd;
    final bg = onBurgundy ? WeddingColors.burgundy : WeddingColors.cream;
    final fg = onBurgundy ? WeddingColors.softCream : WeddingColors.inkOnCream;
    final accent = onBurgundy ? WeddingColors.softCream : WeddingColors.burgundy;

    final content = RevealOnScroll(
      child: Column(
        children: [
          Text(event.name,
              style: WeddingType.script(size: 44, color: accent),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(event.dateLabel.toUpperCase(),
              style: WeddingType.caps(size: 14, color: fg, letterSpacing: 3.5)),
          const SizedBox(height: 10),
          Text(event.tagline,
              style: WeddingType.serif(
                  size: 17,
                  color: fg.withValues(alpha: 0.85),
                  height: 1.4),
              textAlign: TextAlign.center),
          const SizedBox(height: 30),
          _ScheduleTimeline(items: event.schedule, color: fg),
          const SizedBox(height: 30),
          Text(event.venueName,
              style: WeddingType.display(size: 20, color: fg),
              textAlign: TextAlign.center),
          if (event.venueAddress.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(event.venueAddress,
                style: WeddingType.serif(size: 16, color: fg),
                textAlign: TextAlign.center),
          ],
          if (event.mapQuery != null) ...[
            const SizedBox(height: 18),
            MapPreview(query: event.mapQuery!, openUrl: event.mapUrl),
          ],
          const SizedBox(height: 16),
          _MapButton(event: event, onBurgundy: onBurgundy),
          if (event.dressNote.isNotEmpty || event.palette.isNotEmpty) ...[
            const SizedBox(height: 26),
            const OrnamentDivider(),
            const SizedBox(height: 22),
            Text('Dress Code',
                style:
                    WeddingType.caps(size: 13, color: fg, letterSpacing: 3)),
            if (event.dressNote.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(event.dressNote,
                  style: WeddingType.serif(
                      size: 17, color: fg.withValues(alpha: 0.9)),
                  textAlign: TextAlign.center),
            ],
            if (event.palette.isNotEmpty) ...[
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final c in event.palette)
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: fg.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );

    if (onBurgundy) {
      return TornSection(
        color: bg,
        seed: 20 + index * 7,
        padding: const EdgeInsets.symmetric(vertical: 76, horizontal: 28),
        child: content,
      );
    }
    return Container(
      color: bg,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 28),
      child: content,
    );
  }
}

/// Schedule timeline with a rose that travels along the centre line as the
/// page scrolls: it holds a fixed height on screen, so it glides from the
/// first event point to the last while the schedule moves beneath it, parking
/// at either end when the section enters or leaves the viewport.
class _ScheduleTimeline extends StatefulWidget {
  final List<ScheduleItem> items;
  final Color color;
  const _ScheduleTimeline({required this.items, required this.color});

  @override
  State<_ScheduleTimeline> createState() => _ScheduleTimelineState();
}

class _ScheduleTimelineState extends State<_ScheduleTimeline> {
  static const double _flowerSize = 48;

  /// Fraction of the viewport height where the flower rides on screen.
  static const double _anchor = 0.55;

  final ValueNotifier<double> _flowerTop = ValueNotifier(0);
  ScrollPosition? _position;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (!identical(position, _position)) {
      _position?.removeListener(_update);
      _position = position;
      _position?.addListener(_update);
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_update);
    _flowerTop.dispose();
    super.dispose();
  }

  void _update() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final viewportHeight = MediaQuery.of(context).size.height;
    final maxTop = box.size.height - _flowerSize;
    if (maxTop <= 0) return;
    final target = viewportHeight * _anchor - top - _flowerSize / 2;
    _flowerTop.value = target.clamp(0.0, maxTop);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildRows(),
        // Travelling rose, always centred on the timeline's vertical line.
        Positioned.fill(
          child: IgnorePointer(
            child: ValueListenableBuilder<double>(
              valueListenable: _flowerTop,
              builder: (context, top, child) => Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: top),
                  child: child,
                ),
              ),
              child: Image.asset(
                'assets/flowers/flower2.webp',
                width: _flowerSize,
                height: _flowerSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRows() {
    final items = widget.items;
    final color = widget.color;
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          RevealOnScroll(
            delay: Duration(milliseconds: 70 * i),
            offsetY: 18,
            child: _buildRow(i, items, color),
          ),
      ],
    );
  }

  Widget _buildRow(int i, List<ScheduleItem> items, Color color) {
    return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      items[i].time,
                      textAlign: TextAlign.right,
                      style: WeddingType.display(size: 21, color: color),
                    ),
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: 1,
                          color: i == 0
                              ? Colors.transparent
                              : color.withValues(alpha: 0.5),
                        ),
                      ),
                      Transform.rotate(
                        angle: 0.785398,
                        child: Container(width: 7, height: 7, color: color),
                      ),
                      Expanded(
                        child: Container(
                          width: 1,
                          color: i == items.length - 1
                              ? Colors.transparent
                              : color.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      items[i].label,
                      style: WeddingType.serif(
                          size: 17, color: color, height: 1.3),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final WeddingEvent event;
  final bool onBurgundy;
  const _MapButton({required this.event, required this.onBurgundy});

  @override
  Widget build(BuildContext context) {
    final enabled = event.mapUrl != null;
    final fg = onBurgundy ? WeddingColors.burgundy : WeddingColors.cream;
    final bg = onBurgundy ? WeddingColors.cream : WeddingColors.burgundy;

    return OutlinedButton.icon(
      onPressed: enabled
          ? () => launchUrl(Uri.parse(event.mapUrl!),
              mode: LaunchMode.externalApplication)
          : null,
      style: OutlinedButton.styleFrom(
        backgroundColor: enabled ? bg : bg.withValues(alpha: 0.45),
        foregroundColor: fg,
        disabledForegroundColor: fg.withValues(alpha: 0.8),
        side: BorderSide(color: WeddingColors.gold.withValues(alpha: 0.6)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      icon: const Icon(Icons.place_outlined, size: 18),
      label: Text(
        enabled ? 'Open in Google Maps' : 'Location coming soon',
        style: WeddingType.caps(
            size: 12,
            color: enabled ? fg : fg.withValues(alpha: 0.8),
            letterSpacing: 2),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Details
// ---------------------------------------------------------------------------

class _DetailsSection extends StatelessWidget {
  const _DetailsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 28),
      child: RevealOnScroll(
        child: Column(
          children: [
            Text('Details',
                style:
                    WeddingType.script(size: 36, color: WeddingColors.burgundy)),
            const SizedBox(height: 20),
            Text(
              'For additional information or questions,\nplease feel free to reach out.',
              style: WeddingType.serif(size: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            for (final c in WeddingConfig.contacts) ...[
              Text(c.name, style: WeddingType.display(size: 19)),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => launchUrl(
                    Uri(scheme: 'tel', path: c.phone.replaceAll(' ', ''))),
                child: Text(c.phone,
                    style: WeddingType.serif(
                        size: 18, color: WeddingColors.burgundy)),
              ),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 10),
            Text(
              'Your presence is the greatest gift to us, and your prayers are '
              'the most precious of all.',
              style: WeddingType.serif(size: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            const FlowerBand(height: 150),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Closing
// ---------------------------------------------------------------------------

class _ClosingSection extends StatelessWidget {
  const _ClosingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Hope to see you there!',
            style: WeddingType.script(size: 34), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          '${WeddingConfig.groomShort} & ${WeddingConfig.brideShort}',
          style: WeddingType.display(size: 22, color: WeddingColors.softCream),
        ),
        const SizedBox(height: 34),
        const RevealOnScroll(
          child: GentleFloat(
            dy: 6,
            period: Duration(seconds: 6),
            child: CoupleIllustration(height: 340),
          ),
        ),
        const SizedBox(height: 34),
        Text(
          'MADE WITH LOVE · OCTOBER 2026',
          style: WeddingType.caps(
              size: 10,
              color: WeddingColors.softCream.withValues(alpha: 0.6),
              letterSpacing: 3),
        ),
      ],
    );
  }
}
