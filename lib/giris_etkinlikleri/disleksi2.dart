import 'package:flutter/material.dart';
import 'dart:math';
import 'disleksi4.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İlk Harf Bulma Oyunu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Disleksi2(),
    );
  }
}

class Disleksi2 extends StatefulWidget {
  const Disleksi2({super.key});

  @override
  _Disleksi2State createState() => _Disleksi2State();
}

class _Disleksi2State extends State<Disleksi2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Kelime ve emoji verileri
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
  bool _gameOver = false;
  int correctAnswers = 0;
  int totalQuestions = 0;
  String? selectedOption;
  int currentQuestionNumber = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    startNewGame();
  }

  void startNewGame() {
    setState(() {
      remainingWords = List.from(wordData);
      totalQuestions = wordData.length;
      correctAnswers = 0;
      _gameOver = false;
      currentQuestionNumber = 1;
      getNextWord(isFirst: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void getNextWord({bool isFirst = false}) {
    setState(() {
      if (remainingWords.isEmpty) {
        isAnswered = true;
        isCorrect = true;
        selectedOption = null;
        currentQuestionNumber = totalQuestions;
        return;
      }
      int randomIndex = Random().nextInt(remainingWords.length);
      currentWordData = remainingWords[randomIndex];
      // Randomize the options order
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
      if (isCorrect) {
        correctAnswers++;
        _controller.forward().then((_) => _controller.reverse());
      }
    });

    if (remainingWords.isNotEmpty) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          getNextWord();
        }
      });
    } else {
      // Oyun bittiğinde Disleksi4'e geç
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Disleksi4(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final displayedWord = isAnswered
        ? currentWordData["word"]!
        : "_${currentWordData["word"]!.substring(1)}";
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title:
            Text(isEnglish ? 'First Letter Placement' : 'İlk Harf Yerleştirme'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
          child: Column(
            key: ValueKey<int>(currentQuestionNumber),
            children: [
              const SizedBox(height: 12),
              Text(
                isEnglish
                    ? 'Question ${currentQuestionNumber > totalQuestions ? totalQuestions : currentQuestionNumber}/$totalQuestions'
                    : 'Soru ${currentQuestionNumber > totalQuestions ? totalQuestions : currentQuestionNumber}/$totalQuestions',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                currentWordData["emoji"]!,
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 12),
              Text(
                isEnglish
                    ? 'Select the correct letter for the blank below!'
                    : 'Aşağıdaki boşluğa gelecek doğru harfi seç!',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
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
                  Color? getButtonColor() {
                    if (!isAnswered) return Colors.pinkAccent;
                    if (option == currentWordData["word"]![0]) {
                      return Colors.green;
                    }
                    if (selectedOption == option &&
                        option != currentWordData["word"]![0]) {
                      return Colors.red;
                    }
                    return Colors.pinkAccent;
                  }

                  return ElevatedButton(
                    onPressed: isAnswered ? null : () => checkAnswer(option),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 24),
                      backgroundColor: getButtonColor(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      option,
                      style: const TextStyle(
                          fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              if (isAnswered)
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: isCorrect
                      ? Column(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 70),
                            const SizedBox(height: 8),
                            Text(isEnglish ? 'Well done! 🎉' : 'Aferin! 🎉',
                                style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                          ],
                        )
                      : Column(
                          children: [
                            const Icon(Icons.cancel,
                                color: Colors.red, size: 70),
                            const SizedBox(height: 8),
                            Text(
                                isEnglish
                                    ? 'Sorry, wrong answer! ��'
                                    : 'Üzgünüm yanlış cevap! 😔',
                                style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
