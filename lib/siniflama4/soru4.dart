import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'soru5.dart';
import '../screens/siniflandirma_sorulari_screen.dart';

class AtikSinifla extends StatefulWidget {
  const AtikSinifla({super.key});

  @override
  State<AtikSinifla> createState() => _AtikSiniflaState();
}

class _AtikSiniflaState extends State<AtikSinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {'emoji': '📰', 'id': 'gazete', 'type': 'kagit', 'isPlaced': false},
    {'emoji': '🗞️', 'id': 'burusuk_kagit', 'type': 'kagit', 'isPlaced': false},
    {'emoji': '🥤', 'id': 'pet_sise', 'type': 'plastik', 'isPlaced': false},
    {
      'emoji': '🧃',
      'id': 'plastik_bardak',
      'type': 'plastik',
      'isPlaced': false,
    },
    {'emoji': '🍾', 'id': 'cam_sise', 'type': 'cam', 'isPlaced': false},
    {'emoji': '🥛', 'id': 'cam_bardak', 'type': 'cam', 'isPlaced': false},
  ];

  final List<Map<String, dynamic>> paperGroup = [];
  final List<Map<String, dynamic>> plasticGroup = [];
  final List<Map<String, dynamic>> glassGroup = [];
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

  void _handleDrag(Map<String, dynamic> item, String type) {
    setState(() {
      isCorrect = item['type'] == type;
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);

    if (isCorrect) {
      setState(() {
        if (!item['isPlaced']) {
          if (type == 'kagit') {
            paperGroup.add(item);
          } else if (type == 'plastik') {
            plasticGroup.add(item);
          } else if (type == 'cam') {
            glassGroup.add(item);
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
    if (paperGroup.length + plasticGroup.length + glassGroup.length ==
        items.length) {
      bool isCorrect = true;
      for (var item in paperGroup) {
        if (item['type'] != 'kagit') {
          isCorrect = false;
          break;
        }
      }
      for (var item in plasticGroup) {
        if (item['type'] != 'plastik') {
          isCorrect = false;
          break;
        }
      }
      for (var item in glassGroup) {
        if (item['type'] != 'cam') {
          isCorrect = false;
          break;
        }
      }
      if (isCorrect && !_dialogShown) {
        _dialogShown = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const OlaySinifla()),
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
                                  ? 'Drag the waste to the correct bin!'
                                  : 'Atıkları doğru kutuya sürükle!',
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      _buildGroup(
                                        isEnglish
                                            ? 'Paper Bin'
                                            : 'Kağıt Kutusu',
                                        paperGroup,
                                        'kagit',
                                        Colors.purple.shade100,
                                        Colors.purple.shade300,
                                      ),
                                      _buildGroup(
                                        isEnglish
                                            ? 'Plastic Bin'
                                            : 'Plastik Kutusu',
                                        plasticGroup,
                                        'plastik',
                                        Colors.blue.shade100,
                                        Colors.blue.shade400,
                                      ),
                                      _buildGroup(
                                        isEnglish ? 'Glass Bin' : 'Cam Kutusu',
                                        glassGroup,
                                        'cam',
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
                                          items
                                              .where(
                                                (item) => !item['isPlaced'],
                                              )
                                              .map((item) {
                                                return Draggable<
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
                                                );
                                              })
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
    String title,
    List<Map<String, dynamic>> group,
    String type,
    Color boxColor,
    Color borderColor,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final titleSize = screenSize.width * 0.05;
    final emojiSize = screenSize.width * 0.1;

    return Expanded(
      child: DragTarget<Map<String, dynamic>>(
        onWillAcceptWithDetails: (details) => !details.data['isPlaced'],
        onAcceptWithDetails: (details) => _handleDrag(details.data, type),
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
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenSize.height * 0.01),
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

  Widget _buildDraggableItem(Map<String, dynamic> item) {
    final screenSize = MediaQuery.of(context).size;
    final itemSize = screenSize.width * 0.2;
    final emojiSize = screenSize.width * 0.1;

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.003),
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
