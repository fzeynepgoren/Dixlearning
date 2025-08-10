import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'soru4.dart';

class BoyutSinifla extends StatefulWidget {
  const BoyutSinifla({super.key});

  @override
  State<BoyutSinifla> createState() => _BoyutSiniflaState();
}

class _BoyutSiniflaState extends State<BoyutSinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {'emoji': '⚽', 'id': 'futbol1', 'size': 'buyuk'},
    {'emoji': '⚽', 'id': 'futbol2', 'size': 'kucuk'},
    {'emoji': '🏀', 'id': 'basket1', 'size': 'orta'},
    {'emoji': '🏀', 'id': 'basket2', 'size': 'buyuk'},
    {'emoji': '⚾', 'id': 'beyzbol1', 'size': 'kucuk'},
    {'emoji': '⚾', 'id': 'beyzbol2', 'size': 'orta'},
  ];
  late List<Map<String, dynamic>> shuffledItems;
  List<Map<String, dynamic>> kucukItems = [];
  List<Map<String, dynamic>> ortaItems = [];
  List<Map<String, dynamic>> buyukItems = [];
  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    shuffledItems = List.from(items);
    shuffledItems.shuffle();

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

  double getTopSize(String size) {
    switch (size) {
      case 'kucuk':
        return 20.0;
      case 'orta':
        return 40.0;
      case 'buyuk':
        return 80.0;
      default:
        return 20.0;
    }
  }

  void _handleDrag(Map<String, dynamic> item, String targetSize) {
    setState(() {
      isCorrect = item['size'] == targetSize;
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    if (isCorrect) {
      setState(() {
        switch (targetSize) {
          case 'kucuk':
            kucukItems.add(item);
            break;
          case 'orta':
            ortaItems.add(item);
            break;
          case 'buyuk':
            buyukItems.add(item);
            break;
        }
        shuffledItems.remove(item);
      });

      if (shuffledItems.isEmpty && !_dialogShown) {
        _dialogShown = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            // Etkinlik tamamlandı

            ActivityTracker.completeActivity();

            

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

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          showFeedback = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: const Text('Boyut Sınıflama',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.shade100,
                  Colors.deepPurple.shade50,
                  Colors.white,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Nesneleri boyutlarına göre sınıfla!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildGroup(
                            'Küçük', kucukItems, 'kucuk', Colors.blue.shade100),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGroup(
                            'Orta', ortaItems, 'orta', Colors.orange.shade100),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGroup(
                            'Büyük', buyukItems, 'buyuk', Colors.red.shade100),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(12),
                    itemCount: shuffledItems.length,
                    itemBuilder: (context, index) {
                      final item = shuffledItems[index];
                      final size = getTopSize(item['size']);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Draggable<Map<String, dynamic>>(
                          data: item,
                          feedback: Text(
                            item['emoji'],
                            style: TextStyle(fontSize: size),
                          ),
                          childWhenDragging: SizedBox(
                            width: size,
                            height: size,
                          ),
                          child: Text(
                            item['emoji'],
                            style: TextStyle(fontSize: size),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (showFeedback)
                  Center(
                    child: ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _feedbackController,
                        curve: Curves.elasticOut,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isCorrect ? 'Aferin! 🎉' : 'Tekrar dene! 😔',
                              style: TextStyle(
                                fontSize: 20,
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(String title, List<Map<String, dynamic>> group,
      String size, Color color) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (data) => _handleDrag(data.data, size),
      builder: (context, candidateItems, rejectedItems) {
        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: color == Colors.blue.shade100
                      ? Colors.blue.shade200
                      : color == Colors.orange.shade100
                          ? Colors.orange.shade200
                          : Colors.red.shade200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color == Colors.blue.shade100
                        ? Colors.blue
                        : color == Colors.orange.shade100
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: group
                        .map((item) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                item['emoji'],
                                style: TextStyle(
                                    fontSize: getTopSize(item['size'])),
                                textAlign: TextAlign.center,
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
}
