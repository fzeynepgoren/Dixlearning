import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/matching_questions_screen.dart'; // Ana menü ekranının yolu
import '../screens/home_screen.dart';
import '../widgets/in_game_menu.dart';

class HayvanEsle extends StatefulWidget {
  const HayvanEsle({super.key});

  @override
  State<HayvanEsle> createState() => _HayvanEsleState();
}

class _HayvanEsleState extends State<HayvanEsle> with TickerProviderStateMixin {
  final List<String> leftAnimals = ['🦜', '🐠', '🐢'];
  late List<String> rightAnimals;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = [false, false, false];
  List<bool> matchedRight = [false, false, false];
  bool showFeedback = false;
  bool isCorrect = false;
  bool _isSoundOn = true;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    rightAnimals = List.from(leftAnimals)..shuffle();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _saveStageCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('asama1_completed', true);
  }

  Future<void> _trackWrongAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('asama1_wrong_count') ?? 0;
    wrongCount++;
    await prefs.setInt('asama1_wrong_count', wrongCount);
  }

  Future<int> _calculateStars() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('asama1_wrong_count') ?? 0;
    const int totalItems = 3; // Toplam item sayısı
    
    // Başarı oranına göre yıldız hesapla
    double successRate = totalItems / (totalItems + wrongCount);
    
    if (successRate >= 0.75) {
      return 3; // %75-100 başarı → 3 yıldız
    } else if (successRate >= 0.50) {
      return 2; // %50-75 başarı → 2 yıldız
    } else {
      return 1; // %0-50 başarı → 1 yıldız (minimum)
    }
  }

  void _handleTap(int index, bool isLeft) {
    if (showFeedback) return;
    setState(() {
      if (isLeft) {
        if (matchedLeft[index]) return;
        selectedLeftIndex = index;
      } else {
        if (matchedRight[index]) return;
        selectedRightIndex = index;
      }

      if (selectedLeftIndex != null && selectedRightIndex != null) {
        isCorrect =
            leftAnimals[selectedLeftIndex!] ==
            rightAnimals[selectedRightIndex!];
        showFeedback = true;
        _feedbackController.forward(from: 0);

        if (isCorrect) {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;

          if (matchedLeft.every((element) => element)) {
            _saveStageCompletion();
            Future.delayed(const Duration(seconds: 2), () async {
              if (mounted) {
                final prefs = await SharedPreferences.getInstance();
                // Önce yanlış sayısını al ve kaydet (daha sonra kullanılabilir)
                int wrongCount = prefs.getInt('asama1_wrong_count') ?? 0;
                await prefs.setInt('asama1_final_wrong_count', wrongCount);

                // Yıldız hesapla
                int stars = await _calculateStars();

                // Yanlış sayısını sıfırla (bir sonraki aşama için)
                await prefs.setInt('asama1_wrong_count', 0);

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
            });
          } else {
            // Feedback'i 2 saniye sonra gizle
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
        } else {
          // Yanlış cevap için feedback'i 2 saniye sonra gizle
          _trackWrongAnswer();
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
      }
    });
  }

  Widget buildItem({
    required String emoji,
    required bool isSelected,
    required bool isMatched,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:
            showFeedback ? Duration.zero : const Duration(milliseconds: 300),
        width: 120,
        height: 120,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color:
              isMatched
                  ? Colors.green.shade400
                  : (showFeedback && !isCorrect && isSelected)
                  ? Colors.red.shade400
                  : isSelected
                  ? Colors.blue.shade200
                  : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 48))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                              'Sevimli hayvanları eşleştirin!',
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
                                      leftAnimals.length,
                                      (index) => GestureDetector(
                                        onTap: () => _handleTap(index, true),
                                        child: AnimatedContainer(
                                          duration:
                                              showFeedback
                                                  ? Duration.zero
                                                  : const Duration(
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
                                                matchedLeft[index]
                                                    ? Colors.green.shade400
                                                    : (showFeedback &&
                                                        selectedLeftIndex ==
                                                            index &&
                                                        !isCorrect)
                                                    ? Colors.red.shade400
                                                    : (selectedLeftIndex ==
                                                        index)
                                                    ? Colors.blue.shade200
                                                    : Colors.white,
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
                                              leftAnimals[index],
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

                                // BAŞLANGIÇ: MAVİ GRADYAN ÇİZGİ BÖLÜMÜ (425.0 Yüksekliğe Ayarlandı)
                                SizedBox(
                                  height:
                                      425.0, // Çizginin uzunluğu (yüksekliği)
                                  child: Container(
                                    width: 4,
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
                                ),

                                // SON: MAVİ GRADYAN ÇİZGİ BÖLÜMÜ
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      rightAnimals.length,
                                      (index) => GestureDetector(
                                        onTap: () => _handleTap(index, false),
                                        child: AnimatedContainer(
                                          duration:
                                              showFeedback
                                                  ? Duration.zero
                                                  : const Duration(
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
                                                    : (showFeedback &&
                                                        selectedRightIndex ==
                                                            index &&
                                                        !isCorrect)
                                                    ? Colors.red.shade400
                                                    : (selectedRightIndex ==
                                                        index)
                                                    ? Colors.blue.shade200
                                                    : Colors.white,
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
                                              rightAnimals[index],
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
                              ],
                            ),
                          ),
                        ],
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
