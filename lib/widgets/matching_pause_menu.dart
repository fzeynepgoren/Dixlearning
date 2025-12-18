import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';

class MatchingPauseMenu extends StatefulWidget {
  const MatchingPauseMenu({
    super.key,
    required this.isEnglish,
    required this.isSoundOn,
    required this.onResume,
    required this.onToggleSound,
    required this.onHome,
    required this.onEntryScreen,
    required this.onDismiss,
  });

  final bool isEnglish;
  final bool isSoundOn;
  final VoidCallback onResume;
  final VoidCallback onToggleSound;
  final VoidCallback onHome;
  final VoidCallback onEntryScreen;
  final VoidCallback onDismiss;

  @override
  State<MatchingPauseMenu> createState() => _MatchingPauseMenuState();
}

class _MatchingPauseMenuState extends State<MatchingPauseMenu> {
  bool _showOptionsMenu = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final menuWidth = MediaQuery.of(context).size.width * 0.78;

    if (_showOptionsMenu) {
      // Seçenekler menüsü
      return _buildOptionsMenu(
        context,
        themeProvider,
        languageProvider,
        menuWidth,
      );
    } else {
      // Ana menü
      return _buildMainMenu(context, menuWidth);
    }
  }

  Widget _buildMainMenu(BuildContext context, double menuWidth) {
    final homeLabel = widget.isEnglish ? 'EXIT' : 'ÇIK';
    final optionsLabel = widget.isEnglish ? 'Options' : 'Seçenekler';
    final continueLabel = widget.isEnglish ? 'Continue' : 'Devam et';

    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onDismiss,
        child: Container(
          color: Colors.black.withOpacity(0.35),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: menuWidth,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade200,
                          Colors.blue.shade200,
                          const Color(0xffffffff),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: Colors.blue.shade300, width: 3),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 350),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                'MENU',
                                style: GoogleFonts.quicksand(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 4,
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.blue.shade800.withOpacity(
                                        0.8,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 0),
                                    ),
                                    Shadow(
                                      color: Colors.blue.shade600.withOpacity(
                                        0.6,
                                      ),
                                      blurRadius: 15,
                                      offset: const Offset(0, 0),
                                    ),
                                    Shadow(
                                      color: Colors.white.withOpacity(0.9),
                                      blurRadius: 10,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          _MenuButton(
                            icon: Icons.play_arrow_rounded,
                            label: continueLabel,
                            color: Colors.green,
                            onPressed: widget.onResume,
                            isSoundOn: widget.isSoundOn,
                          ),
                          const SizedBox(height: 14),
                          _MenuButton(
                            icon: Icons.settings_rounded,
                            label: optionsLabel,
                            color: Colors.orange,
                            onPressed: () {
                              setState(() {
                                _showOptionsMenu = true;
                              });
                            },
                            isSoundOn: widget.isSoundOn,
                          ),
                          const SizedBox(height: 14),
                          _MenuButton(
                            icon: Icons.home_rounded,
                            label: homeLabel,
                            color: Colors.red,
                            onPressed: widget.onHome,
                            isSoundOn: widget.isSoundOn,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsMenu(
    BuildContext context,
    ThemeProvider themeProvider,
    LanguageProvider languageProvider,
    double menuWidth,
  ) {
    final soundLabel =
        widget.isSoundOn
            ? (widget.isEnglish ? 'Mute sound' : 'Sesi kapat')
            : (widget.isEnglish ? 'Enable sound' : 'Sesi aç');
    final themeLabel =
        themeProvider.isDark
            ? (widget.isEnglish ? 'Light mode' : 'Aydınlık mod')
            : (widget.isEnglish ? 'Dark mode' : 'Karanlık mod');
    final languageLabel = widget.isEnglish ? 'Türkçe' : 'English';
    final backLabel = widget.isEnglish ? 'Back' : 'Geri';
    final optionsTitle = widget.isEnglish ? 'OPTIONS' : 'SEÇENEKLER';

    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showOptionsMenu = false;
          });
        },
        child: Container(
          color: Colors.black.withOpacity(0.35),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: menuWidth,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade200,
                          Colors.blue.shade200,
                          const Color(0xffffffff),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: Colors.blue.shade300, width: 3),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 350),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                optionsTitle,
                                style: GoogleFonts.quicksand(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.blue.shade800.withOpacity(
                                        0.8,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 0),
                                    ),
                                    Shadow(
                                      color: Colors.blue.shade600.withOpacity(
                                        0.6,
                                      ),
                                      blurRadius: 15,
                                      offset: const Offset(0, 0),
                                    ),
                                    Shadow(
                                      color: Colors.white.withOpacity(0.9),
                                      blurRadius: 10,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          _MenuButton(
                            icon:
                                widget.isSoundOn
                                    ? Icons.volume_up_rounded
                                    : Icons.volume_off_rounded,
                            label: soundLabel,
                            color: const Color(0xFF4FC3F7),
                            onPressed: widget.onToggleSound,
                            isSoundOn: widget.isSoundOn,
                          ),
                          const SizedBox(height: 10),
                          _MenuButton(
                            icon:
                                themeProvider.isDark
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                            label: themeLabel,
                            color: const Color(0xFF9C27B0),
                            onPressed: () {
                              themeProvider.toggleTheme();
                            },
                            isSoundOn: widget.isSoundOn,
                          ),
                          const SizedBox(height: 10),
                          _MenuButton(
                            icon: Icons.language_rounded,
                            label: languageLabel,
                            color: const Color(0xFF00BCD4),
                            onPressed: () async {
                              await languageProvider.setLanguage(
                                !widget.isEnglish,
                              );
                            },
                            isSoundOn: widget.isSoundOn,
                          ),
                          const SizedBox(height: 10),
                          _MenuButton(
                            icon: Icons.arrow_back_rounded,
                            label: backLabel,
                            color: const Color(0xFF757575),
                            onPressed: () {
                              setState(() {
                                _showOptionsMenu = false;
                              });
                            },
                            isSoundOn: widget.isSoundOn,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WavyTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Estetik oran: dalga yüksekliği buton yüksekliğinin %5'i (daha yumuşak)
    final waveAmplitude = size.height * 0.05;
    // 2.5 dalga - estetik ve düzenli görünüm için
    const waveCount = 2.5;
    // Sol ve sağ kenarlar için oval radius (buton yüksekliğinin yarısı)
    final verticalRadius = size.height / 2;
    const totalPoints = 500; // Smooth geçiş için nokta sayısı

    // Sol kenar - oval (sağ kenarla tam aynı şekil, simetrik)
    // Alttan üste oval geçiş - sağ kenarla aynı formül
    // Sol kenar alt kenarın sol ucundan başlamalı (verticalRadius, size.height)
    path.moveTo(verticalRadius, size.height);

    // Sol kenar için oval noktalar - sağ kenarla tam aynı formül (simetrik, ters sırada)
    final leftArcPoints = <Offset>[];
    for (int i = 200; i >= 0; i--) {
      final angle =
          -math.pi / 2 +
          (i / 200) * math.pi; // 90°'den -90°'ye (ters sırada, alttan üste)
      // Sol kenar için x: verticalRadius'dan başlayıp 0'a gidip tekrar verticalRadius'a
      // Sağ kenar: size.width - verticalRadius + verticalRadius * cos(angle)
      // Sol kenar (simetrik): verticalRadius - verticalRadius * cos(angle)
      final x = verticalRadius - verticalRadius * math.cos(angle);
      final y = size.height / 2 + verticalRadius * math.sin(angle);
      leftArcPoints.add(Offset(x, y));
    }

    // Sol kenarı smooth cubic bezier ile çiz
    for (int i = 1; i < leftArcPoints.length; i++) {
      final current = leftArcPoints[i];
      final previous = leftArcPoints[i - 1];

      if (i == 1) {
        path.lineTo(current.dx, current.dy);
      } else if (i == leftArcPoints.length - 1) {
        path.lineTo(current.dx, current.dy);
      } else {
        final prevPrev = leftArcPoints[i - 2];
        final dx1 = previous.dx - (previous.dx - prevPrev.dx) * 0.3;
        final dy1 = previous.dy - (previous.dy - prevPrev.dy) * 0.3;
        final dx2 = previous.dx + (current.dx - previous.dx) * 0.3;
        final dy2 = previous.dy + (current.dy - previous.dy) * 0.3;
        path.cubicTo(dx1, dy1, dx2, dy2, current.dx, current.dy);
      }
    }

    // Üst kenar - sinüs dalgaları
    final usableWidth = size.width - 2 * verticalRadius;
    final topPoints = <Offset>[];

    for (int i = 0; i <= totalPoints; i++) {
      final t = i / totalPoints;
      final x = verticalRadius + t * usableWidth;

      if (x > size.width - verticalRadius) {
        topPoints.add(Offset(size.width - verticalRadius, 0));
        break;
      }

      // Sinüs dalgası - buton sınırları içinde kalması garanti
      final wavePhase = t * waveCount * 2 * math.pi;
      final y = waveAmplitude * math.sin(wavePhase);
      // Taşmayı önle: y değeri 0 ile waveAmplitude arasında olmalı
      final clampedY = y.clamp(-waveAmplitude, waveAmplitude);
      topPoints.add(Offset(x, clampedY));
    }

    // Üst kenarı çiz - smooth cubic bezier ile
    for (int i = 1; i < topPoints.length; i++) {
      final current = topPoints[i];
      final previous = topPoints[i - 1];

      if (i == 1) {
        path.lineTo(current.dx, current.dy);
      } else if (i == topPoints.length - 1) {
        path.lineTo(current.dx, current.dy);
      } else {
        final prevPrev = topPoints[i - 2];
        final dx1 = previous.dx - (previous.dx - prevPrev.dx) * 0.3;
        final dy1 = previous.dy - (previous.dy - prevPrev.dy) * 0.3;
        final dx2 = previous.dx + (current.dx - previous.dx) * 0.3;
        final dy2 = previous.dy + (current.dy - previous.dy) * 0.3;
        path.cubicTo(dx1, dy1, dx2, dy2, current.dx, current.dy);
      }
    }

    // Sağ kenar - oval (smooth elips yayı ile)
    // Üstten alta oval geçiş - smooth cubic bezier ile
    final rightArcPoints = <Offset>[];
    for (int i = 0; i <= 200; i++) {
      final angle = -math.pi / 2 + (i / 200) * math.pi; // -90°'den 90°'ye
      final x = size.width - verticalRadius + verticalRadius * math.cos(angle);
      final y = size.height / 2 + verticalRadius * math.sin(angle);
      rightArcPoints.add(Offset(x, y));
    }

    // Sağ kenarı smooth cubic bezier ile çiz
    for (int i = 1; i < rightArcPoints.length; i++) {
      final current = rightArcPoints[i];
      final previous = rightArcPoints[i - 1];

      if (i == 1) {
        path.lineTo(current.dx, current.dy);
      } else if (i == rightArcPoints.length - 1) {
        path.lineTo(current.dx, current.dy);
      } else {
        final prevPrev = rightArcPoints[i - 2];
        final dx1 = previous.dx - (previous.dx - prevPrev.dx) * 0.3;
        final dy1 = previous.dy - (previous.dy - prevPrev.dy) * 0.3;
        final dx2 = previous.dx + (current.dx - previous.dx) * 0.3;
        final dy2 = previous.dy + (current.dy - previous.dy) * 0.3;
        path.cubicTo(dx1, dy1, dx2, dy2, current.dx, current.dy);
      }
    }

    // Alt kenar - sinüs dalgaları (ters, simetrik)
    final bottomPoints = <Offset>[];

    for (int i = 0; i <= totalPoints; i++) {
      final t = i / totalPoints;
      final x = size.width - verticalRadius - t * usableWidth;

      if (x < verticalRadius) {
        bottomPoints.add(Offset(verticalRadius, size.height));
        break;
      }

      // Sinüs dalgası (ters) - üsttekiyle simetrik, taşma yok
      final wavePhase = t * waveCount * 2 * math.pi;
      final waveY = waveAmplitude * math.sin(wavePhase);
      // Taşmayı önle: y değeri size.height - waveAmplitude ile size.height + waveAmplitude arasında
      final clampedWaveY = waveY.clamp(-waveAmplitude, waveAmplitude);
      final y = size.height - clampedWaveY;
      bottomPoints.add(Offset(x, y));
    }

    // Alt kenarı çiz - smooth cubic bezier ile
    for (int i = 1; i < bottomPoints.length; i++) {
      final current = bottomPoints[i];
      final previous = bottomPoints[i - 1];

      if (i == 1) {
        path.lineTo(current.dx, current.dy);
      } else if (i == bottomPoints.length - 1) {
        path.lineTo(current.dx, current.dy);
      } else {
        final prevPrev = bottomPoints[i - 2];
        final dx1 = previous.dx - (previous.dx - prevPrev.dx) * 0.3;
        final dy1 = previous.dy - (previous.dy - prevPrev.dy) * 0.3;
        final dx2 = previous.dx + (current.dx - previous.dx) * 0.3;
        final dy2 = previous.dy + (current.dy - previous.dy) * 0.3;
        path.cubicTo(dx1, dy1, dx2, dy2, current.dx, current.dy);
      }
    }

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    required this.isSoundOn,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool isSoundOn;

  @override
  Widget build(BuildContext context) {
    // Renge göre gradyan tonları (üstte açık, altta koyu - 3 boyutlu görünüm için)
    List<Color> gradientColors;
    if (color == Colors.red) {
      gradientColors = [
        Colors.red.shade400,
        Colors.red.shade500,
        Colors.red.shade700,
      ];
    } else if (color == Colors.green) {
      gradientColors = [
        Colors.green.shade400,
        Colors.green.shade500,
        Colors.green.shade700,
      ];
    } else if (color == Colors.orange) {
      gradientColors = [
        Colors.orange.shade400,
        Colors.orange.shade500,
        Colors.orange.shade700,
      ];
    } else if (color == const Color(0xFF4FC3F7)) {
      // Mavi (ses butonu)
      gradientColors = [
        const Color(0xFF81D4FA), // Açık mavi
        const Color(0xFF4FC3F7), // Orta mavi
        const Color(0xFF0288D1), // Koyu mavi
      ];
    } else if (color == const Color(0xFF9C27B0)) {
      // Mor (tema butonu)
      gradientColors = [
        const Color(0xFFBA68C8), // Açık mor
        const Color(0xFF9C27B0), // Orta mor
        const Color(0xFF6A1B9A), // Koyu mor
      ];
    } else if (color == const Color(0xFF00BCD4)) {
      // Cyan (dil butonu)
      gradientColors = [
        const Color(0xFF4DD0E1), // Açık cyan
        const Color(0xFF00BCD4), // Orta cyan
        const Color(0xFF00838F), // Koyu cyan
      ];
    } else if (color == const Color(0xFF757575)) {
      // Gri (geri butonu)
      gradientColors = [
        const Color(0xFF9E9E9E), // Açık gri
        const Color(0xFF757575), // Orta gri
        const Color(0xFF424242), // Koyu gri
      ];
    } else {
      // Diğer renkler için üstte açık, altta koyu gradient
      gradientColors = [color.withOpacity(0.6), color, color.withOpacity(0.9)];
    }

    return SizedBox(
      width: double.infinity,
      child: ClipPath(
        clipper: _WavyTopClipper(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.6),
                blurRadius: 15,
                offset: const Offset(0, 4),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                onPressed();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 26, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
