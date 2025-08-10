import 'package:dixlearning/asama1/soru3.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../utils/activity_tracker.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class GDisgrafi1 extends StatefulWidget {
  const GDisgrafi1({super.key});

  @override
  State<GDisgrafi1> createState() => _GDisgrafi1State();
}

class _GDisgrafi1State extends State<GDisgrafi1> with TickerProviderStateMixin {
  final List<String> leftToys = ['⚽', '🧸', '🚂', '🎮'];
  late List<String> rightToys;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = List.filled(4, false);
  List<bool> matchedRight = List.filled(4, false);
  int matchedPairs = 0;
  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    rightToys = List.from(leftToys);
    do {
      rightToys.shuffle();
    } while (_listsAreEqual(leftToys, rightToys));

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
        isCorrect =
            leftToys[selectedLeftIndex!] == rightToys[selectedRightIndex!];
        showFeedback = true;
      });
      _feedbackController.forward(from: 0);

      if (isCorrect) {
        setState(() {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;
          matchedPairs++;
        });

        if (matchedPairs == leftToys.length) {
          // Etkinlik tamamlandı
          ActivityTracker.completeActivity();
          
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const GeometricMatching()),
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
          title: Text(
            isEnglish ? 'Toy Matching' : 'Oyuncak Eşleştirme',
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
                isEnglish ? 'Match the Toys' : 'Oyuncakları Eşleştir',
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
                          leftToys.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
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
                                    leftToys[index],
                                    style: const TextStyle(fontSize: 42),
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
                          rightToys.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
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
                                    rightToys[index],
                                    style: const TextStyle(fontSize: 42),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
