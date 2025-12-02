import 'package:flutter/material.dart';
import 'giris_etkinlikleri_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'matching_questions_screen.dart';
import 'karsilastirma_sorulari_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'sorting_roadmap_screen_new.dart';
import 'siniflandirma_sorulari_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
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
    } else if (index == 2) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  const SettingsScreen(),
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
  }

  void _navigateToActivity(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    const Color mainColor = Color(0xFFB3E5FC);
    const Color accentColor = Color(0xFF81D4FA);

    return WillPopScope(
      onWillPop: () async {
        setState(() {
          _selectedIndex = 1;
        });
        return true;
      },
      child: Scaffold(
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

                // Görünmez butonlar - Her yapı için
                // 1. MANTAR EV - Giriş Etkinlikleri (sağ alt)
                _buildInvisibleButton(
                  left: screenWidth * 0.58,
                  top: screenHeight * 0.78,
                  width: screenWidth * 0.38,
                  height: screenHeight * 0.10,
                  onTap:
                      () =>
                          _navigateToActivity(const GirisEtkinlikleriScreen()),
                ),

                // 2. PEMBE SARAY - Sıralama Soruları (sol alt)
                _buildInvisibleButton(
                  left: screenWidth * 0.02,
                  top: screenHeight * 0.72,
                  width: screenWidth * 0.40,
                  height: screenHeight * 0.14,
                  onTap:
                      () =>
                          _navigateToActivity(const SortingRoadmapScreenNew()),
                ),

                // 3. YEŞİL/MAVİ ŞATO - Sınıflama Soruları (orta sağ)
                _buildInvisibleButton(
                  left: screenWidth * 0.42,
                  top: screenHeight * 0.48,
                  width: screenWidth * 0.55,
                  height: screenHeight * 0.14,
                  onTap:
                      () => _navigateToActivity(
                        const ClassificationQuestionsScreen(),
                      ),
                ),

                // 4. ANTİK TAPINAK - Karşılaştırma Etkinlikleri (orta sol)
                _buildInvisibleButton(
                  left: screenWidth * 0.02,
                  top: screenHeight * 0.36,
                  width: screenWidth * 0.40,
                  height: screenHeight * 0.12,
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
                      () =>
                          _navigateToActivity(const MatchingQuestionsScreen()),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          mainColor: mainColor,
          accentColor: accentColor,
          isEnglish: isEnglish,
        ),
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
