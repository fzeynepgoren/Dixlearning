import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'soru2.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../screens/home_screen.dart';

class DuyguSiniflama extends StatefulWidget {
  const DuyguSiniflama({super.key});

  @override
  State<DuyguSiniflama> createState() => _DuyguSiniflamaState();
}

class _DuyguSiniflamaState extends State<DuyguSiniflama>
    with TickerProviderStateMixin {
  final Map<String, String> dogruEslesmeler = {
    '😊': 'Mutlu',
    '😂': 'Mutlu',
    '😢': 'Üzgün',
    '😞': 'Üzgün',
    '😠': 'Kızgın',
    '😤': 'Kızgın',
  };

  late List<String> yuzler;
  late List<String> shuffledYuzler;
  final List<String> kategoriler = ['Mutlu', 'Üzgün', 'Kızgın'];

  Set<String> eslesenler = {};
  Map<String, Color?> kategoriRenkleri = {};

  String feedbackText = 'Sürükle bırak ile eşleştir!';
  Color feedbackColor = Colors.yellow.shade800;
  IconData feedbackIcon = Icons.lightbulb_outline;
  bool showFeedback = false;

  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    yuzler = dogruEslesmeler.keys.toList();
    kategoriler.shuffle(Random());
    shuffledYuzler = List<String>.from(yuzler);
    shuffledYuzler.shuffle(Random());

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

  void gosterGeriBildirim(String mesaj, Color renk, IconData ikon) {
    setState(() {
      feedbackText = mesaj;
      feedbackColor = renk;
      feedbackIcon = ikon;
      showFeedback = true;
    });

    _feedbackController.forward(from: 0).then((_) {
      if (eslesenler.length == dogruEslesmeler.length) {
        kontrolVeIlerle(context);
      }
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && eslesenler.length != dogruEslesmeler.length) {
          setState(() {
            feedbackText = 'Sürükle bırak ile eşleştir!';
            feedbackColor = Colors.yellow.shade800;
            feedbackIcon = Icons.lightbulb_outline;
            showFeedback = false;
          });
        }
      });
    });
  }

  void kontrolVeIlerle(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DuyuOrganlariSinifla()),
        );
      }
    });
  }

  void kutuyuRenklendir(String kategori, Color renk) {
    setState(() {
      kategoriRenkleri[kategori] = renk;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          kategoriRenkleri[kategori] = null;
        });
      }
    });
  }

  void eslesmeYapildi(String data, String kategori) {
    if (dogruEslesmeler[data] == kategori) {
      setState(() {
        eslesenler.add(data);
      });
      gosterGeriBildirim(
        'Aferin! 🎉',
        Colors.green,
        Icons.check_circle,
      );
      kutuyuRenklendir(kategori, Colors.green.shade200);
    } else {
      gosterGeriBildirim(
        'Tekrar dene! 😔',
        Colors.red,
        Icons.cancel,
      );
      kutuyuRenklendir(kategori, Colors.red.shade200);
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
                                  ? 'Drag and drop the faces to the correct box.'
                                  : 'Yüz ifadelerini duygularına göre uygun kutuya sürükle!',
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
                                  flex: 3,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: kategoriler.map((kategori) {
                                      const Color renk = Color(0xFFE0F7FA);
                                      const Color border = Colors.black;

                                      Color? dynamicBoxColor = kategoriRenkleri[kategori] ?? renk;

                                      final eslesenYuzler = eslesenler
                                          .where((e) => dogruEslesmeler[e] == kategori)
                                          .toList();

                                      return Expanded(
                                        child: DragTarget<String>(
                                          builder: (context, _, __) {
                                            return Container(
                                              width: double.infinity,
                                              margin: const EdgeInsets.symmetric(vertical: 6),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: dynamicBoxColor,
                                                border: Border.all(color: border, width: 1.5),
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    kategori,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: eslesenYuzler
                                                        .map((e) => _buildYuz(e, small: true))
                                                        .toList(),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          onWillAccept: (data) => data != null && !eslesenler.contains(data),
                                          onAccept: (data) {
                                            eslesmeYapildi(data, kategori);
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: shuffledYuzler.map((id) {
                                      bool eslesti = eslesenler.contains(id);
                                      return eslesti
                                          ? Container() // Eşleşen emojiyi gizle
                                          : Draggable<String>(
                                        data: id,
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: SizedBox(
                                            width: 76,
                                            height: 76,
                                            child: _buildYuz(id, small: false),
                                          ),
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: 0.3,
                                          child: _buildYuz(id, small: false),
                                        ),
                                        child: SizedBox(
                                          width: 76,
                                          height: 76,
                                          child: _buildYuz(id, small: false),
                                        ),
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
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            feedbackIcon,
                            color: feedbackColor,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            feedbackText,
                            style: TextStyle(
                              fontSize: 18,
                              color: feedbackColor,
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

  Widget _buildYuz(String emoji,
      {bool small = false, bool isMatched = false}) {
    double size = small ? 52 : 76;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            emoji,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size * 0.9,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
