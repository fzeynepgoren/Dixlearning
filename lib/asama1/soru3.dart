import 'package:dixlearning/asama1/soru4.dart';
import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: const Text('Ana Menü'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GeometricMatching()),
                );
              },
              child: const Text(
                'Oyunu Başlat',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
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
    Shape(shape: 'Kare', color: const Color(0xFFE57373), icon: Icons.square),
    Shape(shape: 'Daire', color: const Color(0xFF81C784), icon: Icons.circle),
    Shape(
        shape: 'Üçgen',
        color: const Color(0xFF64B5F6),
        icon: Icons.change_history),
  ];

  late List<Shape> rightShapes;
  Shape? draggedShape;
  Map<String, String> matches = {};
  bool showFeedback = false;
  bool isCorrect = false;

  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    rightShapes = List.from(leftShapes)..shuffle();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
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
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Soru4()),
            );
          }
        });
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              showFeedback = false;
            });
          }
        });
      }
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            showFeedback = false;
          });
        }
      });
    }
  }

  Color? getMatchedColor(String shapeName) {
    if (matches.containsKey(shapeName)) {
      return leftShapes.firstWhere((s) => s.shape == shapeName).color;
    }
    return null;
  }

  Widget buildLeftShapeContainer(Shape shape, {bool isDragging = false}) {
    final matchedColor = getMatchedColor(shape.shape);

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: matchedColor ?? shape.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: shape.shape == 'Üçgen'
            ? SizedBox(
                width: 50,
                height: 50,
                child: CustomPaint(
                  painter: TrianglePainter(color: Colors.white),
                ),
              )
            : Icon(
                shape.icon,
                size: 50,
                color: Colors.white,
              ),
      ),
    );
  }

  Widget buildRightShapeContainer(Shape shape, {bool isTarget = false}) {
    final matchedColor = getMatchedColor(shape.shape);

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: matchedColor ?? (isTarget ? Colors.blue.shade200 : Colors.white),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: shape.shape == 'Üçgen'
            ? SizedBox(
                width: 50,
                height: 50,
                child: CustomPaint(
                  painter: TrianglePainter(
                    color: matchedColor != null
                        ? Colors.white
                        : Colors.grey.shade800,
                  ),
                ),
              )
            : Icon(
                shape.icon,
                size: 50,
                color:
                    matchedColor != null ? Colors.white : Colors.grey.shade800,
              ),
      ),
    );
  }

  Widget buildDraggingShape(Shape shape) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: shape.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: shape.shape == 'Üçgen'
            ? SizedBox(
                width: 50,
                height: 50,
                child: CustomPaint(
                  painter: TrianglePainter(color: Colors.white),
                ),
              )
            : Icon(
                shape.icon,
                size: 50,
                color: Colors.white,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: const Text(
          'Şekil Eşleştirme Oyunu',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Renkli şekilleri gölgelerine sürükle!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...leftShapes.map((shape) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Draggable<String>(
                              data: shape.shape,
                              feedback: Material(
                                elevation: 8,
                                child: buildDraggingShape(shape),
                              ),
                              childWhenDragging: buildLeftShapeContainer(shape),
                              child: buildLeftShapeContainer(shape),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Container(
                    width: 4,
                    height: MediaQuery.of(context).size.height * 0.5,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...rightShapes.map((shape) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: DragTarget<String>(
                              builder: (context, candidateData, rejectedData) {
                                return buildRightShapeContainer(
                                  shape,
                                  isTarget: candidateData.isNotEmpty,
                                );
                              },
                              onWillAcceptWithDetails: (details) =>
                                  !matches.containsKey(details.data) &&
                                  !matches.containsValue(shape.shape),
                              onAcceptWithDetails: (details) =>
                                  checkMatch(details.data, shape.shape),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (showFeedback)
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _feedbackController,
                  curve: Curves.elasticOut,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
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
                          color: isCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class Shape {
  final String shape;
  final Color color;
  final IconData icon;

  Shape({
    required this.shape,
    required this.color,
    required this.icon,
  });
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
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
