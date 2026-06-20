import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:notisboard/custom/dialog/exit_app_dialog.dart';
import 'package:notisboard/custom/dialog/force_update_dialog.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/services/biometric/biometric_auth_service.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/api/host_coin_api.dart';
import 'package:notisboard/services/location/user_location_service.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/ip_api.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/setting_api.dart';
import 'package:notisboard/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/model/aap_configuration_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/model/fetch_listener_profile_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/model/listener_coin_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/model/ip_api_response_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/model/setting_api_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

import '../api/aap_configuration_api.dart';

Future<T?> _guardedSplashTask<T>(
  String label,
  Future<T?> Function() task, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  try {
    return await task().timeout(timeout);
  } catch (error, stackTrace) {
    Utils.showLog("$label failed => $error");
    log(label, error: error, stackTrace: stackTrace);
    return null;
  }
}

class SplashScreenController extends GetxController {
  SettingApiModel? settingApiModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;
  FetchListenerProfileModel? fetchListenerProfileModel;
  IpApiResponseModel? ipApiResponseModel;
  AppConfigurationModel? appConfigurationModel;
  bool _didScheduleSplashNavigation = false;

  Future<void> syncInitialBalances() async {
    if (Database.isGuestMode) return;
    if (fetchLoginUserProfileModel?.status != true) return;

    if (fetchLoginUserProfileModel?.user?.isListener == true) {
      ListenerCoinModel? listenerCoinModel =
          await _guardedSplashTask<ListenerCoinModel>(
        "Listener balance sync",
        () => HostCoinApi.callApi(),
        timeout: const Duration(seconds: 6),
      );
      if (listenerCoinModel?.status == true) {
        Database.onSetListenerCoin((listenerCoinModel?.coin ?? 0).toString());
      }
      return;
    }

    UserCoinModel? userCoinModel = await _guardedSplashTask<UserCoinModel>(
      "User balance sync",
      () => UserCoinApi.callApi(),
      timeout: const Duration(seconds: 6),
    );
    if (userCoinModel?.status == true) {
      Database.onSetUserCoin((userCoinModel?.coin ?? 0).toString());
    }
  }

  @override
  void onInit() {
    log('Enter splash screen controller');
    unawaited(init());
    super.onInit();
  }

  Future<void> init() async {
    bool shouldScheduleNavigation = true;
    try {
      /// for privacy policy link and app live key
      appConfigurationModel = await _guardedSplashTask<AppConfigurationModel>(
        "App configuration",
        () => AppConfigurationApi.callApi(),
      );
      Database.appConfigurationModel = appConfigurationModel;
      final token = await _guardedSplashTask<String>(
        "Firebase access token",
        () => FirebaseAccessToken.onGet(),
        timeout: const Duration(seconds: 5),
      );
      settingApiModel = await _guardedSplashTask<SettingApiModel>(
        "Setting api",
        () => SettingApi.callApi(),
      );
      Database.settingApiModel = settingApiModel;
      if (Database.isLogin &&
          Database.loginUserFirebaseId.isNotEmpty &&
          (token ?? '').isNotEmpty) {
        fetchLoginUserProfileModel =
            await _guardedSplashTask<FetchLoginUserProfileModel>(
          "Login profile fetch",
          () => FetchLoginUserProfileApi.callApi(
            loginUserId: Database.loginUserFirebaseId,
            token: token ?? '',
          ),
        );
      }
      Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

      if (Database.loginUserFirebaseId.isEmpty &&
          (fetchLoginUserProfileModel?.user?.firebaseId ?? '').isNotEmpty) {
        Database.onSetLoginUserFirebaseId(
            fetchLoginUserProfileModel?.user?.firebaseId ?? '');
      }

      await _guardedSplashTask<UserLocationData>(
        "Startup location cache",
        () => UserLocationService.primeStartupLocation(),
        timeout: const Duration(seconds: 12),
      );

      ///version update dialog show in splash screen not go main screen
      final bool waitter = await checkForceUpdate();
      if (waitter) {
        shouldScheduleNavigation = false;
        return;
      }
      if (Database.settingApiModel?.data?.isApplicationLive == false) {
        log("Application is not live...");
        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: const AppNotLiveDialog(),
          ),
        );
        shouldScheduleNavigation = false;
        return;
      }

      // if (fetchLoginUserProfileModel?.status == false || fetchLoginUserProfileModel?.message == "User not found in the database." || token == null) {
      //   log("Login user not found, redirecting to main screen...");
      //   Get.offAllNamed(AppRoutes.main);
      //   return;
      // }

      if (fetchLoginUserProfileModel?.user?.isListener == true) {
        fetchListenerProfileModel =
            await _guardedSplashTask<FetchListenerProfileModel>(
          "Listener profile fetch",
          () => FetchListenerProfileAPi.callApi(
            loginListenerId:
                Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
          ),
        );
        final listenerUserId = fetchListenerProfileModel?.data?.id ?? '';
        if (listenerUserId.isNotEmpty) {
          Database.onSetLoginUserId(listenerUserId);
          Database.onSetLoginListenerId(listenerUserId);
        }
        if (fetchListenerProfileModel?.status == false) {
          Utils.showLog(fetchListenerProfileModel?.message ?? "");
        }
        Database.fetchListenerProfileModel = fetchListenerProfileModel;
      }

      await syncInitialBalances();

      ipApiResponseModel = await _guardedSplashTask<IpApiResponseModel>(
        "IP location fetch",
        () => IpApi.callApi(),
        timeout: const Duration(seconds: 5),
      );
      final countryCode = ipApiResponseModel?.countryCode;
      if ((countryCode ?? '').isNotEmpty) {
        Database.onSetSelectedCountryCode(countryCode ?? '');
      }
      if (UserLocationService.cachedLocation == null &&
          ipApiResponseModel?.lat != null &&
          ipApiResponseModel?.lon != null) {
        await Database.onSetUserLatitude(ipApiResponseModel!.lat!);
        await Database.onSetUserLongitude(ipApiResponseModel!.lon!);
      }
      log("Database.selectedCountryCode :: ${Database.selectedCountryCode}");
      Database.getDialCode();
    } catch (error, stackTrace) {
      Utils.showLog("Splash init failed => $error");
      log("Splash init failed", error: error, stackTrace: stackTrace);
    } finally {
      if (shouldScheduleNavigation) {
        _scheduleSplashNavigation();
      }
    }
  }

  void _scheduleSplashNavigation() {
    if (_didScheduleSplashNavigation) return;
    _didScheduleSplashNavigation = true;
    unawaited(splashScreen());
  }

  Future<bool> checkForceUpdate() async {
    final packageInfo = await _guardedSplashTask<PackageInfo>(
      "Package info",
      () => PackageInfo.fromPlatform(),
      timeout: const Duration(seconds: 3),
    );
    if (packageInfo == null) {
      _scheduleSplashNavigation();
      return false;
    }
    final currentVersion = packageInfo.version;
    Utils.showLog("Current version ==> ${packageInfo.version}");
    // 🔴 Replace this with API response

    final latestVersion = GetPlatform.isIOS
        ? Database.settingApiModel?.data?.iosAppVersion ?? ""
        : Database.settingApiModel?.data?.androidAppVersion ?? "";
    // final latestVersion = GetPlatform.isIOS ? "0.1.1" ?? "" : "0.1.1" ?? "";
    Utils.showLog("Latest  version ==> $latestVersion");
    if (latestVersion.isEmpty) {
      Utils.showLog("⚠️ Latest version missing from API");
      _scheduleSplashNavigation();
      return false;
    }
    if (isUpdateRequired(currentVersion, latestVersion)) {
      Get.dialog(
        const ForceUpdateDialog(),
        barrierDismissible: false, // ❌ outside tap disabled
      );
      return true;
    } else {
      _scheduleSplashNavigation();
      return false;
    }
  }

  bool isUpdateRequired(String current, String latest) {
    final currentParts = _parseVersionParts(current);
    final latestParts = _parseVersionParts(latest);

    for (int i = 0; i < latestParts.length; i++) {
      if (currentParts[i] < latestParts[i]) return true;
      if (currentParts[i] > latestParts[i]) return false;
    }
    return false;
  }

  List<int> _parseVersionParts(String version) {
    final parts = version
        .split('+')
        .first
        .split('-')
        .first
        .split('.')
        .map((part) => int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')))
        .map((part) => part ?? 0)
        .toList();

    while (parts.length < 3) {
      parts.add(0);
    }
    return parts.take(3).toList();
  }
}

Future<void> splashScreen() async {
  Timer(const Duration(seconds: 2), () async {
    void navigateFromSplash(String route, {dynamic arguments}) {
      if (Get.currentRoute != AppRoutes.splashScreenPage) {
        Utils.showLog(
            "Splash navigation skipped because current route is ${Get.currentRoute}");
        return;
      }

      Get.offAllNamed(route, arguments: arguments);
    }

    Future<void> enterLimitedGuestBrowsing() async {
      Database.fetchLoginUserProfileModel = null;
      await Database.onSetIsLogin(false);
      await Database.onSetGuestMode(true);
      await Database.onSetLoginType(0);
      await Database.onSetFillProfile(false);
      await Database.onSetSeenOnboarding(true);
      await Database.onSetLoginUserFirebaseId("");
      await Database.onSetLoginUserId("");
      await Database.onSetLoginListenerId("");
      await Database.onSetLoginUserName("");
      await Database.onSetLoginUserNickName("");
      await Database.onSetLoginUserEmail("");
      await Database.onSetLoginUserProfilePic("");
      await Database.onSetLoginUserPhoneNumber("");
      await Database.onSetLoginUserBirthDate("");
      await Database.onSetLoginUserGender("Male");
      await Database.onSetUserCoin("0.00");
    }

    // Check User Is Login Or Not...
    try {
      final token = await _guardedSplashTask<String>(
        "Splash Firebase token",
        () => FirebaseAccessToken.onGet(),
        timeout: const Duration(seconds: 5),
      );

      log("isLogin :: ${Database.isLogin}");
      log("isFillProfile :: ${Database.isFillProfile}");
      log("isSeenOnBoarding :: ${Database.isSeenOnBoarding}");
      log("Database.fetchLoginUserProfileModel?.user?.isListener :: ${Database.fetchLoginUserProfileModel?.user?.isListener}");

      if (Database.settingApiModel?.data?.isApplicationLive == false) {
        log("Application is not live...");
        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: const AppNotLiveDialog(),
          ),
        );
      } else {
        // Onboarding screens are disabled: mark as seen and always continue with main/login flow.
        if (!Database.isSeenOnBoarding) {
          await Database.onSetSeenOnboarding(true);
        }

        final hasValidProfile =
            Database.fetchLoginUserProfileModel?.status == true &&
                Database.fetchLoginUserProfileModel?.user != null;

        final userNotFoundInBackend =
            Database.fetchLoginUserProfileModel?.message ==
                "User not found in the database.";

        if (!hasValidProfile || token == null) {
          if (Database.isLogin && !userNotFoundInBackend) {
            // Keep existing signed-in state on transient startup failures
            // (network/token refresh race) instead of forcing guest logout.
            Utils.showLog(
              "Startup profile/token unavailable temporarily; preserving login session.",
            );

            if (Database.isFillProfile == true) {
              final isHostMode = Database.isListener;
              final isVerifiedExpert = Database.fetchLoginUserProfileModel?.user?.isListener == true;
              
              if (isHostMode || isVerifiedExpert) {
                navigateFromSplash(AppRoutes.hostBottomBar);
              } else {
                navigateFromSplash(AppRoutes.bottomBar);
              }
            } else {
              navigateFromSplash(AppRoutes.main);
            }
            return;
          }

          Utils.showLog(
              "No valid login profile. Using limited guest browsing.");
          await enterLimitedGuestBrowsing();
          navigateFromSplash(AppRoutes.bottomBar);
          return;
        } else {
          Utils.showLog("lllllllllllllllllllllllllllllllllllllll");
          if (Database.isLogin == true) {
            if (Database.isFillProfile == true) {
              final shouldBiometricUnlock =
                  await BiometricAuthService.shouldRequireUnlockOnStartup();
              final isHostMode = Database.isListener;
              final isVerifiedExpert = Database.fetchLoginUserProfileModel?.user?.isListener == true;
              final nextRoute = (isHostMode || isVerifiedExpert)
                  ? AppRoutes.hostBottomBar
                  : AppRoutes.bottomBar;

              if (shouldBiometricUnlock) {
                navigateFromSplash(
                  AppRoutes.biometricUnlockScreen,
                  arguments: {'nextRoute': nextRoute},
                );
                return;
              }
              if (isHostMode || isVerifiedExpert) {
                navigateFromSplash(AppRoutes.hostBottomBar);
              } else {
                navigateFromSplash(AppRoutes.bottomBar);
              }
            } else {
              navigateFromSplash(
                AppRoutes.fillProfileScreen,
                arguments: [
                  Database.loginUserName,
                  Database.loginUserProfilePic,
                  Database.loginUserEmail,
                ],
              );
            }
          } else {
            navigateFromSplash(AppRoutes.bottomBar);
          }
        }
      }
    } catch (error, stackTrace) {
      Utils.showLog("Splash navigation failed => $error");
      log("Splash navigation failed", error: error, stackTrace: stackTrace);
      await enterLimitedGuestBrowsing();
      navigateFromSplash(AppRoutes.bottomBar);
    }
  });
}
