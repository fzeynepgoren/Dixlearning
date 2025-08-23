import 'package:flutter/material.dart';
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
    });

    _feedbackController.forward(from: 0);

    if (isAnswerCorrect) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        ActivityTracker.completeActivity();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HeceDoldurma()),
        );
      });
    } else {
      // İstersen feedback’in ekranda kalma süresini kısaca sınırlayabilirsin:
      // Future.delayed(const Duration(seconds: 2), () {
      //   if (!mounted) return;
      //   setState(() => _showFeedback = false);
      // });
    }
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
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: isEnglish
                                  ? 'Write the sentence here...'
                                  : 'Cümleyi buraya yazınız...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ✔️ Buton
                          ElevatedButton(
                            onPressed: _checkPoem,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade200,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 48, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              isEnglish ? 'Check' : 'Kontrol Et',
                              style: const TextStyle(fontSize: 20),
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
                      horizontal: 20, vertical: 10),
                  child: _showFeedback
                      ? ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _feedbackController,
                      curve: Curves.elasticOut,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isCorrect
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _isCorrect
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
                              : (isEnglish
                              ? 'Try again! 😔'
                              : 'Tekrar dene! 😔'),
                          style: TextStyle(
                            fontSize: 18,
                            color: _isCorrect
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
