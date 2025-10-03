import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../screens/home_screen.dart';
import 'package:dixlearning/karsilastirma_kalin_ince/kalin_ince_asama1/soru3.dart';

class KalinInceSoru2 extends StatefulWidget {
  const KalinInceSoru2({super.key});

  @override
  State<KalinInceSoru2> createState() => _KalinInceSoru2State();
}

class _KalinInceSoru2State extends State<KalinInceSoru2>
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
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void checkAnswer(bool isKalin) {
    // Soru: 'İnce olanı işaretle.'
    // Resim 3 ince (checkAnswer(false) bağlı), Resim 4 kalın (checkAnswer(true) bağlı).
    // Doğru cevap ince olan, yani isKalin = false olan butondur.
    final bool correctAnswer = !isKalin;

    setState(() {
      selectedAnswer = isKalin; // Basılan butonu temsil eder (false: ince, true: kalın)
      isCorrect = correctAnswer; // Cevabın doğru olup olmadığını tutar
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    if (isCorrect) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const KalinInceSoru3(),
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
                // Üst kısım - Geri butonu ve Aşama yazısı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: Colors.black, size: iconSize),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
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
                          4, 0, 4, 0), // Sağdan ve soldan daha geniş
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
                                horizontal: 20, vertical: 1),
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

                          // First Image (ince çubuk)
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
                                  'assets/kalin_ince_asa1/soru2/Resim3.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // First Button (ince çubuk, Doğru cevap)
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              // checkAnswer(false) -> isKalin false demek, yani ince demek. Doğru cevap.
                              onPressed: () => checkAnswer(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedAnswer == false
                                    ? (isCorrect
                                    ? Colors.green.shade500
                                    : Colors.red.shade500)
                                    : const Color(0xfff5e62d),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: selectedAnswer == false ? 8 : 4,
                                shadowColor: selectedAnswer == false
                                    ? (isCorrect
                                    ? Colors.green.shade300
                                    : Colors.red.shade300)
                                    : const Color(0xfff5e62d),
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

                          const SizedBox(height: 70),

                          // Second Image (kalın çubuk)
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
                                  'assets/kalin_ince_asa1/soru2/Resim4.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Second Button (kalın çubuk, Yanlış cevap)
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              // checkAnswer(true) -> isKalin true demek, yani kalın demek. Yanlış cevap.
                              onPressed: () => checkAnswer(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedAnswer == true
                                    ? (!isCorrect // Basılan bu, ama doğru mu?
                                    ? Colors.red.shade500
                                    : Colors.green.shade500)
                                    : const Color(0xfff5e62d),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: selectedAnswer == true ? 8 : 4,
                                shadowColor: selectedAnswer == true
                                    ? (!isCorrect
                                    ? Colors.red.shade300
                                    : Colors.green.shade300)
                                    : const Color(0xfff5e62d),
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
                        ],
                      ),
                    ),
                  ),
                ),

                // Sabit Feedback Alanı - Alt kısımda sabit alan
                Container(
                  height: 80, // Sabit yükseklik
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: showFeedback
                      ? ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _feedbackController,
                      curve: Curves.elasticOut,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      // === Sadeleştirilmiş Feedback Alanı ===
                      decoration: BoxDecoration(
                        color: Colors.white, // Sade arka plan
                        borderRadius: BorderRadius.circular(16),
                        // Kenarlık ve gölge yok
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green : Colors.red,
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