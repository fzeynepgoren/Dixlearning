import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/activity_tracker.dart';
import 'disgrafi1.dart';
import '../screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class Diskalkuli4 extends StatefulWidget {
  const Diskalkuli4({super.key});

  @override
  State<Diskalkuli4> createState() => _Diskalkuli4State();
}

class _Diskalkuli4State extends State<Diskalkuli4>
    with TickerProviderStateMixin {
  // Sorular: İlk 3 nesne, sonra diğer 3 nesne
  final List<Map<String, dynamic>> questions = [
    {
      'texts': ['Ördek', 'Şemsiye', 'Şapka'],
    },
    {
      'texts': ['Davul', 'Mantar', 'Araba'],
    },
  ];

  int currentIndex = 0;
  List<String?> matchedImages = [
    null,
    null,
    null,
  ]; // Her text için eşleşen görsel
  List<bool?> matchStatus = [
    null,
    null,
    null,
  ]; // Her eşleştirmenin doğru/yanlış durumu (null: henüz kontrol edilmedi, true: doğru, false: yanlış)
  String? selectedText; // Seçili text
  String? selectedImage; // Seçili görsel
  List<String> shuffledTexts = []; // Rastgele sıralanmış textler
  List<String> shuffledImages = []; // Rastgele sıralanmış görseller
  bool showFeedback = false;
  bool isCorrect = false;
  bool _dialogShown = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _feedbackController;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
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
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shuffleImages();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _shuffleImages() {
    final current = questions[currentIndex];
    // Text ve görselleri ayrı ayrı karıştır
    shuffledTexts = List<String>.from(current['texts']);
    shuffledTexts.shuffle(_random);
    shuffledImages = List<String>.from(current['texts']);
    shuffledImages.shuffle(_random);
  }

  String _getImagePath(String itemName) {
    // Görsel dosya isimlerini eşleştir
    final imageMap = {
      'Ördek': 'ordek',
      'Şemsiye': 'semsiye',
      'Şapka': 'sapka',
      'Davul': 'davul',
      'Mantar': 'mantar',
      'Araba': 'araba',
    };
    final imageName = imageMap[itemName] ?? itemName.toLowerCase();
    return 'assets/golgeoyunu/$imageName.png';
  }

  void _onTextTap(String textName) {
    setState(() {
      if (selectedText == textName) {
        // Aynı text'e tekrar tıklanırsa seçimi kaldır
        selectedText = null;
      } else {
        selectedText = textName;
        // Eğer bir görsel seçiliyse, eşleştir
        if (selectedImage != null) {
          final current = questions[currentIndex];
          // Orijinal index'i bul (shuffled değil, orijinal sıradaki index)
          final originalIndex = current['texts'].indexOf(textName);
          if (originalIndex != -1) {
            // Eğer bu görsel başka bir text'e atanmışsa, önceki eşleşmeyi kaldır
            for (int i = 0; i < matchedImages.length; i++) {
              if (matchedImages[i] == selectedImage && i != originalIndex) {
                matchedImages[i] = null;
                break;
              }
            }
            matchedImages[originalIndex] = selectedImage;
            selectedImage = null;
            selectedText = null;
          }
        }
      }
    });
  }

  void _onImageTap(String imageName) {
    setState(() {
      if (selectedImage == imageName) {
        // Aynı görsele tekrar tıklanırsa seçimi kaldır
        selectedImage = null;
      } else {
        selectedImage = imageName;
        // Eğer bir text seçiliyse, eşleştir
        if (selectedText != null) {
          final current = questions[currentIndex];
          // Orijinal index'i bul (shuffled değil, orijinal sıradaki index)
          final originalIndex = current['texts'].indexOf(selectedText!);
          if (originalIndex != -1) {
            // Eğer bu görsel başka bir text'e atanmışsa, önceki eşleşmeyi kaldır
            for (int i = 0; i < matchedImages.length; i++) {
              if (matchedImages[i] == imageName && i != originalIndex) {
                matchedImages[i] = null;
                break;
              }
            }
            matchedImages[originalIndex] = imageName;
            selectedImage = null;
            selectedText = null;
          }
        }
      }
    });
  }

  void checkAnswers() {
    final current = questions[currentIndex];
    bool allMatched = true;

    // Her eşleştirmenin doğru/yanlış durumunu kontrol et
    List<bool?> newMatchStatus = [null, null, null];
    for (int i = 0; i < current['texts'].length; i++) {
      final correctText = current['texts'][i];
      if (matchedImages[i] != null) {
        newMatchStatus[i] = matchedImages[i] == correctText;
        if (matchedImages[i] != correctText) {
          allMatched = false;
        }
      } else {
        allMatched = false;
      }
    }

    setState(() {
      isCorrect = allMatched;
      matchStatus = newMatchStatus;
      showFeedback = true;
    });

    _feedbackController.forward(from: 0);

    if (isCorrect) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _nextQuestion();
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            showFeedback = false;
            // Yanlış eşleştirmeleri temizle
            matchedImages = [null, null, null];
            matchStatus = [null, null, null];
            selectedImage = null;
            selectedText = null;
          });
        }
      });
    }
  }

  void _nextQuestion() {
    if (!mounted) return;

    setState(() {
      showFeedback = false;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      if (currentIndex < questions.length - 1) {
        setState(() {
          currentIndex++;
          matchedImages = [null, null, null];
          matchStatus = [null, null, null];
          selectedImage = null;
          selectedText = null;
        });
        _shuffleImages();
        _slideController.forward(from: 0.0);
      } else if (!_dialogShown) {
        _dialogShown = true;
        ActivityTracker.completeActivity();
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => const Disgrafi1(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final current = questions[currentIndex];
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.065;

    // Box boyutlarını ekrana göre ayarla - 3 öğe için optimize edilmiş
    final boxSize = (screenSize.width * 0.28).clamp(90.0, 130.0);
    final spacing = 16.0;

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
                      child: SingleChildScrollView(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (
                            Widget child,
                            Animation<double> animation,
                          ) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            key: ValueKey<int>(currentIndex),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  isEnglish
                                      ? 'Match the texts with their shadows!'
                                      : 'Yazıları gölgeleriyle eşleştir!',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Text box'lar ve görseller - ortalanmış ve sabit boyutlu
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Sol taraf - Text box'lar (karışık sırada)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: List.generate(
                                      shuffledTexts.length,
                                      (index) {
                                        final textName = shuffledTexts[index];
                                        final originalIndex = current['texts']
                                            .indexOf(textName);
                                        final matchedImage =
                                            originalIndex != -1
                                                ? matchedImages[originalIndex]
                                                : null;
                                        final isMatched = matchedImage != null;
                                        final isSelected =
                                            selectedText == textName;
                                        final matchResult =
                                            originalIndex != -1
                                                ? matchStatus[originalIndex]
                                                : null;
                                        final isCorrectMatch =
                                            matchResult == true;
                                        final isWrongMatch =
                                            matchResult == false;

                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: spacing,
                                          ),
                                          child: GestureDetector(
                                            onTap: () => _onTextTap(textName),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              width: boxSize,
                                              height: boxSize,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                    horizontal: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    isSelected
                                                        ? Colors.blue.shade100
                                                        : isWrongMatch
                                                        ? Colors.red.shade100
                                                        : isCorrectMatch
                                                        ? Colors.green.shade100
                                                        : isMatched
                                                        ? Colors.green.shade50
                                                        : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                border: Border.all(
                                                  color:
                                                      isSelected
                                                          ? Colors.blue.shade600
                                                          : isWrongMatch
                                                          ? Colors.red
                                                          : isCorrectMatch
                                                          ? Colors.green
                                                          : isMatched
                                                          ? Colors
                                                              .green
                                                              .shade300
                                                          : Colors
                                                              .blue
                                                              .shade300,
                                                  width:
                                                      isSelected
                                                          ? 4
                                                          : (isWrongMatch ||
                                                                  isCorrectMatch
                                                              ? 3
                                                              : isMatched
                                                              ? 2.5
                                                              : 2.5),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        isSelected
                                                            ? Colors.blue
                                                                .withOpacity(
                                                                  0.3,
                                                                )
                                                            : Colors.black
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                    blurRadius:
                                                        isSelected ? 12 : 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  textName,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: boxSize * 0.24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: screenSize.width * 0.06),
                                  // Sağ taraf - Görseller (rastgele sırada)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: List.generate(
                                      shuffledImages.length,
                                      (index) {
                                        final imageName = shuffledImages[index];
                                        final isUsed = matchedImages.contains(
                                          imageName,
                                        );
                                        final isSelected =
                                            selectedImage == imageName;
                                        // Bu görselin hangi text ile eşleştiğini bul
                                        int? matchedTextIndex;
                                        for (
                                          int i = 0;
                                          i < matchedImages.length;
                                          i++
                                        ) {
                                          if (matchedImages[i] == imageName) {
                                            matchedTextIndex = i;
                                            break;
                                          }
                                        }
                                        final matchResult =
                                            matchedTextIndex != null
                                                ? matchStatus[matchedTextIndex]
                                                : null;
                                        final isCorrectMatch =
                                            matchResult == true;
                                        final isWrongMatch =
                                            matchResult == false;

                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: spacing,
                                          ),
                                          child: GestureDetector(
                                            onTap: () => _onImageTap(imageName),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              width: boxSize,
                                              height: boxSize,
                                              decoration: BoxDecoration(
                                                color:
                                                    isSelected
                                                        ? Colors.blue.shade100
                                                        : isWrongMatch
                                                        ? Colors.red.shade100
                                                        : isCorrectMatch
                                                        ? Colors.green.shade100
                                                        : isUsed
                                                        ? Colors.green.shade50
                                                        : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                border: Border.all(
                                                  color:
                                                      isSelected
                                                          ? Colors.blue.shade600
                                                          : isWrongMatch
                                                          ? Colors.red
                                                          : isCorrectMatch
                                                          ? Colors.green
                                                          : isUsed
                                                          ? Colors
                                                              .green
                                                              .shade300
                                                          : Colors
                                                              .blue
                                                              .shade300,
                                                  width:
                                                      isSelected
                                                          ? 4
                                                          : (isWrongMatch ||
                                                                  isCorrectMatch
                                                              ? 3
                                                              : isUsed
                                                              ? 2.5
                                                              : 2.5),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        isSelected
                                                            ? Colors.blue
                                                                .withOpacity(
                                                                  0.3,
                                                                )
                                                            : Colors.black
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                    blurRadius:
                                                        isSelected ? 12 : 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Image.asset(
                                                    _getImagePath(imageName),
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Center(
                                                        child: Text(
                                                          imageName,
                                                          style: TextStyle(
                                                            fontSize:
                                                                boxSize * 0.2,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Kontrol Et butonu
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade400,
                                      Colors.blue.shade600,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: ElevatedButton(
                                  onPressed: showFeedback ? null : checkAnswers,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: Text(
                                    isEnglish ? 'Check' : 'Kontrol Et',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Alt feedback strip
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
                                            ? "Try again! 😔"
                                            : "Tekrar dene! 😔"),
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
