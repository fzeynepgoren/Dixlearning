import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import '../screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'soru2.dart';
import 'soru3.dart';
import 'soru4.dart';
import 'soru5.dart';

class RenkNesneEsle extends StatefulWidget {
  const RenkNesneEsle({super.key});

  @override
  State<RenkNesneEsle> createState() => _RenkNesneEsleState();
}

class _RenkNesneEsleState extends State<RenkNesneEsle>
    with TickerProviderStateMixin {
  final List<String> leftImages = ['🍓', '🍋', '🍀'];
  final List<String> rightColors = ['Sarı', 'Kırmızı', 'Yeşil'];
  final List<String> rightColorsEnglish = ['Yellow', 'Red', 'Green'];
  late List<String> shuffledColors;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = List.filled(3, false);
  List<bool> matchedRight = List.filled(3, false);
  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _dialogShown = false;

  final Map<String, String> imageToColor = {
    '🍓': 'Kırmızı',
    '🍋': 'Sarı',
    '🍀': 'Yeşil',
  };

  final Map<String, String> imageToColorEnglish = {
    '🍓': 'Red',
    '🍋': 'Yellow',
    '🍀': 'Green',
  };

  @override
  void initState() {
    super.initState();
    final isEnglish =
        Provider.of<LanguageProvider>(context, listen: false).isEnglish;
    shuffledColors = List.from(isEnglish ? rightColorsEnglish : rightColors);
    shuffledColors.shuffle();
    while (_listsAreEqual(
        isEnglish ? rightColorsEnglish : rightColors, shuffledColors)) {
      shuffledColors.shuffle();
    }

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
      String left = leftImages[selectedLeftIndex!];
      String right = shuffledColors[selectedRightIndex!];
      final isEnglish =
          Provider.of<LanguageProvider>(context, listen: false).isEnglish;
      setState(() {
        isCorrect = isEnglish
            ? imageToColorEnglish[left] == right
            : imageToColor[left] == right;
        showFeedback = true;
      });
      _feedbackController.forward(from: 0);

      if (isCorrect) {
        setState(() {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;
        });
      }

      Future.delayed(const Duration(milliseconds: 800), () {
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

  Widget _buildCard({
    required String content,
    required bool isLeft,
    required int index,
    required bool matched,
    required bool selected,
    required bool wrong,
    required TextStyle style,
    required VoidCallback onTap,
  }) {
    Color cardColor = Colors.white;
    if (matched) {
      cardColor = Colors.green.shade200;
    } else if (wrong) {
      cardColor = Colors.red.shade200;
    } else if (selected) {
      cardColor = Colors.blue.shade200;
    }

    return GestureDetector(
      onTap: matched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 120,
        height: 120,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
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
            content,
            style: style,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    bool allMatched = matchedLeft.every((e) => e) && matchedRight.every((e) => e);

    if (allMatched && !_dialogShown) {
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
                      '3. aşamayı tamamladınız!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        ActivityTracker.completeActivity();
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Ana Menüye Dön',
                        style: TextStyle(fontSize: 18, color: Colors.white),
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

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE1F5FE),
        appBar: AppBar(
          title: Text(
            isEnglish ? 'Color-Object Matching' : 'Renk Nesne Eşleştirme',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ActivityTracker.completeActivity();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
        ),
        body: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    isEnglish
                        ? 'Match the objects with their colors!'
                        : 'Nesneleri renkleriyle eşleştir!',
                    style: const TextStyle(
                        fontSize: 23, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(
                              leftImages.length,
                              (index) => _buildCard(
                                content: leftImages[index],
                                isLeft: true,
                                index: index,
                                matched: matchedLeft[index],
                                selected: selectedLeftIndex == index,
                                wrong: showFeedback && !isCorrect && selectedLeftIndex == index,
                                style: const TextStyle(fontSize: 42),
                                onTap: () => _handleLeftTap(index),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 4,
                          height: MediaQuery.of(context).size.height * 0.45,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(
                              shuffledColors.length,
                              (index) => _buildCard(
                                content: shuffledColors[index],
                                isLeft: false,
                                index: index,
                                matched: matchedRight[index],
                                selected: selectedRightIndex == index,
                                wrong: showFeedback && !isCorrect && selectedRightIndex == index,
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple),
                                onTap: () => _handleRightTap(index),
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
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
        ),
      ),
    );
  }
}
