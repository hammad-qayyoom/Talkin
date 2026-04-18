import 'dart:async';
import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:notisboard/custom/ringtone/ringtone_method.dart';
import 'package:notisboard/localization/locale_constant.dart';
import 'package:notisboard/routes/app_pages.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/services/notification_service/notification_services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'localization/localizations_delegate.dart';
import 'utils/utils.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';

AppLifecycleState? currentAppLifecycleState;

Future<void> _preloadSplashFonts() async {
  // Ensure splash wordmark/text renders once with final styling (no font swap flicker).
  try {
    GoogleFonts.kaushanScript();
    GoogleFonts.poppins();
    await GoogleFonts.pendingFonts([
      GoogleFonts.kaushanScript(),
      GoogleFonts.poppins(),
      GoogleFonts.poppins(fontWeight: FontWeight.w500),
      GoogleFonts.poppins(fontWeight: FontWeight.w600),
    ]);
  } catch (e, stackTrace) {
    log('Splash font preload failed', error: e, stackTrace: stackTrace);
  }
}

Future<String?> _getSafeFcmToken() async {
  try {
    if (GetPlatform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // On iOS, getToken can fail early until APNS token is ready.
      for (int i = 0; i < 10; i++) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null && apnsToken.isNotEmpty) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    }

    return await FirebaseMessaging.instance.getToken();
  } catch (e, stackTrace) {
    Utils.showLog("FCM token init error => $e");
    log("FCM token init error", error: e, stackTrace: stackTrace);
    return null;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _preloadSplashFonts();

  await Firebase.initializeApp();
  await GetStorage.init();
  WakelockPlus.enable();
  await RingtoneService.init();
  final identity = (await MobileDeviceIdentifier().getDeviceId())!;
  final fcmToken = await _getSafeFcmToken();

  Utils.showLog("Device Id => $identity");
  Utils.showLog("FCM Token => $fcmToken");

  await Database.init(identity, fcmToken ?? "");
  NotificationServices.init();

  // Set up Awesome Notifications listeners
  AwesomeNotifications().setListeners(
    onActionReceivedMethod:
        NotificationServices.onAwesomeNotificationActionReceived,
  );

  NotificationServices.firebaseInit();
  FirebaseMessaging.onBackgroundMessage(backgroundNotification);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final StreamController purchaseStreamController =
      StreamController<PurchaseDetails>.broadcast();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    currentAppLifecycleState = state;
    Utils.showLog('AppLifecycleState changed to: $state');
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        log("didChangeDependencies Preference Revoked ${locale.languageCode}");
        log("didChangeDependencies GET LOCALE Revoked ${Get.locale?.languageCode}");
        Get.updateLocale(locale);
      });
    });
    super.didChangeDependencies();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Utils.showLog("MY Current Routes => ${Get.currentRoute}");
    return GetMaterialApp(
      title: 'Notisboard',
      debugShowCheckedModeBanner: false,
      locale: const Locale("en"),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Container(
            color: AppColors.white,
            child: SafeArea(
              bottom: true,
              top: false,
              left: false,
              right: false,
              child: Scaffold(
                // backgroundColor: AppColors.black,
                body: Stack(
                  children: [
                    child ?? const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      translations: AppLanguages(),
      initialRoute: AppRoutes.splashScreenPage,
      getPages: AppPages.list,
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
