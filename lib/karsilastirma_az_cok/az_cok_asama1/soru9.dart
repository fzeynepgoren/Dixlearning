import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/language_provider.dart';
import '../../screens/karsilastirma_sorulari_screen.dart';

class AzCokSoru9 extends StatefulWidget {
  const AzCokSoru9({super.key});

  @override
  State<AzCokSoru9> createState() => _AzCokSoru9State();
}

class _AzCokSoru9State extends State<AzCokSoru9> with TickerProviderStateMixin {
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

  @override
  void dispose() {
    _feedbackController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void checkAnswer(bool isCorrectAnswer) async {
    setState(() {
      selectedAnswer = isCorrectAnswer;
      isCorrect = isCorrectAnswer;
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    if (isCorrectAnswer) {
      // Level 1 tamamlandı olarak kaydet
      final prefs = await SharedPreferences.getInstance();
      final currentLevel = prefs.getInt('karsilastirma_completed_level') ?? 0;
      if (currentLevel < 1) {
        await prefs.setInt('karsilastirma_completed_level', 1);
      }

      // Doğruysa 2 saniye sonra sonraki soruya geç
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const KarsilastirmaSorulariScreen(),
            ),
          );
        }
      });
    } else {
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
                          Text(
                            isEnglish
                                ? 'Choose the one with more.'
                                : 'Çok olanı işaretle.',
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          Expanded(
                            child: Image.asset(
                              'assets/az_cok_asa1/soru9/az_papatya.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                                          : Color(0xFFFDC726),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: selectedAnswer == false ? 8 : 4,
                                  shadowColor:
                                      selectedAnswer == false
                                          ? (isCorrect
                                              ? Colors.green.shade300
                                              : Colors.red.shade300)
                                          : Color(0xFFFDC726),
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
                          Expanded(
                            child: Image.asset(
                              'assets/az_cok_asa1/soru9/cok_sekil.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                                          : Color(0xFFFDC726),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: selectedAnswer == true ? 8 : 4,
                                  shadowColor:
                                      selectedAnswer == true
                                          ? (isCorrect
                                              ? Colors.green.shade300
                                              : Colors.red.shade300)
                                          : Color(0xFFFDC726),
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
}
