import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'soru3.dart';
import '../screens/home_screen.dart';

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

        bool allMatched = matchedLeft.every((e) => e);
        if (allMatched && !_dialogShown) {
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
        body: Container(
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
                // geri oku
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black, size: iconSize),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
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
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.all(12),
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
                                // sol emojiler
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      leftOrgans.length,
                                      (index) => GestureDetector(
                                        onTap: () => _handleLeftTap(index),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          width: 90,
                                          height: 90,
                                          margin: const EdgeInsets.symmetric(vertical: 6),
                                          decoration: BoxDecoration(
                                            color: matchedLeft[index]
                                                ? Colors.green.shade200
                                                : (showFeedback &&
                                                        !isCorrect &&
                                                        selectedLeftIndex == index)
                                                    ? Colors.red.shade200
                                                    : Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            border: (selectedLeftIndex == index &&
                                                    !matchedLeft[index])
                                                ? Border.all(
                                                    color: Colors.lightGreen.shade400,
                                                    width: 3,
                                                  )
                                                : null,
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
                                              leftOrgans[index],
                                              style: const TextStyle(fontSize: 38),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // orta çizgi
                                Container(
                                  width: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),

                                // sağ duyular
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      shuffledSenses.length,
                                      (index) => GestureDetector(
                                        onTap: () => _handleRightTap(index),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          width: 90,
                                          height: 90,
                                          margin: const EdgeInsets.symmetric(vertical: 6),
                                          decoration: BoxDecoration(
                                            color: matchedRight[index]
                                                ? Colors.green.shade200
                                                : (showFeedback &&
                                                        !isCorrect &&
                                                        selectedRightIndex == index)
                                                    ? Colors.red.shade200
                                                    : Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            border: (selectedRightIndex == index &&
                                                    !matchedRight[index])
                                                ? Border.all(
                                                    color: Colors.lightGreen.shade400,
                                                    width: 3,
                                                  )
                                                : null,
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
                                              shuffledSenses[index],
                                              style: const TextStyle(
                                                fontSize: 16,
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

                // feedback alanı
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
                                  isCorrect ? "Aferin! 🎉" : "Tekrar dene! 😔",
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
