import 'package:dixlearning/asama1/soru4.dart';
import 'package:flutter/material.dart';
import '../screens/matching_questions_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Şekil Eşleştirme Oyunu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Şekil Eşleştirme Oyunu'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade300,
        elevation: 4,
        toolbarHeight: 80,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade100, Colors.white],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 25,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GeometricMatching(),
                    ),
                  );
                },
                child: const Text(
                  'Oyunu Başlat',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GeometricMatching extends StatefulWidget {
  const GeometricMatching({super.key});

  @override
  State<GeometricMatching> createState() => _GeometricMatchingState();
}

class _GeometricMatchingState extends State<GeometricMatching>
    with TickerProviderStateMixin {
  final List<Shape> leftShapes = [
    Shape(
      shape: 'Kare',
      color: const Color(0xFFE57373),
      icon: Icons.square_outlined,
    ),
    Shape(
      shape: 'Daire',
      color: const Color.fromARGB(255, 170, 111, 199),
      icon: Icons.circle_outlined,
    ),
    Shape(
      shape: 'Üçgen',
      color: const Color(0xFF64B5F6),
      icon: Icons.change_history,
    ),
  ];

  late List<Shape> rightShapes;
  Shape? selectedLeftShape;
  Map<String, String> matches = {};
  bool showFeedback = false;
  bool isCorrect = false;

  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    rightShapes = List.from(leftShapes)..shuffle();
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

  Future<void> _trackWrongAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('asama1_wrong_count') ?? 0;
    wrongCount++;
    await prefs.setInt('asama1_wrong_count', wrongCount);
  }

  void checkMatch(String leftShape, String rightShape) {
    setState(() {
      isCorrect = leftShape == rightShape;
      showFeedback = true;
    });

    _feedbackController.forward(from: 0);

    if (isCorrect) {
      setState(() {
        matches[leftShape] = rightShape;
      });
      if (matches.length == leftShapes.length) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Soru4()),
            );
          }
        });
      } else {
        // Feedback'i 2 saniye sonra gizle
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              showFeedback = false;
              selectedLeftShape = null; // Seçimi temizle
            });
          }
        });
      }
    } else {
      // Yanlış cevap için feedback'i 2 saniye sonra gizle
      _trackWrongAnswer();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            showFeedback = false;
            selectedLeftShape = null; // Seçimi temizle
          });
        }
      });
    }
  }

  // Şekil kartlarının modern tasarımı
  Widget buildShapeCard(
    Shape shape, {
    bool isMatched = false,
    bool isShadow = false,
    bool isSelected = false,
  }) {
    Color cardColor;
    Color iconColor;

    if (isMatched) {
      cardColor = Colors.green.shade400;
      iconColor = Colors.white;
    } else if (isShadow) {
      cardColor = Colors.grey.shade200;
      iconColor = Colors.grey.shade600;
    } else {
      // Sol taraf için orijinal renkli arka plan
      cardColor = shape.color;
      iconColor = Colors.white;
    }

    return AnimatedContainer(
      duration:
          showFeedback ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 120,
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border:
            isSelected && !isMatched && !isShadow
                ? Border.all(color: Colors.white, width: 3)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child:
            shape.shape == 'Üçgen'
                ? SizedBox(
                  width: 50,
                  height: 50,
                  child: CustomPaint(
                    painter: TrianglePainter(color: iconColor),
                  ),
                )
                : Icon(shape.icon, size: 48, color: iconColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
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
                      size: screenSize.width * 0.065,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const MatchingQuestionsScreen(),
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
                          child: const Text(
                            'Renkli şekillere tıkla ve gölgeleriyle eşleştir!',
                            style: TextStyle(
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
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ...leftShapes.map((shape) {
                                      final isMatched = matches.containsKey(
                                        shape.shape,
                                      );
                                      final isSelected =
                                          selectedLeftShape?.shape ==
                                          shape.shape;

                                      return GestureDetector(
                                        onTap:
                                            isMatched || showFeedback
                                                ? null
                                                : () {
                                                  setState(() {
                                                    selectedLeftShape = shape;
                                                  });
                                                },
                                        child: buildShapeCard(
                                          shape,
                                          isSelected: isSelected,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),

                              // BAŞLANGIÇ: MAVİ GRADYAN ÇİZGİ BÖLÜMÜ (425.0 Yüksekliğe Ayarlandı)
                              SizedBox(
                                height:
                                    425.0, // Çizginin uzunluğu burada ayarlandı
                                child: Container(
                                  width: 4, // Çizginin kalınlığı
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.blue.shade400,
                                        Colors.blue.shade200,
                                        Colors.blue.shade100,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),

                              // SON: MAVİ GRADYAN ÇİZGİ BÖLÜMÜ
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ...rightShapes.map((shape) {
                                      final isMatched = matches.containsValue(
                                        shape.shape,
                                      );
                                      return GestureDetector(
                                        onTap:
                                            isMatched ||
                                                    selectedLeftShape == null ||
                                                    showFeedback
                                                ? null
                                                : () {
                                                  if (selectedLeftShape !=
                                                      null) {
                                                    checkMatch(
                                                      selectedLeftShape!.shape,
                                                      shape.shape,
                                                    );
                                                  }
                                                },
                                        child: buildShapeCard(
                                          shape,
                                          isShadow: !isMatched,
                                          isMatched: isMatched,
                                        ),
                                      );
                                    }),
                                  ],
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
                              children: [
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect ? Colors.green : Colors.red,
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  isCorrect ? 'Aferin! 🎉' : 'Tekrar dene! 😔',
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
    );
  }
}

class Shape {
  final String shape;
  final Color color;
  final IconData icon;

  Shape({required this.shape, required this.color, required this.icon});
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
