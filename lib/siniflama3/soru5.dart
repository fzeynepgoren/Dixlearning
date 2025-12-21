import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../screens/siniflandirma_sorulari_screen.dart';

class HayvanYasamSinifla extends StatefulWidget {
  const HayvanYasamSinifla({super.key});

  @override
  State<HayvanYasamSinifla> createState() => _HayvanYasamSiniflaState();
}

class _HayvanYasamSiniflaState extends State<HayvanYasamSinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {'emoji': '🐟', 'id': 'balik1', 'habitat': 'water', 'isPlaced': false},
    {'emoji': '🐠', 'id': 'balik2', 'habitat': 'water', 'isPlaced': false},
    {'emoji': '🦅', 'id': 'kus1', 'habitat': 'air', 'isPlaced': false},
    {'emoji': '🦜', 'id': 'kus2', 'habitat': 'air', 'isPlaced': false},
    {'emoji': '🦙', 'id': 'kara1', 'habitat': 'land', 'isPlaced': false},
    {'emoji': '🐑', 'id': 'kara2', 'habitat': 'land', 'isPlaced': false},
  ];

  final Map<String, List<Map<String, dynamic>>> habitatGroups = {
    'water': [],
    'air': [],
    'land': [],
  };

  bool showFeedback = false;
  bool isCorrect = false;
  bool _dialogShown = false;

  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    items.shuffle();

    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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

  @override
  void dispose() {
    _feedbackController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _trackWrongAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('siniflama3_wrong_count') ?? 0;
    wrongCount++;
    await prefs.setInt('siniflama3_wrong_count', wrongCount);
  }

  void _handleDrag(Map<String, dynamic> item, String targetHabitat) {
    bool correct = item['habitat'] == targetHabitat;

    setState(() {
      isCorrect = correct;
      showFeedback = true;

      if (correct && !item['isPlaced']) {
        habitatGroups[targetHabitat]?.add(item);
        item['isPlaced'] = true;
      }
    });

    _feedbackController.forward(from: 0);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          showFeedback = false;
        });
      }
    });

    if (correct) {
      _checkCompletion();
    } else {
      // Yanlış eşleşme
      _trackWrongAnswer();
    }
  }

  Future<int> _calculateStars() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('siniflama3_wrong_count') ?? 0;
    const int totalItems = 6; // Toplam item sayısı
    
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

  void _checkCompletion() async {
    final allPlaced = items.every((e) => e['isPlaced'] == true);
    if (allPlaced && !_dialogShown) {
      _dialogShown = true;

      try {
        // Level 3'ü tamamlandı olarak kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('siniflama_completed_level', 3);

        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (!mounted) return;
        
        final prefs2 = await SharedPreferences.getInstance();
        int stars = await _calculateStars();
        int wrongCount = prefs2.getInt('siniflama3_wrong_count') ?? 0;
        await prefs2.setInt('siniflama3_final_wrong_count', wrongCount);
        await prefs2.setInt('siniflama3_wrong_count', 0); // Reset for next playthrough

        if (mounted) {
          _showCompletionDialog(stars);
        }
      } catch (e) {
        // Hata durumunda sessizce devam et veya logla
        if (mounted) {
          int stars = await _calculateStars();
          _showCompletionDialog(stars);
        }
      }
    }
  }

  void _showCompletionDialog(int stars) {
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
                        // Sualtı popup görseli - ekranın ortasına
                        Image.asset(
                          'assets/popup/sualti_popup.png',
                          width: popupWidth,
                          height: popupHeight,
                          fit: BoxFit.contain,
                        ),
                        // Deniz yıldızı görseli - popup'ın ortasındaki dikdörtgene
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
                                // Her deniz yıldızı için boyut - popup genişliğine göre dinamik
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
                                          'assets/popup/denizyildizi.png',
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
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ClassificationQuestionsScreen(),
                                  ),
                                  (route) => false,
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
                Colors.white,
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
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: iconSize,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
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
                                  ? 'Drag the animals to their habitats!'
                                  : 'Hayvanları yaşam alanlarına sürükle!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildGroup(
                                        'water',
                                        isEnglish ? 'Water' : 'Su',
                                        Colors.purple.shade100,
                                        Colors.purple.shade300,
                                        habitatGroups['water']!,
                                      ),
                                      _buildGroup(
                                        'air',
                                        isEnglish ? 'Air' : 'Hava',
                                        Colors.blue.shade100,
                                        Colors.blue.shade400,
                                        habitatGroups['air']!,
                                      ),
                                      _buildGroup(
                                        'land',
                                        isEnglish ? 'Land' : 'Kara',
                                        Colors.yellow.shade100,
                                        Colors.yellow.shade600,
                                        habitatGroups['land']!,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:
                                        items
                                            .where((item) => !item['isPlaced'])
                                            .map(
                                              (item) => Draggable<
                                                Map<String, dynamic>
                                              >(
                                                data: item,
                                                feedback: Material(
                                                  color: Colors.transparent,
                                                  child: _buildDraggableItem(
                                                    item,
                                                  ),
                                                ),
                                                childWhenDragging: Opacity(
                                                  opacity: 0.3,
                                                  child: _buildDraggableItem(
                                                    item,
                                                  ),
                                                ),
                                                child: _buildDraggableItem(
                                                  item,
                                                ),
                                              ),
                                            )
                                            .toList(),
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

  Widget _buildGroup(
    String key,
    String title,
    Color boxColor,
    Color borderColor,
    List<Map<String, dynamic>> group,
  ) {
    return Container(
      width: double.infinity,
      height: 145,
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: boxColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DragTarget<Map<String, dynamic>>(
        onWillAcceptWithDetails: (data) => true, // tüm sürüklemeleri kabul et
        onAcceptWithDetails: (data) => _handleDrag(data.data, key),
        builder: (context, candidateData, rejectedData) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 4,
                    children:
                        group
                            .map(
                              (item) => Text(
                                item['emoji'],
                                style: const TextStyle(
                                  fontSize: 50,
                                  color: Colors.black,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDraggableItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      width: 70,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Center(
        child: Text(
          item['emoji'],
          style: const TextStyle(fontSize: 40, color: Colors.black),
        ),
      ),
    );
  }
}
