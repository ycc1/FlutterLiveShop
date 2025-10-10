import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 依你的目录结构：myGame/bomb → minigame → gacha_puzzle/points_adapter.dart
import '../points_adapter.dart';

class BombDefusePage extends ConsumerStatefulWidget {
  const BombDefusePage({super.key});
  @override
  ConsumerState<BombDefusePage> createState() => _BombDefusePageState();
}

class _BombDefusePageState extends ConsumerState<BombDefusePage> {
  static const int maxSeconds = 60;
  static const int penalty = 10;
  static const int reward = 50;

  static const _colors = <Color>[
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.amber,
    Colors.purple
  ];
  static const _labels = ['RED', 'BLUE', 'GREEN', 'YELLOW', 'PURPLE'];

  late List<_Wire> wires; // 5 条线
  late String ruleText; // 展示规则
  late int correctIndex; // 正确应剪哪一条
  int seconds = maxSeconds;
  bool finished = false;
  bool exploded = false;
  Timer? _ticker;
  final rnd = Random();

  @override
  void initState() {
    super.initState();
    _setupRound();
  }

  void _setupRound() {
    // 随机生成 5 条线：颜色、编号（1~9）、字母标签
    wires = List.generate(5, (i) {
      final num = rnd.nextInt(9) + 1;
      return _Wire(
        color: _colors[i],
        label: _labels[i],
        number: num,
      );
    })..shuffle(rnd);

    // 随机选择规则并求解
    final rules = <_Rule>[
      _ruleEarliestAlphabet,
      _ruleLatestAlphabet,
      _ruleSmallestNumber,
      _ruleLargestNumber,
      _ruleSumEven,
      _ruleRedBeatsBlue,
    ];
    final pick = rules[rnd.nextInt(rules.length)];
    final result = pick(wires);
    ruleText = result.text;       // ← 不再使用 $1 / $2
    correctIndex = result.index;  // ← 使用命名属性

    // 计时器
    seconds = maxSeconds;
    finished = false;
    exploded = false;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || finished) return;
      setState(() {
        seconds--;
        if (seconds <= 0) {
          seconds = 0;
          exploded = true;
          finished = true;
          _ticker?.cancel();
        }
      });
    });
    setState(() {});
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _cut(int index) async {
    if (finished) return;
    if (index == correctIndex) {
      finished = true;
      _ticker?.cancel();
      await ref.read(pointsServiceProvider).add(reward);
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('已成功拆彈！'),
          content: Text('獲得 $reward 積分'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _setupRound();
                },
                child: const Text('再來一局')),
            FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('返回')),
          ],
        ),
      );
    } else {
      setState(() {
        seconds = (seconds - penalty).clamp(0, maxSeconds);
        if (seconds == 0) {
          exploded = true;
          finished = true;
          _ticker?.cancel();
        }
      });
      if (mounted && !finished) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('錯誤！扣 $penalty 秒，剩餘 $seconds 秒')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final danger =
        exploded ? Colors.red : (seconds <= 10 ? Colors.orange : Colors.green);
    return Scaffold(
      appBar: AppBar(
        title: const Text('拆炸彈'),
        actions: [
          IconButton(
              onPressed: _setupRound,
              icon: const Icon(Icons.refresh),
              tooltip: '重新布置'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 倒计时
            Row(
              children: [
                Icon(Icons.timer_outlined, color: danger),
                const SizedBox(width: 8),
                Text('$seconds s',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                            color: danger, fontWeight: FontWeight.w700)),
                const Spacer(),
                if (finished && exploded)
                  const Chip(
                      label: Text('爆炸了！',
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red)
                else if (finished)
                  const Chip(
                      label: Text('成功拆彈'), backgroundColor: Colors.green)
              ],
            ),
            const SizedBox(height: 12),
            // 规则提示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('規則：$ruleText',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 16),
            // “炸弹”主体
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: _BombBox(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        _SevenSeg(seconds: seconds),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.separated(
                            itemCount: wires.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final w = wires[i];
                              final isCorrect =
                                  i == correctIndex && finished && !exploded;
                              final isWrong =
                                  i != correctIndex && finished && exploded;
                              return _WireTile(
                                wire: w,
                                highlight: isCorrect
                                    ? Colors.green
                                    : (isWrong ? Colors.red : null),
                                onCut: () => _cut(i),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text('點擊任意一條引線以剪斷；剪錯會扣 $penalty 秒。',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// ---------- 规则：用类取代 records ----------
typedef _Rule = _RuleResult Function(List<_Wire>);

class _RuleResult {
  final String text;
  final int index;
  const _RuleResult(this.text, this.index);
}

_RuleResult _ruleEarliestAlphabet(List<_Wire> ws) {
  final labels = ws.map((e) => e.label).toList()..sort();
  final idx = ws.indexWhere((w) => w.label == labels.first);
  return _RuleResult('剪掉【字母序最靠前】的線（按標籤英文）', idx);
}

_RuleResult _ruleLatestAlphabet(List<_Wire> ws) {
  final labels = ws.map((e) => e.label).toList()..sort();
  final idx = ws.indexWhere((w) => w.label == labels.last);
  return _RuleResult('剪掉【字母序最靠後】的線', idx);
}

_RuleResult _ruleSmallestNumber(List<_Wire> ws) {
  final minNum = ws.map((e) => e.number).reduce(min);
  final idx = ws.indexWhere((w) => w.number == minNum);
  return _RuleResult('剪掉【數字最小】的線', idx);
}

_RuleResult _ruleLargestNumber(List<_Wire> ws) {
  final maxNum = ws.map((e) => e.number).reduce(max);
  final idx = ws.indexWhere((w) => w.number == maxNum);
  return _RuleResult('剪掉【數字最大】的線', idx);
}

_RuleResult _ruleSumEven(List<_Wire> ws) {
  final sum = ws.fold<int>(0, (p, e) => p + e.number);
  if (sum % 2 == 0) {
    final idx = ws.indexWhere((w) => w.number % 2 == 0 && w.label != 'YELLOW');
    return _RuleResult(
        '若所有數字總和為偶數，剪【第一條 偶數 且非黃色】的線', idx >= 0 ? idx : 0);
  } else {
    final idx = ws.indexWhere((w) => w.number % 2 == 1 && w.label != 'RED');
    return _RuleResult(
        '若總和為奇數，剪【第一條 奇數 且非紅色】的線', idx >= 0 ? idx : 0);
  }
}

_RuleResult _ruleRedBeatsBlue(List<_Wire> ws) {
  final red = ws.indexWhere((w) => w.label == 'RED');
  final blue = ws.indexWhere((w) => w.label == 'BLUE');
  if (red >= 0 && blue >= 0) {
    if (ws[red].number < ws[blue].number) {
      return _RuleResult('若紅與藍同時存在且紅號碼更小，剪【紅色】', red);
    }
  }
  final minNum = ws.map((e) => e.number).reduce(min);
  final idx = ws.indexWhere((w) => w.number == minNum);
  return _RuleResult('否則剪【數字最小】的線', idx);
}

/// ---------- UI 组件 ----------
class _BombBox extends StatelessWidget {
  final Widget child;
  const _BombBox({required this.child});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.25), blurRadius: 16)],
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

class _SevenSeg extends StatelessWidget {
  final int seconds;
  const _SevenSeg({required this.seconds});
  @override
  Widget build(BuildContext context) {
    final txt = seconds.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Text(
        txt,
        style: const TextStyle(
          fontFamily: 'Courier',
          color: Color(0xFFE53935),
          fontSize: 40,
          letterSpacing: 2,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _WireTile extends StatelessWidget {
  final _Wire wire;
  final Color? highlight;
  final VoidCallback onCut;
  const _WireTile({required this.wire, required this.onCut, this.highlight});

  @override
  Widget build(BuildContext context) {
    final cardColor = highlight ?? Theme.of(context).colorScheme.surface;
    return Card(
      color: cardColor,
      child: InkWell(
        onTap: onCut,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 10,
                decoration: BoxDecoration(
                  color: wire.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text('${wire.label}  #${wire.number}',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              const Icon(Icons.content_cut),
            ],
          ),
        ),
      ),
    );
  }
}

class _Wire {
  final Color color;
  final String label;
  final int number;
  _Wire({required this.color, required this.label, required this.number});
}
