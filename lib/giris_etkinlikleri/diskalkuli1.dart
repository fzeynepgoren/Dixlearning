import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'diskalkuli3.dart';
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
      ['🐟', '🐟', '🐟', '🐟', '🐟']
    ],
    [
      ['🍎', '🍎', '🍎'],
      ['🍎', '🍎']
    ],
    [
      ['🦋', '🦋', '🦋', '🦋'],
      ['🦋', '🦋', '🦋']
    ],
    [
      ['🚗', '🚗', '🚗', '🚗', '🚗'],
      ['🚗', '🚗']
    ],
    [
      ['🌼', '🌼', '🌼', '🌼'],
      ['🌼', '🌼', '🌼', '🌼', '🌼', '🌼']
    ],
  ];

  int currentIndex = 0;
  List<TextEditingController> controllers = [
    TextEditingController(),
    TextEditingController()
  ];
  List<bool?> isCorrect = [null, null];
  bool showFeedback = false;
  bool _dialogShown = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    _slideController.dispose();
    super.dispose();
  }

  void checkAnswers() {
    final current = questions[currentIndex];
    bool isFirstCorrect = int.tryParse(controllers[0].text) == current[0].length;
    bool isSecondCorrect = int.tryParse(controllers[1].text) == current[1].length;

    setState(() {
      isCorrect[0] = isFirstCorrect;
      isCorrect[1] = isSecondCorrect;
      showFeedback = true;
    });

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

  void _nextQuestion() {
    if (!mounted) return;

    // Önce geri bildirim çipini gizle
    setState(() {
      showFeedback = false;
    });

    // Animasyonun tamamlanması için kısa bir gecikme ekle
    Future.delayed(const Duration(milliseconds: 300), () {
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
        ActivityTracker.completeActivity();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Diskalkuli3()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final current = questions[currentIndex];
    final screenSize = MediaQuery.of(context).size;

    // Dinamik ölçüler
    final iconSize = screenSize.width * 0.062;
    final horizontalPadding = screenSize.width * 0.06;
    final verticalPadding = screenSize.height * 0.012;
    final gapSmall = screenSize.height * 0.01;
    final gapMedium = screenSize.height * 0.018;

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
                // Top bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: iconSize,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),

                // Card area
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.02),
                      padding: EdgeInsets.all(screenSize.width * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Başlık
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: verticalPadding * 0.6),
                            child: Text(
                              isEnglish
                                  ? 'Count the objects!'
                                  : 'Nesneleri say ve kutulara yaz!',
                              style: TextStyle(
                                fontSize: screenSize.width * 0.065,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: gapSmall),

                          // İçerik (kaydırılabilir ama sıkı)
                          Flexible(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildEmojiGroup(
                                      current[0], 0, current[0].length, isEnglish),
                                  SizedBox(height: gapMedium),
                                  _buildEmojiGroup(
                                      current[1], 1, current[1].length, isEnglish),
                                  SizedBox(height: gapMedium),

                                  // Buton
                                  ElevatedButton(
                                    onPressed: showFeedback ? null : checkAnswers,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenSize.width * 0.07,
                                        vertical: screenSize.height * 0.015,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      isEnglish ? 'Check' : 'Kontrol Et',
                                      style: TextStyle(
                                        fontSize: screenSize.width * 0.052,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: gapSmall),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Alt feedback strip
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding, vertical: verticalPadding),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: showFeedback ? 1.0 : 0.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          (isCorrect[0] == true && isCorrect[1] == true)
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: (isCorrect[0] == true && isCorrect[1] == true)
                              ? Colors.green
                              : Colors.red,
                          size: screenSize.width * 0.06,
                        ),
                        SizedBox(width: screenSize.width * 0.02),
                        Flexible(
                          child: Text(
                            (isCorrect[0] == true && isCorrect[1] == true)
                                ? (isEnglish ? 'Well done! 🎉' : 'Aferin! 🎉')
                                : (isEnglish ? "Here's the right one! 🧐" : "İşte doğrusu! 🧐"),
                            style: TextStyle(
                              fontSize: screenSize.width * 0.042,
                              color: (isCorrect[0] == true && isCorrect[1] == true)
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiGroup(
      List<String> emojis, int index, int correctCount, bool isEnglish) {
    final screenSize = MediaQuery.of(context).size;

    // Dinamik emoji boyutu
    final emojiSize = math.min(screenSize.width * 0.085, 54.0);
    final spacingH = screenSize.width * 0.02;
    final spacingV = screenSize.height * 0.008;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: spacingH,
          runSpacing: spacingV,
          children: emojis
              .map((e) => Text(
            e,
            style: TextStyle(fontSize: emojiSize),
          ))
              .toList(),
        ),
        SizedBox(height: screenSize.height * 0.012),
        SizedBox(
          width: math.min(screenSize.width * 0.24, 120),
          child: TextField(
            controller: controllers[index],
            enabled: !showFeedback || isCorrect[index] == false,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenSize.width * 0.055,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '?',
              hintStyle: TextStyle(fontSize: screenSize.width * 0.045),
              filled: true,
              fillColor: showFeedback && isCorrect[index] == false
                  ? Colors.red.shade50
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isCorrect[index] == null
                      ? Colors.grey
                      : isCorrect[index]!
                      ? Colors.green
                      : Colors.red,
                  width: 2.6,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isCorrect[index] == null
                      ? Colors.blue
                      : isCorrect[index]!
                      ? Colors.green
                      : Colors.red,
                  width: 2.6,
                ),
              ),
            ),
          ),
        ),

        // Animated Chip
        AnimatedSize(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: showFeedback && isCorrect[index] == false ? 1.0 : 0.0,
            child: Padding(
              padding: EdgeInsets.only(top: screenSize.height * 0.006),
              child: Chip(
                backgroundColor: Colors.green.shade100,
                avatar: Icon(
                  Icons.check,
                  color: Colors.green,
                  size: screenSize.width * 0.045,
                ),
                label: Text(
                  "${isEnglish ? "Correct:" : "Doğrusu:"} $correctCount",
                  style: TextStyle(
                    fontSize: screenSize.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.008),
      ],
    );
  }
}