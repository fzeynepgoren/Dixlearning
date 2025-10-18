import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../../SIRALAMA_SORULARI/Asama3/soru1.dart';
import 'home_screen.dart';

class SortingActivitiesScreen extends StatefulWidget {
  const SortingActivitiesScreen({super.key});

  @override
  State<SortingActivitiesScreen> createState() =>
      _SortingActivitiesScreenState();
}

class _SortingActivitiesScreenState extends State<SortingActivitiesScreen>
    with TickerProviderStateMixin {
  List<bool> completedStages = [false, false, false, false, false];
  late AnimationController _hoverController;
  int? hoveredPlanet;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadCompletedStages();
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  Future<void> _loadCompletedStages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Aşama numaraları tersine çevrildi: 5-4-3-2-1
      completedStages[0] = prefs.getBool('sorting_stage_5_completed') ?? false;
      completedStages[1] = prefs.getBool('sorting_stage_4_completed') ?? false;
      completedStages[2] = prefs.getBool('sorting_stage_3_completed') ?? false;
      completedStages[3] = prefs.getBool('sorting_stage_2_completed') ?? false;
      completedStages[4] = prefs.getBool('sorting_stage_1_completed') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D1B69), // Koyu mor
              Color(0xFF8B5FBF), // Orta mor
              Color(0xFFC77DFF), // Açık mor/pembe
              Color(0xFFE0AAFF), // Pembe
            ],
          ),
        ),
        child: Stack(
          children: [
            // Yıldızlar arka planı
            ...List.generate(100, (index) => _buildStar()),

            // Sol üstteki büyük nebula/galaksi
            _buildNebula(),

            // Sağ alttaki küçük nebula
            _buildSmallNebula(),

            // Ana gezegenler ve asteroid yolu
            _buildSpaceRoadmap(),

            // Uzay gemisi
            _buildSpaceship(),

            // Başlık - Sıralama Soruları (şeffaf arka plan)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.08,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    'Sıralama Soruları',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 3,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Geri tuşu (şeffaf arka plan)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.05,
              left: MediaQuery.of(context).size.width * 0.05,
              child: GestureDetector(
                onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 3,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Gezegen tıklama alanları (aşağıdan yukarıya 5-4-3-2-1)
            // Stage 5 - En alttaki kayalık yüzey (Stage 5)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.50,
              top: MediaQuery.of(context).size.height * 0.90,
              child: _buildPlanetClickableArea(
                planetNumber: 5,
                onTap: () => _navigateToStage(context, 5),
              ),
            ),

            // Stage 4 - Sağ alttaki turuncu-kırmızı kuyruklu yıldız (Stage 4)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.70,
              top: MediaQuery.of(context).size.height * 0.80,
              child: _buildPlanetClickableArea(
                planetNumber: 4,
                onTap: () => _navigateToStage(context, 4),
              ),
            ),

            // Stage 3 - Orta sağdaki mavi-yeşil Dünya benzeri gezegen (Stage 3)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.65,
              top: MediaQuery.of(context).size.height * 0.50,
              child: _buildPlanetClickableArea(
                planetNumber: 3,
                onTap: () => _navigateToStage(context, 3),
              ),
            ),

            // Stage 2 - Orta soldaki pembe halkalı mor gezegen (Stage 2)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.20,
              top: MediaQuery.of(context).size.height * 0.45,
              child: _buildPlanetClickableArea(
                planetNumber: 2,
                onTap: () => _navigateToStage(context, 2),
              ),
            ),

            // Stage 1 - Sol üstteki çizgili mor gezegen (Stage 1)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.15,
              top: MediaQuery.of(context).size.height * 0.25,
              child: _buildPlanetClickableArea(
                planetNumber: 1,
                onTap: () => _navigateToStage(context, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStar() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return Positioned(
      left: (random + random.hashCode) % MediaQuery.of(context).size.width,
      top: (random + random.hashCode * 2) % MediaQuery.of(context).size.height,
      child: Container(
        width: 2,
        height: 2,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 3,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNebula() {
    return Positioned(
      left: MediaQuery.of(context).size.width * 0.05,
      top: MediaQuery.of(context).size.height * 0.05,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.purple.withOpacity(0.3),
              Colors.pink.withOpacity(0.2),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallNebula() {
    return Positioned(
      right: MediaQuery.of(context).size.width * 0.1,
      bottom: MediaQuery.of(context).size.height * 0.1,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.height * 0.15,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.orange.withOpacity(0.4),
              Colors.red.withOpacity(0.2),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpaceship() {
    return Positioned(
      left: MediaQuery.of(context).size.width * 0.35,
      top: MediaQuery.of(context).size.height * 0.55,
      child: Container(
        width: 40,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            // Roket gövdesi
            Container(
              width: 30,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Roket burnu
            Positioned(
              left: 0,
              top: 5,
              child: Container(
                width: 15,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            // Alev
            Positioned(
              right: -5,
              top: 3,
              child: Container(
                width: 15,
                height: 14,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.yellow],
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpaceRoadmap() {
    return CustomPaint(
      size: Size.infinite,
      painter: SpaceRoadmapPainter(),
    );
  }

  Widget _buildPlanetClickableArea({
    required int planetNumber,
    required VoidCallback onTap,
  }) {
    final isHovered = hoveredPlanet == planetNumber;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hoveredPlanet = planetNumber;
        });
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() {
          hoveredPlanet = null;
        });
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: isHovered ? 1.2 : 1.0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow:
                    isHovered
                        ? [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.yellow.withOpacity(0.6),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ]
                        : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: onTap,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isHovered
                                ? Colors.white.withOpacity(0.8)
                                : Colors.transparent,
                        width: isHovered ? 3 : 0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$planetNumber',
                        style: TextStyle(
                          color: isHovered ? Colors.white : Colors.transparent,
                          fontSize: isHovered ? 20 : 0,
                          fontWeight: FontWeight.bold,
                          shadows:
                              isHovered
                                  ? [
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                      offset: const Offset(1, 1),
                                    ),
                                  ]
                                  : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  void _navigateToStage(BuildContext context, int stageNumber) {
    final isEnglish =
        Provider.of<LanguageProvider>(context, listen: false).isEnglish;

    // Check if previous stages are completed (aşama numaraları tersine çevrildi)
    bool canAccess = true;
    int stageIndex = stageNumber - 1; // 0-based index

    // Önceki aşamaları kontrol et (yukarıdan aşağıya)
    for (int i = 0; i < stageIndex; i++) {
      if (!completedStages[i]) {
        canAccess = false;
        break;
      }
    }

    if (!canAccess) {
      _showLockedStageDialog(context, stageNumber, isEnglish);
      return;
    }

    Widget? targetWidget;
    switch (stageNumber) {
      case 1:
        // targetWidget = const SortingStage1();
        break;
      case 2:
        // targetWidget = const SortingStage2();
        break;
      case 3:
        targetWidget = const Asama3Soru1();
        break;
      case 4:
        // targetWidget = const SortingStage4();
        break;
      case 5:
        // targetWidget = const SortingStage5();
        break;
    }

    if (targetWidget != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetWidget!),
      ).then((_) {
        // Refresh completed stages when returning
        _loadCompletedStages();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEnglish ? 'Coming soon!' : 'Yakında eklenecek!'),
        ),
      );
    }
  }

  void _showLockedStageDialog(
    BuildContext context,
    int stageNumber,
    bool isEnglish,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 20,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lock Icon with Animation
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 40),
                ),

                const SizedBox(height: 25),

                // Title
                Text(
                  isEnglish ? '🚀 Stage Locked!' : '🚀 Aşama Kilitli!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Message
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    isEnglish
                        ? 'You need to complete Stage ${stageNumber - 1} first before accessing Stage $stageNumber.'
                        : 'Aşama $stageNumber\'e erişmen için önce Aşama ${stageNumber - 1}\'i tamamlaman gerekiyor.',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                // Beautiful Button
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () => Navigator.of(context).pop(),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.rocket_launch,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isEnglish ? 'Got it!' : 'Anladım!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SpaceRoadmapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Asteroid yolu çiz
    _drawAsteroidPath(canvas, size);
    
    // Gezegenleri çiz
    _drawPlanets(canvas, size);
  }

  void _drawAsteroidPath(Canvas canvas, Size size) {
    final path = Path();
    
    // S şeklinde asteroid yolu
    path.moveTo(size.width * 0.5, size.height * 0.9); // Başlangıç (Stage 5)
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.8, // Stage 4
      size.width * 0.65, size.height * 0.5, // Stage 3
    );
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.45, // Stage 2
      size.width * 0.15, size.height * 0.25, // Stage 1
    );

    // Asteroid yolu için paint
    final asteroidPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = Colors.purple.withOpacity(0.8);

    canvas.drawPath(path, asteroidPaint);

    // Asteroid parçaları çiz
    _drawAsteroids(canvas, size);
  }

  void _drawAsteroids(Canvas canvas, Size size) {
    final asteroidPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.purple.withOpacity(0.9);

    // Yol boyunca asteroid parçaları
    final positions = [
      Offset(size.width * 0.5, size.height * 0.9),
      Offset(size.width * 0.6, size.height * 0.85),
      Offset(size.width * 0.7, size.height * 0.8),
      Offset(size.width * 0.68, size.height * 0.7),
      Offset(size.width * 0.65, size.height * 0.5),
      Offset(size.width * 0.45, size.height * 0.47),
      Offset(size.width * 0.2, size.height * 0.45),
      Offset(size.width * 0.18, size.height * 0.35),
      Offset(size.width * 0.15, size.height * 0.25),
    ];

    for (final pos in positions) {
      canvas.drawCircle(pos, 6, asteroidPaint);
    }
  }

  void _drawPlanets(Canvas canvas, Size size) {
    // Stage 5 - En alttaki kayalık yüzey
    _drawPlanet(canvas, size.width * 0.5, size.height * 0.9, 25, 
                Colors.brown, Colors.grey, 5);

    // Stage 4 - Sağ alttaki turuncu-kırmızı kuyruklu yıldız
    _drawPlanet(canvas, size.width * 0.7, size.height * 0.8, 20, 
                Colors.orange, Colors.red, 4);

    // Stage 3 - Orta sağdaki mavi-yeşil Dünya benzeri gezegen
    _drawPlanet(canvas, size.width * 0.65, size.height * 0.5, 30, 
                Colors.blue, Colors.green, 3);

    // Stage 2 - Orta soldaki pembe halkalı mor gezegen
    _drawPlanet(canvas, size.width * 0.2, size.height * 0.45, 28, 
                Colors.purple, Colors.pink, 2);

    // Stage 1 - Sol üstteki çizgili mor gezegen
    _drawPlanet(canvas, size.width * 0.15, size.height * 0.25, 35, 
                Colors.deepPurple, Colors.purple, 1);
  }

  void _drawPlanet(Canvas canvas, double x, double y, double radius, 
                   Color planetColor, Color ringColor, int stageNumber) {
    // Gezegen gövdesi
    final planetPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = planetColor;

    canvas.drawCircle(Offset(x, y), radius, planetPaint);

    // Gezegen halkası
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = ringColor;

    canvas.drawCircle(Offset(x, y), radius + 8, ringPaint);

    // Aşama numarası
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$stageNumber',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
