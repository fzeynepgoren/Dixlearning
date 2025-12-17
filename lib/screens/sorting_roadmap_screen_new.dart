import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../SIRALAMA_SORULARI/Asama1/soru1.dart';
import '../SIRALAMA_SORULARI/Asama2/soru1.dart';
import '../SIRALAMA_SORULARI/Asama3/soru1.dart';
import '../SIRALAMA_SORULARI/Asama4/soru1.dart';
import '../SIRALAMA_SORULARI/Asama5/soru1.dart';
import 'home_screen.dart';

class SortingRoadmapScreenNew extends StatefulWidget {
  const SortingRoadmapScreenNew({super.key});

  @override
  State<SortingRoadmapScreenNew> createState() =>
      _SortingRoadmapScreenNewState();
}

class _SortingRoadmapScreenNewState extends State<SortingRoadmapScreenNew>
    with TickerProviderStateMixin {
  int completedLevel = 0;
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
      // Kaç stage tamamlanmış?
      int completed = 0;
      if (prefs.getBool('sorting_stage_1_completed') ?? false) completed = 1;
      if (prefs.getBool('sorting_stage_2_completed') ?? false) completed = 2;
      if (prefs.getBool('sorting_stage_3_completed') ?? false) completed = 3;
      if (prefs.getBool('sorting_stage_4_completed') ?? false) completed = 4;
      if (prefs.getBool('sorting_stage_5_completed') ?? false) completed = 5;
      completedLevel = completed;
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
    // Level 5 (İleri Seviye) her zaman açık
    if (level == 5) {
      return true;
    }
    return level <= completedLevel + 1;
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;

    return Scaffold(
      body: Stack(
        children: [
          // Arka plan - Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFFFB6C1), // Açık pembe
                  const Color(0xFFFFD1DC), // Orta pembe
                  const Color(0xFFFFF0F5), // Açık lavanta
                ],
              ),
            ),
          ),

          // Arka plan resmi - Şeker Tema
          Positioned.fill(
            child: Image.asset(
              'assets/screensphoto/sekerback.png',
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
                    // Level 1: 2 Resimli Sıralama (En alt - ortada)
                    _buildLevelButton(
                      context,
                      level: 1,
                      leftFactor: 0.50,
                      topFactor: 0.78,
                      emoji: '🎯',
                      title: isEnglish ? '2 Pictures' : '2 Resim',
                      color: const Color(0xFFE74C3C), // Kırmızı
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Asama1Soru1(),
                          ),
                        );
                        _loadProgress();
                      },
                      isUnlocked: _isLevelUnlocked(1),
                      isCompleted: completedLevel >= 1,
                    ),

                    // Level 2: 3 Resimli Sıralama (Sağ kıvrım - 1'in sağ üstü)
                    _buildLevelButton(
                      context,
                      level: 2,
                      leftFactor: 0.75,
                      topFactor: 0.60,
                      emoji: '🎨',
                      title: isEnglish ? '3 Pictures' : '3 Resim',
                      color: const Color(0xFF27AE60), // Yeşil
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Asama2Soru1(),
                          ),
                        );
                        _loadProgress();
                      },
                      isUnlocked: _isLevelUnlocked(2),
                      isCompleted: completedLevel >= 2,
                    ),

                    // Level 3: 4 Resimli Sıralama (Sol kıvrım)
                    _buildLevelButton(
                      context,
                      level: 3,
                      leftFactor: 0.35,
                      topFactor: 0.46,
                      emoji: '🌟',
                      title: isEnglish ? '4 Pictures' : '4 Resim',
                      color: const Color(0xFF3498DB), // Mavi
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Asama3Soru1(),
                          ),
                        );
                        _loadProgress();
                      },
                      isUnlocked: _isLevelUnlocked(3),
                      isCompleted: completedLevel >= 3,
                    ),

                    // Level 4: 3 Fotoğraf (Günlük Rutinler) (Sağ üst kıvrım)
                    _buildLevelButton(
                      context,
                      level: 4,
                      leftFactor: 0.75,
                      topFactor: 0.35,
                      emoji: '🧼',
                      title: isEnglish ? 'Daily Routines' : 'Günlük Rutinler',
                      color: const Color(0xFF8E44AD), // Mor
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Asama4Soru1(),
                          ),
                        );
                        _loadProgress();
                      },
                      isUnlocked: _isLevelUnlocked(4),
                      isCompleted: completedLevel >= 4,
                    ),

                    // Level 5: İleri Seviye (Şato önü)
                    _buildLevelButton(
                      context,
                      level: 5,
                      leftFactor: 0.50,
                      topFactor: 0.24,
                      emoji: '🏆',
                      title: isEnglish ? 'Advanced' : 'İleri Seviye',
                      color: const Color(0xFFF39C12), // Turuncu
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Asama5Soru1(),
                          ),
                        );
                        _loadProgress();
                      },
                      isUnlocked: _isLevelUnlocked(5),
                      isCompleted: completedLevel >= 5,
                    ),

                    // Tamamlanan her aşama için şekerler dökülür
                    if (completedLevel >= 1)
                      ...List.generate(30, (index) {
                        return _buildFallingStars(context, index);
                      }),
                  ],
                ),
              ),

              // Sevimli geri butonu - Şeker Teması (Kalp Şekli)
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
                          colors: [Color(0xFFF06491), Color(0xFFE55D87)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF06491).withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Parlama efekti
                          Positioned(
                            top: 10,
                            left: 12,
                            child: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                            ),
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
            // Yıldızlar (level tamamlandıysa) - Animasyonlu
            if (isCompleted)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  // Alt gölge
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

                  // Ana buton
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
                        // Parlama efektleri
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

    // Şeker emojileri listesi
    final List<String> candies = [
      '🍬',
      '🍭',
      '🍫',
      '🍰',
      '🧁',
      '🍪',
      '🍩',
      '🍯',
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -100, end: MediaQuery.of(context).size.height + 100),
      duration: Duration(seconds: duration.toInt()),
      onEnd: () {
        setState(() {});
      },
      builder: (context, value, child) {
        return Positioned(
          left: leftPosition * MediaQuery.of(context).size.width / 100,
          top: value - (delay * 100),
          child: Transform.rotate(
            angle: (value / 100) * 0.5, // Şekerler dönerken düşer
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
      child: Text(
        candies[random % candies.length],
        style: TextStyle(fontSize: size),
      ),
    );
  }
}
