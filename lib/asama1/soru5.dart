import 'package:flutter/material.dart';
import 'dart:async';
import '../screens/home_screen.dart'; // Ana menü ekranının yolu

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

  void _handleTap(int index, bool isLeft) {
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
            leftAnimals[selectedLeftIndex!] ==
            rightAnimals[selectedRightIndex!];
        showFeedback = true;
        _feedbackController.forward(from: 0);

        if (isCorrect) {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;

          if (matchedLeft.every((element) => element)) {
            Future.delayed(const Duration(seconds: 1), () {
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
                              colors: [
                                Colors.blue.shade100,
                                Colors.blue.shade50,
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
                                      builder: (context) => const HomeScreen(),
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
          }
        }

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              showFeedback = false;
              selectedLeftIndex = null;
              selectedRightIndex = null;
            });
          }
        });
      }
    });
  }

  Widget buildItem({
    required String emoji,
    required bool isSelected,
    required bool isMatched,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color:
              isMatched
                  ? Colors.green.shade300
                  : (showFeedback && !isCorrect && isSelected)
                  ? Colors.red.shade200
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
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 42))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                                        duration: const Duration(
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
                                                  : (selectedLeftIndex == index)
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
                              Container(
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
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(
                                    rightAnimals.length,
                                    (index) => GestureDetector(
                                      onTap: () => _handleTap(index, false),
                                      child: AnimatedContainer(
                                        duration: const Duration(
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
}
