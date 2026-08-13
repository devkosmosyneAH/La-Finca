import 'package:flutter/material.dart';

import 'content_service.dart';
import 'site_content.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _pdfController = TextEditingController();
  final _instagramController = TextEditingController();
  final _mapsController = TextEditingController();
  final _heroTitleController = TextEditingController();
  final _heroSubtitleController = TextEditingController();
  final _reservationTitleController = TextEditingController();
  bool _loading = false;
  bool _loggedIn = false;

  @override
  void dispose() {
    for (final controller in [
      _emailController,
      _passwordController,
      _phoneController,
      _messageController,
      _pdfController,
      _instagramController,
      _mapsController,
      _heroTitleController,
      _heroSubtitleController,
      _reservationTitleController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _login() async {
    if (!ContentService.isConfigured) return;
    setState(() => _loading = true);
    try {
      final credential = await ContentService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      final user = credential.user;
      if (user == null || !user.emailVerified) {
        if (user != null) await user.sendEmailVerification();
        await ContentService.signOut();
        _message(
          'Debes verificar el correo. Te enviamos un nuevo enlace de verificación.',
        );
        return;
      }
      final content = await ContentService.load();
      _fill(content);
      if (mounted) setState(() => _loggedIn = true);
    } catch (_) {
      _message('No se pudo iniciar sesión. Revisa el correo y la contraseña.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await ContentService.save(_contentFromForm());
      _message(
          'Cambios guardados. La página pública ya puede mostrar la nueva configuración.');
    } catch (_) {
      _message(
          'No se pudieron guardar los cambios. Revisa la configuración de Firebase.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fill(SiteContent content) {
    _phoneController.text = content.phone;
    _messageController.text = content.whatsappMessage;
    _pdfController.text = content.pdfUrl;
    _instagramController.text = content.instagramUrl;
    _mapsController.text = content.mapsUrl;
    _heroTitleController.text = content.heroTitle;
    _heroSubtitleController.text = content.heroSubtitle;
    _reservationTitleController.text = content.reservationTitle;
  }

  SiteContent _contentFromForm() => SiteContent(
        phone: _phoneController.text,
        whatsappMessage: _messageController.text,
        pdfUrl: _pdfController.text,
        instagramUrl: _instagramController.text,
        mapsUrl: _mapsController.text,
        heroTitle: _heroTitleController.text,
        heroSubtitle: _heroSubtitleController.text,
        reservationTitle: _reservationTitleController.text,
      );

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración · LA FINCA'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
            child: const Text('Ver página pública'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: !ContentService.isConfigured
                ? _setupNotice()
                : _loggedIn
                    ? _editor()
                    : _loginForm(),
          ),
        ),
      ),
    );
  }

  Widget _setupNotice() => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Panel pendiente de conectar',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text(
                'Configura Firebase y reemplaza los valores de firebase_options.dart. La página pública sigue funcionando con su contenido local mientras tanto.',
              ),
            ],
          ),
        ),
      );

  Widget _loginForm() => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Acceso del propietario',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Correo')),
              const SizedBox(height: 12),
              TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña')),
              const SizedBox(height: 20),
              FilledButton(
                  onPressed: _loading ? null : _login,
                  child: Text(_loading ? 'Entrando…' : 'Iniciar sesión')),
            ],
          ),
        ),
      );

  Widget _editor() => ListView(
        children: [
          const Text('Contenido editable',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'El PDF debe tener permisos de Drive: “cualquier persona con el enlace puede ver”.'),
          const SizedBox(height: 20),
          _field(_phoneController, 'Teléfono de reservas'),
          _field(_messageController, 'Mensaje de WhatsApp'),
          _field(_pdfController, 'Enlace compartido del PDF de Drive'),
          _field(_instagramController, 'Enlace de Instagram'),
          _field(_mapsController, 'Enlace de Google Maps'),
          _field(_heroTitleController, 'Título principal'),
          _field(_heroSubtitleController, 'Subtítulo principal'),
          _field(_reservationTitleController, 'Título de reservas'),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: _loading ? null : _save,
              child: Text(_loading ? 'Guardando…' : 'Guardar cambios')),
        ],
      );

  Widget _field(TextEditingController controller, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(
          controller: controller,
          maxLines:
              label.contains('Título') || label.contains('Mensaje') ? 3 : 1,
          decoration: InputDecoration(
              labelText: label, border: const OutlineInputBorder()),
        ),
      );
}
