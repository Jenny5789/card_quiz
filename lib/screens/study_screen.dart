import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/app_settings.dart';
import '../services/storage_service.dart';
import '../models/deck.dart';
import '../models/card_item.dart';
import 'result_screen.dart';

class StudyScreen extends StatefulWidget {
  final Deck deck;
  final Function(int, int, Deck) onComplete;

  const StudyScreen({
    super.key,
    required this.deck,
    required this.onComplete,
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late List<CardItem> _cards;
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _correctCount = 0;
  int _wrongCount = 0;
  final List<CardItem> _wrongCards = [];
  final List<bool?> _answers = [];

  String? _overlayEmoji;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _initCards();
  }

  void _initCards() {
    final settings = context.read<AppSettings>();
    final direction = settings.studyDirection;

    if (direction == '랜덤') {
      _cards = List.from(widget.deck.cards)..shuffle();
    } else if (direction == '뒤→앞') {
      _cards = widget.deck.cards.map((c) =>
        CardItem(front: c.back, back: c.front, wrongCount: c.wrongCount)
      ).toList();
    } else {
      _cards = List.from(widget.deck.cards);
    }
    _answers.clear();
    for (int i = 0; i < _cards.length; i++) {
      _answers.add(null);
    }
  }

  void _flip() {
    setState(() => _isFlipped = !_isFlipped);
  }

  void _showResultOverlay(bool isCorrect) {
    setState(() {
      _overlayEmoji = isCorrect ? '⭕' : '❌';
      _showOverlay = true;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showOverlay = false);
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            if (isCorrect) {
              _doCorrect();
            } else {
              _doWrong();
            }
          }
        });
      }
    });
  }

  void _correct() => _showResultOverlay(true);
  void _wrong() => _showResultOverlay(false);

  void _doCorrect() {
    if (_answers[_currentIndex] == false) {
      _wrongCards.removeWhere((c) => c.front == _cards[_currentIndex].front);
      _wrongCount--;
    } else if (_answers[_currentIndex] == null) {
      _correctCount++;
    }
    _answers[_currentIndex] = true;
    setState(() {});
    _next();
  }

  void _doWrong() {
    if (_answers[_currentIndex] == true) {
      _correctCount--;
    } else if (_answers[_currentIndex] == null) {
      _wrongCount++;
      _wrongCards.add(_cards[_currentIndex]);
    }
    _answers[_currentIndex] = false;
    setState(() {});
    _next();
  }

  void _next() {
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    } else {
      StorageService.clearProgress();
      widget.onComplete(_correctCount, _wrongCount, widget.deck);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            deck: widget.deck,
            correctCount: _correctCount,
            wrongCount: _wrongCount,
            wrongCards: _wrongCards,
            onComplete: widget.onComplete,
          ),
        ),
      );
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final card = _cards[_currentIndex];

    return Scaffold(
      backgroundColor: JejuColors.bg,
      appBar: AppBar(
        backgroundColor: JejuColors.accent,
        foregroundColor: Colors.white,
        title: Text(widget.deck.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('학습 종료',
                  textAlign: TextAlign.center),
              content: const Text(
                '학습을 종료할까요?\n진행 상황이 저장되지 않아요.',
                textAlign: TextAlign.center,
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                    child: const Text('계속하기'),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white),
                    child: const Text('종료'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _cards.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(JejuColors.main),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_currentIndex + 1} / ${_cards.length}',
                        style: const TextStyle(color: Colors.grey)),
                    Row(
                      children: [
                        const Icon(Icons.check, color: Colors.green, size: 16),
                        Text(' $_correctCount  ',
                            style: const TextStyle(color: Colors.green)),
                        const Icon(Icons.close, color: Colors.red, size: 16),
                        Text(' $_wrongCount',
                            style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: GestureDetector(
                    onTap: _isFlipped || _showOverlay ? null : _flip,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(_isFlipped),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _isFlipped ? JejuColors.main : JejuColors.card,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isFlipped ? '뒷면' : '앞면',
                              style: TextStyle(
                                fontSize: 14,
                                color: _isFlipped
                                    ? Colors.white70
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24),
                              child: Text(
                                _isFlipped ? card.back : card.front,
                                style: TextStyle(
                                  fontSize: settings.fontSize + 8,
                                  fontWeight: FontWeight.bold,
                                  color: _isFlipped
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (!_isFlipped)
                              const Text(
                                '탭해서 뒤집기',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!_showOverlay)
                  Row(
                    children: [
                      if (_currentIndex > 0)
                        IconButton(
                          onPressed: _prev,
                          icon: const Icon(Icons.arrow_back_ios),
                          color: JejuColors.main,
                          iconSize: 28,
                        ),
                      if (_currentIndex > 0) const SizedBox(width: 8),
                      if (_isFlipped) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _wrong,
                            icon: const Icon(Icons.close),
                            label: const Text('틀림',
                                style: TextStyle(fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _correct,
                            icon: const Icon(Icons.check),
                            label: const Text('맞춤',
                                style: TextStyle(fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ] else
                        Expanded(
                          child: Center(
                            child: Text(
                              '카드를 탭해서 뒤집어보세요',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: settings.fontSize - 2),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          // 오버레이 애니메이션
          if (_showOverlay)
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showOverlay ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Image.asset(
                    _overlayEmoji == '⭕'
                        ? 'assets/images/check.png'
                        : 'assets/images/wrong.png',
                    height: 180,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}