# LA FINCA: configuracion del panel

La aplicacion usa esta arquitectura:

```text
Aplicacion publica Flutter -> GitHub Pages
                              |
                              v
                    Firebase Realtime Database
                              ^
Panel /admin Flutter ---------|
        |
        +--> Firebase Authentication (Email/Password)
        +--> Google Drive para el enlace publico del PDF
```

Firebase se usa unicamente para Authentication y Realtime Database. No se
usa Firebase Hosting, Firestore, Firebase Storage, Analytics, Messaging ni
Cloud Functions.

## Configuracion de Firebase

1. Activar Authentication -> Sign-in method -> Email/Password.
2. Crear un unico usuario para el propietario. No activar el registro publico.
3. Crear o activar Realtime Database.
4. Publicar las reglas de `database.rules.json`.
5. La aplicacion guarda el contenido en `site/content`.

La clave web se inyecta durante la compilacion mediante
`FIREBASE_API_KEY`. No se deben subir al repositorio contrasenas, tokens,
cuentas de servicio ni claves privadas.

## Publicacion

La pagina se publica unicamente mediante GitHub Pages. El workflow de GitHub
Actions compila Flutter Web y publica el resultado. Firebase no aloja la
pagina.

En GitHub Pages, el panel se abre en `/#/admin` dentro de la misma aplicacion
Flutter. El acceso
esta protegido por Firebase Authentication y las escrituras por las reglas de
Realtime Database.

## Uso de los PDF

El propietario comparte el PDF en Google Drive como:

```text
Cualquier persona con el enlace -> Lector
```

Luego pega los enlaces y las categorías de ambos documentos en `/#/admin`.
La página pública mostrará un botón por cada PDF configurado. Los PDF no se
guardan en Firebase Storage; solo se guardan sus enlaces en Realtime Database.

## Costos y alcance

- GitHub Pages: alojamiento del sitio estatico.
- Firebase Authentication y Realtime Database: consumo bajo para este sitio.
- Google Drive: almacenamiento de la cuenta del propietario.
- Dominio: costo anual del cliente, si se agrega uno.

El panel administra telefono, WhatsApp, dos PDF con sus categorías, Instagram,
Maps y los textos principales de portada y reservas. Las fotografias siguen
siendo assets locales del proyecto.

## Restriccion de la clave web

Restringir la API key por HTTP referrer a:

```text
https://devkosmosyneah.github.io/*
http://localhost:*/
```

Permitir solamente las APIs necesarias para Firebase Authentication y
Realtime Database.
