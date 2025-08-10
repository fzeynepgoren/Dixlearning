import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'soru3.dart';

class HarfHayvanEsle extends StatefulWidget {
  const HarfHayvanEsle({super.key});

  @override
  State<HarfHayvanEsle> createState() => _HarfHayvanEsleState();
}

class _HarfHayvanEsleState extends State<HarfHayvanEsle>
    with TickerProviderStateMixin {
  final List<String> leftAnimals = ['🦒', '🐘', '🐰'];
  final List<String> rightLetters = ['Z', 'F', 'T'];
  late List<String> shuffledLetters;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = [false, false, false];
  List<bool> matchedRight = [false, false, false];
  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;
  bool _dialogShown = false;
  int? wrongLeftIndex;
  int? wrongRightIndex;

  final Map<String, String> animalToLetter = {
    '🦒': 'Z',
    '🐘': 'F',
    '🐰': 'T',
  };

  @override
  void initState() {
    super.initState();
    shuffledLetters = List.from(rightLetters)..shuffle();
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
        isCorrect = animalToLetter[leftAnimals[selectedLeftIndex!]] ==
            shuffledLetters[selectedRightIndex!];

        showFeedback = true;
        _feedbackController.forward(from: 0);

        if (isCorrect) {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;
          wrongLeftIndex = null;
          wrongRightIndex = null;

          if (matchedLeft.every((element) => element)) {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                // Etkinlik tamamlandı

                ActivityTracker.completeActivity();

                

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Soru3()),
                );
              }
            });
          }
        } else {
          wrongLeftIndex = selectedLeftIndex;
          wrongRightIndex = selectedRightIndex;
        }

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              showFeedback = false;
              selectedLeftIndex = null;
              selectedRightIndex = null;
              wrongLeftIndex = null;
              wrongRightIndex = null;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool allMatched = matchedLeft.every((e) => e);
    if (allMatched && !_dialogShown) {
      _dialogShown = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // Etkinlik tamamlandı

          ActivityTracker.completeActivity();

          

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Soru3()),
          );
        }
      });
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE1F5FE),
        appBar: AppBar(
          title: const Text('Harf-Hayvan Eşleştirme',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Resimdeki hayvanları baş harfi ile eşleştir!',
                    style: TextStyle(
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
                              leftAnimals.length,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: GestureDetector(
                                  onTap: () => _handleTap(index, true),
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: matchedLeft[index]
                                          ? Colors.green.shade300
                                          : (wrongLeftIndex == index &&
                                                  showFeedback &&
                                                  !isCorrect)
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
                                        leftAnimals[index],
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
                              shuffledLetters.length,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: GestureDetector(
                                  onTap: () => _handleTap(index, false),
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: matchedRight[index]
                                          ? Colors.green.shade300
                                          : (wrongRightIndex == index &&
                                                  showFeedback &&
                                                  !isCorrect)
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
                                        shuffledLetters[index],
                                        style: const TextStyle(
                                          fontSize: 42,
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
      ),
    );
  }
}
