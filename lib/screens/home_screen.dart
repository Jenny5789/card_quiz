import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/app_settings.dart';
import '../services/storage_service.dart';
import '../models/deck.dart';
import '../models/today_stats.dart';
import 'deck_list_screen.dart';
import 'settings_screen.dart';
import 'card_list_screen.dart';
import 'study_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Deck> _decks = [];
  TodayStats _stats = TodayStats();
  String? _recentDeckName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final decks = await StorageService.loadDecks();
    final stats = await StorageService.loadStats();
    final recentDeck = await StorageService.loadRecentDeck();
    setState(() {
      _decks = decks;
      _stats = stats;
      _recentDeckName = recentDeck;
    });
  }

  void _onStudyComplete(int correct, int wrong, Deck deck) async {
    await StorageService.saveStats(
      _stats.correct + correct,
      _stats.wrong + wrong,
    );
    await StorageService.saveRecentDeck(deck.name);
    await _loadData();
  }

  void _onDecksChanged() async {
    await StorageService.saveDecks(_decks);
    setState(() {});
  }

  Deck? get _recentDeck {
    if (_recentDeckName == null) return null;
    try {
      return _decks.firstWhere((d) => d.name == _recentDeckName);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final fontSize = settings.fontSize;
    final totalCards = _decks.fold(0, (sum, d) => sum + d.cards.length);
    final totalStudied = _stats.correct + _stats.wrong;
    final accuracy = totalStudied == 0
        ? 0
        : (_stats.correct / totalStudied * 100).round();

    return Scaffold(
      backgroundColor: JejuColors.bg,
      appBar: AppBar(
        backgroundColor: JejuColors.accent,
        foregroundColor: Colors.white,
        title: Text('🍊 퀴즈카드',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: fontSize + 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
                setState(() {});
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 오늘의 학습 통계
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: JejuColors.main,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🍊', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text('오늘의 학습 통계',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: fontSize - 2)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _statItem('맞춤', '${_stats.correct}', fontSize)),
                        _divider(),
                        Expanded(child: _statItem('틀림', '${_stats.wrong}', fontSize)),
                        _divider(),
                        Expanded(child: _statItem('정답률', '$accuracy%', fontSize)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: totalStudied == 0
                            ? 0
                            : _stats.correct / totalStudied,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.greenAccent),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      totalStudied == 0
                          ? '아직 학습 기록이 없어요'
                          : '총 $totalStudied장 학습했어요',
                      style: TextStyle(
                          color: Colors.white60, fontSize: fontSize - 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 최근 학습한 단어장
              if (_recentDeck != null) ...[
                Text('최근 학습한 단어장',
                    style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: JejuColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: JejuColors.point, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: JejuColors.point,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.book,
                            color: JejuColors.main, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_recentDeck!.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSize)),
                            Text('${_recentDeck!.cards.length}장',
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: fontSize - 4)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _recentDeck!.cards.isEmpty
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StudyScreen(
                                      deck: _recentDeck!,
                                      onComplete: _onStudyComplete,
                                    ),
                                  ),
                                ),
                        icon: const Icon(Icons.play_arrow, size: 16),
                        label: Text('시작',
                            style: TextStyle(fontSize: fontSize - 2)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: JejuColors.main,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              // 바로가기
              Text('바로가기',
                  style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  // 단어장 목록
                  Expanded(
                    child: _shortcutCard(
                      icon: Icons.library_books,
                      label: '단어장 목록',
                      sub: '${_decks.length}개',
                      fontSize: fontSize,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DeckListScreen(
                              decks: _decks,
                              onStudyComplete: _onStudyComplete,
                              onDecksChanged: _onDecksChanged,
                            ),
                          ),
                        );
                        await _loadData();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 카드 목록 — 단어장 선택 팝업
                  Expanded(
                    child: _shortcutCard(
                      icon: Icons.style,
                      label: '카드 목록',
                      sub: '$totalCards장',
                      fontSize: fontSize,
                      onTap: () async {
                        if (_decks.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('먼저 단어장을 만들어주세요!')),
                          );
                          return;
                        }
                        final selectedDeck = await showDialog<Deck>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('단어장 선택'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _decks.length,
                                itemBuilder: (context, index) {
                                  final deck = _decks[index];
                                  return ListTile(
                                    leading: Icon(Icons.book,
                                        color: JejuColors.main),
                                    title: Text(deck.name),
                                    subtitle:
                                        Text('카드 ${deck.cards.length}장'),
                                    onTap: () =>
                                        Navigator.pop(context, deck),
                                  );
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('취소'),
                              ),
                            ],
                          ),
                        );
                        if (selectedDeck != null) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CardListScreen(
                                deck: selectedDeck,
                                onStudyComplete: _onStudyComplete,
                                onCardsChanged: _onDecksChanged,
                              ),
                            ),
                          );
                          await _loadData();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 학습 시작
                  Expanded(
                    child: _shortcutCard(
                      icon: Icons.play_circle,
                      label: '학습 시작',
                      sub: '바로 시작',
                      fontSize: fontSize,
                      onTap: () {
                        if (_decks.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('먼저 단어장을 만들어주세요!')),
                          );
                          return;
                        }
                        final deck = _recentDeck ?? _decks.first;
                        if (deck.cards.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('카드를 먼저 추가해주세요!')),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudyScreen(
                              deck: deck,
                              onComplete: _onStudyComplete,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, double fontSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value,
            style: TextStyle(
                color: Colors.white,
                fontSize: fontSize + 6,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: Colors.white70, fontSize: fontSize - 3)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: Colors.white30);
  }

  Widget _shortcutCard({
    required IconData icon,
    required String label,
    required String sub,
    required double fontSize,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: JejuColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: JejuColors.point, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: JejuColors.main, size: fontSize + 12),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: fontSize - 3)),
            const SizedBox(height: 4),
            Text(sub,
                style: TextStyle(
                    color: Colors.grey[500], fontSize: fontSize - 5)),
          ],
        ),
      ),
    );
  }
}