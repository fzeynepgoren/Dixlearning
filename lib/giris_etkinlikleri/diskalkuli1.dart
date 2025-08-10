import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'diskalkuli3.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class Diskalkuli1 extends StatefulWidget {
  const Diskalkuli1({super.key});

  @override
  State<Diskalkuli1> createState() => _Diskalkuli1State();
}

class _Diskalkuli1State extends State<Diskalkuli1> {
  final List<List<List<String>>> questions = [
    [
      ['🐟', '🐟'],
      ['🐟', '🐟', '🐟', '🐟', '🐟']
    ],
    [
      ['🍎', '🍎', '🍎'],
      ['🍎', '🍎']
    ],
    [
      ['🦋', '🦋', '🦋', '🦋'],
      ['🦋', '🦋', '🦋']
    ],
    [
      ['🚗', '🚗', '🚗', '🚗', '🚗'],
      ['🚗', '🚗']
    ],
    [
      ['🌼', '🌼', '🌼', '🌼'],
      ['🌼', '🌼', '🌼', '🌼', '🌼', '🌼']
    ],
  ];

  int currentIndex = 0;
  List<TextEditingController> controllers = [
    TextEditingController(),
    TextEditingController()
  ];
  List<bool?> isCorrect = [null, null];
  bool showFeedback = false;

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void checkAnswers() {
    final current = questions[currentIndex];
    setState(() {
      isCorrect[0] = int.tryParse(controllers[0].text) == current[0].length;
      isCorrect[1] = int.tryParse(controllers[1].text) == current[1].length;
      showFeedback = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (currentIndex < questions.length - 1) {
        if (mounted) {
          setState(() {
            currentIndex++;
            controllers[0].clear();
            controllers[1].clear();
            isCorrect = [null, null];
            showFeedback = false;
          });
        }
      } else {
        if (mounted) {
          print('Diskalkuli1 tamamlandı, bir sonraki aktiviteye geçiliyor');
          // Etkinlik tamamlandı

          ActivityTracker.completeActivity();

          

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Diskalkuli3()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final current = questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      appBar: AppBar(
        title: Text(isEnglish ? 'Counting Activity' : 'Sayma Etkinliği'),
        backgroundColor: const Color(0xFF00BCD4),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                isEnglish
                    ? 'Question ${currentIndex + 1}/${questions.length}'
                    : 'Soru ${currentIndex + 1}/${questions.length}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00796B),
                ),
              ),
              const SizedBox(height: 32),
              _buildEmojiGroup(current[0], 0),
              const SizedBox(height: 32),
              _buildEmojiGroup(current[1], 1),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: showFeedback ? null : checkAnswers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  isEnglish ? 'Check' : 'Kontrol Et',
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiGroup(List<String> emojis, int index) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: emojis
              .map((e) => Text(e, style: const TextStyle(fontSize: 40)))
              .toList(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 80,
          child: TextField(
            controller: controllers[index],
            enabled: !showFeedback,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '?',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isCorrect[index] == null
                      ? Colors.grey
                      : isCorrect[index]!
                          ? Colors.green
                          : Colors.red,
                  width: 3,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isCorrect[index] == null
                      ? Colors.blue
                      : isCorrect[index]!
                          ? Colors.green
                          : Colors.red,
                  width: 3,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (showFeedback && isCorrect[index] != null)
          Icon(
            isCorrect[index]! ? Icons.check_circle : Icons.cancel,
            color: isCorrect[index]! ? Colors.green : Colors.red,
            size: 32,
          ),
      ],
    );
  }
}
