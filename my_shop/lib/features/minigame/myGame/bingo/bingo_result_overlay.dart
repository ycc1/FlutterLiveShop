// BINGO! 結果提示
import 'package:flutter/material.dart';

class BingoResultOverlay extends StatelessWidget {
  const BingoResultOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black.withOpacity(0.3),
          alignment: Alignment.center,
          child: Text(
            '🎉 BINGO! 🎉',
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w900,
              color: Colors.amber.shade300,
              shadows: [const Shadow(blurRadius: 12, color: Colors.black54)],
            ),
          ),
        ),
      ),
    );
  }
}
