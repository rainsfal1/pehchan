import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;

import 'package:pehchan/src/core/pehchan_util.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeakingRepeatedly = false;
  double _ttsSpeed = PKBAppState().ttsSpeed;

  TtsService() {
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    if (Platform.isIOS) {
      await _flutterTts.setSharedInstance(true);
    }
  }

  // set tts speed
  void setTtsSpeed(double speed) {
    _ttsSpeed = speed;
  }

  /// Get the TTS language code based on the current app locale
  String _getTtsLanguage() {
    try {
      final storedLocale = PKBLocalizations.getStoredLocale();
      final languageCode = storedLocale?.languageCode ?? 'en';

      // Map app language codes to TTS language codes
      switch (languageCode) {
        case 'ur':
          // Use Pakistani Urdu for proper pronunciation
          return 'ur-PK';
        case 'en':
        default:
          return 'en-US';
      }
    } catch (e) {
      // If preferences not initialized yet, default to English
      return 'en-US';
    }
  }

  Future<void> speak(String text) async {
    await _flutterTts.setLanguage(_getTtsLanguage());
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(_ttsSpeed);
    if (PKBAppState().silentMode == false) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeakingRepeatedly = false; // Ensure to stop repeated speaking
  }

  Future<void> speakRepeatedly(String text) async {
    _isSpeakingRepeatedly = true;
    while (_isSpeakingRepeatedly && PKBAppState().silentMode == false) {
      await speak(text);
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  void stopRepeatedSpeaking() async {
    _isSpeakingRepeatedly = false;
    await stop();
  }
}
