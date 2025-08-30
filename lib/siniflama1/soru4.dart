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
                                  ? 'Drag the items to the correct group!'
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: _buildGroupContainer(
                                          foodGroup,
                                          true,
                                          isEnglish,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: _buildGroupContainer(
                                          drinkGroup,
                                          false,
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
                                    children: items
                                        .where((item) => !item['isPlaced'])
                                        .map((item) {
                                      return Draggable<
                                          Map<String, dynamic>
                                      >(
                                        data: item,
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: _buildItemBox(item),
                                        ),
                                        childWhenDragging: const SizedBox.shrink(),
                                        child: _buildItemBox(item),
                                      );
                                    })
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
                    child: Row(
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

  Widget _buildGroupContainer(
      List<Map<String, dynamic>> group,
      bool isFood,
      bool isEnglish,
      ) {
    Color boxColor = isFood ? const Color(0xFFE8F5E8) : const Color(0xFFD6ECFF);
    Color borderColor = isFood ? Colors.green : Colors.lightBlue;

    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (item) => true,
      onAccept: (item) => _handleDrag(item!, isFood),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: double.infinity,
          height: 140,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: boxColor,
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isFood
                    ? (isEnglish ? 'Food' : 'Yiyecek')
                    : (isEnglish ? 'Drinks' : 'İçecek'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: group
                    .map((item) => Text(
                  item['emoji'],
                  style: const TextStyle(fontSize: 36),
                ))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemBox(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: 100,
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
          item['emoji'],
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );
  }
}