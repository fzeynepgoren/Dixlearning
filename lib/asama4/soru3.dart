import 'package:flutter/material.dart';
import 'soru4.dart';

class Soru3 extends StatefulWidget {
  const Soru3({super.key});

  @override
  State<Soru3> createState() => _Soru3State();
}

class _Soru3State extends State<Soru3> with TickerProviderStateMixin {
  final List<String> leftItems = ['🍎', '🍕', '🍦', '🥕'];
  final List<String> rightItems = [
    'Meyve',
    'Sebze',
    'Tatlı',
    'Fast Food',
  ];
  late List<String> shuffledRightItems;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = [false, false, false, false];
  List<bool> matchedRight = [false, false, false, false];
  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    shuffledRightItems = List.from(rightItems)..shuffle();
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

  void checkMatch(int leftIndex, int rightIndex) {
    setState(() {
      if (matchedLeft[leftIndex] || matchedRight[rightIndex]) return;

      selectedLeftIndex = leftIndex;
      selectedRightIndex = rightIndex;

      // Check if the food matches with the correct category
      isCorrect = (leftItems[leftIndex] == '🍎' &&
              shuffledRightItems[rightIndex] == 'Meyve') ||
          (leftItems[leftIndex] == '🥕' &&
              shuffledRightItems[rightIndex] == 'Sebze') ||
          (leftItems[leftIndex] == '🍦' &&
              shuffledRightItems[rightIndex] == 'Tatlı') ||
          (leftItems[leftIndex] == '🍕' &&
              shuffledRightItems[rightIndex] == 'Fast Food');

      showFeedback = true;
      _feedbackController.forward(from: 0);

      if (isCorrect) {
        matchedLeft[leftIndex] = true;
        matchedRight[rightIndex] = true;

        if (matchedLeft.every((element) => element) && !_dialogShown) {
          _dialogShown = true;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MevsimHavaEsle()),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: const Text('Yiyecek Kategorileri'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Yiyecekleri kategorileriyle eşleştir',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            leftItems.length,
                            (index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (selectedRightIndex != null) {
                                    checkMatch(index, selectedRightIndex!);
                                  } else {
                                    setState(() {
                                      selectedLeftIndex = index;
                                    });
                                  }
                                },
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: matchedLeft[index]
                                        ? Colors.green.shade300
                                        : (showFeedback &&
                                                !isCorrect &&
                                                selectedLeftIndex == index)
                                            ? Colors.red.shade200
                                            : selectedLeftIndex == index
                                                ? Colors.blue.shade200
                                                : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      leftItems[index],
                                      style: const TextStyle(fontSize: 50),
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
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            shuffledRightItems.length,
                            (index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (selectedLeftIndex != null) {
                                    checkMatch(selectedLeftIndex!, index);
                                  } else {
                                    setState(() {
                                      selectedRightIndex = index;
                                    });
                                  }
                                },
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: matchedRight[index]
                                        ? Colors.green.shade300
                                        : (showFeedback &&
                                                !isCorrect &&
                                                selectedRightIndex == index)
                                            ? Colors.red.shade200
                                            : selectedRightIndex == index
                                                ? Colors.blue.shade200
                                                : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      shuffledRightItems[index],
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
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
                const SizedBox(height: 20),
                if (showFeedback)
                  ScaleTransition(
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
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green : Colors.red,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isCorrect ? 'Aferin! 🎉' : 'Tekrar dene! 😔',
                            style: TextStyle(
                              fontSize: 18,
                              color: isCorrect ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
