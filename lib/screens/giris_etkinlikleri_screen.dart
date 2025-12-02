import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'giris_etkinlikleri_flow_screen.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class GirisEtkinlikleriScreen extends StatefulWidget {
  const GirisEtkinlikleriScreen({super.key});

  @override
  State<GirisEtkinlikleriScreen> createState() =>
      _GirisEtkinlikleriScreenState();
}

class _GirisEtkinlikleriScreenState extends State<GirisEtkinlikleriScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _floatController;
  late AnimationController _rotateController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _startRandomActivity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GirisEtkinlikleriFlowScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Arka plan - Orman/Mantar teması
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF87CEEB),
                  Color(0xFF98D8AA),
                  Color(0xFF4A7C59),
                  Color(0xFF2D5A3D),
                ],
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // Dekoratif bulutlar
          Positioned(
            top: screenHeight * 0.03,
            left: 10,
            child: _buildCloud(70),
          ),
          Positioned(
            top: screenHeight * 0.06,
            right: 20,
            child: _buildCloud(90),
          ),
          Positioned(
            top: screenHeight * 0.12,
            left: 80,
            child: _buildCloud(55),
          ),
          Positioned(
            top: screenHeight * 0.08,
            right: 130,
            child: _buildCloud(45),
          ),

          // Güneş
          Positioned(
            top: screenHeight * 0.05,
            right: screenWidth * 0.1,
            child: AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateController.value * 2 * math.pi,
                  child: child,
                );
              },
              child: const Text('☀️', style: TextStyle(fontSize: 50)),
            ),
          ),

          // Çimen dekorasyonu (alt)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xFF228B22)],
                ),
              ),
            ),
          ),

          // Sol alt köşe - Mantarlar grubu
          Positioned(
            bottom: 10,
            left: 10,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value * 0.5),
                  child: child,
                );
              },
              child: const Text('🍄', style: TextStyle(fontSize: 55)),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 55,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_floatAnimation.value * 0.7),
                  child: child,
                );
              },
              child: const Text('🍄', style: TextStyle(fontSize: 35)),
            ),
          ),
          Positioned(
            bottom: 5,
            left: 80,
            child: const Text('🍄', style: TextStyle(fontSize: 28)),
          ),

          // Sağ alt köşe - Mantarlar grubu
          Positioned(
            bottom: 15,
            right: 15,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_floatAnimation.value * 0.6),
                  child: child,
                );
              },
              child: const Text('🍄', style: TextStyle(fontSize: 60)),
            ),
          ),
          Positioned(
            bottom: 45,
            right: 70,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value * 0.5),
                  child: child,
                );
              },
              child: const Text('🍄', style: TextStyle(fontSize: 40)),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 100,
            child: const Text('🍄', style: TextStyle(fontSize: 30)),
          ),

          // Çiçekler - Sol
          Positioned(
            bottom: 60,
            left: 20,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_floatAnimation.value * 0.3, 0),
                  child: child,
                );
              },
              child: const Text('🌸', style: TextStyle(fontSize: 35)),
            ),
          ),
          Positioned(
            bottom: 85,
            left: 70,
            child: const Text('🌺', style: TextStyle(fontSize: 30)),
          ),
          Positioned(
            bottom: 30,
            left: 130,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-_floatAnimation.value * 0.4, 0),
                  child: child,
                );
              },
              child: const Text('🌼', style: TextStyle(fontSize: 32)),
            ),
          ),

          // Çiçekler - Sağ
          Positioned(
            bottom: 70,
            right: 25,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-_floatAnimation.value * 0.3, 0),
                  child: child,
                );
              },
              child: const Text('🌷', style: TextStyle(fontSize: 38)),
            ),
          ),
          Positioned(
            bottom: 90,
            right: 80,
            child: const Text('🌻', style: TextStyle(fontSize: 32)),
          ),
          Positioned(
            bottom: 35,
            right: 140,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_floatAnimation.value * 0.4, 0),
                  child: child,
                );
              },
              child: const Text('🌸', style: TextStyle(fontSize: 28)),
            ),
          ),

          // Kelebekler
          Positioned(
            top: screenHeight * 0.25,
            left: 30,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _floatAnimation.value * 2,
                    _floatAnimation.value,
                  ),
                  child: child,
                );
              },
              child: const Text('🦋', style: TextStyle(fontSize: 30)),
            ),
          ),
          Positioned(
            top: screenHeight * 0.35,
            right: 40,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    -_floatAnimation.value * 1.5,
                    -_floatAnimation.value,
                  ),
                  child: child,
                );
              },
              child: const Text('🦋', style: TextStyle(fontSize: 25)),
            ),
          ),
          Positioned(
            top: screenHeight * 0.55,
            left: 50,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _floatAnimation.value,
                    -_floatAnimation.value * 1.2,
                  ),
                  child: child,
                );
              },
              child: const Text('🦋', style: TextStyle(fontSize: 22)),
            ),
          ),

          // Arılar
          Positioned(
            top: screenHeight * 0.3,
            right: 60,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _floatAnimation.value * 1.5,
                    _floatAnimation.value * 0.8,
                  ),
                  child: child,
                );
              },
              child: const Text('🐝', style: TextStyle(fontSize: 24)),
            ),
          ),
          Positioned(
            top: screenHeight * 0.45,
            left: 30,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    -_floatAnimation.value * 1.2,
                    _floatAnimation.value * 0.5,
                  ),
                  child: child,
                );
              },
              child: const Text('🐝', style: TextStyle(fontSize: 20)),
            ),
          ),

          // Uğur böcekleri
          Positioned(
            bottom: 110,
            left: screenWidth * 0.4,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_floatAnimation.value * 0.5, 0),
                  child: child,
                );
              },
              child: const Text('🐞', style: TextStyle(fontSize: 22)),
            ),
          ),
          Positioned(
            bottom: 95,
            right: screenWidth * 0.35,
            child: const Text('🐞', style: TextStyle(fontSize: 18)),
          ),

          // Ağaçlar/bitkiler kenarlarında
          Positioned(
            bottom: 80,
            left: -10,
            child: const Text('🌿', style: TextStyle(fontSize: 50)),
          ),
          Positioned(
            bottom: 100,
            right: -10,
            child: const Text('🌿', style: TextStyle(fontSize: 45)),
          ),
          Positioned(
            bottom: 60,
            left: screenWidth * 0.15,
            child: const Text('🌱', style: TextStyle(fontSize: 25)),
          ),
          Positioned(
            bottom: 55,
            right: screenWidth * 0.18,
            child: const Text('🌱', style: TextStyle(fontSize: 22)),
          ),

          // Ana içerik
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mantar ev ikonu
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -_bounceAnimation.value),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE74C3C).withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: 15,
                          ),
                        ],
                      ),
                      child: const Text('🏠', style: TextStyle(fontSize: 80)),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Başlık
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Text(
                      isEnglish ? 'Entry Activities' : 'Giriş Etkinlikleri',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Başla butonu
                  GestureDetector(
                    onTap: () => _startRandomActivity(context),
                    child: AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1 + (_bounceAnimation.value * 0.012),
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 45,
                          vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF4CAF50),
                              Color(0xFF45A049),
                              Color(0xFF388E3C),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withOpacity(0.6),
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(-5, -5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 36,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              isEnglish ? "Let's Start!" : 'Haydi Başla!',
                              style: const TextStyle(
                                fontSize: 26,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text('🎉', style: TextStyle(fontSize: 28)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Geri butonu
          Positioned(
            top: 10,
            left: 10,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF2E7D32),
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloud(double size) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(size),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.6),
            blurRadius: 25,
            spreadRadius: 8,
          ),
        ],
      ),
    );
  }
}
