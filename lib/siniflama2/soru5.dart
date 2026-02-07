import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../screens/siniflandirma_sorulari_screen.dart';
import '../../screens/home_screen.dart';
import '../../widgets/in_game_menu.dart';

class ParaSinifla extends StatefulWidget {
  const ParaSinifla({super.key});

  @override
  State<ParaSinifla> createState() => _ParaSiniflaState();
}

class _ParaSiniflaState extends State<ParaSinifla>
    with TickerProviderStateMixin {
  final Map<String, String> dogruEslesmeler = {
    '🪙': 'Coins',
    'assets/siniflama2/madeni2.png': 'Coins', // İkinci madeni para görseli
    '💵': 'Paper Money',
    '💶': 'Paper Money',
  };

  late List<String> suruklenecekOgeler;
  final List<String> kategoriler = ['Paper Money', 'Coins'];

  Set<String> eslesenler = {};
  bool showFeedback = false;
  bool isCorrect = false;
  bool _isSoundOn = true;
  bool _dialogShown = false;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    ogeleriKaristir();
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

  @override
  void dispose() {
    _feedbackController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void ogeleriKaristir() {
    final List<String> tumOgeler = dogruEslesmeler.keys.toList();
    tumOgeler.shuffle();
    suruklenecekOgeler = tumOgeler;
  }

  Future<void> _trackWrongAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('siniflama2_wrong_count') ?? 0;
    wrongCount++;
    await prefs.setInt('siniflama2_wrong_count', wrongCount);
  }

  void _handleDrag(String draggedItem, String targetCategory) {
    bool isCorrectMatch = dogruEslesmeler[draggedItem] == targetCategory;

    setState(() {
      isCorrect = isCorrectMatch;
      showFeedback = true;
    });

    _feedbackController.forward(from: 0);

    if (isCorrectMatch) {
      setState(() {
        if (!eslesenler.contains(draggedItem)) {
          eslesenler.add(draggedItem);
        }
      });
      _checkCompletion();
    } else {
      // Yanlış eşleşme
      _trackWrongAnswer();
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          showFeedback = false;
        });
      }
    });
  }

  Future<int> _calculateStars() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('siniflama2_wrong_count') ?? 0;
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

  void _checkCompletion() async {
    if (eslesenler.length == suruklenecekOgeler.length) {
      try {
        // Level 2'yi tamamlandı olarak kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('siniflama_completed_level', 2);

        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (!mounted) return;
        
        final prefs2 = await SharedPreferences.getInstance();
        int stars = await _calculateStars();
        int wrongCount = prefs2.getInt('siniflama2_wrong_count') ?? 0;
        await prefs2.setInt('siniflama2_final_wrong_count', wrongCount);
        
        // Yıldızları kaydet (roadmap için) - sadece öncekinden daha iyiyse güncelle
        int previousStars = prefs2.getInt('classification_stage_2_stars') ?? 0;
        if (stars > previousStars) {
          await prefs2.setInt('classification_stage_2_stars', stars);
        } else {
          stars = previousStars; // Önceki yıldız sayısını kullan
        }
        
        await prefs2.setInt('siniflama2_wrong_count', 0); // Reset for next playthrough

        if (mounted && !_dialogShown) {
          _dialogShown = true;
          _showCompletionDialog(stars);
        }
      } catch (e) {
        // Hata durumunda sessizce devam et veya logla
        if (mounted && !_dialogShown) {
          final prefs3 = await SharedPreferences.getInstance();
          int stars = await _calculateStars();
          // Yıldızları kaydet (roadmap için) - sadece öncekinden daha iyiyse güncelle
          int previousStars = prefs3.getInt('classification_stage_2_stars') ?? 0;
          if (stars > previousStars) {
            await prefs3.setInt('classification_stage_2_stars', stars);
          } else {
            stars = previousStars; // Önceki yıldız sayısını kullan
          }
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
                                  ? 'Drag the money to the correct group!'
                                  : 'Paraları doğru gruba sürükle!',
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children:
                                        kategoriler
                                            .map(
                                              (kategori) => Expanded(
                                                child: _buildGroupContainer(
                                                  kategori,
                                                  isEnglish,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:
                                        suruklenecekOgeler
                                            .where(
                                              (item) =>
                                                  !eslesenler.contains(item),
                                            )
                                            .map((item) {
                                              return Draggable<String>(
                                                data: item,
                                                feedback: Material(
                                                  color: Colors.transparent,
                                                  child: _buildItemBox(item),
                                                ),
                                                childWhenDragging:
                                                    const SizedBox.shrink(),
                                                child: _buildItemBox(item),
                                              );
                                            })
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
            InGameMenu(
              isSoundOn: _isSoundOn,
              onToggleSound: () => setState(() => _isSoundOn = !_isSoundOn),
              onHome: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const ClassificationQuestionsScreen(),
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

  Widget _buildGroupContainer(String kategori, bool isEnglish) {
    Color boxColor =
        kategori == 'Paper Money'
            ? Colors.deepPurple.shade100
            : Colors.blue.shade100;
    Color borderColor =
        kategori == 'Paper Money'
            ? Colors.deepPurple.shade300
            : Colors.blue.shade400;
    return DragTarget<String>(
      onWillAcceptWithDetails: (data) => !eslesenler.contains(data.data),
      onAcceptWithDetails: (data) => _handleDrag(data.data, kategori),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: boxColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isEnglish
                    ? (kategori == 'Paper Money' ? 'Paper Money' : 'Coins')
                    : (kategori == 'Paper Money'
                        ? 'Kâğıt Para'
                        : 'Madeni Para'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children:
                    eslesenler
                        .where((item) => dogruEslesmeler[item] == kategori)
                        .map((item) => _buildItemDisplay(item))
                        .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemBox(String item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: 90,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Center(child: _buildItemDisplay(item)),
    );
  }

  Widget _buildItemDisplay(String item) {
    if (item.startsWith('assets/')) {
      return SizedBox(
        width: 80,
        height: 80,
        child: Image.asset(item, fit: BoxFit.contain),
      );
    } else {
      return Text(item, style: const TextStyle(fontSize: 60));
    }
  }
}
