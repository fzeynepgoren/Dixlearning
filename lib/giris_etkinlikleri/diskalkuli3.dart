import 'package:flutter/material.dart';
import '../utils/activity_tracker.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'diskalkuli4.dart';
import '../screens/home_screen.dart';

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
  bool _isWrong = false;
  String? _feedbackText;
  late AnimationController _fadeController;
  late AnimationController _congratsController;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _congratsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _congratsController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onDrop(int value) async {
    final problem = _problems[_currentProblemIndex];
    final isCorrect = value == problem['answer'];

    setState(() {
      problem['userAnswer'] = value;
    });

    if (isCorrect) {
      setState(() {
        _feedbackText = "Aferin! 🎉";
      });
      _congratsController.forward(from: 0);
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        _feedbackText = null;
      });
    } else {
      setState(() {
        _isWrong = true;
        _feedbackText = "İşte doğrusu! 🧐";
      });
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0);
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        _feedbackText = null;
      });
    }

    // Sonraki soruya geç
    if (_currentProblemIndex < _problems.length - 1) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _currentProblemIndex++;
        _problems[_currentProblemIndex]['userAnswer'] = null;
        _isWrong = false;
        _feedbackText = null;
      });
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        ActivityTracker.completeActivity();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Diskalkuli4()),
        );
      }
    }
  }

  List<int> _getNumberOptions() {
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
    final problem = _problems[_currentProblemIndex];
    final isCorrect = problem['userAnswer'] == problem['answer'];
    final hasAnswer = problem['userAnswer'] != null;
    final numberOptions = _getNumberOptions();

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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: MediaQuery.of(context).size.width * 0.065,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
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
                        Text(
                          problem['problem'],
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF37474F),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        buildHouse(
                          hasAnswer: hasAnswer,
                          isCorrect: isCorrect,
                          answer: hasAnswer ? problem['userAnswer'] : null,
                          onDrop: _onDrop,
                        ),
                        const SizedBox(height: 36),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: MediaQuery.of(context).size.width * 0.04,
                          runSpacing: MediaQuery.of(context).size.width * 0.03,
                          children:
                              numberOptions.map((num) {
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
                  ),
                ),
              ),
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child:
                    _feedbackText != null
                        ? AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Container(
                            key: ValueKey<String>(_feedbackText!),
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
                                  _isWrong ? Icons.cancel : Icons.check_circle,
                                  color: _isWrong ? Colors.red : Colors.green,
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _isWrong ? "İşte doğrusu! 🧐" : "Aferin! 🎉",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: _isWrong ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberBox(int num, {bool dragging = false}) {
    final screenSize = MediaQuery.of(context).size;
    final boxSize = screenSize.width * 0.15;

    return Container(
      width: boxSize,
      height: boxSize,
      margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
      decoration: BoxDecoration(
        color: dragging ? Colors.amberAccent : Colors.pinkAccent,
        borderRadius: BorderRadius.circular(boxSize * 0.3),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Text(
          num.toString(),
          style: TextStyle(
            fontSize: boxSize * 0.5,
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
    final problem = _problems[_currentProblemIndex];
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
      width: screenSize.width * 0.55,
      height: screenSize.height * 0.35,
      child: Stack(
        alignment: Alignment.center,
        children: [
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
                        color:
                            candidateData.isNotEmpty
                                ? Colors.yellow[100]
                                : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              hasAnswer
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
                        child:
                            hasAnswer
                                ? Text(
                                  _isWrong
                                      ? problem['answer'].toString()
                                      : answer.toString(),
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isCorrect ? Colors.green : Colors.red,
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
