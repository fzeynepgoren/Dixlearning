import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home_screen.dart';
import 'register_screen.dart';

class MascotDialog extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  final String assetPath;
  const MascotDialog({
    super.key,
    required this.message,
    required this.onClose,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.55),
      child: InkWell(
        onTap: onClose,
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mascotSize = constraints.maxWidth * 0.38;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Maskot
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.25),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      assetPath,
                      height: mascotSize,
                      width: mascotSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Konuşma balonu
                  Container(
                    width: constraints.maxWidth * 0.8,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.10),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                          color: Colors.indigoAccent.withOpacity(0.12),
                          width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            color: Colors.indigo[900],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onClose,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigoAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              'Tamam',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class CloudBubble extends StatelessWidget {
  final String text;
  const CloudBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.95;
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/konusma_balonu.png',
            width: maxWidth,
            fit: BoxFit.contain,
          ),
          Container(
            width: maxWidth * 1.0, // Balonun iç kısmına göre daha büyük
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.indigo[900],
                fontWeight: FontWeight.w600,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: 5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final path = Path();
    // Bulutun ana gövdesi
    path.moveTo(size.width * 0.2, size.height * 0.7);
    path.quadraticBezierTo(0, size.height * 0.7, 0, size.height * 0.4);
    path.quadraticBezierTo(0, 0, size.width * 0.4, 0);
    path.quadraticBezierTo(
        size.width * 0.45, -size.height * 0.18, size.width * 0.65, 0.0);
    path.quadraticBezierTo(size.width, 0, size.width, size.height * 0.4);
    path.quadraticBezierTo(
        size.width, size.height * 0.7, size.width * 0.8, size.height * 0.7);
    path.quadraticBezierTo(
        size.width * 0.7, size.height, size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(
        size.width * 0.3, size.height, size.width * 0.2, size.height * 0.7);
    canvas.drawShadow(path, Colors.black26, 8, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MascotBottomSheet extends StatefulWidget {
  final String message;
  final String assetPath;
  final VoidCallback onDismiss;
  const MascotBottomSheet(
      {super.key,
      required this.message,
      required this.assetPath,
      required this.onDismiss});

  @override
  State<MascotBottomSheet> createState() => _MascotBottomSheetState();
}

class _MascotBottomSheetState extends State<MascotBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _offsetAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mascotSize = MediaQuery.of(context).size.width * 1.5;
    final visibleHeight = mascotSize * 0.1;
    return Positioned.fill(
      child: GestureDetector(
        onTap: _dismiss,
        child: Container(
          color: Colors.black.withOpacity(0.35),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: _offsetAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: visibleHeight *
                                0.1), // balonu maskota çok daha yakınlaştır
                        child: CloudBubble(text: widget.message),
                      ),
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            height: visibleHeight,
                          ),
                          ClipRect(
                            child: Align(
                              alignment: Alignment.topCenter,
                              heightFactor: 0.6, // Sadece üst kısmı göster
                              child: Image.asset(
                                widget.assetPath,
                                height: mascotSize,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final void Function(ThemeMode)? onThemeChanged;
  final ThemeMode? themeMode;
  final bool? isEnglish;
  final void Function(bool isEnglish)? onLanguageChanged;

  const LoginScreen({
    super.key,
    this.onThemeChanged,
    this.themeMode,
    this.isEnglish,
    this.onLanguageChanged,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showMascot = false;
  String _mascotMessage = '';

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    _checkAutoLogin();
    // Show mascot on first open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _showMascot = true;
        _mascotMessage = widget.isEnglish == true
            ? 'Hello my friend, I am Dixy.\nWelcome!'
            : 'Merhaba dostum, ben Dixy.\nHoş geldin!';
      });
    });
  }

  void _checkAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final String? currentUser = prefs.getString('current_user');
      
      if (isLoggedIn && currentUser != null && mounted) {
        // Kullanıcı zaten giriş yapmış, ana ekrana yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              onThemeChanged: widget.onThemeChanged,
              themeMode: widget.themeMode,
              isEnglish: widget.isEnglish,
              onLanguageChanged: widget.onLanguageChanged,
            ),
          ),
        );
      }
    } catch (e) {
      // Hata durumunda normal giriş ekranında kal
      print('Auto login check failed: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = null;
    });
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // SharedPreferences'ten kayıtlı kullanıcıları al
        final prefs = await SharedPreferences.getInstance();
        final String? usersJson = prefs.getString('registered_users');
        
        if (usersJson == null) {
          setState(() {
            _errorMessage = widget.isEnglish == true
                ? "No registered users found. Please register first."
                : "Kayıtlı kullanıcı bulunamadı. Lütfen önce kayıt olun.";
            _isLoading = false;
          });
          return;
        }
        
        List<Map<String, dynamic>> users = List<Map<String, dynamic>>.from(json.decode(usersJson));
        
        // Kullanıcıyı bul
        Map<String, dynamic>? user = users.firstWhere(
          (user) => user['email'] == _emailController.text.trim() && user['password'] == _passwordController.text,
          orElse: () => {},
        );
        
        if (user.isEmpty) {
          setState(() {
            _errorMessage = widget.isEnglish == true
                ? "Invalid email or password"
                : "Geçersiz e-posta veya şifre";
            _isLoading = false;
          });
          return;
        }
        
        // Giriş başarılı - kullanıcı bilgilerini kaydet
        await prefs.setString('current_user', json.encode(user));
        await prefs.setBool('is_logged_in', true);
        
        // Ana ekrana yönlendir
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                onThemeChanged: widget.onThemeChanged,
                themeMode: widget.themeMode,
                isEnglish: widget.isEnglish,
                onLanguageChanged: widget.onLanguageChanged,
              ),
            ),
          );
        }
        
      } catch (e) {
        setState(() {
          _errorMessage = widget.isEnglish == true
              ? "An error occurred. Please try again."
              : "Bir hata oluştu. Lütfen tekrar deneyin.";
        });
      }
      
      setState(() {
        _isLoading = false;
      });
    } else {
      // If form is not valid, and user tries to login without registering
      if ((_emailController.text.isEmpty || _passwordController.text.isEmpty)) {
        setState(() {
          _showMascot = true;
          _mascotMessage = widget.isEnglish == true
              ? "I see you haven't registered yet. You can register using the button below before logging in."
              : "Henüz kayıt olmadığını görüyorum. Kayıt ol butonundan kayıt olduktan sonra giriş yapabilirsin.";
        });
      }
    }
  }

  void _closeMascot() {
    setState(() {
      _showMascot = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = widget.isEnglish == true;
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                // Background gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFA7C7E7),
                        Color(0xFFB5EAD7),
                        Color(0xFFFFFACD)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.97),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 18,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo or Icon
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.indigo[100],
                              child: Icon(Icons.school,
                                  size: 40, color: Colors.indigo[700]),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'DixLearning',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: Colors.indigoAccent,
                              ),
                            ),
                            const SizedBox(height: 28),
                            // Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.poppins(
                                fontSize: 19,
                                color: Colors.indigo[900],
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: isEnglish ? 'Email' : 'E-posta',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.indigo[400],
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: const Icon(Icons.email,
                                    color: Colors.indigo),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.red[600],
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return isEnglish
                                      ? 'Please enter your email'
                                      : 'Lütfen e-posta girin';
                                }
                                if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}")
                                    .hasMatch(value)) {
                                  return isEnglish
                                      ? 'Enter a valid email'
                                      : 'Geçerli bir e-posta girin';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.poppins(
                                fontSize: 19,
                                color: Colors.indigo[900],
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: isEnglish ? 'Password' : 'Şifre',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.indigo[400],
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: const Icon(Icons.lock,
                                    color: Colors.indigo),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.indigo),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.red[600],
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return isEnglish
                                      ? 'Please enter your password'
                                      : 'Lütfen şifrenizi girin';
                                }
                                if (value.length < 6) {
                                  return isEnglish
                                      ? 'Password must be at least 6 characters'
                                      : 'Şifre en az 6 karakter olmalı';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            if (_errorMessage != null) ...[
                              Text(
                                _errorMessage!,
                                style: GoogleFonts.poppins(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            // Gradient Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                onPressed: _isLoading ? null : _login,
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6C63FF),
                                        Color(0xFF00C9A7)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            isEnglish ? 'Login' : 'Giriş Yap',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Register link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isEnglish
                                      ? "Don't have an account? "
                                      : 'Hesabın yok mu? ',
                                  style: GoogleFonts.poppins(
                                    color: Colors.indigo[800],
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterScreen()),
                                    );
                                  },
                                  child: Text(
                                    isEnglish ? 'Register' : 'Kayıt ol',
                                    style: GoogleFonts.poppins(
                                      color: Colors.teal[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      decoration: TextDecoration.underline,
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
                ),
              ],
            ),
          ),
          if (_showMascot)
            MascotBottomSheet(
              message: _mascotMessage,
              assetPath: 'assets/erkek_maskot.png',
              onDismiss: _closeMascot,
            ),
        ],
      ),
    );
  }
}
