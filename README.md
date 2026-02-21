# coredo_app
- 食事をする、旅行に行く、遊びに行く、贈り物を選ぶなどの迷ったときに質問フローでそれらの決定を助け、キャラクターボイスを聞くことができるアプリ

## 仕組み
- 2〜3択の質問を繰り返し → 最終的に結果に到達

## 画面構成
- **HomeScreen** → 「質問スタート」ボタン
- **QuestionScreen** → 選択肢を表示、回答を送信
- **ResultScreen** → 結果表示、結果をタップして検索、外部ページに遷移するボタン
- **HistoryScreen** → 過去の回答履歴
- **VoiceListScreen** → キャラクターボイス一覧

## 技術スタック
- **バックエンド:** Rails API + PostgreSQL (EC2/Cloud9)
- **フロント:** Flutter (Android/iOS)
- **Webランディング:** HTML/CSS/JS + jQuery
- **DB:** SQL (PostgreSQL)
- **IDE:** Cloud9
- **デプロイ:** Puma + Nginx + SSL (EC2)

## Rails API設計
- **Question**: 質問文、routing(enum: static/ai)、order_index
- **Option**: 選択肢、次の質問 or Resultへの分岐
- **Result**: 結果文、URL
- **Answer**: ユーザー回答履歴（session_idで紐付け）