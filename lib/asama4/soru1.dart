import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'package:dixlearning/asama4/soru2.dart';

class DuyguYuzEsle extends StatefulWidget {
  const DuyguYuzEsle({super.key});

  @override
  State<DuyguYuzEsle> createState() => _DuyguYuzEsleState();
}

class _DuyguYuzEsleState extends State<DuyguYuzEsle>
    with TickerProviderStateMixin {
  final List<String> leftItems = ['😊', '😠', '😢', '😲'];
  final List<String> rightItems = ['Mutlu', 'Kızgın', 'Üzgün', 'Şaşkın'];
  late List<String> shuffledRightItems;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = [false, false, false, false];
  List<bool> matchedRight = [false, false, false, false];
  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;
  bool _dialogShown = false;

  final Map<String, String> itemToName = {
    '😊': 'Mutlu',
    '😠': 'Kızgın',
    '😢': 'Üzgün',
    '😲': 'Şaşkın',
  };

  @override
  void initState() {
    super.initState();
    shuffledRightItems = List.from(rightItems);
    do {
      shuffledRightItems.shuffle();
    } while (_listsAreEqual(leftItems, shuffledRightItems));

    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  bool _listsAreEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (itemToName[a[i]] == b[i]) return true;
    }
    return false;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleLeftTap(int index) {
    if (matchedLeft[index]) return;
    setState(() {
      selectedLeftIndex = index;
    });
    _checkMatch();
  }

  void _handleRightTap(int index) {
    if (matchedRight[index]) return;
    setState(() {
      selectedRightIndex = index;
    });
    _checkMatch();
  }

  void _checkMatch() {
    if (selectedLeftIndex != null && selectedRightIndex != null) {
      String left = leftItems[selectedLeftIndex!];
      String right = shuffledRightItems[selectedRightIndex!];
      setState(() {
        isCorrect = itemToName[left] == right;
        showFeedback = true;
      });
      _feedbackController.forward(from: 0);
      if (isCorrect) {
        setState(() {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;
        });

        if (matchedLeft.every((element) => element) && !_dialogShown) {
          _dialogShown = true;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              // Etkinlik tamamlandı

              ActivityTracker.completeActivity();

              

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DuyuOrganEsle()),
              );
            }
          });
        }
      } else {
        // Yanlış eşleşme durumunda kutuları kırmızı yap
        setState(() {
          matchedLeft[selectedLeftIndex!] = false;
          matchedRight[selectedRightIndex!] = false;
        });
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: const Text('Duygu-Yüz İfadesi Eşleştirme',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Yüz ifadelerini duygularla eşleştir!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          leftItems.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: GestureDetector(
                              onTap: () => _handleLeftTap(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
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
                                  borderRadius: BorderRadius.circular(20),
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
                                    style: const TextStyle(fontSize: 48),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: (120 + 32.0) * leftItems.length - 32.0,
                        child: Container(
                          width: 3,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.18),
                                spreadRadius: 1,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          shuffledRightItems.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: GestureDetector(
                              onTap: () => _handleRightTap(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
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
                                  borderRadius: BorderRadius.circular(20),
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
    );
  }
}
