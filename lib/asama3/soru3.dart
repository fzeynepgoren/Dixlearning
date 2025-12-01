import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'soru4.dart';
import '../screens/matching_questions_screen.dart';
import '../screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/matching_pause_menu.dart';

class Soru3 extends StatefulWidget {
  const Soru3({super.key});

  @override
  State<Soru3> createState() => _Soru3State();
}

class _Soru3State extends State<Soru3> with TickerProviderStateMixin {
  final List<String> leftItems = ['👨‍🏫', '👨‍⚕️', '👨‍🍳'];
  final List<String> rightItems = ['Öğrenci', 'Fırıncı', 'Hasta'];
  late List<String> shuffledRightItems;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = [false, false, false];
  List<bool> matchedRight = [false, false, false];
  bool showFeedback = false;
  bool isCorrect = false;
  bool _showPauseMenu = false;
  bool _isSoundOn = true;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _dialogShown = false;

  final Map<String, String> itemToName = {
    '👨‍🏫': 'Öğrenci',
    '👨‍⚕️': 'Hasta',
    '👨‍🍳': 'Fırıncı',
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
      String left = leftItems[selectedLeftIndex!];
      String right = shuffledRightItems[selectedRightIndex!];
      setState(() {
        isCorrect = itemToName[left] == right;
        showFeedback = true;
      });
      _feedbackController.forward(from: 0);
      if (isCorrect) {
        setState(() {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;
        });

        bool allMatched = matchedLeft.every((e) => e);
        if (allMatched && !_dialogShown) {
          _dialogShown = true;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              // Etkinlik tamamlandı

              ActivityTracker.completeActivity();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const YapiNesneEsle()),
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
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.065;

    return WillPopScope(
      onWillPop: () async {
        if (_showPauseMenu) {
          // Menü açıksa, geri tuşu ile kapat
          setState(() {
            _showPauseMenu = false;
          });
        } else {
          // Menü kapalıysa, geri tuşu ile aç
          setState(() {
            _showPauseMenu = true;
          });
        }
        return false;
      },
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showPauseMenu = true;
                              });
                            },
                            child: Container(
                              width: iconSize * 1.6,
                              height: iconSize * 1.6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.purple.shade300,
                                    Colors.purple.shade600,
                                    Colors.deepPurple.shade700,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple.shade800.withOpacity(
                                      0.5,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 1,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(-2, -2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.home_rounded,
                                color: Colors.black,
                                size: iconSize * 0.9,
                              ),
                            ),
                          ),
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
                                      ? 'Match the professions with their tasks!'
                                      : 'Meslekleri yaptıkları işlerle eşleştir!',
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
                                            MainAxisAlignment.spaceEvenly,
                                        children: List.generate(
                                          leftItems.length,
                                          (index) => GestureDetector(
                                            onTap: () => _handleLeftTap(index),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                              width: 120,
                                              height: 120,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    matchedLeft[index]
                                                        ? Colors.green.shade200
                                                        : (showFeedback &&
                                                            !isCorrect &&
                                                            selectedLeftIndex ==
                                                                index)
                                                        ? Colors.red.shade200
                                                        : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border:
                                                    (selectedLeftIndex ==
                                                                index &&
                                                            !matchedLeft[index])
                                                        ? Border.all(
                                                          color:
                                                              Colors
                                                                  .blue
                                                                  .shade400,
                                                          width: 4,
                                                        )
                                                        : null,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  leftItems[index],
                                                  style: const TextStyle(
                                                    fontSize: 42,
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
                                      height: 425,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 10,
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
                                          shuffledRightItems.length,
                                          (index) => GestureDetector(
                                            onTap: () => _handleRightTap(index),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                              width: 120,
                                              height: 120,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    matchedRight[index]
                                                        ? Colors.green.shade200
                                                        : (showFeedback &&
                                                            !isCorrect &&
                                                            selectedRightIndex ==
                                                                index)
                                                        ? Colors.red.shade200
                                                        : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border:
                                                    (selectedRightIndex ==
                                                                index &&
                                                            !matchedRight[index])
                                                        ? Border.all(
                                                          color:
                                                              Colors
                                                                  .blue
                                                                  .shade400,
                                                          width: 4,
                                                        )
                                                        : null,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  shuffledRightItems[index],
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  textAlign: TextAlign.center,
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
            if (_showPauseMenu)
              MatchingPauseMenu(
                isEnglish: isEnglish,
                isSoundOn: _isSoundOn,
                onResume: () => setState(() => _showPauseMenu = false),
                onToggleSound: () => setState(() => _isSoundOn = !_isSoundOn),
                onHome: () {
                  setState(() => _showPauseMenu = false);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const MatchingQuestionsScreen(),
                    ),
                    (route) => false,
                  );
                },
                onEntryScreen: () {
                  setState(() => _showPauseMenu = false);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                onDismiss: () => setState(() => _showPauseMenu = false),
              ),
          ],
        ),
      ),
    );
  }
}
