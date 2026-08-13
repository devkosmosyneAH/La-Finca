import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  static const forestDark = Color(0xFF0D2D26);
  static const gold = Color(0xFFC8954B);
  static const cream = Color(0xFFF7F4EE);
  static const ink = Color(0xFF20352D);
  static const muted = Color(0xFF68766E);
  static const error = Color(0xFF9E3D2F);

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
  bool _checkingSession = true;
  bool _obscurePassword = true;
  bool _contentLoaded = true;
  String? _authError;
  String? _dataError;
  DateTime? _lastSavedAt;

  @override
  void initState() {
    super.initState();
    if (!ContentService.isConfigured) {
      _checkingSession = false;
    } else {
      _restoreSession();
    }
  }

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
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _authError = null;
    });

    try {
      final credential = await ContentService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      final user = credential.user;
      if (user == null || !user.emailVerified) {
        if (user != null) {
          await user.sendEmailVerification();
        }
        await ContentService.signOut();
        if (mounted) {
          setState(() {
            _authError =
                'Tu correo aún no está verificado. Te enviamos un nuevo enlace.';
          });
        }
        return;
      }
      await _enterEditor();
    } catch (error) {
      if (mounted) setState(() => _authError = _authMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _restoreSession() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser == null || !refreshedUser.emailVerified) {
        await ContentService.signOut();
        return;
      }
      await _enterEditor();
    } catch (_) {
      await ContentService.signOut();
    } finally {
      if (mounted) setState(() => _checkingSession = false);
    }
  }

  Future<void> _enterEditor() async {
    try {
      final content = await ContentService.load();
      _fill(content);
      if (mounted) {
        setState(() {
          _loggedIn = true;
          _checkingSession = false;
          _contentLoaded = true;
          _dataError = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loggedIn = true;
          _checkingSession = false;
          _contentLoaded = false;
          _dataError =
              'No pudimos cargar la información guardada. Revisa tu conexión e inténtalo de nuevo.';
        });
      }
    }
  }

  Future<void> _retryLoad() async {
    setState(() => _loading = true);
    try {
      final content = await ContentService.load();
      _fill(content);
      if (mounted) {
        setState(() {
          _contentLoaded = true;
          _dataError = null;
        });
      }
      _message('Contenido cargado correctamente.');
    } catch (_) {
      if (mounted) {
        setState(() {
          _contentLoaded = false;
          _dataError =
              'El servicio de contenido no respondió. Confirma tu conexión e inténtalo de nuevo.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await ContentService.signOut();
    if (!mounted) return;
    setState(() {
      _loggedIn = false;
      _passwordController.clear();
      _authError = null;
      _dataError = null;
    });
  }

  Future<void> _save() async {
    if (!_contentLoaded) {
      _message('Carga el contenido antes de guardar cambios.', error: true);
      return;
    }
    final content = _contentFromForm();
    final validationError = _validateContent(content);
    if (validationError != null) {
      _message(validationError, error: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await ContentService.save(content);
      if (!mounted) return;
      setState(() => _lastSavedAt = DateTime.now());
      _message('Cambios guardados. La página pública ya está actualizada.');
    } catch (saveError) {
      _message(_databaseMessage(saveError), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateContent(SiteContent content) {
    if (content.pdfUrl1.isNotEmpty && content.pdfCategory1.trim().isEmpty) {
      return 'Agrega una categoría para el PDF 1.';
    }
    if (content.pdfUrl2.isNotEmpty && content.pdfCategory2.trim().isEmpty) {
      return 'Agrega una categoría para el PDF 2.';
    }
    for (final entry in <String, String>{
      'PDF 1': content.pdfUrl1,
      'PDF 2': content.pdfUrl2,
      'Instagram': content.instagramUrl,
      'Google Maps': content.mapsUrl,
    }.entries) {
      if (entry.value.trim().isEmpty) continue;
      final uri = Uri.tryParse(entry.value.trim());
      if (uri == null || !{'http', 'https'}.contains(uri.scheme)) {
        return 'El enlace de ${entry.key} debe comenzar con https://.';
      }
    }
    return null;
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
        phone: _phoneController.text.trim(),
        whatsappMessage: _messageController.text.trim(),
        pdfUrl1: _pdfUrl1Controller.text.trim(),
        pdfCategory1: _pdfCategory1Controller.text.trim(),
        pdfUrl2: _pdfUrl2Controller.text.trim(),
        pdfCategory2: _pdfCategory2Controller.text.trim(),
        instagramUrl: _instagramController.text.trim(),
        mapsUrl: _mapsController.text.trim(),
        heroTitle: _heroTitleController.text.trim(),
        heroSubtitle: _heroSubtitleController.text.trim(),
        reservationTitle: _reservationTitleController.text.trim(),
      );

  void _message(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? const Color(0xFF7B3026) : forest,
          content: Row(
            children: [
              Icon(
                  error
                      ? Icons.error_outline_rounded
                      : Icons.check_circle_outline,
                  color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      );
  }

  String _authMessage(Object exception) {
    if (exception is FirebaseAuthException) {
      switch (exception.code) {
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
        case 'operation-not-allowed':
          return 'El acceso por correo y contraseña está temporalmente desactivado. Contacta al administrador.';
        case 'unauthorized-domain':
          return 'Este sitio no está autorizado para iniciar sesión. Contacta al administrador.';
        case 'api-key-not-valid.-please-pass-a-valid-api-key.':
          return 'Hay un problema con la configuración del acceso. Contacta al administrador.';
      }
    }
    return 'No se pudo iniciar sesión. Inténtalo nuevamente.';
  }

  String _databaseMessage(Object exception) {
    if (exception is FirebaseException) {
      switch (exception.code) {
        case 'permission-denied':
          return 'No tienes permiso para guardar cambios. Confirma que tu correo esté verificado.';
        case 'network-request-failed':
          return 'No hay conexión. Tus cambios no se guardaron.';
        case 'unauthenticated':
          return 'La sesión expiró. Cierra sesión e ingresa nuevamente.';
      }
    }
    return 'No se pudieron guardar los cambios. Inténtalo nuevamente.';
  }

  @override
  Widget build(BuildContext context) {
    if (!ContentService.isConfigured) return _adminShell(_setupNotice());
    if (_checkingSession) return _adminShell(_sessionLoading());
    if (_loggedIn) return _adminShell(_editor());
    return _loginView();
  }

  Widget _adminShell(Widget child) => Scaffold(
        backgroundColor: cream,
        appBar: AppBar(
          toolbarHeight: 72,
          backgroundColor: forest,
          foregroundColor: Colors.white,
          titleSpacing: 20,
          title: Row(
            children: [
              _brandMark(size: 38),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('LA FINCA',
                      style: TextStyle(fontSize: 15, letterSpacing: 1.4)),
                  Text('Panel de administración',
                      style: TextStyle(fontSize: 11, color: Color(0xFFBFD4C8))),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              tooltip: 'Ver página pública',
              icon: const Icon(Icons.open_in_new_rounded),
            ),
            if (_loggedIn)
              IconButton(
                onPressed: _loading ? null : _logout,
                tooltip: 'Cerrar sesión',
                icon: const Icon(Icons.logout_rounded),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: child,
              ),
            ),
          ),
        ),
      );

  Widget _loginView() => Scaffold(
        backgroundColor: forest,
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [forest, forestDark],
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

  Widget _setupNotice() => _noticeCard(
        icon: Icons.link_off_rounded,
        title: 'Panel pendiente de conectar',
        message:
            'Completa la configuración del panel para habilitar el acceso administrativo. La página pública continúa funcionando con su contenido local.',
        color: const Color(0xFF9E6B25),
      );

  Widget _sessionLoading() => _noticeCard(
        icon: Icons.sync_rounded,
        title: 'Comprobando sesión',
        message: 'Estamos verificando tu acceso seguro…',
        color: forest,
        action: const CircularProgressIndicator(strokeWidth: 2),
      );

  Widget _noticeCard({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
    Widget? action,
  }) =>
      Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE6E7E0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: .12),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: ink,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(message,
                        style: const TextStyle(color: muted, height: 1.45)),
                  ],
                ),
              ),
              if (action != null) ...[const SizedBox(width: 16), action],
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
                offset: Offset(0, 16)),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: _brandMark(size: 76)),
              const SizedBox(height: 18),
              const Text('PANEL PRIVADO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.2)),
              const SizedBox(height: 8),
              const Text('Administra LA FINCA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: forest,
                      fontSize: 28,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text(
                  'Actualiza tus enlaces y contenidos desde un solo lugar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, height: 1.45)),
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
                _inlineError(_authError!),
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
              const Text('Acceso exclusivo para el propietario del sitio.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF8A9289), fontSize: 11)),
            ],
          ),
        ),
      );

  Widget _brandMark({required double size}) => ClipOval(
        child: Image.asset(
          'assets/instagram/profile.jpg',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: size,
            height: size,
            color: gold,
            child: Icon(Icons.spa_rounded, color: forest, size: size * .5),
          ),
        ),
      );

  Widget _inlineError(String message) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE9E4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF4C7BE)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded, color: error, size: 18),
            const SizedBox(width: 8),
            Expanded(
                child: Text(message,
                    style: const TextStyle(
                        color: Color(0xFF86352B), fontSize: 12))),
          ],
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
  }) =>
      TextFormField(
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
              borderSide:
                  const BorderSide(color: Color(0xFFC75D4C), width: 1.4)),
        ),
      );

  Widget _editor() => ListView(
        children: [
          _editorHeader(),
          if (_dataError != null) ...[
            const SizedBox(height: 18),
            _dataWarning(),
          ],
          const SizedBox(height: 22),
          _sectionCard(
            icon: Icons.contact_phone_outlined,
            title: 'Contacto y reservas',
            description:
                'Define cómo pueden comunicarse contigo tus visitantes.',
            children: [
              _field(_phoneController, 'Teléfono de reservas'),
              _field(_messageController, 'Mensaje de WhatsApp'),
            ],
          ),
          const SizedBox(height: 16),
          _sectionCard(
            icon: Icons.picture_as_pdf_outlined,
            title: 'Documentos PDF',
            description:
                'Pega enlaces públicos de Drive y asigna una categoría a cada documento.',
            children: [_pdfGrid()],
          ),
          const SizedBox(height: 16),
          _sectionCard(
            icon: Icons.public_rounded,
            title: 'Enlaces públicos',
            description: 'Estos accesos aparecerán en la página pública.',
            children: [
              _field(_instagramController, 'Enlace de Instagram'),
              _field(_mapsController, 'Enlace de Google Maps'),
            ],
          ),
          const SizedBox(height: 16),
          _sectionCard(
            icon: Icons.edit_note_rounded,
            title: 'Textos principales',
            description:
                'Personaliza los mensajes que verá el visitante al entrar al sitio.',
            children: [
              _field(_heroTitleController, 'Título principal'),
              _field(_heroSubtitleController, 'Subtítulo principal'),
              _field(_reservationTitleController, 'Título de reservas'),
            ],
          ),
          const SizedBox(height: 20),
          _saveBar(),
          const SizedBox(height: 16),
          Center(child: _developerCredit(dark: false)),
        ],
      );

  Widget _editorHeader() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Contenido del sitio',
                    style: TextStyle(
                        color: ink, fontSize: 30, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text(
                    'Administra los enlaces y textos de LA FINCA desde un solo panel.',
                    style: TextStyle(color: muted, height: 1.4)),
              ],
            ),
          ),
          if (_lastSavedAt != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 6),
              child: _savedBadge(),
            ),
        ],
      );

  Widget _savedBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE5F2E7),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded,
                color: Color(0xFF2F7D47), size: 16),
            SizedBox(width: 6),
            Text('Guardado',
                style: TextStyle(
                    color: Color(0xFF2F7D47),
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _dataWarning() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5DD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8D39C)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFF946A1B)),
            const SizedBox(width: 12),
            Expanded(
                child: Text(_dataError!,
                    style: const TextStyle(color: Color(0xFF72521A)))),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: _loading ? null : _retryLoad,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String description,
    required List<Widget> children,
  }) =>
      Card(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFFE4E7DF)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEAF1EC),
                        borderRadius: BorderRadius.circular(13)),
                    child: Icon(icon, color: forest, size: 21),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: ink,
                                fontSize: 17,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Text(description,
                            style: const TextStyle(
                                color: muted, fontSize: 12, height: 1.35)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ...children,
            ],
          ),
        ),
      );

  Widget _pdfGrid() => LayoutBuilder(
        builder: (context, constraints) {
          final cards = [
            _pdfSection('1', _pdfCategory1Controller, _pdfUrl1Controller),
            _pdfSection('2', _pdfCategory2Controller, _pdfUrl2Controller),
          ];
          if (constraints.maxWidth < 650) {
            return Column(
                children: [cards[0], const SizedBox(height: 12), cards[1]]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 14),
              Expanded(child: cards[1]),
            ],
          );
        },
      );

  Widget _pdfSection(String number, TextEditingController categoryController,
          TextEditingController urlController) =>
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E9E1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                    radius: 14,
                    backgroundColor: gold,
                    foregroundColor: forest,
                    child: Text(number,
                        style: const TextStyle(fontWeight: FontWeight.w800))),
                const SizedBox(width: 9),
                Text('Documento PDF $number',
                    style: const TextStyle(
                        color: ink, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 14),
            _field(categoryController, 'Categoría'),
            _field(urlController, 'Enlace público de Drive'),
          ],
        ),
      );

  Widget _saveBar() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: forest,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: Color(0x22000000), blurRadius: 14, offset: Offset(0, 6))
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_done_outlined, color: Color(0xFFD9E8DE)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Publicar cambios',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800)),
                  SizedBox(height: 3),
                  Text(
                      'Se guardarán de forma segura y la página pública se actualizará.',
                      style: TextStyle(color: Color(0xFFBFD4C8), fontSize: 12)),
                ],
              ),
            ),
            FilledButton(
              onPressed: _loading || !_contentLoaded ? null : _save,
              style: FilledButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: forest,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
              child: Text(_loading ? 'Guardando…' : 'Guardar cambios'),
            ),
          ],
        ),
      );

  Widget _field(TextEditingController controller, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(
          controller: controller,
          maxLines: label.contains('Mensaje') ||
                  label.contains('Título') ||
                  label.contains('Subtítulo')
              ? 3
              : 1,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: const Color(0xFFFCFDFC),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xFFDDE3DC))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xFFDDE3DC))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: forest, width: 1.4)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          ),
        ),
      );

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
                      fontWeight: FontWeight.w800)),
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
}
