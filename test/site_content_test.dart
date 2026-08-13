import 'package:flutter_test/flutter_test.dart';
import 'package:la_finca_propuesta/site_content.dart';

void main() {
  test('los valores por defecto estan completos', () {
    final content = SiteContent.defaults;

    expect(content.phone, isNotEmpty);
    expect(content.heroTitle, isNotEmpty);
    expect(content.reservationTitle, isNotEmpty);
  });

  test('el contenido se serializa y se recupera correctamente', () {
    final original = SiteContent.defaults;
    final restored = SiteContent.fromMap(original.toMap());

    expect(restored.phone, original.phone);
    expect(restored.whatsappMessage, original.whatsappMessage);
    expect(restored.heroTitle, original.heroTitle);
    expect(restored.reservationTitle, original.reservationTitle);
  });
}
