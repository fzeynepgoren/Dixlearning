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
  bool _showCorrectAnswer = false;
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
      print('Playing audio: $path');
    } catch (e) {
      print('Error playing audio: $e');
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

    if (allCorrect) {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _showCorrectAnswer = false;
        });
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Tebrikler!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            content: const Text('Tüm soruları başarıyla tamamladınız.',
                style: TextStyle(fontSize: 18)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Etkinlik tamamlandı

                  ActivityTracker.completeActivity();

                  

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Disgrafi2()),
                  );
                },
                child: const Text('Devam Et', style: TextStyle(fontSize: 18)),
              )
            ],
          ),
        );
      }
    } else {
      setState(() {
        _showCorrectAnswer = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showCorrectAnswer = false;
            if (_currentQuestionIndex < _questions.length - 1) {
              _currentQuestionIndex++;
            }
          });
        }
      });
    }
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                isEnglish ? 'Listen and write the missing words!' : 'Cümleyi dinle ve eksik kelimeleri yaz!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(current['sentence'].length, (index) {
                  final word = current['sentence'][index];
                  if (word == '') {
                    final controller = current['controllers'][index ~/ 2];
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
                    String displayWord = word
                        .replaceAll('ğ', 'g')
                        .replaceAll('ş', 's')
                        .replaceAll('ü', 'u');
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        displayWord,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                }),
              ),
            ),
            if (_showCorrectAnswer) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      isEnglish ? 'Correct Answer:' : 'Dogru Cevap:',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${current['sentence'][0].replaceAll('ğ', 'g').replaceAll('ş', 's').replaceAll('ü', 'u')} ${current['answers'][0]} ${current['sentence'][2].replaceAll('ğ', 'g').replaceAll('ş', 's').replaceAll('ü', 'u')} ${current['answers'][1]}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
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
