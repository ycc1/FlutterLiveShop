import 'package:flutter/material.dart';

class BingoBallStrip extends StatelessWidget {
  final List<int> history; // 已抽出的顺序
  const BingoBallStrip({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final balls = history.reversed.take(24).toList().reversed.toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: balls
            .map((n) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Text('$n', style: const TextStyle(fontWeight: FontWeight.bold)),
                ))
            .toList(),
      ),
    );
  }
}
