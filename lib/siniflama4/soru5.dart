import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../screens/siniflandirma_sorulari_screen.dart';

class OlaySinifla extends StatefulWidget {
  const OlaySinifla({super.key});

  @override
  State<OlaySinifla> createState() => _OlaySiniflaState();
}

class _OlaySiniflaState extends State<OlaySinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> sentenceItems = [
    {
      'text': 'Ali, sabah kahvaltı yapmadı.',
      'type': 'cause',
      'isPlaced': false,
      'placedType': null,
    },
    {
      'text': 'Derste kendini yorgun hissetti.',
      'type': 'effect',
      'isPlaced': false,
      'placedType': null,
    },
    {
      'text': 'Teneffüs olunca tost yedi.',
      'type': 'solution',
      'isPlaced': false,
      'placedType': null,
    },
  ];

  final List<Map<String, dynamic>> draggableItems = [
    {'text': 'Sebep', 'type': 'cause', 'isPlaced': false},
    {'text': 'Sonuç', 'type': 'effect', 'isPlaced': false},
    {'text': 'Çözüm', 'type': 'solution', 'isPlaced': false},
  ];

  bool showFeedback = false;
  bool isCorrect = false;
  bool _dialogShown = false;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    sentenceItems.shuffle();
    draggableItems.shuffle();
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

  void _handleDrag(Map<String, dynamic> droppedItem, String targetType) {
    setState(() {
      isCorrect = droppedItem['type'] == targetType;
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    if (isCorrect) {
      setState(() {
        for (var item in sentenceItems) {
          if (item['type'] == targetType) {
            item['isPlaced'] = true;
            item['placedType'] = droppedItem['text'];
            break;
          }
        }
        for (var item in draggableItems) {
          if (item['type'] == droppedItem['type']) {
            item['isPlaced'] = true;
            break;
          }
        }
      });
      _checkCompletion();
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          showFeedback = false;
        });
      }
    });
  }

<<<<<<< Updated upstream
=======
  Future<int> _calculateStars() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('siniflama4_wrong_count') ?? 0;

    // Toplam doğru cevap sayısı (soru1: 6, soru2: 6, soru4: 6, soru5: 3)
    const int totalCorrect = 21;
    // Toplam deneme = doğru + yanlış
    int totalAttempts = totalCorrect + wrongCount;
    // Yanlış oranı
    double wrongRatio = wrongCount / totalAttempts;

    int stars;
    if (wrongRatio <= 0.25) {
      stars = 3;
    } else if (wrongRatio <= 0.50) {
      stars = 2;
    } else {
      // %75 ve üzeri
      stars = 1;
    }

    // Yıldız sayısını kaydet
    await prefs.setInt('siniflama_level_4_stars', stars);

    return stars;
  }

>>>>>>> Stashed changes
  void _checkCompletion() async {
    final allPlaced = sentenceItems.every((item) => item['isPlaced']);
    if (allPlaced && !_dialogShown) {
      _dialogShown = true;

<<<<<<< Updated upstream
      // Level 4'ü tamamlandı olarak kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('siniflama_completed_level', 4);
=======
      try {
        // Level 4'ü tamamlandı olarak kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('siniflama_completed_level', 4);

        await Future.delayed(const Duration(milliseconds: 1500));

        if (!mounted) return;

        final prefs2 = await SharedPreferences.getInstance();
        int stars = await _calculateStars();
        int wrongCount = prefs2.getInt('siniflama4_wrong_count') ?? 0;
        await prefs2.setInt('siniflama4_final_wrong_count', wrongCount);
        await prefs2.setInt(
          'siniflama4_wrong_count',
          0,
        ); // Reset for next playthrough
>>>>>>> Stashed changes

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
<<<<<<< Updated upstream
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 25,
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Colors.blue.shade50],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 25,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Custom Golden Trophy Icon
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Trophy Cup
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade300,
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                    color: Colors.blue.shade800,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
=======
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
                        opacity: value.clamp(0.0, 1.0),
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
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const ClassificationQuestionsScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: (popupHeight * 0.1).clamp(45.0, 65.0),
                                  color: Colors.transparent,
>>>>>>> Stashed changes
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.amber.shade600,
                                    size: 40,
                                  ),
                                ),
                              ),
                              // Trophy Handles
                              Positioned(
                                left: 10,
                                top: 25,
                                child: Container(
                                  width: 20,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.blue.shade800,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 10,
                                top: 25,
                                child: Container(
                                  width: 20,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.blue.shade800,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              // Trophy Base
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  width: 100,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade800,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue.shade800,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 60,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade400,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Decorative Stars
                              Positioned(
                                top: 5,
                                left: 20,
                                child: Icon(
                                  Icons.star,
                                  color: Colors.amber.shade400,
                                  size: 12,
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 20,
                                child: Icon(
                                  Icons.star,
                                  color: Colors.amber.shade400,
                                  size: 12,
                                ),
                              ),
                              Positioned(
                                bottom: 30,
                                left: 15,
                                child: Icon(
                                  Icons.star,
                                  color: Colors.amber.shade400,
                                  size: 10,
                                ),
                              ),
                              Positioned(
                                bottom: 30,
                                right: 15,
                                child: Icon(
                                  Icons.star,
                                  color: Colors.amber.shade400,
                                  size: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          Provider.of<LanguageProvider>(
                                context,
                                listen: false,
                              ).isEnglish
                              ? 'CONGRATULATIONS!'
                              : 'TEBRİKLER',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.blue.shade800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          Provider.of<LanguageProvider>(
                                context,
                                listen: false,
                              ).isEnglish
                              ? 'You have completed the activity!'
                              : 'Etkinliği tamamladınız!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 35),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const ClassificationQuestionsScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue.shade600,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 12,
                              shadowColor: Colors.blue.withOpacity(0.4),
                            ),
                            child: Text(
                              Provider.of<LanguageProvider>(
                                    context,
                                    listen: false,
                                  ).isEnglish
                                  ? 'GO TO MENU'
                                  : 'MENÜYE GİT',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
<<<<<<< Updated upstream
                      ],
                    ),
                  ),
                ),
          );
        }
      });
    }
=======
                      ),
                    );
                  },
                );
              },
            ),
          ),
    );
>>>>>>> Stashed changes
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.065;
    final horizontalPadding = screenSize.width * 0.05;
    final verticalPadding = screenSize.height * 0.02;

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
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: iconSize,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                      padding: EdgeInsets.all(screenSize.width * 0.025),
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
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: verticalPadding * 0.5,
                            ),
                            child: Text(
                              isEnglish
                                  ? 'Drag and drop the categories to the sentences!'
                                  : 'Kategorileri cümlelerin üzerine sürükle!',
                              style: TextStyle(
                                fontSize: screenSize.width * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.02),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children:
                                        sentenceItems.map((item) {
                                          return _buildSentenceGroup(item);
                                        }).toList(),
                                  ),
                                ),
                                SizedBox(width: screenSize.width * 0.04),
                                Expanded(
                                  flex: 2,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children:
                                          draggableItems
                                              .where(
                                                (item) => !item['isPlaced'],
                                              )
                                              .map((item) {
                                                return Draggable<
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
                                                );
                                              })
                                              .toList(),
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
                Container(
                  height: screenSize.height * 0.1,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child:
                      showFeedback
                          ? ScaleTransition(
                            scale: CurvedAnimation(
                              parent: _feedbackController,
                              curve: Curves.elasticOut,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: screenSize.height * 0.01,
                                horizontal: screenSize.width * 0.04,
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
                                    size: screenSize.width * 0.07,
                                  ),
                                  SizedBox(width: screenSize.width * 0.025),
                                  Text(
                                    isCorrect
                                        ? (isEnglish
                                            ? 'Well done! 🎉'
                                            : 'Aferin! 🎉')
                                        : (isEnglish
                                            ? 'Try again! 😔'
                                            : 'Tekrar dene! 😔'),
                                    style: TextStyle(
                                      fontSize: screenSize.width * 0.045,
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

  Widget _buildSentenceGroup(Map<String, dynamic> item) {
    final screenSize = MediaQuery.of(context).size;

    final Color itemColor;
    final Color borderColor;
    switch (item['type']) {
      case 'cause':
        itemColor = Colors.purple.shade100;
        borderColor = Colors.purple.shade300;
        break;
      case 'effect':
        itemColor = Colors.blue.shade100;
        borderColor = Colors.blue.shade400;
        break;
      case 'solution':
        itemColor = Colors.yellow.shade100;
        borderColor = Colors.yellow.shade400;
        break;
      default:
        itemColor = Colors.grey.shade100;
        borderColor = Colors.grey.shade400;
        break;
    }

    // Ortak boyutları belirle
    final double boxWidth = screenSize.width * 0.28; // Örnek boyut
    final double boxHeight = screenSize.height * 0.045; // Örnek boyut

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (data) => !item['isPlaced'],
      onAcceptWithDetails: (data) => _handleDrag(data.data, item['type']),
      builder: (context, candidateItems, rejectedItems) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
          padding: EdgeInsets.all(screenSize.width * 0.03),
          decoration: BoxDecoration(
            color: itemColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['text'],
                style: TextStyle(
                  fontSize: screenSize.width * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenSize.height * 0.01),
              Container(
                width: boxWidth,
                height: boxHeight,
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.02,
                  vertical: screenSize.height * 0.005,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    30,
                  ), // Oval şekil için daha yüksek radius
                ),
                child: Center(
                  child: Text(
                    item['isPlaced'] ? item['placedType'] : '',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.04,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableItem(Map<String, dynamic> item) {
    final screenSize = MediaQuery.of(context).size;
    final double boxWidth = screenSize.width * 0.28;
    final double boxHeight = screenSize.height * 0.045;

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.015),
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.02,
        vertical: screenSize.height * 0.001,
      ),
      width: boxWidth,
      height: boxHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Text(
          item['text'],
          style: TextStyle(
            fontSize: screenSize.width * 0.04,
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
