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
  final List<Map<String, dynamic>> items = [
    {
      'text': 'Ali, sabah kahvaltı yapmadı.',
      'id': 'sebep',
      'type': 'cause',
      'isPlaced': false,
      'isWrong': false
    },
    {
      'text': 'Derste kendini yorgun hissetti.',
      'id': 'sonuc',
      'type': 'effect',
      'isPlaced': false,
      'isWrong': false
    },
    {
      'text': 'Teneffüs olunca tost yedi.',
      'id': 'cozum',
      'type': 'solution',
      'isPlaced': false,
      'isWrong': false
    },
  ];

  final List<Map<String, dynamic>> causeGroup = [];
  final List<Map<String, dynamic>> effectGroup = [];
  final List<Map<String, dynamic>> solutionGroup = [];
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
    items.shuffle();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Color _getItemColor(Map<String, dynamic> item) {
    if (item['isWrong'] == true) {
      return Colors.red.shade100;
    }
    if (!item['isPlaced']) {
      return Colors.blue.shade100;
    }
    return Colors.green.shade100;
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
          switch (type) {
            case 'cause':
              causeGroup.add(item);
              break;
            case 'effect':
              effectGroup.add(item);
              break;
            case 'solution':
              solutionGroup.add(item);
              break;
          }
          item['isPlaced'] = true;
        }
      });

      _checkCompletion();
    } else {
      setState(() {
        item['isPlaced'] = false;
        item['isWrong'] = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            item['isWrong'] = false;
          });
        }
      });
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
    if (causeGroup.length + effectGroup.length + solutionGroup.length ==
        items.length) {
      bool isCorrect = true;
      for (var item in causeGroup) {
        if (item['type'] != 'cause') {
          isCorrect = false;
          break;
        }
      }
      for (var item in effectGroup) {
        if (item['type'] != 'effect') {
          isCorrect = false;
          break;
        }
      }
      for (var item in solutionGroup) {
        if (item['type'] != 'solution') {
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
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Classify Events' : 'Olayları Sınıfla',
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
                        ? 'Drag the sentences to their correct categories!'
                        : 'Cümleleri doğru kategorilere sürükle!',
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
                        child: DragTarget<Map<String, dynamic>>(
                          builder: (context, candidateItems, rejectedItems) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
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
                                      color: Colors.blue.shade200,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      isEnglish ? 'Cause' : 'Sebep',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: causeGroup.map((item) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            item['text'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.blue,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onWillAcceptWithDetails: (details) => true,
                          onAcceptWithDetails: (details) =>
                              _handleDrag(details.data, 'cause'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DragTarget<Map<String, dynamic>>(
                          builder: (context, candidateItems, rejectedItems) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
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
                                      color: Colors.green.shade200,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      isEnglish ? 'Effect' : 'Sonuç',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: effectGroup.map((item) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            item['text'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.green,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onWillAcceptWithDetails: (item) => true,
                          onAcceptWithDetails: (item) =>
                              _handleDrag(item.data, 'effect'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DragTarget<Map<String, dynamic>>(
                          builder: (context, candidateItems, rejectedItems) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
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
                                      color: Colors.orange.shade200,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      isEnglish ? 'Solution' : 'Çözüm',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: solutionGroup.map((item) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            item['text'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.orange,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onWillAcceptWithDetails: (item) => true,
                          onAcceptWithDetails: (item) =>
                              _handleDrag(item.data, 'solution'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  height: 200,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                    items.where((item) => !item['isPlaced']).map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Draggable<Map<String, dynamic>>(
                          data: item,
                          feedback: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              item['text'],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          childWhenDragging: const SizedBox(
                            width: 200,
                            height: 40,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: item['isWrong']
                                  ? Colors.red.shade100
                                  : _getItemColor(item),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              item['text'],
                              style: TextStyle(
                                fontSize: 18,
                                color: item['isWrong']
                                    ? Colors.red.shade800
                                    : Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
}