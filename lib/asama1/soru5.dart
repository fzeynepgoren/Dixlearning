import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/matching_questions_screen.dart'; // Ana menü ekranının yolu
import '../screens/home_screen.dart';
import '../widgets/in_game_menu.dart';

class HayvanEsle extends StatefulWidget {
  const HayvanEsle({super.key});

  @override
  State<HayvanEsle> createState() => _HayvanEsleState();
}

class _HayvanEsleState extends State<HayvanEsle> with TickerProviderStateMixin {
  final List<String> leftAnimals = ['🦜', '🐠', '🐢'];
  late List<String> rightAnimals;
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
    rightAnimals = List.from(leftAnimals)..shuffle();
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

  Future<void> _saveStageCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('asama1_completed', true);
  }

  Future<void> _saveQuestionResult(bool isCorrect) async {
    final prefs = await SharedPreferences.getInstance();
    int correctCount = prefs.getInt('esleme1_session_correct_count') ?? 0;
    int wrongCount = prefs.getInt('esleme1_session_wrong_count') ?? 0;

    if (isCorrect) {
      correctCount++;
    } else {
      wrongCount++;
    }

    await prefs.setInt('esleme1_session_correct_count', correctCount);
    await prefs.setInt('esleme1_session_wrong_count', wrongCount);
  }

  Future<void> _finalizeStars() async {
    final prefs = await SharedPreferences.getInstance();
    int correctCount = prefs.getInt('esleme1_session_correct_count') ?? 0;
    int wrongCount = prefs.getInt('esleme1_session_wrong_count') ?? 0;

    if (correctCount + wrongCount == 5) {
      double accuracy = correctCount / 5;
      int stars = 0;

      if (accuracy == 1.0) {
        stars = 3;
      } else if (accuracy >= 0.6) {
        stars = 2;
      } else if (accuracy >= 0.4) {
        stars = 1;
      }

      await prefs.setInt('esleme1_stars', stars);
    }
  }

  void _handleTap(int index, bool isLeft) async {
    if (showFeedback) return;

    // Seçim işlemini yap
    setState(() {
      if (isLeft) {
        if (matchedLeft[index]) return;
        selectedLeftIndex = index;
      } else {
        if (matchedRight[index]) return;
        selectedRightIndex = index;
      }
    });

    // Eşleşme kontrolü
    if (selectedLeftIndex != null && selectedRightIndex != null) {
      final isCorrectValue =
          leftAnimals[selectedLeftIndex!] == rightAnimals[selectedRightIndex!];

      setState(() {
        isCorrect = isCorrectValue;
        showFeedback = true;
      });

      _feedbackController.forward(from: 0);

      // Doğruluk sonucunu kaydet
      await _saveQuestionResult(isCorrectValue);

      if (isCorrectValue) {
        setState(() {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;
        });

        if (matchedLeft.every((element) => element)) {
          await _saveStageCompletion();
          await _finalizeStars();
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) => Dialog(
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
                            colors: [Colors.blue.shade100, Colors.blue.shade50],
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
                              'Tebrikler! 🎉',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '1. aşamayı tamamladınız!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const MatchingQuestionsScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade200,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Ana Menüye Dön',
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
            }
          });
        } else {
          // Tüm eşleşmeler bitmediyse, feedback'i kısa süre sonra kapatıp seçimleri sıfırla
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

      // Feedback'i 2 saniye sonra gizle (doğru cevap için)
      if (isCorrectValue && matchedLeft.every((element) => !element)) {
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
  }

  Widget buildItem({
    required String emoji,
    required bool isSelected,
    required bool isMatched,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:
            showFeedback ? Duration.zero : const Duration(milliseconds: 300),
        width: 120,
        height: 120,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color:
              isMatched
                  ? Colors.green.shade400
                  : (showFeedback && !isCorrect && isSelected)
                  ? Colors.red.shade400
                  : isSelected
                  ? Colors.blue.shade200
                  : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 48))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.065;

    return Scaffold(
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
                  const SizedBox(height: 10),
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
                              'Sevimli hayvanları eşleştirin!',
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
                                      leftAnimals.length,
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
                                                        selectedLeftIndex ==
                                                            index &&
                                                        !isCorrect)
                                                    ? Colors.red.shade400
                                                    : (selectedLeftIndex ==
                                                        index)
                                                    ? Colors.blue.shade200
                                                    : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              leftAnimals[index],
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
                                      rightAnimals.length,
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
                                                        selectedRightIndex ==
                                                            index &&
                                                        !isCorrect)
                                                    ? Colors.red.shade400
                                                    : (selectedRightIndex ==
                                                        index)
                                                    ? Colors.blue.shade200
                                                    : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              rightAnimals[index],
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
                                          isCorrect ? Colors.green : Colors.red,
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
    );
  }
}
