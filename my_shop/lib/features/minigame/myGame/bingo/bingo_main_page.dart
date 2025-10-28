import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bingo_controller.dart';
import 'bingo_card_widget.dart';
import 'bingo_ball_drawer.dart';
import 'bingo_result_overlay.dart';

class BingoMainPage extends StatelessWidget {
  const BingoMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BingoController(),
      child: const _BingoView(),
    );
  }
}

class _BingoView extends StatelessWidget {
  const _BingoView();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<BingoController>();
    return Scaffold(
      backgroundColor: const Color(0xfff6f6ea),
      appBar: AppBar(
        title: const Text('Bingo'),
        backgroundColor: const Color(0xfff6f6ea),
        actions: [
          Center(
            child: Row(
              children: [
                _stat('Kredit', ctrl.credit.toString()),
                _stat('Pusta', ctrl.bet.toString()),
                _stat('Panalo', ctrl.winThisRound.toString()),
                _stat('Balls', '${ctrl.drawn.length}/90'),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          BingoBallDrawer(numbers: ctrl.drawn.toList()),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.1),
              itemCount: ctrl.cards.length,
              itemBuilder: (context, i) => BingoCardWidget(index: i),
            ),
          ),
          _bottomBar(context),
          if (!ctrl.running && ctrl.winThisRound > 0)
            const BingoResultOverlay(),
        ],
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    final ctrl = context.read<BingoController>();
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
              onPressed: !ctrl.running ? ctrl.decreaseBet : null,
              icon: const Icon(Icons.remove_circle_outline)),
          Text('${ctrl.bet}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
              onPressed: !ctrl.running ? ctrl.increaseBet : null,
              icon: const Icon(Icons.add_circle_outline)),
          const Spacer(),
          FilledButton.tonal(
              onPressed: ctrl.running ? ctrl.stopGame : ctrl.startGame,
              child: Text(ctrl.running ? 'STOP' : 'START')),
          const SizedBox(width: 8),
          FilledButton(onPressed: ctrl.running ? null : ctrl.changeNumbers, child: const Text('CHANGE NUMBERS')),
        ],
      ),
    );
  }

  Widget _stat(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text('$k: $v', style: const TextStyle(fontWeight: FontWeight.w600)),
      );
}
