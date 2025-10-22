import 'package:flutter/material.dart';
import 'bingo_controller.dart';

class BingoCardWidget extends StatelessWidget {
  final BingoCard card;
  final Set<int> drawn;
  final bool highlightWin;
  const BingoCardWidget({
    super.key,
    required this.card,
    required this.drawn,
    required this.highlightWin,
  });

  @override
  Widget build(BuildContext context) {
    final border = highlightWin ? Border.all(color: Colors.amber, width: 4) : Border.all(color: Colors.black26);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: border,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        itemCount: 25,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemBuilder: (_, i) {
          final r = i ~/ 5, c = i % 5;
          final n = card.cells[r][c];
          final marked = drawn.contains(n);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: marked ? Colors.lightGreen.shade400 : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black26),
            ),
            child: Text(
              '$n',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: marked ? Colors.white : Colors.black87,
              ),
            ),
          );
        },
      ),
    );
  }
}
