import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../screens/siniflandirma_sorulari_screen.dart';

class HayvanBacakSinifla extends StatefulWidget {
  const HayvanBacakSinifla({super.key});

  @override
  State<HayvanBacakSinifla> createState() => _HayvanBacakSiniflaState();
}

class _HayvanBacakSiniflaState extends State<HayvanBacakSinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {'emoji': '🐓', 'id': 'horoz', 'isFourLegs': false, 'isPlaced': false},
    {'emoji': '🐈', 'id': 'kedi', 'isFourLegs': true, 'isPlaced': false},
    {'emoji': '🐦', 'id': 'kus', 'isFourLegs': false, 'isPlaced': false},
    {'emoji': '🐎', 'id': 'at', 'isFourLegs': true, 'isPlaced': false},
  ];

  final List<Map<String, dynamic>> fourLegsGroup = [];
  final List<Map<String, dynamic>> twoLegsGroup = [];
  bool showFeedback = false;
  bool isCorrect = false;

  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Örnek tasarıma uyumlu süre
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

  void _handleDragFeedback(bool correct) {
    // Eğer zaten doğru geri bildirim gösteriliyorsa, yanlış geri bildirimi engelle
    if (showFeedback && isCorrect && !correct) return;

    setState(() {
      isCorrect = correct;
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          showFeedback = false;
        });
        _feedbackController.reset();
      }
    });
  }

  Future<int> _calculateStars() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('siniflama1_wrong_count') ?? 0;

    if (wrongCount >= 0 && wrongCount <= 4) {
      return 3;
    } else if (wrongCount >= 5 && wrongCount <= 8) {
      return 2;
    } else {
      // 9 ve üzeri
      return 1;
    }
  }

  void _checkCompletion() async {
    if (fourLegsGroup.length == 2 && twoLegsGroup.length == 2) {
      _handleDragFeedback(
        true,
      ); // Tüm doğru eşleşmeler bittiğinde pozitif geri bildirim

      try {
        // Level 1'i tamamlandı olarak kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('siniflama_completed_level', 1);

        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (!mounted) return;
        
        final prefs2 = await SharedPreferences.getInstance();
        int stars = await _calculateStars();
        int wrongCount = prefs2.getInt('siniflama1_wrong_count') ?? 0;
        await prefs2.setInt('siniflama1_final_wrong_count', wrongCount);
        await prefs2.setInt('siniflama1_wrong_count', 0); // Reset for next playthrough

        if (mounted) {
          _showCompletionDialog(stars);
        }
      } catch (e) {
        // Hata durumunda sessizce devam et veya logla
        if (mounted) {
          // Hata olsa bile popup'ı göster
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

  // ÖRNEK TASARIM: Sürüklenen Öğenin Kutusu
  Widget _buildItem(Map<String, dynamic> item) {
    return Draggable<Map<String, dynamic>>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 90,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(item['emoji'], style: const TextStyle(fontSize: 60)),
          ),
        ),
      ),
      // Sürüklenirken yerinde kalıntı bırakmama
      childWhenDragging: const SizedBox.shrink(),
      child: Container(
        width: 90,
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(item['emoji'], style: const TextStyle(fontSize: 60)),
        ),
      ),
    );
  }

  // ÖRNEK TASARIM: Grup Kutusu (DragTarget) yapısı
  Widget _buildGroup(
    String title,
    List<Map<String, dynamic>> items,
    bool isFourLegs,
  ) {
    // Özel renkler bu soruya uyarlandı
    Color boxColor =
        isFourLegs ? Colors.lightBlue.shade100 : Colors.deepPurple.shade100;
    Color borderColor =
        isFourLegs ? Colors.lightBlue.shade400 : Colors.deepPurple.shade400;

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (data) {
        // Doğru kategori kontrolü
        return !data.data['isPlaced'] && data.data['isFourLegs'] == isFourLegs;
      },
      onAcceptWithDetails: (data) {
        // Doğru yere bırakıldı
        setState(() {
          data.data['isPlaced'] = true;
          if (isFourLegs) {
            fourLegsGroup.add(data.data);
          } else {
            twoLegsGroup.add(data.data);
          }
        });
        _handleDragFeedback(true); // Doğru bırakma: Aferin!
        _checkCompletion();
      },
      builder: (context, candidateData, rejectedData) {
        // Yanlış kutuya bırakıldığında "Tekrar Dene" geri bildirimi
        if (rejectedData.isNotEmpty) {
          Future.microtask(() => _handleDragFeedback(false));
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: boxColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment:
                        items.isEmpty
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                    children:
                        items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              item['emoji'],
                              style: const TextStyle(fontSize: 60),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final iconSize = MediaQuery.of(context).size.width * 0.065;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          // Gradient arka plan
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
                // Başlık kaldırıldı, sadece geri tuşu kaldı.
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: iconSize,
                      ),
                      onPressed: () {
                        // Ana ekrana dönme
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const ClassificationQuestionsScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    // İçerik kutusu
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
                                  ? 'Drag the animals to the correct group!'
                                  : 'Hayvanları doğru gruba sürükle!',
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
                                    // Grup kutuları Expanded ile sarıldı.
                                    children: [
                                      Expanded(
                                        child: _buildGroup(
                                          isEnglish ? '4 Legs' : '4 Bacak',
                                          fourLegsGroup,
                                          true,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: _buildGroup(
                                          isEnglish ? '2 Legs' : '2 Bacak',
                                          twoLegsGroup,
                                          false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: AbsorbPointer(
                                    absorbing: showFeedback,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children:
                                          items
                                              .where(
                                                (item) => !item['isPlaced'],
                                              )
                                              .map((item) => _buildItem(item))
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
                // Geri Bildirim Kutusu
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
