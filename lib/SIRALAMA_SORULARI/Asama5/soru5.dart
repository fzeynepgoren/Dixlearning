import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/language_provider.dart';
import 'package:dixlearning/screens/sorting_roadmap_screen_new.dart';
import '../../widgets/in_game_menu.dart';
import '../../screens/home_screen.dart';

class Asama5Soru5 extends StatefulWidget {
  const Asama5Soru5({super.key});

  @override
  State<Asama5Soru5> createState() => _Asama5Soru5State();
}

class _AdvancedStage {
  final String label;
  final String assetPath;
  _AdvancedStage(this.label, this.assetPath);
}

class _Asama5Soru5State extends State<Asama5Soru5>
    with TickerProviderStateMixin {
  late List<_AdvancedStage> stages;
  late List<_AdvancedStage> dragSources;
  bool showFeedback = false;
  bool isCorrect = false;
  bool _isSoundOn = true;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    stages = [
      _AdvancedStage(
        'İlk',
        'assets/SIRALAMA_RESIMLERI/Asama5/soru5/Resim1.png',
      ),
      _AdvancedStage(
        'İkinci',
        'assets/SIRALAMA_RESIMLERI/Asama5/soru5/Resim2.png',
      ),
      _AdvancedStage(
        'Üçüncü',
        'assets/SIRALAMA_RESIMLERI/Asama5/soru5/Resim3.png',
      ),
      _AdvancedStage(
        'Dördüncü',
        'assets/SIRALAMA_RESIMLERI/Asama5/soru5/Resim4.png',
      ),
    ];
    dragSources = List.from(stages)..shuffle();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _saveStageCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sorting_stage_5_completed', true);
  }

  Future<int> _finalizeStars() async {
    final prefs = await SharedPreferences.getInstance();
    // Son soruya kadar birikmiş doğru ve yanlış sayıları al
    int correctCount = prefs.getInt('asama5_session_correct_count') ?? 0;
    int wrongCount = prefs.getInt('asama5_session_wrong_count') ?? 0;

    // Toplam soru sayısı
    int totalCount = correctCount + wrongCount;
    if (totalCount == 0) totalCount = 5; // Fallback

    // Yıldız hesaplama - başarı oranına göre
    double successRate = correctCount / totalCount;
    int stars = 0;

    if (successRate >= 0.75) {
      stars = 3; // %75-100 başarı → 3 yıldız
    } else if (successRate >= 0.50) {
      stars = 2; // %50-75 başarı → 2 yıldız
    } else {
      stars = 1; // %0-50 başarı → 1 yıldız (minimum)
    }

    // Yıldızları kaydet - sadece öncekinden daha iyiyse güncelle
    int previousStars = prefs.getInt('sorting_stage_5_stars') ?? 0;
    if (stars > previousStars) {
      await prefs.setInt('sorting_stage_5_stars', stars);
    } else {
      stars = previousStars; // Önceki yıldız sayısını kullan
    }

    return stars;
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
                            Image.asset(
                              'assets/popup/uzay_popup.png',
                              width: popupWidth,
                              height: popupHeight,
                              fit: BoxFit.contain,
                            ),
                            if (stars > 0)
                              Positioned(
                                top: popupHeight * 0.45,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(stars, (index) {
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
                                                const SortingRoadmapScreenNew(),
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

  // Yıldız sistemi için doğruluk takibi
  Future<void> _saveQuestionResult(bool isCorrect) async {
    final prefs = await SharedPreferences.getInstance();

    // Bu deneme için doğru ve yanlış sayılarını al
    int correctCount = prefs.getInt('asama5_session_correct_count') ?? 0;
    int wrongCount = prefs.getInt('asama5_session_wrong_count') ?? 0;

    if (isCorrect) {
      correctCount++;
    } else {
      wrongCount++;
    }

    // Kaydet
    await prefs.setInt('asama5_session_correct_count', correctCount);
    await prefs.setInt('asama5_session_wrong_count', wrongCount);
  }

  void checkOrder() async {
    // Bu son soru, yıldız hesaplamayı burada yapacağız
    setState(() {
      isCorrect = true;
      for (int i = 0; i < stages.length; i++) {
        if (dragSources[i].label != stages[i].label) {
          isCorrect = false;
          break;
        }
      }
      showFeedback = true;
    });

    _feedbackController.forward(from: 0);

    // Doğruluk sonucunu kaydet
    await _saveQuestionResult(isCorrect);

    // Son soru olduğu için yıldızları hesapla ve popup göster
    if (isCorrect) {
      await _saveStageCompletion();
      int earnedStars = await _finalizeStars();

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _showCompletionDialog(earnedStars);
        }
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            showFeedback = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final screenWidth = MediaQuery.of(context).size.width;

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
                    // Sıralama Alanı Kartı (Başlık ve buton da içinde)
                    Expanded(
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.97),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Başlık
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Text(
                                  isEnglish
                                      ? 'Sort the stages of washing clotes.'
                                      : 'Çamaşır katlama aşamalarını sırala.',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              // Reorderable List
                              Expanded(
                                child: ReorderableListView(
                                  onReorder: (oldIndex, newIndex) {
                                    setState(() {
                                      if (newIndex > oldIndex) newIndex--;
                                      final item = dragSources.removeAt(
                                        oldIndex,
                                      );
                                      dragSources.insert(newIndex, item);
                                    });
                                  },
                                  buildDefaultDragHandles: false,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  children: [
                                    for (int i = 0; i < dragSources.length; i++)
                                      AnimatedContainer(
                                        key: ValueKey(dragSources[i].label),
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 12,
                                          ),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.asset(
                                                  dragSources[i].assetPath,
                                                  width: screenWidth * 0.26,
                                                  height: screenWidth * 0.26,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              const Spacer(),
                                              ReorderableDragStartListener(
                                                index: i,
                                                child: const Icon(
                                                  Icons.drag_handle,
                                                  color: Colors.grey,
                                                  size: 28,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Kontrol Butonu
                              SizedBox(
                                width: double.infinity,
                                height: 35,
                                child: ElevatedButton(
                                  onPressed: checkOrder,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFF8E6A3B,
                                    ), // Kahverengi (Ağaç teması)
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 6,
                                  ),
                                  child: Text(
                                    isEnglish ? 'Check' : 'Kontrol Et',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Geri Bildirim
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
                                    horizontal: 12,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
            InGameMenu(
              isSoundOn: _isSoundOn,
              onToggleSound: () => setState(() => _isSoundOn = !_isSoundOn),
              onHome: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const SortingRoadmapScreenNew(),
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
              iconSize: screenWidth * 0.065,
            ),
          ],
        ),
      ),
    );
  }
}
