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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0C29), // Koyu mor
              Color(0xFF24243e), // Orta mor
              Color(0xFF302B63), // Açık mor
            ],
          ),
        ),
        child: Stack(
          children: [
            // Yıldızlar arka planı
            ...List.generate(50, (index) => _buildStar()),
            
            // Ana gezegenler ve yol
            _buildSpaceRoadmap(),
            
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

            // Gezegen tıklama alanları
            // Stage 1 - Dünya (sağ altta)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.15,
              top: MediaQuery.of(context).size.height * 0.75,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 1),
              ),
            ),

            // Stage 2 - Halkalı gezegen (sol altta)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.25,
              top: MediaQuery.of(context).size.height * 0.65,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 2),
              ),
            ),

            // Stage 3 - Satürn (ortada)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.45,
              top: MediaQuery.of(context).size.height * 0.55,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 3),
              ),
            ),

            // Stage 4 - Dev gezegen (sağ üstte)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.65,
              top: MediaQuery.of(context).size.height * 0.35,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 4),
              ),
            ),

            // Stage 5 - Nebula (sol üstte)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.15,
              top: MediaQuery.of(context).size.height * 0.25,
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
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Gezegenlerin konumları
    final planets = [
      Offset(size.width * 0.15, size.height * 0.75), // Dünya
      Offset(size.width * 0.25, size.height * 0.65), // Halkalı
      Offset(size.width * 0.45, size.height * 0.55), // Satürn
      Offset(size.width * 0.65, size.height * 0.35), // Dev
      Offset(size.width * 0.15, size.height * 0.25), // Nebula
    ];

    // Gezegenler arası yol çizgisi
    final path = Path();
    path.moveTo(planets[0].dx, planets[0].dy);
    for (int i = 1; i < planets.length; i++) {
      path.lineTo(planets[i].dx, planets[i].dy);
    }
    canvas.drawPath(path, paint);

    // Gezegenleri çiz
    for (int i = 0; i < planets.length; i++) {
      final planetPaint = Paint()
        ..color = _getPlanetColor(i)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = completedStages[i] ? Colors.green : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(planets[i], 30, planetPaint);
      canvas.drawCircle(planets[i], 30, borderPaint);

      // Gezegen numarası
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          planets[i].dx - textPainter.width / 2,
          planets[i].dy - textPainter.height / 2,
        ),
      );
    }
  }

  Color _getPlanetColor(int index) {
    switch (index) {
      case 0: return const Color(0xFF4CAF50); // Dünya - Yeşil
      case 1: return const Color(0xFF9C27B0); // Halkalı - Mor
      case 2: return const Color(0xFFFF9800); // Satürn - Turuncu
      case 3: return const Color(0xFF673AB7); // Dev - Mor-mavi
      case 4: return const Color(0xFFE91E63); // Nebula - Pembe
      default: return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}