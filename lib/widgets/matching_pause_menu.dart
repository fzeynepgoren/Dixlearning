import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      return _buildOptionsMenu(context, themeProvider, languageProvider, menuWidth);
    } else {
      // Ana menü
      return _buildMainMenu(context, menuWidth);
    }
  }

  Widget _buildMainMenu(BuildContext context, double menuWidth) {
    final homeLabel = widget.isEnglish ? 'Go to home' : 'Ana menüye dön';
    final entryLabel = widget.isEnglish ? 'Entry screen' : 'Giriş ekranı';
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
                borderRadius: BorderRadius.zero,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: menuWidth,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.zero,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFB26A43), width: 3),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'MENU',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6D3B1F),
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.7),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _MenuButton(
                          icon: Icons.home_rounded,
                          label: homeLabel,
                          color: const Color(0xFFFFB74D),
                          onPressed: widget.onHome,
                          isSoundOn: widget.isSoundOn,
                        ),
                        const SizedBox(height: 14),
                        _MenuButton(
                          icon: Icons.login_rounded,
                          label: entryLabel,
                          color: const Color(0xFFFF9800),
                          onPressed: widget.onEntryScreen,
                          isSoundOn: widget.isSoundOn,
                        ),
                        const SizedBox(height: 14),
                        _MenuButton(
                          icon: Icons.settings_rounded,
                          label: optionsLabel,
                          color: const Color(0xFF9C27B0),
                          onPressed: () {
                            setState(() {
                              _showOptionsMenu = true;
                            });
                          },
                          isSoundOn: widget.isSoundOn,
                        ),
                        const SizedBox(height: 14),
                        _MenuButton(
                          icon: Icons.play_arrow_rounded,
                          label: continueLabel,
                          color: const Color(0xFF81C784),
                          onPressed: widget.onResume,
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
    );
  }

  Widget _buildOptionsMenu(BuildContext context, ThemeProvider themeProvider, 
      LanguageProvider languageProvider, double menuWidth) {
    final soundLabel = widget.isSoundOn
        ? (widget.isEnglish ? 'Mute sound' : 'Sesi kapat')
        : (widget.isEnglish ? 'Enable sound' : 'Sesi aç');
    final themeLabel = themeProvider.isDark
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
                borderRadius: BorderRadius.zero,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: menuWidth,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.zero,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFB26A43), width: 3),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          optionsTitle,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6D3B1F),
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.7),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _MenuButton(
                          icon: widget.isSoundOn
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          label: soundLabel,
                          color: const Color(0xFF4FC3F7),
                          onPressed: widget.onToggleSound,
                          isSoundOn: widget.isSoundOn,
                        ),
                        const SizedBox(height: 14),
                        _MenuButton(
                          icon: themeProvider.isDark
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
                            await languageProvider.setLanguage(!widget.isEnglish);
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
    );
  }
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 6,
          shadowColor: Colors.black26,
        ),
        onPressed: () {
          // Ses kapalıyken tuş seslerini engellemek için
          // HapticFeedback kullanmıyoruz
          onPressed();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}


