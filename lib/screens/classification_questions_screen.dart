import 'package:dixlearning/siniflama1/soru1.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../siniflama2/soru1.dart';
import '../siniflama3/soru1.dart';
import '../siniflama4/soru1.dart';

class ClassificationQuestionsScreen extends StatelessWidget {
  const ClassificationQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    const Color mainColor = Color(0xFF6C63FF);
    const Color accentColor = Color(0xFF00C9A7);

    final activities = [
      {
        'emoji': '📏',
        'title': isEnglish ? 'Stage 1 Questions' : '1.Aşama Soruları',
        'desc':
            isEnglish ? 'Long and short objects!' : 'Uzun ve kısa nesneler!',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CinsiyetEsleme()),
          );
        },
      },
      {
        'emoji': '🐱',
        'title': isEnglish ? 'Stage 2 Questions' : '2.Aşama Soruları',
        'desc':
            isEnglish
                ? 'Living and non-living things!'
                : 'Canlı ve cansız nesneler!',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MeyveSebzeEsleme()),
          );
        },
      },
      {
        'emoji': '📦',
        'title': isEnglish ? 'Stage 3 Questions' : '3.Aşama Soruları',
        'desc':
            isEnglish
                ? 'Objects by size!'
                : 'Nesneleri boyutlarına göre sınıfla!',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SekilSiniflama()),
          );
        },
      },
      {
        'emoji': '👃',
        'title': isEnglish ? 'Stage 4 Questions' : '4.Aşama Soruları',
        'desc':
            isEnglish
                ? 'Classify by sensory organs!'
                : 'Duyu organlarına göre sınıfla!',
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
                        color: mainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
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
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C63FF),
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
                      color: mainColor.withOpacity(0.5),
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
