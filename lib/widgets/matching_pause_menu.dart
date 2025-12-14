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
                          const SizedBox(height: 14),
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
                          const SizedBox(height: 14),
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
                          const SizedBox(height: 14),
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
    final waveHeight = 18.0;
    final waveCount = 5.0;

    // Yuvarlak köşeler için radius - buton yüksekliğine göre ayarlanmış (yüksekliğin %30'u)
    final cornerRadius = (size.height * 0.30).clamp(12.0, 18.0);

    // Üst sol köşeden başla
    path.moveTo(cornerRadius, 0);

    // Üst kenar - pürüzsüz sinüs dalgaları
    final usableWidth = size.width - 2 * cornerRadius;
    final totalPoints = 100; // Pürüzsüz geçiş için yeterli nokta

    for (int i = 0; i <= totalPoints; i++) {
      final t = i / totalPoints;
      final x = cornerRadius + t * usableWidth;

      if (x > size.width - cornerRadius) break;

      // Pürüzsüz sinüs dalgası
      final wavePhase = t * waveCount * 2 * math.pi;
      final y = waveHeight * 0.08 * math.sin(wavePhase);

      if (i == 0) {
        path.lineTo(x, y);
      } else {
        final prevT = (i - 1) / totalPoints;
        final prevX = cornerRadius + prevT * usableWidth;
        final prevWavePhase = prevT * waveCount * 2 * math.pi;
        final prevY = waveHeight * 0.08 * math.sin(prevWavePhase);

        // Pürüzsüz cubic bezier
        final controlX1 = prevX + (x - prevX) * 0.5;
        final controlY1 = prevY;
        final controlX2 = x - (x - prevX) * 0.5;
        final controlY2 = y;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

    // Üst sağ köşe yuvarlatma
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    // Sağ kenar (düz)
    path.lineTo(size.width, size.height - cornerRadius);

    // Alt sağ köşe yuvarlatma
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );

    // Alt kenar - pürüzsüz sinüs dalgaları (ters)
    for (int i = 0; i <= totalPoints; i++) {
      final t = i / totalPoints;
      final x = size.width - cornerRadius - t * usableWidth;

      if (x < cornerRadius) {
        path.lineTo(cornerRadius, size.height);
        break;
      }

      // Pürüzsüz sinüs dalgası (ters)
      final wavePhase = t * waveCount * 2 * math.pi;
      final y = size.height - waveHeight * 0.08 * math.sin(wavePhase);

      if (i == 0) {
        path.lineTo(x, y);
      } else {
        final prevT = (i - 1) / totalPoints;
        final prevX = size.width - cornerRadius - prevT * usableWidth;
        final prevWavePhase = prevT * waveCount * 2 * math.pi;
        final prevY = size.height - waveHeight * 0.08 * math.sin(prevWavePhase);

        // Pürüzsüz cubic bezier
        final controlX1 = prevX - (prevX - x) * 0.5;
        final controlY1 = prevY;
        final controlX2 = x + (prevX - x) * 0.5;
        final controlY2 = y;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

    // Alt sol köşe yuvarlatma
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);

    // Sol kenar (düz)
    path.lineTo(0, cornerRadius);

    // Üst sol köşe yuvarlatma
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

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
    // Renge göre gradyan tonları
    List<Color> gradientColors;
    if (color == const Color(0xFFFFB74D)) {
      gradientColors = [
        const Color(0xFFFFB74D).withOpacity(0.9),
        const Color(0xFFFFB74D),
        const Color(0xFFFFB74D).withOpacity(0.8),
      ];
    } else if (color == const Color(0xFFFF9800)) {
      gradientColors = [
        const Color(0xFFFF9800).withOpacity(0.9),
        const Color(0xFFFF9800),
        const Color(0xFFFF9800).withOpacity(0.8),
      ];
    } else if (color == const Color(0xFF9C27B0)) {
      gradientColors = [
        const Color(0xFF9C27B0).withOpacity(0.9),
        const Color(0xFF9C27B0),
        const Color(0xFF9C27B0).withOpacity(0.8),
      ];
    } else if (color == const Color(0xFF81C784)) {
      gradientColors = [
        const Color(0xFF81C784).withOpacity(0.9),
        const Color(0xFF81C784),
        const Color(0xFF81C784).withOpacity(0.8),
      ];
    } else if (color == const Color(0xFF4FC3F7)) {
      gradientColors = [
        const Color(0xFF4FC3F7).withOpacity(0.9),
        const Color(0xFF4FC3F7),
        const Color(0xFF4FC3F7).withOpacity(0.8),
      ];
    } else if (color == const Color(0xFF00BCD4)) {
      gradientColors = [
        const Color(0xFF00BCD4).withOpacity(0.9),
        const Color(0xFF00BCD4),
        const Color(0xFF00BCD4).withOpacity(0.8),
      ];
    } else if (color == const Color(0xFF757575)) {
      gradientColors = [
        const Color(0xFF757575).withOpacity(0.9),
        const Color(0xFF757575),
        const Color(0xFF757575).withOpacity(0.8),
      ];
    } else if (color == Colors.green) {
      // Yeşil buton: üstte açık, altta koyu
      gradientColors = [
        Colors.green.shade400,
        Colors.green.shade500,
        Colors.green.shade700,
      ];
    } else if (color == Colors.orange) {
      // Turuncu buton: üstte açık, altta koyu
      gradientColors = [
        Colors.orange.shade400,
        Colors.orange.shade500,
        Colors.orange.shade700,
      ];
    } else if (color == Colors.red) {
      // Kırmızı buton: üstte açık, altta koyu
      gradientColors = [
        Colors.red.shade400,
        Colors.red.shade500,
        Colors.red.shade700,
      ];
    } else {
      // Diğer renkler için varsayılan
      gradientColors = [color, color, color];
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
