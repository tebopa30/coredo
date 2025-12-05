import 'package:flutter/material.dart';
import 'package:coredo_app/sound_manager.dart';
import 'package:coredo_app/components/background_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: ValueListenableBuilder<bool>(
        valueListenable: SoundManager().isSoundOn,
        builder: (context, isSoundOn, child) {
          return ListView(
            children: [
              const SizedBox(height: 80), // AppBarの分空ける
              SwitchListTile(
                title: const Text(
                  '音声',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                value: isSoundOn,
                onChanged: (value) {
                  SoundManager().setSound(value);
                },
                secondary: Icon(
                  isSoundOn ? Icons.volume_up : Icons.volume_off,
                  color: Colors.black54,
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text(
                  'プライバシーポリシー',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('プライバシーポリシー'),
                      content: const SingleChildScrollView(
                        child: Text('''
本アプリでは、ユーザーの皆さまのプライバシーを尊重し、以下の方針に基づいて個人情報を取り扱います。

1. 収集する情報について
本アプリは、通常の利用において個人情報を収集することはありません。
ユーザーが課金を行う際に、決済に必要な情報（氏名、メールアドレス、決済手段等）が入力される場合があります。

2. 利用目的
収集した情報は、課金処理およびサービス提供に必要な範囲でのみ利用します。
本アプリの機能提供にあたり、OpenAI社の ChatGPT API を利用していますが、通常の利用において個人を特定できる情報は送信されません。

3. 第三者への提供
収集した個人情報は、法令に基づく場合を除き、第三者に提供することはありません。

4. 安全管理
収集した情報は、適切な方法で管理し、不正アクセスや漏洩を防止するよう努めます。

5. 外部サービスの利用
本アプリは、OpenAI社の ChatGPT API を利用して回答を生成します。
この際、ユーザーが入力したテキストは OpenAI のサーバーに送信されますが、課金時以外に個人情報を送信することはありません。

6. 改定について
本ポリシーの内容は、必要に応じて改定される場合があります。改定後は速やかにアプリ内で告知します。

制定日：2025年12月6日
                          '''),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('閉じる'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
