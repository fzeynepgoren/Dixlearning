import 'package:dixlearning/siniflama1/soru1.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../siniflama2/soru1.dart';
import '../siniflama3/soru1.dart';
import '../siniflama4/soru1.dart';
import 'home_screen.dart';

class ClassificationQuestionsScreen extends StatelessWidget {
  const ClassificationQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final Color mainColor = const Color(0xFF6C63FF);
    final Color accentColor = const Color(0xFF00C9A7);

    final activities = [
      {
        'emoji': '🌍',
        'title':
            isEnglish ? 'Stage 1 - Earth Planet' : '1.Aşama - Dünya Gezegeni',
        'desc':
            isEnglish ? 'Long and short objects!' : 'Uzun ve kısa nesneler!',
        'planetColor': const Color(0xFF4CAF50), // Yeşil-mavi Dünya
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CinsiyetEsleme()),
          );
        },
      },
      {
        'emoji': '🪐',
        'title':
            isEnglish ? 'Stage 2 - Ring Planet' : '2.Aşama - Halkalı Gezegen',
        'desc':
            isEnglish
                ? 'Living and non-living things!'
                : 'Canlı ve cansız nesneler!',
        'planetColor': const Color(0xFF9C27B0), // Mor-pembe halkalı gezegen
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MeyveSebzeEsleme()),
          );
        },
      },
      {
        'emoji': '🪐',
        'title':
            isEnglish ? 'Stage 3 - Saturn Planet' : '3.Aşama - Satürn Gezegeni',
        'desc':
            isEnglish
                ? 'Objects by size!'
                : 'Nesneleri boyutlarına göre sınıfla!',
        'planetColor': const Color(0xFFFF9800), // Sarı-turuncu Satürn
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SekilSiniflama()),
          );
        },
      },
      {
        'emoji': '🪐',
        'title': isEnglish ? 'Stage 4 - Giant Planet' : '4.Aşama - Dev Gezegen',
        'desc':
            isEnglish
                ? 'Classify by sensory organs!'
                : 'Duyu organlarına göre sınıfla!',
        'planetColor': const Color(0xFF673AB7), // Mor-mavi dev gezegen
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DuyguSiniflama()),
          );
        },
      },
      {
        'emoji': '🌌',
        'title':
            isEnglish ? 'Stage 5 - Nebula Planet' : '5.Aşama - Nebula Gezegeni',
        'desc':
            isEnglish ? 'Advanced classification!' : 'İleri seviye sınıflama!',
        'planetColor': const Color(0xFFE91E63), // Pembe-beyaz nebula
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DuyguSiniflama()),
          );
        },
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Classification Activities' : 'Sınıflama Etkinlikleri',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: mainColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Ana ekrana dön
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              onTap: activity['onTap'] as VoidCallback,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      mainColor.withOpacity(0.1),
                      accentColor.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: (activity['planetColor'] as Color).withOpacity(
                          0.2,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: activity['planetColor'] as Color,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          activity['emoji'] as String,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['title'] as String,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: activity['planetColor'] as Color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activity['desc'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: (activity['planetColor'] as Color).withOpacity(
                        0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
