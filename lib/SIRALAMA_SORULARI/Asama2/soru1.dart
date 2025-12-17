import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/language_provider.dart';
import 'soru2.dart';
import 'package:dixlearning/screens/sorting_roadmap_screen_new.dart';
import '../../widgets/in_game_menu.dart';
import '../../screens/home_screen.dart';

class Asama2Soru1 extends StatefulWidget {
  const Asama2Soru1({super.key});

  @override
  State<Asama2Soru1> createState() => _Asama2Soru1State();
}

class _TimeStage {
  final String label;
  final String assetPath;
  _TimeStage(this.label, this.assetPath);
}

class _Asama2Soru1State extends State<Asama2Soru1>
    with TickerProviderStateMixin {
  late List<_TimeStage> stages;
  late List<_TimeStage> dragSources;
  bool showFeedback = false;
  bool isCorrect = false;
  bool _isSoundOn = true;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    stages = [
      _TimeStage(
        'Sabah',
        'assets/SIRALAMA_RESIMLERI/Asama2/soru1/gun_dogumu.png',
      ),
      _TimeStage(
        'Öğle',
        'assets/SIRALAMA_RESIMLERI/Asama2/soru1/gunes_tepede.png',
      ),
      _TimeStage('Akşam', 'assets/SIRALAMA_RESIMLERI/Asama2/soru1/aksam.png'),
    ];
    dragSources = List.from(stages)..shuffle();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    final prefs = await SharedPreferences.getInstance();
    // Her aşama başında session sayacını sıfırla
    await prefs.setInt('asama2_session_correct_count', 0);
    await prefs.setInt('asama2_session_wrong_count', 0);
    // Son tamamlanma zamanını kaydet
    await prefs.setString(
      'asama2_last_session_time',
      DateTime.now().toIso8601String(),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // Yıldız sistemi için doğruluk takibi
  Future<void> _saveQuestionResult(bool isCorrect) async {
    final prefs = await SharedPreferences.getInstance();

    // Bu deneme için doğru ve yanlış sayılarını al
    int correctCount = prefs.getInt('asama2_session_correct_count') ?? 0;
    int wrongCount = prefs.getInt('asama2_session_wrong_count') ?? 0;

    if (isCorrect) {
      correctCount++;
    } else {
      wrongCount++;
    }

    // Kaydet
    await prefs.setInt('asama2_session_correct_count', correctCount);
    await prefs.setInt('asama2_session_wrong_count', wrongCount);
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
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Asama2Soru2()),
          );
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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

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
                            horizontal: 20,
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
                                      ? 'Sort the times of day in the correct order.'
                                      : 'Günün zamanlarını doğru sıraya koy.',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              // Sıralama Alanı
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
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                                                borderRadius:
                                                    BorderRadius.circular(50),
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
                                  onPressed: !showFeedback ? checkOrder : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFFFFF59D,
                                    ), // Çok Açık Sarı (Güneş teması)
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 6,
                                  ),
                                  child: Text(
                                    isEnglish ? 'Check' : 'Kontrol Et',
                                    style: const TextStyle(
                                      fontSize: 22,
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
                    // Geri Bildirim Alanı
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
