import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _notificationsExpanded = false;
  bool _languageExpanded = false;
  bool _themeExpanded = false;
  bool _privacyExpanded = false;
  bool _logoutExpanded = false;
  
  // Giriş istatistikleri yüzdeleri
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
    
    // Tüm giriş etkinliklerinin tamamlanıp tamamlanmadığını kontrol et
    // Disleksi: disleksi1, disleksi2, disleksi4
    bool disleksi1Completed = (prefs.getInt('disleksi1_total') ?? 0) > 0;
    bool disleksi2Completed = (prefs.getInt('disleksi2_total') ?? 0) > 0;
    bool disleksi4Completed = (prefs.getInt('disleksi4_total') ?? 0) > 0;
    bool allDisleksiCompleted = disleksi1Completed && disleksi2Completed && disleksi4Completed;
    
    // Disgrafi: disgrafi1, disgrafi2, disgrafi3
    bool disgrafi1Completed = (prefs.getInt('disgrafi1_total') ?? 0) > 0;
    bool disgrafi2Completed = (prefs.getInt('disgrafi2_total') ?? 0) > 0;
    bool disgrafi3Completed = (prefs.getInt('disgrafi3_total') ?? 0) > 0;
    bool allDisgrafiCompleted = disgrafi1Completed && disgrafi2Completed && disgrafi3Completed;
    
    // Diskalkuli: diskalkuli1, diskalkuli2, diskalkuli3
    bool diskalkuli1Completed = (prefs.getInt('diskalkuli1_total') ?? 0) > 0;
    bool diskalkuli2Completed = (prefs.getInt('diskalkuli2_total') ?? 0) > 0;
    bool diskalkuli3Completed = (prefs.getInt('diskalkuli3_total') ?? 0) > 0;
    bool allDiskalkuliCompleted = diskalkuli1Completed && diskalkuli2Completed && diskalkuli3Completed;
    
    // TÜM kategoriler (Disleksi, Disgrafi, Diskalkuli) tamamlanmadan hiçbir yüzde gösterilmez
    bool allCategoriesCompleted = allDisleksiCompleted && allDisgrafiCompleted && allDiskalkuliCompleted;
    
    // Sadece tüm kategoriler tamamlandıysa ilk tamamlandığında kaydedilen yüzdeleri göster
    // Bu yüzdeler her çözümde değişmez, ilk çözümdeki başarı yüzdesini gösterir
    if (allCategoriesCompleted) {
      _disleksiPercentage = prefs.getDouble('disleksi_first_percentage');
      _disgrafiPercentage = prefs.getDouble('disgrafi_first_percentage');
      _diskalkuliPercentage = prefs.getDouble('diskalkuli_first_percentage');
    } else {
      // Tüm kategoriler tamamlanmamışsa hiçbir yüzde gösterilmez
      _disleksiPercentage = null;
      _disgrafiPercentage = null;
      _diskalkuliPercentage = null;
    }
    
    if (mounted) {
      setState(() {});
    }
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
        children: [
          Icon(icon, size: 20 * scaleFactor, color: mainColor),
          SizedBox(width: 8 * scaleFactor),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
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
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color mainColor = Color(0xFFB3E5FC); // Açık gök mavisi
    const Color accentColor = Color(0xFF81D4FA); // Daha koyu açık mavi
    final Color cardBg = Theme.of(context).cardColor;
    final Color cardText = Theme.of(context).textTheme.bodyLarge!.color!;
    final Color cardSubText =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white70
            : Colors.grey[600]!;
    final Color cardShadow = mainColor.withOpacity(
      Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.10,
    );

    // Ekran boyutuna göre ölçeklendirme (6.6 inç ekran referans: ~800 dp yükseklik)
    final screenHeight = MediaQuery.of(context).size.height;
    final refHeight = 800.0; // 6.6 inç ekran referans yüksekliği
    final scaleFactor = screenHeight / refHeight;

    // Dinamik boyutlar
    final double cardPadding = 18 * scaleFactor;
    final double horizontalPadding = 20 * scaleFactor;
    final double cardSpacing = 16 * scaleFactor;
    final double borderRadius = 20 * scaleFactor;
    final double borderRadiusLarge = 22 * scaleFactor;
    final double titleFontSize = 17 * scaleFactor;
    final double subtitleFontSize = 12.5 * scaleFactor;
    final double iconSize = 26 * scaleFactor;
    final double avatarSize = 80 * scaleFactor;
    final double avatarFontSize = 36 * scaleFactor;
    final double homeButtonSize = 50 * scaleFactor;
    final double homeIconSize = 28 * scaleFactor;
    final double blurRadius = 12 * scaleFactor;
    final double shadowOffset = 4 * scaleFactor;
    final double smallSpacing = 12 * scaleFactor;
    final double mediumSpacing = 16 * scaleFactor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Arka plan görseli
          Positioned.fill(
            child: Image.asset(
              'assets/screensphoto/profil_arkaplan.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                );
              },
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height:
                      MediaQuery.of(context).padding.top + (20 * scaleFactor),
                ),

                // Profile Summary Card
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
                    child: Row(
                      children: [
                        // Large Avatar
                        GestureDetector(
                          onTap:
                              () => _showEditProfileModal(context, isEnglish),
                          child: Stack(
                            children: [
                              Container(
                                width: avatarSize,
                                height: avatarSize,
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
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    userProvider.avatar,
                                    style: TextStyle(fontSize: avatarFontSize),
                                  ),
                                ),
                              ),
                              // Edit Icon
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 24 * scaleFactor,
                                  height: 24 * scaleFactor,
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
                                  child: Icon(
                                    Icons.edit,
                                    size: 12 * scaleFactor,
                                    color: Colors.white,
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
                        const SizedBox(height: 16),

                        // Stats Grid - Disleksi, Disgrafi, Diskalkuli
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildSimpleStatCard(
                                icon: Icons.text_fields,
                                title: isEnglish ? 'Dyslexia' : 'Disleksi',
                                value:
                                    _disleksiPercentage != null
                                        ? '${_disleksiPercentage!.toStringAsFixed(0)}%'
                                        : '-',
                                isDark: isDark,
                                mainColor: mainColor,
                                scaleFactor: scaleFactor,
                              ),
                            ),
                            SizedBox(width: 8 * scaleFactor),
                            Expanded(
                              flex: 1,
                              child: _buildSimpleStatCard(
                                icon: Icons.edit,
                                title: isEnglish ? 'Dysgraphia' : 'Disgrafi',
                                value:
                                    _disgrafiPercentage != null
                                        ? '${_disgrafiPercentage!.toStringAsFixed(0)}%'
                                        : '-',
                                isDark: isDark,
                                mainColor: mainColor,
                                scaleFactor: scaleFactor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8 * scaleFactor),
                        _buildSimpleStatCard(
                          icon: Icons.calculate,
                          title: isEnglish ? 'Dyscalculia' : 'Diskalkuli',
                          value:
                              _diskalkuliPercentage != null
                                  ? '${_diskalkuliPercentage!.toStringAsFixed(0)}%'
                                  : '-',
                          isDark: isDark,
                          mainColor: mainColor,
                          scaleFactor: scaleFactor,
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
                                Switch(
                                  value: _notificationsEnabled,
                                  activeColor: accentColor,
                                  onChanged: (value) {
                                    setState(() {
                                      _notificationsEnabled = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: cardSpacing),

                // DİL DEĞİŞİMİ
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _languageExpanded = !_languageExpanded;
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
                                FluentIcons.globe_24_regular,
                                color: Colors.teal,
                                size: iconSize,
                              ),
                              SizedBox(width: smallSpacing),
                              Expanded(
                                child: Text(
                                  isEnglish ? 'Language' : 'Dil',
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: cardText,
                                  ),
                                ),
                              ),
                              Icon(
                                _languageExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: cardText,
                                size: iconSize * 0.9,
                              ),
                            ],
                          ),
                          if (_languageExpanded) ...[
                            SizedBox(height: smallSpacing),
                            Padding(
                              padding: EdgeInsets.only(left: 38 * scaleFactor),
                              child: Text(
                                isEnglish
                                    ? 'Switch app language'
                                    : 'Uygulama dilini değiştir',
                                style: GoogleFonts.poppins(
                                  fontSize: subtitleFontSize,
                                  color: cardSubText,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            SizedBox(height: mediumSpacing),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: FlutterSwitch(
                                    width: 110.0 * scaleFactor,
                                    height: 38.0 * scaleFactor,
                                    valueFontSize: 14.0 * scaleFactor,
                                    toggleSize: 28.0 * scaleFactor,
                                    value: isEnglish,
                                    borderRadius: 20.0 * scaleFactor,
                                    padding: 4.0 * scaleFactor,
                                    activeColor: mainColor,
                                    inactiveColor: accentColor,
                                    activeText: 'English',
                                    inactiveText: 'Türkçe',
                                    activeTextFontWeight: FontWeight.w700,
                                    inactiveTextFontWeight: FontWeight.w700,
                                    showOnOff: true,
                                    onToggle: (val) async {
                                      await Provider.of<LanguageProvider>(
                                        context,
                                        listen: false,
                                      ).setLanguage(val);
                                    },
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

                SizedBox(height: cardSpacing),

                // TEMA
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _themeExpanded = !_themeExpanded;
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
                                FluentIcons.weather_sunny_24_regular,
                                color: Colors.amber[700],
                                size: iconSize,
                              ),
                              SizedBox(width: smallSpacing),
                              Expanded(
                                child: Text(
                                  isEnglish ? 'Theme' : 'Tema',
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: cardText,
                                  ),
                                ),
                              ),
                              Icon(
                                _themeExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: cardText,
                                size: iconSize * 0.9,
                              ),
                            ],
                          ),
                          if (_themeExpanded) ...[
                            SizedBox(height: smallSpacing),
                            Padding(
                              padding: EdgeInsets.only(left: 38 * scaleFactor),
                              child: Text(
                                isEnglish
                                    ? 'Switch between light and dark mode'
                                    : 'Açık ve koyu mod arasında geçiş yap',
                                style: GoogleFonts.poppins(
                                  fontSize: subtitleFontSize,
                                  color: cardSubText,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            SizedBox(height: mediumSpacing),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      20 * scaleFactor,
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2 * scaleFactor,
                                    ),
                                  ),
                                  child: FlutterSwitch(
                                    width: 110.0 * scaleFactor,
                                    height: 38.0 * scaleFactor,
                                    valueFontSize: 14.0 * scaleFactor,
                                    toggleSize: 28.0 * scaleFactor,
                                    value: themeProvider.isDark,
                                    borderRadius: 20.0,
                                    padding: 4.0,
                                    activeColor: mainColor,
                                    inactiveColor: accentColor,
                                    activeText: isEnglish ? 'Dark' : 'Koyu',
                                    inactiveText: isEnglish ? 'Light' : 'Açık',
                                    activeTextFontWeight: FontWeight.w700,
                                    inactiveTextFontWeight: FontWeight.w700,
                                    showOnOff: true,
                                    onToggle: (val) {
                                      themeProvider.setThemeMode(
                                        val ? ThemeMode.dark : ThemeMode.light,
                                      );
                                    },
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

                SizedBox(height: cardSpacing),

                // GİZLİLİK
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _privacyExpanded = !_privacyExpanded;
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
                Center(
                  child: Text(
                    'V1.0',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
          // Sağ üstte anasayfa butonu
          Positioned(
            top: MediaQuery.of(context).padding.top + (10 * scaleFactor),
            right: horizontalPadding,
            child: GestureDetector(
              onTap: () {
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
              },
              child: Container(
                width: homeButtonSize,
                height: homeButtonSize,
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? Colors.white.withOpacity(0.15)
                          : Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8 * scaleFactor,
                      offset: Offset(0, 2 * scaleFactor),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.home,
                  color: isDark ? Colors.white : const Color(0xFF4A90E2),
                  size: homeIconSize * 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
