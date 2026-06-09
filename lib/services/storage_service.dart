import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/deck.dart';
import '../models/today_stats.dart';
import '../models/card_item.dart';

class StorageService {
  static const _decksKey = 'decks';
  static const _recentDeckKey = 'recentDeck';
  static const _statsKey = 'todayStats';
  static const _fontSizeKey = 'fontSize';
  static const _studyDirectionKey = 'studyDirection';
  static const _themeKey = 'selectedTheme';

  static Future<void> saveDecks(List<Deck> decks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_decksKey,
        jsonEncode(decks.map((d) => d.toJson()).toList()));
  }

  static Future<List<Deck>> loadDecks() async {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_decksKey);
      if (json == null) {
        final sampleDecks = _createSampleDecks();
        await saveDecks(sampleDecks);
        return sampleDecks;
      }
      return (jsonDecode(json) as List).map((d) => Deck.fromJson(d)).toList();
    }

  static List<Deck> _createSampleDecks() {
    return [
      Deck(
        name: '자료구조',
        cards: [
          CardItem(front: '스택', back: 'LIFO(Last In First Out) 구조'),
          CardItem(front: '큐', back: 'FIFO(First In First Out) 구조'),
          CardItem(front: '연결 리스트', back: '노드들이 포인터로 연결된 자료구조'),
          CardItem(front: '트리', back: '계층적 구조를 가진 비선형 자료구조'),
          CardItem(front: '해시 테이블', back: '키-값 쌍으로 데이터를 저장하는 구조'),
        ],
      ),
      Deck(
        name: '파이썬 기초',
        cards: [
          CardItem(front: '리스트', back: '순서가 있는 변경 가능한 자료형 []'),
          CardItem(front: '튜플', back: '순서가 있는 변경 불가능한 자료형 ()'),
          CardItem(front: '딕셔너리', back: '키-값 쌍으로 이루어진 자료형 {}'),
          CardItem(front: '함수', back: 'def 키워드로 정의하는 코드 블록'),
          CardItem(front: '클래스', back: '객체를 만들기 위한 설계도'),
        ],
      ),
    ];
  }

  static Future<void> saveRecentDeck(String deckName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recentDeckKey, deckName);
  }

  static Future<String?> loadRecentDeck() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_recentDeckKey);
  }

  static Future<void> saveStats(int correct, int wrong) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_statsKey}_correct', correct);
    await prefs.setInt('${_statsKey}_wrong', wrong);
  }

  static Future<TodayStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    return TodayStats(
      correct: prefs.getInt('${_statsKey}_correct') ?? 0,
      wrong: prefs.getInt('${_statsKey}_wrong') ?? 0,
    );
  }

  static Future<void> saveSettings({
    required double fontSize,
    required String studyDirection,
    required int selectedTheme,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, fontSize);
    await prefs.setString(_studyDirectionKey, studyDirection);
    await prefs.setInt(_themeKey, selectedTheme);
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'fontSize': prefs.getDouble(_fontSizeKey) ?? 16.0,
      'studyDirection': prefs.getString(_studyDirectionKey) ?? '앞→뒤',
      'selectedTheme': prefs.getInt(_themeKey) ?? 0,
    };
  }

  static Future<void> saveProgress({
    required String deckName,
    required int currentIndex,
    required int correctCount,
    required int wrongCount,
    required List<String> shuffledFronts,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('progress_deck', deckName);
    await prefs.setInt('progress_index', currentIndex);
    await prefs.setInt('progress_correct', correctCount);
    await prefs.setInt('progress_wrong', wrongCount);
    await prefs.setStringList('progress_order', shuffledFronts);
  }

  static Future<Map<String, dynamic>?> loadProgress(String deckName) async {
    final prefs = await SharedPreferences.getInstance();
    final savedDeck = prefs.getString('progress_deck');
    if (savedDeck != deckName) return null;
    return {
      'currentIndex': prefs.getInt('progress_index') ?? 0,
      'correctCount': prefs.getInt('progress_correct') ?? 0,
      'wrongCount': prefs.getInt('progress_wrong') ?? 0,
      'shuffledFronts': prefs.getStringList('progress_order') ?? [],
    };
  }

  static Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('progress_deck');
    await prefs.remove('progress_index');
    await prefs.remove('progress_correct');
    await prefs.remove('progress_wrong');
    await prefs.remove('progress_order');
  }
}