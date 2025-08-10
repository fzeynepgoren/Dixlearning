import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import '../screens/home_screen.dart';

class EmojiAnimalMatching extends StatefulWidget {
  const EmojiAnimalMatching({super.key});

  @override
  State<EmojiAnimalMatching> createState() => _EmojiAnimalMatchingState();
}

class _EmojiAnimalMatchingState extends State<EmojiAnimalMatching>
    with TickerProviderStateMixin {
  final List<String> leftEmojis = ['🐶', '🐱', '🐰', '🐼'];
  final List<String> rightAnimals = [
    'Köpek',
    'Kedi',
    'Tavşan',
    'Panda',
  ];
  late List<String> shuffledAnimals;
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
    shuffledAnimals = List.from(rightAnimals)..shuffle();
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
        // Check if the emoji matches with the correct animal
        isCorrect = (leftEmojis[selectedLeftIndex!] == '🐶' &&
                shuffledAnimals[selectedRightIndex!] == 'Köpek') ||
            (leftEmojis[selectedLeftIndex!] == '🐱' &&
                shuffledAnimals[selectedRightIndex!] == 'Kedi') ||
            (leftEmojis[selectedLeftIndex!] == '🐰' &&
                shuffledAnimals[selectedRightIndex!] == 'Tavşan') ||
            (leftEmojis[selectedLeftIndex!] == '🐼' &&
                shuffledAnimals[selectedRightIndex!] == 'Panda');

        showFeedback = true;
        _feedbackController.forward(from: 0);

        if (isCorrect) {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;

          if (matchedLeft.every((element) => element) && !_dialogShown) {
            _dialogShown = true;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Dialog(
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
                            Colors.deepPurple.shade100,
                            Colors.deepPurple.shade50,
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
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '4. aşamayı tamamladınız!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Etkinlik tamamlandı

                              ActivityTracker.completeActivity();

                              

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: const Text('Emoji-Hayvan Eşleştirme'),
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
                  'Emojileri hayvanlarla eşleştir',
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
                            leftEmojis.length,
                            (index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () => _handleTap(index, true),
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
                                      leftEmojis[index],
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
                            shuffledAnimals.length,
                            (index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () => _handleTap(index, false),
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
                                      shuffledAnimals[index],
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
