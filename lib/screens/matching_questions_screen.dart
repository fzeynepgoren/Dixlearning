import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../asama1/soru1.dart';
import '../asama2/soru1.dart';
import '../asama3/soru1.dart';
import '../asama4/soru1.dart';
import 'home_screen.dart';

class MatchingQuestionsScreen extends StatefulWidget {
  const MatchingQuestionsScreen({super.key});

  @override
  State<MatchingQuestionsScreen> createState() =>
      _MatchingQuestionsScreenState();
}

class _MatchingQuestionsScreenState extends State<MatchingQuestionsScreen>
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
      // Kaç aşama tamamlanmış?
      int completed = 0;
      if (prefs.getBool('asama1_completed') ?? false) completed = 1;
      if (prefs.getBool('asama2_completed') ?? false) completed = 2;
      if (prefs.getBool('asama3_completed') ?? false) completed = 3;
      if (prefs.getBool('asama4_completed') ?? false) completed = 4;
      completedLevel = completed;
    });

    // Tamamlanan leveller için yıldız animasyonunu başlat
    if (completedLevel > 0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _starController1.forward(from: 0);
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _starController2.forward(from: 0);
      });
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) _starController3.forward(from: 0);
      });
    }
  }

  bool _isLevelUnlocked(int level) {
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
                  const Color(0xFFFFE5B4), // Açık turuncu-sarı
                  const Color(0xFFFFD1A1), // Orta turuncu
                  const Color(0xFFFFC897), // Koyu turuncu
                ],
              ),
            ),
          ),

          // Arka plan resmi - Uzay Teması
          Positioned.fill(
            child: Image.asset(
              'assets/screensphoto/uzayback.png',
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
                    // Level 1: Meyve Eşleme (En alt - ortada)
                    _buildLevelButton(
                      context,
                      level: 1,
                      leftFactor: 0.74,
                      topFactor: 0.82,
                      emoji: '🍎',
                      title: isEnglish ? 'Fruits' : 'Meyveler',
                      color: const Color(0xFFE5A2BE), // Canlı kırmızı
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MeyveEsle(),
                          ),
                        );
                        _loadProgress();
                      },
                      isUnlocked: _isLevelUnlocked(1),
                      isCompleted: completedLevel >= 1,
                    ),

                    // Level 2: Harf Oyunları (Orta-alt - solda)
                    _buildLevelButton(
                      context,
                      level: 2,
                      leftFactor: 0.32,
                      topFactor: 0.67,
                      emoji: '🔤',
                      title: isEnglish ? 'Letters' : 'Harfler',
                      color: const Color(0xFF5D4695), // Canlı yeşil
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Soru1(),
                          ),
                        );
                        _loadProgress();
                      },
                      isUnlocked: _isLevelUnlocked(2),
                      isCompleted: completedLevel >= 2,
                    ),

                    // Level 3: Yapı ve Nesne (Orta - sağda)
                    _buildLevelButton(
                      context,
                      level: 3,
                      leftFactor: 0.7,
                      topFactor: 0.49,
                      emoji: '🏛️',
                      title: isEnglish ? 'Objects' : 'Nesneler',
                      color: const Color(0xFFC99470), // Canlı mor
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ActivityMatching(),
                          ),
                        );
                        _loadProgress();
                      },
                      isUnlocked: _isLevelUnlocked(3),
                      isCompleted: completedLevel >= 3,
                    ),

                    // Level 4: Mevsim ve Hava (Üst - ortada)
                    _buildLevelButton(
                      context,
                      level: 4,
                      leftFactor: 0.36,
                      topFactor: 0.36,
                      emoji: '🌦️',
                      title: isEnglish ? 'Weather' : 'Hava Durumu',
                      color: const Color(0xFF469DBC), // Canlı turuncu
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DuyguYuzEsle(),
                          ),
                        );
                        _loadProgress();
                      },
                      isUnlocked: _isLevelUnlocked(4),
                      isCompleted: completedLevel >= 4,
                    ),

                    // Kayan yıldızlar (her zaman göster)
                    ...List.generate(15, (index) {
                      return _buildFallingStars(context, index);
                    }),
                  ],
                ),
              ),

              // Sevimli geri butonu - Uzay Teması (Yıldız/Roket)
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
                          colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.yellow.withOpacity(0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF64BDD2).withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                          // Yıldız parlama efekti
                          BoxShadow(
                            color: Colors.yellow.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Yıldız parlaması
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.star,
                              color: Colors.yellow.withOpacity(0.6),
                              size: 12,
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

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -100, end: MediaQuery.of(context).size.height + 100),
      duration: Duration(seconds: duration.toInt()),
      onEnd: () {
        if (mounted) setState(() {});
      },
      builder: (context, value, child) {
        return Positioned(
          left: leftPosition * MediaQuery.of(context).size.width / 100,
          top: value - (delay * 100),
          child: Opacity(
            opacity:
                (value > -50 && value < MediaQuery.of(context).size.height + 50)
                    ? 1.0
                    : 0.0,
            child: Transform.rotate(
              angle: (value / 100) * 3.14,
              child: Icon(
                Icons.star,
                size: size,
                color:
                    [
                      const Color(0xFFFFD700),
                      const Color(0xFFFFA500),
                      const Color(0xFFFFE55C),
                      const Color(0xFFFFFF00),
                    ][index % 4],
                shadows: [
                  Shadow(color: Colors.amber.withOpacity(0.8), blurRadius: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
