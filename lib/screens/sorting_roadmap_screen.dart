import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
// Lütfen bu importların projenizde doğru yollara sahip olduğundan emin olun
import '../providers/language_provider.dart';
import '../../SIRALAMA_SORULARI/Asama3/soru1.dart';
import '../../SIRALAMA_SORULARI/Asama2/soru1.dart';
import '../../SIRALAMA_SORULARI/Asama2/soru2.dart';
import 'home_screen.dart';

// Gezegen ve yol renklerini kontrol etmek için yeni sabitler
const Color _unlockedStarColor = Color(0xFFFFD700); // Altın Sarısı
const Color _lockedStarColor = Color(0xFF4A4E69); // Soluk Gri/Mavi
const Color _readyToUnlockGlowColor = Color(0xFF6C63FF); // Mor/Mavi parlama

class SortingRoadmapScreen extends StatefulWidget {
  const SortingRoadmapScreen({super.key});

  @override
  State<SortingRoadmapScreen> createState() => _SortingRoadmapScreenState();
}

class _SortingRoadmapScreenState extends State<SortingRoadmapScreen>
    with TickerProviderStateMixin {
  // Aşama numaraları: 1-2-3-4-5
  List<bool> completedStages = [
    true,
    true,
    false,
    false,
    false,
  ]; // Temporarily unlock stages 1 and 2

  // Yıldız sistemi: Her aşama için 0-3 yıldız
  List<int> starCounts = [0, 0, 0, 0, 0]; // Her aşama için yıldız sayısı

  // Gezegen etkileşimleri için Controller
  late AnimationController _planetHoverController;
  late Animation<double> _glowAnimation;
  int? hoveredPlanet;

  // Kayan yıldızlar için Controller'lar
  late AnimationController _shootingStarController1;
  late Animation<Offset> _shootingStarAnimation1;
  late AnimationController _shootingStarController2;
  late Animation<Offset> _shootingStarAnimation2;

  // Konfeti Controller'ı
  late ConfettiController _confettiController;

  // Gezegen konumları (Ekran Yüksekliği oranları)
  // [stageNumber, x_ratio, y_ratio, emoji]
  final List<List<dynamic>> _planetPositions = [
    [1, 0.35, 0.85, "🌍"], // En altta - Dünya
    [2, 0.75, 0.66, "🌕"], // Dolunay
    [3, 0.28, 0.51, "🪐"], // Satürn
    [4, 0.65, 0.34, "🌑"], // Yeni ay
    [5, 0.38, 0.19, "🛸"], // En üstte - Uzay aracı
  ];

  @override
  void initState() {
    super.initState();

    // Gezegen Parlama Kontrolcüsü
    _planetHoverController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _planetHoverController, curve: Curves.easeInOut),
    );

    // Kayan Yıldız 1 Kontrolcüsü ve Animasyonu
    _shootingStarController1 = AnimationController(
      duration: const Duration(seconds: 4), // Geçiş süresi
      vsync: this,
    )..repeat(
      // Belirli bir gecikmeyle tekrarla
      period: const Duration(seconds: 10),
      reverse: false,
    );
    _shootingStarAnimation1 = Tween<Offset>(
      begin: const Offset(
        -0.2,
        0.3,
      ), // Ekranın sol üstünden başla (x,y oranları)
      end: const Offset(1.2, 0.8), // Ekranın sağ altına doğru git
    ).animate(
      CurvedAnimation(parent: _shootingStarController1, curve: Curves.linear),
    );

    // Kayan Yıldız 2 Kontrolcüsü ve Animasyonu
    _shootingStarController2 = AnimationController(
      duration: const Duration(seconds: 3), // Daha hızlı geçiş
      vsync: this,
    )..repeat(
      period: const Duration(seconds: 8), // Daha sık tekrarla
      reverse: false,
    );
    _shootingStarAnimation2 = Tween<Offset>(
      begin: const Offset(1.2, 0.1), // Ekranın sağ üstünden başla
      end: const Offset(-0.2, 0.6), // Ekranın sol altına doğru git
    ).animate(
      CurvedAnimation(parent: _shootingStarController2, curve: Curves.linear),
    );

    // Konfeti Controller'ını initialize et
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _loadCompletedStages();
  }

  @override
  void dispose() {
    _planetHoverController.dispose();
    _shootingStarController1.dispose();
    _shootingStarController2.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadCompletedStages() async {
    final prefs = await SharedPreferences.getInstance();

    // Önceki durumu sakla
    List<bool> previousCompletedStages = List.from(completedStages);

    setState(() {
      completedStages[0] =
          prefs.getBool('sorting_stage_1_completed') ??
          true; // Temporarily unlocked
      completedStages[1] =
          prefs.getBool('sorting_stage_2_completed') ??
          true; // Temporarily unlocked
      completedStages[2] = prefs.getBool('sorting_stage_3_completed') ?? false;
      completedStages[3] = prefs.getBool('sorting_stage_4_completed') ?? false;
      completedStages[4] = prefs.getBool('sorting_stage_5_completed') ?? false;

      // Yıldız sayılarını yükle
      starCounts[0] = prefs.getInt('sorting_stage_1_stars') ?? 0;
      starCounts[1] = prefs.getInt('sorting_stage_2_stars') ?? 0;
      starCounts[2] = prefs.getInt('sorting_stage_3_stars') ?? 0;
      starCounts[3] = prefs.getInt('sorting_stage_4_stars') ?? 0;
      starCounts[4] = prefs.getInt('sorting_stage_5_stars') ?? 0;
    });

    // Yeni tamamlanan aşama var mı kontrol et (sadece gerçek aşamalar için)
    for (int i = 2; i < completedStages.length; i++) {
      // Sadece 3, 4, 5. aşamalar için
      if (!previousCompletedStages[i] && completedStages[i]) {
        // Yeni bir aşama tamamlandı!
        _triggerConfetti();
        break; // Sadece bir kez konfeti patlat
      }
    }
  }

  // Konfeti tetikleme metodu
  void _triggerConfetti() {
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Gezegenlerin piksel cinsinden konumlarını hesapla (Path Painter için gerekli)
    final pixelPositions =
        _planetPositions
            .map(
              (p) => Offset(
                screenSize.width * (p[1] as double),
                screenSize.height * (p[2] as double),
              ),
            )
            .toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D0A1C),
              Color(0xFF1E1A5F),
              Color(0xFF183B89),
              Color(0xFF0E1A40),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // 🌟 Sabit yıldızlar
            ...List.generate(70, (index) {
              final random = Random(index);
              final left = random.nextDouble() * screenSize.width;
              final top = random.nextDouble() * screenSize.height;
              final size = random.nextDouble() * 2 + 1;
              return Positioned(
                left: left,
                top: top,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),

            // ✨ Kayan Yıldız 1
            AnimatedBuilder(
              animation: _shootingStarAnimation1,
              builder: (context, child) {
                return Positioned(
                  left: screenSize.width * _shootingStarAnimation1.value.dx,
                  top: screenSize.height * _shootingStarAnimation1.value.dy,
                  child: ShootingStar(
                    key: const ValueKey('shootingStar1'),
                    color: Colors.white,
                    size: 4, // Başlangıç boyutu
                    tailLength: 60, // Kuyruk uzunluğu
                    directionAngle: -pi / 4, // Sağ alta doğru
                    trailDuration: const Duration(
                      milliseconds: 700,
                    ), // İz silinme süresi
                    trailSegmentCount: 15, // İzdeki nokta sayısı
                  ),
                );
              },
            ),

            // ✨ Kayan Yıldız 2 (farklı konum ve zamanlama ile)
            AnimatedBuilder(
              animation: _shootingStarAnimation2,
              builder: (context, child) {
                return Positioned(
                  left: screenSize.width * _shootingStarAnimation2.value.dx,
                  top: screenSize.height * _shootingStarAnimation2.value.dy,
                  child: ShootingStar(
                    key: const ValueKey('shootingStar2'),
                    color: Colors.amberAccent,
                    size: 3,
                    tailLength: 40,
                    directionAngle: pi / 4, // Sol alta doğru
                    trailDuration: const Duration(milliseconds: 500),
                    trailSegmentCount: 10,
                  ),
                );
              },
            ),

            // 🌟 Yıldızlardan oluşan eğri yol (Gezegenler arası bağlantılar dahil)
            Positioned.fill(
              top: 0,
              bottom: 0,
              child: CustomPaint(
                painter: StarPathPainter(
                  completedStages: completedStages,
                  customHeight: screenSize.height,
                  planetPositions: pixelPositions,
                ),
              ),
            ),

            // 🪐 Gezegenler alttan yukarı 1–5
            ..._planetPositions
                .map(
                  (p) => _buildPlanetClickableArea(
                    context,
                    p[2], // y_ratio
                    p[1], // x_ratio
                    p[3] as String, // emoji
                    p[0] as int, // stageNumber
                  ),
                )
                .toList(),

            // Başlık kaldırıldı

            // Geri tuşu
            Positioned(
              top: screenSize.height * 0.05,
              left: screenSize.width * 0.05,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(27),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),

            // 🎉 Konfeti efekti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2, // Aşağı doğru
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.amber,
                  Colors.yellow,
                  Colors.orange,
                  Colors.deepOrange,
                ],
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.3,
                maxBlastForce: 20,
                minBlastForce: 5,
                particleDrag: 0.05,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🪐 Gezegen (emoji + numara) - tıklanabilir ve parlar
  Widget _buildPlanetClickableArea(
    BuildContext context,
    double y, // Y konumu oranı
    double x, // X konumu oranı
    String emoji,
    int stageNumber,
  ) {
    final isHovered = hoveredPlanet == stageNumber;
    final isLocked = stageNumber > 1 && !completedStages[stageNumber - 2];
    final isCompleted = completedStages[stageNumber - 1];

    // Aşama erişilebilir VE tamamlanmamışsa sürekli parlamalı
    final shouldGlowContinuously = !isLocked && !isCompleted;

    return Positioned(
      // Gezegeni yolun merkezine hizalamak için düzenleme yapıldı (boyut 60x60 varsayımıyla)
      left: MediaQuery.of(context).size.width * x - 30,
      top: MediaQuery.of(context).size.height * y - 30,
      child: MouseRegion(
        onEnter: (_) {
          if (!isLocked) {
            setState(() {
              hoveredPlanet = stageNumber;
            });
          }
        },
        onExit: (_) {
          if (!isLocked) {
            setState(() {
              hoveredPlanet = null;
            });
          }
        },
        child: AnimatedBuilder(
          animation: _planetHoverController,
          builder: (context, child) {
            final glowScale =
                shouldGlowContinuously ? _glowAnimation.value : 1.0;
            final finalScale = isHovered ? 1.2 : glowScale;

            return Transform.scale(
              scale: finalScale,
              child: GestureDetector(
                onTap:
                    isLocked
                        ? () => _showLockedStageDialog(
                          context,
                          stageNumber,
                          Provider.of<LanguageProvider>(
                            context,
                            listen: false,
                          ).isEnglish,
                        )
                        : () => _navigateToStage(context, stageNumber),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // ✨ Parlama Efekti
                        boxShadow:
                            isHovered
                                ? [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(1.0),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ]
                                : shouldGlowContinuously
                                ? [
                                  BoxShadow(
                                    color: _readyToUnlockGlowColor.withOpacity(
                                      0.8,
                                    ),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ]
                                : isCompleted
                                ? [
                                  BoxShadow(
                                    color: Colors.greenAccent.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 3,
                                  ),
                                ]
                                : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            emoji,
                            style: TextStyle(
                              fontSize:
                                  emoji == "🪐"
                                      ? (isHovered
                                          ? 75
                                          : 65) // Satürn daha büyük
                                      : (isHovered
                                          ? 65
                                          : 55), // Diğer gezegenler normal
                              color:
                                  emoji == "🌑"
                                      ? Colors
                                          .blue
                                          .shade300 // Yeni ay için mavi renk
                                      : null, // Diğerleri için varsayılan renk
                              shadows:
                                  emoji == "🌑"
                                      ? [
                                        Shadow(
                                          color: Colors.blue.shade200,
                                          blurRadius: 12,
                                        ),
                                        Shadow(
                                          color: Colors.white38,
                                          blurRadius: 8,
                                        ),
                                      ]
                                      : const [
                                        Shadow(
                                          color: Colors.white38,
                                          blurRadius: 8,
                                        ),
                                      ],
                            ),
                          ),
                          if (isLocked) // Kilit simgesi (SİYAH)
                            Icon(
                              Icons.lock,
                              color: Colors.black.withOpacity(0.8),
                              size: 30, // Kilit boyutu küçültüldü
                            ),
                          if (isCompleted && !isLocked) // Tik işareti
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Yıldızlar
                    if (isCompleted &&
                        !isLocked) // Sadece tamamlanmış aşamalarda yıldızları göster
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (index) {
                            final starIndex = index;
                            final isStarEarned =
                                starIndex < starCounts[stageNumber - 1];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              child: Icon(
                                Icons.star,
                                color:
                                    isStarEarned
                                        ? Colors.amber
                                        : Colors.grey.shade400,
                                size: 16,
                                shadows:
                                    isStarEarned
                                        ? [
                                          Shadow(
                                            color: Colors.amber.withOpacity(
                                              0.5,
                                            ),
                                            blurRadius: 4,
                                          ),
                                        ]
                                        : null,
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ... (Diğer metodlar aynı kalır)
  void _navigateToStage(BuildContext context, int stageNumber) {
    final isEnglish =
        Provider.of<LanguageProvider>(context, listen: false).isEnglish;

    bool canAccess = true;
    int stageIndex = stageNumber - 1;

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
        print('Navigating to Asama2Soru1');
        targetWidget = const Asama2Soru1();
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
                // Lock Icon
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

// 🌠 Eğri yol boyunca küçük yıldız emojileri çizen painter
class StarPathPainter extends CustomPainter {
  final List<bool> completedStages;
  final double customHeight;
  final List<Offset> planetPositions;

  StarPathPainter({
    required this.completedStages,
    required this.customHeight,
    required this.planetPositions,
  });

  // Gezegenler arasındaki kavisli yolu oluşturan yardımcı fonksiyon
  Path _createRoadmapPath(Size size) {
    final path = Path();
    if (planetPositions.length < 2) return path;

    // Path'in başlangıcı en alttaki gezegenin (1. aşama) merkezinden başlar.
    path.moveTo(planetPositions[0].dx, planetPositions[0].dy);

    for (int i = 0; i < planetPositions.length - 1; i++) {
      final start = planetPositions[i];
      final end = planetPositions[i + 1];

      Offset control1;
      Offset control2;

      // Kontrol noktalarını daha hassas ayarlayarak görseldeki kıvrımlara benzer hale getirildi
      final dy = (end.dy - start.dy).abs();

      if (i == 0) {
        // 1-2. Gezegen Arası (Aşağıdan yukarı, sağa kıvrım)
        control1 = Offset(start.dx + size.width * 0.25, start.dy - dy * 0.1);
        control2 = Offset(end.dx - size.width * 0.15, end.dy + dy * 0.15);
      } else if (i == 1) {
        // 2-3. Gezegen Arası (Sağdan sola, sola kıvrım)
        control1 = Offset(start.dx - size.width * 0.25, start.dy - dy * 0.1);
        control2 = Offset(end.dx + size.width * 0.15, end.dy + dy * 0.15);
      } else if (i == 2) {
        // 3-4. Gezegen Arası (Soldan sağa, sağa kıvrım)
        control1 = Offset(start.dx + size.width * 0.25, start.dy - dy * 0.1);
        control2 = Offset(end.dx - size.width * 0.15, end.dy + dy * 0.15);
      } else {
        // 4-5. Gezegen Arası (Sağdan sola, sola kıvrım)
        control1 = Offset(start.dx - size.width * 0.25, start.dy - dy * 0.1);
        control2 = Offset(end.dx + size.width * 0.15, end.dy + dy * 0.15);
      }
      path.cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        end.dx,
        end.dy,
      );
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createRoadmapPath(size);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    // Önce yolu çiz (gezegenler arasındaki çizgi)
    for (int i = 0; i < metrics.length; i++) {
      final metric = metrics[i];
      final segmentIsCompleted = completedStages[i];
      final pathColor =
          segmentIsCompleted ? _unlockedStarColor : _lockedStarColor;

      // Yol çizgisi
      final pathPaint =
          Paint()
            ..color = pathColor.withOpacity(0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round;

      // Yolun parlaklık efekti
      final glowPaint =
          Paint()
            ..color = pathColor.withOpacity(0.2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round;

      // Önce parlama efekti, sonra ana çizgi
      canvas.drawPath(metric.extractPath(0, metric.length), glowPaint);
      canvas.drawPath(metric.extractPath(0, metric.length), pathPaint);
    }

    // Sonra gezegenleri yolun üzerine çiz
    for (int i = 0; i < planetPositions.length; i++) {
      final planetPos = planetPositions[i];
      final stageNumber = i + 1;
      final isCompleted = completedStages[i];
      final isLocked = stageNumber > 1 && !completedStages[stageNumber - 2];

      // Gezegen rengi: tamamlanmışsa yeşil, kilitliyse gri, erişilebilirse altın
      Color planetColor;
      if (isCompleted) {
        planetColor = Colors.greenAccent;
      } else if (isLocked) {
        planetColor = Colors.grey;
      } else {
        planetColor = _unlockedStarColor;
      }

      // Gezegeni yolun üzerine çiz
      final planetPaint =
          Paint()
            ..color = planetColor
            ..style = PaintingStyle.fill
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(planetPos, 12, planetPaint);

      // Gezegenin etrafına parlama efekti
      final glowPaint =
          Paint()
            ..color = planetColor.withOpacity(0.3)
            ..style = PaintingStyle.fill
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(planetPos, 20, glowPaint);
    }

    // Sonra gezegenler arasındaki küçük yıldızları çiz
    for (int i = 0; i < metrics.length; i++) {
      final metric = metrics[i];
      const int starsPerSegment = 8; // Her segment arasına 8 yıldız

      // i. yolun tamamlanması için i. aşamanın (0-tabanlı) tamamlanması gerekir
      final segmentIsCompleted = completedStages[i];
      final starColor =
          segmentIsCompleted ? _unlockedStarColor : _lockedStarColor;

      // Yıldızları gezegenler arasında eşit aralıklarla yerleştirmek için t değerini ayarla
      // Gezegenin kapladığı alanı dikkate alarak yıldızları yerleştir
      for (int j = 1; j <= starsPerSegment; j++) {
        final t = j / (starsPerSegment + 1); // 1/(N+1), 2/(N+1), ..., N/(N+1)
        final pos = metric.getTangentForOffset(metric.length * t)!.position;

        final textPainter = TextPainter(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );

        textPainter.text = TextSpan(
          text: "⭐",
          style: TextStyle(
            fontSize: 14,
            color: starColor,
            shadows: [Shadow(color: starColor.withOpacity(0.6), blurRadius: 4)],
          ),
        );
        textPainter.layout();
        canvas.save();
        // Yıldızları yola göre hafifçe döndür
        final angle = metric.getTangentForOffset(metric.length * t)!.angle;
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(angle + pi / 2); // Yıldızı yolun açısına göre döndür
        textPainter.paint(canvas, Offset(-7, -7));
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant StarPathPainter oldDelegate) =>
      oldDelegate.completedStages != completedStages ||
      oldDelegate.customHeight != customHeight ||
      oldDelegate.planetPositions != planetPositions;
}

// ✨ Kayan Yıldız Widget'ı (İz efekti eklendi)
class ShootingStar extends StatefulWidget {
  final Color color;
  final double size; // Başlangıç yıldızının boyutu
  final double tailLength; // Kuyruğun piksel cinsinden uzunluğu (genel yön)
  final double directionAngle; // Kaydığı açı (radyan)
  final Duration trailDuration; // İzlerin ekranda kalma süresi
  final int trailSegmentCount; // İzdeki nokta sayısı

  const ShootingStar({
    super.key,
    required this.color,
    required this.size,
    required this.tailLength,
    required this.directionAngle,
    this.trailDuration = const Duration(milliseconds: 500),
    this.trailSegmentCount = 10,
  });

  @override
  State<ShootingStar> createState() => _ShootingStarState();
}

class _ShootingStarState extends State<ShootingStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _trailFadeController;
  final List<_TrailDot> _trailDots = [];
  Offset? _lastPosition;

  @override
  void initState() {
    super.initState();
    _trailFadeController = AnimationController(
      duration: widget.trailDuration,
      vsync: this,
    )..addListener(() {
      setState(() {
        // Her animasyon karesinde iz noktalarını güncelle
        _updateTrailDots();
      });
    });

    // Trail fade animasyonunu sürekli çalıştırma ihtiyacımız yok,
    // sadece mevcut iz noktalarının opasitesini yönetmek için kullanacağız.
    // _trailFadeController.forward(); // Animasyonu başlangıçta bir kez çalıştır.
  }

  @override
  void didUpdateWidget(covariant ShootingStar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kayan yıldızın konumu değiştiğinde yeni bir iz noktası ekle
    final newPosition = (context.findRenderObject() as RenderBox?)
        ?.localToGlobal(Offset.zero);
    if (newPosition != null &&
        _lastPosition != null &&
        newPosition != _lastPosition) {
      _addTrailDot(newPosition);
    }
    _lastPosition = newPosition;
  }

  void _addTrailDot(Offset position) {
    _trailDots.add(
      _TrailDot(
        position: position,
        timestamp: DateTime.now(),
        initialOpacity: 1.0,
        size: widget.size * 0.7, // İz noktaları yıldızdan küçük olsun
        color: widget.color,
      ),
    );
    // Çok fazla iz birikmesini önle
    if (_trailDots.length > widget.trailSegmentCount) {
      _trailDots.removeAt(0);
    }
  }

  void _updateTrailDots() {
    final now = DateTime.now();
    _trailDots.removeWhere((dot) {
      final elapsed = now.difference(dot.timestamp);
      return elapsed > widget.trailDuration;
    });

    for (var dot in _trailDots) {
      final elapsed = now.difference(dot.timestamp);
      final progress =
          elapsed.inMilliseconds / widget.trailDuration.inMilliseconds;
      dot.opacity = (1.0 - progress).clamp(0.0, 1.0);
    }
  }

  @override
  void dispose() {
    _trailFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kayan yıldızın kendi pozisyonunu al
    final starGlobalPosition = (context.findRenderObject() as RenderBox?)
        ?.localToGlobal(Offset.zero);
    if (starGlobalPosition != null) {
      // Sadece ana yıldız hareket ettiğinde yeni iz noktaları ekle
      // Bu, AnimatedBuilder'ın her rebuild'inde otomatik olarak gerçekleşir
      if (_lastPosition == null || starGlobalPosition != _lastPosition) {
        _addTrailDot(starGlobalPosition);
      }
      _lastPosition = starGlobalPosition;
    }

    return CustomPaint(
      // Geniş bir alanı kaplaması için yeterli boyut ver
      size: Size(
        widget.tailLength * 2 + widget.size,
        widget.tailLength * 2 + widget.size,
      ),
      painter: _ShootingStarPainter(
        color: widget.color,
        size: widget.size,
        tailLength: widget.tailLength,
        directionAngle: widget.directionAngle,
        trailDots: _trailDots, // İz noktalarını painter'a gönder
        trailOffset:
            starGlobalPosition != null
                ? -starGlobalPosition
                : Offset.zero, // Null check eklendi
      ),
    );
  }
}

class _TrailDot {
  Offset position;
  DateTime timestamp;
  double initialOpacity;
  double opacity;
  double size;
  Color color;

  _TrailDot({
    required this.position,
    required this.timestamp,
    required this.initialOpacity,
    required this.size,
    required this.color,
    double opacity = 1.0,
  }) : opacity = opacity;
}

class _ShootingStarPainter extends CustomPainter {
  final Color color;
  final double size;
  final double tailLength;
  final double directionAngle;
  final List<_TrailDot> trailDots; // İz noktaları listesi
  final Offset
  trailOffset; // İz noktalarının global konumdan, painter'ın lokal konumuna çevrimi için offset

  _ShootingStarPainter({
    required this.color,
    required this.size,
    required this.tailLength,
    required this.directionAngle,
    required this.trailDots,
    required this.trailOffset,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    // Ana yıldız
    final starPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    final starCenter = Offset(
      canvasSize.width / 2,
      canvasSize.height / 2,
    ); // Yıldızı canvas ortasına çiz
    canvas.drawCircle(starCenter, size / 2, starPaint);

    // Kayan yıldızın kuyruğu (gradient şeklinde) - bu kalıcı bir kuyruktur, iz noktalarından ayrı
    final tailPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment(cos(directionAngle), sin(directionAngle)),
            end: Alignment(-cos(directionAngle), -sin(directionAngle)),
            colors: [
              color.withOpacity(0.0),
              color.withOpacity(0.8),
              color.withOpacity(0.0), // Kuyruğun ortası daha parlak, sonu soluk
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, tailLength, size));

    final Path tailPath = Path();
    tailPath.moveTo(starCenter.dx, starCenter.dy);

    final tailEndPointX = starCenter.dx + tailLength * cos(directionAngle + pi);
    final tailEndPointY = starCenter.dy + tailLength * sin(directionAngle + pi);

    final tailWidth = size / 2;

    final edge1X = tailEndPointX + tailWidth * cos(directionAngle + pi / 2);
    final edge1Y = tailEndPointY + tailWidth * sin(directionAngle + pi / 2);

    final edge2X = tailEndPointX + tailWidth * cos(directionAngle - pi / 2);
    final edge2Y = tailEndPointY + tailWidth * sin(directionAngle - pi / 2);

    tailPath.lineTo(edge1X, edge1Y);
    tailPath.lineTo(starCenter.dx, starCenter.dy);
    tailPath.lineTo(edge2X, edge2Y);
    tailPath.close();

    canvas.save();
    canvas.drawPath(tailPath, tailPaint);
    canvas.restore();

    // İz noktalarını çiz
    for (final dot in trailDots) {
      final dotPaint =
          Paint()
            ..color = dot.color.withOpacity(dot.opacity)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              dot.size * dot.opacity,
            ); // Parlama efekti

      // İz noktalarının global konumunu, painter'ın lokal koordinatlarına çevir
      // Kayan yıldız widget'ının merkezi = starCenter
      // Kayan yıldız widget'ının global pozisyonu = -trailOffset
      final localDotPosition = dot.position + trailOffset + starCenter;

      canvas.drawCircle(localDotPosition, dot.size / 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShootingStarPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.size != size ||
        oldDelegate.tailLength != tailLength ||
        oldDelegate.directionAngle != directionAngle ||
        oldDelegate.trailDots != trailDots || // List değiştiğinde repaint et
        oldDelegate.trailOffset != trailOffset;
  }
}
