import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/matching_questions_screen.dart';
import '../screens/home_screen.dart';
import '../widgets/in_game_menu.dart';
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
  bool _isSoundOn = true;
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

  Future<void> _trackWrongAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('asama4_wrong_count') ?? 0;
    wrongCount++;
    await prefs.setInt('asama4_wrong_count', wrongCount);
  }

  Future<int> _calculateStars() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('asama4_wrong_count') ?? 0;
    const int totalItems = 4; // Toplam item sayısı
    
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

      // Tüm eşleşmeler tamamlanınca uzay temalı pop-up
      if (matchedLeft.every((e) => e) && !_dialogShown) {
        _saveStageCompletion();
        _dialogShown = true;
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (!mounted) return;
          final prefs = await SharedPreferences.getInstance();
          int wrongCount = prefs.getInt('asama4_wrong_count') ?? 0;
          await prefs.setInt('asama4_final_wrong_count', wrongCount);

          int stars = await _calculateStars();
          
          // Yıldızları kaydet (roadmap için) - sadece öncekinden daha iyiyse güncelle
          int previousStars = prefs.getInt('matching_stage_4_stars') ?? 0;
          if (stars > previousStars) {
            await prefs.setInt('matching_stage_4_stars', stars);
          } else {
            stars = previousStars; // Önceki yıldız sayısını kullan
          }
          
          await prefs.setInt('asama4_wrong_count', 0);

          _showCompletionDialog(stars);
        });
      }
    } else {
      _trackWrongAnswer();
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
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.065;

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
                    // Üst geri düğmesi
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
                                              margin:
                                                  const EdgeInsets.symmetric(
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
                                                                : Colors
                                                                    .white)),
                                                borderRadius:
                                                    BorderRadius.circular(20),
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
                                              margin:
                                                  const EdgeInsets.symmetric(
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
                                                                : Colors
                                                                    .white)),
                                                borderRadius:
                                                    BorderRadius.circular(20),
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
                                            isCorrect
                                                ? Colors.green
                                                : Colors.red,
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

  void _showCompletionDialog(int stars) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
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
                                    final individualSize = (popupWidth * 0.15)
                                        .clamp(40.0, 80.0);
                                    return TweenAnimationBuilder<double>(
                                      duration: Duration(
                                        milliseconds: 400 + (index * 200),
                                      ),
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
                                        builder:
                                            (context) =>
                                                const MatchingQuestionsScreen(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: double.infinity,
                                    height: (popupHeight * 0.1).clamp(
                                      45.0,
                                      65.0,
                                    ),
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
}
