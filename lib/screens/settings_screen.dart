import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return Scaffold(
      backgroundColor: JejuColors.bg,
      appBar: AppBar(
        backgroundColor: JejuColors.accent,
        foregroundColor: Colors.white,
        title: const Text('⚙️ 설정',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 테마 설정
          _sectionTitle('테마 색상'),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              AppSettings.themes.length,
              (i) {
                final theme = AppSettings.themes[i];
                final isSelected = settings.selectedTheme == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await settings.updateTheme(i);
                      setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: theme['main'] as Color,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [BoxShadow(
                                color: (theme['main'] as Color).withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )]
                            : null,
                      ),
                      child: Column(
                        children: [
                          if (isSelected)
                            const Icon(Icons.check,
                                color: Colors.white, size: 20),
                          Text(
                            theme['name'] as String,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          // 폰트 크기
          _sectionTitle('폰트 크기'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: JejuColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: JejuColors.point),
            ),
            child: Column(
              children: [
                // 미리보기 텍스트
                Text(
                  '미리보기 텍스트예요',
                  style: TextStyle(
                      fontSize: settings.fontSize,
                      color: JejuColors.main,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${settings.fontSize.round()}px',
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 12),
                ),
                Slider(
                  value: settings.fontSize,
                  min: 12,
                  max: 24,
                  divisions: 6,
                  activeColor: JejuColors.main,
                  label: '${settings.fontSize.round()}px',
                  onChanged: (val) async {
                    await settings.updateFontSize(val);
                    setState(() {});
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('작게 (12px)',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('크게 (24px)',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // 학습 방향
          _sectionTitle('학습 방향'),
          const SizedBox(height: 12),
          Row(
            children: ['앞→뒤', '뒤→앞', '랜덤'].map((direction) {
              final isSelected = settings.studyDirection == direction;
              return Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await settings.updateStudyDirection(direction);
                    setState(() {});
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? JejuColors.main : JejuColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: JejuColors.point),
                    ),
                    child: Text(
                      direction,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          // 설정 저장 버튼
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('설정이 저장됐어요!'),
                    backgroundColor: JejuColors.main,
                    duration: const Duration(seconds: 2),
                  ),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
              label: const Text('설정 저장',
                  style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: JejuColors.main,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}