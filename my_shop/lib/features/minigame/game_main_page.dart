import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GameMainPage extends StatelessWidget {
  const GameMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = <_GameCard>[
      _GameCard(
        title: '走迷宮',
        subtitle: '找到出口 +50 分',
        icon: Icons.grid_on,
        route: '/minigame/maze',
      ),
      _GameCard(
        title: '拆炸彈 Bomb',
        subtitle: '在限時內剪對引線 +50 分',
        icon: Icons.bolt_outlined,
        route: '/minigame/bomb',
      ),
      _GameCard(
        title: '电子鸡 Tamagotchi',
        subtitle: '在限時內剪對引線 +50 分',
        icon: Icons.bolt_outlined,
        route: '/minigame/eTamagotchi',
      ),
      _GameCard(
        title: 'Bingo',
        subtitle: 'Bingo +50 分',
        icon: Icons.bolt_outlined,
        route: '/minigame/bingo',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('遊戲大廳')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .95),
        itemCount: cards.length,
        itemBuilder: (_, i) => _GameTile(card: cards[i]),
      ),
    );
  }
}

class _GameCard {
  final String title, subtitle, route;
  final IconData icon;
  _GameCard({required this.title, required this.subtitle, required this.icon, required this.route});
}

class _GameTile extends StatelessWidget {
  final _GameCard card;
  const _GameTile({required this.card, super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(card.route),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(card.icon, size: 42),
              const Spacer(),
              Text(card.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(card.subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
