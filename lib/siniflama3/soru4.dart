import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'soru5.dart';

class TasitSinifla extends StatefulWidget {
  const TasitSinifla({super.key});

  @override
  State<TasitSinifla> createState() => _TasitSiniflaState();
}

class _TasitSiniflaState extends State<TasitSinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {'emoji': '🚗', 'id': 'araba', 'type': 'kara', 'isPlaced': false},
    {'emoji': '🚌', 'id': 'otobus', 'type': 'kara', 'isPlaced': false},
    {'emoji': '🚢', 'id': 'gemi', 'type': 'deniz', 'isPlaced': false},
    {'emoji': '⛵', 'id': 'yelkenli', 'type': 'deniz', 'isPlaced': false},
    {'emoji': '✈️', 'id': 'ucak', 'type': 'hava', 'isPlaced': false},
    {'emoji': '🚁', 'id': 'helikopter', 'type': 'hava', 'isPlaced': false},
  ];

  final List<Map<String, dynamic>> landGroup = [];
  final List<Map<String, dynamic>> seaGroup = [];
  final List<Map<String, dynamic>> airGroup = [];
  bool showFeedback = false;
  bool isCorrect = false;
  bool _dialogShown = false;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
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

  void _handleDrag(Map<String, dynamic> item, String type) {
    setState(() {
      isCorrect = item['type'] == type;
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    if (isCorrect) {
      setState(() {
        if (!item['isPlaced']) {
          if (type == 'kara') {
            landGroup.add(item);
          } else if (type == 'deniz') {
            seaGroup.add(item);
          } else if (type == 'hava') {
            airGroup.add(item);
          }
          item['isPlaced'] = true;
        }
      });
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
    if (landGroup.length + seaGroup.length + airGroup.length == items.length) {
      bool isCorrect = true;
      for (var item in landGroup) {
        if (item['type'] != 'kara') {
          isCorrect = false;
          break;
        }
      }
      for (var item in seaGroup) {
        if (item['type'] != 'deniz') {
          isCorrect = false;
          break;
        }
      }
      for (var item in airGroup) {
        if (item['type'] != 'hava') {
          isCorrect = false;
          break;
        }
      }
      if (isCorrect && !_dialogShown) {
        _dialogShown = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const HayvanYasamSinifla(),
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: Text(
          isEnglish
              ? 'Classify Vehicles by Type'
              : 'Taşıt Türü ve Alanı Sınıflama',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  child: Text(
                    isEnglish
                        ? 'Drag the vehicles to the correct group!'
                        : 'Taşıtları doğru gruba sürükle!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildGroup(
                          isEnglish ? 'Land' : 'Kara',
                          landGroup,
                          'kara',
                          Colors.green.shade200,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGroup(
                          isEnglish ? 'Sea' : 'Deniz',
                          seaGroup,
                          'deniz',
                          Colors.blue.shade200,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGroup(
                          isEnglish ? 'Air' : 'Hava',
                          airGroup,
                          'hava',
                          Colors.purple.shade200,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  height: 120,
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
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      if (!item['isPlaced']) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Draggable<Map<String, dynamic>>(
                            data: item,
                            feedback: _buildDraggableItem(item),
                            childWhenDragging: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _buildDraggableItem(item),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
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
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(String title, List<Map<String, dynamic>> group,
      String type, Color color) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (data) => _handleDrag(data.data, type),
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                width: double.infinity,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
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
                                style: const TextStyle(fontSize: 48),
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

  Widget _buildDraggableItem(Map<String, dynamic> item) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          item['emoji'],
          style: const TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
