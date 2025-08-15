import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'soru2.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../screens/home_screen.dart';
import 'package:dixlearning/karsilastirma_kalin_ince/kalin_ince_asama1/soru3.dart'; // Bu dosyayı kendi sonraki sayfa dosyanızla değiştirin

class SekilSiniflama extends StatefulWidget {
  const SekilSiniflama({super.key});

  @override
  State<SekilSiniflama> createState() => _SekilSiniflamaState();
}

class _SekilSiniflamaState extends State<SekilSiniflama>
    with TickerProviderStateMixin {
  final Map<String, String> dogruEslesmeler = {
    'ucgen1': 'Üçgen',
    'kare1': 'Kare',
    'daire1': 'Daire',
    'ucgen2': 'Üçgen',
    'kare2': 'Kare',
    'daire2': 'Daire',
  };

  late List<String> sekiller;
  late List<String> shuffledSekiller;
  final List<String> kategoriler = ['Üçgen', 'Daire', 'Kare'];

  Set<String> eslesenler = {};
  Map<String, Color?> sekilRenkleri = {};
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
    sekiller = dogruEslesmeler.keys.toList();
    kategoriler.shuffle(Random());
    shuffledSekiller = List<String>.from(sekiller);
    shuffledSekiller.shuffle(Random());

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
          MaterialPageRoute(builder: (context) => const BoyutSinifla()), // Sayfa geçişi soru2.dart'a yönlendirildi
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
                                  ? 'Drag and drop the shapes to the correct box.'
                                  : 'Şekilleri türlerine göre uygun kutuya sürükle!',
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
                                      Color renk = const Color(0xFFE0F7FA);
                                      Color border = Colors.black;

                                      Color? dynamicBoxColor = kategoriRenkleri[kategori] ?? renk;

                                      return Expanded(
                                        child: DragTarget<String>(
                                          builder: (context, _, __) {
                                            final eslesenSekiller = eslesenler
                                                .where((e) => dogruEslesmeler[e] == kategori)
                                                .toList();
                                            return Container(
                                              width: double.infinity,
                                              margin: const EdgeInsets.symmetric(vertical: 7),
                                              padding: const EdgeInsets.all(7),
                                              decoration: BoxDecoration(
                                                color: dynamicBoxColor,
                                                border: Border.all(color: border, width: 2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Center(
                                                    child: Text(
                                                      kategori,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: border,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Wrap(
                                                    spacing: 8,
                                                    alignment: WrapAlignment.center,
                                                    children: eslesenSekiller
                                                        .map((e) => _buildSekil(e, small: true, renk: sekilRenkleri[e]))
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
                                    children: shuffledSekiller.map((id) {
                                      bool eslesti = eslesenler.contains(id);
                                      return eslesti
                                          ? Container()
                                          : Draggable<String>(
                                        data: id,
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: Container(
                                            width: 64,
                                            height: 64,
                                            child: Center(child: _buildSekil(id, small: false, renk: sekilRenkleri[id])),
                                          ),
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: 0.3,
                                          child: _buildSekil(id, small: false, renk: sekilRenkleri[id]),
                                        ),
                                        child: Container(
                                          width: 64,
                                          height: 64,
                                          child: Center(child: _buildSekil(id, small: false, renk: sekilRenkleri[id])),
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

  Widget _buildSekil(String id,
      {bool small = false, bool eslesti = false, Color? renk}) {
    Widget sekil;
    Color baseColor;
    double size = small ? 40 : 56;

    if (id == 'ucgen1') {
      baseColor = Colors.orange;
    } else if (id == 'ucgen2') {
      baseColor = Colors.deepOrange;
    } else if (id == 'daire1') {
      baseColor = Colors.blue;
    } else if (id == 'daire2') {
      baseColor = Colors.indigo;
    } else if (id == 'kare1') {
      baseColor = Colors.green;
    } else {
      baseColor = Colors.teal;
    }

    Color finalRenk = renk ?? (eslesti ? baseColor.withOpacity(0.4) : baseColor);

    if (id.contains('ucgen')) {
      sekil = CustomPaint(
        size: Size(size, size),
        painter: _TrianglePainter(finalRenk),
      );
    } else if (id.contains('daire')) {
      sekil = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: finalRenk,
        ),
      );
    } else {
      sekil = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: finalRenk,
        ),
      );
    }
    return sekil;
  }
}

class _TrianglePainter extends CustomPainter {
  final Color renk;
  _TrianglePainter(this.renk);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = renk
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
