import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // ← EKLENDİ
import 'providers/language_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;

    return MaterialApp(
      title: 'DixLearning',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        textTheme: GoogleFonts.quicksandTextTheme(), // ← Quicksand fontu burada
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          titleTextStyle: GoogleFonts.quicksand(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigoAccent,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.quicksand(fontSize: 18),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.quicksandTextTheme(), // ← Karanlık tema için de
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black87,
          titleTextStyle: GoogleFonts.quicksand(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardColor: Colors.grey[800],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.quicksand(fontSize: 18),
          ),
        ),
      ),
      themeMode: _themeMode,
      home: LoginScreen(
        onThemeChanged: _setThemeMode,
        themeMode: _themeMode,
      ),
      routes: {
        '/home': (context) => HomeScreen(
          onThemeChanged: _setThemeMode,
          themeMode: _themeMode,
        ),
      },
    );
  }
}
