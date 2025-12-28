import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'matching_pause_menu.dart';

class InGameMenu extends StatefulWidget {
  const InGameMenu({
    super.key,
    required this.isSoundOn,
    required this.onToggleSound,
    required this.onHome,
    required this.onEntryScreen,
    this.iconSize,
    this.screenSize,
  });

  final bool isSoundOn;
  final VoidCallback onToggleSound;
  final VoidCallback onHome;
  final VoidCallback onEntryScreen;
  final double? iconSize;
  final Size? screenSize;

  @override
  State<InGameMenu> createState() => _InGameMenuState();
}

class _InGameMenuState extends State<InGameMenu> {
  bool _showPauseMenu = false;

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;
    final iconSize =
        widget.iconSize ??
        (widget.screenSize != null ? widget.screenSize!.width * 0.065 : 40.0);

    return WillPopScope(
      onWillPop: () async {
        if (_showPauseMenu) {
          // Menü açıksa, geri tuşu ile kapat
          setState(() {
            _showPauseMenu = false;
          });
        } else {
          // Menü kapalıysa, geri tuşu ile aç
          setState(() {
            _showPauseMenu = true;
          });
        }
        return false;
      },
      child: Stack(
        children: [
          // Menü butonu
          Positioned(
            top: 8.0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showPauseMenu = true;
                    });
                  },
                  child: Container(
                    width: iconSize * 1.6,
                    height: iconSize * 1.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade300,
                          const Color(0xffffffff),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade600.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(-2, -2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.home_rounded,
                      color: Colors.black,
                      size: iconSize * 0.9,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Menü overlay
          if (_showPauseMenu)
            MatchingPauseMenu(
              isEnglish: isEnglish,
              isSoundOn: widget.isSoundOn,
              onResume: () {
                setState(() {
                  _showPauseMenu = false;
                });
              },
              onToggleSound: widget.onToggleSound,
              onHome: widget.onHome,
              onEntryScreen: widget.onEntryScreen,
              onDismiss: () {
                setState(() {
                  _showPauseMenu = false;
                });
              },
            ),
        ],
      ),
    );
  }
}
