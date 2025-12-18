import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/matching_questions_screen.dart';
import '../screens/home_screen.dart';
import '../utils/activity_tracker.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/in_game_menu.dart';

class SeninWidget extends StatefulWidget {
  const SeninWidget({super.key});

  @override
  State<SeninWidget> createState() => _SeninWidgetState();
}

class _SeninWidgetState extends State<SeninWidget>
    with TickerProviderStateMixin {
  final List<String> leftItems = ['🍎', '🍌', '🍇'];
  final List<String> rightItems = ['Muz', 'Üzüm', 'Elma'];
  late List<String> shuffledRightItems;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = [false, false, false];
  List<bool> matchedRight = [false, false, false];
  bool showFeedback = false;
  bool isCorrect = false;
  bool allMatched = false;
  bool _isSoundOn = true;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _dialogShown = false;

  final Map<String, String> itemToName = {
    '🍎': 'Elma',
    '🍌': 'Muz',
    '🍇': 'Üzüm',
  };

  @override
  void initState() {
    super.initState();
    shuffledRightItems = List.from(rightItems)..shuffle();

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

  Future<void> _saveStageCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('asama2_completed', true);
  }

  Future<void> _trackWrongAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('asama2_wrong_count') ?? 0;
    wrongCount++;
    await prefs.setInt('asama2_wrong_count', wrongCount);
  }

  Future<int> _calculateStars() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('asama2_wrong_count') ?? 0;

    if (wrongCount >= 0 && wrongCount <= 3) {
      return 3;
    } else if (wrongCount >= 4 && wrongCount <= 8) {
      return 2;
    } else {
      // 9 ve üzeri
      return 1;
    }
  }

  void _handleTap(int index, bool isLeft) {
    if (allMatched) return;

    setState(() {
      if (isLeft) {
        if (matchedLeft[index]) return;
        selectedLeftIndex = index;
      } else {
        if (matchedRight[index]) return;
        selectedRightIndex = index;
      }
      if (selectedLeftIndex != null && selectedRightIndex != null) {
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    setState(() {
      isCorrect =
          itemToName[leftItems[selectedLeftIndex!]] ==
          shuffledRightItems[selectedRightIndex!];
      showFeedback = true;
    });

    _feedbackController.forward(from: 0);

    if (isCorrect) {
      matchedLeft[selectedLeftIndex!] = true;
      matchedRight[selectedRightIndex!] = true;

      if (matchedLeft.every((element) => element)) {
        allMatched = true;
        _saveStageCompletion();
        if (!_dialogShown) {
          _dialogShown = true;
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) _showCompletionDialog();
          });
        }
      }
    } else {
      _trackWrongAnswer();
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

  void _showCompletionDialog() async {
    // Önce yıldız hesapla (yanlış sayısı sıfırlanmadan önce)
    int stars = await _calculateStars();
    
    // Yanlış sayısını kaydet ve sıfırla
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('asama2_wrong_count') ?? 0;
    await prefs.setInt('asama2_final_wrong_count', wrongCount);
    await prefs.setInt('asama2_wrong_count', 0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            // Ekrana sığdır - dinamik boyut
            final popupWidth = screenWidth * 0.9;
            final popupHeight = screenHeight * 0.75;

            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: Opacity(
                    opacity: value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Uzay popup görseli - ekranın ortasına
                        Image.asset(
                          'assets/popup/uzay_popup.png',
                          width: popupWidth,
                          height: popupHeight,
                          fit: BoxFit.contain,
                        ),
                        // Yıldız görseli - popup'ın ortasındaki dikdörtgene
                        // Yıldız sayısına göre göster (yan yana)
                        if (stars > 0)
                          Positioned(
                            // Popup'ın ortasına yerleştir - popup görselinin ortasındaki dikdörtgen alanına
                            top: popupHeight * 0.45,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(stars, (index) {
                                // Her yıldız için boyut - popup genişliğine göre dinamik
                                // Popup'ın ortasındaki dikdörtgene sığacak şekilde
                                final individualSize = (popupWidth * 0.15).clamp(40.0, 80.0);
                                return TweenAnimationBuilder<double>(
                                  duration: Duration(milliseconds: 400 + (index * 200)),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  curve: Curves.elasticOut,
                                  builder: (context, scaleValue, child) {
                                    return Transform.scale(
                                      scale: scaleValue,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: popupWidth * 0.02,
                                        ),
                                        child: Image.asset(
                                          'assets/popup/yildiz.png',
                                          width: individualSize,
                                          height: individualSize,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ),
                        // MENÜYE GİT butonu - popup'ın alt kısmına transparan buton
                        Positioned(
                          bottom: popupHeight * 0.28,
                          left: popupWidth * 0.15,
                          right: popupWidth * 0.15,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                ActivityTracker.completeActivity();
                                Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MatchingQuestionsScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                height: (popupHeight * 0.1).clamp(45.0, 65.0),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard({
    required int index,
    required bool isLeft,
    required String text,
    required TextStyle style,
  }) {
    final bool isSelected =
        isLeft ? selectedLeftIndex == index : selectedRightIndex == index;
    final bool isMatched = isLeft ? matchedLeft[index] : matchedRight[index];
    final bool isWrongSelection = showFeedback && !isCorrect && isSelected;

    Color cardColor = Colors.white;
    if (isMatched) {
      cardColor = Colors.green.shade200;
    } else if (isWrongSelection) {
      cardColor = Colors.red.shade200;
    } else if (isSelected) {
      cardColor = Colors.blue.shade200;
    }

    return GestureDetector(
      onTap: isMatched ? null : () => _handleTap(index, isLeft),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
          child: Text(text, style: style, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.065;

    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                  const SizedBox(height: 10),
                  Expanded(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(242),
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
                                    ? 'Match the fruits with their names!'
                                    : 'Meyveleri isimleriyle eşleştir!',
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
                                          MainAxisAlignment.spaceAround,
                                      children: List.generate(
                                        leftItems.length,
                                        (index) => _buildCard(
                                          index: index,
                                          isLeft: true,
                                          text: leftItems[index],
                                          style: const TextStyle(fontSize: 42),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 4,
                                    height: 425,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade400,
                                          Colors.blue.shade200,
                                          Colors.blue.shade100,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: List.generate(
                                        shuffledRightItems.length,
                                        (index) => _buildCard(
                                          index: index,
                                          isLeft: false,
                                          text: shuffledRightItems[index],
                                          style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
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
                                          ? 'Aferin! 🎉'
                                          : 'Tekrar dene! 😔',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color:
                                            isCorrect
                                                ? Colors.green
                                                : Colors.red,
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
          InGameMenu(
            isSoundOn: _isSoundOn,
            onToggleSound: () => setState(() => _isSoundOn = !_isSoundOn),
            onHome: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const MatchingQuestionsScreen(),
                ),
                (route) => false,
              );
            },
            onEntryScreen: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            iconSize: iconSize,
          ),
        ],
      ),
    );
  }
}
