import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'soru5.dart';

class AtikSinifla extends StatefulWidget {
  const AtikSinifla({super.key});

  @override
  State<AtikSinifla> createState() => _AtikSiniflaState();
}

class _AtikSiniflaState extends State<AtikSinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {'emoji': '📰', 'id': 'gazete', 'type': 'kagit', 'isPlaced': false},
    {'emoji': '🗞️', 'id': 'burusuk_kagit', 'type': 'kagit', 'isPlaced': false},
    {'emoji': '🥤', 'id': 'pet_sise', 'type': 'plastik', 'isPlaced': false},
    {
      'emoji': '🧃',
      'id': 'plastik_bardak',
      'type': 'plastik',
      'isPlaced': false
    },
    {'emoji': '🍾', 'id': 'cam_sise', 'type': 'cam', 'isPlaced': false},
    {'emoji': '🥛', 'id': 'cam_bardak', 'type': 'cam', 'isPlaced': false},
  ];

  final List<Map<String, dynamic>> paperGroup = [];
  final List<Map<String, dynamic>> plasticGroup = [];
  final List<Map<String, dynamic>> glassGroup = [];
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
          if (type == 'kagit') {
            paperGroup.add(item);
          } else if (type == 'plastik') {
            plasticGroup.add(item);
          } else if (type == 'cam') {
            glassGroup.add(item);
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
    if (paperGroup.length + plasticGroup.length + glassGroup.length ==
        items.length) {
      bool isCorrect = true;
      for (var item in paperGroup) {
        if (item['type'] != 'kagit') {
          isCorrect = false;
          break;
        }
      }
      for (var item in plasticGroup) {
        if (item['type'] != 'plastik') {
          isCorrect = false;
          break;
        }
      }
      for (var item in glassGroup) {
        if (item['type'] != 'cam') {
          isCorrect = false;
          break;
        }
      }
      if (isCorrect && !_dialogShown) {
        _dialogShown = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const OlaySinifla(),
              ),
              (route) => false,
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
          isEnglish ? 'Classify Waste by Type' : 'Atık Türüne Göre Sınıflama',
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
                        ? 'Drag the waste to the correct bin!'
                        : 'Atıkları doğru kutuya sürükle!',
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
                          isEnglish ? 'Paper Bin' : 'Kağıt Kutusu',
                          paperGroup,
                          'kagit',
                          Colors.blue.shade200,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGroup(
                          isEnglish ? 'Plastic Bin' : 'Plastik Kutusu',
                          plasticGroup,
                          'plastik',
                          Colors.orange.shade200,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGroup(
                          isEnglish ? 'Glass Bin' : 'Cam Kutusu',
                          glassGroup,
                          'cam',
                          Colors.green.shade200,
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
                              isCorrect ? 'Aferin! 🎉' : 'Tekrar dene! 😔',
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title.split(' ')[0],
                        style: const TextStyle(
                          fontSize: 47,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        title.split(' ').length > 1 ? title.split(' ')[1] : '',
                        style: const TextStyle(
                          fontSize: 47,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
