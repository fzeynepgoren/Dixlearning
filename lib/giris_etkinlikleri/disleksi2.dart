import 'package:flutter/material.dart';
import 'dart:math';
import 'disleksi4.dart';
import '../screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class Disleksi2 extends StatefulWidget {
  const Disleksi2({super.key});

  @override
  _Disleksi2State createState() => _Disleksi2State();
}

class _Disleksi2State extends State<Disleksi2>
    with SingleTickerProviderStateMixin {
  late AnimationController _feedbackController;

  final List<Map<String, dynamic>> wordData = [
    {
      "word": "balık",
      "emoji": "🐟",
      "options": ["b", "p"]
    },
    {
      "word": "pasta",
      "emoji": "🎂",
      "options": ["p", "b"]
    },
    {
      "word": "şemsiye",
      "emoji": "☂️",
      "options": ["ş", "s"]
    },
    {
      "word": "şeker",
      "emoji": "🍬",
      "options": ["ş", "s"]
    },
    {
      "word": "uçak",
      "emoji": "✈️",
      "options": ["u", "ü"]
    },
    {
      "word": "tavşan",
      "emoji": "🐰",
      "options": ["t", "f"]
    },
    {
      "word": "ceket",
      "emoji": "🧥",
      "options": ["c", "ç"]
    },
  ];

  List<Map<String, dynamic>> remainingWords = [];
  late Map<String, dynamic> currentWordData;
  bool isCorrect = false;
  bool isAnswered = false;
  String? selectedOption;
  int currentQuestionNumber = 1;
  int totalQuestions = 0;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    startNewGame();
  }

  void startNewGame() {
    setState(() {
      remainingWords = List.from(wordData);
      totalQuestions = wordData.length;
      currentQuestionNumber = 1;
      getNextWord(isFirst: true);
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void getNextWord({bool isFirst = false}) {
    setState(() {
      if (remainingWords.isEmpty) {
        // Son kelime ise ve cevaplanmışsa navigasyon Disleksi4'e yönlendirilir
        return;
      }
      int randomIndex = Random().nextInt(remainingWords.length);
      currentWordData = remainingWords[randomIndex];
      List<String> shuffledOptions = List.from(currentWordData["options"]);
      shuffledOptions.shuffle();
      currentWordData["options"] = shuffledOptions;
      remainingWords.removeAt(randomIndex);
      isAnswered = false;
      isCorrect = false;
      selectedOption = null;
      if (!isFirst && currentQuestionNumber < totalQuestions) {
        currentQuestionNumber++;
      }
    });
  }

  void checkAnswer(String option) {
    setState(() {
      selectedOption = option;
      isAnswered = true;
      isCorrect = option == currentWordData["word"]![0];
    });

    _feedbackController.forward(from: 0);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (remainingWords.isNotEmpty) {
          getNextWord();
        } else {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
              const Disleksi4(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final displayedWord = isAnswered
        ? currentWordData["word"]!
        : "_${currentWordData["word"]!.substring(1)}";

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black, size: iconSize),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
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
                  child: Container(
                    key: ValueKey<int>(currentQuestionNumber),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            currentWordData["emoji"]!,
                            style: const TextStyle(fontSize: 80),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            isEnglish
                                ? 'Select the correct letter for the blank below!'
                                : 'Aşağıdaki boşluğa doğru harfi seçin!',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          displayedWord,
                          style: const TextStyle(
                            fontSize: 44,
                            letterSpacing: 2,
                            color: Color(0xFF37474F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: currentWordData["options"].map<Widget>((option) {
                            Color getButtonColor() {
                              if (!isAnswered) return Colors.blue.shade200;
                              if (option == currentWordData["word"]![0]) {
                                return Colors.green.shade500;
                              }
                              if (selectedOption == option && option != currentWordData["word"]![0]) {
                                return Colors.red.shade500;
                              }
                              return Colors.blue.shade200;
                            }

                            return ElevatedButton(
                              onPressed: isAnswered ? null : () => checkAnswer(option),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                                backgroundColor: getButtonColor(),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Text(
                                option,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: isAnswered
                    ? ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _feedbackController,
                    curve: Curves.elasticOut,
                  ),
                  child: Row(
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
                            ? (isEnglish ? 'Well done! 🎉' : 'Aferin! 🎉')
                            : (isEnglish ? "Here's the right one! 🧐" : 'İşte doğrusu! 🧐'),
                        style: TextStyle(
                          fontSize: 18,
                          color: isCorrect ? Colors.green : Colors.red,
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
    );
  }
}