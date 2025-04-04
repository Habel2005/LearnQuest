import 'package:flutter/material.dart';
import 'dart:async';

class AnimatedCustomIcon extends StatefulWidget {
  final String gifPath;
  final String imagePath;
  final bool shouldPlayGif;

  const AnimatedCustomIcon({
    super.key,
    required this.gifPath,
    required this.imagePath,
    this.shouldPlayGif = true,
  });

  @override
  State<AnimatedCustomIcon> createState() => _AnimatedCustomIconState();
}

class _AnimatedCustomIconState extends State<AnimatedCustomIcon> {
  bool _showGif = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.shouldPlayGif) {
      _startGifLoop();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedCustomIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPlayGif && !_showGif) {
      _showGif = true;
      _startGifLoop();
    } else if (!widget.shouldPlayGif) {
      _showGif = false;
      _timer?.cancel(); // Cancel the timer if the widget shouldn't play GIF
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGifLoop() {
    _timer?.cancel(); // Cancel any existing timer
    _showGif = true;
    _timer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _showGif = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45.0,
      height: 45.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: ClipOval(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _showGif
              ? Image.asset(
                  widget.gifPath,
                  key: const ValueKey('gif'),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  widget.imagePath,
                  key: const ValueKey('png'),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
