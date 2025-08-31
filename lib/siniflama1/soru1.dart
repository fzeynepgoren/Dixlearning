import 'package:flutter/material.dart';
import 'dart:math';
import 'soru2.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../screens/home_screen.dart';

class CinsiyetEsleme extends StatefulWidget {
  const CinsiyetEsleme({super.key});

  @override
  State<CinsiyetEsleme> createState() => _CinsiyetEslemeState();
}

class _CinsiyetEslemeState extends State<CinsiyetEsleme>
    with TickerProviderStateMixin {
  final Map<String, String> dogruEslesmeler = {
    '🧍‍♀️': 'Kız',
    '🚶‍♀️': 'Kız',
    '🧍‍♂️': 'Erkek',
    '🚶': 'Erkek',
  };

  late List<String> emojiler;
  final List<String> kategoriler = ['Kız', 'Erkek'];

  Set<String> eslesenler = {};
  bool showFeedback = false;
  String feedbackText = 'Sürükle bırak ile eşleştir!';
  Color feedbackColor = Colors.yellow.shade800;
  IconData feedbackIcon = Icons.lightbulb_outline;
  
  Map<String, Color> kategoriRenkleri = {};

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
    
    kategoriRenkleri = {
      'Kız': const Color(0xFFFFDDEE),
      'Erkek': const Color(0xFFD6ECFF),
    };
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void emojileriKaristir() {
    final List<String> tumEmojiler = dogruEslesmeler.keys.toList();
    tumEmojiler.shuffle(Random());
    emojiler = tumEmojiler;
  }
  
  void gosterGeriBildirim(String text, Color color, IconData icon) {
    setState(() {
      feedbackText = text;
      feedbackColor = color;
      feedbackIcon = icon;
      showFeedback = true;
    });

    _feedbackController.forward(from: 0).then((_) {
      if (eslesenler.length == emojiler.length) {
        kontrolVeIlerle(context);
      }
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && eslesenler.length != emojiler.length) {
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
          MaterialPageRoute(builder: (context) => const UzunKisaSinifla()),
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
          if (kategori == 'Kız') {
            kategoriRenkleri[kategori] = const Color(0xFFFFDDEE);
          } else {
            kategoriRenkleri[kategori] = const Color(0xFFD6ECFF);
          }
        });
      }
    });
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
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 1,
                            ),
                            child: Text(
                              isEnglish
                                  ? 'Drag and drop the children to the correct box.'
                                  : 'Çocukları uygun kutuya sürükle!',
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: kategoriler.map((kategori) {
                                      Color boxColor =
                                          kategoriRenkleri[kategori] ??
                                              Colors.transparent;
                                      Color borderColor = kategori == 'Kız'
                                          ? Colors.pinkAccent
                                          : Colors.lightBlue;

                                      return DragTarget<String>(
                                        onWillAccept: (data) =>
                                            !eslesenler.contains(data),
                                        onAcceptWithDetails: (data) {
                                          if (dogruEslesmeler[data.data] ==
                                              kategori) {
                                            setState(() {
                                              eslesenler.add(data.data);
                                            });
                                            gosterGeriBildirim(
                                              isEnglish
                                                  ? 'Well done! 🎉'
                                                  : 'Aferin! 🎉',
                                              Colors.green,
                                              Icons.check_circle,
                                            );
                                            kutuyuRenklendir(
                                              kategori,
                                              Colors.green.shade200,
                                            );
                                          } else {
                                            gosterGeriBildirim(
                                              isEnglish
                                                  ? 'Try again! 😔'
                                                  : 'Tekrar dene! 😔',
                                              Colors.red,
                                              Icons.cancel,
                                            );
                                            kutuyuRenklendir(
                                              kategori,
                                              Colors.red.shade200,
                                            );
                                          }
                                        },
                                        builder: (context, _, __) {
                                          return Container(
                                            width: double.infinity,
                                            height: 140,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 16),
                                            decoration: BoxDecoration(
                                              color: boxColor,
                                              border: Border.all(
                                                color: borderColor,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  isEnglish
                                                      ? (kategori == 'Kız'
                                                          ? 'Girl'
                                                          : 'Boy')
                                                      : kategori,
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Wrap(
                                                  alignment:
                                                      WrapAlignment.center,
                                                  spacing: 8,
                                                  children: eslesenler
                                                      .where((e) =>
                                                          dogruEslesmeler[e] ==
                                                          kategori)
                                                      .map(
                                                        (e) => Text(
                                                          e,
                                                          style: const TextStyle(
                                                              fontSize: 36),
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: emojiler
                                        .where((emoji) =>
                                            !eslesenler.contains(emoji))
                                        .map((emoji) {
                                      return Draggable<String>(
                                        data: emoji,
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: _buildItemBox(emoji),
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: 0.3,
                                          child: _buildItemBox(emoji),
                                        ),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  child: showFeedback
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

  Widget _buildItemBox(String emoji) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: 90,
      height: 100,
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
          emoji,
          style: const TextStyle(fontSize: 70),
        ),
      ),
    );
  }
}