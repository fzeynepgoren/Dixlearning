import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'soru2.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/language_provider.dart';
import '../../screens/home_screen.dart';
import '../screens/siniflandirma_sorulari_screen.dart';
import '../../widgets/in_game_menu.dart';

class DuyguSiniflama extends StatefulWidget {
  const DuyguSiniflama({super.key});

  @override
  State<DuyguSiniflama> createState() => _DuyguSiniflamaState();
}

class _DuyguSiniflamaState extends State<DuyguSiniflama>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {'emoji': '😊', 'id': 'mutlu1', 'organ': 'Mutlu', 'isPlaced': false},
    {'emoji': '😂', 'id': 'mutlu2', 'organ': 'Mutlu', 'isPlaced': false},
    {'emoji': '😢', 'id': 'uzgun1', 'organ': 'Üzgün', 'isPlaced': false},
    {'emoji': '😞', 'id': 'uzgun2', 'organ': 'Üzgün', 'isPlaced': false},
    {'emoji': '😠', 'id': 'kizgin1', 'organ': 'Kızgın', 'isPlaced': false},
    {'emoji': '😤', 'id': 'kizgin2', 'organ': 'Kızgın', 'isPlaced': false},
  ];

  final Map<String, List<Map<String, dynamic>>> organGroups = {
    'Mutlu': [],
    'Üzgün': [],
    'Kızgın': [],
  };

  bool showFeedback = false;
  bool isCorrect = false;
  bool _dialogShown = false;
  bool _isSoundOn = true;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _wrongCountReset = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_wrongCountReset) {
      _resetWrongCountSync();
      _wrongCountReset = true;
    }
  }

  void _resetWrongCountSync() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('siniflama4_wrong_count', 0);
    });
  }

  @override
  void initState() {
    super.initState();
    items.shuffle(Random());
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

  Future<void> _trackWrongAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    int wrongCount = prefs.getInt('siniflama4_wrong_count') ?? 0;
    wrongCount++;
    await prefs.setInt('siniflama4_wrong_count', wrongCount);
  }

  void _handleDrag(Map<String, dynamic> item, String organ) {
    setState(() {
      isCorrect = item['organ'] == organ;
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    if (isCorrect) {
      setState(() {
        if (!item['isPlaced']) {
          organGroups[organ]!.add(item);
          item['isPlaced'] = true;
        }
      });
      _checkCompletion();
    } else {
      // Yanlış eşleşme
      _trackWrongAnswer();
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
    final allPlaced = items.every((e) => e['isPlaced'] == true);
    if (allPlaced && !_dialogShown) {
      _dialogShown = true;

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DuyuOrganlariSinifla(),
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

    return Scaffold(
        body: Stack(
          children: [
            Container(
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
                    const SizedBox(height: 10),
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
                                      ? 'Drag and drop the faces to the correct box.'
                                      : 'Yüz ifadelerini duygularına göre uygun kutuya sürükle!',
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        children: [
                                          _buildGroupContainer(
                                            isEnglish ? 'Happy' : 'Mutlu',
                                            organGroups['Mutlu']!,
                                            'Mutlu',
                                            Colors.deepPurple.shade100,
                                            Colors.deepPurple.shade300,
                                          ),
                                          _buildGroupContainer(
                                            isEnglish ? 'Sad' : 'Üzgün',
                                            organGroups['Üzgün']!,
                                            'Üzgün',
                                            Colors.blue.shade100,
                                            Colors.blue.shade400,
                                          ),
                                          _buildGroupContainer(
                                            isEnglish ? 'Angry' : 'Kızgın',
                                            organGroups['Kızgın']!,
                                            'Kızgın',
                                            Colors.yellow.shade100,
                                            Colors.yellow.shade400,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: screenSize.width * 0.04),
                                    Expanded(
                                      flex: 2,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children:
                                              items.map((item) {
                                                return Draggable<
                                                  Map<String, dynamic>
                                                >(
                                                  data: item,
                                                  feedback: Material(
                                                    color: Colors.transparent,
                                                    child: _buildItemBox(item),
                                                  ),
                                                  childWhenDragging: Opacity(
                                                    opacity: 0.5,
                                                    child: _buildItemBox(item),
                                                  ),
                                                  child:
                                                      item['isPlaced']
                                                          ? const SizedBox.shrink()
                                                          : _buildItemBox(item),
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
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            InGameMenu(
              isSoundOn: _isSoundOn,
              onToggleSound: () => setState(() => _isSoundOn = !_isSoundOn),
              onHome: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const ClassificationQuestionsScreen(),
                  ),
                  (route) => false,
                );
              },
              onEntryScreen: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              iconSize: iconSize,
            ),
          ],
        ),
      );
  }

  Widget _buildGroupContainer(
    String title,
    List<Map<String, dynamic>> group,
    String organType,
    Color boxColor,
    Color borderColor,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final emojiSize = screenSize.width * 0.12;

    return Expanded(
      child: DragTarget<Map<String, dynamic>>(
        onWillAcceptWithDetails: (details) => !details.data['isPlaced'],
        onAcceptWithDetails: (details) => _handleDrag(details.data, organType),
        builder: (context, candidateData, rejectedData) {
          return Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
              vertical: screenSize.height * 0.01,
              horizontal: screenSize.width * 0.04,
            ),
            decoration: BoxDecoration(
              color: boxColor,
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.055,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: screenSize.width * 0.02,
                  children:
                      group
                          .map(
                            (item) => Text(
                              item['emoji'],
                              style: TextStyle(fontSize: emojiSize),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemBox(Map<String, dynamic> item) {
    final screenSize = MediaQuery.of(context).size;
    final itemSize = screenSize.width * 0.2;
    final emojiSize = screenSize.width * 0.1;

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.002),
      width: itemSize,
      height: itemSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Text(item['emoji'], style: TextStyle(fontSize: emojiSize)),
      ),
    );
  }
}
