import 'package:flutter/material.dart';
import 'soru2.dart';

class CinsiyetEsleme extends StatefulWidget {
  const CinsiyetEsleme({super.key});

  @override
  State<CinsiyetEsleme> createState() => _CinsiyetEslemeState();
}

class _CinsiyetEslemeState extends State<CinsiyetEsleme> {
  final Map<String, String> dogruEslesmeler = {
    '👧': 'Kız',
    '👩': 'Kız',
    '👦': 'Erkek',
    '👨': 'Erkek',
  };

  final List<String> emojiler = ['👧', '👩', '👦', '👨'];
  final List<String> kategoriler = ['Kız', 'Erkek'];

  Set<String> eslesenler = {};
  Map<String, Color?> emojiRenkleri = {};

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

  void kontrolVeIlerle(BuildContext context) {
    if (eslesenler.length == emojiler.length) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UzunKisaSinifla()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Kız ve Erkekleri Sınıflama'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Kız ve erkek çocuklarını uygun kutuya sürükle!',
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
                        Color boxColor = kategori == 'Kız'
                            ? const Color(0xFFFFDDEE)
                            : const Color(0xFFD6ECFF);
                        Color borderColor = kategori == 'Kız'
                            ? Colors.pinkAccent
                            : Colors.lightBlue;

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
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 8,
                                    children: eslesenler
                                        .where((e) =>
                                            dogruEslesmeler[e] == kategori)
                                        .map((e) => Text(
                                              e,
                                              style: const TextStyle(
                                                fontSize: 36,
                                                color: Color(0xFF999999),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            );
                          },
                          onWillAcceptWithDetails: (details) =>
                              !eslesenler.contains(details.data),
                          onAcceptWithDetails: (details) {
                            if (dogruEslesmeler[details.data] == kategori) {
                              setState(() {
                                eslesenler.add(details.data);
                              });
                              renkliGoster(details.data, Colors.green.shade200);
                              kontrolVeIlerle(context);
                            } else {
                              renkliGoster(details.data, Colors.red.shade300);
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

                        return Draggable<String>(
                          data: emoji,
                          feedback: Material(
                            color: Colors.transparent,
                            child: _buildEmojiBox(emoji, eslesti, renk,
                                dragging: true),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _buildEmojiBox(emoji, eslesti, renk),
                          ),
                          child: _buildEmojiBox(emoji, eslesti, renk),
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
    );
  }

  Widget _buildEmojiBox(String emoji, bool eslesti, Color? renk,
      {bool dragging = false}) {
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
          style: TextStyle(
            fontSize: 38,
            color: eslesti ? const Color(0xFF999999) : Colors.black,
          ),
        ),
      ),
    );
  }
}
