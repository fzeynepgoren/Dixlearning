import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../screens/home_screen.dart';
import '../screens/siniflandirma_sorulari_screen.dart';
import 'soru4.dart';

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

  void _checkCompletion() {
    if (fourLegsGroup.length == 2 && twoLegsGroup.length == 2) {
      _handleDragFeedback(
        true,
      ); // Tüm doğru eşleşmeler bittiğinde pozitif geri bildirim
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
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
                        Container(
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          );
        }
      });
    }
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
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:
                                        items
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
