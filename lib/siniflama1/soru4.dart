import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'soru5.dart'; // HayvanBacakSinifla sınıfı için
import '../../screens/home_screen.dart'; // Geri tuşu için eklendi

class YiyecekIcecekSinifla extends StatefulWidget {
  const YiyecekIcecekSinifla({super.key});

  @override
  State<YiyecekIcecekSinifla> createState() => _YiyecekIcecekSiniflaState();
}

class _YiyecekIcecekSiniflaState extends State<YiyecekIcecekSinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {'emoji': '🥛', 'id': 'sut', 'isFood': false, 'isPlaced': false},
    {'emoji': '🍰', 'id': 'kek', 'isFood': true, 'isPlaced': false},
    {'emoji': '🍹', 'id': 'meyveSuyu', 'isFood': false, 'isPlaced': false},
    {'emoji': '🍞', 'id': 'ekmek', 'isFood': true, 'isPlaced': false},
  ];

  final List<Map<String, dynamic>> foodGroup = [];
  final List<Map<String, dynamic>> drinkGroup = [];
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
      duration: const Duration(milliseconds: 800),
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
        _feedbackController.reset(); // Geri bildirim sonrası controller'ı sıfırla
      }
    });
  }

  void _checkCompletion() {
    if (foodGroup.length == 2 && drinkGroup.length == 2) {
      _handleDragFeedback(true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HayvanBacakSinifla()),
          );
        }
      });
    }
  }

  // Sürüklenen Öğenin Kutusu
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

  // Grup Kutusu (DragTarget) yapısı
  Widget _buildGroup(
      String title,
      List<Map<String, dynamic>> items,
      bool isFood,
      ) {
    Color boxColor = isFood ? Colors.lightBlue.shade100 : Colors.deepPurple.shade100;
    Color borderColor = isFood ? Colors.lightBlue.shade400 : Colors.deepPurple.shade400;

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (data) {
        // Yanlış yere sürüklenirse negatif geri bildirim göster
        if (data.data['isFood'] != isFood) {
          // Bu, sürükleme sırasında erken geri bildirim vermemizi sağlar.
          // Ancak istenen davranış sadece **bırakıldığında** olmasıdır.
          // Bu yüzden bu bloğu siliyorum ve 'rejectedData' kontrolünü kullanıyorum.
          return false;
        }
        return !data.data['isPlaced'];
      },
      onAcceptWithDetails: (data) {
        // Doğru yere bırakıldı
        setState(() {
          data.data['isPlaced'] = true;
          if (isFood) {
            foodGroup.add(data.data);
          } else {
            drinkGroup.add(data.data);
          }
        });
        _handleDragFeedback(true); // Doğru bırakma: Aferin!
        _checkCompletion();
      },
      builder: (context, candidateData, rejectedData) {
        // Hata Düzeltme: Yanlış yere bırakıldığında "Tekrar Dene" geri bildirimi
        if (rejectedData.isNotEmpty) {
          Future.microtask(() => _handleDragFeedback(false));
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: boxColor,
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
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
                    mainAxisAlignment: items.isEmpty
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: items.map((item) {
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
                            builder: (context) => const HomeScreen(),
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
                                horizontal: 20, vertical: 1),
                            child: Text(
                              isEnglish
                                  ? 'Drag the items to the correct group!'
                                  : 'Nesneleri doğru gruba sürükle!',
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
                                    children: [
                                      Expanded(
                                        child: _buildGroup(
                                          isEnglish ? 'Food' : 'Yiyecek',
                                          foodGroup,
                                          true,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: _buildGroup(
                                          isEnglish ? 'Drink' : 'İçecek',
                                          drinkGroup,
                                          false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: items
                                        .where((item) => !item['isPlaced'])
                                        .map((item) => _buildItem(item))
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
                // Geri Bildirim Kutusu
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: showFeedback
                      ? ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _feedbackController,
                      curve: Curves.elasticOut,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
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
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green : Colors.red,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isCorrect
                                ? (isEnglish ? 'Well done! 🎉' : 'Aferin! 🎉')
                                : (isEnglish
                                ? 'Try again! 😔'
                                : 'Tekrar dene! 😔'),
                            style: TextStyle(
                              fontSize: 18,
                              color: isCorrect ? Colors.green : Colors.red,
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