import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/language_provider.dart';
import '../../screens/karsilastirma_sorulari_screen.dart';

class KalinInceSoru9 extends StatefulWidget {
  const KalinInceSoru9({super.key});

  @override
  State<KalinInceSoru9> createState() => _KalinInceSoru9State();
}

class _KalinInceSoru9State extends State<KalinInceSoru9>
    with TickerProviderStateMixin {
  bool? selectedAnswer;
  bool showFeedback = false;
  bool isCorrect = false;
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

  void _resetWrongCountSync() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('kalin_ince_asama1_wrong_count', 0);
    });
  }

  Future<void> _trackWrongAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('kalin_ince_asama1_wrong_count') ?? 0;
    wrongCount++;
    await prefs.setInt('kalin_ince_asama1_wrong_count', wrongCount);
  }

  Future<int> _calculateStars() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('kalin_ince_asama1_wrong_count') ?? 0;

    if (wrongCount >= 0 && wrongCount <= 3) {
      return 3;
    } else if (wrongCount >= 4 && wrongCount <= 6) {
      return 2;
    } else {
      // 7-9 yanlış
      return 1;
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void checkAnswer(bool isInce) async {
    setState(() {
      selectedAnswer = isInce;
      isCorrect = isInce;
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    if (isInce) {
      // Level 3 tamamlandı olarak kaydet
      final prefs = await SharedPreferences.getInstance();
      final currentLevel = prefs.getInt('karsilastirma_completed_level') ?? 0;
      if (currentLevel < 3) {
        await prefs.setInt('karsilastirma_completed_level', 3);
      }

      // Yıldız hesapla ve popup göster
      Future.delayed(const Duration(seconds: 2), () async {
        if (mounted) {
          int stars = await _calculateStars();
          _showCompletionDialog(stars);
        }
      });
    } else {
      _trackWrongAnswer();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            showFeedback = false;
            selectedAnswer = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final iconSize = screenWidth * 0.065;
    final stageFontSize = screenWidth * 0.038;

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
                // Üst kısım - Geri butonu ve Aşama yazısı
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
                  ],
                ),
                // Main Content - Ekranı yukarı alıyoruz
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(
                        4,
                        0,
                        4,
                        0,
                      ), // Sağdan ve soldan daha geniş
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
                      child: Column(
                        children: [
                          // Title
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 1,
                            ),
                            child: Text(
                              isEnglish
                                  ? 'Choose the thin one.'
                                  : 'İnce olanı işaretle.',
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 15),

                          // First Image (ince dal)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 0,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  'assets/kalin_ince_asa1/soru9/Resim17.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // First Button
                          Center(
                            child: SizedBox(
                              width: screenWidth * 0.65,
                              height: 40,
                              child: ElevatedButton(
                                onPressed:
                                    showFeedback
                                        ? null
                                        : () => checkAnswer(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      selectedAnswer == true
                                          ? (isCorrect
                                              ? Colors.green
                                              : Colors.red)
                                          : Colors.pinkAccent.shade100,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: selectedAnswer == true ? 8 : 4,
                                  shadowColor:
                                      selectedAnswer == true
                                          ? (isCorrect
                                              ? Colors.green.shade300
                                              : Colors.red.shade300)
                                          : Colors.pink.shade100,
                                ),
                                child: const Text(
                                  'Seç',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 70),

                          // Second Image (kalın dal)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 0,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  'assets/kalin_ince_asa1/soru9/Resim18.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Second Button
                          Center(
                            child: SizedBox(
                              width: screenWidth * 0.65,
                              height: 40,
                              child: ElevatedButton(
                                onPressed:
                                    showFeedback
                                        ? null
                                        : () => checkAnswer(false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      selectedAnswer == false
                                          ? (isCorrect
                                              ? Colors.green
                                              : Colors.red)
                                          : Colors.pinkAccent.shade100,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: selectedAnswer == false ? 8 : 4,
                                  shadowColor:
                                      selectedAnswer == false
                                          ? (isCorrect
                                              ? Colors.green.shade300
                                              : Colors.red.shade300)
                                          : Colors.pink.shade100,
                                ),
                                child: const Text(
                                  'Seç',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sabit Feedback Alanı - Alt kısımda sabit alan
                Container(
                  height: 80, // Sabit yükseklik
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
                                    isCorrect
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color:
                                        isCorrect ? Colors.green : Colors.red,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isCorrect
                                        ? (isEnglish
                                            ? 'Well done! 🎉'
                                            : 'Aferin! 🎉')
                                        : (isEnglish
                                            ? 'Try again! 😔'
                                            : 'Tekrar dene! 😔'),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color:
                                          isCorrect ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : const SizedBox.shrink(), // Boş alan
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCompletionDialog(int stars) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
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
                    opacity: value,
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
                                final individualSize = (popupWidth * 0.15).clamp(40.0, 80.0);
                                return TweenAnimationBuilder<double>(
                                  duration: Duration(milliseconds: 400 + (index * 200)),
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
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const KarsilastirmaSorulariScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                height: (popupHeight * 0.1).clamp(45.0, 65.0),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
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
          },
        ),
      ),
    );
  }
}
