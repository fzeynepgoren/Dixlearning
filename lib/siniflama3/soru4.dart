import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'soru5.dart'; // HayvanYasamSinifla sınıfının bulunduğu dosya

class TasitSinifla extends StatefulWidget {
  const TasitSinifla({super.key});

  @override
  State<TasitSinifla> createState() => _TasitSiniflaState();
}

class _TasitSiniflaState extends State<TasitSinifla> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {'emoji': '🚗', 'id': 'araba', 'type': 'kara', 'isPlaced': false},
    {'emoji': '🚌', 'id': 'otobus', 'type': 'kara', 'isPlaced': false},
    {'emoji': '🚢', 'id': 'gemi', 'type': 'deniz', 'isPlaced': false},
    {'emoji': '⛵', 'id': 'yelkenli', 'type': 'deniz', 'isPlaced': false},
    {'emoji': '✈️', 'id': 'ucak', 'type': 'hava', 'isPlaced': false},
    {'emoji': '🚁', 'id': 'helikopter', 'type': 'hava', 'isPlaced': false},
  ];

  final Map<String, List<Map<String, dynamic>>> typeGroups = {
    'kara': [],
    'deniz': [],
    'hava': [],
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

  void _handleDrag(Map<String, dynamic> item, String targetType) {
    bool correct = item['type'] == targetType;

    setState(() {
      isCorrect = correct;
      showFeedback = true;

      if (correct && !item['isPlaced']) {
        typeGroups[targetType]?.add(item);
        item['isPlaced'] = true;
      }
    });

    _feedbackController.forward(from: 0);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          showFeedback = false;
        });
      }
    });

    if (correct) {
      _checkCompletion();
    }
  }

  void _checkCompletion() {
    final allPlaced = items.every((e) => e['isPlaced'] == true);
    if (allPlaced && !_dialogShown) {
      _dialogShown = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HayvanYasamSinifla()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.065;

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
                      icon: Icon(Icons.arrow_back, color: Colors.black, size: iconSize),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                            child: Text(
                              isEnglish
                                  ? 'Drag the vehicles to the correct group!'
                                  : 'Taşıtları doğru gruba sürükle!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
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
                                      _buildGroup(
                                        isEnglish ? 'Land' : 'Kara',
                                        typeGroups['kara']!,
                                        'kara',
                                        Colors.green.shade50,
                                        Colors.green,
                                      ),
                                      _buildGroup(
                                        isEnglish ? 'Sea' : 'Deniz',
                                        typeGroups['deniz']!,
                                        'deniz',
                                        Colors.blue.shade50,
                                        Colors.lightBlue,
                                      ),
                                      _buildGroup(
                                        isEnglish ? 'Air' : 'Hava',
                                        typeGroups['hava']!,
                                        'hava',
                                        Colors.purple.shade50,
                                        Colors.deepPurpleAccent,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: items
                                          .where((item) => !item['isPlaced'])
                                          .map((item) => Draggable<Map<String, dynamic>>(
                                        data: item,
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: _buildDraggableItem(item),
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: 0.3,
                                          child: _buildDraggableItem(item),
                                        ),
                                        child: _buildDraggableItem(item),
                                      ))
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
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: showFeedback
                      ? ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _feedbackController,
                      curve: Curves.elasticOut,
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
                              : (isEnglish ? 'Try again! 😔' : 'Tekrar dene! 😔'),
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

  Widget _buildGroup(String title, List<Map<String, dynamic>> group, String type,
      Color boxColor, Color borderColor) {
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => data?['type'] == type,
      onAccept: (data) => _handleDrag(data, type),
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
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
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
                      style: const TextStyle(fontSize: 50, color: Colors.black),
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

  Widget _buildDraggableItem(Map<String, dynamic> item) {
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
          item['emoji'],
          style: const TextStyle(fontSize: 50, color: Colors.black),
        ),
      ),
    );
  }
}
