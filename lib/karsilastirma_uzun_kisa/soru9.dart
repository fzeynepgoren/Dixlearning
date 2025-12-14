import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/karsilastirma_sorulari_screen.dart';

class UzunKisaMantarSemsiyeSorusu extends StatefulWidget {
  const UzunKisaMantarSemsiyeSorusu({super.key});

  @override
  State<UzunKisaMantarSemsiyeSorusu> createState() =>
      _UzunKisaMantarSemsiyeSorusuState();
}

class _UzunKisaMantarSemsiyeSorusuState
    extends State<UzunKisaMantarSemsiyeSorusu>
    with TickerProviderStateMixin {
  int? selectedIndex;
  bool? isCorrect;
  bool showFeedback = false;
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

<<<<<<< Updated upstream
=======
  Future<void> _trackWrongAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('uzun_kisa_wrong_count') ?? 0;
    wrongCount++;
    await prefs.setInt('uzun_kisa_wrong_count', wrongCount);
  }

  Future<int> _calculateStars() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('uzun_kisa_wrong_count') ?? 0;

    // Toplam doğru cevap sayısı (9 soru × 1 doğru = 9)
    const int totalCorrect = 9;
    // Toplam deneme = doğru + yanlış
    int totalAttempts = totalCorrect + wrongCount;
    // Yanlış oranı
    double wrongRatio = wrongCount / totalAttempts;

    int stars;
    if (wrongRatio <= 0.25) {
      stars = 3;
    } else if (wrongRatio <= 0.50) {
      stars = 2;
    } else {
      // %50 üzeri
      stars = 1;
    }

    // Yıldız sayısını kaydet
    await prefs.setInt('level_4_stars', stars);

    return stars;
  }

>>>>>>> Stashed changes
  void _handleSelect(int index) async {
    setState(() {
      selectedIndex = index;
      isCorrect = (index == 1); // 1: şemsiye (sağdaki) - uzun olan
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);
    if (isCorrect == true) {
      // Level 4 tamamlandı olarak kaydet
      final prefs = await SharedPreferences.getInstance();
      final currentLevel = prefs.getInt('karsilastirma_completed_level') ?? 0;
      if (currentLevel < 4) {
        await prefs.setInt('karsilastirma_completed_level', 4);
      }

<<<<<<< Updated upstream
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const KarsilastirmaSorulariScreen(),
          ),
        );
=======
      // Yıldız hesapla ve popup göster
      Future.delayed(const Duration(seconds: 2), () async {
        if (mounted) {
          // Önce feedback'i gizle
          setState(() {
            showFeedback = false;
            selectedIndex = null;
          });
          int stars = await _calculateStars();
          _showCompletionDialog(stars);
        }
>>>>>>> Stashed changes
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
    final double imageHeight = screenHeight * 0.48;
    const double buttonHeight = 50;
    final double buttonWidth = screenWidth * 0.28;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
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
                // Üst kısım - Sadece geri butonu mavi arka planda
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: iconSize,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const KarsilastirmaSorulariScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                    SizedBox(width: iconSize),
                  ],
                ),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 6,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
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
                                // Row with back button and stage label removed from here
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    'Uzun olanı işaretle.',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Ana resim
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
                                      'assets/uzun_kisa/soru9/mantarvesemsiye.png',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Seçim kutucukları
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.13,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(2, (i) {
                                      final isSelected = selectedIndex == i;
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
                                                    : Colors.cyan.shade400,
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
                                                    : Colors.cyan.shade300,
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
      ),
    );
  }
<<<<<<< Updated upstream
=======

  void _showCompletionDialog(int stars) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final screenHeight = MediaQuery.of(context).size.height;
                // Ekrana sığdır - dinamik boyut
                final popupWidth = screenWidth * 0.9;
                final popupHeight = screenHeight * 0.75;

                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (value * 0.2),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Col popup görseli - ekranın ortasına
                            Image.asset(
                              'assets/popup/col_popup.png',
                              width: popupWidth,
                              height: popupHeight,
                              fit: BoxFit.contain,
                            ),
                            // Beyaz yıldız görseli - popup'ın ortasındaki dikdörtgene
                            // Yıldız sayısına göre göster (yan yana)
                            if (stars > 0)
                              Positioned(
                                // Popup'ın ortasına yerleştir - popup görselinin ortasındaki dikdörtgen alanına
                                top: popupHeight * 0.45,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(stars, (index) {
                                    // Her yıldız için boyut - popup genişliğine göre dinamik
                                    // Popup'ın ortasındaki dikdörtgene sığacak şekilde
                                    final individualSize = (popupWidth * 0.15)
                                        .clamp(40.0, 80.0);
                                    return TweenAnimationBuilder<double>(
                                      duration: Duration(
                                        milliseconds: 400 + (index * 200),
                                      ),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      curve: Curves.elasticOut,
                                      builder: (context, scaleValue, child) {
                                        return Transform.scale(
                                          scale: scaleValue,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: popupWidth * 0.02,
                                            ),
                                            child: Image.asset(
                                              'assets/popup/beyazyildiz.png',
                                              width: individualSize,
                                              height: individualSize,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                ),
                              ),
                            // MENÜYE GİT butonu - popup'ın alt kısmına transparan buton
                            Positioned(
                              bottom: popupHeight * 0.28,
                              left: popupWidth * 0.15,
                              right: popupWidth * 0.15,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const KarsilastirmaSorulariScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: (popupHeight * 0.1).clamp(45.0, 65.0),
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
    );
  }
>>>>>>> Stashed changes
}
