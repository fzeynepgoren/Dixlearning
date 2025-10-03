import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../screens/home_screen.dart';

class HayvanYasamSinifla extends StatefulWidget {
  const HayvanYasamSinifla({super.key});

  @override
  State<HayvanYasamSinifla> createState() => _HayvanYasamSiniflaState();
}

class _HayvanYasamSiniflaState extends State<HayvanYasamSinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {'emoji': '🐟', 'id': 'balik1', 'habitat': 'water', 'isPlaced': false},
    {'emoji': '🐠', 'id': 'balik2', 'habitat': 'water', 'isPlaced': false},
    {'emoji': '🦅', 'id': 'kus1', 'habitat': 'air', 'isPlaced': false},
    {'emoji': '🦜', 'id': 'kus2', 'habitat': 'air', 'isPlaced': false},
    {'emoji': '🦙', 'id': 'kara1', 'habitat': 'land', 'isPlaced': false},
    {'emoji': '🐑', 'id': 'kara2', 'habitat': 'land', 'isPlaced': false},
  ];

  final Map<String, List<Map<String, dynamic>>> habitatGroups = {
    'water': [],
    'air': [],
    'land': [],
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

  void _handleDrag(Map<String, dynamic> item, String targetHabitat) {
    bool correct = item['habitat'] == targetHabitat;

    setState(() {
      isCorrect = correct;
      showFeedback = true;

      if (correct && !item['isPlaced']) {
        habitatGroups[targetHabitat]?.add(item);
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
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepPurple.shade100,
                          Colors.deepPurple.shade50,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 80,
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          Provider.of<LanguageProvider>(
                                context,
                                listen: false,
                              ).isEnglish
                              ? 'Congratulations! 🎉'
                              : 'Tebrikler! 🎉',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          Provider.of<LanguageProvider>(
                                context,
                                listen: false,
                              ).isEnglish
                              ? 'You have completed the activity!'
                              : 'Etkinliği tamamladınız!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            Provider.of<LanguageProvider>(
                                  context,
                                  listen: false,
                                ).isEnglish
                                ? 'Back to Menu'
                                : 'Ana Menüye Dön',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 1,
                            ),
                            child: Text(
                              isEnglish
                                  ? 'Drag the animals to their habitats!'
                                  : 'Hayvanları yaşam alanlarına sürükle!',
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildGroup(
                                        'water',
                                        isEnglish ? 'Water' : 'Su',
                                        Colors.purple.shade100,
                                        Colors.purple.shade300,
                                        habitatGroups['water']!,
                                      ),
                                      _buildGroup(
                                        'air',
                                        isEnglish ? 'Air' : 'Hava',
                                        Colors.blue.shade100,
                                        Colors.blue.shade400,
                                        habitatGroups['air']!,
                                      ),
                                      _buildGroup(
                                        'land',
                                        isEnglish ? 'Land' : 'Kara',
                                        Colors.yellow.shade100,
                                        Colors.yellow.shade600,
                                        habitatGroups['land']!,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children:
                                          items
                                              .where(
                                                (item) => !item['isPlaced'],
                                              )
                                              .map(
                                                (item) => Draggable<
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
                                                ),
                                              )
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
    String key,
    String title,
    Color boxColor,
    Color borderColor,
    List<Map<String, dynamic>> group,
  ) {
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
      child: DragTarget<Map<String, dynamic>>(
        onWillAccept: (data) => true, // tüm sürüklemeleri kabul et
        onAccept: (data) => _handleDrag(data!, key),
        builder: (context, candidateData, rejectedData) {
          return Column(
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
                    children:
                        group
                            .map(
                              (item) => Text(
                                item['emoji'],
                                style: const TextStyle(
                                  fontSize: 50,
                                  color: Colors.black,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDraggableItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      width: 70,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Center(
        child: Text(
          item['emoji'],
          style: const TextStyle(fontSize: 40, color: Colors.black),
        ),
      ),
    );
  }
}
