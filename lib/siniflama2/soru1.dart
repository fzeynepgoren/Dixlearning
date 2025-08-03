import 'package:flutter/material.dart';
import 'dart:async';
import 'soru2.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MeyveSebzeEsleme(),
    ));

class MeyveSebzeEsleme extends StatefulWidget {
  const MeyveSebzeEsleme({super.key});

  @override
  State<MeyveSebzeEsleme> createState() => _MeyveSebzeEslemeState();
}

class _MeyveSebzeEslemeState extends State<MeyveSebzeEsleme> {
  final Map<String, String> dogruEslesmeler = {
    '🍎': 'Meyve',
    '🍌': 'Meyve',
    '🌶️': 'Sebze',
    '🥕': 'Sebze',
  };

  final List<String> emojiler = ['🍎', '🍌', '🌶️', '🥕'];
  final List<String> kategoriler = ['Meyve', 'Sebze'];

  Set<String> eslesenler = {};
  Map<String, Color?> emojiRenkleri = {};

  String? mesaj;
  Color? mesajRenk;
  IconData? mesajIkon;

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

  void renkliGoster(String emoji, Color renk) {
    setState(() {
      emojiRenkleri[emoji] = renk;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        emojiRenkleri[emoji] = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Meyveleri ve Sebzeleri Sınıflandır'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Görsellerdeki yiyecekleri uygun kutuya sürükle!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: kategoriler.map((kategori) {
                        Color boxColor = const Color(0xFFE0F7FA);
                        Color borderColor = Colors.black;

                        return DragTarget<String>(
                          builder: (context, _, __) {
                            return Container(
                              width: double.infinity,
                              height: 220,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                color: boxColor,
                                border: Border.all(
                                  color: borderColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  Text(
                                    kategori,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Column(
                                    children: eslesenler
                                        .where((e) =>
                                            dogruEslesmeler[e] == kategori)
                                        .map((e) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0),
                                              child: Text(
                                                e,
                                                style: const TextStyle(
                                                  fontSize: 36,
                                                  color: Colors.black,
                                                ),
                                              ),
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
                            if (dogruEslesmeler[data.data] == kategori) {
                              setState(() {
                                eslesenler.add(data.data);
                              });
                              renkliGoster(data.data, Colors.green.shade200);
                              gosterMesaj('Aferin! 🎉', Colors.green,
                                  Icons.check_circle);

                              if (eslesenler.length == emojiler.length) {
                                Future.delayed(const Duration(seconds: 1), () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CanliCansizSinifla()),
                                  );
                                });
                              }
                            } else {
                              renkliGoster(data.data, Colors.red.shade300);
                              gosterMesaj(
                                  'Tekrar dene! 😔', Colors.red, Icons.cancel);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: emojiler.map((emoji) {
                        bool eslesti = eslesenler.contains(emoji);
                        Color? renk = emojiRenkleri[emoji];

                        return eslesti
                            ? _buildEmojiBox(emoji, renk)
                            : Draggable<String>(
                                data: emoji,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: _buildEmojiBox(emoji, renk),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: _buildEmojiBox(emoji, renk),
                                ),
                                child: _buildEmojiBox(emoji, renk),
                              );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            if (mesaj != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(mesajIkon, color: mesajRenk),
                  const SizedBox(width: 8),
                  Text(
                    mesaj!,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: mesajRenk),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiBox(String emoji, Color? renk) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: renk ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(
            fontSize: 38,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class SonrakiSoruSayfasi extends StatelessWidget {
  const SonrakiSoruSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: AppBar(
        title: const Text('Yeni Görev'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text(
          '',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
