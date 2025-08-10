import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  final bool? isEnglish;
  final void Function(bool isEnglish)? onLanguageChanged;
  const RegisterScreen({super.key, this.isEnglish, this.onLanguageChanged});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
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
        List<Map<String, dynamic>> users = [];
        
        if (usersJson != null) {
          users = List<Map<String, dynamic>>.from(json.decode(usersJson));
        }
        
        // Email'in zaten kayıtlı olup olmadığını kontrol et
        bool emailExists = users.any((user) => user['email'] == _emailController.text.trim());
        
        if (emailExists) {
          setState(() {
            _errorMessage = widget.isEnglish == true
                ? "This email is already registered"
                : "Bu e-posta zaten kayıtlı";
            _isLoading = false;
          });
          return;
        }
        
        // Yeni kullanıcıyı ekle
        users.add({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text, // Gerçek uygulamada şifrelenmeli
          'registrationDate': DateTime.now().toIso8601String(),
        });
        
        // Kullanıcıları kaydet
        await prefs.setString('registered_users', json.encode(users));
        
        // Başarı mesajı göster
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isEnglish == true
                    ? 'Account created successfully! You can now login.'
                    : 'Hesap başarıyla oluşturuldu! Artık giriş yapabilirsiniz.',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Giriş ekranına dön
          Navigator.pop(context);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = widget.isEnglish == true;
    return Scaffold(
      body: Stack(
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
                      // Logo or App Icon
                      const Icon(
                        Icons.person_add,
                        size: 70,
                        color: Colors.indigoAccent,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        isEnglish ? 'Create Account' : 'Kayıt Ol',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigoAccent,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          color: Colors.indigo[900],
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: isEnglish ? 'Full Name' : 'Ad Soyad',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.indigo[400],
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.indigo),
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
                                ? 'Please enter your name'
                                : 'Lütfen adınızı girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          color: Colors.indigo[900],
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: isEnglish ? 'Email' : 'Email',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.indigo[400],
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.indigo),
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
                      // Password Field
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
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.indigo),
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
                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          color: Colors.indigo[900],
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              isEnglish ? 'Confirm Password' : 'Şifreyi Onayla',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.indigo[400],
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Colors.indigo),
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.indigo),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
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
                                ? 'Please confirm your password'
                                : 'Lütfen şifrenizi onaylayın';
                          }
                          if (value != _passwordController.text) {
                            return isEnglish
                                ? 'Passwords do not match'
                                : 'Şifreler eşleşmiyor';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
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
                      // Register Button
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
                          onPressed: _isLoading ? null : _register,
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)],
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
                                      isEnglish ? 'Register' : 'Kayıt Ol',
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
                      // Back to Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isEnglish
                                ? 'Already have an account? '
                                : 'Zaten hesabın var mı? ',
                            style: GoogleFonts.poppins(
                              color: Colors.indigo[800],
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              isEnglish ? 'Login' : 'Giriş Yap',
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
    );
  }
}
