import 'package:flutter/material.dart';
import 'soru2.dart';
import '../giris_etkinlikleri/intro_flow_controller.dart';
import '../../main.dart';
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

  final List<String> rightDescriptions = [
    'Bloklarla kule yapıyor',
    'Parmak boyasıyla resim yapıyor',
    'Topa vuruyor',
  ];

  late List<String> shuffledDescriptions;
  String? draggedDescription;
  Map<String, String> matches = {};
  bool showFeedback = false;
  bool isCorrect = false;
  bool _dialogShown = false;
  String? wrongDescription;
  String? wrongLeftDescription;

  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    shuffledDescriptions = List.from(rightDescriptions)..shuffle();
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

  void checkMatch(String imagePath, String description) {
    setState(() {
      final correctDescription =
          leftActivities.firstWhere((a) => a.image == imagePath).description;
      isCorrect = description == correctDescription;
      showFeedback = true;
      if (!isCorrect) {
        wrongDescription = description;
        wrongLeftDescription = correctDescription;
      }
    });

    _feedbackController.forward(from: 0);

    if (isCorrect) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            matches[imagePath] = description;
            showFeedback = false;
            wrongDescription = null;
            wrongLeftDescription = null;
            if (matches.length == leftActivities.length && !_dialogShown) {
              _dialogShown = true;
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HarfHayvanEsle()),
                  );
                }
              });
            }
          });
        }
      });
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            showFeedback = false;
            wrongDescription = null;
            wrongLeftDescription = null;
          });
        }
      });
    }
  }

  Widget buildLeftActivityContainer(Activity activity,
      {bool isMatched = false, bool isDragging = false}) {
    final bool isWrong = wrongLeftDescription == activity.description &&
        showFeedback &&
        !isCorrect;
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: isMatched
            ? Colors.green.shade300
            : isWrong
                ? Colors.red.shade200
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            activity.image,
            fit: BoxFit.contain, // Resimlerin orantılı şekilde sığması için
          ),
        ),
      ),
    );
  }

  Widget buildRightDescriptionContainer(String description,
      {bool isMatched = false, bool isTarget = false}) {
    final bool isWrong =
        wrongDescription == description && showFeedback && !isCorrect;
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: isMatched
            ? Colors.green.shade300
            : isWrong
                ? Colors.red.shade200
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: const Text('Görsel-Eylem Eşleştirme',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Resimdeki çocukların yaptığı etkinliği açıklamalara sürükle!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceEvenly, // Öğeler arası boşluk eklendi
                          children: [
                            ...leftActivities.map((activity) {
                              final isMatched =
                                  matches.containsKey(activity.image);
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Draggable<String>(
                                  data: activity.description,
                                  feedback: Material(
                                    elevation: 8,
                                    borderRadius: BorderRadius.circular(24),
                                    child: buildLeftActivityContainer(activity,
                                        isDragging: true),
                                  ),
                                  childWhenDragging: buildLeftActivityContainer(
                                    activity,
                                    isMatched: isMatched,
                                  ),
                                  child: buildLeftActivityContainer(
                                    activity,
                                    isMatched: isMatched,
                                  ),
                                ),
                              );
                            }),
                          ],
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
                          mainAxisAlignment: MainAxisAlignment
                              .spaceEvenly, // Öğeler arası boşluk eklendi
                          children: [
                            ...shuffledDescriptions.map((description) {
                              final isMatched =
                                  matches.containsValue(description);
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: DragTarget<String>(
                                  builder:
                                      (context, candidateData, rejectedData) {
                                    return buildRightDescriptionContainer(
                                      description,
                                      isMatched: isMatched,
                                      isTarget: candidateData.isNotEmpty,
                                    );
                                  },
                                  onWillAcceptWithDetails: (data) =>
                                      !isMatched &&
                                      !matches.containsValue(description),
                                  onAcceptWithDetails: (data) {
                                    final imagePath = leftActivities
                                        .firstWhere(
                                            (a) => a.description == data)
                                        .image;
                                    checkMatch(imagePath, description);
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (showFeedback)
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _feedbackController,
                      curve: Curves.elasticOut,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Activity {
  final String image;
  final String description;

  Activity({required this.image, required this.description});
}
