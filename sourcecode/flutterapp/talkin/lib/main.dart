import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
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
import 'package:notisboard/utils/startup_helper.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'localization/localizations_delegate.dart';
import 'utils/utils.dart';

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

Future<void> _initializePostLaunchServices() async {
  unawaited(AppStartupHelper.runTask<void>(
    "Wakelock init",
    () => WakelockPlus.enable(),
    timeout: const Duration(seconds: 2),
  ));

  unawaited(AppStartupHelper.runTask<void>(
    "Ringtone service init",
    () => RingtoneService.init(),
    timeout: const Duration(seconds: 2),
  ));

  final identity = await AppStartupHelper.getSafeDeviceId();
  final fcmToken = await AppStartupHelper.runTask<String?>(
    "FCM token init",
    () => AppStartupHelper.getSafeFcmToken(),
    timeout: const Duration(seconds: 5),
  );

  Utils.showLog("Device Id => $identity");
  Utils.showLog("FCM Token => $fcmToken");

  await AppStartupHelper.runTask<void>(
    "Local database startup",
    () => Database.init(identity, fcmToken ?? ""),
    timeout: const Duration(seconds: 8),
  );

  await AppStartupHelper.runTask<void>(
    "Notification services init",
    () => NotificationServices.init(),
    timeout: const Duration(seconds: 5),
  );

  await AppStartupHelper.runTask<void>(
    "Firebase notification listeners init",
    () => NotificationServices.firebaseInit(),
    timeout: const Duration(seconds: 5),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  await AppStartupHelper.runTask<FirebaseApp>(
    "Firebase initialize",
    () => Firebase.initializeApp(),
    timeout: const Duration(seconds: 8),
  );
  await AppStartupHelper.runTask<void>(
    "Local storage initialize",
    () async {
      await GetStorage.init();
    },
    timeout: const Duration(seconds: 4),
  );
  await _preloadSplashFonts();

  runApp(const MyApp());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initializePostLaunchServices());
  });
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
        final bool isBottomBarRoute = Get.currentRoute == AppRoutes.bottomBar ||
            Get.currentRoute == AppRoutes.hostBottomBar;

        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Container(
            color: AppColors.white,
            child: SafeArea(
              bottom: !isBottomBarRoute,
              top: false,
              left: false,
              right: false,
              child: Scaffold(
                // backgroundColor: AppColors.black,
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    child ?? const SizedBox.expand(),
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
