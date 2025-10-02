import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'soru4.dart'; // Corrected class name from Soru4 to TeknolojikSinifla

class CanliCansizSinifla extends StatefulWidget {
  const CanliCansizSinifla({super.key});

  @override
  State<CanliCansizSinifla> createState() => _CanliCansizSiniflaState();
}

class _CanliCansizSiniflaState extends State<CanliCansizSinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {
      'emoji': '🐈',
      'category': 'living',
      'isPlaced': false,
    },
    {
      'emoji': '🪑',
      'category': 'non-living',
      'isPlaced': false,
    },
    {
      'emoji': '🌳',
      'category': 'living',
      'isPlaced': false,
    },
    {
      'emoji': '✏️',
      'category': 'non-living',
      'isPlaced': false,
    },
  ];

  final List<String> livingGroup = [];
  final List<String> nonLivingGroup = [];
  bool showFeedback = false;
  bool isCorrect = false;
  bool _dialogShown = false;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

  void _handleDrag(String draggedEmoji, String targetCategory) {
    final item = items.firstWhere((e) => e['emoji'] == draggedEmoji);
    bool isCorrectMatch = item['category'] == targetCategory;

    setState(() {
      isCorrect = isCorrectMatch;
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    if (isCorrectMatch) {
      setState(() {
        if (!item['isPlaced']) {
          if (targetCategory == 'living') {
            livingGroup.add(draggedEmoji);
          } else {
            nonLivingGroup.add(draggedEmoji);
          }
          item['isPlaced'] = true;
        }
      });
      _checkCompletion();
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => showFeedback = false);
    });
  }

  void _checkCompletion() {
    if (livingGroup.length + nonLivingGroup.length == items.length) {
      bool allCorrect =
      items.every((item) =>
      (item['category'] == 'living' && livingGroup.contains(item['emoji'])) ||
          (item['category'] == 'non-living' && nonLivingGroup.contains(item['emoji'])));

      if (allCorrect && !_dialogShown) {
        _dialogShown = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TeknolojikSinifla(),
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
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.065;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade200, Colors.blue.shade200, const Color(0xffffffff)],
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
                    onPressed: () => Navigator.of(context).pop(),
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
                          child: Text(
                            isEnglish
                                ? 'Drag the objects to the correct group!'
                                : 'Nesneleri doğru gruba sürükle!',
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: _buildGroupContainer(
                                        'non-living',
                                        isEnglish,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: _buildGroupContainer(
                                        'living',
                                        isEnglish,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: items.where((item) => !item['isPlaced']).map((item) {
                                    return Draggable<String>(
                                      data: item['emoji'],
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: _buildItemBox(item['emoji']),
                                      ),
                                      childWhenDragging: const SizedBox.shrink(),
                                      child: _buildItemBox(item['emoji']),
                                    );
                                  }).toList(),
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
                    horizontal: 20, vertical: 10),
                child: showFeedback
                    ? ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _feedbackController,
                    curve: Curves.elasticOut,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
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
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemBox(String emoji) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: 90,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 60),
        ),
      ),
    );
  }

  Widget _buildGroupContainer(
      String category,
      bool isEnglish,
      ) {
    Color boxColor = category == 'living' ? Colors.blue.shade100 : Colors.deepPurple.shade100;
    Color borderColor = category == 'living' ? Colors.blue.shade400 : Colors.deepPurple.shade300;
    List<String> group = category == 'living' ? livingGroup : nonLivingGroup;

    return DragTarget<String>(
      onWillAccept: (data) => true,
      onAccept: (data) => _handleDrag(data!, category),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: boxColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isEnglish
                    ? (category == 'living' ? 'Living Objects' : 'Non-living Objects')
                    : (category == 'living' ? 'Canlı Nesneler' : 'Cansız Nesneler'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: group.map(
                      (emoji) => Text(
                    emoji,
                    style: const TextStyle(fontSize: 60),
                  ),
                ).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}