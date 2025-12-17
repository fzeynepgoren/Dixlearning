import 'package:flutter/material.dart';
import 'giris_etkinlikleri_screen.dart';
import 'profile_screen.dart';
import 'matching_questions_screen.dart';
import 'karsilastirma_sorulari_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'sorting_roadmap_screen_new.dart';
import 'siniflandirma_sorulari_screen.dart';
import 'login_screen.dart';

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
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
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

              // Sol üstte profil butonu
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _AnimatedIconButton(
                    onTap: _navigateToProfile,
                    icon: Icons.person,
                    iconColor: const Color(0xFF81D4FA),
                    iconSize: 40,
                  ),
                ),
              ),

              // Sağ üstte çıkış butonu
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _AnimatedIconButton(
                      onTap: _handleLogout,
                      icon: Icons.logout,
                      iconColor: Colors.red,
                      iconSize: 35,
                    ),
                  ),
                ),
              ),

              // Görünmez butonlar - Her yapı için
              // 1. MANTAR EV - Giriş Etkinlikleri (sağ alt) - Parıltısız
              Positioned(
                left: screenWidth * 0.58,
                top: screenHeight * 0.73,
                child: GestureDetector(
                  onTap: () => _navigateToActivity(const GirisEtkinlikleriScreen()),
                  child: Container(
                    width: screenWidth * 0.42,
                    height: screenHeight * 0.2,
                    color: Colors.transparent,
                  ),
                ),
              ),

              // 2. PEMBE SARAY - Sıralama Soruları (sol alt) - PEMBE
              _buildInvisibleButton(
                left: screenWidth * 0.005,
                top: screenHeight * 0.69,
                width: screenWidth * 0.42,
                height: screenHeight * 0.28,
                shineColor: const Color(0xFFE91E63),
                onTap:
                    () => _navigateToActivity(const SortingRoadmapScreenNew()),
              ),

              // 3. YEŞİL/MAVİ ŞATO - Sınıflama Soruları (orta sağ) - YEŞİL
              _buildInvisibleButton(
                left: screenWidth * 0.5,
                top: screenHeight * 0.38,
                width: screenWidth * 0.5,
                height: screenHeight * 0.26,
                shineColor: const Color(0xFF4CAF50),
                onTap:
                    () => _navigateToActivity(
                      const ClassificationQuestionsScreen(),
                    ),
              ),

              // 4. SARI TAPINAK - Karşılaştırma Etkinlikleri (orta sol) - SARI
              _buildInvisibleButton(
                left: screenWidth * 0.005,
                top: screenHeight * 0.3,
                width: screenWidth * 0.40,
                height: screenHeight * 0.2,
                shineColor: const Color(0xFFFFEB3B),
                shineAlignment: const Alignment(0.3, 0.0),
                onTap:
                    () => _navigateToActivity(
                      const KarsilastirmaSorulariScreen(),
                    ),
              ),

              // 5. BÜYÜK SARAY - Eşleme Soruları (en üst) - SARI
              _buildInvisibleButton(
                left: screenWidth * 0.18,
                top: screenHeight * 0.08,
                width: screenWidth * 0.65,
                height: screenHeight * 0.16,
                shineColor: const Color(0xFFFFEB3B),
                shineAlignment: const Alignment(0.2, 0.0),
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
    required Color shineColor,
    Alignment shineAlignment = Alignment.center,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: _AnimatedTapButton(
        width: width,
        height: height,
        onTap: onTap,
        shineColor: shineColor,
        shineAlignment: shineAlignment,
      ),
    );
  }
}

class _AnimatedIconButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final double iconSize;

  const _AnimatedIconButton({
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.iconSize,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
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
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: widget.iconSize,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedTapButton extends StatefulWidget {
  final double width;
  final double height;
  final VoidCallback onTap;
  final Color shineColor;
  final Alignment shineAlignment;

  const _AnimatedTapButton({
    required this.width,
    required this.height,
    required this.onTap,
    required this.shineColor,
    this.shineAlignment = Alignment.center,
  });

  @override
  State<_AnimatedTapButton> createState() => _AnimatedTapButtonState();
}

class _AnimatedTapButtonState extends State<_AnimatedTapButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 0.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _isPressed = true;
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) async {
    if (_isPressed) {
      _isPressed = false;
      await _controller.reverse();
      widget.onTap();
    }
  }

  void _onTapCancel() {
    _isPressed = false;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.width < widget.height ? widget.width : widget.height;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            color: Colors.transparent,
            child: Align(
              alignment: widget.shineAlignment,
              child: Container(
                width: size * 0.5,
                height: size * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(_opacityAnimation.value * 0.9),
                      widget.shineColor.withOpacity(_opacityAnimation.value * 0.8),
                      widget.shineColor.withOpacity(_opacityAnimation.value * 0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.2, 0.6, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.shineColor.withOpacity(_opacityAnimation.value),
                      blurRadius: 50,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
