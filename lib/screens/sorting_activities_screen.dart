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

class _SortingActivitiesScreenState extends State<SortingActivitiesScreen> {
  List<bool> completedStages = [false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    _loadCompletedStages();
  }

  Future<void> _loadCompletedStages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      completedStages[0] = prefs.getBool('sorting_stage_1_completed') ?? false;
      completedStages[1] = prefs.getBool('sorting_stage_2_completed') ?? false;
      completedStages[2] = prefs.getBool('sorting_stage_3_completed') ?? false;
      completedStages[3] = prefs.getBool('sorting_stage_4_completed') ?? false;
      completedStages[4] = prefs.getBool('sorting_stage_5_completed') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;

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

            // Invisible back button
            Positioned(
              top: MediaQuery.of(context).size.height * 0.05,
              left: MediaQuery.of(context).size.width * 0.05,
              child: _buildInvisibleClickableArea(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ),

            // Gezegen tıklama alanları (fotoğraftaki sıraya göre - aşağıdan yukarıya)
            // Stage 1 - En alttaki turuncu-kırmızı kuyruklu yıldız (sağ alt)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.70,
              top: MediaQuery.of(context).size.height * 0.80,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 1),
              ),
            ),

            // Stage 2 - Sol alttaki Dünya benzeri gezegen (mavi-yeşil)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.25,
              top: MediaQuery.of(context).size.height * 0.70,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 2),
              ),
            ),

            // Stage 3 - Orta soldaki mor gezegen (girdaplı)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.20,
              top: MediaQuery.of(context).size.height * 0.45,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 3),
              ),
            ),

            // Stage 4 - Orta sağdaki Satürn benzeri gezegen (sarı-turuncu)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.70,
              top: MediaQuery.of(context).size.height * 0.35,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 4),
              ),
            ),

            // Stage 5 - En üstteki büyük mor gezegen (altın halkalı)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.75,
              top: MediaQuery.of(context).size.height * 0.15,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStar() {
    return Positioned(
      left:
          (DateTime.now().millisecondsSinceEpoch % 1000) /
          1000 *
          MediaQuery.of(context).size.width,
      top:
          (DateTime.now().millisecondsSinceEpoch % 1000) /
          1000 *
          MediaQuery.of(context).size.height,
      child: Container(
        width: 2,
        height: 2,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildNebula() {
    return Positioned(
      left: MediaQuery.of(context).size.width * 0.05,
      top: MediaQuery.of(context).size.height * 0.05,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFFE91E63).withOpacity(0.8),
              const Color(0xFF9C27B0).withOpacity(0.6),
              const Color(0xFF673AB7).withOpacity(0.4),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallNebula() {
    return Positioned(
      left: MediaQuery.of(context).size.width * 0.70,
      top: MediaQuery.of(context).size.height * 0.80,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFFFF9800).withOpacity(0.8),
              const Color(0xFFFF5722).withOpacity(0.6),
              const Color(0xFFE91E63).withOpacity(0.4),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpaceship() {
    return Positioned(
      left: MediaQuery.of(context).size.width * 0.50,
      top: MediaQuery.of(context).size.height * 0.60,
      child: Container(
        width: 30,
        height: 15,
        decoration: BoxDecoration(
          color: const Color(0xFFE53E3E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Uzay gemisi gövdesi
            Container(
              width: 30,
              height: 15,
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // Beyaz detaylar
            Positioned(
              left: 4,
              top: 6,
              child: Container(
                width: 6,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Egzoz efekti
            Positioned(
              left: -12,
              top: 5,
              child: Container(
                width: 12,
                height: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF9800),
                      const Color(0xFFFF5722),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
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
      painter: SpaceRoadmapPainter(completedStages),
    );
  }

  Widget _buildInvisibleClickableArea({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
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
                border: Border.all(color: Colors.transparent, width: 0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToStage(BuildContext context, int stageNumber) {
    final isEnglish =
        Provider.of<LanguageProvider>(context, listen: false).isEnglish;

    // Check if previous stages are completed
    bool canAccess = true;
    for (int i = 0; i < stageNumber - 1; i++) {
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
  final List<bool> completedStages;

  SpaceRoadmapPainter(this.completedStages);

  @override
  void paint(Canvas canvas, Size size) {
    // Asteroid yol segmentleri
    _drawAsteroidPath(canvas, size);

    // Gezegenlerin konumları (fotoğraftaki sıraya göre - aşağıdan yukarıya)
    final planets = [
      Offset(size.width * 0.70, size.height * 0.80), // 1. En alttaki turuncu-kırmızı kuyruklu yıldız
      Offset(size.width * 0.25, size.height * 0.70), // 2. Sol alttaki Dünya benzeri gezegen
      Offset(size.width * 0.20, size.height * 0.45), // 3. Orta soldaki mor gezegen (girdaplı)
      Offset(size.width * 0.70, size.height * 0.35), // 4. Orta sağdaki Satürn benzeri gezegen
      Offset(size.width * 0.75, size.height * 0.15), // 5. En üstteki büyük mor gezegen (altın halkalı)
    ];

    // Gezegenleri çiz
    for (int i = 0; i < planets.length; i++) {
      _drawPlanet(canvas, planets[i], i);
    }
  }

  void _drawAsteroidPath(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF8B5FBF).withOpacity(0.6)
          ..style = PaintingStyle.fill;

    // Asteroid segmentleri - fotoğraftaki gibi kıvrımlı yol
    final segments = [
      // Segment 1 - En alttan başlayan yol (sağ alt)
      Path()
        ..moveTo(size.width * 0.70, size.height * 0.90)
        ..lineTo(size.width * 0.75, size.height * 0.88)
        ..lineTo(size.width * 0.72, size.height * 0.85)
        ..close(),

      // Segment 2 - Sola doğru kıvrılan yol
      Path()
        ..moveTo(size.width * 0.30, size.height * 0.75)
        ..lineTo(size.width * 0.35, size.height * 0.73)
        ..lineTo(size.width * 0.32, size.height * 0.70)
        ..close(),

      // Segment 3 - Yukarı doğru çıkan yol
      Path()
        ..moveTo(size.width * 0.25, size.height * 0.50)
        ..lineTo(size.width * 0.30, size.height * 0.48)
        ..lineTo(size.width * 0.27, size.height * 0.45)
        ..close(),

      // Segment 4 - Sağa doğru kıvrılan yol
      Path()
        ..moveTo(size.width * 0.60, size.height * 0.40)
        ..lineTo(size.width * 0.65, size.height * 0.38)
        ..lineTo(size.width * 0.62, size.height * 0.35)
        ..close(),

      // Segment 5 - Sol üst köşeye doğru yol
      Path()
        ..moveTo(size.width * 0.70, size.height * 0.20)
        ..lineTo(size.width * 0.75, size.height * 0.18)
        ..lineTo(size.width * 0.72, size.height * 0.15)
        ..close(),
    ];

    for (final segment in segments) {
      canvas.drawPath(segment, paint);
    }
  }

  void _drawPlanet(Canvas canvas, Offset position, int index) {
    final planetPaint =
        Paint()
          ..color = _getPlanetColor(index)
          ..style = PaintingStyle.fill;

    final borderPaint =
        Paint()
          ..color = completedStages[index] ? Colors.green : Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    // Gezegen boyutu
    final radius = _getPlanetSize(index);

    // Ana gezegen
    canvas.drawCircle(position, radius, planetPaint);
    canvas.drawCircle(position, radius, borderPaint);

    // Halkalar (bazı gezegenler için)
    if (index == 1 || index == 2 || index == 3 || index == 4) {
      _drawRings(canvas, position, index);
    }

    // Gezegen numarası
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${index + 1}',
        style: const TextStyle(
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
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawRings(Canvas canvas, Offset position, int index) {
    final ringPaint =
        Paint()
          ..color = _getRingColor(index)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final radius = _getPlanetSize(index);

    // Halkalar
    canvas.drawCircle(position, radius + 8, ringPaint);
    canvas.drawCircle(position, radius + 12, ringPaint);
    if (index == 4) {
      // En üstteki büyük gezegen için ek halka
      canvas.drawCircle(position, radius + 16, ringPaint);
    }
  }

  double _getPlanetSize(int index) {
    switch (index) {
      case 0:
        return 20; // En alttaki turuncu-kırmızı kuyruklu yıldız - küçük
      case 1:
        return 25; // Sol alttaki Dünya benzeri gezegen - orta
      case 2:
        return 30; // Orta soldaki mor gezegen (girdaplı) - büyük
      case 3:
        return 22; // Orta sağdaki Satürn benzeri gezegen - orta
      case 4:
        return 35; // En üstteki büyük mor gezegen (altın halkalı) - en büyük
      default:
        return 25;
    }
  }

  Color _getPlanetColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFF5722); // En alttaki turuncu-kırmızı kuyruklu yıldız
      case 1:
        return const Color(0xFF4CAF50); // Sol alttaki Dünya benzeri gezegen (mavi-yeşil)
      case 2:
        return const Color(0xFF673AB7); // Orta soldaki mor gezegen (girdaplı)
      case 3:
        return const Color(0xFFFF9800); // Orta sağdaki Satürn benzeri gezegen (sarı-turuncu)
      case 4:
        return const Color(0xFF9C27B0); // En üstteki büyük mor gezegen (altın halkalı)
      default:
        return Colors.grey;
    }
  }

  Color _getRingColor(int index) {
    switch (index) {
      case 1:
        return const Color(0xFF81C784); // Dünya benzeri gezegen için yeşil halka
      case 2:
        return const Color(0xFFE91E63); // Mor gezegen için pembe halka
      case 3:
        return const Color(0xFFFFF8E1); // Satürn benzeri gezegen için açık sarı halkalar
      case 4:
        return const Color(0xFFFFD700); // En üstteki gezegen için altın halkalar
      default:
        return Colors.white;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
