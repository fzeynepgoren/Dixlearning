import 'package:flutter/material.dart';
import 'dart:async';
import 'soru5.dart';
import '../utils/activity_tracker.dart';
import '../screens/matching_questions_screen.dart';
import '../screens/home_screen.dart';
import '../widgets/in_game_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Soru4 extends StatefulWidget {
  const Soru4({super.key});

  @override
  State<Soru4> createState() => _Soru4State();
}

class _Soru4State extends State<Soru4> with TickerProviderStateMixin {
  final List<String> leftItems = ['🧹', '✏️', '✂️'];
  late List<String> rightItems;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = [false, false, false];
  List<bool> matchedRight = [false, false, false];
  bool showFeedback = false;
  bool isCorrect = false;
  bool _isSoundOn = true;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    rightItems = List.from(leftItems)..shuffle();
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

  Future<void> _trackWrongAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('asama1_wrong_count') ?? 0;
    wrongCount++;
    await prefs.setInt('asama1_wrong_count', wrongCount);
  }

  void _handleTap(int index, bool isLeft) {
    if (showFeedback) return;
    setState(() {
      if (isLeft) {
        if (matchedLeft[index]) return;
        selectedLeftIndex = index;
      } else {
        if (matchedRight[index]) return;
        selectedRightIndex = index;
      }

      if (selectedLeftIndex != null && selectedRightIndex != null) {
        isCorrect =
            leftItems[selectedLeftIndex!] == rightItems[selectedRightIndex!];
        showFeedback = true;
        _feedbackController.forward(from: 0);

        if (isCorrect) {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;

          if (matchedLeft.every((element) => element)) {
            ActivityTracker.completeActivity();
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HayvanEsle()),
                );
              }
            });
          } else {
            // Feedback'i 2 saniye sonra gizle
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  showFeedback = false;
                  selectedLeftIndex = null;
                  selectedRightIndex = null;
                });
              }
            });
          }
        } else {
          // Yanlış cevap için feedback'i 2 saniye sonra gizle
          _trackWrongAnswer();
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                showFeedback = false;
                selectedLeftIndex = null;
                selectedRightIndex = null;
              });
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.065;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
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
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const MatchingQuestionsScreen(),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                    Expanded(
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
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 1,
                              ),
                              child: const Text(
                                'Doğru okul malzemelerini eşleştir!',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: List.generate(
                                        leftItems.length,
                                        (index) => GestureDetector(
                                          onTap: () => _handleTap(index, true),
                                          child: AnimatedContainer(
                                            duration:
                                                showFeedback
                                                    ? Duration.zero
                                                    : const Duration(
                                                      milliseconds: 300,
                                                    ),
                                            curve: Curves.easeInOut,
                                            width: 120,
                                            height: 120,
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  matchedLeft[index]
                                                      ? Colors.green.shade400
                                                      : (showFeedback &&
                                                          !isCorrect &&
                                                          selectedLeftIndex ==
                                                              index)
                                                      ? Colors.red.shade400
                                                      : (selectedLeftIndex ==
                                                          index)
                                                      ? Colors.blue.shade200
                                                      : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                leftItems[index],
                                                style: const TextStyle(
                                                  fontSize: 48,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // BAŞLANGIÇ: MAVİ GRADYAN ÇİZGİ BÖLÜMÜ (425.0 Yüksekliğe Ayarlandı)
                                  SizedBox(
                                    height:
                                        425.0, // Çizginin uzunluğu (yüksekliği)
                                    child: Container(
                                      width: 4,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.blue.shade400,
                                            Colors.blue.shade200,
                                            Colors.blue.shade100,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),

                                  // SON: MAVİ GRADYAN ÇİZGİ BÖLÜMÜ
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: List.generate(
                                        rightItems.length,
                                        (index) => GestureDetector(
                                          onTap: () => _handleTap(index, false),
                                          child: AnimatedContainer(
                                            duration:
                                                showFeedback
                                                    ? Duration.zero
                                                    : const Duration(
                                                      milliseconds: 300,
                                                    ),
                                            curve: Curves.easeInOut,
                                            width: 120,
                                            height: 120,
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  matchedRight[index]
                                                      ? Colors.green.shade400
                                                      : (showFeedback &&
                                                          !isCorrect &&
                                                          selectedRightIndex ==
                                                              index)
                                                      ? Colors.red.shade400
                                                      : (selectedRightIndex ==
                                                          index)
                                                      ? Colors.blue.shade200
                                                      : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                rightItems[index],
                                                style: const TextStyle(
                                                  fontSize: 48,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                                            isCorrect
                                                ? Colors.green
                                                : Colors.red,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        isCorrect
                                            ? 'Aferin! 🎉'
                                            : 'Tekrar dene! 😔',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              isCorrect
                                                  ? Colors.green
                                                  : Colors.red,
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
            InGameMenu(
              isSoundOn: _isSoundOn,
              onToggleSound: () => setState(() => _isSoundOn = !_isSoundOn),
              onHome: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const MatchingQuestionsScreen(),
                  ),
                  (route) => false,
                );
              },
              onEntryScreen: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              iconSize: iconSize,
            ),
          ],
        ),
      ),
    );
  }
}
