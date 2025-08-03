import 'package:flutter/material.dart';
import '../../main.dart';
import '../screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'soru2.dart'; // Eğer HarfHayvanEsle burada tanımlıysa
import 'soru3.dart'; // soru2'de
import 'soru4.dart'; // soru3'te
import 'soru5.dart'; // soru4'te

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
  int matchedPairs = 0;
  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;
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
          matchedPairs++;
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

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    bool allMatched =
        matchedLeft.every((e) => e) && matchedRight.every((e) => e);
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
                        Navigator.of(context).pop();
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
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: Text(
            isEnglish ? 'Color-Object Matching' : 'Renk Nesne Eşleştirme',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              isEnglish
                  ? 'Match the objects with their colors!'
                  : 'Nesneleri renkleriyle eşleştir!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
                          leftImages.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                                    leftImages[index],
                                    style: const TextStyle(fontSize: 42),
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
                        height: (120 + 32.0) * leftImages.length - 32.0,
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
                          shuffledColors.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                                    shuffledColors[index],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                    textAlign: TextAlign.center,
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
            if (allMatched)
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _feedbackController,
                  curve: Curves.elasticOut,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Tüm eşleştirmeler tamamlandı!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
