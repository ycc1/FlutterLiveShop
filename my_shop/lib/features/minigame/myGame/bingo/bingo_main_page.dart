// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bingo_ball_drawer.dart';
import 'bingo_controller.dart';
import 'bingo_card_widget.dart';

class BingoMainPage extends ConsumerWidget {
  const BingoMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(bingoProvider);
    final c = ref.read(bingoProvider.notifier);

    // 中奖音效
    if (s.showWinAnim) {
      // final player = AudioPlayer();
      // player.play(AssetSource('sounds/win.mp3')); // 你可放在 assets/sounds/win.mp3
      Future.delayed(const Duration(seconds: 3), c.hideWinAnim);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bingo')),
      body: Stack(
        children: [
          Column(
            children: [
              _topStats(context, s),
              BingoBallStrip(history: s.history),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: s.numCards,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.05),
                  itemBuilder: (_, i) {
                    final card = s.cards[i];
                    final win = card.getBingo(s.drawn);
                    return BingoCardWidget(card: card, drawn: s.drawn, highlightWin: win);
                  },
                ),
              ),
              _bottomControls(context, s, c),
            ],
          ),
          if (s.showWinAnim) _winOverlay(context),
        ],
      ),
    );
  }

  Widget _topStats(BuildContext context, BingoState s) {
    TextStyle bold = const TextStyle(fontWeight: FontWeight.bold);
    return Container(
      color: Colors.amber.shade100,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Text('💰 Kredit: ${s.kredit}', style: bold),
          const SizedBox(width: 12),
          Text('🎯 Pusta: ${s.pusta}', style: bold),
          const SizedBox(width: 12),
          Text('🏆 Panalo: ${s.panalo}', style: bold.copyWith(color: Colors.green.shade700)),
          const Spacer(),
          Text('Balls: ${s.history.length}/90', style: bold),
        ],
      ),
    );
  }

  Widget _bottomControls(BuildContext context, BingoState s, BingoController c) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(onPressed: () => c.changePusta(-1), icon: const Icon(Icons.remove_circle_outline)),
          Text('${s.pusta}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => c.changePusta(1), icon: const Icon(Icons.add_circle_outline)),
          const SizedBox(width: 12),
          FilledButton(onPressed: s.running ? c.stop : c.start, child: Text(s.running ? 'STOP' : 'START')),
          const SizedBox(width: 12),
          OutlinedButton(onPressed: c.shuffleAll, child: const Text('CHANGE NUMBERS')),
        ],
      ),
    );
  }

  Widget _winOverlay(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: const Text(
          '🎉 BINGO! 🎉',
          style: TextStyle(
            fontSize: 60,
            color: Colors.yellow,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(blurRadius: 10, color: Colors.red)],
          ),
        ),
      ),
    );
  }
}
