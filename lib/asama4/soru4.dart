import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import '../screens/matching_questions_screen.dart';
import 'soru5.dart';

class MevsimHavaEsle extends StatefulWidget {
  const MevsimHavaEsle({super.key});

  @override
  State<MevsimHavaEsle> createState() => _MevsimHavaEsleState();
}

class _MevsimHavaEsleState extends State<MevsimHavaEsle>
    with TickerProviderStateMixin {
  final List<String> leftSeasons = ['🌞', '❄️', '🌸', '🍂'];
  final List<String> rightWeather = ['Yaz', 'Kış', 'İlkbahar', 'Sonbahar'];

  late List<String> shuffledWeather;

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

  /// Emoji -> Doğru mevsim adı
  final Map<String, String> itemToName = const {
    '🌞': 'Yaz',
    '❄️': 'Kış',
    '🌸': 'İlkbahar',
    '🍂': 'Sonbahar',
  };

  @override
  void initState() {
    super.initState();

    // Sağ listeyi hizalı doğru eşleşme olmayacak şekilde karıştır
    shuffledWeather = List.from(rightWeather);
    do {
      shuffledWeather.shuffle();
    } while (_hasAnyAlignedCorrectPair(leftSeasons, shuffledWeather));

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

  /// Aynı indekslerde doğru eşleşme var mı? (Başlangıç shuffle kontrolü için)
  bool _hasAnyAlignedCorrectPair(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (int i = 0; i < left.length; i++) {
      if (itemToName[left[i]] == right[i]) return true;
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
    setState(() => selectedLeftIndex = index);
    _checkMatch();
  }

  void _handleRightTap(int index) {
    if (matchedRight[index]) return;
    setState(() => selectedRightIndex = index);
    _checkMatch();
  }

  void _checkMatch() {
    if (selectedLeftIndex == null || selectedRightIndex == null) return;

    final String left = leftSeasons[selectedLeftIndex!];
    final String right = shuffledWeather[selectedRightIndex!];

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

      // Tüm eşleşmeler tamamlandıysa sıradaki ekrana geç
      if (matchedLeft.every((e) => e) && !_dialogShown) {
        _dialogShown = true;

        // Etkinlik tamamlandı
        ActivityTracker.completeActivity();

        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const EmojiAnimalMatching(),
            ),
          );
        });
      }
    } else {
      // Yanlış eşleşmede state kilidi yok; yalnızca geri bildirim gösteriliyor
      setState(() {
        matchedLeft[selectedLeftIndex!] = false;
        matchedRight[selectedRightIndex!] = false;
      });
    }

    // 1 sn sonra seçimleri sıfırla
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        showFeedback = false;
        selectedLeftIndex = null;
        selectedRightIndex = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Sistem geri tuşu: HomeScreen’e dön ve stack’i temizle
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MatchingQuestionsScreen(),
          ),
          (route) => false,
        );
        return false;
      },
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
                // Üst geri düğmesi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder:
                                (context) => const MatchingQuestionsScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),

                // İçerik kartı
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
                              'Mevsimleri hava durumlarıyla eşleştir!',
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
                                // SOL SÜTUN: Emojiler
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      leftSeasons.length,
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
                                            // 1) matched -> yeşil
                                            // 2) geri bildirim var ve yanlış seçili -> kırmızı
                                            // 3) geri bildirim yok ve seçili -> mavi
                                            // 4) diğer -> beyaz
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
                                              leftSeasons[index],
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

                                // AYIRICI: mavi gradient çizgi
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

                                // SAĞ SÜTUN: Mevsim adları
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      shuffledWeather.length,
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
                                              shuffledWeather[index],
                                              style: const TextStyle(
                                                fontSize: 24,
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

                // ALT GERİ BİLDİRİM BANDI
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
      ),
    );
  }
}
