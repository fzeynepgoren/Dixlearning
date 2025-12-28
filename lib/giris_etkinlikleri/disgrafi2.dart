import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/activity_tracker.dart';
import 'disgrafi3.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../screens/home_screen.dart';

class Disgrafi2 extends StatefulWidget {
  const Disgrafi2({super.key});

  @override
  State<Disgrafi2> createState() => _Disgrafi2State();
}

class _Disgrafi2State extends State<Disgrafi2> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  bool _isCorrect = false;
  bool _showFeedback = false;
  int _attemptCount = 0; // Deneme sayacı
  int _correctCount = 0;
  int _totalQuestions = 1; // Disgrafi2'de 1 soru var

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();

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

    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _slideController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _checkPoem() {
    const correct = 'Ailemle birlikte tiyatroya gittik.';
    final isAnswerCorrect = _controller.text.trim() == correct;

    setState(() {
      _isCorrect = isAnswerCorrect;
      _showFeedback = true;
      _attemptCount++; // Deneme sayısını artır
    });

    _feedbackController.forward(from: 0);

    // İlk deneme doğruysa veya ikinci deneme sonrası Disgrafi3'e geç
    if (isAnswerCorrect || _attemptCount >= 2) {
      if (isAnswerCorrect) {
        _correctCount = 1;
      }
      Future.delayed(const Duration(seconds: 3), () async {
        if (!mounted) return;
        // Disgrafi2 tamamlandı - başarı yüzdesini kaydet
        await _saveDisgrafiProgress();
        ActivityTracker.completeActivity();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HeceDoldurma()),
        );
      });
    } else {
      // İlk deneme yanlışsa, 3 saniye sonra feedback'i gizle ve tekrar deneme imkanı ver
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() {
          _showFeedback = false;
        });
      });
    }
  }

  Future<void> _saveDisgrafiProgress() async {
    final prefs = await SharedPreferences.getInstance();
    // Disgrafi2 için doğru ve toplam sayıları kaydet
    int disgrafi2Correct = prefs.getInt('disgrafi2_correct') ?? 0;
    int disgrafi2Total = prefs.getInt('disgrafi2_total') ?? 0;
    
    disgrafi2Correct += _correctCount;
    disgrafi2Total += _totalQuestions;
    
    await prefs.setInt('disgrafi2_correct', disgrafi2Correct);
    await prefs.setInt('disgrafi2_total', disgrafi2Total);
    
    // Disgrafi kategori toplamını hesapla (disgrafi1 + disgrafi2 + disgrafi3)
    int disgrafi1Correct = prefs.getInt('disgrafi1_correct') ?? 0;
    int disgrafi1Total = prefs.getInt('disgrafi1_total') ?? 0;
    int disgrafi3Correct = prefs.getInt('disgrafi3_correct') ?? 0;
    int disgrafi3Total = prefs.getInt('disgrafi3_total') ?? 0;
    
    int disgrafiTotalCorrect = disgrafi1Correct + disgrafi2Correct + disgrafi3Correct;
    int disgrafiTotal = disgrafi1Total + disgrafi2Total + disgrafi3Total;
    
    await prefs.setInt('disgrafi_correct', disgrafiTotalCorrect);
    await prefs.setInt('disgrafi_total', disgrafiTotal);
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.065;

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
                // 🔙 Geri tuşu
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
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),

                // 📦 İçerik kutusu
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(20),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            isEnglish
                                ? 'Write the sentence below exactly.'
                                : 'Aşağıdaki cümleyi aynen yazınız.',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // 📜 Gösterilen cümle
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isEnglish
                                  ? 'I went to the theater with my family.'
                                  : 'Ailemle birlikte tiyatroya gittik.',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 📝 Cevap yazma alanı
                          TextField(
                            controller: _controller,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: screenSize.width * 0.045,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  isEnglish
                                      ? 'Write the sentence here...'
                                      : 'Cümleyi buraya yazınız...',
                              hintStyle: TextStyle(
                                fontSize: screenSize.width * 0.04,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: EdgeInsets.all(
                                screenSize.width * 0.03,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ✔️ Buton
                          if (!_showFeedback)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ElevatedButton(
                                onPressed: _checkPoem,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48,
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  isEnglish ? 'Check' : 'Kontrol Et',
                                  style: const TextStyle(
                                    fontSize: 20,
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

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child:
                      _showFeedback
                          ? ScaleTransition(
                            scale: CurvedAnimation(
                              parent: _feedbackController,
                              curve: Curves.elasticOut,
                            ),
                            child: Column(
                              children: [
                                Container(
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
                                    children: [
                                      Icon(
                                        _isCorrect
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color:
                                            _isCorrect
                                                ? Colors.green
                                                : Colors.red,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _isCorrect
                                            ? (isEnglish
                                                ? 'Well done! 🎉'
                                                : 'Aferin! 🎉')
                                            : (_attemptCount == 1
                                                ? (isEnglish
                                                    ? 'Try again! 😔'
                                                    : 'Tekrar dene! 😔')
                                                : (isEnglish
                                                    ? 'Here\'s the right one! 🧐'
                                                    : 'İşte doğrusu! 🧐')),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              _isCorrect
                                                  ? Colors.green
                                                  : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                // Doğru cümleyi göster (sadece ikinci deneme yanlışsa)
                                if (!_isCorrect && _attemptCount >= 2) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      'Ailemle birlikte tiyatroya gittik.',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ],
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
}
