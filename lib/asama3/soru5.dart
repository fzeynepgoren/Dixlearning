import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import '../screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class RenkNesneEsle extends StatefulWidget {
  const RenkNesneEsle({super.key});

  @override
  State<RenkNesneEsle> createState() => _RenkNesneEsleState();
}

class _RenkNesneEsleState extends State<RenkNesneEsle>
    with TickerProviderStateMixin {
  final List<String> leftImages = ['🍓', '🍋', '🍀'];
  final List<String> rightColors = ['Kırmızı', 'Sarı', 'Yeşil'];
  final List<String> rightColorsEnglish = ['Red', 'Yellow', 'Green'];
  late List<String> shuffledColors;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = [false, false, false];
  List<bool> matchedRight = [false, false, false];
  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

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
    shuffledColors =
        List.from(isEnglish ? rightColorsEnglish : rightColors)..shuffle();
    _feedbackController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
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

  void _handleTap(int index, bool isLeft) {
    if (isLeft && matchedLeft[index]) return;
    if (!isLeft && matchedRight[index]) return;
    setState(() {
      if (isLeft) {
        selectedLeftIndex = index;
      } else {
        selectedRightIndex = index;
      }
    });

    if (selectedLeftIndex != null && selectedRightIndex != null) {
      final isEnglish =
          Provider.of<LanguageProvider>(context, listen: false).isEnglish;
      setState(() {
        isCorrect = (isEnglish
            ? imageToColorEnglish[leftImages[selectedLeftIndex!]] ==
                shuffledColors[selectedRightIndex!]
            : imageToColor[leftImages[selectedLeftIndex!]] ==
                shuffledColors[selectedRightIndex!]);
        showFeedback = true;
      });
      _feedbackController.forward(from: 0);

      if (isCorrect) {
        setState(() {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;
        });

        // Tüm eşleşmeler tamamlandıysa
        if (matchedLeft.every((e) => e)) {
          ActivityTracker.completeActivity();
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          });
        }
      }

      Future.delayed(const Duration(milliseconds: 900), () {
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

  Widget _buildCard(String content, bool isLeft, int index,
      {bool isEnglish = false}) {
    final bool isSelected =
        isLeft ? selectedLeftIndex == index : selectedRightIndex == index;
    final bool isMatched = isLeft ? matchedLeft[index] : matchedRight[index];
    final bool isWrong = showFeedback && !isCorrect && isSelected;

    Color cardColor = Colors.white;
    if (isMatched) {
      cardColor = Colors.green.shade300;
    } else if (isWrong) {
      cardColor = Colors.red.shade300;
    } else if (isSelected) {
      cardColor = isLeft ? Colors.blue.shade200 : Colors.yellow.shade200;
    }

    return GestureDetector(
      onTap: isMatched ? null : () => _handleTap(index, isLeft),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 110,
        height: 110,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.13),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Center(
          child: Text(
            content,
            style: TextStyle(
              fontSize: isLeft ? 54 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade200,
                Colors.blue.shade200,
                const Color(0xffffffff),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Geri butonu üstte sola hizalı
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                  ],
                ),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.96),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.09),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              isEnglish
                                  ? 'Match the objects with their colors!'
                                  : 'Nesneleri renkleriyle eşleştir!',
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: List.generate(
                                        leftImages.length,
                                        (i) => _buildCard(leftImages[i], true, i),
                                      ),
                                    ),
                                  ),
                                  // Ortadaki çizgi
                                  Container(
                                    width: 4,
                                    height: screenSize.height * 0.38,
                                    margin: const EdgeInsets.symmetric(horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: List.generate(
                                        shuffledColors.length,
                                        (i) => _buildCard(shuffledColors[i], false, i,
                                            isEnglish: isEnglish),
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
                ),
                // Feedback alanı
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: showFeedback
                      ? ScaleTransition(
                          scale: CurvedAnimation(
                            parent: _feedbackController,
                            curve: Curves.elasticOut,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
    }