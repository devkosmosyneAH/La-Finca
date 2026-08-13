# LA FINCA: configuración del panel

La solución está preparada para esta arquitectura:

```text
Página pública Flutter  →  Firebase Hosting (sitio estático)
                           ↓
                    Firebase Firestore
                           ↑
Panel /admin Flutter  →  Firebase Authentication

PDF del menú  ←  enlace público de Google Drive
```

El panel no almacena el PDF. El propietario pega el enlace compartido de
Google Drive y la página pública lo usa para el botón `Ver menú PDF`. Esto
evita usar Firebase Storage.

## Conectar Firebase

1. Crear un proyecto en Firebase con la cuenta del propietario.
2. Activar Authentication → Sign-in method → Email/Password.
3. Crear un único usuario para el propietario. No activar el registro público.
4. Crear Firestore Database en modo producción.
5. Publicar las reglas del archivo `firestore.rules`.
6. Instalar FlutterFire CLI si aún no está instalado:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

7. Reemplazar `lib/firebase_options.dart` con el archivo generado por
   `flutterfire configure` y cambiar `isConfigured` a `true`.

El panel queda disponible en `/admin`. La regla `web/_redirects` permite que
Cloudflare Pages entregue la aplicación Flutter también cuando se abre esa
ruta directamente.

## Publicar la página

La versión actual está publicada en el sitio Firebase Hosting del proyecto
`la-finca-1394c`. Para futuras versiones:

```bash
flutter build web --release --base-href "/"
firebase deploy --project la-finca-1394c --only hosting
```

El proyecto Firebase y el dominio deben pertenecer al propietario. El
repositorio no debe contener contraseñas ni claves privadas.

## Uso del PDF

El propietario debe compartir el PDF en Google Drive como:

```text
Cualquier persona con el enlace → Lector
```

Luego pega ese enlace en `/admin`. Para conservar el mismo enlace, debe
reemplazar el contenido del archivo existente en Drive en lugar de borrar el
archivo y crear uno nuevo.

## Costos y alcance

- Firebase Hosting: cuota gratuita para el sitio estático; revisar el consumo
  del proyecto desde la consola.
- Firestore/Auth: consumo muy bajo para este proyecto; la cuenta y cualquier
  facturación deben ser del propietario.
- Google Drive: usa el almacenamiento de la cuenta del propietario.
- Dominio: costo anual del cliente.

El panel actual administra teléfono, WhatsApp, PDF, Instagram, Maps y los
textos principales de portada y reservas. Las fotos siguen siendo assets
locales hasta implementar una galería editable.
