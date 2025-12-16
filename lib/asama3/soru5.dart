import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/activity_tracker.dart';
import '../screens/matching_questions_screen.dart';
import '../screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/in_game_menu.dart';

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
  bool _isSoundOn = true;
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
    shuffledColors = List.from(isEnglish ? rightColorsEnglish : rightColors)
      ..shuffle();
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
    await prefs.setBool('asama3_completed', true);
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
        isCorrect =
            (isEnglish
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
          _saveStageCompletion();
          ActivityTracker.completeActivity();
          Future.delayed(const Duration(milliseconds: 800), () async {
            if (mounted) {
              final prefs = await SharedPreferences.getInstance();
              int wrongCount = prefs.getInt('asama3_wrong_count') ?? 0;
              await prefs.setInt('asama3_final_wrong_count', wrongCount);

              int stars = await _calculateStars();
              await prefs.setInt('asama3_wrong_count', 0);

              _showCompletionDialog(stars);
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

  Widget _buildCard(
    String content,
    bool isLeft,
    int index, {
    bool isEnglish = false,
  }) {
    final bool isSelected =
        isLeft ? selectedLeftIndex == index : selectedRightIndex == index;
    final bool isMatched = isLeft ? matchedLeft[index] : matchedRight[index];
    final bool isWrong = showFeedback && !isCorrect && isSelected;

    Color cardColor = Colors.white;
    if (isMatched) {
      cardColor = Colors.green.shade200;
    } else if (isWrong) {
      cardColor = Colors.red.shade200;
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
          border:
              isSelected && !isMatched
                  ? Border.all(color: Colors.blue.shade400, width: 4)
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.13),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
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

    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: List.generate(
                                          leftImages.length,
                                          (i) => _buildCard(
                                            leftImages[i],
                                            true,
                                            i,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Ortadaki çizgi
                                    Container(
                                      width: 4,
                                      height: 425,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 14,
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
                                          shuffledColors.length,
                                          (i) => _buildCard(
                                            shuffledColors[i],
                                            false,
                                            i,
                                            isEnglish: isEnglish,
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
                  ),
                  // Feedback alanı
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

  Future<int> _calculateStars() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('asama3_wrong_count') ?? 0;
    if (wrongCount == 0) return 3;
    if (wrongCount <= 2) return 2;
    return 1;
  }

  void _showCompletionDialog(int stars) {
    if (!mounted) return;
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Dialog(
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
                                      final individualSize = (popupWidth * 0.15)
                                          .clamp(40.0, 80.0);
                                      return TweenAnimationBuilder<double>(
                                        duration: Duration(
                                          milliseconds: 400 + (index * 200),
                                        ),
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
                                      Navigator.of(context).pop();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const MatchingQuestionsScreen(),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width: double.infinity,
                                      height: (popupHeight * 0.1).clamp(
                                        45.0,
                                        65.0,
                                      ),
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
    } catch (e) {
      // Hata durumunda sessizce devam et
      debugPrint('Popup gösterilirken hata: $e');
    }
  }
}
