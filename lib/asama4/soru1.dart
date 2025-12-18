import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'package:dixlearning/asama4/soru2.dart';
import '../screens/matching_questions_screen.dart';
import '../screens/home_screen.dart';
import '../widgets/in_game_menu.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DuyguYuzEsle extends StatefulWidget {
  const DuyguYuzEsle({super.key});

  @override
  State<DuyguYuzEsle> createState() => _DuyguYuzEsleState();
}

class _DuyguYuzEsleState extends State<DuyguYuzEsle>
    with TickerProviderStateMixin {
  final List<String> leftItems = ['😊', '😠', '😢', '😲'];
  final List<String> rightItems = ['Mutlu', 'Kızgın', 'Üzgün', 'Şaşkın'];
  late List<String> shuffledRightItems;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = [false, false, false, false];
  List<bool> matchedRight = [false, false, false, false];
  bool showFeedback = false;
  bool isCorrect = false;
  bool _isSoundOn = true;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _dialogShown = false;
  bool _wrongCountReset = false;

  final Map<String, String> itemToName = {
    '😊': 'Mutlu',
    '😠': 'Kızgın',
    '😢': 'Üzgün',
    '😲': 'Şaşkın',
  };

  @override
  void initState() {
    super.initState();
    shuffledRightItems = List.from(rightItems);
    do {
      shuffledRightItems.shuffle();
    } while (_listsAreEqual(leftItems, shuffledRightItems));

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

  bool _listsAreEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (itemToName[a[i]] == b[i]) return true;
    }
    return false;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Aşama başında yanlış sayısını kesinlikle sıfırla (sadece bir kez)
    if (!_wrongCountReset) {
      _resetWrongCount();
    }
  }

  Future<void> _resetWrongCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('asama4_wrong_count', 0);
    _wrongCountReset = true;
  }

  Future<void> _trackWrongAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('asama4_wrong_count') ?? 0;
    wrongCount++;
    await prefs.setInt('asama4_wrong_count', wrongCount);
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

        if (matchedLeft.every((element) => element) && !_dialogShown) {
          _dialogShown = true;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              // Etkinlik tamamlandı

              ActivityTracker.completeActivity();
              Provider.of<ProgressProvider>(
                context,
                listen: false,
              ).completeStage4();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DuyuOrganEsle()),
              );
            }
          });
        }
      } else {
        // Yanlış eşleşme
        _trackWrongAnswer();
        setState(() {
          matchedLeft[selectedLeftIndex!] = false;
          matchedRight[selectedRightIndex!] = false;
        });
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
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
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
                                child: const Text(
                                  'Yüz ifadelerini duygularla eşleştir!',
                                  style: TextStyle(
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
                                              // SOL SÜTUN: AnimatedContainer > decoration
                                              decoration: BoxDecoration(
                                                // RENK MANTIĞI:
                                                // 1) Doğru eşleşmişse (matched): yeşil
                                                // 2) Geri bildirim anında yanlış seçilmişse: kırmızı
                                                // 3) Geri bildirim yokken sadece seçiliyse: mavi
                                                // 4) Diğer durumlarda: beyaz
                                                color:
                                                    matchedLeft[index]
                                                        ? Colors.green.shade400
                                                        : (showFeedback
                                                            ? ((selectedLeftIndex ==
                                                                        index &&
                                                                    !isCorrect)
                                                                ? Colors
                                                                    .red
                                                                    .shade400
                                                                : Colors.white)
                                                            : (selectedLeftIndex ==
                                                                    index
                                                                ? Colors
                                                                    .blue
                                                                    .shade200
                                                                : Colors
                                                                    .white)),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                // ÖNCEKİ YEŞİL BORDER'I KALDIRDIK -> border: null
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
                                                    fontSize: 48,
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
                                      height: 475,
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
                                                // 1) Doğru eşleşmişse yeşil
                                                // 2) Yanlış eşleşmede kırmızı
                                                // 3) Seçiliyse mavi
                                                // 4) Diğer durumlarda beyaz
                                                color:
                                                    matchedRight[index]
                                                        ? Colors.green.shade400
                                                        : (showFeedback
                                                            ? ((selectedRightIndex ==
                                                                        index &&
                                                                    !isCorrect)
                                                                ? Colors
                                                                    .red
                                                                    .shade400
                                                                : Colors.white)
                                                            : (selectedRightIndex ==
                                                                    index
                                                                ? Colors
                                                                    .blue
                                                                    .shade200
                                                                : Colors
                                                                    .white)),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                // border’ı tamamen kaldırıyoruz
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
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
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
