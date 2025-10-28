import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class BingoController extends ChangeNotifier {
  static const rows = 5, cols = 5;
  static const minN = 1, maxN = 90;
  static const cardCount = 4;

  int credit = 1000;
  int bet = 20;
  int? selectedIndex;
  int winThisRound = 0;

  List<List<List<int>>> cards = [];
  Set<int> drawn = {};
  bool running = false;

  Timer? _timer;

  BingoController() {
    _generateCards();
  }

  void _generateCards() {
    final rng = Random();
    cards = List.generate(cardCount, (_) {
      final s = <int>{};
      while (s.length < rows * cols) {
        s.add(minN + rng.nextInt(maxN - minN + 1));
      }
      final list = s.toList();
      return List.generate(
          rows, (r) => List.generate(cols, (c) => list[r * cols + c]));
    });
    drawn.clear();
    running = false;
    selectedIndex = null;
    winThisRound = 0;
    notifyListeners();
  }

  void selectCard(int index) {
    if (running) return;
    selectedIndex = index;
    notifyListeners();
  }

  void startGame() {
    if (selectedIndex == null || running) return;
    credit -= bet;
    running = true;
    notifyListeners();

    final bag = List.generate(maxN - minN + 1, (i) => minN + i);
    final rng = Random();

    _timer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (bag.isEmpty) {
        stopGame();
        return;
      }
      final n = bag.removeAt(rng.nextInt(bag.length));
      drawn.add(n);

      final winner = _checkWinner();
      if (winner != null) {
        stopGame();
        final win = (winner == selectedIndex);
        if (win) {
          credit += bet * 11; // 返还本金+奖励
          winThisRound = bet * 10;
        }
        notifyListeners();
      } else {
        notifyListeners();
      }
    });
  }

  void stopGame() {
    running = false;
    _timer?.cancel();
    notifyListeners();
  }

  void increaseBet() {
    if (bet >= 10)
      bet += 10;
    else if (bet > 1) bet++;
    notifyListeners();
  }

  void decreaseBet() {
    if (bet > 10)
      bet -= 10;
    else if (bet > 1) bet--;
    notifyListeners();
  }

  int? _checkWinner() {
    for (int i = 0; i < cards.length; i++) {
      if (_isBingo(cards[i])) return i;
    }
    return null;
  }

  bool cardIsWinner(int index) => _isBingo(cards[index]);

  bool _isBingo(List<List<int>> c) {
    for (int r = 0; r < rows; r++) {
      if (c[r].every(drawn.contains)) return true;
    }
    for (int cIndex = 0; cIndex < cols; cIndex++) {
      bool ok = true;
      for (int r = 0; r < rows; r++) {
        if (!drawn.contains(c[r][cIndex])) {
          ok = false;
          break;
        }
      }
      if (ok) return true;
    }
    bool d1 = true, d2 = true;
    for (int i = 0; i < rows; i++) {
      d1 &= drawn.contains(c[i][i]);
      d2 &= drawn.contains(c[i][cols - 1 - i]);
    }
    return d1 || d2;
  }

  void changeNumbers() => _generateCards();
}
