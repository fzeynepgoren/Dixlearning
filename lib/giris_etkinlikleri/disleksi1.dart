import 'package:flutter/material.dart';
import 'disleksi2.dart';
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

  void checkAnswer(String letter) {
    setState(() {
      selectedLetter = letter;
      isCorrect = letter == questions[currentQuestionIndex].correctLetter;
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (currentQuestionIndex == questions.length - 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Disleksi2()),
          );
        } else {
          setState(() {
            currentQuestionIndex++;
            selectedLetter = null;
            showFeedback = false;
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
    // Feedback sırasında her zaman doğru kelimeyi göster
        ? question.incompleteWord.replaceFirst('_', question.correctLetter)
        : question.incompleteWord;


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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                question.emoji,
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
                              children: question.options.map((option) {
                                Color getButtonColor() {
                                  if (!showFeedback) return Colors.blue.shade200;
                                  if (option == question.correctLetter) return Colors.green.shade500;
                                  if (selectedLetter == option && option != question.correctLetter) {
                                    return Colors.red.shade500;
                                  }
                                  return Colors.blue.shade200;
                                }

                                return ElevatedButton(
                                  onPressed: showFeedback ? null : () => checkAnswer(option),
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
                ),
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  child: showFeedback
                      ? ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _feedbackController,
                      curve: Curves.elasticOut,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            color: isCorrect
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