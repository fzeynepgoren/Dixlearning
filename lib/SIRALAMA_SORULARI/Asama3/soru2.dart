import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import 'package:dixlearning/SIRALAMA_SORULARI/Asama3/soru3.dart';

class Asama3Soru2 extends StatefulWidget {
  const Asama3Soru2({super.key});

  @override
  State<Asama3Soru2> createState() => _Asama3Soru2State();
}

class _PlantStage {
  final String label;
  final String assetPath;
  _PlantStage(this.label, this.assetPath);
}

class _Asama3Soru2State extends State<Asama3Soru2>
    with TickerProviderStateMixin {
  late List<_PlantStage> stages;
  late List<_PlantStage> dragSources;
  late List<_PlantStage?> dropTargets;
  bool showFeedback = false;
  bool isCorrect = false;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    stages = [
      _PlantStage(
          'Yumurta', 'assets/SIRALAMA_RESIMLERI/Asama3/soru2/yumurta.png'),
      _PlantStage('Yumurta ve Civciv',
          'assets/SIRALAMA_RESIMLERI/Asama3/soru2/yumurta_civciv.png'),
      _PlantStage(
          'Civciv', 'assets/SIRALAMA_RESIMLERI/Asama3/soru2/civciv.png'),
      _PlantStage('Tavuk', 'assets/SIRALAMA_RESIMLERI/Asama3/soru2/tavuk.png'),
    ];
    dragSources = List.from(stages)..shuffle();
    dropTargets = List<_PlantStage?>.filled(stages.length, null);
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void checkOrder() {
    setState(() {
      isCorrect = true;
      for (int i = 0; i < stages.length; i++) {
        if (dragSources[i].label != stages[i].label) {
          isCorrect = false;
          break;
        }
      }
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);
    if (isCorrect) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const Asama3Soru3(),
            ),
          );
        }
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            showFeedback = false;
          });
        }
      });
    }
  }

  void removeFromDropTargets(_PlantStage stage) {
    setState(() {
      for (int i = 0; i < dropTargets.length; i++) {
        if (dropTargets[i]?.label == stage.label) {
          dropTargets[i] = null;
          dragSources.add(stage);
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final imageSize = MediaQuery.of(context).size.width * 0.3;
    final dropSize = screenWidth * 0.28;
    final gap = screenWidth * 0.04;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey,
                Colors.grey,
                Color(0xffffffff),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Üst kısım - Geri butonu ve Aşama yazısı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.black, size: 28),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const Asama3Soru3()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
                // Sıralama Alanı Kartı (Başlık ve buton da içinde)
                Expanded(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.97),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Başlık
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              isEnglish
                                  ? 'Sort the chicken stages in the correct order.'
                                  : 'Tavuk nasıl büyür? Sırala.',
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // Sıralama Alanı
                          Expanded(
                            child: ReorderableListView(
                              onReorder: (oldIndex, newIndex) {
                                setState(() {
                                  if (newIndex > oldIndex) newIndex--;
                                  final item = dragSources.removeAt(oldIndex);
                                  dragSources.insert(newIndex, item);
                                });
                              },
                              buildDefaultDragHandles: false,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              children: [
                                for (int i = 0; i < dragSources.length; i++)
                                  AnimatedContainer(
                                    key: ValueKey(dragSources[i].label),
                                    duration: const Duration(milliseconds: 200),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 12,
                                          offset: Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 20),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Image.asset(
                                              dragSources[i].assetPath,
                                              width: imageSize,
                                              height: imageSize,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const Spacer(),
                                          ReorderableDragStartListener(
                                            index: i,
                                            child: const Icon(Icons.drag_handle,
                                                color: Colors.grey, size: 32),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Kontrol Butonu
                          SizedBox(
                            width: double.infinity,
                            height: 35,
                            child: ElevatedButton(
                              onPressed: !showFeedback ? checkOrder : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF0C329),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 6,
                              ),
                              child: Text(
                                isEnglish ? 'Check' : 'Kontrol Et',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Geri Bildirim Alanı
                Container(
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: showFeedback
                      ? ScaleTransition(
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
}
