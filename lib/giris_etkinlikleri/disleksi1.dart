import 'package:flutter/material.dart';
import 'disleksi2.dart';
import '../main.dart';
import '../screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class Disleksi1 extends StatefulWidget {
  const Disleksi1({super.key});

  @override
  State<Disleksi1> createState() => _Disleksi1State();
}

class _Disleksi1State extends State<Disleksi1> with TickerProviderStateMixin {
  final List<Question> questions = [
    Question(
      emoji: '🕷️',
      incompleteWord: 'örü_cek',
      correctLetter: 'm',
      options: ['m', 'n'],
    ),
    Question(
      emoji: '🌍',
      incompleteWord: 'dü_ya',
      correctLetter: 'n',
      options: ['m', 'n'],
    ),
    Question(
      emoji: '🍽️',
      incompleteWord: 'taba_',
      correctLetter: 'k',
      options: ['k', 't'],
    ),
    Question(
      emoji: '🎫',
      incompleteWord: 'bile_',
      correctLetter: 't',
      options: ['k', 't'],
    ),
  ];

  int currentQuestionIndex = 0;
  bool showFeedback = false;
  bool isCorrect = false;
  String? selectedLetter;

  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void checkAnswer(String letter) {
    setState(() {
      selectedLetter = letter;
      isCorrect = letter == questions[currentQuestionIndex].correctLetter;
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          showFeedback = false;
        });
        if (currentQuestionIndex == questions.length - 1) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple.shade100,
                      Colors.deepPurple.shade50,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 80,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Congratulations! 🎉',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Harika bir iş çıkardınız!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const Disleksi2(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;
                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Next Activity',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          setState(() {
            currentQuestionIndex++;
            selectedLetter = null;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final question = questions[currentQuestionIndex];
    final displayedWord = showFeedback
        ? question.incompleteWord.replaceFirst('_', question.correctLetter)
        : question.incompleteWord.replaceFirst('_', selectedLetter ?? '_');

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE1F5FE),
        appBar: AppBar(
          title: Text(isEnglish
              ? 'Missing Letter Placement'
              : 'Eksik Harf Yerleştirme'),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const HomeScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(-1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
                (route) => false,
              );
            },
          ),
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
              key: ValueKey<int>(currentQuestionIndex),
              children: [
                const SizedBox(height: 12),
                Text(
                  isEnglish
                      ? 'Question ${currentQuestionIndex + 1}/${questions.length}'
                      : 'Soru ${currentQuestionIndex + 1}/${questions.length}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  question.emoji,
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Select the correct letter for the blank below!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                  children: question.options.map((option) {
                    Color? getButtonColor() {
                      if (!showFeedback) return Colors.pinkAccent;
                      if (option == question.correctLetter) return Colors.green;
                      if (selectedLetter == option &&
                          option != question.correctLetter) {
                        return Colors.red;
                      }
                      return Colors.pinkAccent;
                    }

                    return ElevatedButton(
                      onPressed:
                          showFeedback ? null : () => checkAnswer(option),
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
                if (showFeedback)
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _feedbackController,
                      curve: Curves.elasticOut,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                              color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            isCorrect
                                ? 'Well done! 🎉'
                                : 'Sorry, wrong answer! 😔',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Question {
  final String emoji;
  final String incompleteWord;
  final String correctLetter;
  final List<String> options;

  Question({
    required this.emoji,
    required this.incompleteWord,
    required this.correctLetter,
    required this.options,
  });
}
