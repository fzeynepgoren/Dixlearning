import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../utils/activity_tracker.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class HeceDoldurma extends StatefulWidget {
  const HeceDoldurma({super.key});

  @override
  State<HeceDoldurma> createState() => _HeceDoldurmaState();
}

class _HeceDoldurmaState extends State<HeceDoldurma>
    with TickerProviderStateMixin {
  final List<Map<String, String>> items = [
    {'emoji': '🖊️', 'prefix': 'ka', 'answer': 'lem'}, // ka___
    {
      'emoji': '🪑',
      'prefix': 'san',
      'suffix': 'ye',
      'answer': 'dal',
    }, // san___ye
    {'emoji': '💻', 'suffix': 'gisayar', 'answer': 'bil'}, // ___gisayar
    {'emoji': '🍳', 'prefix': 'ta', 'answer': 'va'}, // ta___
    {'emoji': '🔨', 'suffix': 'kiç', 'answer': 'çe'}, // ___kiç
    {'emoji': '🥛', 'prefix': 'bar', 'answer': 'dak'}, // bar___
  ];

  final List<String> commonLetters = [
    'a',
    'k',
    'n',
    'r',
    'e',
    't',
    's',
    'u',
    'o',
    'i',
    'm',
    'l',
    'd',
    'b',
    'y',
    'z',
    'v',
    'ç',
    'ş',
    'ğ',
    'ü',
    'ö',
    'c',
    'p',
    'h',
    'f',
    'j',
    'g',
  ];

  int currentIndex = 0;
  List<List<String?>> userInputs = [];
  bool isCorrect = false;
  bool isWrong = false;
  bool showFeedback = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    userInputs = List.generate(
      items.length,
      (i) => List.filled(items[i]['answer']!.length, null),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 16,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

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
    _shakeController.dispose();
    _feedbackController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void checkAnswer() async {
    String userAnswer = userInputs[currentIndex].join();
    bool answerIsCorrect = userAnswer == items[currentIndex]['answer'];
    setState(() {
      isCorrect = answerIsCorrect;
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (currentIndex < items.length - 1) {
          setState(() {
            currentIndex++;
            showFeedback = false;
            userInputs[currentIndex] = List.filled(
              items[currentIndex]['answer']!.length,
              null,
            );
          });
        } else {
          print('Disgrafi3 tamamlandı, bir sonraki aktiviteye geçiliyor');
          // Etkinlik tamamlandı
          ActivityTracker.completeActivity();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    });
  }

  void clearInput(int i) {
    setState(() {
      userInputs[currentIndex][i] = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final item = items[currentIndex];
    final answer = item['answer']!;
    final userInput = userInputs[currentIndex];
    String prefix = item['prefix'] ?? '';
    String suffix = item['suffix'] ?? '';

    // Doğru cevabın harfleri
    List<String> answerLetters = answer.split('');
    // Karıştırıcı harfler
    List<String> distractors = [];
    final rand = Random();
    while (distractors.length < 5 - answerLetters.length) {
      String letter = commonLetters[rand.nextInt(commonLetters.length)];
      if (!answerLetters.contains(letter) && !distractors.contains(letter)) {
        distractors.add(letter);
      }
    }
    // Tüm harfler (doğru + karıştırıcı), karışık sırada
    List<String> allLetters = [...answerLetters, ...distractors];
    allLetters.shuffle();

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
                                item['emoji']!,
                                style: const TextStyle(fontSize: 80),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Text(
                                isEnglish
                                    ? 'Drag the missing letters to the blanks!'
                                    : 'Eksik harfleri sürükleyerek boşlukları doldur!',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Soru metni (prefix + kutular + suffix)
                            AnimatedBuilder(
                              animation: _shakeController,
                              builder: (context, child) {
                                double offset =
                                    isWrong ? _shakeAnimation.value : 0;
                                return Transform.translate(
                                  offset: Offset(
                                    offset * (Random().nextBool() ? 1 : -1),
                                    0,
                                  ),
                                  child: child,
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (prefix.isNotEmpty)
                                    Text(
                                      prefix,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ...List.generate(answer.length, (i) {
                                    // Geri bildirim sırasında doğru cevabı göster
                                    String displayLetter =
                                        showFeedback && !isCorrect
                                            ? answer[i]
                                            : (userInput[i] ?? '');
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: DragTarget<String>(
                                        onAcceptWithDetails:
                                            showFeedback
                                                ? null
                                                : (details) {
                                                  setState(() {
                                                    userInput[i] = details.data;
                                                  });
                                                },
                                        builder: (
                                          context,
                                          candidateData,
                                          rejectedData,
                                        ) {
                                          return GestureDetector(
                                            onLongPress:
                                                userInput[i] != null &&
                                                        !showFeedback
                                                    ? () => clearInput(i)
                                                    : null,
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              width: 60,
                                              height: 60,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color:
                                                    showFeedback && !isCorrect
                                                        ? Colors.red
                                                            .withOpacity(0.7)
                                                        : (showFeedback &&
                                                                isCorrect
                                                            ? Colors.green
                                                            : (candidateData
                                                                    .isNotEmpty
                                                                ? Colors
                                                                    .yellow[200]
                                                                : Colors.blue
                                                                    .withOpacity(
                                                                      0.5,
                                                                    ))),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color:
                                                      showFeedback && !isCorrect
                                                          ? Colors.red
                                                          : (showFeedback &&
                                                                  isCorrect
                                                              ? Colors.green
                                                              : Colors
                                                                  .blueAccent),
                                                  width: 3,
                                                ),
                                                boxShadow: [
                                                  if (candidateData.isNotEmpty)
                                                    const BoxShadow(
                                                      color: Colors.amber,
                                                      blurRadius: 12,
                                                      spreadRadius: 2,
                                                    ),
                                                ],
                                              ),
                                              child: Text(
                                                displayLetter,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }),
                                  if (suffix.isNotEmpty)
                                    Text(
                                      suffix,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),
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
                                onPressed: showFeedback ? null : checkAnswer,
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
                                child: const Text(
                                  'Kontrol Et',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Sürüklenebilir harf kutuları
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 12,
                              children:
                                  allLetters.map((letter) {
                                    return Draggable<String>(
                                      data: letter,
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: _buildLetterBox(
                                          letter,
                                          dragging: true,
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.3,
                                        child: _buildLetterBox(letter),
                                      ),
                                      child: _buildLetterBox(letter),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
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
                                            ? "Here's the right one! 🧐"
                                            : 'İşte doğrusu! 🧐'),
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
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLetterBox(String letter, {bool dragging = false}) {
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient:
            dragging
                ? LinearGradient(
                  colors: [Colors.blue.shade300, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : LinearGradient(
                  colors: [Colors.blue.shade200, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
