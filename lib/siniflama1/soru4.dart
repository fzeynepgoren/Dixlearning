import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'soru5.dart';

class YiyecekIcecekSinifla extends StatefulWidget {
  const YiyecekIcecekSinifla({super.key});

  @override
  State<YiyecekIcecekSinifla> createState() => _YiyecekIcecekSiniflaState();
}

class _YiyecekIcecekSiniflaState extends State<YiyecekIcecekSinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {'emoji': '🥛', 'id': 'sut', 'isFood': false, 'isPlaced': false},
    {'emoji': '🍰', 'id': 'kek', 'isFood': true, 'isPlaced': false},
    {'emoji': '🍹', 'id': 'meyveSuyu', 'isFood': false, 'isPlaced': false},
    {'emoji': '🍞', 'id': 'ekmek', 'isFood': true, 'isPlaced': false},
  ];

  final List<Map<String, dynamic>> foodGroup = [];
  final List<Map<String, dynamic>> drinkGroup = [];
  bool showFeedback = false;
  bool isCorrect = false;
  bool _dialogShown = false;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleDrag(Map<String, dynamic> item, bool isFood) {
    setState(() {
      isCorrect = item['isFood'] == isFood;
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    if (isCorrect) {
      setState(() {
        if (!item['isPlaced']) {
          if (isFood) {
            foodGroup.add(item);
          } else {
            drinkGroup.add(item);
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
    if (foodGroup.length + drinkGroup.length == items.length) {
      bool isCorrect = true;
      for (var item in foodGroup) {
        if (!item['isFood']) {
          isCorrect = false;
          break;
        }
      }
      for (var item in drinkGroup) {
        if (item['isFood']) {
          isCorrect = false;
          break;
        }
      }

      if (isCorrect && !_dialogShown) {
        _dialogShown = true;

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HayvanBacakSinifla(),
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
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final iconSize = screenWidth * 0.065;

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
                // Üst kısım - Sadece geri butonu mavi arka planda
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
                    SizedBox(width: iconSize),
                  ],
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 6,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              isEnglish
                                  ? 'Drag the items to the correct group!'
                                  : 'Nesneleri doğru gruba sürükle!',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Gruplar
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildGroup(
                                  isEnglish ? 'Food' : 'Yiyecek',
                                  foodGroup,
                                  true,
                                  Colors.green.shade200,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildGroup(
                                  isEnglish ? 'Drinks' : 'İçecek',
                                  drinkGroup,
                                  false,
                                  Colors.blue.shade200,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Sürüklenebilir öğeler
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
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
                          // Feedback
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child:
                                showFeedback
                                    ? ScaleTransition(
                                      scale: CurvedAnimation(
                                        parent: _feedbackController,
                                        curve: Curves.elasticOut,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isCorrect
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color:
                                                isCorrect
                                                    ? Colors.green
                                                    : Colors.red,
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
                                                  isCorrect
                                                      ? Colors.green
                                                      : Colors.red,
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
    bool isFood,
    Color color,
  ) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (data) => _handleDrag(data.data, isFood),
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
              Container(
                height: 120,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: group.length,
                  itemBuilder: (context, index) {
                    return _buildDraggableItem(group[index]);
                  },
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
          style: const TextStyle(fontSize: 35, fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
