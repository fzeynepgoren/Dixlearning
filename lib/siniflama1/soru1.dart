import 'package:dixlearning/siniflama1/soru2.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../screens/home_screen.dart';
import 'soru4.dart';

class CinsiyetEsleme extends StatefulWidget {
  const CinsiyetEsleme({super.key});

  @override
  State<CinsiyetEsleme> createState() => _CinsiyetEslemeState();
}

class _CinsiyetEslemeState extends State<CinsiyetEsleme>
    with TickerProviderStateMixin {
  // YENİ EMOJİLER: Bir yürüyen ve bir ayakta duran figür her kategori için
  final List<Map<String, dynamic>> dragItems = [
    {
      'emoji': '🚶‍♀️',
      'kategori': 'Kız',
      'id': 1,
      'isPlaced': false,
    }, // Yürüyen Kadın
    {
      'emoji': '🧍‍♀️',
      'kategori': 'Kız',
      'id': 2,
      'isPlaced': false,
    }, // Ayakta Duran Kadın
    {
      'emoji': '🚶‍♂️',
      'kategori': 'Erkek',
      'id': 3,
      'isPlaced': false,
    }, // Yürüyen Erkek
    {
      'emoji': '🧍‍♂️',
      'kategori': 'Erkek',
      'id': 4,
      'isPlaced': false,
    }, // Ayakta Duran Erkek
  ];

  final List<String> kategoriler = ['Kız', 'Erkek'];

  List<Map<String, dynamic>> placedGirlItems = [];
  List<Map<String, dynamic>> placedBoyItems = [];

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

  void _showFeedback(bool correct) {
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

  void _handleDrag(Map<String, dynamic> draggedItem, String targetCategory) {
    bool isCorrectMatch = draggedItem['kategori'] == targetCategory;

    if (isCorrectMatch) {
      draggedItem['isPlaced'] = true;

      setState(() {
        if (targetCategory == 'Kız') {
          placedGirlItems.add(draggedItem);
        } else {
          placedBoyItems.add(draggedItem);
        }
      });

      _showFeedback(true); // Aferin!
      _checkCompletion();
    } else {
      // Doğru kutuya bırakma anı zaten DragTarget'ın 'rejectedData' bölümünde yakalanacaktır.
      // Bu fonksiyon sadece 'onAccept' anında çağrılır, yani doğru kutuya bırakılmış demektir.
      // Ancak _handleDrag, onAccept içinden çağrıldığı için bu else bloğu normalde tetiklenmez.
      // Yine de kodun mantıksal olarak güvenliğini sağlamak için bırakılabilir.
    }
  }

  void _checkCompletion() {
    if (placedGirlItems.length + placedBoyItems.length == dragItems.length) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UzunKisaSinifla()),
          );
        }
      });
    }
  }

  // ÖRNEK TASARIM: Grup Kutusu (DragTarget) yapısı
  Widget _buildGroupContainer(String kategori, bool isEnglish) {
    Color? boxColor =
        kategori == 'Kız' ? const Color(0xFFFFDDEE) : const Color(0xFFE3F2FD);
    Color borderColor =
        kategori == 'Kız' ? Colors.pinkAccent : Colors.lightBlue;

    List<Map<String, dynamic>> currentPlacedItems =
        kategori == 'Kız' ? placedGirlItems : placedBoyItems;

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (data) {
        return !data.data['isPlaced'] && data.data['kategori'] == kategori;
      },
      onAcceptWithDetails: (data) => _handleDrag(data.data, kategori),
      builder: (context, candidateData, rejectedData) {
        // Yanlış kutuya bırakıldığında geri bildirim gösterilmesi
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
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isEnglish ? (kategori == 'Kız' ? 'Girl' : 'Boy') : kategori,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                fit: FlexFit.loose,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12, // Öğeler arası boşluk
                  runSpacing: 8,
                  children:
                      currentPlacedItems
                          .map(
                            (item) => Text(
                              item['emoji'],
                              style: const TextStyle(fontSize: 60),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ÖRNEK TASARIM: Sürüklenen Emoji Kutusu yapısı
  Widget _buildItemBox(Map<String, dynamic> item) {
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
      child: Center(
        child: Text(item['emoji'], style: const TextStyle(fontSize: 60)),
      ),
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
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
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
                                  ? 'Drag and drop the figures to the correct gender box.'
                                  : 'Figürleri uygun kutuya sürükle!',
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
                                  child: AbsorbPointer(
                                    absorbing: showFeedback,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children:
                                          dragItems
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
