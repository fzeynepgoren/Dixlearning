import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _userName = 'Kullanıcı';
  int _userAge = 10;
  String _avatar = '👦';



  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final themeProvider = Provider.of<ThemeProvider>(context);
    const Color mainColor = Color.fromARGB(255, 137, 189, 214); // Açık gök mavisi
    const Color accentColor = Color.fromARGB(255, 104, 178, 211); // Daha koyu açık mavi
    final Color cardBg = Theme.of(context).cardColor;
    final Color cardText = Theme.of(context).textTheme.bodyLarge!.color!;
    final Color cardSubText = Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey[600]!;
    final Color cardShadow = mainColor.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.10);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(FluentIcons.settings_24_regular, size: 32, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isEnglish ? 'Settings' : 'Ayarlar',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEnglish ? 'Personalize your app' : 'Uygulamanı kişiselleştir',
                          style: const TextStyle(fontSize: 13, color: Colors.white70),
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              mainColor,
              accentColor,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 100),

              // PROFİL KARTI
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
                      child: Text(_avatar, style: const TextStyle(fontSize: 36)),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: cardText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (isEnglish ? 'Age: ' : 'Yaş: ') + _userAge.toString(),
                            style: TextStyle(fontSize: 15, color: cardSubText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // BİLDİRİMLER
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
                        const Icon(FluentIcons.alert_24_regular, color: Colors.teal, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          isEnglish ? 'Notifications' : 'Bildirimler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: cardText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish ? 'Get notified about new events!' : 'Yeni etkinliklerden haberdar ol!',
                      style: TextStyle(fontSize: 13, color: cardSubText),
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

              // DİL DEĞİŞİMİ
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
                        const Icon(FluentIcons.globe_24_regular, color: Colors.teal, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          isEnglish ? 'Language' : 'Dil',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: cardText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish ? 'Switch app language' : 'Uygulama dilini değiştir',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: cardSubText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 18),
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
                            width: 110.0,
                            height: 38.0,
                            valueFontSize: 14.0,
                            toggleSize: 28.0,
                            value: isEnglish,
                            borderRadius: 20.0,
                            padding: 4.0,
                            activeColor: mainColor,
                            inactiveColor: accentColor,
                            activeText: 'English',
                            inactiveText: 'Türkçe',
                            activeTextFontWeight: FontWeight.w700,
                            inactiveTextFontWeight: FontWeight.w700,
                            showOnOff: true,
                            onToggle: (val) async {
                              await Provider.of<LanguageProvider>(context, listen: false).setLanguage(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // TEMA
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
                        Icon(FluentIcons.weather_sunny_24_regular, color: Colors.amber[700], size: 28),
                        const SizedBox(width: 10),
                        Text(
                          isEnglish ? 'Theme' : 'Tema',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: cardText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish ? 'Switch between light and dark mode' : 'Açık ve koyu mod arasında geçiş yap',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: cardSubText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 18),
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
                            width: 110.0,
                            height: 38.0,
                            valueFontSize: 14.0,
                            toggleSize: 28.0,
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
                              themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // GİZLİLİK
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
                    const Icon(FluentIcons.shield_24_regular, color: Colors.blue, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEnglish ? 'Privacy & Security' : 'Gizlilik & Güvenlik',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: cardText),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEnglish ? 'Your information is always safe!' : 'Bilgilerin güvende!',
                            style: TextStyle(fontSize: 13, color: cardSubText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ÇIKIŞ YAP
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
                child: InkWell(
                  onTap: () {
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
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                isEnglish ? 'Cancel' : 'İptal',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(isEnglish ? 'Logout' : 'Çıkış'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(FluentIcons.sign_out_24_regular, color: Colors.red, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEnglish ? 'Logout' : 'Çıkış Yap',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: cardText),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEnglish ? 'Sign out of your account' : 'Hesabınızdan çıkış yapın',
                              style: TextStyle(fontSize: 13, color: cardSubText),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Center(
                child: Text(
                  isEnglish ? 'Always safe and fun! 🎉🔒' : 'Her zaman güvenli ve eğlenceli! 🎉🔒',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.w600,
                  ),
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
