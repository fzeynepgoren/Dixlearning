import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'soru2.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SekilSiniflama(),
    ));

class SekilSiniflama extends StatefulWidget {
  const SekilSiniflama({super.key});

  @override
  State<SekilSiniflama> createState() => _SekilSiniflamaState();
}

class _SekilSiniflamaState extends State<SekilSiniflama> {
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

  String? mesaj;
  Color? mesajRenk;
  IconData? mesajIkon;

  @override
  void initState() {
    super.initState();
    sekiller = dogruEslesmeler.keys.toList();
    kategoriler.shuffle(Random());
    shuffledSekiller = List<String>.from(sekiller);
    shuffledSekiller.shuffle(Random());
  }

  void gosterMesaj(String text, Color renk, IconData ikon) {
    setState(() {
      mesaj = text;
      mesajRenk = renk;
      mesajIkon = ikon;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        mesaj = null;
      });
    });
  }

  void renkliGoster(String id, Color renk) {
    setState(() {
      sekilRenkleri[id] = renk;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        sekilRenkleri[id] = null;
      });
    });
  }

  // ✅ SADECE BURAYI GÜNCELLEDİM
  void eslesmeYapildi(String data, String kategori) {
    if (dogruEslesmeler[data] == kategori) {
      setState(() {
        eslesenler.add(data);
      });
      renkliGoster(data, Colors.green.shade200);
      gosterMesaj('Aferin! 🎉', Colors.green, Icons.check_circle);

      if (eslesenler.length == dogruEslesmeler.length) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BoyutSinifla()),
          );
        });
      }
    } else {
      renkliGoster(data, Colors.red.shade300);
      gosterMesaj('Tekrar dene! 😔', Colors.red, Icons.cancel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Üçgen, Kare, Daireyi Sınıflama'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Şekilleri türlerine göre uygun kutuya sürükle!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
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
                                  color: renk,
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: eslesenSekiller
                                          .map((e) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 12),
                                                child: _buildSekil(e,
                                                    small: true,
                                                    renk: sekilRenkleri[e]),
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onWillAcceptWithDetails: (data) =>
                                data != null && !eslesenler.contains(data),
                            onAcceptWithDetails: (data) {
                              eslesmeYapildi(data.data, kategori);
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
                            ? SizedBox(
                                width: 64,
                                height: 64,
                                child: Center(
                                  child: _buildSekil(id,
                                      small: false,
                                      eslesti: true,
                                      renk: sekilRenkleri[id]),
                                ),
                              )
                            : Draggable<String>(
                                data: id,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: SizedBox(
                                    width: 64,
                                    height: 64,
                                    child: Center(
                                      child: _buildSekil(id,
                                          small: false,
                                          renk: sekilRenkleri[id]),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: _buildSekil(id,
                                      small: false, renk: sekilRenkleri[id]),
                                ),
                                child: SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: Center(
                                    child: _buildSekil(id,
                                        small: false, renk: sekilRenkleri[id]),
                                  ),
                                ),
                              );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            if (mesaj != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(mesajIkon, color: mesajRenk),
                  const SizedBox(width: 6),
                  Text(
                    mesaj!,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: mesajRenk),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ],
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

    Color finalRenk =
        renk ?? (eslesti ? baseColor.withOpacity(0.4) : baseColor);

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

// ✅ YENİ SORU SAYFASI - BOŞ
class SonrakiSoru extends StatelessWidget {
  const SonrakiSoru({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      body: Center(child: Container()),
    );
  }
}
