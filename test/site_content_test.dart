import 'package:flutter_test/flutter_test.dart';
import 'package:la_finca_propuesta/site_content.dart';

void main() {
  test('los valores por defecto estan completos', () {
    final content = SiteContent.defaults;

    expect(content.phone, isNotEmpty);
    expect(content.pdfCategory1, isNotEmpty);
    expect(content.pdfCategory2, isNotEmpty);
    expect(content.heroTitle, isNotEmpty);
    expect(content.reservationTitle, isNotEmpty);
  });

  test('el contenido se serializa y se recupera correctamente', () {
    final original = SiteContent.defaults;
    final restored = SiteContent.fromMap(original.toMap());

    expect(restored.phone, original.phone);
    expect(restored.whatsappMessage, original.whatsappMessage);
    expect(restored.pdfUrl1, original.pdfUrl1);
    expect(restored.pdfCategory1, original.pdfCategory1);
    expect(restored.pdfUrl2, original.pdfUrl2);
    expect(restored.pdfCategory2, original.pdfCategory2);
    expect(restored.heroTitle, original.heroTitle);
    expect(restored.reservationTitle, original.reservationTitle);
  });

  test('mantiene el PDF antiguo como primer documento', () {
    final content = SiteContent.fromMap({
      'pdfUrl': 'https://drive.google.com/old-file',
    });

    expect(content.pdfUrl1, 'https://drive.google.com/old-file');
    expect(content.pdfUrl2, isEmpty);
  });
}
