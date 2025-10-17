import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'giris_etkinlikleri_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'matching_questions_screen.dart';
import 'classification_questions_screen.dart';
import 'karsilastirma_sorulari_screen.dart';
import 'login_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'sorting_activities_screen.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 1; // Home is selected by default
  int _completedToday = 0; // Dinamik etkinlik sayısı
  String _currentUserEmail = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTodayActivities();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Uygulama geri geldiğinde sayacı yenile
      _loadTodayActivities();
    }
  }

  void _loadTodayActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? currentUserJson = prefs.getString('current_user');

      if (currentUserJson != null) {
        final currentUser = Map<String, dynamic>.from(
          json.decode(currentUserJson),
        );
        _currentUserEmail = currentUser['email'] ?? '';

        // Bugünün tarihini al
        final today = DateTime.now();
        final todayKey = '${today.year}-${today.month}-${today.day}';
        final userActivityKey = '${_currentUserEmail}_activities_$todayKey';
        final lastDateKey = '${_currentUserEmail}_last_activity_date';

        // Son etkinlik tarihini kontrol et
        final lastDate = prefs.getString(lastDateKey);

        if (lastDate != null && lastDate != todayKey) {
          // Farklı bir gün, sayacı sıfırla
          await prefs.setInt(userActivityKey, 0);
        }

        // Son etkinlik tarihini güncelle
        await prefs.setString(lastDateKey, todayKey);

        // Bugünkü etkinlik sayısını al
        final todayActivities = prefs.getInt(userActivityKey) ?? 0;

        setState(() {
          _completedToday = todayActivities;
        });
      }
    } catch (e) {
      print('Error loading today activities: $e');
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => const ProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  void _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      await prefs.remove('current_user');

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Logout failed: $e');
    }
  }

  void _navigateToActivity(Widget screen) {
    // Etkinliğe git
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Widget _buildProgressItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _getCurrentStreak() {
    // Basit streak hesaplama - gerçek uygulamada SharedPreferences'tan alınabilir
    return _completedToday > 0 ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    const Color mainColor = Color(0xFFB3E5FC); // Açık gök mavisi
    const Color accentColor = Color(0xFF81D4FA); // Daha koyu açık mavi
    const Color yellowColor = Color(0xFFFFD700); // Altın sarı
    const Color orangeColor = Color(0xFFFF8C00); // Turuncu
    const String userName =
        'Kullanıcı'; // (isteğe bağlı: ayarlardan alınabilir)
    const String avatar = '👦'; // (isteğe bağlı: ayarlardan alınabilir)
    final activities = [
      {
        'emoji': '🎲',
        'icon': Icons.casino,
        'title': isEnglish ? 'Entry Activities' : 'Giriş Etkinlikleri',
        'color': const Color(0xFFFFD700), // Altın sarı
        'textColor': Colors.white,
        'desc':
            isEnglish
                ? 'Warm-up games and fun!'
                : 'Isınma oyunları ve eğlence!',
        'onTap': () {
          _navigateToActivity(const GirisEtkinlikleriScreen());
        },
      },
      {
        'emoji': '🔗',
        'icon': Icons.link,
        'title': isEnglish ? 'Matching Questions' : 'Eşleme Soruları',
        'color': const Color(0xFF8C64F0), // Orta mor
        'textColor': Colors.white,
        'desc':
            isEnglish
                ? 'Test your matching skills!'
                : 'Eşleştirme becerilerini test et!',
        'onTap': () {
          _navigateToActivity(const MatchingQuestionsScreen());
        },
      },
      {
        'emoji': '🧩',
        'icon': Icons.extension,
        'title': isEnglish ? 'Classification Questions' : 'Sınıflama Soruları',
        'color': const Color(0xFF4ECDC4), // Turkuaz
        'textColor': Colors.white,
        'desc':
            isEnglish
                ? 'Test your classification skills!'
                : 'Sınıflandırma becerilerini test et!',
        'onTap': () {
          _navigateToActivity(const ClassificationQuestionsScreen());
        },
      },
      {
        'emoji': '⚖️',
        'icon': Icons.balance,
        'title':
            isEnglish ? 'Comparison Activities' : 'Karşılaştırma Etkinlikleri',
        'color': const Color(0xFFFF8C3C), // Turuncu
        'textColor': Colors.white,
        'desc':
            isEnglish
                ? 'Learn comparison concepts!'
                : 'Karşılaştırma kavramlarını öğren!',
        'onTap': () {
          _navigateToActivity(const KarsilastirmaSorulariScreen());
        },
      },
      {
        'emoji': '⏫',
        'icon': Icons.sort,
        'title': isEnglish ? 'Sorting Activities' : 'Sıralama Etkinlikleri',
        'color': const Color(0xFFF06491), // Pembe
        'textColor': Colors.white,
        'desc':
            isEnglish
                ? 'Test your sorting skills!'
                : 'Sıralama becerilerini test et!',
        'onTap': () {
          _navigateToActivity(const SortingActivitiesScreen());
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  Theme.of(context).brightness == Brightness.dark
                      ? [
                        const Color(0xFF1E1E1E), // Dark grey
                        const Color(0xFF121212), // Darker grey
                      ]
                      : [
                        const Color.fromARGB(255, 137, 189, 214),
                        const Color.fromARGB(255, 104, 178, 211),
                      ],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 10),
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
                  // Günlük İlerleme Kartı
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isEnglish
                                        ? 'Daily Progress'
                                        : 'Günlük İlerleme',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    isEnglish
                                        ? 'Keep learning every day! 🌟'
                                        : 'Her gün öğrenmeye devam et! 🌟',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildProgressItem(
                                isEnglish ? 'Completed' : 'Tamamlanan',
                                _completedToday.toString(),
                                Icons.check_circle,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildProgressItem(
                                isEnglish ? 'Streak' : 'Seri',
                                _getCurrentStreak().toString(),
                                Icons.local_fire_department,
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildProgressItem(
                                isEnglish ? 'Points' : 'Puan',
                                (_completedToday * 50).toString(),
                                Icons.star,
                                Colors.yellow,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Activities Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return _AnimatedActivityCard(
                        emoji: activity['emoji'] as String,
                        icon: activity['icon'] as IconData,
                        title: activity['title'] as String,
                        desc: activity['desc'] as String,
                        onTap: activity['onTap'] as VoidCallback,
                        cardColor: activity['color'] as Color,
                        mainColor: mainColor,
                        accentColor: accentColor,
                      );
                    },
                  ),
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
  final IconData icon;
  final String title;
  final String desc;
  final VoidCallback onTap;
  final Color cardColor;
  final Color mainColor;
  final Color accentColor;
  const _AnimatedActivityCard({
    required this.emoji,
    required this.icon,
    required this.title,
    required this.desc,
    required this.onTap,
    required this.cardColor,
    required this.mainColor,
    required this.accentColor,
  });

  @override
  State<_AnimatedActivityCard> createState() => _AnimatedActivityCardState();
}

class _AnimatedActivityCardState extends State<_AnimatedActivityCard>
    with TickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isHovered ? _pulseAnimation.value : 1.0,
              child: Container(
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  color: widget.cardColor,
                  border: Border.all(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[600]!
                            : Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: widget.cardColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Emoji ve ikon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Icon(widget.icon, color: Colors.white, size: 24),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Başlık
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
