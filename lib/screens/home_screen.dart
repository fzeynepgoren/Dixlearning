import 'package:flutter/material.dart';
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isEnglish ? 'Logout' : 'Çıkış Yap',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            isEnglish
                ? 'Are you sure you want to logout?'
                : 'Çıkış yapmak istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isEnglish ? 'Cancel' : 'İptal',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Oturum bilgilerini temizle
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('is_logged_in', false);
                await prefs.remove('current_user');
                // Login ekranına yönlendir
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(isEnglish ? 'Logout' : 'Çıkış'),
            ),
          ],
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

              // Sol üstte çıkış butonu
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: _handleLogout,
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
                        Icons.logout,
                        color: Colors.red,
                        size: 35,
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


