import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../screens/home_screen.dart';

class HayvanBacakSinifla extends StatefulWidget {
  const HayvanBacakSinifla({super.key});

  @override
  State<HayvanBacakSinifla> createState() => _HayvanBacakSiniflaState();
}

class _HayvanBacakSiniflaState extends State<HayvanBacakSinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {'emoji': '🐓', 'id': 'horoz', 'isFourLegs': false, 'isPlaced': false},
    {'emoji': '🐈', 'id': 'kedi', 'isFourLegs': true, 'isPlaced': false},
    {'emoji': '🐦', 'id': 'kus', 'isFourLegs': false, 'isPlaced': false},
    {'emoji': '🐎', 'id': 'at', 'isFourLegs': true, 'isPlaced': false},
  ];

  final List<Map<String, dynamic>> fourLegsGroup = [];
  final List<Map<String, dynamic>> twoLegsGroup = [];
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

  void _handleDrag(Map<String, dynamic> item, bool isFourLegs) {
    setState(() {
      isCorrect = item['isFourLegs'] == isFourLegs;
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    if (isCorrect) {
      setState(() {
        if (!item['isPlaced']) {
          if (isFourLegs) {
            fourLegsGroup.add(item);
          } else {
            twoLegsGroup.add(item);
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
    if (fourLegsGroup.length + twoLegsGroup.length == items.length) {
      bool isCorrect = true;
      for (var item in fourLegsGroup) {
        if (!item['isFourLegs']) {
          isCorrect = false;
          break;
        }
      }
      for (var item in twoLegsGroup) {
        if (item['isFourLegs']) {
          isCorrect = false;
          break;
        }
      }

      if (isCorrect && !_dialogShown) {
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
                                ? 'You have completed stage 5!'
                                : '5. aşamayı tamamladınız!',
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
                              Navigator.push(
                                context,
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
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: Text(
          isEnglish
              ? 'Classify Animals by Legs'
              : 'Hayvanları Bacaklarına Göre Sınıfla',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
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
                        ? 'Drag the animals to the correct group!'
                        : 'Hayvanları doğru gruba sürükle!',
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
                          isEnglish ? 'Four Legs' : 'Dört Bacaklı',
                          fourLegsGroup,
                          true,
                          Colors.green.shade100,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGroup(
                          isEnglish ? 'Two Legs' : 'İki Bacaklı',
                          twoLegsGroup,
                          false,
                          Colors.blue.shade100,
                          Colors.blue,
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
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      if (!item['isPlaced']) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Draggable<Map<String, dynamic>>(
                            data: item,
                            feedback: Text(
                              item['emoji'],
                              style: const TextStyle(fontSize: 48),
                            ),
                            childWhenDragging: const SizedBox(
                              width: 60,
                              height: 60,
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

  Widget _buildGroup(
    String title,
    List<Map<String, dynamic>> group,
    bool isFourLegs,
    Color bgColor,
    Color textColor,
  ) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (data) => _handleDrag(data.data, isFourLegs),
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: group.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        group[index]['emoji'],
                        style: const TextStyle(fontSize: 48),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
