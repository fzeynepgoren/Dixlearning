import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'dart:math';
import "package:flutter_animate/flutter_animate.dart";
import 'diskalkuli1.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../screens/home_screen.dart';

class Disleksi4 extends StatefulWidget {
  const Disleksi4({super.key});

  @override
  State<Disleksi4> createState() => _Disleksi4State();
}

class _Disleksi4State extends State<Disleksi4> with TickerProviderStateMixin {
  final List<Color> colors = [
    Colors.red,
    Colors.yellow,
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.orange
  ];
  final List<String> letters = ['d', 'b', 'm', 'n', 'u', 'ö'];
  final Map<String, Color> letterToColorMap = {};
  final Map<String, bool> correctMatches = {};
  int correctCount = 0;
  int incorrectCount = 0;

  List<String> shuffledLetters = [];
  String lastIncorrect = '';
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();

    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    shuffledLetters = List.from(letters)..shuffle(Random());
    correctMatches.clear();
    letterToColorMap.clear();
    correctCount = 0;
    incorrectCount = 0;
    lastIncorrect = '';
    for (int i = 0; i < letters.length; i++) {
      letterToColorMap[letters[i]] = Colors.transparent;
      correctMatches[letters[i]] = false;
    }
    setState(() {});
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
                Colors.deepPurple.shade200,
                Colors.deepPurple.shade100,
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
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.all(16),
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
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            child: Text(
                              isEnglish
                                  ? 'Drag the colored letters above to the correct gray circles below!'
                                  : 'Üstteki harfi aşağıdaki aynı harfe sürükle!',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 16,
                            runSpacing: 16,
                            children: letters.map((letter) {
                              return Draggable<String>(
                                data: letter,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: _buildLetterBubble(letter,
                                      dragging: true),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: correctMatches[letter]! ? 0.0 : 0.4,
                                  child: _buildLetterBubble(letter),
                                ),
                                child: correctMatches[letter]!
                                    ? Opacity(
                                  opacity: 0.0,
                                  child: _buildLetterBubble(letter),
                                )
                                    : _buildLetterBubble(letter),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 30),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
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
                              child: GridView.count(
                                key: ValueKey<int>(correctCount),
                                crossAxisCount: 3,
                                mainAxisSpacing: 24,
                                crossAxisSpacing: 24,
                                padding: const EdgeInsets.all(20),
                                children: shuffledLetters.map((letter) {
                                  final isLastIncorrect = letter == lastIncorrect;
                                  return DragTarget<String>(
                                    onWillAcceptWithDetails: (receivedLetter) =>
                                    !correctMatches[letter]!,
                                    onAcceptWithDetails: (receivedLetter) {
                                      setState(() {
                                        lastIncorrect = '';
                                        if (letter == receivedLetter.data) {
                                          correctMatches[letter] = true;
                                          letterToColorMap[letter] =
                                          colors[letters.indexOf(letter)];
                                          correctCount++;
                                          isCorrect = true;
                                        } else {
                                          incorrectCount++;
                                          lastIncorrect = letter;
                                          isCorrect = false;
                                        }

                                        showFeedback = true;
                                        _feedbackController.forward(from: 0);

                                        Future.delayed(const Duration(seconds: 2), () {
                                          if (mounted) {
                                            setState(() {
                                              showFeedback = false;
                                            });
                                          }
                                        });

                                        if (correctCount == letters.length) {
                                          Future.delayed(
                                              const Duration(milliseconds: 1000),
                                                  () {
                                                if (mounted) {
                                                  ActivityTracker.completeActivity();

                                                  Navigator.pushReplacement(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder: (context,
                                                          animation,
                                                          secondaryAnimation) =>
                                                      const Diskalkuli1(),
                                                      transitionsBuilder: (context,
                                                          animation,
                                                          secondaryAnimation,
                                                          child) {
                                                        const begin =
                                                        Offset(1.0, 0.0);
                                                        const end = Offset.zero;
                                                        const curve =
                                                            Curves.ease;
                                                        var tween = Tween(
                                                            begin: begin,
                                                            end: end)
                                                            .chain(CurveTween(
                                                            curve: curve));
                                                        return SlideTransition(
                                                          position:
                                                          animation.drive(tween),
                                                          child: child,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                }
                                              });
                                        }
                                      });
                                    },
                                    builder: (context, accepted, rejected) {
                                      final target = AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        decoration: BoxDecoration(
                                          color: correctMatches[letter]!
                                              ? colors[letters.indexOf(letter)]
                                              : Colors.grey.shade200,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.black26),
                                          boxShadow: correctMatches[letter]!
                                              ? [
                                            BoxShadow(
                                              color: colors[letters.indexOf(letter)]
                                                  .withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                              : [],
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          letter,
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: correctMatches[letter]!
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      );

                                      if (correctMatches[letter]!) {
                                        return target.animate().scale(duration: 500.ms);
                                      } else if (isLastIncorrect) {
                                        return target.animate().shake(duration: 900.ms);
                                      } else {
                                        return target;
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? Colors.green : Colors.red,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isCorrect
                              ? (isEnglish
                              ? 'Well done! 🎉'
                              : 'Aferin! 🎉')
                              : (isEnglish
                              ? 'Try again! 😔'
                              : 'Tekrar dene! 😔'),
                          style: TextStyle(
                            fontSize: 20,
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
      ),
    );
  }

  Widget _buildLetterBubble(String letter, {bool dragging = false}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: colors[letters.indexOf(letter)],
        shape: BoxShape.circle,
        boxShadow: dragging
            ? [
          BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: const Offset(4, 4))
        ]
            : [],
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}