import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'soru4.dart';

class DuyuOrganlariSinifla extends StatefulWidget {
  const DuyuOrganlariSinifla({super.key});

  @override
  State<DuyuOrganlariSinifla> createState() => _DuyuOrganlariSiniflaState();
}

class _DuyuOrganlariSiniflaState extends State<DuyuOrganlariSinifla>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {'emoji': '🌸', 'id': 'cicek', 'organ': 'burun', 'isPlaced': false},
    {'emoji': '🧴', 'id': 'parfum', 'organ': 'burun', 'isPlaced': false},
    {'emoji': '🎧', 'id': 'kulaklik', 'organ': 'kulak', 'isPlaced': false},
    {'emoji': '🎵', 'id': 'muzik', 'organ': 'kulak', 'isPlaced': false},
    {'emoji': '🍫', 'id': 'cikolata', 'organ': 'dil', 'isPlaced': false},
    {'emoji': '🍭', 'id': 'seker', 'organ': 'dil', 'isPlaced': false},
  ];

  final Map<String, List<Map<String, dynamic>>> organGroups = {
    'burun': [],
    'kulak': [],
    'dil': [],
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
            MaterialPageRoute(builder: (context) => const AtikSinifla()),
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
                                  ? 'Drag the items to the correct group!'
                                  : 'Nesneleri doğru duyuya sürükle!',
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
                                      _buildGroupContainer(
                                        isEnglish ? 'Nose' : 'Burun',
                                        organGroups['burun']!,
                                        'burun',
                                        Colors.green.shade100,
                                        Colors.green.shade400,
                                      ),
                                      _buildGroupContainer(
                                        isEnglish ? 'Ear' : 'Kulak',
                                        organGroups['kulak']!,
                                        'kulak',
                                        Colors.blue.shade100,
                                        Colors.blue.shade400,
                                      ),
                                      _buildGroupContainer(
                                        isEnglish ? 'Tongue' : 'Dil',
                                        organGroups['dil']!,
                                        'dil',
                                        Colors.purple.shade100,
                                        Colors.purple.shade400,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: screenSize.width * 0.04),
                                Expanded(
                                  flex: 2,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: items.map((item) {
                                        return Draggable<Map<String, dynamic>>(
                                          data: item,
                                          feedback: Material(
                                            color: Colors.transparent,
                                            child: _buildItemBox(item),
                                          ),
                                          childWhenDragging: Opacity(
                                            opacity: 0.5,
                                            child: _buildItemBox(item),
                                          ),
                                          child: item['isPlaced']
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
                  height: screenSize.height * 0.1,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
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
                          size: screenSize.width * 0.07,
                        ),
                        SizedBox(width: screenSize.width * 0.025),
                        Text(
                          isCorrect
                              ? (isEnglish ? 'Well done! 🎉' : 'Aferin! 🎉')
                              : (isEnglish ? 'Try again! 😔' : 'Tekrar dene! 😔'),
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

  Widget _buildGroupContainer(
      String title,
      List<Map<String, dynamic>> group,
      String organType,
      Color boxColor,
      Color borderColor) {
    final screenSize = MediaQuery.of(context).size;
    final emojiSize = screenSize.width * 0.12;

    return Expanded(
      child: DragTarget<Map<String, dynamic>>(
        onWillAccept: (data) => !data!['isPlaced'],
        onAccept: (data) => _handleDrag(data, organType),
        builder: (context, candidateData, rejectedData) {
          return Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.01, horizontal: screenSize.width * 0.04),
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
                  children: group
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
      margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.003),
      width: itemSize,
      height: itemSize,
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
          item['emoji'],
          style: TextStyle(fontSize: emojiSize),
        ),
      ),
    );
  }
}