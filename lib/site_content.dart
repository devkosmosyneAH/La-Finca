class SiteContent {
  const SiteContent({
    required this.phone,
    required this.whatsappMessage,
    required this.pdfUrl,
    required this.instagramUrl,
    required this.mapsUrl,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.reservationTitle,
  });

  final String phone;
  final String whatsappMessage;
  final String pdfUrl;
  final String instagramUrl;
  final String mapsUrl;
  final String heroTitle;
  final String heroSubtitle;
  final String reservationTitle;

  static const defaults = SiteContent(
    phone: '099 721 0017',
    whatsappMessage: 'Hola LA FINCA, quiero consultar disponibilidad.',
    pdfUrl: '',
    instagramUrl: 'https://www.instagram.com/lafinca.spa/',
    mapsUrl: 'https://maps.app.goo.gl/DoZu9bp9NGxzDAvg9',
    heroTitle: 'La Amazonía que\nse disfruta sin\nprisa.',
    heroSubtitle: 'PISCINAS · SPA · GLAMPING · GASTRONOMÍA · EVENTOS',
    reservationTitle: 'Tu próxima experiencia\nempieza con un mensaje.',
  );

  factory SiteContent.fromMap(Map<String, dynamic> data) {
    String value(String key, String fallback) {
      final raw = data[key];
      return raw is String && raw.trim().isNotEmpty ? raw : fallback;
    }

    return SiteContent(
      phone: value('phone', defaults.phone),
      whatsappMessage: value('whatsappMessage', defaults.whatsappMessage),
      pdfUrl: value('pdfUrl', defaults.pdfUrl),
      instagramUrl: value('instagramUrl', defaults.instagramUrl),
      mapsUrl: value('mapsUrl', defaults.mapsUrl),
      heroTitle: value('heroTitle', defaults.heroTitle),
      heroSubtitle: value('heroSubtitle', defaults.heroSubtitle),
      reservationTitle: value('reservationTitle', defaults.reservationTitle),
    );
  }

  Map<String, dynamic> toMap() => {
        'phone': phone,
        'whatsappMessage': whatsappMessage,
        'pdfUrl': pdfUrl,
        'instagramUrl': instagramUrl,
        'mapsUrl': mapsUrl,
        'heroTitle': heroTitle,
        'heroSubtitle': heroSubtitle,
        'reservationTitle': reservationTitle,
      };
}
