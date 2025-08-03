import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../asama1/soru1.dart';
import '../asama2/soru1.dart';
import '../asama3/soru1.dart';
import '../asama4/soru1.dart';

class MatchingQuestionsScreen extends StatelessWidget {
  const MatchingQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    const Color mainColor = Color(0xFF6C63FF);
    const Color accentColor = Color(0xFF00C9A7);

    final activities = [
      {
        'emoji': '🍎',
        'title': isEnglish ? 'Stage 1 Questions' : '1.Aşama Soruları',
        'desc': isEnglish
            ? 'Fruit matching and more!'
            : 'Meyve eşleştirme ve fazlası!',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MeyveEsle(),
            ),
          );
        },
      },
      {
        'emoji': '🔤',
        'title': isEnglish ? 'Stage 2 Questions' : '2.Aşama Soruları',
        'desc': isEnglish
            ? 'Letter games and puzzles!'
            : 'Harf oyunları ve bulmacalar!',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Soru1(),
            ),
          );
        },
      },
      {
        'emoji': '🏛️',
        'title': isEnglish ? 'Stage 3 Questions' : '3.Aşama Soruları',
        'desc':
            isEnglish ? 'Structures and objects!' : 'Yapı ve nesne eşleştirme!',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ActivityMatching(),
            ),
          );
        },
      },
      {
        'emoji': '🌦️',
        'title': isEnglish ? 'Stage 4 Questions' : '4.Aşama Soruları',
        'desc': isEnglish ? 'Seasons and weather!' : 'Mevsim ve hava durumu!',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DuyguYuzEsle(),
            ),
          );
        },
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Matching Questions' : 'Eşleme Soruları',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              onTap: activity['onTap'] as VoidCallback,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [mainColor, accentColor],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          activity['emoji'] as String,
                          style: const TextStyle(fontSize: 30),
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
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity['desc'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
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
