import 'package:flutter/material.dart';
import 'disgrafi3.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class Disgrafi2 extends StatefulWidget {
  const Disgrafi2({super.key});

  @override
  State<Disgrafi2> createState() => _Disgrafi2State();
}

class _Disgrafi2State extends State<Disgrafi2> {
  final _controller = TextEditingController();
  String _resultMessage = '';
  Color _resultColor = Colors.transparent;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkPoem() {
    const correct = 'Ailemle birlikte tiyatroya gittik.';
    if (_controller.text.trim() == correct) {
      setState(() {
        _resultMessage = '🎉 Harika! Cümleyi doğru yazdınız!';
        _resultColor = Colors.green;
      });

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          print('Disgrafi2 tamamlandı, bir sonraki aktiviteye geçiliyor');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HeceDoldurma()),
          );
        }
      });
    } else {
      setState(() {
        _resultMessage = '❌ Hatalı yazım! Tekrar deneyin.';
        _resultColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    return Scaffold(
      appBar: AppBar(title: Text(isEnglish ? 'Dysgraphia 2' : 'Disgrafi 2')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              isEnglish ? 'Write the sentence below exactly:' : 'Aşağıdaki cümleyi aynen yazınız:',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isEnglish ? 'I went to the theater with my family.' : 'Ailemle birlikte tiyatroya gittik.',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: isEnglish ? 'Write the sentence here...' : 'Cümleyi buraya yazınız...',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPoem,
              child: Text(isEnglish ? 'Check' : 'Kontrol Et'),
            ),
            const SizedBox(height: 24),
            if (_resultMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _resultColor.withOpacity(0.2),
                  border: Border.all(color: _resultColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isEnglish
                      ? (_resultMessage.contains('Harika')
                          ? '🎉 Great! You wrote the sentence correctly!'
                          : '❌ Incorrect writing! Try again.')
                      : _resultMessage,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _resultColor,
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
