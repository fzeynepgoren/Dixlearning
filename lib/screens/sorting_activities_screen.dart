import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../../SIRALAMA_SORULARI/Asama3/soru1.dart';
import 'home_screen.dart';

class SortingActivitiesScreen extends StatefulWidget {
  const SortingActivitiesScreen({super.key});

  @override
  State<SortingActivitiesScreen> createState() => _SortingActivitiesScreenState();
}

class _SortingActivitiesScreenState extends State<SortingActivitiesScreen> {
  List<bool> completedStages = [false, false, false, false, false, false];

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
      completedStages[5] = prefs.getBool('sorting_stage_6_completed') ?? false;
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

            // Gezegen tıklama alanları (fotoğraftaki sıraya göre)
            // Stage 1 - Sol üstteki girdaplı galaksi/nebula
            Positioned(
              left: MediaQuery.of(context).size.width * 0.15,
              top: MediaQuery.of(context).size.height * 0.15,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 1),
              ),
            ),

            // Stage 2 - Sağ üstteki büyük halkalı mor gezegen
            Positioned(
              left: MediaQuery.of(context).size.width * 0.75,
              top: MediaQuery.of(context).size.height * 0.20,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 2),
              ),
            ),

            // Stage 3 - Orta soldaki çizgili mor gezegen
            Positioned(
              left: MediaQuery.of(context).size.width * 0.25,
              top: MediaQuery.of(context).size.height * 0.45,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 3),
              ),
            ),

            // Stage 4 - Orta sağdaki halkalı sarı gezegen
            Positioned(
              left: MediaQuery.of(context).size.width * 0.65,
              top: MediaQuery.of(context).size.height * 0.50,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 4),
              ),
            ),

            // Stage 5 - Orta soldaki pembe halkalı mor gezegen
            Positioned(
              left: MediaQuery.of(context).size.width * 0.35,
              top: MediaQuery.of(context).size.height * 0.70,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 5),
              ),
            ),

            // Stage 6 - Orta sağdaki Dünya benzeri gezegen
            Positioned(
              left: MediaQuery.of(context).size.width * 0.70,
              top: MediaQuery.of(context).size.height * 0.75,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStar() {
    return Positioned(
      left: (DateTime.now().millisecondsSinceEpoch % 1000) / 1000 * MediaQuery.of(context).size.width,
      top: (DateTime.now().millisecondsSinceEpoch % 1000) / 1000 * MediaQuery.of(context).size.height,
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
      left: MediaQuery.of(context).size.width * 0.45,
      top: MediaQuery.of(context).size.height * 0.85,
      child: Container(
        width: 40,
        height: 20,
        decoration: BoxDecoration(
          color: const Color(0xFFE53E3E),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            // Uzay gemisi gövdesi
            Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Beyaz detaylar
            Positioned(
              left: 5,
              top: 8,
              child: Container(
                width: 8,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Egzoz efekti
            Positioned(
              left: -15,
              top: 7,
              child: Container(
                width: 15,
                height: 6,
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
    final isEnglish = Provider.of<LanguageProvider>(context, listen: false).isEnglish;

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
      case 6:
        // targetWidget = const SortingStage6();
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
        SnackBar(content: Text(isEnglish ? 'Coming soon!' : 'Yakında eklenecek!')),
      );
    }
  }

  void _showLockedStageDialog(BuildContext context, int stageNumber, bool isEnglish) {
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
    
    // Gezegenlerin konumları (fotoğraftaki sıraya göre)
    final planets = [
      Offset(size.width * 0.15, size.height * 0.15), // 1. Sol üstteki girdaplı galaksi/nebula
      Offset(size.width * 0.75, size.height * 0.20), // 2. Sağ üstteki büyük halkalı mor gezegen
      Offset(size.width * 0.25, size.height * 0.45), // 3. Orta soldaki çizgili mor gezegen
      Offset(size.width * 0.65, size.height * 0.50), // 4. Orta sağdaki halkalı sarı gezegen
      Offset(size.width * 0.35, size.height * 0.70), // 5. Orta soldaki pembe halkalı mor gezegen
      Offset(size.width * 0.70, size.height * 0.75), // 6. Orta sağdaki Dünya benzeri gezegen
    ];

    // Gezegenleri çiz
    for (int i = 0; i < planets.length; i++) {
      _drawPlanet(canvas, planets[i], i);
    }
  }

  void _drawAsteroidPath(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B5FBF).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Asteroid segmentleri - fotoğraftaki gibi düzensiz şekiller
    final segments = [
      // Segment 1 - Alt kısım
      Path()
        ..moveTo(size.width * 0.40, size.height * 0.90)
        ..lineTo(size.width * 0.50, size.height * 0.88)
        ..lineTo(size.width * 0.45, size.height * 0.85)
        ..close(),
      
      // Segment 2
      Path()
        ..moveTo(size.width * 0.35, size.height * 0.75)
        ..lineTo(size.width * 0.40, size.height * 0.78)
        ..lineTo(size.width * 0.38, size.height * 0.72)
        ..close(),
      
      // Segment 3
      Path()
        ..moveTo(size.width * 0.25, size.height * 0.50)
        ..lineTo(size.width * 0.30, size.height * 0.48)
        ..lineTo(size.width * 0.28, size.height * 0.45)
        ..close(),
      
      // Segment 4
      Path()
        ..moveTo(size.width * 0.60, size.height * 0.55)
        ..lineTo(size.width * 0.65, size.height * 0.53)
        ..lineTo(size.width * 0.63, size.height * 0.50)
        ..close(),
      
      // Segment 5
      Path()
        ..moveTo(size.width * 0.70, size.height * 0.30)
        ..lineTo(size.width * 0.75, size.height * 0.28)
        ..lineTo(size.width * 0.73, size.height * 0.25)
        ..close(),
      
      // Segment 6
      Path()
        ..moveTo(size.width * 0.15, size.height * 0.20)
        ..lineTo(size.width * 0.20, size.height * 0.18)
        ..lineTo(size.width * 0.18, size.height * 0.15)
        ..close(),
    ];

    for (final segment in segments) {
      canvas.drawPath(segment, paint);
    }
  }

  void _drawPlanet(Canvas canvas, Offset position, int index) {
    final planetPaint = Paint()
      ..color = _getPlanetColor(index)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = completedStages[index] ? Colors.green : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Gezegen boyutu
    final radius = _getPlanetSize(index);
    
    // Ana gezegen
    canvas.drawCircle(position, radius, planetPaint);
    canvas.drawCircle(position, radius, borderPaint);

    // Halkalar (bazı gezegenler için)
    if (index == 1 || index == 3 || index == 4) {
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
    final ringPaint = Paint()
      ..color = _getRingColor(index)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final radius = _getPlanetSize(index);
    
    // Halkalar
    canvas.drawCircle(position, radius + 8, ringPaint);
    canvas.drawCircle(position, radius + 12, ringPaint);
    if (index == 1) { // Büyük gezegen için ek halka
      canvas.drawCircle(position, radius + 16, ringPaint);
    }
  }

  double _getPlanetSize(int index) {
    switch (index) {
      case 0: return 25; // Nebula - küçük
      case 1: return 35; // Büyük halkalı gezegen
      case 2: return 20; // Çizgili mor gezegen
      case 3: return 22; // Halkalı sarı gezegen
      case 4: return 28; // Pembe halkalı mor gezegen
      case 5: return 24; // Dünya benzeri gezegen
      default: return 25;
    }
  }

  Color _getPlanetColor(int index) {
    switch (index) {
      case 0: return const Color(0xFFE91E63); // Sol üstteki girdaplı galaksi/nebula - Pembe
      case 1: return const Color(0xFF673AB7); // Sağ üstteki büyük halkalı mor gezegen - Mor
      case 2: return const Color(0xFF9C27B0); // Orta soldaki çizgili mor gezegen - Mor
      case 3: return const Color(0xFFFF9800); // Orta sağdaki halkalı sarı gezegen - Turuncu
      case 4: return const Color(0xFF8B5FBF); // Orta soldaki pembe halkalı mor gezegen - Mor-pembe
      case 5: return const Color(0xFF4CAF50); // Orta sağdaki Dünya benzeri gezegen - Yeşil
      default: return Colors.grey;
    }
  }

  Color _getRingColor(int index) {
    switch (index) {
      case 1: return const Color(0xFFFFF8E1); // Büyük gezegen için açık sarı halkalar
      case 3: return const Color(0xFFFFF8E1); // Sarı gezegen için açık sarı halkalar
      case 4: return const Color(0xFFE91E63); // Pembe gezegen için pembe halkalar
      default: return Colors.white;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}