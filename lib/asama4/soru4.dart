import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'dart:async';
import 'soru5.dart'; // Eğer sonraki ekran burada ise bırakıldı
import '../screens/home_screen.dart';

class MevsimHavaEsle extends StatefulWidget {
  const MevsimHavaEsle({super.key});

  @override
  State<MevsimHavaEsle> createState() => _MevsimHavaEsleState();
}

class _MevsimHavaEsleState extends State<MevsimHavaEsle>
    with TickerProviderStateMixin {
  final List<String> leftSeasons = ['🌞', '❄️', '🌸', '🍂'];
  final List<String> rightWeather = ['Yaz', 'Kış', 'İlkbahar', 'Sonbahar'];

  late List<String> shuffledWeather;
  int? selectedLeftIndex;
  int? selectedRightIndex;

  List<bool> matchedLeft = [false, false, false, false];
  List<bool> matchedRight = [false, false, false, false];

  bool showFeedback = false;
  bool isCorrect = false;
  bool _dialogShown = false;

  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    shuffledWeather = List.from(rightWeather)..shuffle();

    _feedbackController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _slide_controllerInit();
  }

  void _slide_controllerInit() {
    _slide_controllerInit_impl();
  }

  void _slide_controllerInit_impl() {
    _slideController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleTap(int index, bool isLeft) {
    setState(() {
      if (isLeft) {
        if (matchedLeft[index]) return;
        selectedLeftIndex = index;
      } else {
        if (matchedRight[index]) return;
        selectedRightIndex = index;
      }

      if (selectedLeftIndex != null && selectedRightIndex != null) {
        // doğru eşleşme kontrolü
        isCorrect = (leftSeasons[selectedLeftIndex!] == '🌞' &&
                shuffledWeather[selectedRightIndex!] == 'Yaz') ||
            (leftSeasons[selectedLeftIndex!] == '❄️' &&
                shuffledWeather[selectedRightIndex!] == 'Kış') ||
            (leftSeasons[selectedLeftIndex!] == '🌸' &&
                shuffledWeather[selectedRightIndex!] == 'İlkbahar') ||
            (leftSeasons[selectedLeftIndex!] == '🍂' &&
                shuffledWeather[selectedRightIndex!] == 'Sonbahar');

        showFeedback = true;
        _feedbackController.forward(from: 0);

        if (isCorrect) {
          matchedLeft[selectedLeftIndex!] = true;
          matchedRight[selectedRightIndex!] = true;

          if (matchedLeft.every((e) => e) && !_dialogShown) {
            _dialogShown = true;
            ActivityTracker.completeActivity();

            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const EmojiAnimalMatching()),
                );
              }
            });
          }
        }

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              showFeedback = false;
              selectedLeftIndex = null;
              selectedRightIndex = null;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.065;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade200,
                Colors.blue.shade200,
                const Color(0xffffffff),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Üstte geri oku (back)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black, size: iconSize),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),

                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Başlık
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            child: const Text(
                              'Mevsimleri hava durumlarıyla eşleştir',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // İçerik: sol emojiler — orta çizgi — sağ metin kutuları
                          Expanded(
                            child: Row(
                              children: [
                                // sol emojiler (beyaz kutulu)
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      leftSeasons.length,
                                      (index) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child: GestureDetector(
                                          onTap: () => _handleTap(index, true),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: matchedLeft[index]
                                                  ? Colors.green.shade200
                                                  : (showFeedback &&
                                                          !isCorrect &&
                                                          selectedLeftIndex == index)
                                                      ? Colors.red.shade200
                                                      : selectedLeftIndex == index
                                                          ? Colors.blue.shade200
                                                          : Colors.white,
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.12),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                              border: selectedLeftIndex == index && !matchedLeft[index]
                                                  ? Border.all(color: Colors.lightGreen.shade400, width: 3)
                                                  : null,
                                            ),
                                            child: Center(
                                              child: Text(
                                                leftSeasons[index],
                                                style: const TextStyle(
                                                  fontSize: 48, // EMOJİLER DAHA BÜYÜK!
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // orta çizgi (mavi gradient)
                                Container(
                                  width: 4,
                                  height: screenSize.height * 0.58,
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade400,
                                        Colors.blue.shade200,
                                        Colors.blue.shade100,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),

                                // sağ mevsim isimleri (beyaz kutulu)
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      shuffledWeather.length,
                                      (index) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child: GestureDetector(
                                          onTap: () => _handleTap(index, false),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: matchedRight[index]
                                                  ? Colors.green.shade200
                                                  : (showFeedback &&
                                                          !isCorrect &&
                                                          selectedRightIndex == index)
                                                      ? Colors.red.shade200
                                                      : selectedRightIndex == index
                                                          ? Colors.yellow.shade200
                                                          : Colors.white,
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.12),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                              border: selectedRightIndex == index && !matchedRight[index]
                                                  ? Border.all(color: Colors.lightGreen.shade400, width: 3)
                                                  : null,
                                            ),
                                            child: Center(
                                              child: Text(
                                                shuffledWeather[index],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // feedback alanı (animasyonlu)
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: showFeedback
                      ? ScaleTransition(
                          scale: CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                                    color: isCorrect ? Colors.green : Colors.red, size: 26),
                                const SizedBox(width: 8),
                                Text(
                                  isCorrect ? "Aferin! 🎉" : "Tekrar dene! 😔",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isCorrect ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );   
   }
  }
