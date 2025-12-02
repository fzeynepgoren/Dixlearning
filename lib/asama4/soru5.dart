import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/matching_questions_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class EmojiAnimalMatching extends StatefulWidget {
  const EmojiAnimalMatching({super.key});

  @override
  State<EmojiAnimalMatching> createState() => _EmojiAnimalMatchingState();
}

class _EmojiAnimalMatchingState extends State<EmojiAnimalMatching>
    with TickerProviderStateMixin {
  final List<String> leftEmojis = ['🐶', '🐱', '🐰', '🐼'];
  final List<String> rightAnimals = ['Köpek', 'Kedi', 'Tavşan', 'Panda'];

  late List<String> shuffledAnimals;

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

  /// Emoji -> Doğru hayvan adı
  final Map<String, String> itemToName = const {
    '🐶': 'Köpek',
    '🐱': 'Kedi',
    '🐰': 'Tavşan',
    '🐼': 'Panda',
  };

  @override
  void initState() {
    super.initState();

    // Sağ listeyi hizalı doğru eşleşme olmayacak şekilde karıştır
    shuffledAnimals = List.from(rightAnimals);
    do {
      shuffledAnimals.shuffle();
    } while (_hasAnyAlignedCorrectPair(leftEmojis, shuffledAnimals));

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

  Future<void> _saveStageCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('asama4_completed', true);
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

    final String left = leftEmojis[selectedLeftIndex!];
    final String right = shuffledAnimals[selectedRightIndex!];

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

      // Tüm eşleşmeler tamamlanınca tebrik diyaloğu
      if (matchedLeft.every((e) => e) && !_dialogShown) {
        _saveStageCompletion();
        _dialogShown = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue.shade100, Colors.blue.shade50],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 80,
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Tebrikler! 🎉',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '4. aşamayı tamamladınız!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const MatchingQuestionsScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade200,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Ana Menüye Dön',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          );
        });
      }
    } else {
      // Yanlış eşleşme — yalnızca geri bildirim, state kilidi yok
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
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;

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

                // İçerik kartı + animasyon
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
                                  ? 'Match the emojis with the animals!'
                                  : 'Emojileri hayvanlarla eşleştir!',
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
                                // SOL SÜTUN: Emojiler
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      leftEmojis.length,
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
                                              leftEmojis[index],
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
                                  height: 550,
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

                                // SAĞ SÜTUN: Hayvan adları
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      shuffledAnimals.length,
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
                                              shuffledAnimals[index],
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
                                    isEnglish
                                        ? (isCorrect
                                            ? 'Great! 🎉'
                                            : 'Try again! 😔')
                                        : (isCorrect
                                            ? 'Aferin! 🎉'
                                            : 'Tekrar dene! 😔'),
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
