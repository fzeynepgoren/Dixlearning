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
      'isPlaced': false,
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
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const OlaySinifla()),
            );
          }
        });
      }
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
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Expanded(
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
                                ? 'Drag the waste to the correct bin!'
                                : 'Atıkları doğru kutuya sürükle!',
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildGroup(
                                      isEnglish ? 'Paper Bin' : 'Kağıt Kutusu',
                                      paperGroup,
                                      'kagit',
                                      Colors.blue.shade50,
                                      Colors.blue,
                                    ),
                                    _buildGroup(
                                      isEnglish
                                          ? 'Plastic Bin'
                                          : 'Plastik Kutusu',
                                      plasticGroup,
                                      'plastik',
                                      Colors.green.shade50,
                                      Colors.green,
                                    ),
                                    _buildGroup(
                                      isEnglish ? 'Glass Bin' : 'Cam Kutusu',
                                      glassGroup,
                                      'cam',
                                      Colors.purple.shade50,
                                      Colors.purple,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:
                                        items
                                            .where((item) => !item['isPlaced'])
                                            .map((item) {
                                              return Draggable<
                                                Map<String, dynamic>
                                              >(
                                                data: item,
                                                feedback: Material(
                                                  color: Colors.transparent,
                                                  child: _buildDraggableItem(
                                                    item,
                                                  ),
                                                ),
                                                childWhenDragging: Opacity(
                                                  opacity: 0.3,
                                                  child: _buildDraggableItem(
                                                    item,
                                                  ),
                                                ),
                                                child: _buildDraggableItem(
                                                  item,
                                                ),
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
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
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

  Widget _buildGroup(
    String title,
    List<Map<String, dynamic>> group,
    String type,
    Color boxColor,
    Color borderColor,
  ) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (data) => _handleDrag(data.data, type),
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
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 4,
                children:
                    group
                        .map(
                          (item) => Text(
                            item['emoji'],
                            style: const TextStyle(
                              fontSize: 32,
                              color: Color(0xFF999999),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: 64,
      height: 64,
      child: Center(
        child: Text(
          item['emoji'],
          style: const TextStyle(fontSize: 32, color: Colors.black),
        ),
      ),
    );
  }
}
