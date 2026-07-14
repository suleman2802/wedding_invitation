import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// EDIT EVERYTHING ABOUT THE WEDDING HERE — names, dates, times, venues,
/// map links and contact numbers. The rest of the app reads from this file.
/// ---------------------------------------------------------------------------

class WeddingConfig {
  static const String groomName = 'Suleman Ahmad';
  static const String brideName = 'Mehrunisa Zahid';

  static const String groomShort = 'Suleman';
  static const String brideShort = 'Mehrunisa';

  static const String groomFatherName = 'Rizwan Ahmad';
  static const String brideFatherName = 'Zahid Rashid';

  /// Monogram shown on the wax seal of the envelope.
  static const String sealMonogram = 'S ♥ M';

  /// The countdown ticks down to the first event (Mehndi).
  static DateTime get countdownTarget => events.first.startsAt;

  /// Contact people shown in the Details + RSVP sections.
  static const List<ContactPerson> contacts = [
    ContactPerson(name: 'Rizwan Ahmad', phone: '+92 300 964 3759'),
    ContactPerson(name: 'Suleman Ahmad', phone: '+92 318 448 2240'),
  ];

  /// WhatsApp number used by the RSVP button (digits only, country code first).
  static const String rsvpWhatsApp = '923184482240';

  static final List<WeddingEvent> events = [
    WeddingEvent(
      name: 'Mehndi',
      tagline: 'An evening of dhol, dance and henna',
      startsAt: DateTime(2026, 10, 22, 19, 0),
      dateLabel: '22nd October 2026',
      venueName: 'Mehndi (In-House)',
      venueAddress: 'Gujranwala, Punjab',
      mapUrl: 'https://maps.app.goo.gl/BAuLTnMMYYUfUCWr8',
      mapQuery: '32.138211,74.210410',
      schedule: [
        ScheduleItem('7:00 PM', 'Dholki'),
        ScheduleItem('8:30 PM', 'Rasam'),
        ScheduleItem('9:30 PM', 'Dinner'),
        ScheduleItem('11:00 PM', 'Sangeet'),
      ],
      dressNote: '',
      palette: [],
    ),
    WeddingEvent(
      name: 'Barat',
      tagline: 'The Nikkah ceremony and grand celebration',
      startsAt: DateTime(2026, 10, 24, 14, 0),
      dateLabel: '24th October 2026',
      venueName: 'Kashmir Fort Marquee',
      venueAddress: 'Lahore, Punjab',
      mapUrl: 'https://maps.app.goo.gl/YRPmeFJNNjkGhYUq7',
      mapQuery: 'Kashmir Fort Marquee, Lahore',
      schedule: [
        ScheduleItem('2:00 PM', 'Sehra Bandi'),
        ScheduleItem('6:00 PM', 'Reception'),
        ScheduleItem('7:30 PM', 'Nikkah'),
        ScheduleItem('9:30 PM', 'Rukhsati'),
        ScheduleItem('11:45 PM', 'Bride Welcome'),
      ],
      dressNote: '',
      palette: [],
    ),
    WeddingEvent(
      name: 'Walima',
      tagline: 'A reception in honour of the newlyweds',
      startsAt: DateTime(2026, 10, 25, 18, 30),
      dateLabel: '25th October 2026',
      venueName: 'Al-Amin Orchid',
      venueAddress: 'Gujranwala, Punjab',
      mapUrl: 'https://maps.app.goo.gl/XP2ojHRK8278TU2d9',
      mapQuery: 'Amin Orchid, Gujranwala',
      schedule: [
        ScheduleItem('6:30 PM', 'Reception'),
        ScheduleItem('8:00 PM', "Couple's Entry"),
        ScheduleItem('9:00 PM', 'Dinner'),
      ],
      dressNote:
          'Elegant evening wear — soft ivories, pastels and classic formal looks.',
      palette: [
        Color(0xFFF5EBDD),
        Color(0xFFC9A24B),
        Color(0xFF9C7B94),
        Color(0xFF4A3B41),
      ],
    ),
  ];
}

class WeddingEvent {
  final String name;
  final String tagline;
  final DateTime startsAt;
  final String dateLabel;
  final String venueName;
  final String venueAddress;
  final String? mapUrl;

  /// Search text (or "lat,lng") used for the embedded map preview.
  final String? mapQuery;
  final List<ScheduleItem> schedule;
  final String dressNote;
  final List<Color> palette;

  const WeddingEvent({
    required this.name,
    required this.tagline,
    required this.startsAt,
    required this.dateLabel,
    required this.venueName,
    required this.venueAddress,
    required this.mapUrl,
    this.mapQuery,
    required this.schedule,
    required this.dressNote,
    required this.palette,
  });
}

class ScheduleItem {
  final String time;
  final String label;
  const ScheduleItem(this.time, this.label);
}

class ContactPerson {
  final String name;
  final String phone;
  const ContactPerson({required this.name, required this.phone});
}
