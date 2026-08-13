class SiteContent {
  const SiteContent({
    required this.phone,
    required this.whatsappMessage,
    required this.pdfUrl1,
    required this.pdfCategory1,
    required this.pdfUrl2,
    required this.pdfCategory2,
    required this.instagramUrl,
    required this.mapsUrl,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.reservationTitle,
  });

  final String phone;
  final String whatsappMessage;
  final String pdfUrl1;
  final String pdfCategory1;
  final String pdfUrl2;
  final String pdfCategory2;
  final String instagramUrl;
  final String mapsUrl;
  final String heroTitle;
  final String heroSubtitle;
  final String reservationTitle;

  static const defaults = SiteContent(
    phone: '099 721 0017',
    whatsappMessage: 'Hola LA FINCA, quiero consultar disponibilidad.',
    pdfUrl1: '',
    pdfCategory1: 'Menú',
    pdfUrl2: '',
    pdfCategory2: 'Información',
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
      pdfUrl1: value('pdfUrl1', value('pdfUrl', defaults.pdfUrl1)),
      pdfCategory1: value('pdfCategory1', defaults.pdfCategory1),
      pdfUrl2: value('pdfUrl2', defaults.pdfUrl2),
      pdfCategory2: value('pdfCategory2', defaults.pdfCategory2),
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
        // pdfUrl remains for compatibility with content saved by the old app.
        'pdfUrl': pdfUrl1,
        'pdfUrl1': pdfUrl1,
        'pdfCategory1': pdfCategory1,
        'pdfUrl2': pdfUrl2,
        'pdfCategory2': pdfCategory2,
        'instagramUrl': instagramUrl,
        'mapsUrl': mapsUrl,
        'heroTitle': heroTitle,
        'heroSubtitle': heroSubtitle,
        'reservationTitle': reservationTitle,
      };
}
