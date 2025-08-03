import 'package:flutter/material.dart';
import '../giris_etkinlikleri/disleksi1.dart';
import '../giris_etkinlikleri/disleksi2.dart';
import '../giris_etkinlikleri/disleksi4.dart';
import '../giris_etkinlikleri/disgrafi2.dart';
import '../giris_etkinlikleri/disgrafi3.dart';
import '../giris_etkinlikleri/diskalkuli1.dart';
import '../giris_etkinlikleri/diskalkuli3.dart';
import 'home_screen.dart';

class IntroFlowController {
  final BuildContext context;
  final List<Widget Function()> activityBuilders;
  final VoidCallback onFlowComplete;
  int _currentIndex = 0;

  IntroFlowController({
    required this.context,
    required this.activityBuilders,
    required this.onFlowComplete,
  });

  Widget currentActivity() {
    return activityBuilders[_currentIndex]();
  }

  void next() {
    if (_currentIndex < activityBuilders.length - 1) {
      _currentIndex++;
    } else {
      onFlowComplete();
    }
  }
}

class GirisEtkinlikleriFlowScreen extends StatefulWidget {
  final bool? isEnglish;
  final void Function(bool isEnglish)? onLanguageChanged;

  const GirisEtkinlikleriFlowScreen({
    super.key,
    this.isEnglish,
    this.onLanguageChanged,
  });

  @override
  State<GirisEtkinlikleriFlowScreen> createState() =>
      _GirisEtkinlikleriFlowScreenState();
}

class _GirisEtkinlikleriFlowScreenState
    extends State<GirisEtkinlikleriFlowScreen> {
  late final IntroFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = IntroFlowController(
      context: context,
      activityBuilders: [
        () => const Disleksi1(),
        () => const Disleksi2(),
        () => const Disleksi4(),
        () => const Diskalkuli1(),
        () => const Diskalkuli3(),
        () => const HeceDoldurma(),
        () => const Disgrafi2(),
      ],
      onFlowComplete: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              isEnglish: widget.isEnglish,
              onLanguageChanged: widget.onLanguageChanged,
            ),
          ),
          (route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _IntroFlowWidget(controller: _controller),
    );
  }
}

class _IntroFlowWidget extends StatefulWidget {
  final IntroFlowController controller;
  const _IntroFlowWidget({required this.controller});

  @override
  State<_IntroFlowWidget> createState() => _IntroFlowWidgetState();
}

class _IntroFlowWidgetState extends State<_IntroFlowWidget> {
  @override
  Widget build(BuildContext context) {
    return _ActivityWrapper(
      onComplete: widget.controller.next,
      child: widget.controller.currentActivity(),
    );
  }
}

class _ActivityWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback onComplete;
  const _ActivityWrapper({
    required this.child,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => _ActivityCompletionListener(
          onComplete: onComplete,
          child: child,
        ),
      ),
    );
  }
}

class _ActivityCompletionListener extends StatefulWidget {
  final Widget child;
  final VoidCallback onComplete;
  const _ActivityCompletionListener({
    required this.child,
    required this.onComplete,
  });

  @override
  State<_ActivityCompletionListener> createState() =>
      _ActivityCompletionListenerState();
}

class _ActivityCompletionListenerState
    extends State<_ActivityCompletionListener> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: widget.child,
    );
  }
}
