import 'package:flutter/material.dart';
import 'soru3.dart';
import '../utils/activity_tracker.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class Soru2 extends StatefulWidget {
  const Soru2({super.key});

  @override
  State<Soru2> createState() => _Soru2State();
}

class _Soru2State extends State<Soru2> with TickerProviderStateMixin {
  final List<String> renkliAssets = [
    'assets/asama2_soru2/kurbagarenkli.png',
    'assets/asama2_soru2/pantalonrenkli.png',
    'assets/asama2_soru2/yedirenkli.png',
  ];
  final List<String> golgeAssets = [
    'assets/asama2_soru2/kurbagagolge.png',
    'assets/asama2_soru2/golgepantalon.png',
    'assets/asama2_soru2/yedigolge.png',
  ];

  late List<String> shuffledLeftAssets;
  late List<String> shuffledRightAssets;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = [false, false, false];
  List<bool> matchedRight = [false, false, false];
  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;

  final Map<String, String> renkliToGolge = {
    'assets/asama2_soru2/kurbagarenkli.png':
        'assets/asama2_soru2/kurbagagolge.png',
    'assets/asama2_soru2/pantalonrenkli.png':
        'assets/asama2_soru2/golgepantalon.png',
    'assets/asama2_soru2/yedirenkli.png': 'assets/asama2_soru2/yedigolge.png',
  };

  @override
  void initState() {
    super.initState();
    shuffledLeftAssets = List.from(renkliAssets)..shuffle();
    shuffledRightAssets = List.from(golgeAssets)..shuffle();
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
      String left = shuffledLeftAssets[selectedLeftIndex!];
      String right = shuffledRightAssets[selectedRightIndex!];
      setState(() {
        isCorrect = renkliToGolge[left] == right;
        showFeedback = true;
      });
      _feedbackController.forward(from: 0);
      if (isCorrect) {
        setState(() {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;
        });

        if (matchedLeft.every((element) => element)) {
          ActivityTracker.completeActivity();
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HarfEsle()),
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
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Column(
                children: [
                  // FLASHCARD BAŞLANGIÇ
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Soru kutusu
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 32),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            isEnglish
                                ? 'Match the shadows with their images!'
                                : 'Gölgeleri resimlerle eşleştir!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0288D1),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  renkliAssets.length,
                                  (index) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: GestureDetector(
                                      onTap: () => _handleLeftTap(index),
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color:
                                              matchedLeft[index]
                                                  ? Colors.green.shade100
                                                  : (showFeedback &&
                                                      !isCorrect &&
                                                      selectedLeftIndex ==
                                                          index)
                                                  ? Colors.red.shade100
                                                  : selectedLeftIndex == index
                                                  ? Colors.blue.shade100
                                                  : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color:
                                                matchedLeft[index]
                                                    ? Colors.green
                                                    : (showFeedback &&
                                                        !isCorrect &&
                                                        selectedLeftIndex ==
                                                            index)
                                                    ? Colors.red
                                                    : selectedLeftIndex == index
                                                    ? Colors.blue
                                                    : Colors.grey.shade300,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.08,
                                              ),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Image.asset(
                                            shuffledLeftAssets[index],
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 12,
                              height: 340,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  golgeAssets.length,
                                  (index) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: GestureDetector(
                                      onTap: () => _handleRightTap(index),
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color:
                                              matchedRight[index]
                                                  ? Colors.green.shade100
                                                  : (showFeedback &&
                                                      !isCorrect &&
                                                      selectedRightIndex ==
                                                          index)
                                                  ? Colors.red.shade100
                                                  : selectedRightIndex == index
                                                  ? Colors.blue.shade100
                                                  : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color:
                                                matchedRight[index]
                                                    ? Colors.green
                                                    : (showFeedback &&
                                                        !isCorrect &&
                                                        selectedRightIndex ==
                                                            index)
                                                    ? Colors.red
                                                    : selectedRightIndex ==
                                                        index
                                                    ? Colors.blue
                                                    : Colors.grey.shade300,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.08,
                                              ),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Image.asset(
                                            shuffledRightAssets[index],
                                            fit: BoxFit.contain,
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
                        const SizedBox(height: 32),
                        if (showFeedback)
                          ScaleTransition(
                            scale: CurvedAnimation(
                              parent: _feedbackController,
                              curve: Curves.elasticOut,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isCorrect
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isCorrect ? Colors.green : Colors.red,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isCorrect
                                            ? Colors.green
                                            : Colors.red)
                                        .withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
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
                                    size: 32,
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    isCorrect
                                        ? 'Aferin! 🎉'
                                        : 'Tekrar dene! 😔',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color:
                                          isCorrect ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  // FLASHCARD BİTİŞ
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
