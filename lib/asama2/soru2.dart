import 'package:flutter/material.dart';
import 'soru3.dart';
import '../screens/matching_questions_screen.dart';
import '../screens/home_screen.dart';
import '../utils/activity_tracker.dart';
import '../widgets/in_game_menu.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isSoundOn = true;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Eşleşme için renkli ve gölge assetlerin indexleri aynı olmalı
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

  Future<void> _trackWrongAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('asama2_wrong_count') ?? 0;
    wrongCount++;
    await prefs.setInt('asama2_wrong_count', wrongCount);
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
                MaterialPageRoute(builder: (context) => const HarfEsleSoru3()),
              );
            }
          });
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
  }

  @override
  Widget build(BuildContext context) {
    Color cardColor({
      required bool matched,
      required bool isSelected,
      required bool isWrong,
    }) {
      if (matched) return Colors.green.shade500;
      if (isWrong) return Colors.red.shade500;
      if (isSelected) return Colors.blue.shade200;
      return Colors.white;
    }

    Widget imageCard({
      required int index,
      required bool isLeft,
      required String asset,
    }) {
      final bool isSelected =
          isLeft ? selectedLeftIndex == index : selectedRightIndex == index;
      final bool matched = isLeft ? matchedLeft[index] : matchedRight[index];
      final bool isWrongSelection = showFeedback && !isCorrect && isSelected;

      return GestureDetector(
        onTap:
            matched
                ? null
                : () => isLeft ? _handleLeftTap(index) : _handleRightTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 120,
          height: 120,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: cardColor(
              matched: matched,
              isSelected: isSelected,
              isWrong: isWrongSelection,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(asset, fit: BoxFit.contain),
          ),
        ),
      );
    }

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
                              color: Colors.black.withAlpha(26),
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
                                    ? 'Match the shadows with their images!'
                                    : 'Gölgeleri resimlerle eşleştir!',
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
                                        shuffledLeftAssets.length,
                                        (index) => imageCard(
                                          index: index,
                                          isLeft: true,
                                          asset: shuffledLeftAssets[index],
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
                                        shuffledRightAssets.length,
                                        (index) => imageCard(
                                          index: index,
                                          isLeft: false,
                                          asset: shuffledRightAssets[index],
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
