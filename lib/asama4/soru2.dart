import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'dart:async';
import 'package:dixlearning/asama4/soru3.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../screens/home_screen.dart';

class DuyuOrganEsle extends StatefulWidget {
  const DuyuOrganEsle({super.key});

  @override
  State<DuyuOrganEsle> createState() => _DuyuOrganEsleState();
}

class _DuyuOrganEsleState extends State<DuyuOrganEsle>
    with TickerProviderStateMixin {
  final List<String> leftOrgans = ['👅', '👃', '👁️', '👂'];
  final List<String> rightSenses = ['Tat alma', 'Koklama', 'Görme', 'İşitme'];
  final List<String> rightSensesEnglish = ['Taste', 'Smell', 'Sight', 'Hearing'];

  late List<String> shuffledSenses;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = [false, false, false, false];
  List<bool> matchedRight = [false, false, false, false];
  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    final isEnglish =
        Provider.of<LanguageProvider>(context, listen: false).isEnglish;
    shuffledSenses =
        List.from(isEnglish ? rightSensesEnglish : rightSenses)..shuffle();

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
    setState(() {
      if (isLeft) {
        if (matchedLeft[index]) return;
        selectedLeftIndex = index;
      } else {
        if (matchedRight[index]) return;
        selectedRightIndex = index;
      }

      if (selectedLeftIndex != null && selectedRightIndex != null) {
        final isEnglish =
            Provider.of<LanguageProvider>(context, listen: false).isEnglish;
        final rightSensesList = isEnglish ? rightSensesEnglish : rightSenses;

        isCorrect = (leftOrgans[selectedLeftIndex!] == '👅' &&
                shuffledSenses[selectedRightIndex!] == rightSensesList[0]) ||
            (leftOrgans[selectedLeftIndex!] == '👃' &&
                shuffledSenses[selectedRightIndex!] == rightSensesList[1]) ||
            (leftOrgans[selectedLeftIndex!] == '👁️' &&
                shuffledSenses[selectedRightIndex!] == rightSensesList[2]) ||
            (leftOrgans[selectedLeftIndex!] == '👂' &&
                shuffledSenses[selectedRightIndex!] == rightSensesList[3]);

        showFeedback = true;
        _feedbackController.forward(from: 0);

        if (isCorrect) {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;

          bool allMatched = matchedLeft.every((e) => e);
          if (allMatched && !_dialogShown) {
            _dialogShown = true;
            ActivityTracker.completeActivity();

            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const Soru3()),
                );
              }
            });
          }
        }

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              showFeedback = false;
              selectedLeftIndex = null;
              selectedRightIndex = null;
            });
          }
        });
      }
    });
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
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(16),
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
                                horizontal: 20, vertical: 1),
                            child: Text(
                              isEnglish
                                  ? 'Match the organs with their senses.'
                                  : 'Organları ilgili duyu ile eşleştir',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Row(
                              children: [
                                // Sol organlar
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      leftOrgans.length,
<<<<<<< HEAD
                                          (index) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: GestureDetector(
                                            onTap: () => _handleTap(index, true),
                                            child: Container(
                                              margin: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: matchedLeft[index]
                                                    ? Colors.green.shade500
                                                    : (showFeedback &&
                                                    !isCorrect &&
                                                    selectedLeftIndex == index)
                                                    ? Colors.red.shade500
                                                    : selectedLeftIndex == index
                                                    ? Colors.blue.shade200
                                                    : Colors.white,
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  leftOrgans[index],
                                                  style: const TextStyle(fontSize: 60),
=======
                                      (index) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: GestureDetector(
                                          onTap: () => _handleTap(index, true),
                                          child: AnimatedContainer(
                                            duration:
                                                const Duration(milliseconds: 300),
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: matchedLeft[index]
                                                  ? Colors.green
                                                  : (showFeedback &&
                                                          !isCorrect &&
                                                          selectedLeftIndex ==
                                                              index)
                                                      ? Colors.red
                                                      : selectedLeftIndex == index
                                                          ? Colors.blue.shade200
                                                          : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
>>>>>>> esma_eslemesoruları_temaguncelleme
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                leftOrgans[index],
                                                style: const TextStyle(
                                                    fontSize: 32),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Orta çizgi
                                Container(
                                  width: 4,
                                  height: screenSize.height * 0.55,
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
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
                                // Sağ duyular
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      shuffledSenses.length,
<<<<<<< HEAD
                                          (index) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: GestureDetector(
                                            onTap: () => _handleTap(index, false),
                                            child: Container(
                                              margin: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: matchedRight[index]
                                                    ? Colors.green.shade500
                                                    : (showFeedback &&
                                                    !isCorrect &&
                                                    selectedRightIndex == index)
                                                    ? Colors.red.shade500
                                                    : selectedRightIndex == index
                                                    ? Colors.blue.shade200
                                                    : Colors.white,
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  shuffledSenses[index],
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
=======
                                      (index) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: GestureDetector(
                                          onTap: () => _handleTap(index, false),
                                          child: AnimatedContainer(
                                            duration:
                                                const Duration(milliseconds: 300),
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: matchedRight[index]
                                                  ? Colors.green
                                                  : (showFeedback &&
                                                          !isCorrect &&
                                                          selectedRightIndex ==
                                                              index)
                                                      ? Colors.red
                                                      : selectedRightIndex == index
                                                          ? Colors.yellow.shade200
                                                          : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                shuffledSenses[index],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black, // 🔹 siyah yapıldı
>>>>>>> esma_eslemesoruları_temaguncelleme
                                                ),
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
                // Feedback alanı
                Container(
                  height: 70,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: showFeedback
                      ? ScaleTransition(
                          scale: CurvedAnimation(
                            parent: _feedbackController,
                            curve: Curves.elasticOut,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect ? Colors.green : Colors.red,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
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
                                  color: isCorrect ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
