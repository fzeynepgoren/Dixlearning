import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:dixlearning/karsilastirma_az_cok/az_cok_asama1/soru4.dart';

class AsamaGecisEkrani extends StatefulWidget {
  const AsamaGecisEkrani({super.key});

  @override
  State<AsamaGecisEkrani> createState() => _AsamaGecisEkraniState();
}

class _AsamaGecisEkraniState extends State<AsamaGecisEkrani>
    with TickerProviderStateMixin {
  bool showBorder = true;
  late Timer _timer;
  late AnimationController _glowController;
  late AnimationController _maskotController;
  late AnimationController _cloudController;
  late AnimationController _confettiController;
  late AnimationController _buttonScaleController;
  bool showConfetti = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        showBorder = !showBorder;
      });
    });
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _maskotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _buttonScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _glowController.dispose();
    _maskotController.dispose();
    _cloudController.dispose();
    _confettiController.dispose();
    _buttonScaleController.dispose();
    super.dispose();
  }

  void _onContinue() async {
    await _buttonScaleController.forward();
    await _buttonScaleController.reverse();
    setState(() {
      showConfetti = true;
    });
    _confettiController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      showConfetti = false;
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AzCokSoru4()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final maskotSize = screenWidth * 1.20;
    final balloonFontSize = screenWidth * 0.072;
    final buttonFontSize = screenWidth * 0.065;
    final balloonPadding = screenWidth * 0.09;
    final balonTop =
        screenHeight * 0.08 + maskotSize * 0.55 + screenHeight * 0.01;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8FC8F7),
              Color(0xFFE3F0FF),
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Hareketli bulutlar (Icons.cloud ile, login_screen.dart tarzı)
              AnimatedBuilder(
                animation: _cloudController,
                builder: (context, child) {
                  double t = _cloudController.value;
                  return Stack(
                    children: [
                      Positioned(
                        top: screenHeight * 0.06,
                        left: screenWidth * (0.05 + 0.25 * t),
                        child: Icon(Icons.cloud,
                            size: screenWidth * 0.22,
                            color: Colors.white.withOpacity(0.45)),
                      ),
                      Positioned(
                        top: screenHeight * 0.13,
                        right: screenWidth * (0.10 + 0.20 * t),
                        child: Icon(Icons.cloud,
                            size: screenWidth * 0.18,
                            color: Colors.white.withOpacity(0.38)),
                      ),
                      Positioned(
                        top: screenHeight * 0.19,
                        left: screenWidth * (0.30 - 0.18 * t),
                        child: Icon(Icons.cloud,
                            size: screenWidth * 0.13,
                            color: Colors.white.withOpacity(0.32)),
                      ),
                      Positioned(
                        top: screenHeight * 0.09,
                        right: screenWidth * (0.30 - 0.18 * t),
                        child: Icon(Icons.cloud,
                            size: screenWidth * 0.10,
                            color: Colors.white.withOpacity(0.30)),
                      ),
                    ],
                  );
                },
              ),
              // Maskot balonun arkasından yükseliyor (bacaklar görünmüyor)
              AnimatedBuilder(
                animation: _maskotController,
                builder: (context, child) {
                  double t =
                      Curves.easeOutBack.transform(_maskotController.value);
                  double bounce = sin(t * pi) * 8;
                  return Positioned(
                    top: screenHeight * 0.08 + (1 - t) * 60 - bounce,
                    left: (screenWidth - maskotSize) / 2,
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: 0.55,
                        child: SizedBox(
                          width: maskotSize,
                          height: maskotSize,
                          child: Image.asset(
                            'assets/erkek_maskot.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Konuşma balonu ortada ve oku da ortada
              Positioned(
                top: balonTop,
                left: screenWidth * 0.04,
                right: screenWidth * 0.04,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: balloonPadding,
                        vertical: screenHeight * 0.052,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(38),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey.withOpacity(0.3),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                            color: const Color(0xFF8FC8F7), width: 2),
                      ),
                      child: Text(
                        'TEBRİKLER!\n1. aşamayı bitirdin.\nSırada 2. aşama var.\nHazırsan devam edelim.',
                        style: TextStyle(
                          fontSize: balloonFontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.blueGrey.shade800,
                          height: 1.32,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Balon oku ortada
                    Align(
                      alignment: Alignment.center,
                      child: CustomPaint(
                        painter: _BalloonArrowPainter(),
                        child: const SizedBox(
                          width: 44,
                          height: 22,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                  ],
                ),
              ),
              // Devam Et butonu en altta ve ortada, basit animasyonlu
              Positioned(
                left: 0,
                right: 0,
                bottom: screenHeight * 0.06,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _buttonScaleController,
                    builder: (context, child) {
                      double scale = 1.0 + _buttonScaleController.value;
                      return Transform.scale(
                        scale: scale,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF60BAE3),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.18,
                              vertical: screenHeight * 0.03,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 7,
                          ),
                          onPressed: _onContinue,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Devam Et',
                                style: TextStyle(
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: buttonFontSize * 1.18),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Konfeti efekti (kız maskotlu ekrandaki gibi)
              if (showConfetti)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _confettiController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _ConfettiPainter(_confettiController.value,
                              24, screenWidth, screenHeight),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalloonArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawShadow(path, Colors.blueGrey.withOpacity(0.08), 2, false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final int count;
  final double width;
  final double height;
  final List<Color> colors = const [
    Color(0xFF8FC8F7),
    Color(0xFF60BAE3),
    Color(0xFFB49AD2),
    Color(0xFFF88CFB),
    Color(0xFFFFD166),
    Color(0xFF6EE7B7),
  ];
  _ConfettiPainter(this.progress, this.count, this.width, this.height);
  final Random _rand = Random();

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi + progress * 2 * pi;
      final radius = width * 0.32 * progress + _rand.nextDouble() * 12;
      final x = width / 2 + cos(angle) * radius + _rand.nextDouble() * 8;
      final y = height * 0.18 +
          sin(angle) * radius +
          progress * height * 0.18 +
          _rand.nextDouble() * 8;
      final color = colors[i % colors.length];
      final paint = Paint()..color = color.withOpacity(0.7);
      canvas.drawCircle(Offset(x, y), 7 + _rand.nextDouble() * 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
