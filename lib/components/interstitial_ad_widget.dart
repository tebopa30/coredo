import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart'; // VoidCallback 用

class AdManager {
    // シングルトンインスタンス
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();
  InterstitialAd? _interstitialAd;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-4129557692895172/2613331524', 
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

  void showInterstitialAd(VoidCallback onAdClosed) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          onAdClosed();
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          onAdClosed();
          loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null; // 再利用不可なので null にする
    } else {
      onAdClosed(); // 読み込み失敗時はそのまま遷移
      loadInterstitialAd();
    }
  }
}