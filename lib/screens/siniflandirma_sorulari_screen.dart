import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../siniflama1/soru1.dart';
import '../siniflama2/soru1.dart';
import '../siniflama3/soru1.dart';
import '../siniflama4/soru1.dart';
import 'home_screen.dart';

class ClassificationQuestionsScreen extends StatefulWidget {
  const ClassificationQuestionsScreen({super.key});

  @override
  State<ClassificationQuestionsScreen> createState() =>
      _ClassificationQuestionsScreenState();
}

class _ClassificationQuestionsScreenState
    extends State<ClassificationQuestionsScreen> {
  List<bool> completedStages = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    _loadCompletedStages();
  }

  Future<void> _loadCompletedStages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      completedStages[0] = prefs.getBool('stage_1_completed') ?? false;
      completedStages[1] = prefs.getBool('stage_2_completed') ?? false;
      completedStages[2] = prefs.getBool('stage_3_completed') ?? false;
      completedStages[3] = prefs.getBool('stage_4_completed') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/roadmap_siniflama.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Invisible back button positioned over the image's back arrow
            Positioned(
              top: MediaQuery.of(context).size.height * 0.005,
              left: MediaQuery.of(context).size.width * 0.05,
              child: _buildInvisibleClickableArea(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ),

            // Invisible clickable areas positioned exactly over the numbered circles in the image
            // Stage 1 - Mountain peak - Adjusted to center of circle
            Positioned(
              left: MediaQuery.of(context).size.width * 0.18,
              top: MediaQuery.of(context).size.height * 0.22,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 1),
              ),
            ),

            // Stage 2 - Forest area - Adjusted to center of circle
            Positioned(
              left: MediaQuery.of(context).size.width * 0.10,
              top: MediaQuery.of(context).size.height * 0.57,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 2),
              ),
            ),

            // Stage 3 - River/rock area - Keep as is (working well)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.47,
              top: MediaQuery.of(context).size.height * 0.77,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 3),
              ),
            ),

            // Stage 4 - Castle area - Adjusted to center of circle
            Positioned(
              left: MediaQuery.of(context).size.width * 0.70,
              top: MediaQuery.of(context).size.height * 0.34,
              child: _buildInvisibleClickableArea(
                onTap: () => _navigateToStage(context, 4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvisibleClickableArea({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        // Optional: Add a subtle visual feedback on tap
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: onTap,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.transparent, width: 0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToStage(BuildContext context, int stageNumber) {
    final isEnglish =
        Provider.of<LanguageProvider>(context, listen: false).isEnglish;

    // Check if previous stages are completed
    bool canAccess = true;
    for (int i = 0; i < stageNumber - 1; i++) {
      if (!completedStages[i]) {
        canAccess = false;
        break;
      }
    }

    if (!canAccess) {
      _showLockedStageDialog(context, stageNumber, isEnglish);
      return;
    }

    Widget? targetWidget;
    switch (stageNumber) {
      case 1:
        targetWidget = const CinsiyetEsleme();
        break;
      case 2:
        targetWidget = const MeyveSebzeEsleme();
        break;
      case 3:
        targetWidget = const SekilSiniflama();
        break;
      case 4:
        targetWidget = const DuyguSiniflama();
        break;
    }

    if (targetWidget != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetWidget!),
      ).then((_) {
        // Refresh completed stages when returning
        _loadCompletedStages();
      });
    }
  }

  void _showLockedStageDialog(
    BuildContext context,
    int stageNumber,
    bool isEnglish,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 20,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF8E1), Color(0xFFFFF3C4)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lock Icon with Animation
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 40),
                ),

                const SizedBox(height: 25),

                // Title
                Text(
                  isEnglish ? '🔒 Stage Locked!' : '🔒 Aşama Kilitli!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Message
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    isEnglish
                        ? 'You need to complete Stage ${stageNumber - 1} first before accessing Stage $stageNumber.'
                        : 'Aşama $stageNumber\'e erişmen için önce Aşama ${stageNumber - 1}\'i tamamlaman gerekiyor.',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                // Beautiful Button
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () => Navigator.of(context).pop(),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isEnglish ? 'Got it!' : 'Anladım!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
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
        );
      },
    );
  }
}
