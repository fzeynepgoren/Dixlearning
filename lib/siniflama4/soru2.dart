import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'soru4.dart';

class DuyuOrganlariSinifla extends StatefulWidget {
  const DuyuOrganlariSinifla({super.key});

  @override
  State<DuyuOrganlariSinifla> createState() => _DuyuOrganlariSiniflaState();
}

class _DuyuOrganlariSiniflaState extends State<DuyuOrganlariSinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    // Burun için öğeler
    {'emoji': '🌸', 'id': 'cicek', 'organ': 'burun', 'isPlaced': false},
    {'emoji': '🧴', 'id': 'parfum', 'organ': 'burun', 'isPlaced': false},

    // Kulak için öğeler
    {'emoji': '🎧', 'id': 'kulaklik', 'organ': 'kulak', 'isPlaced': false},
    {'emoji': '🎵', 'id': 'muzik', 'organ': 'kulak', 'isPlaced': false},

    // Dil için öğeler
    {'emoji': '🍫', 'id': 'cikolata', 'organ': 'dil', 'isPlaced': false},
    {'emoji': '🍭', 'id': 'seker', 'organ': 'dil', 'isPlaced': false},
  ];

  final Map<String, List<Map<String, dynamic>>> organGroups = {
    'burun': [],
    'kulak': [],
    'dil': [],
  };

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
    // Emojileri karıştır
    items.shuffle();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleDrag(Map<String, dynamic> item, String organ) {
    setState(() {
      isCorrect = item['organ'] == organ;
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    if (isCorrect) {
      setState(() {
        if (!item['isPlaced']) {
          organGroups[organ]!.add(item);
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
    bool allPlaced = items.every((item) => item['isPlaced']);
    if (allPlaced && !_dialogShown) {
      _dialogShown = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // Etkinlik tamamlandı

          ActivityTracker.completeActivity();

          

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AtikSinifla(),
            ),
          );
        }
      });
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
              ? 'Classify by Sensory Organs'
              : 'Duyu Organlarına Göre Sınıfla',
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
                        ? 'Drag the objects to the correct sensory organ!'
                        : 'Nesneleri doğru duyu organına sürükle!',
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
                        child: _buildOrganGroup(
                          isEnglish ? 'Nose' : 'Burun',
                          'burun',
                          '👃',
                          Colors.purple.shade200,
                          isEnglish,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOrganGroup(
                          isEnglish ? 'Ear' : 'Kulak',
                          'kulak',
                          '👂',
                          Colors.orange.shade200,
                          isEnglish,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOrganGroup(
                          isEnglish ? 'Tongue' : 'Dil',
                          'dil',
                          '👅',
                          Colors.red.shade200,
                          isEnglish,
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
                            feedback: Text(
                              item['emoji'],
                              style: const TextStyle(fontSize: 48),
                            ),
                            childWhenDragging: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              item['emoji'],
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                const SizedBox(height: 20),
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
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
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
                              isCorrect
                                  ? (isEnglish ? 'Well done! 🎉' : 'Aferin! 🎉')
                                  : (isEnglish
                                      ? 'Try again! 😔'
                                      : 'Tekrar dene! 😔'),
                              style: TextStyle(
                                fontSize: 24,
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildOrganGroup(
      String title, String organ, String emoji, Color color, bool isEnglish) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (data) => _handleDrag(data.data, organ),
      builder: (context, candidateItems, rejectedItems) {
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 30),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize:
                              title == (isEnglish ? 'Tongue' : 'Dil') ? 36 : 54,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: organGroups[organ]!
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
}
