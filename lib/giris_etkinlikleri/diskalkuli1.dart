import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/activity_tracker.dart';
import 'diskalkuli2.dart';
import '../screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class Diskalkuli1 extends StatefulWidget {
  const Diskalkuli1({super.key});

  @override
  State<Diskalkuli1> createState() => _Diskalkuli1State();
}

class _Diskalkuli1State extends State<Diskalkuli1>
    with TickerProviderStateMixin {
  final List<List<List<String>>> questions = [
    [
      ['🐟', '🐟'],
      ['🐟', '🐟', '🐟', '🐟', '🐟'],
    ],
    [
      ['🍎', '🍎', '🍎'],
      ['🍎', '🍎'],
    ],
    [
      ['🦋', '🦋', '🦋', '🦋'],
      ['🦋', '🦋', '🦋'],
    ],
    [
      ['🚗', '🚗', '🚗', '🚗', '🚗'],
      ['🚗', '🚗'],
    ],
    [
      ['🌼', '🌼', '🌼', '🌼'],
      ['🌼', '🌼', '🌼', '🌼', '🌼', '🌼'],
    ],
  ];

  int currentIndex = 0;
  List<TextEditingController> controllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  List<bool?> isCorrect = [null, null];
  bool showFeedback = false;
  bool _dialogShown = false;
  int correctCount = 0;
  int totalQuestions = 0;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    // Her soru için 2 kutu var, toplam soru sayısı = soru sayısı x 2
    totalQuestions = questions.length * 2;
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
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    _slideController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void checkAnswers() {
    final current = questions[currentIndex];
    bool isFirstCorrect =
        int.tryParse(controllers[0].text) == current[0].length;
    bool isSecondCorrect =
        int.tryParse(controllers[1].text) == current[1].length;

    setState(() {
      isCorrect[0] = isFirstCorrect;
      isCorrect[1] = isSecondCorrect;
      showFeedback = true;
      // Her doğru kutu için correctCount artırılmalı
      if (isFirstCorrect) {
        correctCount++;
      }
      if (isSecondCorrect) {
        correctCount++;
      }
    });

    _feedbackController.forward(from: 0);

    if (isCorrect[0] == true && isCorrect[1] == true) {
      Future.delayed(const Duration(milliseconds: 900), () {
        _nextQuestion();
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        _nextQuestion();
      });
    }
  }

  void _nextQuestion() async {
    if (!mounted) return;

    // Önce geri bildirim çipini gizle
    setState(() {
      showFeedback = false;
    });

    Future.delayed(const Duration(milliseconds: 800), () async {
      if (!mounted) return;

      if (currentIndex < questions.length - 1) {
        setState(() {
          currentIndex++;
          controllers[0].clear();
          controllers[1].clear();
          isCorrect = [null, null];
        });
        _slideController.forward(from: 0.0);
      } else if (!_dialogShown) {
        _dialogShown = true;
        // Diskalkuli1 tamamlandı - başarı yüzdesini kaydet
        await _saveDiskalkuliProgress();
        ActivityTracker.completeActivity();
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => const Diskalkuli2(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      }
    });
  }

  Future<void> _saveDiskalkuliProgress() async {
    final prefs = await SharedPreferences.getInstance();
    // Diskalkuli1 için doğru ve toplam sayıları kaydet
    int diskalkuli1Correct = prefs.getInt('diskalkuli1_correct') ?? 0;
    int diskalkuli1Total = prefs.getInt('diskalkuli1_total') ?? 0;
    
    diskalkuli1Correct += correctCount;
    diskalkuli1Total += totalQuestions;
    
    await prefs.setInt('diskalkuli1_correct', diskalkuli1Correct);
    await prefs.setInt('diskalkuli1_total', diskalkuli1Total);
    
    // Diskalkuli kategori toplamını hesapla (diskalkuli1 + diskalkuli2 + diskalkuli3)
    int diskalkuli2Correct = prefs.getInt('diskalkuli2_correct') ?? 0;
    int diskalkuli2Total = prefs.getInt('diskalkuli2_total') ?? 0;
    int diskalkuli3Correct = prefs.getInt('diskalkuli3_correct') ?? 0;
    int diskalkuli3Total = prefs.getInt('diskalkuli3_total') ?? 0;
    
    int diskalkuliTotalCorrect = diskalkuli1Correct + diskalkuli2Correct + diskalkuli3Correct;
    int diskalkuliTotal = diskalkuli1Total + diskalkuli2Total + diskalkuli3Total;
    
    await prefs.setInt('diskalkuli_correct', diskalkuliTotalCorrect);
    await prefs.setInt('diskalkuli_total', diskalkuliTotal);
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final current = questions[currentIndex];
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
                      child: SingleChildScrollView(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (
                            Widget child,
                            Animation<double> animation,
                          ) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            key: ValueKey<int>(currentIndex),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  isEnglish
                                      ? 'Count the objects!'
                                      : 'Nesneleri say ve kutulara yaz!',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildEmojiGroup(
                                current[0],
                                0,
                                current[0].length,
                                isEnglish,
                              ),
                              const SizedBox(height: 20),
                              _buildEmojiGroup(
                                current[1],
                                1,
                                current[1].length,
                                isEnglish,
                              ),
                              const SizedBox(height: 24),
                              // Kontrol Et butonu
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
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: ElevatedButton(
                                  onPressed: showFeedback ? null : checkAnswers,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: Text(
                                    isEnglish ? 'Check' : 'Kontrol Et',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Alt feedback strip
                Container(
                  constraints: const BoxConstraints(maxHeight: 80),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
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
                                children: [
                                  Icon(
                                    (isCorrect[0] == true &&
                                            isCorrect[1] == true)
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color:
                                        (isCorrect[0] == true &&
                                                isCorrect[1] == true)
                                            ? Colors.green
                                            : Colors.red,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      (isCorrect[0] == true &&
                                              isCorrect[1] == true)
                                          ? (isEnglish
                                              ? 'Well done! 🎉'
                                              : 'Aferin! 🎉')
                                          : (isEnglish
                                              ? "Try again! 😔"
                                              : "Tekrar dene! 😔"),
                                      style: TextStyle(
                                        fontSize: 18,
                                        color:
                                            (isCorrect[0] == true &&
                                                    isCorrect[1] == true)
                                                ? Colors.green
                                                : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
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

  Widget _buildEmojiGroup(
    List<String> emojis,
    int index,
    int correctCount,
    bool isEnglish,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final emojiSize = screenSize.width * 0.12;
    final inputWidth = screenSize.width * 0.2;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: screenSize.width * 0.02,
          runSpacing: screenSize.width * 0.02,
          children:
              emojis
                  .map((e) => Text(e, style: TextStyle(fontSize: emojiSize)))
                  .toList(),
        ),
        SizedBox(height: screenSize.height * 0.015),
        SizedBox(
          width: inputWidth,
          child: TextField(
            controller: controllers[index],
            enabled: !showFeedback,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenSize.width * 0.06,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '?',
              hintStyle: TextStyle(fontSize: screenSize.width * 0.05),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      !showFeedback
                          ? Colors.grey
                          : (isCorrect[index] == true)
                          ? Colors.green
                          : Colors.red,
                  width: 2.6,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      !showFeedback
                          ? Colors.blue
                          : (isCorrect[index] == true)
                          ? Colors.green
                          : Colors.red,
                  width: 2.6,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        ),

        // Animated Chip - her cevap için ayrı feedback
        AnimatedSize(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: showFeedback ? 1.0 : 0.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Chip(
                backgroundColor:
                    isCorrect[index] == true
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                avatar: Icon(
                  isCorrect[index] == true ? Icons.check : Icons.close,
                  color: isCorrect[index] == true ? Colors.green : Colors.red,
                  size: 18,
                ),
                label: Text(
                  isCorrect[index] == true
                      ? (isEnglish ? "Correct!" : "Doğru!")
                      : "${isEnglish ? "Correct:" : "Doğrusu:"} $correctCount",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCorrect[index] == true ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
      ],
    );
  }
}
