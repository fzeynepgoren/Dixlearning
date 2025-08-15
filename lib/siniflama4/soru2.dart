import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
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
    // Burun
    {'emoji': '🌸', 'id': 'cicek', 'organ': 'burun', 'isPlaced': false},
    {'emoji': '🧴', 'id': 'parfum', 'organ': 'burun', 'isPlaced': false},
    // Kulak
    {'emoji': '🎧', 'id': 'kulaklik', 'organ': 'kulak', 'isPlaced': false},
    {'emoji': '🎵', 'id': 'muzik', 'organ': 'kulak', 'isPlaced': false},
    // Dil
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

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    items.shuffle(); // küçük bir çeşitlilik
  }

  @override
  void dispose() {
    _feedbackController.dispose();
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

      // Etkinlik tamamlandı
      ActivityTracker.completeActivity();

      Future.delayed(const Duration(milliseconds: 500), () {
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
                // Üst geri butonu (TasitSinifla ile aynı)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: iconSize,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                // Kart gövde
                Expanded(
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
                        // Başlık (aynı stil)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 1,
                          ),
                          child: Text(
                            isEnglish
                                ? 'Drag to the correct organ!'
                                : 'Nesneleri doğru duyuya sürükle!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 15),
                        // İçerik: Sol grup kolonları + Sağ draggable liste
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sol: 3 grup kutusu (dikey), TasitSinifla ile aynı hiyerarşi
                              Expanded(
                                flex: 3,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildGroup(
                                      isEnglish ? 'Nose' : 'Burun',
                                      organGroups['burun']!,
                                      'burun',
                                      Colors.green.shade50,
                                      Colors.green,
                                    ),
                                    _buildGroup(
                                      isEnglish ? 'Ear' : 'Kulak',
                                      organGroups['kulak']!,
                                      'kulak',
                                      Colors.blue.shade50,
                                      Colors.lightBlue,
                                    ),
                                    _buildGroup(
                                      isEnglish ? 'Tongue' : 'Dil',
                                      organGroups['dil']!,
                                      'dil',
                                      Colors.purple.shade50,
                                      Colors.deepPurpleAccent,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Sağ: Yerleştirilmemiş öğeler listesi
                              Expanded(
                                flex: 2,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:
                                        items
                                            .where((item) => !item['isPlaced'])
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
                // Alt geri bildirim alanı (aynı animasyon ve ölçüler)
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
    String organType,
    Color boxColor,
    Color borderColor,
  ) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => _handleDrag(details.data, organType),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: double.infinity,
          height: 145,
          margin: const EdgeInsets.symmetric(vertical: 7),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: boxColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 4,
                children:
                    group
                        .map(
                          (item) => Text(
                            item['emoji'],
                            style: const TextStyle(
                              fontSize: 32,
                              color: Color(0xFF999999),
                            ),
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

  Widget _buildDraggableItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: 64,
      height: 64,
      child: Center(
        child: Text(
          item['emoji'],
          style: const TextStyle(fontSize: 32, color: Colors.black),
        ),
      ),
    );
  }
}
