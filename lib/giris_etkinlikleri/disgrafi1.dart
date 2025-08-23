import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'disgrafi2.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class Disgrafi1 extends StatefulWidget {
  const Disgrafi1({super.key});

  @override
  State<Disgrafi1> createState() => _Disgrafi1State();
}

class _Disgrafi1State extends State<Disgrafi1> {
  final player = AudioPlayer();
  int _currentQuestionIndex = 0;
  bool _isPlaying = false;
  bool _showFeedback = false;
  bool _isCorrect = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'audio': 'ses1.mp3',
      'sentence': ['Doktor', '', 'taksi', ''],
      'answers': ['durakta', 'bekledi'],
      'controllers': [TextEditingController(), TextEditingController()],
    },
    {
      'audio': 'ses2.mp3',
      'sentence': ['Baris', '', 'ocakta', ''],
      'answers': ['sutu', 'tasirdi'],
      'controllers': [TextEditingController(), TextEditingController()],
    },
  ];

  @override
  void initState() {
    super.initState();
    player.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
    for (var question in _questions) {
      for (var controller in question['controllers']) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _playAudio(String path) async {
    try {
      setState(() {
        _isPlaying = true;
      });

      await player.stop();
      await player.play(AssetSource(path));
    } catch (e) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  void _checkAnswers() {
    final current = _questions[_currentQuestionIndex];
    bool allCorrect = true;

    for (int i = 0; i < current['answers'].length; i++) {
      final controller = current['controllers'][i];
      final userAnswer = controller.text.trim().toLowerCase();
      final correctAnswer = current['answers'][i].toLowerCase();

      if (userAnswer != correctAnswer) {
        allCorrect = false;
      }
    }

    setState(() {
      _showFeedback = true;
      _isCorrect = allCorrect;
    });

    // 3 saniye bekle → Disgrafi2'ye geç
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      ActivityTracker.completeActivity();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Disgrafi2()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final current = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Dysgraphia Activity' : 'Disgrafi Etkinliği',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade200,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isPlaying ? null : () => _playAudio(current['audio']),
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 32),
              label: Text(
                _isPlaying
                    ? (isEnglish ? 'Playing...' : 'Çalıyor...')
                    : (isEnglish ? 'Listen Sentence' : 'Cümleyi Dinle'),
                style: const TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade200,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 🔹 Cümle + boşluklar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: () {
                  int blankCounter = 0;
                  return current['sentence'].map<Widget>((word) {
                    if (word == '') {
                      final controller = current['controllers'][blankCounter];
                      blankCounter++;
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                            hintText: isEnglish ? 'Word' : 'Kelime',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          word,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                  }).toList();
                }(),
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 Feedback Alanı
            if (_showFeedback)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isCorrect
                      ? (isEnglish ? 'Well done! 🎉' : 'Aferin 🎉')
                      : (isEnglish
                      ? 'Correct Answer: ${current['sentence'][0]} ${current['answers'][0]} ${current['sentence'][2]} ${current['answers'][1]}'
                      : 'Doğru Cevap: ${current['sentence'][0]} ${current['answers'][0]} ${current['sentence'][2]} ${current['answers'][1]}'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),

            const Spacer(),
            if (!_showFeedback)
              ElevatedButton(
                onPressed: _checkAnswers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade200,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isEnglish ? 'Confirm' : 'Onayla',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
