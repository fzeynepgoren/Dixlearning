import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'soru3.dart';
import '../screens/matching_questions_screen.dart';
import '../screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/matching_pause_menu.dart';

class DuyuOrganEsle extends StatefulWidget {
  const DuyuOrganEsle({super.key});

  @override
  State<DuyuOrganEsle> createState() => _DuyuOrganEsleState();
}

class _DuyuOrganEsleState extends State<DuyuOrganEsle>
    with TickerProviderStateMixin {
  final List<String> leftOrgans = ['👁️', '👂', '👅', '👃'];
  final List<String> rightSenses = ['Görme', 'Duyma', 'Tatma', 'Koklama'];

  late List<String> shuffledSenses;
  int? selectedLeftIndex;
  int? selectedRightIndex;

  List<bool> matchedLeft = [false, false, false, false];
  List<bool> matchedRight = [false, false, false, false];

  bool showFeedback = false;
  bool isCorrect = false;
  bool _dialogShown = false;
  bool _showPauseMenu = false;
  bool _isSoundOn = true;

  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final Map<String, String> organToSense = {
    '👁️': 'Görme',
    '👂': 'Duyma',
    '👅': 'Tatma',
    '👃': 'Koklama',
  };

  @override
  void initState() {
    super.initState();
    shuffledSenses = List.from(rightSenses);
    do {
      shuffledSenses.shuffle();
    } while (_listsAreEqual(leftOrgans, shuffledSenses));

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
      if (organToSense[a[i]] == b[i]) return true;
    }
    return false;
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
      String left = leftOrgans[selectedLeftIndex!];
      String right = shuffledSenses[selectedRightIndex!];
      setState(() {
        isCorrect = organToSense[left] == right;
        showFeedback = true;
      });
      _feedbackController.forward(from: 0);

      if (isCorrect) {
        setState(() {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;
        });

        if (matchedLeft.every((e) => e) && !_dialogShown) {
          _dialogShown = true;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              ActivityTracker.completeActivity();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Soru3()),
              );
            }
          });
        }
      } else {
        // yanlışta explicit bir şey yapmana gerek yok; renkler showFeedback/isCorrect ile yönetiliyor
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
                  mainAxisAlignment: MainAxisAlignment.start,
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
                          width: 64,
                          height: 64,
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
                                color: Colors.purple.shade800.withOpacity(0.5),
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
                          child: const Icon(
                            Icons.home_rounded,
                            color: Colors.black,
                            size: 36,
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
                          const Text(
                            'Duyu organlarını duyularla eşleştir!',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          Expanded(
                            child: Row(
                              children: [
                                // SOL: organ emojileri
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      leftOrgans.length,
                                      (index) => GestureDetector(
                                        onTap: () => _handleLeftTap(index),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                          width: 120,
                                          height: 120,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            // 1) Doğru -> yeşil, 2) Yanlış geri bildirim -> kırmızı,
                                            // 3) Geri bildirim yokken seçili -> mavi, 4) Diğer -> beyaz
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
                                                            : Colors.white)),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              leftOrgans[index],
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

                                // ORTA: gradient çizgi
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

                                // SAĞ: duyular
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      shuffledSenses.length,
                                      (index) => GestureDetector(
                                        onTap: () => _handleRightTap(index),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                          width: 120,
                                          height: 120,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
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
                                                            : Colors.white)),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              shuffledSenses[index],
                                              textAlign: TextAlign.center,
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

                // FEEDBACK
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
                                          isCorrect ? Colors.green : Colors.red,
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
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
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
