import 'package:flutter/material.dart';
import 'soru4.dart';
import '../screens/home_screen.dart';
import '../utils/activity_tracker.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class HarfEsle extends StatefulWidget {
  const HarfEsle({super.key});

  @override
  State<HarfEsle> createState() => _HarfEsleState();
}

class _HarfEsleState extends State<HarfEsle> with TickerProviderStateMixin {
  final List<String> leftLetters = ['b', 'd', 't'];
  late List<String> rightLetters;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = List.filled(3, false);
  List<bool> matchedRight = List.filled(3, false);
  int matchedPairs = 0;
  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    rightLetters = List.from(leftLetters);
    rightLetters.shuffle();
    while (_listsAreEqual(leftLetters, rightLetters)) {
      rightLetters.shuffle();
    }
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
      setState(() {
        isCorrect = leftLetters[selectedLeftIndex!] ==
            rightLetters[selectedRightIndex!];
        showFeedback = true;
      });
      _feedbackController.forward(from: 0);

      if (isCorrect) {
        setState(() {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;
          matchedPairs++;
        });

        if (matchedPairs == leftLetters.length) {
          // Etkinlik tamamlandı
          ActivityTracker.completeActivity();
          
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Soru4(),
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
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE1F5FE),
        appBar: AppBar(
          title: Text(isEnglish ? 'Letter Matching' : 'Harf Eşleştirme',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                isEnglish ? 'Match the Letters' : 'Harfleri Eşleştir',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                            leftLetters.length,
                            (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: GestureDetector(
                                onTap: () => _handleLeftTap(index),
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
                                      leftLetters[index],
                                      style: const TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w300,
                                        color: Color.fromRGBO(0, 0, 0, 0.22),
                                        letterSpacing: 2,
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
                            rightLetters.length,
                            (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: GestureDetector(
                                onTap: () => _handleRightTap(index),
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
                                      rightLetters[index],
                                      style: const TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        letterSpacing: 2,
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
