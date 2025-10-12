import 'package:flutter/material.dart';
import '../karsilastirma_az_cok/az_cok_asama1/soru1.dart';
import '../karsilastirma_kalin_ince/kalin_ince_asama1/soru1.dart';
import '../karsilastirma_uzun_kisa/soru1.dart';
import '../karsilastirma_buyuk_kucuk/soru1.dart';
import 'home_screen.dart';

class KarsilastirmaSorulariScreen extends StatelessWidget {
  const KarsilastirmaSorulariScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF6C63FF);
    const Color accentColor = Color(0xFF00C9A7);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karşılaştırma Soruları'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              mainColor.withOpacity(0.10),
              accentColor.withOpacity(0.10),
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
                  '⚖️',
                  'Az-Çok Soruları',
                  'Az ve çok kavramlarını öğren!',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AzCokSoru1(),
                      ),
                    );
                  },
                  mainColor,
                ),
                _buildActivityCard(
                  context,
                  '📏',
                  'Kalın-İnce Soruları',
                  'Kalın ve ince kavramlarını öğren!',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KalinInceSoru1(),
                      ),
                    );
                  },
                  mainColor,
                ),
                _buildActivityCard(
                  context,
                  '📐',
                  'Uzun-Kısa Soruları',
                  'Uzun ve kısa kavramlarını öğren!',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UzunKisaAgacSorusu(),
                      ),
                    );
                  },
                  mainColor,
                ),
                _buildActivityCard(
                  context,
                  '🔍',
                  'Büyük-Küçük Soruları',
                  'Büyük ve küçük kavramlarını öğren!',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BuyukKucukSoru1(),
                      ),
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
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
