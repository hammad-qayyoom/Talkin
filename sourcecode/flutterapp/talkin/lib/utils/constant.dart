import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class Constant {
  /// =================== Id For Refresh Widgets =================== ///
  static var idOnBoarding = 'idOnBoarding';
  static var radioButton = 'radioButton';
  static var idAcceptTerms = 'idAcceptTerms';
  static var idCheckMobile = 'idCheckMobile';
  static var idVerification = 'idVerification';
  static var idLoginOrSignUp = 'idLoginOrSignUp';
  static var idBottomBar = 'idBottomBar';
  static var idVideoCall = 'idVideoCall';
  static var idSpeakerOpen = 'idSpeakerOpen';
  static var idMicMute = 'idMicMute';
  static var idGenderSelect = 'idGenderSelect';
  static var idSwitchOn = 'idSwitchOn';
  static var idResendOtp = 'idResendOtp';
  static var idVerifyOtp = 'idVerifyOtp';
  static var idGetListener = 'idGetListener';
  static var idPaginationListener = 'idPaginationListener';
  static var idCallingHistory = 'idCallingHistory';
  static var idChangeAudioRecordingEvent = 'onChangeAudioRecordingEvent';
  static var idVideoTurn = 'idVideoTurn';
  static var idCameraTurn = 'idCameraTurn';
  static var idTranslation = 'idTranslation';
  static var idSubtitle = 'idSubtitle';
  static var idAnonymousMode = 'idAnonymousMode';
  static var idAnonymousPanel = 'idAnonymousPanel';
  static var idTabChange = 'idTabChange';
  static var idRating = 'idRating';
  static var idChangeCountry = 'idChangeCountry';
  static var onChangePaymentMethod = 'onChangePaymentMethod';
  static var idChangeLanguage = 'idChangeLanguage';
  static var onInitializeCamera = 'onInitializeCamera';
  static var idOnVideoCall = 'idOnVideoCall';
  static var idMuteMic = 'idMuteMic';
  static var idToggleCamera = 'idToggleCamera';
  static var idToggleVideo = 'idToggleVideo';
  static var initializeVideoPlayer = 'initializeVideoPlayer';

  /// =================== Id For Refresh API`s Response =================== ///
  static var idLogin = 'idLogin';
  static var idProfile = 'idProfile';
  static var idIdentityProof = 'idIdentityProof';
  static var idAllLanguage = 'idAllLanguage';
  static var idBecomeHost = 'idBecomeHost';
  static var idFAQListeners = 'idFAQListeners';
  static var idFAQUser = 'idFAQUser';
  static var listenerProfile = 'listenerProfile';
  static var talkAboutTopic = 'talkAboutTopic';
  static var idAllListener = 'idAllListener';
  static var idLanguageSection = 'idLanguageSection';
  static var idChatList = 'idChatList';
  static var idGetOldChat = 'idGetOldChat';
  static var idSendMsg = 'idSendMsg';
  static var idPagination = 'onPagination';
  static var idPaymentHistory = 'idPaymentHistory';
  static var idCoinHistory = 'idCoinHistory';
  static var idPaymentOption = 'idPaymentOption';
  static var idWithdrawRecord = 'idWithdrawRecord';
  static var idSearchListener = 'idSearchListener';
  static var idUserNotification = 'idUserNotification';
  static var idCoinUpdate = 'idCoinUpdate';
  static var idHomeCategories = 'idHomeCategories';
  static var idPhoneFieldUpdate = 'idPhoneFieldUpdate';
  static var idGetListenerReview = 'idGetListenerReview';
  static var idFeed = 'idFeed';
  static var idFeedComments = 'idFeedComments';
  static var idBlogNewsList = 'idBlogNewsList';
  static var idBlogNewsDetail = 'idBlogNewsDetail';

  /// =================== Id For Subscription Plan =================== ///
  static var idGetCoinPlan = 'idGetCoinPlan';

  /// =================== Get Storage (Local Storage) =================== ///
  static final storage = GetStorage();

  /// =================== Localization =================== ///
  static const languageEn = "en";
  static const countryCodeEn = "US";

  /// =================== Stripe Merchant =================== ///
  static const stripeMerchantCountryCode = 'IN';

  /// =================== Country Name List =================== ///
  static List countryList = [
    {"country": "Afrikaans", "code": "af", "id": "1"},
    {"country": "Amharic", "code": "am", "id": "2"},
    {"country": "Arabic", "code": "ar", "id": "3"},
    {"country": "Azerbaijani", "code": "az", "id": "4"},
    {"country": "Belarusian", "code": "be", "id": "5"},
    {"country": "Bulgarian", "code": "bg", "id": "6"},
    {"country": "Bengali", "code": "bn", "id": "7"},
    {"country": "Bosnian", "code": "bs", "id": "8"},
    {"country": "Catalan", "code": "ca", "id": "9"},
    {"country": "Czech", "code": "cs", "id": "10"},
    {"country": "Welsh", "code": "cy", "id": "11"},
    {"country": "Danish", "code": "da", "id": "12"},
    {"country": "German", "code": "de", "id": "13"},
    {"country": "Greek", "code": "el", "id": "14"},
    {"country": "English", "code": "en", "id": "15"},
    {"country": "Esperanto", "code": "eo", "id": "16"},
    {"country": "Spanish", "code": "es", "id": "17"},
    {"country": "Estonian", "code": "et", "id": "18"},
    {"country": "Basque", "code": "eu", "id": "19"},
    {"country": "Persian", "code": "fa", "id": "20"},
    {"country": "Finnish", "code": "fi", "id": "21"},
    {"country": "Filipino", "code": "fil", "id": "22"},
    {"country": "French", "code": "fr", "id": "23"},
    {"country": "Irish", "code": "ga", "id": "24"},
    {"country": "Galician", "code": "gl", "id": "25"},
    {"country": "Gujarati", "code": "gu", "id": "26"},
    {"country": "Hebrew", "code": "he", "id": "27"},
    {"country": "Hindi", "code": "hi", "id": "28"},
    {"country": "Croatian", "code": "hr", "id": "29"},
    {"country": "Haitian Creole", "code": "ht", "id": "30"},
    {"country": "Hungarian", "code": "hu", "id": "31"},
    {"country": "Armenian", "code": "hy", "id": "32"},
    {"country": "Indonesian", "code": "id", "id": "33"},
    {"country": "Icelandic", "code": "is", "id": "34"},
    {"country": "Italian", "code": "it", "id": "35"},
    {"country": "Japanese", "code": "ja", "id": "36"},
    {"country": "Javanese", "code": "jv", "id": "37"},
    {"country": "Georgian", "code": "ka", "id": "38"},
    {"country": "Kazakh", "code": "kk", "id": "39"},
    {"country": "Khmer", "code": "km", "id": "40"},
    {"country": "Kannada", "code": "kn", "id": "41"},
    {"country": "Korean", "code": "ko", "id": "42"},
    {"country": "Kurdish", "code": "ku", "id": "43"},
    {"country": "Kyrgyz", "code": "ky", "id": "44"},
    {"country": "Lao", "code": "lo", "id": "45"},
    {"country": "Lithuanian", "code": "lt", "id": "46"},
    {"country": "Latvian", "code": "lv", "id": "47"},
    {"country": "Malagasy", "code": "mg", "id": "48"},
    {"country": "Macedonian", "code": "mk", "id": "49"},
    {"country": "Malayalam", "code": "ml", "id": "50"},
    {"country": "Mongolian", "code": "mn", "id": "51"},
    {"country": "Marathi", "code": "mr", "id": "52"},
    {"country": "Malay", "code": "ms", "id": "53"},
    {"country": "Maltese", "code": "mt", "id": "54"},
    {"country": "Burmese", "code": "my", "id": "55"},
    {"country": "Norwegian Bokmål", "code": "nb", "id": "56"},
    {"country": "Nepali", "code": "ne", "id": "57"},
    {"country": "Dutch", "code": "nl", "id": "58"},
    {"country": "Norwegian", "code": "no", "id": "59"},
    {"country": "Punjabi", "code": "pa", "id": "60"},
    {"country": "Polish", "code": "pl", "id": "61"},
    {"country": "Pashto", "code": "ps", "id": "62"},
    {"country": "Portuguese", "code": "pt", "id": "63"},
    {"country": "Romanian", "code": "ro", "id": "64"},
    {"country": "Russian", "code": "ru", "id": "65"},
    {"country": "Sindhi", "code": "sd", "id": "66"},
    {"country": "Sinhala", "code": "si", "id": "67"},
    {"country": "Slovak", "code": "sk", "id": "68"},
    {"country": "Slovenian", "code": "sl", "id": "69"},
    {"country": "Somali", "code": "so", "id": "70"},
    {"country": "Albanian", "code": "sq", "id": "71"},
    {"country": "Serbian", "code": "sr", "id": "72"},
    {"country": "Sundanese", "code": "su", "id": "73"},
    {"country": "Swedish", "code": "sv", "id": "74"},
    {"country": "Swahili", "code": "sw", "id": "75"},
    {"country": "Tamil", "code": "ta", "id": "76"},
    {"country": "Telugu", "code": "te", "id": "77"},
    {"country": "Thai", "code": "th", "id": "78"},
    {"country": "Tagalog", "code": "tl", "id": "79"},
    {"country": "Turkish", "code": "tr", "id": "80"},
    {"country": "Ukrainian", "code": "uk", "id": "81"},
    {"country": "Urdu", "code": "ur", "id": "82"},
    {"country": "Uzbek", "code": "uz", "id": "83"},
    {"country": "Vietnamese", "code": "vi", "id": "84"},
    {"country": "Xhosa", "code": "xh", "id": "85"},
    {"country": "Yiddish", "code": "yi", "id": "86"},
    {"country": "Yoruba", "code": "yo", "id": "87"},
    {"country": "Chinese", "code": "zh", "id": "88"},
    {"country": "Zulu", "code": "zu", "id": "89"},
  ];

  /// =================== Shimmers =================== ///
  // static Color baseColor = AppColors.shimmerGrey.withValues(alpha: 0.6);
  static Color highlightColor = Colors.grey.withValues(alpha: 0.2);
  static Duration period = const Duration(milliseconds: 500);
}
