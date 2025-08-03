import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  final void Function(ThemeMode)? onThemeChanged;
  final ThemeMode? themeMode;
  final void Function(bool isEnglish)? onLanguageChanged;
  final bool? isEnglish;
  const SettingsScreen(
      {super.key,
      this.onThemeChanged,
      this.themeMode,
      this.onLanguageChanged,
      this.isEnglish});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  final bool _isEditingProfile = false;
  String _userName = 'Kullanıcı';
  int _userAge = 10;
  String _avatar = '👦';

  void _showEditProfileModal(BuildContext context, bool isEnglish) {
    String tempName = _userName;
    int tempAge = _userAge;
    String tempAvatar = _avatar;
    final avatars = ['👦', '👧', '🧑', '🧒'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEnglish ? 'Edit Profile' : 'Profili Düzenle',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: avatars
                    .map((avatar) => GestureDetector(
                          onTap: () {
                            tempAvatar = avatar;
                            // Modal rebuild
                            (context as Element).markNeedsBuild();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: tempAvatar == avatar
                                    ? const Color(0xFF6C63FF)
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: Text(avatar,
                                style: const TextStyle(fontSize: 36)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  labelText: isEnglish ? 'Name' : 'Ad',
                  border: const OutlineInputBorder(),
                ),
                controller: TextEditingController(text: tempName),
                onChanged: (val) => tempName = val,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: isEnglish ? 'Age' : 'Yaş',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: tempAge.toString()),
                onChanged: (val) => tempAge = int.tryParse(val) ?? tempAge,
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _userName = tempName;
                    _userAge = tempAge;
                    _avatar = tempAvatar;
                  });
                  Navigator.pop(context);
                },
                child: Text(isEnglish ? 'Save' : 'Kaydet'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEnglish != widget.isEnglish) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color mainColor = Color(0xFF6C63FF);
    const Color accentColor = Color(0xFF00C9A7);
    final Color cardBg = isDark ? const Color(0xFF232946) : Colors.white;
    final Color cardText = isDark ? Colors.white : Colors.black;
    final Color cardSubText = isDark ? Colors.white70 : Colors.grey[600]!;
    final Color cardShadow = mainColor.withOpacity(isDark ? 0.25 : 0.10);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
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
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(FluentIcons.settings_24_regular,
                          size: 32, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isEnglish ? 'Settings' : 'Ayarlar',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(
                            isEnglish
                                ? 'Personalize your app'
                                : 'Uygulamanı kişiselleştir',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.white70)),
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              mainColor.withOpacity(0.08),
              accentColor.withOpacity(0.08)
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 100),
              // Profile Card
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: cardBg,
                  boxShadow: [
                    BoxShadow(
                      color: cardShadow,
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: accentColor.withOpacity(0.15),
                      child:
                          Text(_avatar, style: const TextStyle(fontSize: 36)),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_userName,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            (isEnglish ? 'Age: ' : 'Yaş: ') +
                                _userAge.toString(),
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showEditProfileModal(context, isEnglish),
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text(isEnglish ? 'Edit' : 'Düzenle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              // Notification Card
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: cardBg,
                  boxShadow: [
                    BoxShadow(
                      color: cardShadow,
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(FluentIcons.alert_24_regular,
                            color: Colors.teal, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          isEnglish ? 'Notifications' : 'Bildirimler',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish
                          ? 'Get notified about new events!'
                          : 'Yeni etkinliklerden haberdar ol!',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 18),
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
                ),
              ),
              // Language Card
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: cardBg,
                  boxShadow: [
                    BoxShadow(
                      color: cardShadow,
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(FluentIcons.globe_24_regular,
                            color: Colors.teal, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          isEnglish ? 'Language' : 'Dil',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish
                          ? 'Switch app language'
                          : 'Uygulama dilini değiştir',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FlutterSwitch(
                          width: 110.0,
                          height: 38.0,
                          valueFontSize: 14.0,
                          toggleSize: 28.0,
                          value: isEnglish,
                          borderRadius: 20.0,
                          padding: 4.0,
                          activeColor: Colors.teal,
                          inactiveColor: Colors.grey[300]!,
                          activeText: 'English',
                          inactiveText: 'Türkçe',
                          activeTextFontWeight: FontWeight.w700,
                          inactiveTextFontWeight: FontWeight.w700,
                          showOnOff: true,
                          onToggle: (val) async {
                            await Provider.of<LanguageProvider>(context,
                                    listen: false)
                                .setLanguage(val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Theme Card
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: cardBg,
                  boxShadow: [
                    BoxShadow(
                      color: cardShadow,
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(FluentIcons.weather_sunny_24_regular,
                            color: Colors.amber[700], size: 28),
                        const SizedBox(width: 10),
                        Text(
                          isEnglish ? 'Theme' : 'Tema',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish
                          ? 'Switch between light and dark mode'
                          : 'Açık ve koyu mod arasında geçiş yap',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Switch(
                          value: isDark,
                          activeColor: mainColor,
                          onChanged: (val) {
                            if (widget.onThemeChanged != null) {
                              widget.onThemeChanged!(
                                  val ? ThemeMode.dark : ThemeMode.light);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isDark
                              ? (isEnglish ? 'Dark' : 'Koyu')
                              : (isEnglish ? 'Light' : 'Açık'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.deepPurple : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Privacy Card
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: cardBg,
                  boxShadow: [
                    BoxShadow(
                      color: cardShadow,
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(FluentIcons.shield_24_regular,
                        color: Colors.blue, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEnglish
                                ? 'Privacy & Security'
                                : 'Gizlilik & Güvenlik',
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEnglish
                                ? 'Your information is always safe!'
                                : 'Bilgilerin güvende!',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  isEnglish
                      ? 'Always safe and fun! 🎉🔒'
                      : 'Her zaman güvenli ve eğlenceli! 🎉🔒',
                  style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          }
        },
        mainColor: mainColor,
        accentColor: accentColor,
        isEnglish: isEnglish,
      ),
    );
  }
}
