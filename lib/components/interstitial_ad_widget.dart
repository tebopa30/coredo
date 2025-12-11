import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  InterstitialAd? _interstitialAd;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // テスト用ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd(Function onAdClosed) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          onAdClosed(); // 広告終了後に結果画面へ遷移
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          onAdClosed(); // 失敗しても遷移
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      onAdClosed(); // 読み込み失敗時はそのまま遷移
    }
  }
}