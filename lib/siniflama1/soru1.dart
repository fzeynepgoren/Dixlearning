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
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );
    _slideController.forward();

    kategoriRenkleri = {
      'Kız': const Color(0xFFFFDDEE),
      'Erkek': const Color(0xFFE3F2FD),
    };
  }

  void emojileriKaristir() {
    final tumEmojiler = dogruEslesmeler.keys.toList();
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
    _feedbackController.forward();
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
  }

  Widget _buildItemBox(String emoji) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 70))),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.065;

    return PopScope(
      canPop: false,
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
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    SizedBox(width: iconSize),
                    Text(
                      isEnglish ? 'Gender Matching' : 'Cinsiyet Eşleştirme',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            isEnglish
                                ? 'Drag the emojis to the correct gender!'
                                : 'Emojileri doğru cinsiyete sürükle!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children:
                                        kategoriler.map((kategori) {
                                          Color boxColor =
                                              kategoriRenkleri[kategori] ??
                                              Colors.transparent;
                                          Color borderColor =
                                              kategori == 'Kız'
                                                  ? Colors.pinkAccent
                                                  : Colors.lightBlue;

                                          return DragTarget<String>(
                                            onWillAcceptWithDetails:
                                                (data) =>
                                                    !eslesenler.contains(
                                                      data.data,
                                                    ),
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
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 16,
                                                    ),
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    if (eslesenler
                                                        .where(
                                                          (e) =>
                                                              dogruEslesmeler[e] ==
                                                              kategori,
                                                        )
                                                        .isNotEmpty)
                                                      const SizedBox(height: 8),
                                                    Expanded(
                                                      child: SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              eslesenler
                                                                      .where(
                                                                        (e) =>
                                                                            dogruEslesmeler[e] ==
                                                                            kategori,
                                                                      )
                                                                      .isEmpty
                                                                  ? MainAxisAlignment
                                                                      .center
                                                                  : MainAxisAlignment
                                                                      .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children:
                                                              eslesenler
                                                                  .where(
                                                                    (e) =>
                                                                        dogruEslesmeler[e] ==
                                                                        kategori,
                                                                  )
                                                                  .map(
                                                                    (
                                                                      e,
                                                                    ) => Padding(
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            4,
                                                                      ),
                                                                      child: Text(
                                                                        e,
                                                                        style: const TextStyle(
                                                                          fontSize:
                                                                              36,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                  .toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        }).toList(),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:
                                        emojiler
                                            .where(
                                              (emoji) =>
                                                  !eslesenler.contains(emoji),
                                            )
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
                                            })
                                            .toList(),
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
}
