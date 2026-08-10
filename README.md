# LA FINCA — propuesta comercial en Flutter

Landing page responsive para presentar **spa, glamping, gastronomía y recepciones**.

## Abrir en Visual Studio Code

1. Instala Flutter y la extensión **Flutter** de VS Code.
2. Abre esta carpeta: `outputs/la_finca_propuesta`.
3. En la terminal ejecuta:

```bash
flutter pub get
flutter run -d chrome
```

También puedes ejecutar una versión web compilada:

```bash
flutter build web
```

El resultado queda en `build/web`.

## Personalizar antes de presentarla

- Cambia el teléfono `099 721 0017` en `lib/main.dart`.
- Reemplaza `_whatsapp()` por un enlace real de WhatsApp con el número oficial.
- Cambia las imágenes de Unsplash por fotografías reales de LA FINCA.
- Actualiza precios, paquetes, horarios y disponibilidad de glampings.
- Agrega dominio, redes sociales y un formulario conectado a reservas.

La página usa Flutter/Material 3 y `url_launcher` para que los botones de WhatsApp y llamada funcionen de verdad.
