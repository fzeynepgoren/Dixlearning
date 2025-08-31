import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../screens/home_screen.dart';

class OlaySinifla extends StatefulWidget {
  const OlaySinifla({super.key});

  @override
  State<OlaySinifla> createState() => _OlaySiniflaState();
}

class _OlaySiniflaState extends State<OlaySinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> sentenceItems = [
    {
      'text': 'Ali, sabah kahvaltı yapmadı.',
      'type': 'cause',
      'isPlaced': false,
      'placedType': null
    },
    {
      'text': 'Derste kendini yorgun hissetti.',
      'type': 'effect',
      'isPlaced': false,
      'placedType': null
    },
    {
      'text': 'Teneffüs olunca tost yedi.',
      'type': 'solution',
      'isPlaced': false,
      'placedType': null
    },
  ];

  final List<Map<String, dynamic>> draggableItems = [
    {'text': 'Sebep', 'type': 'cause', 'isPlaced': false},
    {'text': 'Sonuç', 'type': 'effect', 'isPlaced': false},
    {'text': 'Çözüm', 'type': 'solution', 'isPlaced': false},
  ];

  bool showFeedback = false;
  bool isCorrect = false;
  bool _dialogShown = false;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    sentenceItems.shuffle();
    draggableItems.shuffle();
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

  void _handleDrag(Map<String, dynamic> droppedItem, String targetType) {
    setState(() {
      isCorrect = droppedItem['type'] == targetType;
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    if (isCorrect) {
      setState(() {
        for (var item in sentenceItems) {
          if (item['type'] == targetType) {
            item['isPlaced'] = true;
            item['placedType'] = droppedItem['text'];
            break;
          }
        }
        for (var item in draggableItems) {
          if (item['type'] == droppedItem['type']) {
            item['isPlaced'] = true;
            break;
          }
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
    final allPlaced = sentenceItems.every((item) => item['isPlaced']);
    if (allPlaced && !_dialogShown) {
      _dialogShown = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
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
                      Provider.of<LanguageProvider>(context, listen: false)
                          .isEnglish
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
                      Provider.of<LanguageProvider>(context, listen: false)
                          .isEnglish
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
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        Provider.of<LanguageProvider>(context, listen: false)
                            .isEnglish
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
    final horizontalPadding = screenSize.width * 0.05;
    final verticalPadding = screenSize.height * 0.02;

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
                      padding: EdgeInsets.all(screenSize.width * 0.025),
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
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: verticalPadding * 0.5,
                            ),
                            child: Text(
                              isEnglish
                                  ? 'Drag and drop the categories to the sentences!'
                                  : 'Kategorileri cümlelerin üzerine sürükle!',
                              style: TextStyle(
                                fontSize: screenSize.width * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.02),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: sentenceItems.map((item) {
                                      return _buildSentenceGroup(item);
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(width: screenSize.width * 0.04),
                                Expanded(
                                  flex: 2,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: draggableItems
                                          .where((item) => !item['isPlaced'])
                                          .map((item) {
                                        return Draggable<Map<String, dynamic>>(
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
                                        );
                                      }).toList(),
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
                  height: screenSize.height * 0.1,
                  padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding, vertical: verticalPadding),
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
                          size: screenSize.width * 0.07,
                        ),
                        SizedBox(width: screenSize.width * 0.025),
                        Text(
                          isCorrect
                              ? (isEnglish ? 'Well done! 🎉' : 'Aferin! 🎉')
                              : (isEnglish
                              ? 'Try again! 😔'
                              : 'Tekrar dene! 😔'),
                          style: TextStyle(
                            fontSize: screenSize.width * 0.045,
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

  Widget _buildSentenceGroup(Map<String, dynamic> item) {
    final screenSize = MediaQuery.of(context).size;

    final Color itemColor;
    final Color borderColor;
    switch (item['type']) {
      case 'cause':
        itemColor = Colors.blue.shade100;
        borderColor = Colors.blue.shade400;
        break;
      case 'effect':
        itemColor = Colors.green.shade100;
        borderColor = Colors.green.shade400;
        break;
      case 'solution':
        itemColor = Colors.orange.shade100;
        borderColor = Colors.orange.shade400;
        break;
      default:
        itemColor = Colors.grey.shade100;
        borderColor = Colors.grey.shade400;
        break;
    }

    // Ortak boyutları belirle
    final double boxWidth = screenSize.width * 0.28; // Örnek boyut
    final double boxHeight = screenSize.height * 0.045; // Örnek boyut

    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => !item['isPlaced'],
      onAccept: (data) => _handleDrag(data, item['type']),
      builder: (context, candidateItems, rejectedItems) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
          padding: EdgeInsets.all(screenSize.width * 0.03),
          decoration: BoxDecoration(
            color: itemColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['text'],
                style: TextStyle(
                  fontSize: screenSize.width * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenSize.height * 0.01),
              Container(
                width: boxWidth,
                height: boxHeight,
                padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.02,
                    vertical: screenSize.height * 0.005),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30), // Oval şekil için daha yüksek radius
                ),
                child: Center(
                  child: Text(
                    item['isPlaced'] ? item['placedType'] : '',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.04,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
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
    final screenSize = MediaQuery.of(context).size;
    final double boxWidth = screenSize.width * 0.28;
    final double boxHeight = screenSize.height * 0.045;

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.015),
      padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.02,
          vertical: screenSize.height * 0.001),
      width: boxWidth,
      height: boxHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          item['text'],
          style: TextStyle(
            fontSize: screenSize.width * 0.04,
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}