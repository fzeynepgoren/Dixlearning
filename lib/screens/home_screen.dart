import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'giris_etkinlikleri_screen.dart';
import 'profile_screen.dart';
import 'matching_questions_screen.dart';
import 'karsilastirma_sorulari_screen.dart';
import 'sorting_roadmap_screen_new.dart';
import 'siniflandirma_sorulari_screen.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _navigateToProfile() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const ProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _handleLogout() {
    final isEnglish =
        Provider.of<LanguageProvider>(context, listen: false).isEnglish;
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (BuildContext context) {
        final dialogWidth = MediaQuery.of(context).size.width * 0.78;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Opacity(
                  opacity: value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        width: dialogWidth,
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
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                              spreadRadius: 1,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.blue.shade400,
                            width: 4,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Başlık
                            Text(
                              isEnglish ? 'Logout' : 'Çıkış Yap',
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
                            const SizedBox(height: 20),
                            // Mesaj
                            Text(
                              isEnglish
                                  ? 'Are you sure you want to logout?'
                                  : 'Çıkış yapmak istediğinizden emin misiniz?',
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            // Butonlar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // İptal Butonu
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.green.shade400,
                                            Colors.green.shade500,
                                            Colors.green.shade700,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                          color: Colors.green.shade800,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(
                                              0.5,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          isEnglish ? 'Cancel' : 'İptal',
                                          style: GoogleFonts.quicksand(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                // Çıkış Butonu
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      // Oturum bilgilerini temizle
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setBool(
                                        'is_logged_in',
                                        false,
                                      );
                                      await prefs.remove('current_user');
                                      // Login ekranına yönlendir
                                      if (context.mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const LoginScreen(),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.red.shade400,
                                            Colors.red.shade500,
                                            Colors.red.shade700,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                          color: Colors.red.shade800,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.5),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          isEnglish ? 'Logout' : 'Çıkış',
                                          style: GoogleFonts.quicksand(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToActivity(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          return Stack(
            children: [
              // Arka plan - Gökyüzü rengi
              Container(color: const Color(0xFF87CEEB)),

              // Arka plan resmi - Tam ekranı doldur
              Positioned.fill(
                child: Image.asset(
                  'assets/screensphoto/anasayfa_roadmap.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.blue.shade200,
                      child: const Center(
                        child: Text(
                          '🏰 Roadmap yükleniyor...',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Sol üstte çıkış butonu - Estetik versiyon
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleLogout,
                      customBorder: const CircleBorder(),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.8),
                              blurRadius: 15,
                              spreadRadius: -2,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Yumuşak arka plan efekti
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            // Çıkış ikonu
                            const Icon(
                              Icons.logout,
                              color: Colors.red,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Sağ üstte profil butonu
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: _navigateToProfile,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF81D4FA),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Görünmez butonlar - Her yapı için
              // 1. MANTAR EV - Giriş Etkinlikleri (sağ alt)
              _buildInvisibleButton(
                left: screenWidth * 0.58,
                top: screenHeight * 0.73,
                width: screenWidth * 0.42,
                height: screenHeight * 0.2,
                onTap:
                    () => _navigateToActivity(const GirisEtkinlikleriScreen()),
              ),

              // 2. PEMBE SARAY - Sıralama Soruları (sol alt)
              _buildInvisibleButton(
                left: screenWidth * 0.005,
                top: screenHeight * 0.69,
                width: screenWidth * 0.42,
                height: screenHeight * 0.28,
                onTap:
                    () => _navigateToActivity(const SortingRoadmapScreenNew()),
              ),

              // 3. YEŞİL/MAVİ ŞATO - Sınıflama Soruları (orta sağ)
              _buildInvisibleButton(
                left: screenWidth * 0.5,
                top: screenHeight * 0.38,
                width: screenWidth * 0.5,
                height: screenHeight * 0.26,
                onTap:
                    () => _navigateToActivity(
                      const ClassificationQuestionsScreen(),
                    ),
              ),

              // 4. ANTİK TAPINAK - Karşılaştırma Etkinlikleri (orta sol)
              _buildInvisibleButton(
                left: screenWidth * 0.005,
                top: screenHeight * 0.3,
                width: screenWidth * 0.40,
                height: screenHeight * 0.2,
                onTap:
                    () => _navigateToActivity(
                      const KarsilastirmaSorulariScreen(),
                    ),
              ),

              // 5. BÜYÜK SARAY - Eşleme Soruları (en üst)
              _buildInvisibleButton(
                left: screenWidth * 0.18,
                top: screenHeight * 0.08,
                width: screenWidth * 0.65,
                height: screenHeight * 0.16,
                onTap:
                    () => _navigateToActivity(const MatchingQuestionsScreen()),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInvisibleButton({
    required double left,
    required double top,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          color: Colors.transparent,
        ),
      ),
    );
  }
}
