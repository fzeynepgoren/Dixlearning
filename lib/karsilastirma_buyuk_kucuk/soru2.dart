import 'package:flutter/material.dart';
import 'soru3.dart'; // 3. sorunun dosyası

class BuyukKucukKarpuzSorusu extends StatefulWidget {
  const BuyukKucukKarpuzSorusu({super.key});

  @override
  State<BuyukKucukKarpuzSorusu> createState() => _BuyukKucukKarpuzSorusuState();
}

class _BuyukKucukKarpuzSorusuState extends State<BuyukKucukKarpuzSorusu>
    with TickerProviderStateMixin {
  int? selectedIndex;
  bool? isCorrect;
  bool showFeedback = false;
  late AnimationController _feedbackController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleSelect(int index) {
    setState(() {
      selectedIndex = index;
      isCorrect = (index == 0); // Soldaki büyük karpuz doğru
      showFeedback = true;
    });
    _feedbackController.forward(from: 0);
    if (isCorrect == true) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const BuyukKucukSoru3(),
          ), // 3. soruya geçiş
        );
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          showFeedback = false;
          selectedIndex = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final iconSize = screenWidth * 0.065;
    const Color defaultBtnColor = Color(0xFF2E7D32);
    final double imageHeight = screenHeight * 0.48;
    const double buttonHeight = 50;
    final double buttonWidth = screenWidth * 0.28;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade200,
                Colors.blue.shade200,
                const Color(0xffffffff),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: iconSize,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(width: iconSize),
                  ],
                ),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 6,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: screenHeight * 0.98,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 8),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    'Karpuzlardan büyük olanı işaretle.',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  height: imageHeight,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.10),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.asset(
                                      'assets/buyuk_kucuk/soru2/Resim2.png', // Soru 2 resmi
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(2, (i) {
                                    final isSelected = selectedIndex == i;
                                    Color btnColor = defaultBtnColor;
                                    if (isSelected) {
                                      if (isCorrect == true) {
                                        btnColor = Colors.green.shade500;
                                      } else if (isCorrect == false) {
                                        btnColor = Colors.red.shade500;
                                      }
                                    }
                                    return SizedBox(
                                      width: buttonWidth,
                                      height: buttonHeight,
                                      child: ElevatedButton(
                                        onPressed: () => _handleSelect(i),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: btnColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Seç',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  height: 60,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  child:
                                      showFeedback
                                          ? ScaleTransition(
                                            scale: CurvedAnimation(
                                              parent: _feedbackController,
                                              curve: Curves.elasticOut,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  isCorrect == true
                                                      ? Icons.check_circle
                                                      : Icons.cancel,
                                                  color:
                                                      isCorrect == true
                                                          ? Colors.green
                                                          : Colors.red,
                                                  size: 28,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  isCorrect == true
                                                      ? 'Aferin! 🎉'
                                                      : 'Tekrar dene! 😔',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color:
                                                        isCorrect == true
                                                            ? Colors.green
                                                            : Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          : const SizedBox.shrink(),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
