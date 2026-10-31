import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// App entry
// ─────────────────────────────────────────────

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const BlockBlastLiteApp());
}

class BlockBlastLiteApp extends StatelessWidget {
  const BlockBlastLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Block Blast Lite',
      home: BlockBlastGamePage(),
    );
  }
}

// ─────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────

class AppColors {
  const AppColors._();

  static const Color background = Color(0xFF141838);
  static const Color boardBackground = Color(0xFF0D1026);
  static const Color cellEmpty = Color(0xFF1B224A);
  static const Color dialogBackground = Color(0xFF1B224A);
  static const Color scoreText = Colors.white;
  static const Color recordText = Color(0xFFFBBF24);
  static const Color scorePlusText = Color(0xFFFFD700);
  static const Color flashCell = Color(0xFFFFFFCC);

  static const List<Color> piecePalette = [
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFEAB308), // Yellow
    Color(0xFF22C55E), // Green
    Color(0xFF06B6D4), // Cyan
    Color(0xFF3B82F6), // Blue
    Color(0xFFA855F7), // Purple
  ];
}

// ─────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────

class PieceModel {
  final List<List<int>> matrix;
  final int colorIndex;

  PieceModel(this.matrix, this.colorIndex);

  int get rows => matrix.length;
  int get cols => matrix[0].length;

  Map<String, dynamic> toJson() => {'m': matrix, 'c': colorIndex};

  factory PieceModel.fromJson(Map<String, dynamic> json) {
    final m = (json['m'] as List)
        .map((r) => (r as List).map((e) => e as int).toList())
        .toList();
    return PieceModel(m, json['c'] as int);
  }
}

class DragInfo {
  final int slotIndex;
  final PieceModel piece;
  final Offset globalPos;
  final int? hoverRow;
  final int? hoverCol;

  const DragInfo({
    required this.slotIndex,
    required this.piece,
    required this.globalPos,
    this.hoverRow,
    this.hoverCol,
  });
}

class ScorePopup {
  final int points;
  final Offset position; // screen (global) coords
  final int id;

  const ScorePopup({
    required this.points,
    required this.position,
    required this.id,
  });
}

// ─────────────────────────────────────────────
// Game page – StatefulWidget
// ─────────────────────────────────────────────

class BlockBlastGamePage extends StatefulWidget {
  const BlockBlastGamePage({super.key});

  @override
  State<BlockBlastGamePage> createState() => _BlockBlastGamePageState();
}

class _BlockBlastGamePageState extends State<BlockBlastGamePage> {
  static const int gridSize = 8;

  static const List<List<List<int>>> shapesPool = [
    [[1]],
    [[1, 1]],
    [[1], [1]],
    [[1, 1, 1]],
    [[1], [1], [1]],
    [[1, 1], [1, 0]],
    [[1, 1], [0, 1]],
    [[1, 0], [1, 1]],
    [[0, 1], [1, 1]],
    [[1, 1], [1, 1]],
    [[1, 1, 1, 1]],
    [[1], [1], [1], [1]],
    [[1, 1, 1], [0, 1, 0]],
    [[0, 1, 0], [1, 1, 1]],
    [[1, 1, 0], [0, 1, 1]],
    [[0, 1, 1], [1, 1, 0]],
    [[1, 1, 1], [1, 0, 0]],
    [[1, 1, 1], [0, 0, 1]],
    [
      [1, 1, 1],
      [1, 1, 1],
      [1, 1, 1]
    ],
  ];

  final Random _rng = Random();
  final GlobalKey _boardKey = GlobalKey();

  late List<List<int?>> board;
  List<PieceModel?> dock = [null, null, null];

  int score = 0;
  int bestScore = 0;
  int combo = 0;
  List<Map<String, dynamic>> historyList = [];

  Set<String> _flashCells = {};
  bool _isPlacing = false; // guard against re-entrant placement

  final ValueNotifier<DragInfo?> dragNotifier = ValueNotifier<DragInfo?>(null);
  final ValueNotifier<List<ScorePopup>> popupNotifier =
      ValueNotifier<List<ScorePopup>>([]);
  // Notifier that AnimatedScoreDisplay listens to
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);

  int _nextPopupId = 0;
  Rect? _cachedBoardRect;

  // ── Lifecycle ──────────────────────────────

  @override
  void initState() {
    super.initState();
    board = List.generate(gridSize, (_) => List.filled(gridSize, null));
    _loadSavedState();
  }

  @override
  void dispose() {
    dragNotifier.dispose();
    popupNotifier.dispose();
    scoreNotifier.dispose();
    super.dispose();
  }

  // ── Persistence ────────────────────────────

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    bestScore = prefs.getInt('bb_best') ?? 0;

    final histRaw = prefs.getString('bb_history');
    if (histRaw != null) {
      historyList =
          List<Map<String, dynamic>>.from(jsonDecode(histRaw) as List);
    }

    final savedRaw = prefs.getString('bb_active');
    if (savedRaw != null) {
      try {
        final data = jsonDecode(savedRaw) as Map<String, dynamic>;
        score = (data['score'] as int?) ?? 0;
        combo = (data['combo'] as int?) ?? 0;
        final bList = data['board'] as List;
        for (int r = 0; r < gridSize; r++) {
          for (int c = 0; c < gridSize; c++) {
            board[r][c] = bList[r][c] as int?;
          }
        }
        final dList = data['dock'] as List;
        for (int i = 0; i < 3; i++) {
          dock[i] =
              dList[i] != null ? PieceModel.fromJson(dList[i] as Map<String, dynamic>) : null;
        }
        if (dock.every((p) => p == null)) _spawnDock();
        scoreNotifier.value = score;
        setState(() {});
        return;
      } catch (_) {}
    }
    _startNewGame();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bb_best', bestScore);
    final payload = {
      'score': score,
      'combo': combo,
      'board': board,
      'dock': dock.map((p) => p?.toJson()).toList(),
    };
    await prefs.setString('bb_active', jsonEncode(payload));
  }

  Future<void> _recordHistory() async {
    if (score <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    historyList.insert(0, {
      'score': score,
      'time': DateTime.now().toString().substring(0, 16),
    });
    if (historyList.length > 25) historyList = historyList.sublist(0, 25);
    await prefs.setString('bb_history', jsonEncode(historyList));
  }

  // ── Game logic ─────────────────────────────

  void _startNewGame() {
    board = List.generate(gridSize, (_) => List.filled(gridSize, null));
    score = 0;
    combo = 0;
    _flashCells = {};
    _isPlacing = false;
    _spawnDock();
    _saveState();
    scoreNotifier.value = 0;
    setState(() {});
  }

  void _spawnDock() {
    for (int i = 0; i < 3; i++) {
      final m = shapesPool[_rng.nextInt(shapesPool.length)];
      final c = _rng.nextInt(AppColors.piecePalette.length);
      dock[i] = PieceModel(m, c);
    }
  }

  bool _canPlace(PieceModel piece, int startR, int startC) {
    for (int r = 0; r < piece.rows; r++) {
      for (int c = 0; c < piece.cols; c++) {
        if (piece.matrix[r][c] == 1) {
          final tr = startR + r;
          final tc = startC + c;
          if (tr < 0 || tr >= gridSize || tc < 0 || tc >= gridSize) return false;
          if (board[tr][tc] != null) return false;
        }
      }
    }
    return true;
  }

  bool _isGameOver() {
    for (final p in dock) {
      if (p == null) continue;
      for (int r = 0; r <= gridSize - p.rows; r++) {
        for (int c = 0; c <= gridSize - p.cols; c++) {
          if (_canPlace(p, r, c)) return false;
        }
      }
    }
    return true;
  }

  // ── Drag handlers ──────────────────────────

  void _updateBoardRect() {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final topLeft = box.localToGlobal(Offset.zero);
      _cachedBoardRect = topLeft & box.size;
    }
  }

  void _onDragStart(int slotIdx, DragStartDetails d) {
    if (_isPlacing) return;
    final piece = dock[slotIdx];
    if (piece == null) return;
    _updateBoardRect();
    // Ẩn block khỏi dock ngay khi bắt đầu kéo
    setState(() => dock[slotIdx] = null);
    dragNotifier.value = DragInfo(
      slotIndex: slotIdx,
      piece: piece,
      globalPos: d.globalPosition,
    );
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final cur = dragNotifier.value;
    if (cur == null || _cachedBoardRect == null) return;

    final rect = _cachedBoardRect!;
    final cellSize = rect.width / gridSize;
    const liftY = 80.0;
    final topLeftX = d.globalPosition.dx - (cur.piece.cols * cellSize) / 2;
    final topLeftY =
        d.globalPosition.dy - (cur.piece.rows * cellSize) / 2 - liftY;

    final col =
        ((topLeftX + cellSize / 2 - rect.left) / cellSize).floor();
    final row =
        ((topLeftY + cellSize / 2 - rect.top) / cellSize).floor();

    int? validR;
    int? validC;
    if (_canPlace(cur.piece, row, col)) {
      validR = row;
      validC = col;
    }

    dragNotifier.value = DragInfo(
      slotIndex: cur.slotIndex,
      piece: cur.piece,
      globalPos: d.globalPosition,
      hoverRow: validR,
      hoverCol: validC,
    );
  }

  void _onDragEnd(DragEndDetails d) {
    final cur = dragNotifier.value;
    dragNotifier.value = null;
    if (cur == null) return;
    if (cur.hoverRow != null && cur.hoverCol != null) {
      // Đặt khối hợp lệ → tiến hành place (dock[slot] đã null từ onDragStart)
      _placePiece(cur.slotIndex, cur.piece, cur.hoverRow!, cur.hoverCol!);
    } else {
      // Thả vào chỗ không hợp lệ → trả block về dock
      setState(() => dock[cur.slotIndex] = cur.piece);
    }
  }

  // ── Place piece (async for flash delay) ────

  Future<void> _placePiece(
      int slotIdx, PieceModel piece, int startR, int startC) async {
    if (_isPlacing) return;
    _isPlacing = true;

    // 1. Place cells on the board
    int placed = 0;
    for (int r = 0; r < piece.rows; r++) {
      for (int c = 0; c < piece.cols; c++) {
        if (piece.matrix[r][c] == 1) {
          board[startR + r][startC + c] = piece.colorIndex;
          placed++;
        }
      }
    }
    // dock[slotIdx] đã được set null khi onDragStart, không cần set lại
    score += placed;

    // 2. Detect full rows & cols
    final fullRows = <int>[];
    final fullCols = <int>[];
    for (int r = 0; r < gridSize; r++) {
      if (board[r].every((cell) => cell != null)) fullRows.add(r);
    }
    for (int c = 0; c < gridSize; c++) {
      bool isFull = true;
      for (int r = 0; r < gridSize; r++) {
        if (board[r][c] == null) {
          isFull = false;
          break;
        }
      }
      if (isFull) fullCols.add(c);
    }

    final lines = fullRows.length + fullCols.length;

    // 3. Flash effect before clearing
    if (lines > 0) {
      final flashSet = <String>{};
      for (final r in fullRows) {
        for (int c = 0; c < gridSize; c++) {
          flashSet.add('$r,$c');
        }
      }
      for (final c in fullCols) {
        for (int r = 0; r < gridSize; r++) {
          flashSet.add('$r,$c');
        }
      }
      setState(() => _flashCells = flashSet);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      setState(() => _flashCells = {});
    }

    // 4. Compute score from lines
    if (lines > 0) {
      combo++;
      score += lines * 10 * lines * combo;
      for (final r in fullRows) {
        for (int c = 0; c < gridSize; c++) {
          board[r][c] = null;
        }
      }
      for (final c in fullCols) {
        for (int r = 0; r < gridSize; r++) {
          board[r][c] = null;
        }
      }
    } else {
      combo = 0;
    }

    if (score > bestScore) bestScore = score;
    if (dock.every((p) => p == null)) _spawnDock();

    // 5. Trigger score popup
    _spawnScorePopup(placed, lines, startR, startC, piece);

    // 6. Update score notifier → triggers AnimatedScoreDisplay
    scoreNotifier.value = score;

    _saveState();
    setState(() {});
    _isPlacing = false;

    if (_isGameOver()) {
      _recordHistory();
      _showGameOverDialog();
    }
  }

  void _spawnScorePopup(
      int placed, int lines, int startR, int startC, PieceModel piece) {
    final rect = _cachedBoardRect;
    if (rect == null) return;

    final cellSize = rect.width / gridSize;
    // Centre of the placed piece on screen
    final centerCol = startC + piece.cols / 2.0;
    final centerRow = startR + piece.rows / 2.0;
    final screenX = rect.left + centerCol * cellSize;
    final screenY = rect.top + centerRow * cellSize;

    final totalPoints = placed + (lines > 0 ? lines * 10 * lines * combo : 0);
    final popup = ScorePopup(
      points: totalPoints,
      position: Offset(screenX, screenY),
      id: _nextPopupId++,
    );

    final current = List<ScorePopup>.from(popupNotifier.value)..add(popup);
    popupNotifier.value = current;
  }

  void _removePopup(int id) {
    popupNotifier.value =
        popupNotifier.value.where((p) => p.id != id).toList();
  }

  // ── Dialog ─────────────────────────────────

  void _showGameOverDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: const Text('Hết nước đi!',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Điểm: $score\nKỷ lục: $bestScore',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewGame();
            },
            child: const Text('Chơi lại'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GameHeader(
                    bestScore: bestScore,
                    onReset: () {
                      _recordHistory();
                      _startNewGame();
                    },
                  ),
                  AnimatedScoreDisplay(scoreNotifier: scoreNotifier),
                  // Board
                  RepaintBoundary(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        key: _boardKey,
                        decoration: BoxDecoration(
                          color: AppColors.boardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ValueListenableBuilder<DragInfo?>(
                          valueListenable: dragNotifier,
                          builder: (_, drag, __) => CustomPaint(
                            painter: BoardPainter(
                              board: board,
                              drag: drag,
                              flashCells: _flashCells,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  DockRow(
                    dock: dock,
                    onDragStart: _onDragStart,
                    onDragUpdate: _onDragUpdate,
                    onDragEnd: _onDragEnd,
                  ),
                ],
              ),
            ),
          ),
          // Drag ghost layer
          DragLayer(
            dragNotifier: dragNotifier,
            cachedBoardRect: _cachedBoardRect,
            gridSize: gridSize,
          ),
          // Score popup layer
          ScorePopupLayer(
            popupNotifier: popupNotifier,
            onPopupDone: _removePopup,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widgets – StatelessWidget
// ─────────────────────────────────────────────

class GameHeader extends StatelessWidget {
  final int bestScore;
  final VoidCallback onReset;

  const GameHeader({
    super.key,
    required this.bestScore,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'KỶ LỤC: $bestScore',
          style: const TextStyle(
            color: AppColors.recordText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        IconButton(
          onPressed: onReset,
          icon: const Icon(Icons.refresh, color: Colors.white),
        ),
      ],
    );
  }
}

class DockRow extends StatelessWidget {
  final List<PieceModel?> dock;
  final void Function(int, DragStartDetails) onDragStart;
  final void Function(DragUpdateDetails) onDragUpdate;
  final void Function(DragEndDetails) onDragEnd;

  const DockRow({
    super.key,
    required this.dock,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Row(
        children: List.generate(3, (i) {
          final p = dock[i];
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) => onDragStart(i, d),
              onPanUpdate: onDragUpdate,
              onPanEnd: onDragEnd,
              child: Center(
                child: p == null
                    ? const SizedBox()
                    : CustomPaint(
                        size: Size(p.cols * 20.0, p.rows * 20.0),
                        painter: PiecePainter(
                          piece: p,
                          color: AppColors.piecePalette[p.colorIndex],
                        ),
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class DragLayer extends StatelessWidget {
  final ValueNotifier<DragInfo?> dragNotifier;
  final Rect? cachedBoardRect;
  final int gridSize;

  const DragLayer({
    super.key,
    required this.dragNotifier,
    required this.cachedBoardRect,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: ValueListenableBuilder<DragInfo?>(
          valueListenable: dragNotifier,
          builder: (_, drag, __) {
            if (drag == null || cachedBoardRect == null) {
              return const SizedBox.shrink();
            }
            final cellSize = cachedBoardRect!.width / gridSize;
            final w = drag.piece.cols * cellSize;
            final h = drag.piece.rows * cellSize;
            return Stack(
              children: [
                Positioned(
                  left: drag.globalPos.dx - w / 2,
                  top: drag.globalPos.dy - h / 2 - 80.0,
                  child: CustomPaint(
                    size: Size(w, h),
                    painter: PiecePainter(
                      piece: drag.piece,
                      color: AppColors.piecePalette[drag.piece.colorIndex],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// AnimatedScoreDisplay – scale pop on change
// ─────────────────────────────────────────────

class AnimatedScoreDisplay extends StatefulWidget {
  final ValueNotifier<int> scoreNotifier;

  const AnimatedScoreDisplay({super.key, required this.scoreNotifier});

  @override
  State<AnimatedScoreDisplay> createState() => _AnimatedScoreDisplayState();
}

class _AnimatedScoreDisplayState extends State<AnimatedScoreDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.25)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: 1.25, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50),
    ]).animate(_ctrl);

    widget.scoreNotifier.addListener(_onScoreChanged);
  }

  void _onScoreChanged() {
    if (!mounted) return;
    _ctrl.forward(from: 0);
    setState(() {});
  }

  @override
  void dispose() {
    widget.scoreNotifier.removeListener(_onScoreChanged);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, __) => Transform.scale(
        scale: _scaleAnim.value,
        child: Text(
          '${widget.scoreNotifier.value}',
          style: const TextStyle(
            color: AppColors.scoreText,
            fontSize: 46,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ScorePopupLayer – float-up & fade-out
// ─────────────────────────────────────────────

class ScorePopupLayer extends StatelessWidget {
  final ValueNotifier<List<ScorePopup>> popupNotifier;
  final void Function(int id) onPopupDone;

  const ScorePopupLayer({
    super.key,
    required this.popupNotifier,
    required this.onPopupDone,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<List<ScorePopup>>(
        valueListenable: popupNotifier,
        builder: (_, popups, __) {
          return Stack(
            children: popups
                .map((p) => _ScorePopupItem(
                      key: ValueKey(p.id),
                      popup: p,
                      onDone: onPopupDone,
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

class _ScorePopupItem extends StatefulWidget {
  final ScorePopup popup;
  final void Function(int id) onDone;

  const _ScorePopupItem({super.key, required this.popup, required this.onDone});

  @override
  State<_ScorePopupItem> createState() => _ScorePopupItemState();
}

class _ScorePopupItemState extends State<_ScorePopupItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _offsetAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _offsetAnim = Tween<double>(begin: 0, end: -60).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50),
    ]).animate(_ctrl);

    _ctrl.forward().then((_) => widget.onDone(widget.popup.id));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Positioned(
        left: widget.popup.position.dx - 30,
        top: widget.popup.position.dy + _offsetAnim.value,
        child: Opacity(
          opacity: _opacityAnim.value.clamp(0.0, 1.0),
          child: Text(
            '+${widget.popup.points}',
            style: const TextStyle(
              color: AppColors.scorePlusText,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(1, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Painters
// ─────────────────────────────────────────────

class BoardPainter extends CustomPainter {
  final List<List<int?>> board;
  final DragInfo? drag;
  final Set<String> flashCells;

  const BoardPainter({
    required this.board,
    this.drag,
    this.flashCells = const {},
  });

  static const int _gridSize = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / _gridSize;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int r = 0; r < _gridSize; r++) {
      for (int c = 0; c < _gridSize; c++) {
        final rect = Rect.fromLTWH(
            c * cellW + 2, r * cellW + 2, cellW - 4, cellW - 4);
        final colorIdx = board[r][c];
        final isFlashing = flashCells.contains('$r,$c');

        if (isFlashing) {
          paint.color = AppColors.flashCell;
        } else if (colorIdx != null) {
          paint.color = AppColors.piecePalette[colorIdx];
        } else {
          paint.color = AppColors.cellEmpty;
        }

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(5)),
          paint,
        );
      }
    }

    // Hover preview
    final d = drag;
    if (d != null && d.hoverRow != null && d.hoverCol != null) {
      paint.color = AppColors.piecePalette[d.piece.colorIndex]
          .withValues(alpha: 0.45);
      for (int r = 0; r < d.piece.rows; r++) {
        for (int c = 0; c < d.piece.cols; c++) {
          if (d.piece.matrix[r][c] == 1) {
            final tr = d.hoverRow! + r;
            final tc = d.hoverCol! + c;
            final rect = Rect.fromLTWH(
                tc * cellW + 2, tr * cellW + 2, cellW - 4, cellW - 4);
            canvas.drawRRect(
              RRect.fromRectAndRadius(rect, const Radius.circular(5)),
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) =>
      oldDelegate.board != board ||
      oldDelegate.drag != drag ||
      oldDelegate.flashCells != flashCells;
}

class PiecePainter extends CustomPainter {
  final PieceModel piece;
  final Color color;

  const PiecePainter({required this.piece, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / piece.cols;
    final cellH = size.height / piece.rows;
    final paint = Paint()..color = color;

    for (int r = 0; r < piece.rows; r++) {
      for (int c = 0; c < piece.cols; c++) {
        if (piece.matrix[r][c] == 1) {
          final rect = Rect.fromLTWH(
              c * cellW + 1.5, r * cellH + 1.5, cellW - 3, cellH - 3);
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PiecePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.piece != piece;
}
