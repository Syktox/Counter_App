import 'package:flutter/material.dart';

class CounterControls extends StatelessWidget {
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onReset;

  const CounterControls({
    super.key,
    required this.onIncrement,
    required this.onDecrement,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: onDecrement,
          style: ElevatedButton.styleFrom(minimumSize: const Size(80, 80)),
          child: const Text('-', style: TextStyle(fontSize: 32)),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: onReset,
          style: ElevatedButton.styleFrom(minimumSize: const Size(100, 80)),
          child: const Text('Reset', style: TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: onIncrement,
          style: ElevatedButton.styleFrom(minimumSize: const Size(80, 80)),
          child: const Text('+', style: TextStyle(fontSize: 32)),
        ),
      ],
    );
  }
}
