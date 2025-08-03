import 'package:flutter/material.dart';
import 'giris_etkinlikleri_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'matching_questions_screen.dart';
import 'classification_questions_screen.dart';
import 'karsilastirma_sorulari_screen.dart';
import '../giris_etkinlikleri/disleksi1.dart';
import '../giris_etkinlikleri/disleksi2.dart';
import '../giris_etkinlikleri/disleksi4.dart';
import '../giris_etkinlikleri/disgrafi2.dart';
import '../giris_etkinlikleri/diskalkuli3.dart';
import '../giris_etkinlikleri/disgrafi3.dart';
import '../giris_etkinlikleri/diskalkuli1.dart';
import '../asama1/soru1.dart';
import '../asama2/soru1.dart';
import '../asama3/soru1.dart';
import '../asama4/soru1.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'sorting_activities_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(ThemeMode)? onThemeChanged;
  final ThemeMode? themeMode;
  final bool? isEnglish;
  final void Function(bool isEnglish)? onLanguageChanged;
  const HomeScreen(
      {super.key,
      this.onThemeChanged,
      this.themeMode,
      this.isEnglish,
      this.onLanguageChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Home is selected by default

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SettingsScreen(
            onThemeChanged: widget.onThemeChanged,
            themeMode: widget.themeMode,
            isEnglish: widget.isEnglish,
            onLanguageChanged: widget.onLanguageChanged,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    const Color mainColor = Color(0xFF6C63FF);
    const Color accentColor = Color(0xFF00C9A7);
    const String userName =
        'Kullanıcı'; // (isteğe bağlı: ayarlardan alınabilir)
    const String avatar = '👦'; // (isteğe bağlı: ayarlardan alınabilir)
    const int completedToday = 2; // (dummy, ileride state ile)
    final activities = [
      {
        'emoji': '🎲',
        'title': isEnglish ? 'Entry Activities' : 'Giriş Etkinlikleri',
        'desc': isEnglish
            ? 'Warm-up games and fun!'
            : 'Isınma oyunları ve eğlence!',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GirisEtkinlikleriScreen(
                isEnglish: isEnglish,
                onLanguageChanged: widget.onLanguageChanged,
              ),
            ),
          );
        },
      },
      {
        'emoji': '🎯',
        'title': isEnglish ? 'Matching Questions' : 'Eşleme Soruları',
        'desc': isEnglish
            ? 'Test your matching skills!'
            : 'Eşleştirme becerilerini test et!',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MatchingQuestionsScreen(),
            ),
          );
        },
      },
      {
        'emoji': '📋',
        'title': isEnglish ? 'Classification Questions' : 'Sınıflama Soruları',
        'desc': isEnglish
            ? 'Test your classification skills!'
            : 'Sınıflandırma becerilerini test et!',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ClassificationQuestionsScreen(),
            ),
          );
        },
      },
      {
        'emoji': '⚖️',
        'title':
            isEnglish ? 'Comparison Activities' : 'Karşılaştırma Etkinlikleri',
        'desc': isEnglish
            ? 'Learn comparison concepts!'
            : 'Karşılaştırma kavramlarını öğren!',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const KarsilastirmaSorulariScreen(),
            ),
          );
        },
      },
      {
        'emoji': '🔢',
        'title': isEnglish ? 'Sorting Activities' : 'Sıralama Etkinlikleri',
        'desc': isEnglish
            ? 'Test your sorting skills!'
            : 'Sıralama becerilerini test et!',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SortingActivitiesScreen(),
            ),
          );
        },
      },
    ];

    return WillPopScope(
      onWillPop: () async {
        setState(() {
          _selectedIndex = 1; // Reset to home when back button is pressed
        });
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [mainColor, accentColor],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(Icons.home,
                            size: 40, color: Colors.white),
                      ),
                      const SizedBox(width: 18),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isEnglish ? 'Home' : 'Ana Sayfa',
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEnglish
                                ? 'Start activities!'
                                : 'Etkinliklere başla!',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 120),
                  // Greeting Card (removed)
                  // Card(
                  //   elevation: 6,
                  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  //   color: mainColor,
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  //     child: Row(
                  //       children: [
                  //         CircleAvatar(
                  //           radius: 32,
                  //           backgroundColor: Colors.white,
                  //           child: Text(avatar, style: const TextStyle(fontSize: 36)),
                  //         ),
                  //         const SizedBox(width: 18),
                  //         Expanded(
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Text(
                  //                 isEnglish ? 'Welcome, $userName!' : 'Hoş geldin, $userName!',
                  //                 style: const TextStyle(
                  //                   fontSize: 22,
                  //                   fontWeight: FontWeight.bold,
                  //                   color: Colors.white,
                  //                 ),
                  //               ),
                  //               const SizedBox(height: 6),
                  //               Text(
                  //                 isEnglish
                  //                   ? "Let's have fun and learn! 🎉"
                  //                   : "Haydi eğlen ve öğren! 🎉",
                  //                 style: const TextStyle(fontSize: 15, color: Colors.white70),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         const Text('✨', style: TextStyle(fontSize: 32)),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 24),
                  // Daily Progress
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    color: accentColor.withOpacity(0.85),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events,
                              color: Colors.white, size: 32),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              isEnglish
                                  ? 'You completed $completedToday activities today!'
                                  : 'Bugün $completedToday etkinlik tamamladın!',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Activities
                  ...activities.map((activity) => _AnimatedActivityCard(
                        emoji: activity['emoji'] as String,
                        title: activity['title'] as String,
                        desc: activity['desc'] as String,
                        onTap: activity['onTap'] as VoidCallback,
                        mainColor: mainColor,
                        accentColor: accentColor,
                      )),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          mainColor: mainColor,
          accentColor: accentColor,
          isEnglish: isEnglish,
        ),
      ),
    );
  }
}

class _AnimatedActivityCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String desc;
  final VoidCallback onTap;
  final Color mainColor;
  final Color accentColor;
  const _AnimatedActivityCard({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.onTap,
    required this.mainColor,
    required this.accentColor,
  });

  @override
  State<_AnimatedActivityCard> createState() => _AnimatedActivityCardState();
}

class _AnimatedActivityCardState extends State<_AnimatedActivityCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  final bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          margin: const EdgeInsets.only(bottom: 22),
          color: widget.mainColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            child: Row(
              children: [
                Text(widget.emoji, style: const TextStyle(fontSize: 38)),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.desc,
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
      ),
    );
  }
}
