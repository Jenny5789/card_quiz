import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/app_settings.dart';
import '../models/deck.dart';
import '../models/card_item.dart';
import 'study_screen.dart';

class ResultScreen extends StatelessWidget {
  final Deck deck;
  final int correctCount;
  final int wrongCount;
  final List<CardItem> wrongCards;
  final Function(int, int, Deck) onComplete;

  const ResultScreen({
    super.key,
    required this.deck,
    required this.correctCount,
    required this.wrongCount,
    required this.wrongCards,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettings>();
    final total = correctCount + wrongCount;
    final percent = total == 0 ? 0 : (correctCount / total * 100).round();

    return Scaffold(
      backgroundColor: JejuColors.bg,
      appBar: AppBar(
        backgroundColor: JejuColors.accent,
        foregroundColor: Colors.white,
        title: const Text('🏆 학습 결과',
            style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 정답률
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: JejuColors.main,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // 정답률에 따라 다른 이미지
                  Image.asset(
                    percent >= 70
                        ? 'assets/images/aaa.png'
                        : 'assets/images/topscorer.png',
                    height: 100,
                  ),
                  const Text('정답률',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('맞춤 $correctCount',
                          style:
                              const TextStyle(color: Colors.greenAccent)),
                      const SizedBox(width: 20),
                      Text('틀림 $wrongCount',
                          style:
                              const TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 틀린 카드 목록
            if (wrongCards.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('틀린 카드',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: wrongCards.length,
                  itemBuilder: (context, index) {
                    final card = wrongCards[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: JejuColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: JejuColors.point, width: 1.5),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.close,
                            color: Colors.redAccent),
                        title: Text(card.front,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(card.back.isEmpty
                            ? '(뒷면 없음)'
                            : card.back),
                      ),
                    );
                  },
                ),
              ),
            ] else
              const Expanded(
                child: Center(
                  child: Text('🎉 모두 맞췄어요!',
                      style: TextStyle(fontSize: 24)),
                ),
              ),
            const SizedBox(height: 16),
            // 버튼
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.popUntil(
                        context, (route) => route.isFirst),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: JejuColors.main),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('홈으로',
                        style: TextStyle(
                            fontSize: 16, color: JejuColors.main)),
                  ),
                ),
                if (wrongCards.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final wrongDeck = Deck(
                          name: '오답 복습',
                          cards: wrongCards,
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudyScreen(
                              deck: wrongDeck,
                              onComplete: onComplete,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JejuColors.main,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('오답 복습',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}