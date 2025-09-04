import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';

class RecordButton extends StatefulWidget {
  const RecordButton({Key? key}) : super(key: key);

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  bool isRecording = false;

  @override
  void initState() {
    super.initState();

    // Animación cíclica de 2s
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _color1 = ColorTween(begin: TongiColors.primary, end: Colors.orange)
        .animate(_controller);
    _color2 = ColorTween(begin: Colors.orange, end: Colors.purple)
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleRecording() {
    setState(() {
      isRecording = !isRecording;
      if (isRecording) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: toggleRecording,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(50),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_color1.value ?? Colors.red, _color2.value ?? Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Icon(
              isRecording ? Icons.stop : Icons.mic,
              size: 60,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
