import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../points_adapter.dart';

class MazeGamePage extends ConsumerStatefulWidget {
  const MazeGamePage({super.key});
  @override
  ConsumerState<MazeGamePage> createState() => _MazeGamePageState();
}

class _MazeGamePageState extends ConsumerState<MazeGamePage> {
  static const rewardPoints = 50;
  static const rows = 15;
  static const cols = 11;

  late List<List<_Cell>> grid;
  late _Pos start, goal;
  late _Pos player;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    // 初始化格子（全封闭）
    grid = List.generate(rows, (r) => List.generate(cols, (c) => _Cell(r, c)));
    // 随机 DFS 挖墙生成迷宫
    final rnd = Random();
    void dfs(int r, int c) {
      grid[r][c].visited = true;
      final dirs = [
        const _Dir(0, -1, 'L'), const _Dir(0, 1, 'R'),
        const _Dir(-1, 0, 'U'), const _Dir(1, 0, 'D'),
      ]..shuffle(rnd);
      for (final d in dirs) {
        final nr = r + d.dr * 2, nc = c + d.dc * 2;
        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && !grid[nr][nc].visited) {
          // 打通当前格与两格外的格（中间格也打通）
          grid[r + d.dr][c + d.dc].wall = false;
          grid[nr][nc].wall = false;
          dfs(nr, nc);
        }
      }
    }
    // 初始全是墙，挑偶数坐标作为路径候选
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        grid[r][c].wall = true;
        grid[r][c].visited = false;
      }
    }
    // 把所有偶数格子先置为路，再 DFS 打通
    for (var r = 0; r < rows; r += 2) {
      for (var c = 0; c < cols; c += 2) {
        grid[r][c].wall = false;
      }
    }
    dfs(0, 0);

    start = const _Pos(0, 0);
    goal  = _Pos(rows - 1, cols - 1);
    player = start;
    setState((){});
  }

  bool _canMove(_Pos p) {
    return p.r >= 0 && p.r < rows && p.c >= 0 && p.c < cols && !grid[p.r][p.c].wall;
  }

  Future<void> _move(int dr, int dc) async {
    final next = _Pos(player.r + dr, player.c + dc);
    if (_canMove(next)) {
      setState(() => player = next);
      if (player == goal) {
        await ref.read(pointsServiceProvider).add(rewardPoints);
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('恭喜！'),
            content: Text('走出迷宮，獲得 $rewardPoints 積分'),
            actions: [
              TextButton(onPressed: () { Navigator.pop(context); _generate(); }, child: const Text('再來一局')),
              FilledButton(onPressed: () => Navigator.pop(context), child: const Text('返回')),
            ],
          ),
        );
      }
    }
  }

  void _onSwipe(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond;
    if (v.distance < 50) return;
    if (v.dx.abs() > v.dy.abs()) {
      _move(0, v.dx > 0 ? 1 : -1);
    } else {
      _move(v.dy > 0 ? 1 : -1, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = 22.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('走迷宮'),
        actions: [
          IconButton(onPressed: _generate, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: GestureDetector(
                onHorizontalDragEnd: _onSwipe,
                onVerticalDragEnd: _onSwipe,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
                  ),
                  child: CustomPaint(
                    size: Size(cols * cellSize, rows * cellSize),
                    painter: _MazePainter(grid: grid, start: start, goal: goal, player: player, cell: cellSize),
                  ),
                ),
              ),
            ),
          ),
          // 方向按钮（移动端更友好）
          Padding(
            padding: const EdgeInsets.only(bottom: 14, top: 6),
            child: _Dpad(onMove: _move),
          ),
        ],
      ),
    );
  }
}

class _MazePainter extends CustomPainter {
  final List<List<_Cell>> grid;
  final _Pos start, goal, player;
  final double cell;
  _MazePainter({required this.grid, required this.start, required this.goal, required this.player, required this.cell});

  @override
  void paint(Canvas canvas, Size size) {
    final wallPaint = Paint()..color = const Color(0xFF2E2E2E);
    final pathPaint = Paint()..color = const Color(0xFFEFEFEF);
    final startPaint = Paint()..color = const Color(0xFF81C784);
    final goalPaint  = Paint()..color = const Color(0xFF64B5F6);
    final playerPaint= Paint()..color = const Color(0xFFF06292);

    for (var r = 0; r < grid.length; r++) {
      for (var c = 0; c < grid[r].length; c++) {
        final rect = Rect.fromLTWH(c * cell, r * cell, cell-1, cell-1);
        canvas.drawRect(rect, grid[r][c].wall ? wallPaint : pathPaint);
      }
    }
    // start/goal
    canvas.drawRect(Rect.fromLTWH(start.c * cell, start.r * cell, cell-1, cell-1), startPaint);
    canvas.drawRect(Rect.fromLTWH(goal.c  * cell, goal.r  * cell, cell-1, cell-1), goalPaint);
    // player
    final pr = Rect.fromLTWH(player.c * cell + 3, player.r * cell + 3, cell-7, cell-7);
    canvas.drawRRect(RRect.fromRectAndRadius(pr, const Radius.circular(6)), playerPaint);
  }

  @override
  bool shouldRepaint(covariant _MazePainter old) =>
      old.grid != grid || old.player != player;
}

class _Cell {
  final int r, c;
  bool wall = true;
  bool visited = false;
  _Cell(this.r, this.c);
}

class _Pos {
  final int r, c;
  const _Pos(this.r, this.c);
  @override
  bool operator ==(Object o) => o is _Pos && o.r == r && o.c == c;
  @override
  int get hashCode => Object.hash(r, c);
}

class _Dir {
  final int dr, dc;
  final String name;
  const _Dir(this.dr, this.dc, this.name);
}

class _Dpad extends StatelessWidget {
  final Future<void> Function(int dr, int dc) onMove;
  const _Dpad({required this.onMove, super.key});
  @override
  Widget build(BuildContext context) {
    final s = 56.0;
    return SizedBox(
      width: 3*s, height: 3*s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 0, child: _btn(Icons.keyboard_arrow_up, ()=>onMove(-1, 0), s)),
          Positioned(bottom: 0, child: _btn(Icons.keyboard_arrow_down, ()=>onMove(1, 0), s)),
          Positioned(left: 0, child: _btn(Icons.keyboard_arrow_left, ()=>onMove(0, -1), s)),
          Positioned(right: 0, child: _btn(Icons.keyboard_arrow_right, ()=>onMove(0, 1), s)),
        ],
      ),
    );
  }
  Widget _btn(IconData i, VoidCallback onTap, double s) => SizedBox(
    width: s, height: s,
    child: FilledButton.tonal(onPressed: onTap, child: Icon(i)),
  );
}
