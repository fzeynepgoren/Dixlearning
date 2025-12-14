import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../karsilastirma_az_cok/az_cok_asama1/soru1.dart';
import '../karsilastirma_kalin_ince/kalin_ince_asama1/soru1.dart';
import '../karsilastirma_uzun_kisa/soru1.dart';
import '../karsilastirma_buyuk_kucuk/soru1.dart';
import 'home_screen.dart';

class KarsilastirmaSorulariScreen extends StatefulWidget {
  const KarsilastirmaSorulariScreen({super.key});

  @override
  State<KarsilastirmaSorulariScreen> createState() =>
      _KarsilastirmaSorulariScreenState();
}

class _KarsilastirmaSorulariScreenState
    extends State<KarsilastirmaSorulariScreen>
    with TickerProviderStateMixin {
  int completedLevel = 0;
  Map<int, int> levelStars = {}; // Her level için yıldız sayısı
  late AnimationController _starController1;
  late AnimationController _starController2;
  late AnimationController _starController3;

  @override
  void initState() {
    super.initState();
    _starController1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _starController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _starController3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadProgress();
  }

  @override
  void dispose() {
    _starController1.dispose();
    _starController2.dispose();
    _starController3.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      completedLevel = prefs.getInt('karsilastirma_completed_level') ?? 0;
      // Her level için yıldız sayısını yükle
      for (int i = 1; i <= 4; i++) {
        levelStars[i] = prefs.getInt('level_${i}_stars') ?? 0;
      }
    });

    // Tamamlanan leveller için yıldız animasyonunu başlat
    if (completedLevel > 0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _starController1.forward(from: 0);
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        _starController2.forward(from: 0);
      });
      Future.delayed(const Duration(milliseconds: 700), () {
        _starController3.forward(from: 0);
      });
    }
  }

  bool _isLevelUnlocked(int level) {
    return level <= completedLevel + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan - Tam ekran kaplayan yol tasarımı
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF87CEEB), // Açık mavi gökyüzü
                  const Color(0xFF90D5FF), // Orta mavi
                  const Color(0xFFA8E6CF), // Yeşilimsi
                ],
              ),
            ),
          ),

          // Arka plan resmi - Tam ekran (Çöl/Renkli Tema)
          Positioned.fill(
            child: Image.asset(
              'assets/screensphoto/colback.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),

          // İçerik
          Stack(
            children: [
              // Seviye düğmeleri
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    // Level 1: Az-Çok (Alt orta - başlangıç)
                    _buildLevelButton(
                      context,
                      level: 1,
                      leftFactor: 0.55,
                      topFactor: 0.82,
                      emoji: '🎯',
                      title: 'Az-Çok',
                      color: const Color(0xFFE74C3C), // Canlı kırmızı
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AzCokSoru1(),
                          ),
                        );
                        _loadProgress();
                      },
                      isUnlocked: _isLevelUnlocked(1),
                      isCompleted: completedLevel >= 1,
                      starCount: levelStars[1] ?? 0,
                    ),

                    // Level 2: Büyük-Küçük (Sağ kıvrım)
                    _buildLevelButton(
                      context,
                      level: 2,
                      leftFactor: 0.75,
                      topFactor: 0.60,
                      emoji: '🎨',
                      title: 'Büyük-Küçük',
                      color: const Color(0xFF27AE60), // Canlı yeşil
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BuyukKucukSoru1(),
                          ),
                        );
                        _loadProgress();
                      },
                      isUnlocked: _isLevelUnlocked(2),
                      isCompleted: completedLevel >= 2,
                      starCount: levelStars[2] ?? 0,
                    ),

                    // Level 3: Kalın-İnce (Sol kıvrım)
                    _buildLevelButton(
                      context,
                      level: 3,
                      leftFactor: 0.35,
                      topFactor: 0.42,
                      emoji: '🎪',
                      title: 'Kalın-İnce',
                      color: const Color(0xFF8E44AD), // Canlı mor
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KalinInceSoru1(),
                          ),
                        );
                        _loadProgress();
                      },
                      isUnlocked: _isLevelUnlocked(3),
                      isCompleted: completedLevel >= 3,
                      starCount: levelStars[3] ?? 0,
                    ),

                    // Level 4: Uzun-Kısa (Üst kıvrım)
                    _buildLevelButton(
                      context,
                      level: 4,
                      leftFactor: 0.45,
                      topFactor: 0.22,
                      emoji: '🎁',
                      title: 'Uzun-Kısa',
                      color: const Color(0xFFF39C12), // Canlı turuncu
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UzunKisaAgacSorusu(),
                          ),
                        );
                        _loadProgress();
                      },
                      isUnlocked: _isLevelUnlocked(4),
                      isCompleted: completedLevel >= 4,
                      starCount: levelStars[4] ?? 0,
                    ),

                    // Tamamlanan her aşama için güneşler dökülür
                    if (completedLevel >= 1)
                      ...List.generate(30, (index) {
                        return _buildFallingStars(context, index);
                      }),
                  ],
                ),
              ),

              // Sevimli geri butonu - Çöl Teması (Güneş Şekli)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFB347), Color(0xFFFF8C3C)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Güneş ışınları efekti
                          Positioned.fill(
                            child: CustomPaint(painter: SunRaysPainter()),
                          ),
                          const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelButton(
    BuildContext context, {
    required int level,
    required double leftFactor,
    required double topFactor,
    required String emoji,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isUnlocked,
    required bool isCompleted,
    required int starCount,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      left: screenWidth * leftFactor - 58,
      top: screenHeight * topFactor,
      child: GestureDetector(
        onTap: isUnlocked ? onTap : null,
        child: Column(
          children: [
            // Yıldızlar (level tamamlandıysa) - Animasyonlu, yanlış sayısına göre
            if (isCompleted && starCount > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. yıldız (her zaman göster eğer starCount >= 1)
                  if (starCount >= 1)
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _starController1,
                        curve: Curves.elasticOut,
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        child: const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 22,
                          shadows: [
                            Shadow(color: Colors.orange, blurRadius: 6),
                            Shadow(color: Colors.amber, blurRadius: 12),
                          ],
                        ),
                      ),
                    ),
                  // 2. yıldız (eğer starCount >= 2)
                  if (starCount >= 2)
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _starController2,
                        curve: Curves.elasticOut,
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        child: const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 22,
                          shadows: [
                            Shadow(color: Colors.orange, blurRadius: 6),
                            Shadow(color: Colors.amber, blurRadius: 12),
                          ],
                        ),
                      ),
                    ),
                  // 3. yıldız (eğer starCount == 3)
                  if (starCount >= 3)
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _starController3,
                        curve: Curves.elasticOut,
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        child: const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 22,
                          shadows: [
                            Shadow(color: Colors.orange, blurRadius: 6),
                            Shadow(color: Colors.amber, blurRadius: 12),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            if (isCompleted) const SizedBox(height: 8),

            // Level butonu - Canlı ve sevimli
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Renkli yumuşak gölgeler
                boxShadow: [
                  if (isUnlocked) ...[
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 3,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ] else ...[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 18,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Alt gölge - yumuşak
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 80,
                      height: 15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Ana buton - Tam boyut, çerçeve yok
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                          isUnlocked
                              ? RadialGradient(
                                center: const Alignment(-0.2, -0.3),
                                radius: 1.2,
                                colors: [
                                  Colors.white.withOpacity(0.85),
                                  color.withOpacity(0.95),
                                  color,
                                  color.withOpacity(0.9),
                                ],
                                stops: const [0.0, 0.3, 0.7, 1.0],
                              )
                              : RadialGradient(
                                center: const Alignment(-0.2, -0.3),
                                radius: 1.2,
                                colors: [
                                  const Color(0xFF9E9288),
                                  const Color(0xFF8A7A6E),
                                  const Color(0xFF6E5E52),
                                  const Color(0xFF5A4D42),
                                ],
                                stops: const [0.0, 0.3, 0.7, 1.0],
                              ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                        if (isUnlocked)
                          BoxShadow(
                            color: Colors.white.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(-2, -2),
                          ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Ana parlama efekti - yumuşak
                        Positioned(
                          top: 10,
                          left: 18,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.6),
                                  Colors.white.withOpacity(0.25),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Yan parlama
                        Positioned(
                          top: 28,
                          right: 20,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.4),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Alt ışık yansıması
                        Positioned(
                          bottom: 28,
                          left: 28,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                        ),
                        // Sayı - Tam ortada
                        Center(
                          child:
                              isUnlocked
                                  ? Text(
                                    '$level',
                                    style: TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1.0,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.6),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                        Shadow(
                                          color: color.withOpacity(0.5),
                                          blurRadius: 30,
                                          offset: const Offset(0, 0),
                                        ),
                                        Shadow(
                                          color: Colors.white.withOpacity(0.4),
                                          blurRadius: 5,
                                          offset: const Offset(-2, -2),
                                        ),
                                      ],
                                    ),
                                  )
                                  : Icon(
                                    Icons.lock_rounded,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 45,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 15,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kayan yıldızlar animasyonu
  Widget _buildFallingStars(BuildContext context, int index) {
    final random = (index * 123) % 100;
    final delay = (random % 5) * 0.5;
    final leftPosition = (random % 80 + 10).toDouble();
    final size = (random % 20 + 15).toDouble();
    final duration = (random % 3 + 3).toDouble();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -100, end: MediaQuery.of(context).size.height + 100),
      duration: Duration(seconds: duration.toInt()),
      onEnd: () {
        // Animasyon bitince yeniden başlat
        setState(() {});
      },
      builder: (context, value, child) {
        return Positioned(
          left: leftPosition * MediaQuery.of(context).size.width / 100,
          top: value - (delay * 100),
          child: Transform.rotate(
            angle: (value / 100) * 0.5, // Güneşler dönerken düşer
            child: Opacity(
              opacity:
                  (value > -50 &&
                          value < MediaQuery.of(context).size.height + 50)
                      ? 1.0
                      : 0.0,
              child: child,
            ),
          ),
        );
      },
      child: Text('☀️', style: TextStyle(fontSize: size)),
    );
  }
}

// Güneş ışınları painter (Çöl teması için)
class SunRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    // 8 ışın çiz
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * 3.14159 / 180;
      final startX = center.dx + radius * 0.7 * cos(angle);
      final startY = center.dy + radius * 0.7 * sin(angle);
      final endX = center.dx + radius * cos(angle);
      final endY = center.dy + radius * sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  double cos(double angle) =>
      angle == 0
          ? 1.0
          : angle == 90
          ? 0.0
          : angle == 180
          ? -1.0
          : angle == 270
          ? 0.0
          : (angle < 90
              ? 1 - (angle / 90)
              : angle < 180
              ? -(angle - 90) / 90
              : angle < 270
              ? -1 + (angle - 180) / 90
              : (angle - 270) / 90);

  double sin(double angle) => cos(angle - 90);
}
