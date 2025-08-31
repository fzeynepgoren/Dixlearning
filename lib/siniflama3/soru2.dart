import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'soru4.dart'; // TasitSinifla sınıfının olduğu dosya

class BoyutSinifla extends StatefulWidget {
  const BoyutSinifla({super.key});

  @override
  State<BoyutSinifla> createState() => _BoyutSiniflaState();
}

class _BoyutSiniflaState extends State<BoyutSinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {'emoji': '⚽', 'id': 'futbol1', 'size': 'buyuk', 'isPlaced': false},
    {'emoji': '⚽', 'id': 'futbol2', 'size': 'kucuk', 'isPlaced': false},
    {'emoji': '🏀', 'id': 'basket1', 'size': 'orta', 'isPlaced': false},
    {'emoji': '🏀', 'id': 'basket2', 'size': 'buyuk', 'isPlaced': false},
    {'emoji': '⚾', 'id': 'beyzbol1', 'size': 'kucuk', 'isPlaced': false},
    {'emoji': '⚾', 'id': 'beyzbol2', 'size': 'orta', 'isPlaced': false},
  ];

  final Map<String, List<Map<String, dynamic>>> sizeGroups = {
    'kucuk': [],
    'orta': [],
    'buyuk': [],
  };

  bool showFeedback = false;
  bool isCorrect = false;
  bool _dialogShown = false;

  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    items.shuffle();

    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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

  void _handleDrag(Map<String, dynamic> item, String targetSize) {
    setState(() {
      isCorrect = item['size'] == targetSize;
      showFeedback = true;
    });

    _feedbackController.forward(from: 0);

    if (isCorrect && !item['isPlaced']) {
      final groupList = sizeGroups[targetSize];
      groupList?.add(item);
      item['isPlaced'] = true;
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

  void _checkCompletion() {
    final allPlaced = items.every((e) => e['isPlaced'] == true);
    if (allPlaced && !_dialogShown) {
      _dialogShown = true;
      ActivityTracker.completeActivity();

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const TasitSinifla(),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Colors.white,
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
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
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
                          const SizedBox(height: 10),
                          const Text(
                            'Nesneleri boyutlarına göre sınıfla!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildGroup('Küçük', sizeGroups['kucuk']!, 'kucuk', Colors.blue.shade50, Colors.blue),
                                      _buildGroup('Orta', sizeGroups['orta']!, 'orta', Colors.orange.shade50, Colors.orange),
                                      _buildGroup('Büyük', sizeGroups['buyuk']!, 'buyuk', Colors.red.shade50, Colors.red),
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
                                        .map((item) => Draggable<Map<String, dynamic>>(
                                      data: item,
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: _buildItemBox(item['emoji'], item['size']),
                                      ),
                                      childWhenDragging: const SizedBox.shrink(),
                                      child: _buildItemBox(item['emoji'], item['size']),
                                    ))
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: showFeedback
                      ? ScaleTransition(
                    scale: CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
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
                          isCorrect ? 'Aferin! 🎉' : 'Tekrar dene! 😔',
                          style: TextStyle(
                            fontSize: 18,
                            color: isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildGroup(String title, List<Map<String, dynamic>> group, String sizeType, Color boxColor, Color borderColor) {
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => true,
      onAccept: (data) => _handleDrag(data, sizeType),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: double.infinity,
          height: 145,
          margin: const EdgeInsets.symmetric(vertical: 7),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: boxColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 4,
                    children: group
                        .map((item) => Text(
                      item['emoji'],
                      style: TextStyle(
                        fontSize: item['size'] == 'kucuk'
                            ? 18
                            : item['size'] == 'orta'
                            ? 30
                            : 54,
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemBox(String emoji, String size) {
    double fontSize;
    switch (size) {
      case 'kucuk':
        fontSize = 18;
        break;
      case 'orta':
        fontSize = 30;
        break;
      case 'buyuk':
        fontSize = 54;
        break;
      default:
        fontSize = 30;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: 90,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: fontSize),
        ),
      ),
    );
  }
}
