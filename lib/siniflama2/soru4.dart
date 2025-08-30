import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'soru5.dart'; // Make sure this path is correct.

class TeknolojikSinifla extends StatefulWidget {
  const TeknolojikSinifla({super.key});

  @override
  State<TeknolojikSinifla> createState() => _TeknolojikSiniflaState();
}

class _TeknolojikSiniflaState extends State<TeknolojikSinifla>
    with TickerProviderStateMixin {
  final Map<String, String> dogruEslesmeler = {
    '📱': 'Teknolojik',
    '📚': 'Geleneksel',
    '🔳': 'Teknolojik',
    '✏️': 'Geleneksel',
  };

  late List<String> emojiler;
  final List<String> kategoriler = ['Teknolojik', 'Geleneksel'];

  Set<String> eslesenler = {};
  bool showFeedback = false;
  bool isCorrect = false;
  bool _dialogShown = false;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    emojileriKaristir();
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

  void emojileriKaristir() {
    final List<String> tumEmojiler = dogruEslesmeler.keys.toList();
    tumEmojiler.shuffle();
    emojiler = tumEmojiler;
  }

  void _handleDrag(String draggedEmoji, String targetCategory) {
    bool isCorrectMatch = dogruEslesmeler[draggedEmoji] == targetCategory;

    setState(() {
      isCorrect = isCorrectMatch;
      showFeedback = true;
    });

    _feedbackController.forward(from: 0);

    if (isCorrectMatch) {
      setState(() {
        if (!eslesenler.contains(draggedEmoji)) {
          eslesenler.add(draggedEmoji);
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
    if (eslesenler.length == emojiler.length) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && !_dialogShown) {
          _dialogShown = true;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ParaSinifla()),
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
                                    children: kategoriler
                                        .map(
                                          (kategori) => Expanded(
                                        child: _buildGroupContainer(
                                            kategori, isEnglish),
                                      ),
                                    )
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: emojiler
                                        .where((emoji) => !eslesenler.contains(emoji))
                                        .map((emoji) {
                                      return Draggable<String>(
                                        data: emoji,
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: _buildItemBox(emoji),
                                        ),
                                        childWhenDragging: const SizedBox.shrink(),
                                        child: _buildItemBox(emoji),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: showFeedback
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
                              ? (isEnglish ? 'Well done! 🎉' : 'Aferin! 🎉')
                              : (isEnglish ? 'Try again! 😔' : 'Tekrar dene! 😔'),
                          style: TextStyle(
                            fontSize: 18,
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

  Widget _buildGroupContainer(String kategori, bool isEnglish) {
    Color boxColor =
    kategori == 'Teknolojik' ? Colors.green.shade100 : const Color(0xFFE0F7FA);
    Color borderColor =
    kategori == 'Teknolojik' ? Colors.green.shade400 : Colors.blue.shade400;

    return DragTarget<String>(
      onWillAccept: (data) => !eslesenler.contains(data!),
      onAccept: (data) => _handleDrag(data!, kategori),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: double.infinity,
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
                isEnglish
                    ? (kategori == 'Teknolojik' ? 'Teknolojik' : 'Geleneksel')
                    : kategori,
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
                children: eslesenler
                    .where((e) => dogruEslesmeler[e] == kategori)
                    .map(
                      (e) => Text(
                    e,
                    style: const TextStyle(fontSize: 60),
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
}