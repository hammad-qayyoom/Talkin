class SupportedLanguage {
  final String code;
  final String name;

  const SupportedLanguage({required this.code, required this.name});

  static const List<SupportedLanguage> all = [
    SupportedLanguage(code: 'af', name: 'Afrikaans'),
    SupportedLanguage(code: 'am', name: 'Amharic'),
    SupportedLanguage(code: 'ar', name: 'Arabic'),
    SupportedLanguage(code: 'az', name: 'Azerbaijani'),
    SupportedLanguage(code: 'be', name: 'Belarusian'),
    SupportedLanguage(code: 'bg', name: 'Bulgarian'),
    SupportedLanguage(code: 'bn', name: 'Bengali'),
    SupportedLanguage(code: 'bs', name: 'Bosnian'),
    SupportedLanguage(code: 'ca', name: 'Catalan'),
    SupportedLanguage(code: 'cs', name: 'Czech'),
    SupportedLanguage(code: 'cy', name: 'Welsh'),
    SupportedLanguage(code: 'da', name: 'Danish'),
    SupportedLanguage(code: 'de', name: 'German'),
    SupportedLanguage(code: 'el', name: 'Greek'),
    SupportedLanguage(code: 'en', name: 'English'),
    SupportedLanguage(code: 'eo', name: 'Esperanto'),
    SupportedLanguage(code: 'es', name: 'Spanish'),
    SupportedLanguage(code: 'et', name: 'Estonian'),
    SupportedLanguage(code: 'eu', name: 'Basque'),
    SupportedLanguage(code: 'fa', name: 'Persian'),
    SupportedLanguage(code: 'fi', name: 'Finnish'),
    SupportedLanguage(code: 'fil', name: 'Filipino'),
    SupportedLanguage(code: 'fr', name: 'French'),
    SupportedLanguage(code: 'ga', name: 'Irish'),
    SupportedLanguage(code: 'gl', name: 'Galician'),
    SupportedLanguage(code: 'gu', name: 'Gujarati'),
    SupportedLanguage(code: 'he', name: 'Hebrew'),
    SupportedLanguage(code: 'hi', name: 'Hindi'),
    SupportedLanguage(code: 'hr', name: 'Croatian'),
    SupportedLanguage(code: 'ht', name: 'Haitian Creole'),
    SupportedLanguage(code: 'hu', name: 'Hungarian'),
    SupportedLanguage(code: 'hy', name: 'Armenian'),
    SupportedLanguage(code: 'id', name: 'Indonesian'),
    SupportedLanguage(code: 'is', name: 'Icelandic'),
    SupportedLanguage(code: 'it', name: 'Italian'),
    SupportedLanguage(code: 'ja', name: 'Japanese'),
    SupportedLanguage(code: 'jv', name: 'Javanese'),
    SupportedLanguage(code: 'ka', name: 'Georgian'),
    SupportedLanguage(code: 'kk', name: 'Kazakh'),
    SupportedLanguage(code: 'km', name: 'Khmer'),
    SupportedLanguage(code: 'kn', name: 'Kannada'),
    SupportedLanguage(code: 'ko', name: 'Korean'),
    SupportedLanguage(code: 'ku', name: 'Kurdish'),
    SupportedLanguage(code: 'ky', name: 'Kyrgyz'),
    SupportedLanguage(code: 'lo', name: 'Lao'),
    SupportedLanguage(code: 'lt', name: 'Lithuanian'),
    SupportedLanguage(code: 'lv', name: 'Latvian'),
    SupportedLanguage(code: 'mg', name: 'Malagasy'),
    SupportedLanguage(code: 'mk', name: 'Macedonian'),
    SupportedLanguage(code: 'ml', name: 'Malayalam'),
    SupportedLanguage(code: 'mn', name: 'Mongolian'),
    SupportedLanguage(code: 'mr', name: 'Marathi'),
    SupportedLanguage(code: 'ms', name: 'Malay'),
    SupportedLanguage(code: 'mt', name: 'Maltese'),
    SupportedLanguage(code: 'my', name: 'Burmese'),
    SupportedLanguage(code: 'nb', name: 'Norwegian Bokmål'),
    SupportedLanguage(code: 'ne', name: 'Nepali'),
    SupportedLanguage(code: 'nl', name: 'Dutch'),
    SupportedLanguage(code: 'no', name: 'Norwegian'),
    SupportedLanguage(code: 'pa', name: 'Punjabi'),
    SupportedLanguage(code: 'pl', name: 'Polish'),
    SupportedLanguage(code: 'ps', name: 'Pashto'),
    SupportedLanguage(code: 'pt', name: 'Portuguese'),
    SupportedLanguage(code: 'ro', name: 'Romanian'),
    SupportedLanguage(code: 'ru', name: 'Russian'),
    SupportedLanguage(code: 'sd', name: 'Sindhi'),
    SupportedLanguage(code: 'si', name: 'Sinhala'),
    SupportedLanguage(code: 'sk', name: 'Slovak'),
    SupportedLanguage(code: 'sl', name: 'Slovenian'),
    SupportedLanguage(code: 'so', name: 'Somali'),
    SupportedLanguage(code: 'sq', name: 'Albanian'),
    SupportedLanguage(code: 'sr', name: 'Serbian'),
    SupportedLanguage(code: 'su', name: 'Sundanese'),
    SupportedLanguage(code: 'sv', name: 'Swedish'),
    SupportedLanguage(code: 'sw', name: 'Swahili'),
    SupportedLanguage(code: 'ta', name: 'Tamil'),
    SupportedLanguage(code: 'te', name: 'Telugu'),
    SupportedLanguage(code: 'th', name: 'Thai'),
    SupportedLanguage(code: 'tl', name: 'Tagalog'),
    SupportedLanguage(code: 'tr', name: 'Turkish'),
    SupportedLanguage(code: 'uk', name: 'Ukrainian'),
    SupportedLanguage(code: 'ur', name: 'Urdu'),
    SupportedLanguage(code: 'uz', name: 'Uzbek'),
    SupportedLanguage(code: 'vi', name: 'Vietnamese'),
    SupportedLanguage(code: 'xh', name: 'Xhosa'),
    SupportedLanguage(code: 'yi', name: 'Yiddish'),
    SupportedLanguage(code: 'yo', name: 'Yoruba'),
    SupportedLanguage(code: 'zh', name: 'Chinese'),
    SupportedLanguage(code: 'zu', name: 'Zulu'),
  ];

  static SupportedLanguage? findByCode(String code) {
    try {
      return all.firstWhere((l) => l.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Returns a filtered list of languages that are actually supported by
  /// Azure Speech Translation for real-time speech recognition + translation.
  /// Some languages support only text translation, not speech.
  static const List<String> speechRecognizedCodes = [
    'ar', 'bg', 'ca', 'cs', 'da', 'de', 'el', 'en', 'es', 'et', 'fi',
    'fr', 'gu', 'he', 'hi', 'hr', 'hu', 'id', 'it', 'ja', 'ko', 'lt',
    'lv', 'ms', 'mt', 'nb', 'nl', 'pl', 'pt', 'ro', 'ru', 'sk', 'sl',
    'sv', 'ta', 'te', 'th', 'tr', 'uk', 'vi', 'zh',
  ];

  static bool isSpeechSupported(String code) => speechRecognizedCodes.contains(code);
}

class TranslationConfigResponse {
  final bool status;
  final String? message;
  final TranslationConfigData? data;

  TranslationConfigResponse({
    required this.status,
    this.message,
    this.data,
  });

  factory TranslationConfigResponse.fromJson(Map<String, dynamic> json) {
    return TranslationConfigResponse(
      status: json['status'] ?? false,
      message: json['message'],
      data: json['data'] != null ? TranslationConfigData.fromJson(json['data']) : null,
    );
  }
}

class TranslationConfigData {
  final bool enabled;
  final bool audioEnabled;
  final bool videoEnabled;
  final String provider;
  final String azureRegion;
  final String defaultSourceLang;
  final String defaultTargetLang;
  final List<String> supportedLanguages;
  final int dailyQuotaMinutes;
  final int monthlyQuotaMinutes;
  final int maxConcurrentSessions;

  TranslationConfigData({
    required this.enabled,
    required this.audioEnabled,
    required this.videoEnabled,
    required this.provider,
    required this.azureRegion,
    required this.defaultSourceLang,
    required this.defaultTargetLang,
    required this.supportedLanguages,
    required this.dailyQuotaMinutes,
    required this.monthlyQuotaMinutes,
    required this.maxConcurrentSessions,
  });

  factory TranslationConfigData.fromJson(Map<String, dynamic> json) {
    return TranslationConfigData(
      enabled: json['enabled'] ?? false,
      audioEnabled: json['audioEnabled'] ?? true,
      videoEnabled: json['videoEnabled'] ?? true,
      provider: json['provider'] ?? 'azure',
      azureRegion: json['azureRegion'] ?? '',
      defaultSourceLang: json['defaultSourceLang'] ?? 'en',
      defaultTargetLang: json['defaultTargetLang'] ?? 'ar',
      supportedLanguages: List<String>.from(json['supportedLanguages'] ?? [
        'af', 'am', 'ar', 'az', 'be', 'bg', 'bn', 'bs', 'ca', 'cs', 'cy',
        'da', 'de', 'el', 'en', 'eo', 'es', 'et', 'eu', 'fa', 'fi', 'fil',
        'fr', 'ga', 'gl', 'gu', 'he', 'hi', 'hr', 'ht', 'hu', 'hy', 'id',
        'is', 'it', 'ja', 'jv', 'ka', 'kk', 'km', 'kn', 'ko', 'ku', 'ky',
        'lo', 'lt', 'lv', 'mg', 'mk', 'ml', 'mn', 'mr', 'ms', 'mt', 'my',
        'nb', 'ne', 'nl', 'no', 'pa', 'pl', 'ps', 'pt', 'ro', 'ru', 'sd',
        'si', 'sk', 'sl', 'so', 'sq', 'sr', 'su', 'sv', 'sw', 'ta', 'te',
        'th', 'tl', 'tr', 'uk', 'ur', 'uz', 'vi', 'xh', 'yi', 'yo', 'zh',
        'zu'
      ]),
      dailyQuotaMinutes: json['dailyQuotaMinutes'] ?? 1000,
      monthlyQuotaMinutes: json['monthlyQuotaMinutes'] ?? 30000,
      maxConcurrentSessions: json['maxConcurrentSessions'] ?? 50,
    );
  }
}

class TranslationSession {
  final String sessionId;
  final String sourceLang;
  final String targetLang;
  final DateTime startedAt;
  final int participantCount;

  TranslationSession({
    required this.sessionId,
    required this.sourceLang,
    required this.targetLang,
    required this.startedAt,
    required this.participantCount,
  });

  factory TranslationSession.fromJson(Map<String, dynamic> json) {
    return TranslationSession(
      sessionId: json['sessionId'] ?? '',
      sourceLang: json['sourceLang'] ?? 'en',
      targetLang: json['targetLang'] ?? 'ar',
      startedAt: DateTime.tryParse(json['startedAt'] ?? '') ?? DateTime.now(),
      participantCount: json['participantCount'] ?? 1,
    );
  }
}

class SubtitleData {
  final String sessionId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String originalText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final double confidence;
  final int timestamp;

  SubtitleData({
    required this.sessionId,
    required this.senderId,
    this.senderName = '',
    required this.senderRole,
    required this.originalText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.confidence,
    required this.timestamp,
  });

  factory SubtitleData.fromJson(Map<String, dynamic> json) {
    return SubtitleData(
      sessionId: json['sessionId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderRole: json['senderRole'] ?? '',
      originalText: json['originalText'] ?? '',
      translatedText: json['translatedText'] ?? '',
      sourceLang: json['sourceLang'] ?? 'en',
      targetLang: json['targetLang'] ?? 'ar',
      confidence: (json['confidence'] ?? 0).toDouble(),
      timestamp: json['timestamp'] ?? 0,
    );
  }
}
