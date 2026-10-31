import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  DragInfo({
    required this.slotIndex,
    required this.piece,
    required this.globalPos,
    this.hoverRow,
    this.hoverCol,
  });
}

class BlockBlastGamePage extends StatefulWidget {
  const BlockBlastGamePage({super.key});
  @override
  State<BlockBlastGamePage> createState() => _BlockBlastGamePageState();
}

class _BlockBlastGamePageState extends State<BlockBlastGamePage> {
  static const int gridSize = 8;
  static const List<Color> palette = [
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFEAB308), // Yellow
    Color(0xFF22C55E), // Green
    Color(0xFF06B6D4), // Cyan
    Color(0xFF3B82F6), // Blue
    Color(0xFFA855F7), // Purple
  ];

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
    [[1, 1, 1], [1, 1, 1], [1, 1, 1]],
  ];

  final Random _rng = Random();
  final GlobalKey _boardKey = GlobalKey();
  late List<List<int?>> board;
  List<PieceModel?> dock = [null, null, null];

  int score = 0;
  int bestScore = 0;
  int combo = 0;
  List<Map<String, dynamic>> historyList = [];

  // ValueNotifier chỉ cập nhật lớp kéo, KHÔNG gọi setState toàn màn hình!
  final ValueNotifier<DragInfo?> dragNotifier = ValueNotifier<DragInfo?>(null);

  Rect? _cachedBoardRect;

  @override
  void initState() {
    super.initState();
    board = List.generate(gridSize, (_) => List.filled(gridSize, null));
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    bestScore = prefs.getInt('bb_best') ?? 0;
    final histRaw = prefs.getString('bb_history');
    if (histRaw != null) {
      historyList = List<Map<String, dynamic>>.from(jsonDecode(histRaw));
    }

    final savedRaw = prefs.getString('bb_active');
    if (savedRaw != null) {
      try {
        final data = jsonDecode(savedRaw);
        score = data['score'] ?? 0;
        combo = data['combo'] ?? 0;
        final bList = data['board'] as List;
        for (int r = 0; r < gridSize; r++) {
          for (int c = 0; c < gridSize; c++) {
            board[r][c] = bList[r][c] as int?;
          }
        }
        final dList = data['dock'] as List;
        for (int i = 0; i < 3; i++) {
          dock[i] = dList[i] != null ? PieceModel.fromJson(dList[i]) : null;
        }
        if (dock.every((p) => p == null)) _spawnDock();
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

  void _startNewGame() {
    board = List.generate(gridSize, (_) => List.filled(gridSize, null));
    score = 0;
    combo = 0;
    _spawnDock();
    _saveState();
    setState(() {});
  }

  void _spawnDock() {
    for (int i = 0; i < 3; i++) {
      final m = shapesPool[_rng.nextInt(shapesPool.length)];
      final c = _rng.nextInt(palette.length);
      dock[i] = PieceModel(m, c);
    }
  }

  void _updateBoardRect() {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final topLeft = box.localToGlobal(Offset.zero);
      _cachedBoardRect = topLeft & box.size;
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

  void _onDragStart(int slotIdx, DragStartDetails d) {
    final piece = dock[slotIdx];
    if (piece == null) return;
    _updateBoardRect();
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
    final topLeftY = d.globalPosition.dy - (cur.piece.rows * cellSize) / 2 - liftY;

    final col = ((topLeftX + cellSize / 2 - rect.left) / cellSize).floor();
    final row = ((topLeftY + cellSize / 2 - rect.top) / cellSize).floor();

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
      _placePiece(cur.slotIndex, cur.piece, cur.hoverRow!, cur.hoverCol!);
    }
  }

  void _placePiece(int slotIdx, PieceModel piece, int startR, int startC) {
    int placed = 0;
    for (int r = 0; r < piece.rows; r++) {
      for (int c = 0; c < piece.cols; c++) {
        if (piece.matrix[r][c] == 1) {
          board[startR + r][startC + c] = piece.colorIndex;
          placed++;
        }
      }
    }
    dock[slotIdx] = null;
    score += placed;

    final fullRows = <int>[];
    final fullCols = <int>[];
    for (int r = 0; r < gridSize; r++) {
      if (board[r].every((cell) => cell != null)) fullRows.add(r);
    }
    for (int c = 0; c < gridSize; c++) {
      bool full = true;
      for (int r = 0; r < gridSize; r++) {
        if (board[r][c] == null) {
          full = false;
          break;
        }
      }
      if (full) fullCols.add(c);
    }

    final lines = fullRows.length + fullCols.length;
    if (lines > 0) {
      combo++;
      score += lines * 10 * lines * combo;
      for (final r in fullRows) {
        for (int c = 0; c < gridSize; c++) board[r][c] = null;
      }
      for (final c in fullCols) {
        for (int r = 0; r < gridSize; r++) board[r][c] = null;
      }
    } else {
      combo = 0;
    }

    if (score > bestScore) bestScore = score;
    if (dock.every((p) => p == null)) _spawnDock();
    _saveState();
    setState(() {});

    if (_isGameOver()) {
      _recordHistory();
      _showGameOverDialog();
    }
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

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B224A),
        title: const Text('Hết nước đi!', style: TextStyle(color: Colors.white)),
        content: Text('Điểm: $score\nKỷ lục: $bestScore',
            style: const TextStyle(color: Colors.white70, fontSize: 16)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewGame();
            },
            child: const Text('Chơi lại'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141838),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('KỶ LỤC: $bestScore',
                          style: const TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      IconButton(
                        onPressed: () {
                          _recordHistory();
                          _startNewGame();
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white),
                      ),
                    ],
                  ),
                  Text('$score',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 46,
                          fontWeight: FontWeight.w900)),
                  // RepaintBoundary tách biệt bàn cờ 8x8
                  RepaintBoundary(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        key: _boardKey,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1026),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ValueListenableBuilder<DragInfo?>(
                          valueListenable: dragNotifier,
                          builder: (_, drag, __) {
                            return CustomPaint(
                              painter: BoardPainter(
                                board: board,
                                palette: palette,
                                drag: drag,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Khay 3 khối gạch dưới
                  SizedBox(
                    height: 110,
                    child: Row(
                      children: List.generate(3, (i) {
                        final p = dock[i];
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanStart: (d) => _onDragStart(i, d),
                            onPanUpdate: _onDragUpdate,
                            onPanEnd: _onDragEnd,
                            child: Center(
                              child: p == null
                                  ? const SizedBox()
                                  : CustomPaint(
                                      size: Size(p.cols * 20.0, p.rows * 20.0),
                                      painter: PiecePainter(
                                          piece: p,
                                          color: palette[p.colorIndex]),
                                    ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Lớp vẽ khối đang kéo độc lập hoàn toàn
          RepaintBoundary(
            child: IgnorePointer(
              child: ValueListenableBuilder<DragInfo?>(
                valueListenable: dragNotifier,
                builder: (_, drag, __) {
                  if (drag == null || _cachedBoardRect == null) {
                    return const SizedBox.shrink();
                  }
                  final cellSize = _cachedBoardRect!.width / gridSize;
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
                            color: palette[drag.piece.colorIndex],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  final List<List<int?>> board;
  final List<Color> palette;
  final DragInfo? drag;
  BoardPainter({required this.board, required this.palette, this.drag});

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / 8;
    final paint = Paint()..style = PaintingStyle.fill;
    final emptyColor = const Color(0xFF1B224A);

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final rect = Rect.fromLTWH(
            c * cellW + 2, r * cellW + 2, cellW - 4, cellW - 4);
        final colorIdx = board[r][c];
        paint.color = colorIdx != null ? palette[colorIdx] : emptyColor;
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(5)), paint);
      }
    }

    if (drag != null && drag!.hoverRow != null && drag!.hoverCol != null) {
      paint.color = palette[drag!.piece.colorIndex].withOpacity(0.45);
      for (int r = 0; r < drag!.piece.rows; r++) {
        for (int c = 0; c < drag!.piece.cols; c++) {
          if (drag!.piece.matrix[r][c] == 1) {
            final tr = drag!.hoverRow! + r;
            final tc = drag!.hoverCol! + c;
            final rect = Rect.fromLTWH(
                tc * cellW + 2, tr * cellW + 2, cellW - 4, cellW - 4);
            canvas.drawRRect(
                RRect.fromRectAndRadius(rect, const Radius.circular(5)), paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter old) => true;
}

class PiecePainter extends CustomPainter {
  final PieceModel piece;
  final Color color;
  PiecePainter({required this.piece, required this.color});

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
              RRect.fromRectAndRadius(rect, const Radius.circular(4)), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PiecePainter old) => false;
}