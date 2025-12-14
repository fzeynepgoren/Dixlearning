import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/language_provider.dart';
import 'package:dixlearning/screens/sorting_roadmap_screen_new.dart';

class Asama4Soru5 extends StatefulWidget {
  const Asama4Soru5({super.key});

  @override
  State<Asama4Soru5> createState() => _Asama4Soru5State();
}

class _Stage {
  final String label;
  final String assetPath;
  _Stage(this.label, this.assetPath);
}

class _Asama4Soru5State extends State<Asama4Soru5>
    with TickerProviderStateMixin {
  late List<_Stage> stages;
  late List<_Stage> dragSources;
  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    stages = [
      _Stage('1', 'assets/SIRALAMA_RESIMLERI/Asama4/giyinme/giyim1.png'),
      _Stage('2', 'assets/SIRALAMA_RESIMLERI/Asama4/giyinme/giyim2.png'),
      _Stage('3', 'assets/SIRALAMA_RESIMLERI/Asama4/giyinme/giyim3.png'),
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
    await prefs.setBool('sorting_stage_4_completed', true);
  }

  Future<void> _finalizeStars() async {
    final prefs = await SharedPreferences.getInstance();
    // Son soruya kadar birikmiş doğru ve yanlış sayıları al
    int correctCount = prefs.getInt('asama4_session_correct_count') ?? 0;
    int wrongCount = prefs.getInt('asama4_session_wrong_count') ?? 0;

    // Yıldız hesaplama - yanlış oranına göre
    if (correctCount + wrongCount == 5) {
      double wrongRatio = wrongCount / 5;
      int stars = 0;

      if (wrongRatio <= 0.25) {
        stars = 3;
      } else if (wrongRatio <= 0.50) {
        stars = 2;
      } else {
        stars = 1;
      }

      await prefs.setInt('sorting_stage_4_stars', stars);
    }
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
                        opacity: value.clamp(0.0, 1.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Şeker popup görseli
                            Image.asset(
                              'assets/popup/seker_popup.png',
                              width: popupWidth,
                              height: popupHeight,
                              fit: BoxFit.contain,
                            ),
                            // Yıldız sayısına göre göster
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
                                              'assets/popup/lolipop.png',
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
                            // MENÜYE GİT butonu - görünmez
                            Positioned(
                              bottom: popupHeight * 0.28,
                              left: popupWidth * 0.15,
                              right: popupWidth * 0.15,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const SortingRoadmapScreenNew(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: (popupHeight * 0.1).clamp(45.0, 65.0),
                                  color: Colors.transparent,
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
    int correctCount = prefs.getInt('asama4_session_correct_count') ?? 0;
    int wrongCount = prefs.getInt('asama4_session_wrong_count') ?? 0;

    if (isCorrect) {
      correctCount++;
    } else {
      wrongCount++;
    }

    // Kaydet
    await prefs.setInt('asama4_session_correct_count', correctCount);
    await prefs.setInt('asama4_session_wrong_count', wrongCount);

    // Yıldız hesaplama: Birkaç denemede doğru = 2 yıldız, %100 doğru = 3 yıldız
    int totalQuestions = correctCount + wrongCount;
    if (totalQuestions >= 5) {
      // 5 soru tamamlandığında - yanlış oranına göre yıldız hesapla
      double wrongRatio = wrongCount / totalQuestions;
      int stars = 0;

      if (wrongRatio <= 0.25) {
        // %25 veya daha az yanlış
        stars = 3;
      } else if (wrongRatio <= 0.50) {
        // %50 veya daha az yanlış
        stars = 2;
      } else {
        // %50 üzeri yanlış
        stars = 1;
      }

      await prefs.setInt('sorting_stage_4_stars', stars);
    }
  }

  void checkOrder() async {
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

    if (isCorrect) {
      // Save completion status
      await _saveStageCompletion();
      await _finalizeStars();

      Future.delayed(const Duration(seconds: 2), () async {
        if (mounted) {
          setState(() {
            showFeedback = false;
          });
          final prefs = await SharedPreferences.getInstance();
          int stars = prefs.getInt('sorting_stage_4_stars') ?? 0;
          _showCompletionDialog(stars);
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
                // Üst kısım - Geri butonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 28,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder:
                                (context) => const SortingRoadmapScreenNew(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
                // Sıralama Kartı
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
                                  ? 'Sort the dressing order.'
                                  : 'Giyinme sırasını sırala.',
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
                                  final item = dragSources.removeAt(oldIndex);
                                  dragSources.insert(newIndex, item);
                                });
                              },
                              buildDefaultDragHandles: false,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              children: [
                                for (int i = 0; i < dragSources.length; i++)
                                  AnimatedContainer(
                                    key: ValueKey(dragSources[i].label),
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 12,
                                          offset: Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 20,
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                            child: Image.asset(
                                              dragSources[i].assetPath,
                                              width: screenWidth * 0.32,
                                              height: screenWidth * 0.32,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const Spacer(),
                                          ReorderableDragStartListener(
                                            index: i,
                                            child: const Icon(
                                              Icons.drag_handle,
                                              color: Colors.grey,
                                              size: 32,
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
                                backgroundColor: const Color(0xFFF1E6A4),
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
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                        ? (isEnglish
                                            ? 'Well done! 🎉'
                                            : 'Aferin! 🎉')
                                        : (isEnglish
                                            ? 'Try again! 😔'
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
