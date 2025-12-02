import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import 'soru4.dart';
import '../screens/siniflandirma_sorulari_screen.dart';


class UzunKisaSinifla extends StatefulWidget {
  const UzunKisaSinifla({super.key});

  @override
  State<UzunKisaSinifla> createState() => _UzunKisaSiniflaState();
}

class _UzunKisaSiniflaState extends State<UzunKisaSinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {
      'image': 'assets/siniflama1/kisa_kalem.png',
      'id': 'kalem1',
      'isLong': false,
      'isPlaced': false,
    },
    {
      'image': 'assets/siniflama1/uzun_kalem.png',
      'id': 'kalem2',
      'isLong': true,
      'isPlaced': false,
    },
    {
      'image': 'assets/siniflama1/kisa_cetvel.png',
      'id': 'cetvel1',
      'isLong': false,
      'isPlaced': false,
    },
    {
      'image': 'assets/siniflama1/uzun_cetvel.png',
      'id': 'cetvel2',
      'isLong': true,
      'isPlaced': false,
    },
  ];

  final List<Map<String, dynamic>> longGroup = [];
  final List<Map<String, dynamic>> shortGroup = [];

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

  void _checkCompletion() {
    if (longGroup.length == 2 && shortGroup.length == 2) {
      _showFeedback(true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const YiyecekIcecekSinifla(),
            ),
          );
        }
      });
    }
  }

  Future<void> _trackWrongAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('siniflama1_wrong_count') ?? 0;
    wrongCount++;
    await prefs.setInt('siniflama1_wrong_count', wrongCount);
  }

  void _showFeedback(bool correct) {
    // Eğer zaten doğru geri bildirim gösteriliyorsa, yanlış geri bildirimi engelle
    if (showFeedback && isCorrect && !correct) return;

    if (!correct) {
      _trackWrongAnswer();
    }

    setState(() {
      showFeedback = true;
      isCorrect = correct;
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

  // ÖRNEK TASARIM: Sürüklenen Öğenin Kutusu
  Widget _buildItem(Map<String, dynamic> item) {
    bool isLong = item['isLong'];
    double boxWidth = isLong ? 90 : 75;
    double boxHeight = isLong ? 100 : 85;
    double imgSize = isLong ? 100 : 55;

    return Draggable<Map<String, dynamic>>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: boxWidth,
          height: boxHeight,
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
            child: Image.asset(
              item['image'],
              width: imgSize,
              height: imgSize,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      childWhenDragging: const SizedBox.shrink(),
      child: Container(
        width: boxWidth,
        height: boxHeight,
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
          child: Image.asset(
            item['image'],
            width: imgSize,
            height: imgSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // ÖRNEK TASARIM: Grup Kutusu (DragTarget) yapısı
  Widget _buildGroup(
    String title,
    List<Map<String, dynamic>> items,
    bool isLong,
  ) {
    Color boxColor =
        isLong ? Colors.lightBlue.shade100 : Colors.deepPurple.shade100;
    Color borderColor =
        isLong ? Colors.lightBlue.shade400 : Colors.deepPurple.shade300;
    double placedImgSize = isLong ? 80 : 50;

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (data) {
        // Sadece doğru kutu için true döndürülür.
        return !data.data['isPlaced'] && data.data['isLong'] == isLong;
      },
      onAcceptWithDetails: (data) {
        // Doğru kutuya bırakıldı.
        setState(() {
          data.data['isPlaced'] = true;
          if (isLong) {
            longGroup.add(data.data);
          } else {
            shortGroup.add(data.data);
          }
        });
        _showFeedback(true); // Aferin!
        _checkCompletion();
      },
      // onDidLeave kaldırıldı.
      builder: (context, candidateData, rejectedData) {
        // Nesne yanlış kutuya bırakılırsa (onWillAcceptDetails false döndürürse)
        // rejectedData boş olmayacaktır.
        if (rejectedData.isNotEmpty) {
          // Geri bildirimin hemen sonra görünmesi için microtask kullanıldı
          Future.microtask(() => _showFeedback(false));
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
                            child: Image.asset(
                              item['image'],
                              width: placedImgSize,
                              height: placedImgSize,
                              fit: BoxFit.contain,
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
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const ClassificationQuestionsScreen(),
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
                              horizontal: 20,
                              vertical: 1,
                            ),
                            child: Text(
                              isEnglish
                                  ? 'Drag the objects to the correct group!'
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
                                          isEnglish ? 'Long' : 'Uzun',
                                          longGroup,
                                          true,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: _buildGroup(
                                          isEnglish ? 'Short' : 'Kısa',
                                          shortGroup,
                                          false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  // Sağ tarafta ayrı bir DragTarget kullanmaya gerek yok
                                  // çünkü yanlış bırakma kontrolü _buildGroup içinde yapılıyor.
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
