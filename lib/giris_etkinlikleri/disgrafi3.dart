import 'package:flutter/material.dart';
import 'dart:math';
import 'disgrafi1.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class HeceDoldurma extends StatefulWidget {
  const HeceDoldurma({super.key});

  @override
  State<HeceDoldurma> createState() => _HeceDoldurmaState();
}

class _HeceDoldurmaState extends State<HeceDoldurma>
    with TickerProviderStateMixin {
  final List<Map<String, String>> items = [
    {'emoji': '🖊️', 'prefix': 'ka', 'answer': 'lem'}, // ka___
    {
      'emoji': '🪑',
      'prefix': 'san',
      'suffix': 'ye',
      'answer': 'dal',
    }, // san___ye
    {'emoji': '💻', 'suffix': 'gisayar', 'answer': 'bil'}, // ___gisayar
    {'emoji': '🍳', 'prefix': 'ta', 'answer': 'va'}, // ta___
    {'emoji': '🔨', 'suffix': 'kiç', 'answer': 'çe'}, // ___kiç
    {'emoji': '🥛', 'prefix': 'bar', 'answer': 'dak'}, // bar___
  ];

  final List<String> commonLetters = [
    'a',
    'k',
    'n',
    'r',
    'e',
    't',
    's',
    'u',
    'o',
    'i',
    'm',
    'l',
    'd',
    'b',
    'y',
    'z',
    'v',
    'ç',
    'ş',
    'ğ',
    'ü',
    'ö',
    'c',
    'p',
    'h',
    'f',
    'j',
    'g',
  ];

  int currentIndex = 0;
  List<List<String?>> userInputs = [];
  bool isCorrect = false;
  bool isWrong = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    userInputs = List.generate(
      items.length,
      (i) => List.filled(items[i]['answer']!.length, null),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 16,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void checkAnswer() async {
    String userAnswer = userInputs[currentIndex].join();
    bool answerIsCorrect = userAnswer == items[currentIndex]['answer'];
    setState(() {
      isCorrect = answerIsCorrect;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      isCorrect = false;
    });
    if (currentIndex < items.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      if (mounted) {
        print('Disgrafi3 tamamlandı, bir sonraki aktiviteye geçiliyor');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Disgrafi1(),
          ),
        );
      }
    }
  }

  void clearInput(int i) {
    setState(() {
      userInputs[currentIndex][i] = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final item = items[currentIndex];
    final answer = item['answer']!;
    final userInput = userInputs[currentIndex];
    String prefix = item['prefix'] ?? '';
    String suffix = item['suffix'] ?? '';

    // Doğru cevabın harfleri
    List<String> answerLetters = answer.split('');
    // Karıştırıcı harfler
    List<String> distractors = [];
    final rand = Random();
    while (distractors.length < 5 - answerLetters.length) {
      String letter = commonLetters[rand.nextInt(commonLetters.length)];
      if (!answerLetters.contains(letter) && !distractors.contains(letter)) {
        distractors.add(letter);
      }
    }
    // Tüm harfler (doğru + karıştırıcı), karışık sırada
    List<String> allLetters = [...answerLetters, ...distractors];
    allLetters.shuffle();

    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: Text(
            isEnglish ? 'Syllable Completion Game' : 'Hece Tamamlama Oyunu'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0288D1),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // İlerleme göstergesi
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                isEnglish
                    ? 'Question ${currentIndex + 1}/${items.length}'
                    : 'Soru ${currentIndex + 1}/${items.length}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0288D1),
                ),
              ),
            ),
            // Emoji ve açıklama
            Text(item['emoji']!, style: const TextStyle(fontSize: 70)),
            const SizedBox(height: 12),
            Text(
              isEnglish
                  ? 'Drag the missing letters to the blanks!'
                  : 'Eksik harfleri sürükleyerek boşlukları doldur!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            // Soru metni (prefix + kutular + suffix)
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                double offset = isWrong ? _shakeAnimation.value : 0;
                return Transform.translate(
                  offset: Offset(offset * (Random().nextBool() ? 1 : -1), 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefix.isNotEmpty)
                    Text(
                      prefix,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ...List.generate(answer.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: DragTarget<String>(
                        onAcceptWithDetails: (details) {
                          setState(() {
                            userInput[i] = details.data;
                          });
                        },
                        builder: (context, candidateData, rejectedData) {
                          return GestureDetector(
                            onLongPress: userInput[i] != null
                                ? () => clearInput(i)
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 60,
                              height: 60,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? Colors.green
                                    : (candidateData.isNotEmpty
                                        ? Colors.yellow[200]
                                        : Colors.blue.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isCorrect
                                      ? Colors.green
                                      : Colors.blueAccent,
                                  width: 3,
                                ),
                                boxShadow: [
                                  if (candidateData.isNotEmpty)
                                    const BoxShadow(
                                      color: Colors.amber,
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                ],
                              ),
                              child: Text(
                                userInput[i] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  if (suffix.isNotEmpty)
                    Text(
                      suffix,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Onayla butonu
            ElevatedButton(
              onPressed: checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorrect ? Colors.green : Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Onayla',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            // Sürüklenebilir harf kutuları
            const Text(
              "Harf Kutuları",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: allLetters.map((letter) {
                return Draggable<String>(
                  data: letter,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _buildLetterBox(letter, dragging: true),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _buildLetterBox(letter),
                  ),
                  child: _buildLetterBox(letter),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterBox(String letter, {bool dragging = false}) {
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dragging ? Colors.amberAccent : Colors.pinkAccent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
