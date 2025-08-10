import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'dart:math';
import "package:flutter_animate/flutter_animate.dart";
import 'diskalkuli1.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeGame();
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
    print(
        'Game initialized. correctCount: $correctCount, letters.length: ${letters.length}');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    print('Building with correctCount: $correctCount');
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: Text(isEnglish ? 'Letter Matching' : 'Harf Eşleştirme'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade200,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                    child: _buildLetterBubble(letter, dragging: true),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                isEnglish
                    ? 'Drag the colored letters above to the correct gray circles below!'
                    : 'Üstteki renkli harfleri, aşağıdaki gri kutulara doğru şekilde sürükle ve bırak!',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
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
                        print(
                            'Accepting letter: ${receivedLetter.data} for target: $letter');
                        print('Current correctCount: $correctCount');

                        setState(() {
                          lastIncorrect = '';
                          if (letter == receivedLetter.data) {
                            print('Correct match!');
                            correctMatches[letter] = true;
                            letterToColorMap[letter] =
                                colors[letters.indexOf(letter)];
                            correctCount++;
                            print('New correctCount: $correctCount');

                            // Tüm harfler doğru eşleştirildiğinde bir sonraki aktiviteye geç
                            if (correctCount == letters.length) {
                              print(
                                  'All letters matched! Moving to next activity...');
                              Future.delayed(const Duration(milliseconds: 1000),
                                  () {
                                if (mounted) {
                                  // Etkinlik tamamlandı

                                  ActivityTracker.completeActivity();

                                  

                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const Diskalkuli1(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.ease;
                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                }
                              });
                            }
                          } else {
                            print('Incorrect match!');
                            incorrectCount++;
                            lastIncorrect = letter;
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterBubble(String letter, {bool dragging = false}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colors[letters.indexOf(letter)],
        shape: BoxShape.circle,
        boxShadow: dragging
            ? [
                const BoxShadow(
                    color: Colors.black26, blurRadius: 8, offset: Offset(2, 2))
              ]
            : [],
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
