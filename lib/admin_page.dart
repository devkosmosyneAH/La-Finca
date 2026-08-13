import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'content_service.dart';
import 'site_content.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  static const forest = Color(0xFF173F35);
  static const gold = Color(0xFFC8954B);
  static const cream = Color(0xFFF7F4EE);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _pdfUrl1Controller = TextEditingController();
  final _pdfCategory1Controller = TextEditingController();
  final _pdfUrl2Controller = TextEditingController();
  final _pdfCategory2Controller = TextEditingController();
  final _instagramController = TextEditingController();
  final _mapsController = TextEditingController();
  final _heroTitleController = TextEditingController();
  final _heroSubtitleController = TextEditingController();
  final _reservationTitleController = TextEditingController();
  bool _loading = false;
  bool _loggedIn = false;
  bool _obscurePassword = true;
  String? _authError;

  @override
  void dispose() {
    for (final controller in [
      _emailController,
      _passwordController,
      _phoneController,
      _messageController,
      _pdfUrl1Controller,
      _pdfCategory1Controller,
      _pdfUrl2Controller,
      _pdfCategory2Controller,
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
    if (!ContentService.isConfigured || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _loading = true);
    setState(() => _authError = null);
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
    } catch (error) {
      if (mounted) setState(() => _authError = _authMessage(error));
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
    _pdfUrl1Controller.text = content.pdfUrl1;
    _pdfCategory1Controller.text = content.pdfCategory1;
    _pdfUrl2Controller.text = content.pdfUrl2;
    _pdfCategory2Controller.text = content.pdfCategory2;
    _instagramController.text = content.instagramUrl;
    _mapsController.text = content.mapsUrl;
    _heroTitleController.text = content.heroTitle;
    _heroSubtitleController.text = content.heroSubtitle;
    _reservationTitleController.text = content.reservationTitle;
  }

  SiteContent _contentFromForm() => SiteContent(
        phone: _phoneController.text,
        whatsappMessage: _messageController.text,
        pdfUrl1: _pdfUrl1Controller.text,
        pdfCategory1: _pdfCategory1Controller.text,
        pdfUrl2: _pdfUrl2Controller.text,
        pdfCategory2: _pdfCategory2Controller.text,
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

  String _authMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Escribe un correo electrónico válido.';
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'El correo o la contraseña no son correctos.';
        case 'user-disabled':
          return 'Esta cuenta está desactivada. Contacta al administrador.';
        case 'too-many-requests':
          return 'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.';
        case 'network-request-failed':
          return 'No hay conexión. Revisa internet e inténtalo de nuevo.';
      }
    }
    return 'No se pudo iniciar sesión. Inténtalo nuevamente.';
  }

  @override
  Widget build(BuildContext context) {
    if (!ContentService.isConfigured) return _adminShell(_setupNotice());
    if (_loggedIn) return _adminShell(_editor());
    return _loginView();
  }

  Widget _adminShell(Widget child) => Scaffold(
        backgroundColor: cream,
        appBar: AppBar(
          backgroundColor: forest,
          foregroundColor: Colors.white,
          title: const Text('Administración · LA FINCA'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              child: const Text('Ver página pública',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(padding: const EdgeInsets.all(24), child: child),
          ),
        ),
      );

  Widget _loginView() => Scaffold(
        backgroundColor: forest,
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [forest, const Color(0xFF0D2D26)],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 18),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      children: [
                        _loginCard(),
                        const SizedBox(height: 22),
                        _developerCredit(dark: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

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

  Widget _loginCard() => Container(
        padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
        decoration: BoxDecoration(
          color: cream,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 30,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ClipOval(
                  child: Image.asset(
                    'assets/instagram/profile.jpg',
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 76,
                      height: 76,
                      color: gold,
                      child: const Icon(Icons.spa_rounded,
                          color: forest, size: 38),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'PANEL PRIVADO',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.2),
              ),
              const SizedBox(height: 8),
              const Text(
                'Administra LA FINCA',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: forest, fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Actualiza tus enlaces y contenidos desde un solo lugar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF69736B), height: 1.45),
              ),
              const SizedBox(height: 26),
              _loginField(
                controller: _emailController,
                label: 'Correo electrónico',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email
                ],
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty || !email.contains('@')) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _loginField(
                controller: _passwordController,
                label: 'Contraseña',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _loading ? null : _login(),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                ),
                validator: (value) => (value == null || value.length < 6)
                    ? 'La contraseña debe tener al menos 6 caracteres'
                    : null,
              ),
              if (_authError != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE9E4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Color(0xFF9E3D2F), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_authError!,
                            style: const TextStyle(
                                color: Color(0xFF86352B), fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _login,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: forest),
                        )
                      : const Icon(Icons.login_rounded, size: 19),
                  label: Text(_loading ? 'Verificando acceso…' : 'Ingresar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: forest,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Acceso exclusivo para el propietario del sitio.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8A9289), fontSize: 11),
              ),
            ],
          ),
        ),
      );

  Widget _loginField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Iterable<String>? autofillHints,
    bool obscureText = false,
    Widget? suffixIcon,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE2E4DD))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: forest, width: 1.4)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFC75D4C))),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFC75D4C), width: 1.4)),
      ),
    );
  }

  Widget _developerCredit({required bool dark}) => TextButton.icon(
        onPressed: _openDeveloper,
        icon: Icon(Icons.auto_awesome_rounded,
            size: 14, color: dark ? const Color(0xFFE6C68A) : gold),
        label: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                  text: 'Desarrollado por  ',
                  style: TextStyle(
                      color: dark ? const Color(0xFFC8D6CD) : forest)),
              const TextSpan(
                text: 'Devkosmosyne',
                style: TextStyle(
                    color: Color(0xFFE6C68A),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        style: TextButton.styleFrom(
          foregroundColor: dark ? Colors.white : forest,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          textStyle: const TextStyle(fontSize: 10, letterSpacing: .15),
        ),
      );

  Future<void> _openDeveloper() async {
    final uri =
        Uri.parse('https://devkosmosyneah.github.io/devkosmosyne-website/');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

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
          _pdfSection(
            number: '1',
            categoryController: _pdfCategory1Controller,
            urlController: _pdfUrl1Controller,
          ),
          _pdfSection(
            number: '2',
            categoryController: _pdfCategory2Controller,
            urlController: _pdfUrl2Controller,
          ),
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

  Widget _pdfSection({
    required String number,
    required TextEditingController categoryController,
    required TextEditingController urlController,
  }) => Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PDF $number',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _field(categoryController, 'Categoría del PDF'),
              _field(urlController, 'Enlace compartido del PDF de Drive'),
            ],
          ),
        ),
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
