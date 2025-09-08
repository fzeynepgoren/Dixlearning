import 'package:dixlearning/asama1/soru3.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../utils/activity_tracker.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class GDisgrafi1 extends StatefulWidget {
  const GDisgrafi1({super.key});

  @override
  State<GDisgrafi1> createState() => _GDisgrafi1State();
}

class _GDisgrafi1State extends State<GDisgrafi1> with TickerProviderStateMixin {
  final List<String> leftToys = ['⚽', '🧸', '🚂', '🎮'];
  late List<String> rightToys;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = List.filled(4, false);
  List<bool> matchedRight = List.filled(4, false);
  int matchedPairs = 0;
  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    rightToys = List.from(leftToys);
    do {
      rightToys.shuffle();
    } while (_listsAreEqual(leftToys, rightToys));

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

  bool _listsAreEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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
      setState(() {
        isCorrect = leftToys[selectedLeftIndex!] == rightToys[selectedRightIndex!];
        showFeedback = true;
      });
      _feedbackController.forward(from: 0);

      if (isCorrect) {
        setState(() {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;
          matchedPairs++;
        });

        if (matchedPairs == leftToys.length) {
          ActivityTracker.completeActivity();

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const GeometricMatching(),
                ),
              );
            }
          });
        }
      }

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            selectedLeftIndex = null;
            selectedRightIndex = null;
            if (!isCorrect) {
              showFeedback = false;
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final iconSize = screenWidth * 0.065;

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Text(
                      isEnglish ? 'Match the Toys' : 'Oyuncakları Eşleştir',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(width: 48), // Denge için
                  ],
                ),
                const SizedBox(height: 15),
                Expanded( // Burayı Expanded olarak geri aldık
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column( // İçteki Column ekledim ki Expanded doğru çalışsın
                        children: [
                          Expanded( // Bu Expanded, oyuncakların listelerinin tüm mevcut alanı kaplamasını sağlar
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      leftToys.length,
                                      (index) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: GestureDetector(
                                          onTap: () => _handleLeftTap(index),
                                          child: Container(
                                            width: 90,
                                            height: 90,
                                            decoration: BoxDecoration(
                                              color: matchedLeft[index]
                                                  ? Colors.green.shade300
                                                  : (showFeedback &&
                                                          !isCorrect &&
                                                          selectedLeftIndex == index)
                                                      ? Colors.red.shade200
                                                      : selectedLeftIndex == index
                                                          ? Colors.blue.shade200
                                                          : Colors.white,
                                              borderRadius: BorderRadius.circular(20),
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
                                                leftToys[index],
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
                                ),
                                Container(
                                  width: 4,
                                  height: screenSize.height * 0.5, // Bu yüksekliği sabit tuttum
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      rightToys.length,
                                      (index) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: GestureDetector(
                                          onTap: () => _handleRightTap(index),
                                          child: Container(
                                            width: 90,
                                            height: 90,
                                            decoration: BoxDecoration(
                                              color: matchedRight[index]
                                                  ? Colors.green.shade300
                                                  : (showFeedback &&
                                                          !isCorrect &&
                                                          selectedRightIndex == index)
                                                      ? Colors.red.shade200
                                                      : selectedRightIndex == index
                                                          ? Colors.blue.shade200
                                                          : Colors.white,
                                              borderRadius: BorderRadius.circular(20),
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
                                                rightToys[index],
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
                                ),
                              ],
                            ),
                          ),
                          // Geri bildirim mesajı, ana içerik kartının hemen altında yer alacak.
                          if (showFeedback)
                            Container(
                              height: 80, // Geri bildirim mesajı için sabit bir yükseklik
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: ScaleTransition(
                                scale: CurvedAnimation(
                                  parent: _feedbackController,
                                  curve: Curves.elasticOut,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Buradaki Spacer kaldırıldı, çünkü ana içerik Expanded ile geri kalan alanı dolduruyor.
                // Ve geri bildirim mesajı ana Column içinde yer alıyor.
              ],
            ),
          ),
        ),
      ),
    );
  }
}