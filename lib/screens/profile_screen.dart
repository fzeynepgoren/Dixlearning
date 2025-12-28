import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double? _disleksiPercentage;
  double? _disgrafiPercentage;
  double? _diskalkuliPercentage;

  @override
  void initState() {
    super.initState();
    _loadEntryStatistics();
  }

  Future<void> _loadEntryStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _disleksiPercentage = prefs.getDouble('disleksi_first_percentage');
      _disgrafiPercentage = prefs.getDouble('disgrafi_first_percentage');
      _diskalkuliPercentage = prefs.getDouble('diskalkuli_first_percentage');
    });
  }

  Widget _buildSimpleStatCard({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
    required Color mainColor,
    required double scaleFactor,
  }) {
    return Container(
      height: 60 * scaleFactor,
      padding: EdgeInsets.symmetric(
        horizontal: 8 * scaleFactor,
        vertical: 6 * scaleFactor,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8 * scaleFactor),
        border: Border.all(
          color: isDark ? const Color(0xFF404040) : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 2 * scaleFactor,
            offset: Offset(0, 1 * scaleFactor),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: mainColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.quicksand(
                    fontSize: 10 * scaleFactor,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2 * scaleFactor),
                Text(
                  value,
                  style: GoogleFonts.quicksand(
                    fontSize: 16 * scaleFactor,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileModal(BuildContext context, bool isEnglish) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String tempName = userProvider.userName;
    String tempSurname = userProvider.userSurname;
    int tempAge = userProvider.userAge;
    String tempAvatar = userProvider.avatar;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isEnglish ? 'Edit Profile' : 'Profili Düzenle',
                          style: GoogleFonts.quicksand(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: isEnglish ? 'Name' : 'Ad',
                            labelStyle: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF4A90E2),
                              ),
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.grey[50],
                          ),
                          onChanged: (value) => tempName = value,
                          controller: TextEditingController(text: tempName),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: isEnglish ? 'Surname' : 'Soyad',
                            labelStyle: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF4A90E2),
                              ),
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.grey[50],
                          ),
                          onChanged: (value) => tempSurname = value,
                          controller: TextEditingController(text: tempSurname),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: isEnglish ? 'Age' : 'Yaş',
                            labelStyle: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF4A90E2),
                              ),
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.grey[50],
                          ),
                          keyboardType: TextInputType.number,
                          onChanged:
                              (value) =>
                                  tempAge = int.tryParse(value) ?? tempAge,
                          controller: TextEditingController(
                            text: tempAge.toString(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isEnglish ? 'Choose Avatar:' : 'Avatar Seç:',
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children:
                              ['👦', '👧', '🧑', '👨', '👩'].map((emoji) {
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      tempAvatar = emoji;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          tempAvatar == emoji
                                              ? (Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? const Color(
                                                    0xFF4A90E2,
                                                  ).withOpacity(0.3)
                                                  : Colors.blue[100])
                                              : (Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? const Color(0xFF2A2A2A)
                                                  : Colors.grey[100]),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            tempAvatar == emoji
                                                ? const Color(0xFF4A90E2)
                                                : (Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey[600]!
                                                    : Colors.grey[300]!),
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  isEnglish ? 'Cancel' : 'İptal',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[300]
                                            : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  userProvider.updateUser(
                                    name: tempName,
                                    surname: tempSurname,
                                    age: tempAge,
                                    avatar: tempAvatar,
                                  );
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A90E2),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  isEnglish ? 'Save' : 'Kaydet',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Verileri her build'de yeniden yükle (sayfa her açıldığında güncel verileri göster)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEntryStatistics();
    });

    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color mainColor = Color(0xFFB3E5FC); // Açık gök mavisi
    const Color accentColor = Color(0xFF81D4FA); // Daha koyu açık mavi

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile Summary Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? const Color(0xFF333333) : Colors.grey[200]!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(isDark ? 0.25 : 0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Large Avatar
                      GestureDetector(
                        onTap: () => _showEditProfileModal(context, isEnglish),
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors:
                                      isDark
                                          ? [
                                            const Color(0xFF4A90E2),
                                            const Color(0xFF357ABD),
                                          ]
                                          : [
                                            const Color(0xFF4A90E2),
                                            const Color(0xFF357ABD),
                                          ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4A90E2,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ),
                              ),
                            ),
                            // Edit Icon
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? const Color(0xFF4A90E2)
                                          : Colors.orange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: mediumSpacing),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userProvider.fullName,
                                style: GoogleFonts.quicksand(
                                  fontSize: 22 * scaleFactor,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color!,
                                ),
                              ),
                              SizedBox(height: 4 * scaleFactor),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16 * scaleFactor,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.grey[600],
                                  ),
                                  SizedBox(width: 6 * scaleFactor),
                                  Text(
                                    '10/2025',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 14 * scaleFactor,
                                      color:
                                          isDark
                                              ? Colors.white70
                                              : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: cardSpacing),

                // General Stats Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Container(
                    padding: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color:
                            isDark
                                ? const Color(0xFF333333)
                                : Colors.grey[200]!,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: mainColor.withOpacity(isDark ? 0.22 : 0.12),
                          blurRadius: blurRadius,
                          offset: Offset(0, shadowOffset),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Stats Header
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: mediumSpacing,
                            vertical: 8 * scaleFactor,
                          ),
                          decoration: BoxDecoration(
                            color: mainColor,
                            borderRadius: BorderRadius.circular(
                              18 * scaleFactor,
                            ),
                          ),
                          child: Text(
                            isEnglish ? 'General Stats' : 'Genel İstatistikler',
                            style: GoogleFonts.quicksand(
                              fontSize: 15 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: cardSpacing),

                        // Stats Grid - Horizontal Layout
                        Row(
                          children: [
                            Expanded(
                              child: _buildSimpleStatCard(
                                icon: Icons.flag,
                                title: isEnglish ? 'First Try' : 'İlk Deneme',
                                value: '3',
                                isDark: isDark,
                                mainColor: mainColor,
                                scaleFactor: scaleFactor,
                              ),
                            ),
                            SizedBox(width: 8 * scaleFactor),
                            Expanded(
                              child: _buildSimpleStatCard(
                                icon: Icons.local_fire_department,
                                title:
                                    isEnglish ? 'Max Streak' : 'Maksimum Seri',
                                value: '2',
                                isDark: isDark,
                                mainColor: mainColor,
                                scaleFactor: scaleFactor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8 * scaleFactor),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSimpleStatCard(
                                icon: Icons.sports_esports,
                                title: isEnglish ? 'Games Won' : 'Oyun Kazanma',
                                value: '0',
                                isDark: isDark,
                                mainColor: mainColor,
                                scaleFactor: scaleFactor,
                              ),
                            ),
                            SizedBox(width: 8 * scaleFactor),
                            Expanded(
                              child: _buildSimpleStatCard(
                                icon: Icons.emoji_events,
                                title:
                                    isEnglish ? 'Achievements' : 'Başarımlar',
                                value: '0',
                                isDark: isDark,
                                mainColor: mainColor,
                                scaleFactor: scaleFactor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: cardSpacing),

                // GİRİŞ İSTATİSTİKLERİ
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Container(
                    padding: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color:
                            isDark
                                ? const Color(0xFF333333)
                                : Colors.grey[200]!,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: mainColor.withOpacity(isDark ? 0.22 : 0.12),
                          blurRadius: blurRadius,
                          offset: Offset(0, shadowOffset),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: mediumSpacing,
                            vertical: 8 * scaleFactor,
                          ),
                          decoration: BoxDecoration(
                            color: mainColor,
                            borderRadius: BorderRadius.circular(
                              18 * scaleFactor,
                            ),
                          ),
                          child: Text(
                            isEnglish
                                ? 'Login Statistics'
                                : 'Giriş İstatistikleri',
                            style: GoogleFonts.quicksand(
                              fontSize: 15 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: cardSpacing),

                        // Stats Grid - Horizontal Layout (Boş kutular)
                        Row(
                          children: [
                            Expanded(
                              child: _buildSimpleStatCard(
                                icon: Icons.calendar_today,
                                title: '',
                                value: '-',
                                isDark: isDark,
                                mainColor: mainColor,
                                scaleFactor: scaleFactor,
                              ),
                            ),
                            SizedBox(width: 8 * scaleFactor),
                            Expanded(
                              child: _buildSimpleStatCard(
                                icon: Icons.access_time,
                                title: '',
                                value: '-',
                                isDark: isDark,
                                mainColor: mainColor,
                                scaleFactor: scaleFactor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8 * scaleFactor),
                        Row(
                          children: [
                            Text(
                              userProvider.fullName,
                              style: GoogleFonts.quicksand(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge!.color!,
                              ),
                            ),
                            SizedBox(width: 8 * scaleFactor),
                            Expanded(
                              child: _buildSimpleStatCard(
                                icon: Icons.bar_chart,
                                title: '',
                                value: '-',
                                isDark: isDark,
                                mainColor: mainColor,
                                scaleFactor: scaleFactor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: cardSpacing),

                // BİLDİRİMLER
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _notificationsExpanded = !_notificationsExpanded;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.all(cardPadding),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadiusLarge),
                        color: cardBg,
                        boxShadow: [
                          BoxShadow(
                            color: cardShadow,
                            blurRadius: blurRadius,
                            offset: Offset(0, shadowOffset),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                FluentIcons.alert_24_regular,
                                color: Colors.teal,
                                size: iconSize,
                              ),
                              SizedBox(width: smallSpacing),
                              Expanded(
                                child: Text(
                                  isEnglish ? 'Notifications' : 'Bildirimler',
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: cardText,
                                  ),
                                ),
                              ),
                              Icon(
                                _notificationsExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: cardText,
                                size: iconSize * 0.9,
                              ),
                            ],
                          ),
                          if (_notificationsExpanded) ...[
                            SizedBox(height: smallSpacing),
                            Padding(
                              padding: EdgeInsets.only(left: 38 * scaleFactor),
                              child: Text(
                                isEnglish
                                    ? 'Get notified about new events!'
                                    : 'Yeni etkinliklerden haberdar ol!',
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  color: cardSubText,
                                ),
                              ),
                            ),
                            SizedBox(height: mediumSpacing),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color:
                                      isDark
                                          ? Colors.white70
                                          : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '10/2025',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // General Stats Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? const Color(0xFF333333) : Colors.grey[200]!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(isDark ? 0.25 : 0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Stats Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isEnglish ? 'General Stats' : 'Genel İstatistikler',
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Stats Grid - Horizontal Layout
                      Row(
                        children: [
                          Row(
                            children: [
                              Icon(
                                FluentIcons.shield_24_regular,
                                color: Colors.blue,
                                size: iconSize,
                              ),
                              SizedBox(width: 14 * scaleFactor),
                              Expanded(
                                child: Text(
                                  isEnglish
                                      ? 'Privacy & Security'
                                      : 'Gizlilik & Güvenlik',
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: cardText,
                                  ),
                                ),
                              ),
                              Icon(
                                _privacyExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: cardText,
                                size: iconSize * 0.9,
                              ),
                            ],
                          ),
                          if (_privacyExpanded) ...[
                            SizedBox(height: smallSpacing),
                            Padding(
                              padding: EdgeInsets.only(left: 40 * scaleFactor),
                              child: Text(
                                isEnglish
                                    ? 'Your information is always safe!'
                                    : 'Bilgilerin güvende!',
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  color: cardSubText,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: cardSpacing),

                // ÇIKIŞ YAP
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _logoutExpanded = !_logoutExpanded;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.all(cardPadding),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadiusLarge),
                        color: cardBg,
                        boxShadow: [
                          BoxShadow(
                            color: cardShadow,
                            blurRadius: blurRadius,
                            offset: Offset(0, shadowOffset),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                FluentIcons.sign_out_24_regular,
                                color: Colors.red,
                                size: iconSize,
                              ),
                              SizedBox(width: 14 * scaleFactor),
                              Expanded(
                                child: Text(
                                  isEnglish ? 'Logout' : 'Çıkış Yap',
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: cardText,
                                  ),
                                ),
                              ),
                              Icon(
                                _logoutExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: cardText,
                                size: iconSize * 0.9,
                              ),
                            ],
                          ),
                          if (_logoutExpanded) ...[
                            SizedBox(height: smallSpacing),
                            Padding(
                              padding: EdgeInsets.only(left: 40 * scaleFactor),
                              child: Text(
                                isEnglish
                                    ? 'Sign out of your account'
                                    : 'Hesabınızdan çıkış yapın',
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  color: cardSubText,
                                ),
                              ),
                            ),
                            SizedBox(height: mediumSpacing),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          isEnglish ? 'Logout' : 'Çıkış Yap',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: Text(
                                          isEnglish
                                              ? 'Are you sure you want to logout?'
                                              : 'Çıkış yapmak istediğinizden emin misiniz?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: Text(
                                              isEnglish ? 'Cancel' : 'İptal',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              // Oturum bilgilerini temizle
                                              final prefs =
                                                  await SharedPreferences.getInstance();
                                              await prefs.setBool(
                                                'is_logged_in',
                                                false,
                                              );
                                              await prefs.remove(
                                                'current_user',
                                              );
                                              // Login ekranına yönlendir
                                              if (context.mounted) {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            const LoginScreen(),
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: Text(
                                              isEnglish ? 'Logout' : 'Çıkış',
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(isEnglish ? 'Logout' : 'Çıkış Yap'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const HomeScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  const begin = Offset(-1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const SettingsScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
