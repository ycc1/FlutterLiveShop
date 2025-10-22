import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BingoCard {
  final List<List<int>> cells;
  BingoCard(this.cells);

  factory BingoCard.random(Random rnd) {
    final nums = List<int>.generate(90, (i) => i + 1)..shuffle(rnd);
    final picked = nums.take(25).toList();
    final grid =
        List.generate(5, (r) => List.generate(5, (c) => picked[r * 5 + c]));
    return BingoCard(grid);
  }

  bool isMarked(int r, int c, Set<int> drawn) => drawn.contains(cells[r][c]);

  bool getBingo(Set<int> drawn) {
    for (int r = 0; r < 5; r++) {
      if (List.generate(5, (c) => isMarked(r, c, drawn)).every((e) => e))
        return true;
    }
    for (int c = 0; c < 5; c++) {
      if (List.generate(5, (r) => isMarked(r, c, drawn)).every((e) => e))
        return true;
    }
    if (List.generate(5, (i) => isMarked(i, i, drawn)).every((e) => e))
      return true;
    if (List.generate(5, (i) => isMarked(i, 4 - i, drawn)).every((e) => e))
      return true;
    return false;
  }
}

class BingoState {
  final List<BingoCard> cards;
  final Set<int> drawn;
  final List<int> history;
  final bool running;
  final int numCards;
  final int? lastNumber;
  final bool hasBingo;

  final int kredit; // 玩家积分
  final int pusta; // 当前下注金额
  final int panalo; // 本轮中奖金额
  final bool showWinAnim; // 控制动画

  const BingoState({
    required this.cards,
    required this.drawn,
    required this.history,
    required this.running,
    required this.numCards,
    required this.lastNumber,
    required this.hasBingo,
    required this.kredit,
    required this.pusta,
    required this.panalo,
    required this.showWinAnim,
  });

  BingoState copyWith({
    List<BingoCard>? cards,
    Set<int>? drawn,
    List<int>? history,
    bool? running,
    int? numCards,
    int? lastNumber,
    bool? hasBingo,
    int? kredit,
    int? pusta,
    int? panalo,
    bool? showWinAnim,
  }) {
    return BingoState(
      cards: cards ?? this.cards,
      drawn: drawn ?? this.drawn,
      history: history ?? this.history,
      running: running ?? this.running,
      numCards: numCards ?? this.numCards,
      lastNumber: lastNumber,
      hasBingo: hasBingo ?? this.hasBingo,
      kredit: kredit ?? this.kredit,
      pusta: pusta ?? this.pusta,
      panalo: panalo ?? this.panalo,
      showWinAnim: showWinAnim ?? this.showWinAnim,
    );
  }

  factory BingoState.initial(Random rnd, {int numCards = 4}) {
    return BingoState(
      cards: List.generate(numCards, (_) => BingoCard.random(rnd)),
      drawn: <int>{},
      history: <int>[],
      running: false,
      numCards: numCards,
      lastNumber: null,
      hasBingo: false,
      kredit: 1000,
      pusta: 5,
      panalo: 0,
      showWinAnim: false,
    );
  }
}

class BingoController extends StateNotifier<BingoState> {
  final Random _rnd = Random();
  Timer? _timer;

  BingoController() : super(BingoState.initial(Random(), numCards: 4));

  void setNumCards(int n) {
    final cards = List.generate(n, (_) => BingoCard.random(_rnd));
    state = state.copyWith(
        cards: cards,
        numCards: n,
        drawn: <int>{},
        history: <int>[],
        lastNumber: null,
        hasBingo: false);
  }

  void changePusta(int delta) {
    final newPusta = (state.pusta + delta).clamp(1, 50);
    state = state.copyWith(pusta: newPusta);
  }

  void shuffleAll() {
    final cards = List.generate(state.numCards, (_) => BingoCard.random(_rnd));
    state = state.copyWith(
        cards: cards,
        drawn: <int>{},
        history: <int>[],
        lastNumber: null,
        hasBingo: false,
        panalo: 0);
  }

  void start() {
    if (state.running || state.kredit < state.pusta) return;
    // 扣除下注
    state = state.copyWith(
      kredit: state.kredit - state.pusta,
      running: true,
      panalo: 0,
      drawn: {},
      history: [],
      hasBingo: false,
      showWinAnim: false,
    );
    _timer?.cancel();
    _timer =
        Timer.periodic(const Duration(milliseconds: 850), (_) => drawOne());
  }

  void drawOne() {
    if (state.hasBingo) return;
    final pool = List<int>.generate(90, (i) => i + 1)
      ..removeWhere(state.drawn.contains);
    if (pool.isEmpty) return;
    final n = pool[_rnd.nextInt(pool.length)];
    final newDrawn = {...state.drawn, n};
    final newHist = [...state.history, n];
    final bingo = state.cards.any((c) => c.getBingo(newDrawn));
    int win = 0;
    bool anim = false;

    if (bingo) {
      win = state.pusta * 10;
      anim = true;
    }

    state = state.copyWith(
      drawn: newDrawn,
      history: newHist,
      lastNumber: n,
      hasBingo: bingo,
      panalo: win,
      kredit: bingo ? state.kredit + win : state.kredit,
      showWinAnim: anim,
    );

    if (bingo) stop();
  }

  void stop() {
    _timer?.cancel();
    state = state.copyWith(running: false);
  }

  void hideWinAnim() {
    state = state.copyWith(showWinAnim: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final bingoProvider = StateNotifierProvider<BingoController, BingoState>((ref) {
  return BingoController();
});
