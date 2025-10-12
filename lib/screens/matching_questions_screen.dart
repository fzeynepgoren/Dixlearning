import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/language_provider.dart';
import '../providers/progress_provider.dart';
import '../asama1/soru1.dart';
import '../asama2/soru1.dart';
import '../asama3/soru1.dart';
import '../asama4/soru1.dart';
import 'home_screen.dart';

class MatchingQuestionsScreen extends StatelessWidget {
  const MatchingQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, ProgressProvider>(
      builder: (context, languageProvider, progressProvider, child) {
        final isEnglish = languageProvider.isEnglish;
        final progress = _calculateProgress(progressProvider);

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [
                        const Color(0xFF0D1117), // GitHub dark
                        const Color(0xFF161B22), // Darker
                        const Color(0xFF21262D), // Darkest
                      ]
                    : [
                        Colors.blue.shade100,
                        Colors.blue.shade200,
                        Colors.blue.shade300,
                      ],
              ),
            ),
            child: Stack(
              children: [
                // Yıldızlı arka plan
                CustomPaint(
                  painter: StarBackgroundPainter(progress: progress, context: context),
                  size: Size.infinite,
                ),

                // Başlık
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      isEnglish ? 'Matching Questions Roadmap' : 'Eşleme Soruları Yol Haritası',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Kıvrımlı yol
                CustomPaint(
                  painter: CurvedPathPainter(progress: progress, context: context),
                  size: Size.infinite,
                ),

                // Aşama kutucukları
                ..._buildStageBoxes(context, isEnglish, progressProvider),
                
                // Geri dönüş butonu (en üstte)
                Positioned(
                  top: 50,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      print('Back butonu tıklandı!');
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
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

  double _calculateProgress(ProgressProvider progressProvider) {
    int completedStages = 0;
    if (progressProvider.stage1Completed) completedStages++;
    if (progressProvider.stage2Completed) completedStages++;
    if (progressProvider.stage3Completed) completedStages++;
    if (progressProvider.stage4Completed) completedStages++;
    return completedStages / 4.0;
  }

  List<Widget> _buildStageBoxes(BuildContext context, bool isEnglish, ProgressProvider progressProvider) {
    return [
      // Aşama 1
      Positioned(
        left: 50,
        top: 700,
        child: _buildStageBox(
          context: context,
          stageNumber: 1,
          isUnlocked: true,
          isCompleted: progressProvider.stage1Completed,
          isEnglish: isEnglish,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MeyveEsle()),
            );
          },
        ),
      ),
      
      // Aşama 2
      Positioned(
        left: 70,
        top: 480,
        child: _buildStageBox(
          context: context,
          stageNumber: 2,
          isUnlocked: progressProvider.stage2Unlocked,
          isCompleted: progressProvider.stage2Completed,
          isEnglish: isEnglish,
          onTap: () {
            if (progressProvider.stage2Unlocked) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Soru1()),
              );
            }
          },
        ),
      ),
      
      // Aşama 3
      Positioned(
        left: 250,
        top: 380,
        child: _buildStageBox(
          context: context,
          stageNumber: 3,
          isUnlocked: progressProvider.stage3Unlocked,
          isCompleted: progressProvider.stage3Completed,
          isEnglish: isEnglish,
          onTap: () {
            if (progressProvider.stage3Unlocked) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActivityMatching()),
              );
            }
          },
        ),
      ),
      
      // Aşama 4
      Positioned(
        left: 150,
        top: 160,
        child: _buildStageBox(
          context: context,
          stageNumber: 4,
          isUnlocked: progressProvider.stage4Unlocked,
          isCompleted: progressProvider.stage4Completed,
          isEnglish: isEnglish,
          onTap: () {
            if (progressProvider.stage4Unlocked) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DuyguYuzEsle()),
              );
            }
          },
        ),
      ),
    ];
  }

  Widget _buildStageBox({
    required BuildContext context,
    required int stageNumber,
    required bool isUnlocked,
    required bool isCompleted,
    required bool isEnglish,
    required VoidCallback onTap,
  }) {
    Color boxColor;
    Widget? icon;
    
    if (isCompleted) {
      boxColor = Colors.green.shade400;
      icon = const Icon(Icons.check, color: Colors.white, size: 30);
    } else if (isUnlocked) {
      boxColor = Colors.blue.shade400;
      icon = Text(
        '$stageNumber',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      boxColor = Colors.grey.shade400;
      icon = const Text(
        '🔒',
        style: TextStyle(fontSize: 30),
      );
    }

    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: icon),
      ),
    );
  }
}

class StarBackgroundPainter extends CustomPainter {
  final double progress;
  final BuildContext context;

  StarBackgroundPainter({
    required this.progress,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    for (int i = 0; i < 150; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 0.5;
      
      final starPaint = Paint()
        ..color = progress > 0.25 
            ? Colors.yellow.shade400
            : Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.6)
                : Colors.white.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CurvedPathPainter extends CustomPainter {
  final double progress;
  final BuildContext context;

  CurvedPathPainter({
    required this.progress,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.6)
          : Colors.white.withOpacity(0.8)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(100, 720); // Sol alt - çok daha aşağıda
    path.quadraticBezierTo(110, 610, 120, 500); // İlk geniş kıvrım - uzatıldı
    path.quadraticBezierTo(200, 450, 280, 400); // İkinci geniş kıvrım - uzatıldı
    path.quadraticBezierTo(240, 290, 200, 180); // Üçüncü geniş kıvrım - yolun sonunda
    
    final completedPaint = Paint()
      ..color = Colors.green.shade400
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final completedPath = Path();
    completedPath.moveTo(100, 720);
    if (progress > 0.25) {
      completedPath.quadraticBezierTo(110, 610, 120, 500);
    }
    if (progress > 0.5) {
      completedPath.quadraticBezierTo(200, 450, 280, 400);
    }
    if (progress > 0.75) {
      completedPath.quadraticBezierTo(240, 290, 200, 180);
    }
    
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(completedPath, completedPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}