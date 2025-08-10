import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'soru5.dart';
import '../screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yapı-Nesne Eşleştirme',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const YapiNesneEsle(),
    );
  }
}

class YapiNesneEsle extends StatefulWidget {
  const YapiNesneEsle({super.key});

  @override
  State<YapiNesneEsle> createState() => _YapiNesneEsleState();
}

class _YapiNesneEsleState extends State<YapiNesneEsle>
    with TickerProviderStateMixin {
  final List<String> leftBuildings = ['🏛️', '🏥', '🏫'];
  final List<String> rightItems = ['Tarihi eser', 'İlaç', 'Kitap'];
  final List<String> rightItemsEnglish = [
    'Historical artifact',
    'Medicine',
    'Book'
  ];
  late List<String> shuffledItems;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = [false, false, false];
  List<bool> matchedRight = [false, false, false];
  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    final isEnglish =
        Provider.of<LanguageProvider>(context, listen: false).isEnglish;
    shuffledItems = List.from(isEnglish ? rightItemsEnglish : rightItems)
      ..shuffle();
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

  void _handleTap(int index, bool isLeft) {
    setState(() {
      if (isLeft) {
        if (matchedLeft[index]) return;
        selectedLeftIndex = index;
      } else {
        if (matchedRight[index]) return;
        selectedRightIndex = index;
      }

      if (selectedLeftIndex != null && selectedRightIndex != null) {
        final isEnglish =
            Provider.of<LanguageProvider>(context, listen: false).isEnglish;
        final rightItemsList = isEnglish ? rightItemsEnglish : rightItems;
        // Check if the building matches with the correct item
        isCorrect = (leftBuildings[selectedLeftIndex!] == '🏛️' &&
                shuffledItems[selectedRightIndex!] == rightItemsList[0]) ||
            (leftBuildings[selectedLeftIndex!] == '🏥' &&
                shuffledItems[selectedRightIndex!] == rightItemsList[1]) ||
            (leftBuildings[selectedLeftIndex!] == '🏫' &&
                shuffledItems[selectedRightIndex!] == rightItemsList[2]);

        showFeedback = true;
        _feedbackController.forward(from: 0);

        if (isCorrect) {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;

          bool allMatched = matchedLeft.every((e) => e);
          if (allMatched && !_dialogShown) {
            _dialogShown = true;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                // Etkinlik tamamlandı

                ActivityTracker.completeActivity();

                

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RenkNesneEsle()),
                );
              }
            });
          }
        }

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              showFeedback = false;
              selectedLeftIndex = null;
              selectedRightIndex = null;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    bool allMatched = matchedLeft.every((e) => e);
    if (allMatched && !_dialogShown) {
      _dialogShown = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // Etkinlik tamamlandı

          ActivityTracker.completeActivity();

          

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RenkNesneEsle()),
          );
        }
      });
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE1F5FE),
        appBar: AppBar(
          title: Text(
              isEnglish ? 'Structure-Object Matching' : 'Yapı-Nesne Eşleştirme',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    isEnglish
                        ? 'Match the structures with their appropriate objects.'
                        : 'Resimdeki yapıları uygun nesne ile eşleştir.',
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              leftBuildings.length,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: GestureDetector(
                                  onTap: () => _handleTap(index, true),
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: matchedLeft[index]
                                          ? Colors.green.shade300
                                          : (showFeedback &&
                                                  !isCorrect &&
                                                  selectedLeftIndex == index)
                                              ? Colors.red.shade200
                                              : selectedLeftIndex == index
                                                  ? Colors.blue.shade200
                                                  : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        leftBuildings[index],
                                        style: const TextStyle(fontSize: 42),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              shuffledItems.length,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: GestureDetector(
                                  onTap: () => _handleTap(index, false),
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: matchedRight[index]
                                          ? Colors.green.shade300
                                          : (showFeedback &&
                                                  !isCorrect &&
                                                  selectedRightIndex == index)
                                              ? Colors.red.shade200
                                              : selectedRightIndex == index
                                                  ? Colors.blue.shade200
                                                  : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        shuffledItems[index],
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isCorrect
                                  ? 'Aferin! 🎉'
                                  : 'Üzgünüm, yanlış eşleştirme! 😔',
                              style: TextStyle(
                                fontSize: 17,
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
      ),
    );
  }
}
