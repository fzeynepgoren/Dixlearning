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
    ['🍎', '🍊', '🍐'],
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
      duration: const Duration(milliseconds: 500),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

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
        isCorrect =
            pageFruits[currentPage][selectedLeftIndex!] ==
            rightFruits[currentPage][selectedRightIndex!];
        showFeedback = true;
      });
      _feedbackController.forward(from: 0);

      if (isCorrect) {
        matchedLeft[currentPage][selectedLeftIndex!] = true;
        matchedRight[currentPage][selectedRightIndex!] = true;
        matchedPairs[currentPage]++;

        if (matchedPairs[currentPage] == pageFruits[currentPage].length) {
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            if (currentPage == 0) {
              setState(() {
                currentPage = 1;
                selectedLeftIndex = null;
                selectedRightIndex = null;
                showFeedback = false;
              });
              _slideController.forward(from: 0); // Reset animation for new page
            } else {
              ActivityTracker.completeActivity();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const GDisgrafi1()),
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

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.065;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          // Arka plan gradyanı resimdeki gibi (hafif mavi)
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
                // Geri butonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: iconSize,
                      ),
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

                const SizedBox(height: 10),

                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: double.infinity,
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
                            child: Text(
                              isEnglish
                                  ? 'Match the fruits!'
                                  : 'Meyveleri eşleştir!',
                              style: const TextStyle(
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
                                      pageFruits[currentPage].length,
                                      (index) => GestureDetector(
                                        onTap: () => _handleLeftTap(index),
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
                                                matchedLeft[currentPage][index]
                                                    ? Colors.green.shade400
                                                    : (showFeedback
                                                        ? ((selectedLeftIndex ==
                                                                    index &&
                                                                !isCorrect)
                                                            ? Colors
                                                                .red
                                                                .shade400
                                                            : Colors.white)
                                                        : (selectedLeftIndex ==
                                                                index
                                                            ? Colors
                                                                .blue
                                                                .shade200
                                                            : Colors.white)),
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
                                              pageFruits[currentPage][index],
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
                                      rightFruits[currentPage].length,
                                      (index) => GestureDetector(
                                        onTap: () => _handleRightTap(index),
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
                                                matchedRight[currentPage][index]
                                                    ? Colors.green.shade400
                                                    : (showFeedback
                                                        ? ((selectedRightIndex ==
                                                                    index &&
                                                                !isCorrect)
                                                            ? Colors
                                                                .red
                                                                .shade400
                                                            : Colors.white)
                                                        : (selectedRightIndex ==
                                                                index
                                                            ? Colors
                                                                .blue
                                                                .shade200
                                                            : Colors.white)),
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
                                              rightFruits[currentPage][index],
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
                                        ? (isEnglish
                                            ? 'Well done! 🎉'
                                            : 'Aferin! 🎉')
                                        : (isEnglish
                                            ? 'Try again! 😔'
                                            : 'Tekrar dene! 😔'),
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
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
