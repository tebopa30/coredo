import 'package:flutter/material.dart';
import 'package:coredo_app/sound_manager.dart';
import 'package:coredo_app/components/banner_ad_widget.dart';

class VoiceListScreen extends StatelessWidget {
  const VoiceListScreen({super.key});

  // ★ カテゴリごとのボイス一覧
  final Map<String, List<Map<String, String>>> categorizedVoices = const {
    "食事をする": [
      {"title": "いつもとは違うジャンルに挑戦してみる？", "file": "audio/16.m4a"},
      {"title": "お腹すいてきたね", "file": "audio/17.m4a"},
      {"title": "決まりだね", "file": "audio/18.m4a"},
      {"title": "なにを食べようかな", "file": "audio/19.m4a"},
      {"title": "食べるのが楽しみだね", "file": "audio/20.m4a"},
      {"title": "はやく食べたいね", "file": "audio/21.m4a"},
    ],
    "旅行に行く": [
      {"title": "お出かけするの楽しみだね", "file": "audio/1.m4a"},
      {"title": "計画を立てるのも楽しいよね", "file": "audio/7.m4a"},
      {"title": "行ってみたい場所ってある？", "file": "audio/9.m4a"},
      {"title": "早く行きたいね", "file": "audio/12.m4a"},
    ],
    "遊びに行く": [
      {"title": "やってみたかったことにチャレンジしてみる？", "file": "audio/4.m4a"},
      {"title": "好きなことをしてリフレッシュしよう", "file": "audio/8.m4a"},
      {"title": "今日のお天気は？", "file": "audio/10.m4a"},
    ],
    "贈り物を選ぶ": [
      {"title": "とても素敵だね", "file": "audio/2.m4a"},
      {"title": "喜んでもらえるといいね", "file": "audio/6.m4a"},
      {"title": "早く渡したいね", "file": "audio/13.m4a"},
      {"title": "相手のことを思い出してみよう", "file": "audio/14.m4a"},
      {"title": "渡すのが楽しみだね", "file": "audio/15.m4a"},
    ],
  };

  // ★ カテゴリごとのアイコン
  final Map<String, IconData> categoryIcons = const {
    "食事をする": Icons.restaurant,
    "旅行に行く": Icons.flight_takeoff,
    "遊びに行く": Icons.sports_esports,
    "贈り物を選ぶ": Icons.card_giftcard,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "キャラクターボイス",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Stack(
        children: [
          // 背景
          Positioned.fill(
            child: Image.asset(
              'assets/winter/10.png',
              fit: BoxFit.cover,
            ),
          ),

          // 半透明パネル
          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),

          // ★ カテゴリ + ボイス一覧
          ListView(
            padding: const EdgeInsets.only(top: 120, bottom: 40),
            children: categorizedVoices.entries.map((entry) {
              final category = entry.key;
              final voices = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ★ カテゴリタイトル（アイコン付き）
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          categoryIcons[category] ?? Icons.volume_up,
                          size: 26,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ★ ボイス一覧
                  ...voices.map((voice) {
                    return Card(
                      color: Colors.white.withValues(alpha: 0.8),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      child: ListTile(
                        title: Text(
                          voice["title"]!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing:
                            const Icon(Icons.play_circle_fill, size: 32),
                        onTap: () {
                          AudioManager.play(voice["file"]!);
                        },
                      ),
                    );
                  })
                ],
              );
            }).toList(),
          ),
        ],
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }
}