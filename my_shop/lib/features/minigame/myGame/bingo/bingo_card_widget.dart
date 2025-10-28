import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bingo_controller.dart';

class BingoCardWidget extends StatelessWidget {
  final int index;
  const BingoCardWidget({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<BingoController>();
    final card = ctrl.cards[index];
    final selected = ctrl.selectedIndex == index;
    final isWinner = ctrl.cardIsWinner(index); // 如果要暴露函数可改成 public getter

    return InkWell(
      onTap: ctrl.running ? null : () => ctrl.selectCard(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.orange : Colors.black12, width: selected ? 3 : 1),
          boxShadow: [if (isWinner) BoxShadow(color: Colors.green.withOpacity(.25), blurRadius: 16, spreadRadius: 2)],
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: BingoController.cols, mainAxisSpacing: 4, crossAxisSpacing: 4),
          itemCount: BingoController.rows * BingoController.cols,
          itemBuilder: (_, i) {
            final r = i ~/ BingoController.cols;
            final c = i % BingoController.cols;
            final n = card[r][c];
            final hit = ctrl.drawn.contains(n);
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: hit ? Colors.green.shade400 : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black12),
              ),
              child: Text('$n', style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          },
        ),
      ),
    );
  }
}
