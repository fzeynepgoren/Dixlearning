import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'soru2.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DuyguSiniflama(),
    ));

class DuyguSiniflama extends StatefulWidget {
  const DuyguSiniflama({super.key});

  @override
  State<DuyguSiniflama> createState() => _DuyguSiniflamaState();
}

class _DuyguSiniflamaState extends State<DuyguSiniflama> {
  final Map<String, String> dogruEslesmeler = {
    'mutlu1': 'Mutlu',
    'mutlu2': 'Mutlu',
    'uzgun1': 'Üzgün',
    'uzgun2': 'Üzgün',
    'kizgin1': 'Kızgın',
    'kizgin2': 'Kızgın',
  };

  late List<String> yuzler;
  late List<String> shuffledYuzler;
  final List<String> kategoriler = ['Mutlu', 'Üzgün', 'Kızgın'];

  Set<String> eslesenler = {};
  Map<String, Color?> yuzRenkleri = {};

  String? mesaj;
  Color? mesajRenk;
  IconData? mesajIkon;

  @override
  void initState() {
    super.initState();
    yuzler = dogruEslesmeler.keys.toList();
    kategoriler.shuffle(Random());
    shuffledYuzler = List<String>.from(yuzler);
    shuffledYuzler.shuffle(Random());
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
      yuzRenkleri[id] = renk;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        yuzRenkleri[id] = null;
      });
    });
  }

  // ✅ SADECE BU FONKSİYONDA GÜNCELLEME YAPILDI
  void eslesmeYapildi(String data, String kategori) {
    if (dogruEslesmeler[data] == kategori) {
      setState(() {
        eslesenler.add(data);
      });
      renkliGoster(data, Colors.green.shade200);
      gosterMesaj('Aferin! 🎉', Colors.green, Icons.check_circle);

      // ✅ Tüm yüzler eşleştiyse, 1 saniye sonra otomatik olarak yeni sayfaya geç
      if (eslesenler.length == dogruEslesmeler.length) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const DuyuOrganlariSinifla()),
          );
        });
      }
    } else {
      renkliGoster(data, Colors.red.shade300);
      gosterMesaj('Tekrar dene! 😔', Colors.red, Icons.cancel);
    }
  }

  Widget _buildYuz(String id,
      {bool small = false, bool eslesti = false, Color? renk}) {
    double size = small ? 52 : 76;
    double opacity = eslesti ? 0.4 : 1.0;
    String emoji;

    if (id.startsWith('mutlu')) {
      emoji = '😊';
    } else if (id.startsWith('uzgun')) {
      emoji = '😢';
    } else {
      emoji = '😠';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: renk ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Opacity(
          opacity: opacity,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Duygulara Göre Sınıflama'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text(
              'Yüz ifadelerini duygularına göre uygun kutuya sürükle!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
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
                                  color: renk,
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
                                          .map((e) => _buildYuz(e,
                                              small: true,
                                              eslesti: true,
                                              renk: yuzRenkleri[e]))
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
                      children: shuffledYuzler.map((id) {
                        bool eslesti = eslesenler.contains(id);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: eslesti
                              ? SizedBox(
                                  width: 76,
                                  height: 76,
                                  child: _buildYuz(id,
                                      small: false,
                                      eslesti: true,
                                      renk: yuzRenkleri[id]),
                                )
                              : Draggable<String>(
                                  data: id,
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: SizedBox(
                                      width: 76,
                                      height: 76,
                                      child: _buildYuz(id,
                                          small: false, renk: yuzRenkleri[id]),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.3,
                                    child: _buildYuz(id,
                                        small: false, renk: yuzRenkleri[id]),
                                  ),
                                  child: SizedBox(
                                    width: 76,
                                    height: 76,
                                    child: _buildYuz(id,
                                        small: false, renk: yuzRenkleri[id]),
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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(mesajIkon, color: mesajRenk),
                  const SizedBox(width: 6),
                  Text(
                    mesaj!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: mesajRenk,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

// ✅ SONRASI İÇİN BOŞ SAYFA
class SonrakiSoru extends StatelessWidget {
  const SonrakiSoru({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      body: Center(child: Container()), // Boş ekran
    );
  }
}
