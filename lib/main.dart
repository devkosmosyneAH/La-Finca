import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const LaFincaApp());

class LaFincaApp extends StatelessWidget {
  const LaFincaApp({super.key});

  static const forest = Color(0xFF173F35);
  static const gold = Color(0xFFC8954B);

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Arial',
      scaffoldBackgroundColor: const Color(0xFFF7F4EE),
      colorScheme: ColorScheme.fromSeed(
        seedColor: forest,
        primary: forest,
        secondary: gold,
        surface: const Color(0xFFF7F4EE),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LA FINCA | Spa, glamping y recepciones',
      theme: base.copyWith(
        splashFactory: InkSparkle.splashFactory,
        textButtonTheme: TextButtonThemeData(
          style:
              TextButton.styleFrom(tapTargetSize: MaterialTapTargetSize.padded),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _experienciasKey = GlobalKey();
  final _glampingKey = GlobalKey();
  final _eventosKey = GlobalKey();
  final _reservasKey = GlobalKey();

  static const forest = Color(0xFF173F35);
  static const pale = Color(0xFFE9E5D9);
  static const gold = Color(0xFFC8954B);

  void _goTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: LaFincaApp.forest,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 820;
              return CustomScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _topBar(mobile)),
                  SliverToBoxAdapter(child: _hero(mobile)),
                  SliverToBoxAdapter(child: _trustStrip(mobile)),
                  SliverToBoxAdapter(
                    child: _section(
                      key: _experienciasKey,
                      mobile: mobile,
                      eyebrow: 'UNA PAUSA QUE SÍ SE SIENTE',
                      title: 'Mucho más que un día de spa',
                      subtitle:
                          'Naturaleza, agua, buena mesa y espacios para celebrar. Diseñamos experiencias para desconectar de la rutina y volver con historias que contar.',
                      child: _experienceCards(mobile),
                    ),
                  ),
                  SliverToBoxAdapter(child: _glampingSection(mobile)),
                  SliverToBoxAdapter(child: _eventsSection(mobile)),
                  SliverToBoxAdapter(child: _testimonial()),
                  SliverToBoxAdapter(child: _reservationSection(mobile)),
                  SliverToBoxAdapter(child: _footer(mobile)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _topBar(bool mobile) {
    return Container(
      color: forest,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 56, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.phone_in_talk_rounded,
              color: Color(0xFFE6C68A), size: 16),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _call,
            child: const Text(
              'Reservas: 099 721 0017',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          if (!mobile)
            const Text(
              'General Leonidas Plaza · Limón Indanza',
              style: TextStyle(color: Color(0xFFD7E0D9), fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _hero(bool mobile) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final titleSize = mobile ? (compact ? 39.0 : 47.0) : 74.0;
    return Container(
      constraints:
          BoxConstraints(minHeight: mobile ? (compact ? 650 : 680) : 700),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1449158743715-0a90ebb6d2d8?auto=format&fit=crop&w=1900&q=85',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding:
            EdgeInsets.fromLTRB(mobile ? 24 : 72, 34, mobile ? 24 : 72, 54),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black.withValues(alpha: .78),
              Colors.black.withValues(alpha: .20)
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heroHeader(mobile, compact),
            SizedBox(height: mobile ? (compact ? 142 : 168) : 235),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Text(
                'El lugar donde\nlos buenos momentos\ntoman forma.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleSize,
                  height: .98,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Spa · Glamping · Piscinas · Gastronomía · Eventos',
              style: TextStyle(
                  color: Color(0xFFF1D6A2),
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 14,
              runSpacing: 12,
              children: [
                _primaryButton('Reservar ahora', Icons.calendar_month_rounded,
                    () => _goTo(_reservasKey)),
                _outlineButton(
                    'Conocer experiencias', () => _goTo(_experienciasKey)),
              ],
            ),
            const SizedBox(height: 36),
            const Row(
              children: [
                Icon(Icons.star_rounded, color: Color(0xFFF1C36C), size: 20),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '4.7 / 5 en Google · experiencias que dejan huella',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroHeader(bool mobile, bool compact) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LA FINCA',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.5,
              fontSize: 21),
        ),
        if (!compact) ...[
          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: const Color(0xFFE6C68A)),
          const SizedBox(width: 12),
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              'SPA & RECEPCIONES',
              style: TextStyle(
                  color: Color(0xFFE6C68A), letterSpacing: 1.5, fontSize: 11),
            ),
          ),
        ],
        const Spacer(),
        if (!mobile)
          Wrap(
            spacing: 4,
            children: [
              _navButton('Experiencias', () => _goTo(_experienciasKey)),
              _navButton('Glamping', () => _goTo(_glampingKey)),
              _navButton('Eventos', () => _goTo(_eventosKey)),
              _navButton('Reservas', () => _goTo(_reservasKey)),
            ],
          ),
      ],
    );
  }

  Widget _navButton(String text, VoidCallback action) {
    return TextButton(
      onPressed: action,
      style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
      child: Text(text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _trustStrip(bool mobile) {
    final items = [
      ('01', 'Naturaleza', 'Un entorno para bajar el ritmo'),
      ('02', 'Experiencias', 'Planes para parejas y familias'),
      ('03', 'Celebraciones', 'Tu evento, con nuestro sello'),
    ];
    return Container(
      color: pale,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 72, vertical: 30),
      child: Wrap(
        spacing: mobile ? 28 : 70,
        runSpacing: 24,
        children: items
            .map(
              (item) => SizedBox(
                width: mobile ? double.infinity : 240,
                child: Row(
                  children: [
                    Text(item.$1,
                        style: const TextStyle(
                            color: gold,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$2,
                              style: const TextStyle(
                                  color: forest,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 3),
                          Text(item.$3,
                              style: const TextStyle(
                                  color: Color(0xFF68746B), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _section({
    required GlobalKey key,
    required bool mobile,
    required String eyebrow,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      key: key,
      padding: EdgeInsets.fromLTRB(24, mobile ? 68 : 88, 24, mobile ? 64 : 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _eyebrow(eyebrow),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                    color: forest,
                    fontSize: mobile ? 36 : 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFF69736B), fontSize: 16, height: 1.6)),
              ),
              const SizedBox(height: 40),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _experienceCards(bool mobile) {
    final cards = [
      (
        'SPA & AGUA',
        'Pausa profunda',
        'Masajes, hidromasaje y momentos para volver a ti.',
        Icons.spa_rounded,
        'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&w=900&q=80'
      ),
      (
        'GLAMPING',
        'Dormir bajo las estrellas',
        'Una escapada distinta, cómoda y conectada con la naturaleza.',
        Icons.nightlight_round,
        'https://images.unsplash.com/photo-1504851149312-7a075b496cc7?auto=format&fit=crop&w=900&q=80'
      ),
      (
        'GASTRONOMÍA',
        'Sabores para compartir',
        'Planes completos para que solo tengas que disfrutar.',
        Icons.restaurant_rounded,
        'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=80'
      ),
    ];
    return Wrap(
      spacing: 18,
      runSpacing: 18,
      children: cards
          .map((card) => SizedBox(
              width: mobile ? double.infinity : 370,
              child: _imageCard(card.$1, card.$2, card.$3, card.$4, card.$5)))
          .toList(),
    );
  }

  Widget _imageCard(
      String label, String title, String text, IconData icon, String image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 360,
        decoration: BoxDecoration(
            image:
                DecorationImage(image: NetworkImage(image), fit: BoxFit.cover)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: .86)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFFE9C47A), size: 28),
              const SizedBox(height: 12),
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFFE9C47A),
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 7),
              Text(text,
                  style: const TextStyle(
                      color: Color(0xFFE9E9E3), fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glampingSection(bool mobile) {
    return Container(
      key: _glampingKey,
      color: forest,
      padding: EdgeInsets.symmetric(
          horizontal: mobile ? 24 : 72, vertical: mobile ? 68 : 84),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 38,
            children: [
              SizedBox(
                width: mobile ? double.infinity : 520,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _eyebrow('NUEVA EXPERIENCIA'),
                    const SizedBox(height: 14),
                    Text('Glamping para\nquedarte un poco más.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: mobile ? 37 : 44,
                            height: 1.05,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 18),
                    const Text(
                        'Despierta con aire limpio, calma y el cielo como techo. La escapada perfecta para parejas, familias y quienes necesitan cambiar de paisaje.',
                        style: TextStyle(
                            color: Color(0xFFC8D6CD),
                            fontSize: 16,
                            height: 1.6)),
                    const SizedBox(height: 28),
                    _outlineButton(
                        'Ver disponibilidad', () => _goTo(_reservasKey)),
                  ],
                ),
              ),
              SizedBox(
                width: mobile ? double.infinity : 470,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                      color: const Color(0xFF235445),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF4D7968))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TU ESCAPADA INCLUYE',
                          style: TextStyle(
                              color: Color(0xFFE9C47A),
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      ...[
                        'Alojamiento con encanto',
                        'Acceso a zonas de descanso',
                        'Opciones de spa y alimentación',
                        'Atención cercana y personalizada'
                      ].map(
                        (text) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFFE9C47A), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(text,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 15))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventsSection(bool mobile) {
    return Container(
      key: _eventosKey,
      padding: EdgeInsets.fromLTRB(24, mobile ? 68 : 84, 24, mobile ? 68 : 84),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_eventCopy(mobile)])
              : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                              'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=1100&q=80',
                              height: 420,
                              fit: BoxFit.cover))),
                  const SizedBox(width: 74),
                  Expanded(child: _eventCopy(mobile)),
                ]),
        ),
      ),
    );
  }

  Widget _eventCopy(bool mobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mobile) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
                'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=1100&q=80',
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover),
          ),
          const SizedBox(height: 34),
        ],
        _eyebrow('RECEPCIONES & EVENTOS'),
        const SizedBox(height: 14),
        Text('Tu celebración merece un escenario especial.',
            style: TextStyle(
                color: forest,
                fontSize: mobile ? 35 : 40,
                height: 1.08,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 18),
        const Text(
            'Bodas, cumpleaños, reuniones familiares y eventos corporativos. Cuéntanos tu idea y construyamos una propuesta a la medida.',
            style:
                TextStyle(color: Color(0xFF69736B), fontSize: 16, height: 1.6)),
        const SizedBox(height: 26),
        Wrap(spacing: 14, runSpacing: 12, children: [
          _primaryButton('Cotizar mi evento', Icons.auto_awesome_rounded,
              () => _goTo(_reservasKey)),
          _textButton('Hablar con el equipo', _call)
        ]),
      ],
    );
  }

  Widget _testimonial() {
    return Container(
      color: pale,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: const Column(
            children: [
              Icon(Icons.format_quote_rounded, color: gold, size: 48),
              SizedBox(height: 10),
              Text(
                  '“Un lugar precioso y acogedor, con excelente servicio. Una gran opción para pasar un día en familia.”',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: forest,
                      fontSize: 25,
                      height: 1.35,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 18),
              Text('— Opinión verificada en Google',
                  style: TextStyle(color: Color(0xFF73786D), fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reservationSection(bool mobile) {
    return Container(
      key: _reservasKey,
      padding: EdgeInsets.fromLTRB(24, mobile ? 68 : 86, 24, mobile ? 68 : 86),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Container(
            padding: EdgeInsets.all(mobile ? 26 : 48),
            decoration: BoxDecoration(
                color: forest, borderRadius: BorderRadius.circular(28)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _eyebrow('HAZ TU RESERVA'),
                const SizedBox(height: 14),
                Text('Tu próxima experiencia\nempieza con un mensaje.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: mobile ? 34 : 39,
                        height: 1.08,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                const Text(
                    'Escríbenos y te ayudamos a elegir el plan ideal para tu visita, glamping o evento.',
                    style: TextStyle(
                        color: Color(0xFFC8D6CD), fontSize: 16, height: 1.5)),
                const SizedBox(height: 28),
                Wrap(spacing: 14, runSpacing: 12, children: [
                  _primaryButton(
                      'Reservar por WhatsApp', Icons.chat_rounded, _whatsapp),
                  _outlineButton('Llamar al 099 721 0017', _call)
                ]),
                const SizedBox(height: 24),
                const Text(
                    'Atención: jueves y viernes 14:00–22:00 · sábados y domingos 12:00–22:00',
                    style: TextStyle(color: Color(0xFF9FB9AB), fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _footer(bool mobile) {
    return Container(
      color: const Color(0xFF0D2D26),
      padding: EdgeInsets.fromLTRB(mobile ? 24 : 72, 34, mobile ? 24 : 72, 34),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 20,
        runSpacing: 18,
        children: [
          const Text('LA FINCA',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  fontSize: 17)),
          if (!mobile)
            const Text('Spa · Glamping · Recepciones',
                style: TextStyle(color: Color(0xFF9FB9AB), fontSize: 12)),
          const Text('© 2026 · Limón Indanza',
              style: TextStyle(color: Color(0xFF9FB9AB), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _eyebrow(String text) => Text(text,
      style: const TextStyle(
          color: gold,
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.w800));

  Widget _primaryButton(String text, IconData icon, VoidCallback onPressed) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: forest,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
    );
  }

  Widget _outlineButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFD7D7C8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      child: Text(text),
    );
  }

  Widget _textButton(String text, VoidCallback onPressed) {
    return TextButton(
        onPressed: onPressed,
        child: Text(text,
            style:
                const TextStyle(color: forest, fontWeight: FontWeight.bold)));
  }

  Future<void> _whatsapp() async {
    final uri = Uri.parse(
        'https://wa.me/593997210017?text=Hola%20LA%20FINCA%2C%20quiero%20consultar%20disponibilidad.');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      _showMessage(
          'WhatsApp', 'No se pudo abrir WhatsApp. Escríbenos al 099 721 0017.');
    }
  }

  Future<void> _call() async {
    final uri = Uri.parse('tel:+593997210017');
    if (!await launchUrl(uri) && mounted) {
      _showMessage(
          'Reservas', 'Llama al 099 721 0017 para consultar disponibilidad.');
    }
  }

  void _showMessage(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'))
        ],
      ),
    );
  }
}
