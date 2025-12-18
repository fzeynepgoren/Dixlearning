import 'package:flutter/material.dart';
import 'soru5.dart';
import '../screens/matching_questions_screen.dart';
import '../screens/home_screen.dart';
import '../widgets/in_game_menu.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Soru4 extends StatefulWidget {
  const Soru4({super.key});

  @override
  State<Soru4> createState() => _Soru4State();
}

class _Soru4State extends State<Soru4> with TickerProviderStateMixin {
  final List<int> leftNumbers = [1, 2, 4];
  late List<int> rightNumbers;
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

  @override
  void initState() {
    super.initState();
    rightNumbers = List.from([1, 2, 4])..shuffle();
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

  void _handleTap(int index, bool isLeft) {
    if (allMatched) return;

    setState(() {
      if (isLeft) {
        if (matchedLeft[index]) return;
        selectedLeftIndex = index;
        if (selectedRightIndex != null && selectedLeftIndex != null) {
          _checkMatch();
        }
      } else {
        if (matchedRight[index]) return;
        selectedRightIndex = index;
        if (selectedLeftIndex != null && selectedRightIndex != null) {
          _checkMatch();
        }
      }
    });
  }

  void _checkMatch() {
    setState(() {
      isCorrect =
          leftNumbers[selectedLeftIndex!] == rightNumbers[selectedRightIndex!];
      showFeedback = true;
    });

    _feedbackController.forward(from: 0);

    if (isCorrect) {
      setState(() {
        matchedLeft[selectedLeftIndex!] = true;
        matchedRight[selectedRightIndex!] = true;
      });

      if (matchedLeft.every((element) => element)) {
        allMatched = true;
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SeninWidget()),
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

  String _getCandies(int number) {
    if (number == 4) {
      return '🍬🍬\n🍬🍬';
    }
    return '🍬' * number;
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

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: iconSize,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const MatchingQuestionsScreen(),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                    Expanded(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
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
                                      ? 'Count and match the candies!'
                                      : 'Şekerleri say ve eşleştir!',
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
                                          leftNumbers.length,
                                          (index) => _buildCard(
                                            index: index,
                                            isLeft: true,
                                            text: leftNumbers[index].toString(),
                                            style: const TextStyle(
                                              fontSize: 42,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
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
                                          rightNumbers.length,
                                          (index) => _buildCard(
                                            index: index,
                                            isLeft: false,
                                            text: _getCandies(
                                              rightNumbers[index],
                                            ),
                                            style: const TextStyle(
                                              fontSize: 26,
                                              height: 1.2,
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
                                            isCorrect
                                                ? Colors.green
                                                : Colors.red,
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
      ),
    );
  }
}
