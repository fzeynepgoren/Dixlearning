import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'disgrafi2.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../screens/home_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Disgrafi1 extends StatefulWidget {
  const Disgrafi1({super.key});

  @override
  State<Disgrafi1> createState() => _Disgrafi1State();
}

class _Disgrafi1State extends State<Disgrafi1> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  int _currentQuestionIndex = 0;
  bool _isPlaying = false;
  bool _showFeedback = false;
  bool _isCorrect = false;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _questions = [
    {
      'sentence': ['Doktor', '', 'taksi', ''],
      'answers': ['durakta', 'bekledi'],
      'controllers': [TextEditingController(), TextEditingController()],
    },
    {
      'sentence': ['Baris', '', 'ocakta', ''],
      'answers': ['sutu', 'tasirdi'],
      'controllers': [TextEditingController(), TextEditingController()],
    },
  ];

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
    for (var question in _questions) {
      for (var controller in question['controllers']) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  // TTS ile cümleyi okuma fonksiyonu
  Future<void> _speakFullSentence() async {
    setState(() {
      _isPlaying = true;
    });

    await flutterTts.setLanguage("tr-TR"); // Türkçe
    await flutterTts.setPitch(1.0); // Ses kalınlığı - daha doğal
    await flutterTts.setSpeechRate(0.7); // Konuşma hızı - daha yavaş
    await flutterTts.setVolume(0.9); // Ses seviyesi
    await flutterTts.speak("Doktor durakta taksi bekledi.");

    flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  void _checkAnswers() {
    final current = _questions[_currentQuestionIndex];
    bool allCorrect = true;

    for (int i = 0; i < current['answers'].length; i++) {
      final controller = current['controllers'][i];
      final userAnswer = controller.text.trim().toLowerCase();
      final correctAnswer = current['answers'][i].toLowerCase();

      if (userAnswer != correctAnswer) {
        allCorrect = false;
      }
    }

    setState(() {
      _showFeedback = true;
      _isCorrect = allCorrect;
    });

    _feedbackController.forward();

    // 3 saniye bekle → Disgrafi2'ye geç
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      ActivityTracker.completeActivity();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Disgrafi2()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final current = _questions[_currentQuestionIndex];
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.065;

    return Scaffold(
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
                mainAxisAlignment: MainAxisAlignment.start,
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
              const SizedBox(height: 20),
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // TTS Play Button
                        ElevatedButton.icon(
                          onPressed:
                              _isPlaying
                                  ? null
                                  : () {
                                    _speakFullSentence();
                                  },
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 32,
                          ),
                          label: Text(
                            _isPlaying
                                ? (isEnglish ? 'Playing...' : 'Çalıyor...')
                                : (isEnglish
                                    ? 'Listen Sentence'
                                    : 'Cümleyi Dinle'),
                            style: const TextStyle(fontSize: 20),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade200,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Sentence with blanks
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: () {
                              int blankCounter = 0;
                              return current['sentence'].map<Widget>((word) {
                                if (word == '') {
                                  final controller =
                                      current['controllers'][blankCounter];
                                  blankCounter++;
                                  return Container(
                                    width: 100,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: TextField(
                                      controller: controller,
                                      style: const TextStyle(fontSize: 18),
                                      decoration: InputDecoration(
                                        hintText: isEnglish ? 'Word' : 'Kelime',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Text(
                                      word,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF37474F),
                                      ),
                                    ),
                                  );
                                }
                              }).toList();
                            }(),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Confirm Button
                        if (!_showFeedback)
                          ElevatedButton(
                            onPressed: _checkAnswers,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade200,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              isEnglish ? 'Confirm' : 'Onayla',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Feedback Area
              Container(
                height: 80,
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: _isCorrect ? Colors.green : Colors.red,
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
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _isCorrect
                                      ? (isEnglish
                                          ? 'Well done! 🎉'
                                          : 'Aferin! 🎉')
                                      : (isEnglish
                                          ? 'Here\'s the right one! 🧐\nDoktor durakta taksi bekledi.'
                                          : 'İşte doğrusu! 🧐\nDoktor durakta taksi bekledi.'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
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
    );
  }
}
