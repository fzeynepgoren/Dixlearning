import 'package:flutter/material.dart';
import 'soru2.dart';
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
      title: 'Görsel-Eylem Eşleştirme',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ActivityMatching(),
    );
  }
}

class ActivityMatching extends StatefulWidget {
  const ActivityMatching({super.key});

  @override
  State<ActivityMatching> createState() => _ActivityMatchingState();
}

class _ActivityMatchingState extends State<ActivityMatching>
    with TickerProviderStateMixin {
  final List<Activity> leftActivities = [
    Activity(
        image: 'assets/asama3/soru1/block_tower.png',
        description: 'Bloklarla kule yapıyor'),
    Activity(
        image: 'assets/asama3/soru1/finger_painting.png',
        description: 'Parmak boyasıyla resim yapıyor'),
    Activity(
        image: 'assets/asama3/soru1/kicking_ball.png',
        description: 'Topa vuruyor'),
  ];

  late List<String> shuffledDescriptions;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> matchedLeft = [false, false, false];
  List<bool> matchedRight = [false, false, false];
  bool showFeedback = false;
  bool isCorrect = false;
  bool allMatched = false;
  String? wrongDescription;
  String? wrongLeftImage;

  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    shuffledDescriptions = List.from(
        leftActivities.map((e) => e.description).toList())
      ..shuffle();
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
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleTap(int index, bool isLeft) {
    if (allMatched) return;

    setState(() {
      if (isLeft) {
        if (matchedLeft[index]) return;
        selectedLeftIndex = index;
      } else {
        if (matchedRight[index]) return;
        selectedRightIndex = index;
      }

      if (selectedLeftIndex != null && selectedRightIndex != null) {
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    setState(() {
      isCorrect = leftActivities[selectedLeftIndex!].description ==
          shuffledDescriptions[selectedRightIndex!];
      showFeedback = true;
    });

    _feedbackController.forward(from: 0);

    if (isCorrect) {
      setState(() {
        matchedLeft[selectedLeftIndex!] = true;
        matchedRight[selectedRightIndex!] = true;
      });

      if (matchedLeft.every((element) => element)) {
        allMatched = true;
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HarfHayvanEsle()),
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

  Widget _buildLeftCard(int index) {
    final activity = leftActivities[index];
    final bool isSelected = selectedLeftIndex == index;
    final bool isMatched = matchedLeft[index];
    final bool isWrongSelection = showFeedback && !isCorrect && isSelected;

    Color cardColor = isMatched
        ? Colors.green.shade200
        : isWrongSelection
        ? Colors.red.shade200
        : Colors.white;

    return GestureDetector(
      onTap: isMatched ? null : () => _handleTap(index, true),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 120,
        height: 120,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isSelected && !isMatched ? Border.all(color: Colors.lightGreen.shade400, width: 4) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              activity.image,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightCard(int index) {
    final description = shuffledDescriptions[index];
    final bool isSelected = selectedRightIndex == index;
    final bool isMatched = matchedRight[index];
    final bool isWrongSelection = showFeedback && !isCorrect && isSelected;

    Color cardColor = isMatched
        ? Colors.green.shade200
        : isWrongSelection
        ? Colors.red.shade200
        : Colors.white;

    return GestureDetector(
      onTap: isMatched ? null : () => _handleTap(index, false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 120,
        height: 120,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isSelected && !isMatched ? Border.all(color: Colors.lightGreen.shade400, width: 4) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
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
                      icon: Icon(Icons.arrow_back, color: Colors.black, size: iconSize),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                              (route) => false,
                        );
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
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                            child: Text(
                              isEnglish
                                  ? 'Tap the picture and its matching description!'
                                  : 'Resme tıkla ve doğru açıklamayla eşleştir!',
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
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      leftActivities.length,
                                          (index) => _buildLeftCard(index),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      shuffledDescriptions.length,
                                          (index) => _buildRightCard(index),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: showFeedback
                      ? ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _feedbackController,
                      curve: Curves.elasticOut,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green : Colors.red,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isCorrect ? 'Aferin! 🎉' : 'Tekrar dene! 😔',
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
      ),
    );
  }
}

class Activity {
  final String image;
  final String description;

  Activity({required this.image, required this.description});
}
