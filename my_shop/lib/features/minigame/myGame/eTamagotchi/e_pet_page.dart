import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../points_adapter.dart';


class EPetTamagotchiPage extends ConsumerStatefulWidget {
  const EPetTamagotchiPage({super.key});

  @override
  ConsumerState<EPetTamagotchiPage> createState() => _EPetPageState();
}

class _EPetPageState extends ConsumerState<EPetTamagotchiPage> {
  int hunger = 80; // 飢餓值
  int happiness = 80; // 快樂值
  int energy = 80; // 能量
  int level = 1;
  int xp = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLifeCycle();
  }

  void _startLifeCycle() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        hunger = (hunger - 2).clamp(0, 100);
        happiness = (happiness - 1).clamp(0, 100);
        energy = (energy - 1).clamp(0, 100);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _feed() {
    setState(() {
      hunger = (hunger + 20).clamp(0, 100);
      xp += 5;
    });
    _checkLevelUp();
  }

  void _play() {
    setState(() {
      happiness = (happiness + 15).clamp(0, 100);
      energy = (energy - 10).clamp(0, 100);
      xp += 8;
    });
    _checkLevelUp();
  }

  void _sleep() {
    setState(() {
      energy = 100;
      hunger = (hunger - 10).clamp(0, 100);
      xp += 3;
    });
    _checkLevelUp();
  }

  void _checkLevelUp() async {
    if (xp >= 100) {
      xp = 0;
      level++;
      await ref.read(pointsServiceProvider).add(10);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🎉 你的電子雞升到 Lv.$level，獲得 10 積分！')),
        );
      }
    }
  }

  String _getMood() {
    if (hunger < 20) return '餓扁了 😢';
    if (energy < 20) return '想睡覺 💤';
    if (happiness < 20) return '心情不好 😔';
    return '開心 😄';
  }

  @override
  Widget build(BuildContext context) {
    final mood = _getMood();
    return Scaffold(
      appBar: AppBar(title: const Text('電子雞 Tamagotchi')),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text('等級 Lv.$level', style: Theme.of(context).textTheme.titleLarge),
              Text('心情：$mood', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              _statusBar('飢餓', hunger as double, Colors.orange),
              _statusBar('快樂', happiness as double, Colors.pink),
              _statusBar('能量', energy as double, Colors.blue),
              _statusBar('經驗', xp.toDouble(), Colors.green, max: 100),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Icon(
                  hunger < 20 || energy < 20
                      ? Icons.sentiment_dissatisfied
                      : Icons.emoji_emotions,
                  key: ValueKey(mood),
                  size: 100,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.fastfood),
                    label: const Text('餵食'),
                    onPressed: _feed,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.sports_esports),
                    label: const Text('玩耍'),
                    onPressed: _play,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.bedtime),
                    label: const Text('睡覺'),
                    onPressed: _sleep,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBar(String label, double value, Color color, {double max = 100}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Text(label),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: value / max,
                  color: color,
                  backgroundColor: Colors.grey.shade300,
                ),
              ),
              const SizedBox(width: 8),
              Text('${value.toInt()}'),
            ],
          ),
        ],
      ),
    );
  }
}
