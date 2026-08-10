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

class _ScrollReveal extends StatefulWidget {
  const _ScrollReveal({required this.controller, required this.child});

  final ScrollController controller;
  final Widget child;

  @override
  State<_ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<_ScrollReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_checkVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (_visible || !mounted) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    final top = renderObject.localToGlobal(Offset.zero).dy;
    final bottom = top + renderObject.size.height;
    final viewportHeight = MediaQuery.sizeOf(context).height;
    if (top < viewportHeight * .92 && bottom > 0) {
      setState(() => _visible = true);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_checkVisibility);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, .08),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late final AnimationController _mapPulseController;
  final _experienciasKey = GlobalKey();
  final _amazoniaKey = GlobalKey();
  final _glampingKey = GlobalKey();
  final _eventosKey = GlobalKey();
  final _ubicacionKey = GlobalKey();
  final _reservasKey = GlobalKey();

  static const forest = Color(0xFF173F35);
  static const pale = Color(0xFFE9E5D9);
  static const gold = Color(0xFFC8954B);
  static const instagramAsset = 'assets/instagram/profile.jpg';

  @override
  void initState() {
    super.initState();
    _mapPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

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
    _mapPulseController.dispose();
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
                  SliverToBoxAdapter(child: _amazoniaSection(mobile)),
                  SliverToBoxAdapter(
                    child: _section(
                      key: _experienciasKey,
                      mobile: mobile,
                      eyebrow: 'EL PLAN QUE TE ESTABA FALTANDO',
                      title: 'Aquí el descanso sí se convierte en recuerdo',
                      subtitle:
                          'No es solo venir a pasar el día: es sumergirte en piscinas, compartir buena comida y respirar la calma de la Amazonía. Tú llegas; nosotros nos encargamos del momento.',
                      child: _experienceCards(mobile),
                    ),
                  ),
                  SliverToBoxAdapter(child: _glampingSection(mobile)),
                  SliverToBoxAdapter(child: _eventsSection(mobile)),
                  SliverToBoxAdapter(child: _locationSection(mobile)),
                  SliverToBoxAdapter(child: _instagramSection(mobile)),
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        constraints:
            BoxConstraints(minHeight: mobile ? (compact ? 650 : 680) : 700),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/instagram/aerial.jpg'),
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
                  'La Amazonía que\nse disfruta sin\nprisa.',
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
                'PISCINAS · SPA · GLAMPING · GASTRONOMÍA · EVENTOS',
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
              Wrap(
                spacing: 10,
                runSpacing: 9,
                children: const [
                  _HeroPill(icon: Icons.pool_rounded, text: 'Piscinas'),
                  _HeroPill(
                      icon: Icons.local_parking_rounded, text: 'Parqueadero'),
                  _HeroPill(
                      icon: Icons.family_restroom_rounded,
                      text: 'Ambiente familiar'),
                ],
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Icon(Icons.star_rounded, color: Color(0xFFF1C36C), size: 20),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                        '4,7 / 5 en Google · un destino que invita a volver',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroHeader(bool mobile, bool compact) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _profileLogo(compact ? 34 : 40),
        const SizedBox(width: 10),
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
              _navButton('Amazonía', () => _goTo(_amazoniaKey)),
              _navButton('Glamping', () => _goTo(_glampingKey)),
              _navButton('Eventos', () => _goTo(_eventosKey)),
              _navButton('Ubicación', () => _goTo(_ubicacionKey)),
              _navButton('Reservas', () => _goTo(_reservasKey)),
            ],
          )
        else
          _mobileMenu(),
      ],
    );
  }

  Widget _mobileMenu() {
    return PopupMenuButton<String>(
      tooltip: 'Abrir menú',
      icon: const Icon(Icons.menu_rounded, color: Colors.white),
      color: const Color(0xFF173F35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        switch (value) {
          case 'experiencias':
            _goTo(_experienciasKey);
            break;
          case 'amazonia':
            _goTo(_amazoniaKey);
            break;
          case 'glamping':
            _goTo(_glampingKey);
            break;
          case 'eventos':
            _goTo(_eventosKey);
            break;
          case 'ubicacion':
            _goTo(_ubicacionKey);
            break;
          case 'reservas':
            _goTo(_reservasKey);
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
            value: 'experiencias',
            child: Text('Experiencias', style: TextStyle(color: Colors.white))),
        PopupMenuItem(
            value: 'amazonia',
            child: Text('Amazonía y clima',
                style: TextStyle(color: Colors.white))),
        PopupMenuItem(
            value: 'glamping',
            child: Text('Glamping', style: TextStyle(color: Colors.white))),
        PopupMenuItem(
            value: 'eventos',
            child: Text('Eventos', style: TextStyle(color: Colors.white))),
        PopupMenuItem(
            value: 'ubicacion',
            child: Text('Ubicación', style: TextStyle(color: Colors.white))),
        PopupMenuItem(
            value: 'reservas',
            child: Text('Reservar',
                style: TextStyle(
                    color: Color(0xFFE9C47A), fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _profileLogo(double size) {
    return ClipOval(
      child: Image.asset(
        instagramAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          color: gold,
          child: Icon(Icons.spa_rounded, color: forest, size: size * .52),
        ),
      ),
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
      ('01', 'Amazonía viva', 'Naturaleza que se siente en cada rincón'),
      ('02', 'Piscinas y calma', 'Un plan fresco para compartir sin apuro'),
      (
        '03',
        'Llegas tranquilo',
        'Parqueadero para visitantes y atención cercana'
      ),
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

  Widget _amazoniaSection(bool mobile) {
    final routes = [
      ('Cuenca', '110 km', '1 h 48 min', Icons.terrain_rounded),
      ('Macas', '115 km', '1 h 30 min', Icons.route_rounded),
      ('Guayaquil', '304 km', '4 h 50 min', Icons.directions_car_rounded),
      ('Quito', '487 km', 'aprox. 10 h', Icons.travel_explore_rounded),
    ];
    return Container(
      key: _amazoniaKey,
      color: const Color(0xFFE8EFE7),
      padding: EdgeInsets.fromLTRB(24, mobile ? 64 : 82, 24, mobile ? 64 : 82),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 36,
            children: [
              SizedBox(
                width: mobile ? double.infinity : 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _eyebrow('EN EL CORAZÓN DE LA AMAZONÍA SUR'),
                    const SizedBox(height: 14),
                    Text('El clima perfecto para bajar las revoluciones.',
                        style: TextStyle(
                            color: forest,
                            fontSize: mobile ? 35 : 44,
                            height: 1.06,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1)),
                    const SizedBox(height: 18),
                    const Text(
                      'Limón Indanza tiene un clima cálido y húmedo de montaña amazónica: verde, fresco y vivo. Aquí una tarde de piscina, una comida compartida o una noche de glamping se sienten como una verdadera escapada.',
                      style: TextStyle(
                          color: Color(0xFF52645A), fontSize: 16, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    Row(children: [
                      _climateStat(Icons.thermostat_rounded, '20–24 °C',
                          'temperatura de referencia'),
                      const SizedBox(width: 24),
                      _climateStat(Icons.water_drop_rounded, 'Amazonía',
                          'verde todo el año'),
                    ]),
                    const SizedBox(height: 26),
                    _primaryButton(
                        'Planear mi visita', Icons.map_rounded, _openMaps),
                  ],
                ),
              ),
              SizedBox(
                width: mobile ? double.infinity : 570,
                child: Container(
                  padding: EdgeInsets.all(mobile ? 22 : 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x160D2D26),
                          blurRadius: 22,
                          offset: Offset(0, 10))
                    ],
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ESTÁS MÁS CERCA DE LO QUE CREES',
                            style: TextStyle(
                                color: forest,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                letterSpacing: 1.1)),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: routes
                              .map((route) => _routeCard(mobile, route.$1,
                                  route.$2, route.$3, route.$4))
                              .toList(),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                            'Distancias y tiempos referenciales; confírmalos antes de salir según la ruta y el estado de la vía.',
                            style: TextStyle(
                                color: Color(0xFF738078),
                                fontSize: 11,
                                height: 1.35)),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _climateStat(IconData icon, String value, String label) => Expanded(
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
                color: Color(0xFFCEE0D3), shape: BoxShape.circle),
            child: Icon(icon, color: forest, size: 20),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: const TextStyle(
                    color: forest, fontSize: 16, fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(color: Color(0xFF607168), fontSize: 11)),
          ]),
        ]),
      );

  Widget _routeCard(bool mobile, String city, String distance, String time,
          IconData icon) =>
      SizedBox(
        width: mobile ? double.infinity : 244,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: const Color(0xFFF7F5EF),
              borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Icon(icon, color: gold, size: 22),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Desde $city',
                      style: const TextStyle(
                          color: forest,
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                  const SizedBox(height: 3),
                  Text('$distance · $time',
                      style: const TextStyle(
                          color: Color(0xFF647169), fontSize: 12)),
                ])),
          ]),
        ),
      );

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
              _reveal(child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reveal(Widget child) {
    return _ScrollReveal(controller: _scrollController, child: child);
  }

  Widget _experienceCards(bool mobile) {
    final cards = [
      (
        'SPA & AGUA',
        'Tu pausa empieza aquí',
        'Agua, descanso y un ambiente que te invita a soltar la rutina.',
        Icons.spa_rounded,
        'assets/instagram/aerial.jpg'
      ),
      (
        'GLAMPING',
        'Una noche para recordar',
        'Próximamente: comodidad, naturaleza y el cielo amazónico como compañía.',
        Icons.nightlight_round,
        'assets/instagram/landscape.jpg'
      ),
      (
        'GASTRONOMÍA',
        'La mesa reúne todo',
        'Buena comida y el espacio perfecto para compartir con los tuyos.',
        Icons.restaurant_rounded,
        'assets/instagram/people.jpg'
      ),
      (
        'PLAN CAMPIN',
        'Tu escape desde \$15',
        'Uso de instalaciones, menú seleccionado y zona de camping.',
        Icons.local_fire_department_rounded,
        'assets/instagram/campin.jpg'
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 22 * (1 - value)),
          child: child,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 360,
          decoration: BoxDecoration(
              image:
                  DecorationImage(image: AssetImage(image), fit: BoxFit.cover)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: .86)
                ],
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
                    Text('Muy pronto:\nglamping en la Amazonía.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: mobile ? 37 : 44,
                            height: 1.05,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 18),
                    const Text(
                        'Cambia el ruido por grillos, aire limpio y una noche distinta. Estamos preparando una experiencia para parejas, familias y viajeros que quieren despertar rodeados de verde.',
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
                        'Espacios pensados para desconectarte',
                        'Piscinas y zonas para disfrutar el día',
                        'Opciones de spa y alimentación',
                        'Atención cercana desde tu llegada'
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
                          child: Image.asset('assets/instagram/people.jpg',
                              height: 420, fit: BoxFit.cover))),
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
            child: Image.asset('assets/instagram/people.jpg',
                height: 260, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 34),
        ],
        _eyebrow('RECEPCIONES & EVENTOS'),
        const SizedBox(height: 14),
        Text('Celebra en un lugar que todos van a recordar.',
            style: TextStyle(
                color: forest,
                fontSize: mobile ? 35 : 40,
                height: 1.08,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 18),
        const Text(
            'Cumpleaños, reuniones familiares y eventos corporativos en un entorno amplio, verde y relajado. Cuéntanos tu idea y creemos un plan que se sienta hecho para ustedes.',
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

  Widget _locationSection(bool mobile) {
    return Container(
      key: _ubicacionKey,
      color: const Color(0xFFF0EDE4),
      padding: EdgeInsets.fromLTRB(24, mobile ? 68 : 82, 24, mobile ? 68 : 82),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 34,
            children: [
              SizedBox(
                width: mobile ? double.infinity : 540,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _eyebrow('ENCUÉNTRANOS'),
                    const SizedBox(height: 14),
                    Text(
                      'Ven a desconectar\nen Limón Indanza.',
                      style: TextStyle(
                        color: forest,
                        fontSize: mobile ? 36 : 44,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'En General Leonidas Plaza, Morona Santiago, te espera un espacio tranquilo para venir en pareja, con amigos o en familia. Tenemos piscinas, áreas para compartir y parqueadero para visitantes. Escríbenos antes de salir y te ayudamos a preparar el plan.',
                      style: TextStyle(
                        color: Color(0xFF69736B),
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _primaryButton(
                            'Cómo llegar', Icons.directions_rounded, _openMaps),
                        _textButton('Llamar al equipo', _call),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: mobile ? double.infinity : 480,
                child: Container(
                  padding: EdgeInsets.all(mobile ? 24 : 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFDCD7C9)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x120D2D26),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _mapPreview(mobile),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0EA),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.location_on_rounded,
                                color: forest, size: 24),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'LA FINCA spa & recepciones',
                              style: TextStyle(
                                  color: forest,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _locationDetail(Icons.place_outlined, 'Dirección',
                          '2G4C+5F, Gral. Leonidas Plaza Gutiérrez\nLimón Indanza, Morona Santiago · Ecuador'),
                      _locationDetail(Icons.schedule_rounded, 'Horario',
                          'Jueves y viernes: 14:00–22:00\nSábados y domingos: 12:00–22:00'),
                      _locationDetail(Icons.star_rounded, 'Google Maps',
                          '4,7 / 5 · categoría Spa'),
                      _locationDetail(Icons.pin_drop_outlined, 'Coordenadas',
                          '-2.9945989, -78.4787797'),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _openMaps,
                          icon: const Icon(Icons.open_in_new_rounded, size: 17),
                          label: const Text('Abrir ubicación en Google Maps'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: forest,
                            side: const BorderSide(color: Color(0xFFB8C8BD)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
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

  Widget _mapPreview(bool mobile) {
    const centerX = 4620;
    const centerY = 8328;
    final tiles = <Widget>[];
    for (var row = -1; row <= 1; row++) {
      for (var column = -1; column <= 1; column++) {
        final tileX = centerX + column;
        final tileY = centerY + row;
        tiles.add(Positioned(
          left: (column + 1) * 256,
          top: (row + 1) * 256,
          width: 256,
          height: 256,
          child: Image.network(
            'https://tile.openstreetmap.org/14/$tileX/$tileY.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: const Color(0xFFD8E3D8)),
          ),
        ));
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: mobile ? 190 : 210,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: const Color(0xFFD8E3D8),
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: 768,
                  height: 768,
                  child: Stack(children: tiles),
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _mapPulseController,
                builder: (context, child) => Transform.scale(
                  scale: .92 + (_mapPulseController.value * .12),
                  child: child,
                ),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4B96A),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x550D2D26),
                          blurRadius: 12,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.spa_rounded, color: forest, size: 18),
                ),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 14,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('LA FINCA · Limón Indanza',
                      style: TextStyle(
                          color: forest,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: forest.withValues(alpha: .88),
                    shape: BoxShape.circle),
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(Icons.map_rounded, color: Colors.white, size: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: forest,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(
                        color: Color(0xFF69736B), fontSize: 13, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _instagramSection(bool mobile) {
    return Container(
      color: const Color(0xFFFBF8F2),
      padding: EdgeInsets.fromLTRB(24, mobile ? 64 : 76, 24, mobile ? 64 : 76),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 30,
            children: [
              SizedBox(
                width: mobile ? double.infinity : 540,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _eyebrow('LA FINCA EN INSTAGRAM'),
                    const SizedBox(height: 14),
                    Text(
                      'Un lugar para\ndesconectarte.',
                      style: TextStyle(
                        color: forest,
                        fontSize: mobile ? 37 : 44,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Descubre nuestros espacios, sabores y celebraciones en el perfil oficial de LA FINCA. Síguenos para enterarte de novedades, promociones y del próximo lanzamiento de glamping.',
                      style: TextStyle(
                          color: Color(0xFF69736B), fontSize: 16, height: 1.6),
                    ),
                    const SizedBox(height: 26),
                    _primaryButton('Visitar @lafinca.spa',
                        Icons.camera_alt_rounded, _openInstagram),
                  ],
                ),
              ),
              SizedBox(
                width: mobile ? double.infinity : 450,
                child: Container(
                  padding: EdgeInsets.all(mobile ? 26 : 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF173F35), Color(0xFF734E4D)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x220D2D26),
                          blurRadius: 24,
                          offset: Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipOval(
                            child: Image.asset(
                              instagramAsset,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 56,
                                height: 56,
                                color: const Color(0xFF315D50),
                                child: const Icon(Icons.camera_alt_rounded,
                                    color: Colors.white, size: 25),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text('@lafinca.spa',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const Icon(Icons.verified_rounded,
                              color: Color(0xFFE9C47A), size: 20),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('SPA · GASTRONOMÍA · EVENTOS',
                          style: TextStyle(
                              color: Color(0xFFE9C47A),
                              fontSize: 11,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text(
                          'Glamping próximamente · Limón Indanza, Morona Santiago',
                          style: TextStyle(
                              color: Colors.white, fontSize: 16, height: 1.45)),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['Desconexión', 'Buena mesa', 'Celebraciones']
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 11, vertical: 7),
                                decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .12),
                                    borderRadius: BorderRadius.circular(30)),
                                child: Text(tag,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ),
                            )
                            .toList(),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _profileLogo(34),
              const SizedBox(width: 10),
              const Text('LA FINCA',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      fontSize: 17)),
            ],
          ),
          if (!mobile)
            const Text('Spa · Glamping · Recepciones',
                style: TextStyle(color: Color(0xFF9FB9AB), fontSize: 12)),
          Wrap(
            spacing: 2,
            children: [
              _socialButton(
                  'Instagram', Icons.camera_alt_rounded, _openInstagram),
              _socialButton('WhatsApp', Icons.chat_rounded, _whatsapp),
              _socialButton('Maps', Icons.map_rounded, _openMaps),
            ],
          ),
          const Text('© 2026 · Limón Indanza',
              style: TextStyle(color: Color(0xFF9FB9AB), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _socialButton(String label, IconData icon, VoidCallback action) {
    return TextButton.icon(
      onPressed: action,
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFC8D6CD),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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

  Future<void> _openInstagram() async {
    final uri = Uri.parse('https://www.instagram.com/lafinca.spa/');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      _showMessage('Instagram',
          'Visita @lafinca.spa en Instagram para conocer novedades de LA FINCA.');
    }
  }

  Future<void> _openMaps() async {
    final uri = Uri.parse('https://maps.app.goo.gl/DoZu9bp9NGxzDAvg9');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      _showMessage('Ubicación',
          'Abre Google Maps y busca: LA FINCA spa & recepciones, Limón Indanza.');
    }
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

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: .20)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: const Color(0xFFF1D6A2), size: 15),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
