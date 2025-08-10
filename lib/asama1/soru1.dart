import 'package:flutter/material.dart';
import 'soru2.dart';
import '../screens/home_screen.dart';
import '../utils/activity_tracker.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class MeyveEsle extends StatefulWidget {
  const MeyveEsle({super.key});

  @override
  State<MeyveEsle> createState() => _MeyveEsleState();
}

class _MeyveEsleState extends State<MeyveEsle> with TickerProviderStateMixin {
  final List<List<String>> pageFruits = [
    ['🍓', '🍇', '🍒'],
    ['🍎', '🍊', '🍐']
  ];
  late List<List<String>> rightFruits;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  late List<List<bool>> matchedLeft;
  late List<List<bool>> matchedRight;
  late List<int> matchedPairs;
  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    rightFruits = List.generate(2, (pageIndex) {
      List<String> fruits = List.from(pageFruits[pageIndex]);
      do {
        fruits.shuffle();
      } while (_listsAreEqual(pageFruits[pageIndex], fruits));
      return fruits;
    });
    matchedLeft = List.generate(2, (_) => List.filled(3, false));
    matchedRight = List.generate(2, (_) => List.filled(3, false));
    matchedPairs = [0, 0];
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

  bool _listsAreEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _handleLeftTap(int index) {
    if (matchedLeft[currentPage][index]) return;
    setState(() {
      selectedLeftIndex = index;
    });
    _checkMatch();
  }

  void _handleRightTap(int index) {
    if (matchedRight[currentPage][index]) return;
    setState(() {
      selectedRightIndex = index;
    });
    _checkMatch();
  }

  void _checkMatch() {
    if (selectedLeftIndex != null && selectedRightIndex != null) {
      setState(() {
        isCorrect = pageFruits[currentPage][selectedLeftIndex!] ==
            rightFruits[currentPage][selectedRightIndex!];
        showFeedback = true;
      });
      _feedbackController.forward(from: 0);

      if (isCorrect) {
        setState(() {
          matchedLeft[currentPage][selectedLeftIndex!] = true;
          matchedRight[currentPage][selectedRightIndex!] = true;
          matchedPairs[currentPage]++;
        });

        if (matchedPairs[currentPage] == pageFruits[currentPage].length) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              if (currentPage == 0) {
                setState(() {
                  currentPage = 1;
                  selectedLeftIndex = null;
                  selectedRightIndex = null;
                });
              } else {
                // Etkinlik tamamlandı, sayacı artır
                ActivityTracker.completeActivity();
                
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const GDisgrafi1()),
                );
              }
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
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE1F5FE),
        appBar: AppBar(
          title: Text(
            isEnglish ? 'Fruit Matching' : 'Meyve Eşleştirme',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                isEnglish ? 'Match the Fruits' : 'Meyveleri Eşleştir',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: GestureDetector(
                              onTap: () => _handleLeftTap(index),
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: matchedLeft[currentPage][index]
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
                                    pageFruits[currentPage][index],
                                    style: const TextStyle(
                                      fontSize: 42,
                                    ),
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
                      height: MediaQuery.of(context).size.height * 0.5,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: GestureDetector(
                              onTap: () => _handleRightTap(index),
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: matchedRight[currentPage][index]
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
                                    rightFruits[currentPage][index],
                                    style: const TextStyle(
                                      fontSize: 42,
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
                        vertical: 10, horizontal: 20),
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
      ),
    );
  }
}
