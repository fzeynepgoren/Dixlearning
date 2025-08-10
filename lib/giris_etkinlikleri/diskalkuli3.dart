import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'disgrafi1.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class Diskalkuli3 extends StatefulWidget {
  const Diskalkuli3({super.key});

  @override
  State<Diskalkuli3> createState() => _Diskalkuli3State();
}

class _Diskalkuli3State extends State<Diskalkuli3>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _problems = [
    {'problem': '2 + 5', 'answer': 7, 'userAnswer': null},
    {'problem': '3 + 6', 'answer': 9, 'userAnswer': null},
    {'problem': '7 + 4', 'answer': 11, 'userAnswer': null},
  ];

  int _currentProblemIndex = 0;
  bool _showCongrats = false;
  bool _isWrong = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _congratsController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    _congratsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 16)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _congratsController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onDrop(int value) async {
    setState(() {
      _problems[_currentProblemIndex]['userAnswer'] = value;
    });
    final isLast = _currentProblemIndex == _problems.length - 1;
    final isCorrect = value == _problems[_currentProblemIndex]['answer'];
    if (isCorrect) {
      setState(() {
        _showCongrats = true;
      });
      _congratsController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 900));
      setState(() {
        _showCongrats = false;
      });
    } else {
      setState(() {
        _isWrong = true;
      });
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        _isWrong = false;
      });
    }
    // Her durumda bir sonraki soruya geç
    if (!isLast) {
      _fadeController.reverse().then((_) {
        setState(() {
          _currentProblemIndex++;
          _problems[_currentProblemIndex]['userAnswer'] = null;
        });
        _fadeController.forward();
      });
    } else {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        print('Diskalkuli3 tamamlandı, bir sonraki aktiviteye geçiliyor');
        // Etkinlik tamamlandı

        ActivityTracker.completeActivity();

        

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Disgrafi1()),
        );
      }
    }
  }

  List<int> _getNumberOptions() {
    // Cevap ve rastgele 4 sayı (toplam 5 kutu)
    final answer = _problems[_currentProblemIndex]['answer'] as int;
    final rand = Random();
    final options = <int>{answer};
    while (options.length < 5) {
      int n = rand.nextInt(16);
      if (n != answer) options.add(n);
    }
    final list = options.toList();
    list.shuffle();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final problem = _problems[_currentProblemIndex];
    final isCorrect = problem['userAnswer'] == problem['answer'];
    final hasAnswer = problem['userAnswer'] != null;
    final numberOptions = _getNumberOptions();

    return Scaffold(
      backgroundColor: const Color(0xFFB2EBF2),
      appBar: AppBar(
        title: Text(isEnglish ? 'Addition Game' : 'Toplama Oyunu'),
        backgroundColor: const Color(0xFF00BCD4),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
              child: Center(
                child: Text(
                  isEnglish
                      ? 'Question ${_currentProblemIndex + 1}/${_problems.length}'
                      : 'Soru ${_currentProblemIndex + 1}/${_problems.length}',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00796B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: Text(
                  problem['problem'],
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6D4C41),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ev görseli (shake animasyonlu)
                          AnimatedBuilder(
                            animation: _shakeController,
                            builder: (context, child) {
                              double offset =
                                  _isWrong ? _shakeAnimation.value : 0;
                              return Transform.translate(
                                offset: Offset(
                                    offset * (Random().nextBool() ? 1 : -1), 0),
                                child: child,
                              );
                            },
                            child: buildHouse(
                              hasAnswer: hasAnswer,
                              isCorrect: isCorrect,
                              answer: hasAnswer ? problem['userAnswer'] : null,
                              onDrop: _onDrop,
                            ),
                          ),
                          const SizedBox(height: 36),
                          // Drag numbers
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 18,
                            children: numberOptions.map((num) {
                              return Draggable<int>(
                                data: num,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: _buildNumberBox(num, dragging: true),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: _buildNumberBox(num),
                                ),
                                child: _buildNumberBox(num),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      // Doğru cevapta "Aferin!" animasyonu çatının üstünde
                      if (_showCongrats)
                        Positioned(
                          top: 80,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.7, end: 1.2)
                                .chain(CurveTween(curve: Curves.elasticOut))
                                .animate(_congratsController),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.shade100,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.emoji_events,
                                      color: Colors.orange, size: 60),
                                  const SizedBox(height: 10),
                                  Text(
                                    isEnglish ? 'Well done!' : 'Aferin!',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberBox(int num, {bool dragging = false}) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: dragging ? Colors.amberAccent : Colors.pinkAccent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildHouse({
    required bool hasAnswer,
    required bool isCorrect,
    required int? answer,
    required void Function(int) onDrop,
  }) {
    return SizedBox(
      width: 220,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Çatı (daha büyük ve oranlı)
          Positioned(
            top: 0,
            child: Container(
              width: 180,
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF8A65), Color(0xFFD84315)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(90),
                  bottomRight: Radius.circular(90),
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: DragTarget<int>(
                  builder: (context, candidateData, rejectedData) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      height: 54,
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color: candidateData.isNotEmpty
                            ? Colors.yellow[100]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: hasAnswer
                              ? (isCorrect ? Colors.green : Colors.red)
                              : Colors.grey,
                          width: 4,
                        ),
                        boxShadow: [
                          if (candidateData.isNotEmpty)
                            const BoxShadow(
                              color: Colors.amber,
                              blurRadius: 16,
                              spreadRadius: 3,
                            ),
                        ],
                      ),
                      child: Center(
                        child: hasAnswer && answer != null
                            ? Text(
                                answer.toString(),
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                              )
                            : const Text(
                                'Cevap',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    );
                  },
                  onWillAcceptWithDetails: (data) => true,
                  onAcceptWithDetails: (details) => onDrop(details.data),
                ),
              ),
            ),
          ),
          // Gövde (daha büyük ve oranlı)
          Positioned(
            top: 90,
            child: Container(
              width: 180,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.orange[200],
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Kapı
                  Positioned(
                    bottom: 16,
                    left: 75,
                    child: Container(
                      width: 36,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  // Sol pencere
                  Positioned(
                    top: 32,
                    left: 28,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blueAccent, width: 3),
                      ),
                    ),
                  ),
                  // Sağ pencere
                  Positioned(
                    top: 32,
                    right: 28,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blueAccent, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
