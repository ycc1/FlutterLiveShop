import 'package:flutter/material.dart';

class BingoBallDrawer extends StatelessWidget {
  final List<int> numbers;
  const BingoBallDrawer({super.key, required this.numbers});

  @override
  Widget build(BuildContext context) {
    numbers.sort();
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: numbers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) => _ball(numbers[i]),
      ),
    );
  }

  Widget _ball(int n) => Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text('$n', style: const TextStyle(fontWeight: FontWeight.w600)),
      );
}
