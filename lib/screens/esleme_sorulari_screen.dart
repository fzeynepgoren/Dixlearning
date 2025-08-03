import 'package:flutter/material.dart';
import '../asama1/soru1.dart';
import '../asama2/soru1.dart';
import '../asama3/soru1.dart';
import '../asama4/soru1.dart';

class EslemeSorulariScreen extends StatelessWidget {
  const EslemeSorulariScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF6C63FF);
    const Color accentColor = Color(0xFF00C9A7);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eşleme Soruları'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              mainColor.withOpacity(0.10),
              accentColor.withOpacity(0.10)
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildActivityCard(
                  context,
                  '🍎',
                  '1. Aşama Soruları',
                  'Meyve eşleştirme ve fazlası!',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MeyveEsle()),
                    );
                  },
                  mainColor,
                ),
                _buildActivityCard(
                  context,
                  '🔤',
                  '2. Aşama Soruları',
                  'Harf oyunları ve bulmacalar!',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Soru1()),
                    );
                  },
                  mainColor,
                ),
                _buildActivityCard(
                  context,
                  '🏛️',
                  '3. Aşama Soruları',
                  'Yapı ve nesne eşleştirme!',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ActivityMatching()),
                    );
                  },
                  mainColor,
                ),
                _buildActivityCard(
                  context,
                  '🌦️',
                  '4. Aşama Soruları',
                  'Mevsim ve hava durumu!',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DuyguYuzEsle()),
                    );
                  },
                  mainColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String emoji,
    String title,
    String description,
    VoidCallback onTap,
    Color mainColor,
  ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      margin: const EdgeInsets.only(bottom: 22),
      color: mainColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 38)),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
