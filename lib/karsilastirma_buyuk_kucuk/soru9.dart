import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/karsilastirma_sorulari_screen.dart';
import '../screens/home_screen.dart';
import '../widgets/matching_pause_menu.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class BuyukKucukSoru9 extends StatefulWidget {
  const BuyukKucukSoru9({super.key});

  @override
  State<BuyukKucukSoru9> createState() => _BuyukKucukSoru9State();
}

class _BuyukKucukSoru9State extends State<BuyukKucukSoru9>
    with TickerProviderStateMixin {
  int? selectedIndex;
  bool? isCorrect;
  bool showFeedback = false;
  bool _showPauseMenu = false;
  bool _isSoundOn = true;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleSelect(int index) async {
    setState(() {
      selectedIndex = index;
      isCorrect = (index == 1); // 1: sağdaki küçük olan doğru
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);
    if (isCorrect == true) {
      // Level 2 tamamlandı olarak kaydet
      final prefs = await SharedPreferences.getInstance();
      final currentLevel = prefs.getInt('karsilastirma_completed_level') ?? 0;
      if (currentLevel < 2) {
        await prefs.setInt('karsilastirma_completed_level', 2);
      }

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const KarsilastirmaSorulariScreen(),
          ),
        );
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          showFeedback = false;
          selectedIndex = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final iconSize = screenWidth * 0.065;
    const Color defaultBtnColor = Color(0xFFD7CCC8); // bej tonları
    final double imageHeight = screenHeight * 0.48;
    const double buttonHeight = 50;
    final double buttonWidth = screenWidth * 0.28;

    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    
    return WillPopScope(
      onWillPop: () async {
        if (_showPauseMenu) {
          setState(() {
            _showPauseMenu = false;
          });
        } else {
          setState(() {
            _showPauseMenu = true;
          });
        }
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
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
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Üst kısım
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showPauseMenu = true;
                          });
                        },
                        child: Container(
                          width: iconSize * 1.6,
                          height: iconSize * 1.6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.purple.shade300,
                                Colors.purple.shade600,
                                Colors.deepPurple.shade700,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.shade800.withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(-2, -2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.home_rounded,
                            color: Colors.black,
                            size: iconSize * 0.9,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: iconSize),
                  ],
                ),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: screenHeight * 0.98,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    'Nesnelerden küçük olanı işaretle.',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Resim alanı
                                Container(
                                  width: double.infinity,
                                  height: imageHeight,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.10),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.asset(
                                      'assets/buyuk_kucuk/soru9/Resim9.png',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Butonlar
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.13,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(2, (i) {
                                      final isSelected = selectedIndex == i;
                                      Color btnColor = defaultBtnColor;
                                      if (isSelected) {
                                        if (isCorrect == true) {
                                          btnColor = Colors.green.shade500;
                                        } else if (isCorrect == false) {
                                          btnColor = Colors.red.shade500;
                                        }
                                      }
                                      return SizedBox(
                                        width: buttonWidth,
                                        height: buttonHeight,
                                        child: ElevatedButton(
                                          onPressed:
                                              showFeedback
                                                  ? null
                                                  : () => _handleSelect(i),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                isSelected
                                                    ? (isCorrect == true
                                                        ? Colors.green
                                                        : Colors.red)
                                                    : Colors
                                                        .deepPurple
                                                        .shade400,
                                            foregroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            elevation: isSelected ? 8 : 4,
                                            shadowColor:
                                                isSelected
                                                    ? (isCorrect == true
                                                        ? Colors.green.shade300
                                                        : Colors.red.shade300)
                                                    : Colors
                                                        .deepPurple
                                                        .shade300,
                                          ),
                                          child: const Text(
                                            'Seç',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Feedback Kutusu - Asama1 gibi basit
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child:
                      showFeedback
                          ? ScaleTransition(
                            scale: CurvedAnimation(
                              parent: _feedbackController,
                              curve: Curves.elasticOut,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isCorrect == true
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color:
                                        isCorrect == true
                                            ? Colors.green
                                            : Colors.red,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isCorrect == true
                                        ? 'Aferin! 🎉'
                                        : 'Tekrar dene! 😔',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color:
                                          isCorrect == true
                                              ? Colors.green
                                              : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
            ),
            if (_showPauseMenu)
              MatchingPauseMenu(
                isEnglish: isEnglish,
                isSoundOn: _isSoundOn,
                onResume: () => setState(() => _showPauseMenu = false),
                onToggleSound: () => setState(() => _isSoundOn = !_isSoundOn),
                onHome: () {
                  setState(() => _showPauseMenu = false);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const KarsilastirmaSorulariScreen(),
                    ),
                    (route) => false,
                  );
                },
                onEntryScreen: () {
                  setState(() => _showPauseMenu = false);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                    (route) => false,
                  );
                },
                onDismiss: () => setState(() => _showPauseMenu = false),
              ),
          ],
        ),
      ),
    );
  }
}
