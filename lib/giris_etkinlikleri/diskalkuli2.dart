import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/activity_tracker.dart';
import 'diskalkuli3.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class Diskalkuli2 extends StatefulWidget {
  const Diskalkuli2({super.key});

  @override
  State<Diskalkuli2> createState() => _Diskalkuli2State();
}

class _Diskalkuli2State extends State<Diskalkuli2>
    with TickerProviderStateMixin {
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
  int _attemptCount = 0; // Deneme sayacı
  int correctCount = 0;
  int totalQuestions = 0;
  late AnimationController _slideController;
  late AnimationController _feedbackController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    totalQuestions = controllers.length; // 5 boşluk = 5 soru
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
    for (var c in controllers.values) {
      c.dispose();
    }
    _slideController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void checkAnswers() {
    setState(() {
      isCorrect.clear();
      correctCount = 0;
      for (var entry in controllers.entries) {
        final kat = entry.key;
        final controller = entry.value;
        bool isCorrectAnswer = int.tryParse(controller.text) == kat;
        isCorrect[kat] = isCorrectAnswer;
        if (isCorrectAnswer) {
          correctCount++;
        }
      }
      showFeedback = true;
      _attemptCount++; // Deneme sayısını artır
    });

    _feedbackController.forward();

    // İlk deneme doğruysa veya ikinci deneme sonrası Diskalkuli3'e geç
    bool allCorrect = isCorrect.values.every((v) => v == true);
    if (allCorrect || _attemptCount >= 2) {
      Future.delayed(const Duration(seconds: 3), () async {
        if (mounted) {
          // Diskalkuli2 tamamlandı - başarı yüzdesini kaydet
          await _saveDiskalkuliProgress();
          ActivityTracker.completeActivity();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Diskalkuli3()),
          );
        }
      });
    } else {
      // İlk deneme yanlışsa, 3 saniye sonra feedback'i gizle ve tekrar deneme imkanı ver
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            showFeedback = false;
          });
        }
      });
    }
  }

  Future<void> _saveDiskalkuliProgress() async {
    final prefs = await SharedPreferences.getInstance();
    // Diskalkuli2 için doğru ve toplam sayıları kaydet
    int diskalkuli2Correct = prefs.getInt('diskalkuli2_correct') ?? 0;
    int diskalkuli2Total = prefs.getInt('diskalkuli2_total') ?? 0;
    
    diskalkuli2Correct += correctCount;
    diskalkuli2Total += totalQuestions;
    
    await prefs.setInt('diskalkuli2_correct', diskalkuli2Correct);
    await prefs.setInt('diskalkuli2_total', diskalkuli2Total);
    
    // Diskalkuli kategori toplamını hesapla (diskalkuli1 + diskalkuli2 + diskalkuli3)
    int diskalkuli1Correct = prefs.getInt('diskalkuli1_correct') ?? 0;
    int diskalkuli1Total = prefs.getInt('diskalkuli1_total') ?? 0;
    int diskalkuli3Correct = prefs.getInt('diskalkuli3_correct') ?? 0;
    int diskalkuli3Total = prefs.getInt('diskalkuli3_total') ?? 0;
    
    int diskalkuliTotalCorrect = diskalkuli1Correct + diskalkuli2Correct + diskalkuli3Correct;
    int diskalkuliTotal = diskalkuli1Total + diskalkuli2Total + diskalkuli3Total;
    
    await prefs.setInt('diskalkuli_correct', diskalkuliTotalCorrect);
    await prefs.setInt('diskalkuli_total', diskalkuliTotal);
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
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
              // Geri butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: screenSize.width * 0.065,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Flashcard - Disgrafi1 tarzında
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                    padding: const EdgeInsets.all(10),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Soru metni
                        Text(
                          isEnglish
                              ? "Complete the pattern correctly!"
                              : "Aşağıdaki örüntüyü doğru şekilde tamamla",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Bina görseli - Büyütülmüş ve güzelleştirilmiş
                        Container(
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300, // Gri renk
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.brown.shade300,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Çatı - Açık kahverengi
                              Container(
                                height: 35,
                                decoration: BoxDecoration(
                                  color:
                                      Colors.brown.shade300, // Açık kahverengi
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                ),
                              ),
                              // Bina gövdesi
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 8,
                                ),
                                child: Column(
                                  children: List.generate(10, (i) {
                                    int floor = 10 - i;
                                    bool isFixed = fixedFloors.containsKey(
                                      floor,
                                    );
                                    bool isInput = controllers.containsKey(
                                      floor,
                                    );
                                    bool isShowFeedback =
                                        showFeedback && isInput;
                                    bool isAnswerCorrect =
                                        isCorrect[floor] == true;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 3,
                                      ),
                                      child: Container(
                                        height: 30,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors
                                                  .lightBlue
                                                  .shade100, // Daha açık mavi
                                              Colors.lightBlue.shade200,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color:
                                                isShowFeedback
                                                    ? (isAnswerCorrect
                                                        ? Colors
                                                            .green
                                                            .shade600 // Belirgin yeşil
                                                        : Colors
                                                            .red
                                                            .shade600) // Belirgin kırmızı
                                                    : Colors.blue.shade400,
                                            width:
                                                isShowFeedback
                                                    ? 3.0
                                                    : 1.5, // Feedback'te daha kalın
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child:
                                              isFixed
                                                  ? Text(
                                                    floor.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors
                                                              .black, // Siyah rakamlar
                                                    ),
                                                  )
                                                  : SizedBox(
                                                    width: 35,
                                                    child: TextField(
                                                      controller:
                                                          controllers[floor],
                                                      enabled: !showFeedback,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            isShowFeedback
                                                                ? (isAnswerCorrect
                                                                    ? Colors
                                                                        .green
                                                                        .shade600 // Belirgin yeşil
                                                                    : Colors
                                                                        .red
                                                                        .shade600) // Belirgin kırmızı
                                                                : Colors.black,
                                                      ),
                                                      decoration: InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        filled: true,
                                                        fillColor:
                                                            Colors.transparent,
                                                        hintText:
                                                            _attemptCount >=
                                                                        2 &&
                                                                    !isAnswerCorrect
                                                                ? floor
                                                                    .toString() // İkinci denemede doğru cevabı göster
                                                                : "?",
                                                        hintStyle: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              _attemptCount >=
                                                                          2 &&
                                                                      !isAnswerCorrect
                                                                  ? Colors
                                                                      .green
                                                                      .shade600 // Belirgin yeşil
                                                                  : Colors.grey,
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  8,
                                                                ),
                                                              ),
                                                          borderSide:
                                                              BorderSide.none,
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                    Radius.circular(
                                                                      8,
                                                                    ),
                                                                  ),
                                                              borderSide:
                                                                  BorderSide
                                                                      .none,
                                                            ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                    Radius.circular(
                                                                      8,
                                                                    ),
                                                                  ),
                                                              borderSide:
                                                                  BorderSide
                                                                      .none,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    );
                                  }),
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

              // Kontrol butonu - Flashcard altında
              if (!showFeedback)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: checkAnswers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        isEnglish ? 'Check' : 'Kontrol Et',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.black, // Siyah yazı
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

              // Feedback Area - Disgrafi1 tarzında
              if (showFeedback)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _feedbackController,
                      curve: Curves.elasticOut,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isCorrect.values.every((v) => v == true)
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color:
                                    isCorrect.values.every((v) => v == true)
                                        ? Colors.green
                                        : Colors.red,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isCorrect.values.every((v) => v == true)
                                    ? (isEnglish
                                        ? 'Well done! 🎉'
                                        : 'Aferin! 🎉')
                                    : (_attemptCount == 1
                                        ? (isEnglish
                                            ? 'Try again! 😔'
                                            : 'Tekrar dene! 😔')
                                        : (isEnglish
                                            ? 'Here\'s the right one! 🧐'
                                            : 'İşte doğrusu! 🧐')),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isCorrect.values.every((v) => v == true)
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
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
