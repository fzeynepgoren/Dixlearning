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
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
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
                  showFeedback = false;
                });
              } else {
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
            selectedLeftIndex = null;
            selectedRightIndex = null;
            if (!isCorrect) {
              showFeedback = false;
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final iconSize = screenWidth * 0.065;

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
                    Text(
                      isEnglish ? 'Match the Fruits' : 'Meyveleri Eşleştir',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(width: 48), // Denge için
                  ],
                ),
                const SizedBox(height: 15),
                // Expanded yerine, yüksekliği 'Az Olanı İşaretle' sorusuna uygun sabit bir değerle (450) kullandım.
                SizedBox(
                  height: 450,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
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
                                            width: 90,
                                            height: 90,
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
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 5),
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
                                  height: screenSize.height * 0.5,
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
                                            width: 90,
                                            height: 90,
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
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 5),
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
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (showFeedback)
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _feedbackController,
                        curve: Curves.elasticOut,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                                  ? (isEnglish ? 'Well done! 🎉' : 'Aferin! 🎉')
                                  : (isEnglish ? 'Try again! 😔' : 'Tekrar dene! 😔'),
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
                  ),
                // `Spacer` artık gerekmiyor, çünkü sabit yükseklik kullandık.
              ],
            ),
          ),
        ),
      ),
    );
  }
}