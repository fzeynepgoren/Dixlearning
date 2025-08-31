import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'diskalkuli3.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class Diskalkuli2 extends StatefulWidget {
  const Diskalkuli2({super.key});

  @override
  State<Diskalkuli2> createState() => _Diskalkuli2State();
}

class _Diskalkuli2State extends State<Diskalkuli2> {
  final Map<int, int> fixedFloors = {1: 1, 3: 3, 6: 6, 8: 8, 10: 10};
  final Map<int, TextEditingController> controllers = {
    2: TextEditingController(),
    4: TextEditingController(),
    5: TextEditingController(),
    7: TextEditingController(),
    9: TextEditingController(),
  };

  bool showFeedback = false;
  Map<int, bool> isCorrect = {};

  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void checkAnswers() {
    setState(() {
      isCorrect.clear();
      for (var entry in controllers.entries) {
        final kat = entry.key;
        final controller = entry.value;
        isCorrect[kat] = int.tryParse(controller.text) == kat;
      }
      showFeedback = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (isCorrect.values.every((v) => v == true)) {
        ActivityTracker.completeActivity();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Diskalkuli3()),
          );
        }
      } else {
        setState(() {
          showFeedback = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;

    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Soru kutusu
              Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    "Aşağıdaki örüntüyü doğru şekilde tamamla",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0288D1),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Bina görseli
              Container(
                width: 140,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.blueAccent.withOpacity(0.18),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(10, (i) {
                    int floor = 10 - i;
                    bool isFixed = fixedFloors.containsKey(floor);
                    bool isInput = controllers.containsKey(floor);
                    bool isShowFeedback = showFeedback && isInput;
                    bool isAnswerCorrect = isCorrect[floor] == true;
                    bool isAnswerWrong = isCorrect[floor] == false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isShowFeedback
                                        ? (isAnswerCorrect
                                            ? Colors.green
                                            : Colors.red)
                                        : Colors.blueAccent.withOpacity(0.4),
                                width: 2.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12.withOpacity(0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child:
                                  isFixed
                                      ? Text(
                                        floor.toString(),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0288D1),
                                        ),
                                      )
                                      : SizedBox(
                                        width: 38,
                                        child: TextField(
                                          controller: controllers[floor],
                                          enabled: !showFeedback,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0288D1),
                                          ),
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 2,
                                                ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                            ),
                          ),
                          if (isShowFeedback)
                            Positioned(
                              right: 8,
                              child: Icon(
                                isAnswerCorrect
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color:
                                    isAnswerCorrect ? Colors.green : Colors.red,
                                size: 22,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: showFeedback ? null : checkAnswers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  isEnglish ? 'Check' : 'Kontrol Et',
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              if (showFeedback && isCorrect.values.any((v) => v == false))
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Text(
                    isEnglish
                        ? 'Please fill in all floors correctly!'
                        : 'Lütfen tüm katları doğru doldurun!',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
