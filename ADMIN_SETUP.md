# LA FINCA: configuración del panel

La solución está preparada para esta arquitectura:

```text
Página pública Flutter  →  GitHub Pages (sitio estático)
                           ↓
                  Firebase Realtime Database
                           ↑
Panel /admin Flutter  →  Firebase Authentication

PDF del menú  ←  enlace público de Google Drive
```

El panel no almacena el PDF. El propietario pega el enlace compartido de
Google Drive y la página pública lo usa para el botón `Ver menú PDF`. Esto
evita usar Firebase Storage. Los enlaces y textos se guardan en Realtime
Database en `site/content`.

## Conectar Firebase

1. Crear un proyecto en Firebase con la cuenta del propietario.
2. Activar Authentication → Sign-in method → Email/Password.
3. Crear un único usuario para el propietario. No activar el registro público.
4. Crear/activar Realtime Database usando la URL del proyecto.
5. Publicar las reglas del archivo `database.rules.json`.
6. Instalar FlutterFire CLI si aún no está instalado:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

7. Reemplazar `lib/firebase_options.dart` con el archivo generado por
   `flutterfire configure` no es necesario para este repositorio; el archivo
   usa `FIREBASE_API_KEY` como variable de compilación.
8. En GitHub, ir a Settings → Secrets and variables → Actions → New repository
   secret y crear `FIREBASE_API_KEY` con la clave web del proyecto.

El panel queda disponible en `/admin`. La regla `web/_redirects` permite que
Cloudflare Pages entregue la aplicación Flutter también cuando se abre esa
ruta directamente.

## Publicar la página

La página pública se publica únicamente mediante GitHub Actions en GitHub
Pages al hacer push a la rama `main`. Firebase se utiliza únicamente para
Authentication y Realtime Database del panel.

El repositorio no debe contener contraseñas ni claves privadas.

## Uso del PDF

El propietario debe compartir el PDF en Google Drive como:

```text
Cualquier persona con el enlace → Lector
```

Luego pega ese enlace en `/admin`. Para conservar el mismo enlace, debe
reemplazar el contenido del archivo existente en Drive en lugar de borrar el
archivo y crear uno nuevo.

## Costos y alcance

- GitHub Pages: hosting del sitio estático mediante el workflow del repositorio.
- Firestore/Auth: consumo muy bajo para este proyecto; la cuenta y cualquier
  facturación deben ser del propietario.
- Google Drive: usa el almacenamiento de la cuenta del propietario.
- Dominio: costo anual del cliente.

El panel actual administra teléfono, WhatsApp, PDF, Instagram, Maps y los
textos principales de portada y reservas. Las fotos siguen siendo assets
locales hasta implementar una galería editable.

## Seguridad de la clave web

La configuración Firebase del navegador necesita una API key pública para
inicializar el SDK; esa clave no concede por sí sola acceso de escritura. El
acceso real está protegido por Authentication y las reglas de Realtime
Database. La clave debe restringirse por HTTP referrers a:

```text
https://devkosmosyneah.github.io/*
http://localhost:*/
```

Y debe permitirse únicamente para las APIs Firebase necesarias. No se deben
subir al repositorio service accounts, claves privadas ni tokens.
