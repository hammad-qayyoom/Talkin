import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:notisboard/custom/dialog/app_update_dialog.dart';
import 'package:notisboard/custom/dialog/exit_app_dialog.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/utils/version_helper.dart';
import 'package:notisboard/services/biometric/biometric_auth_service.dart';
import 'package:notisboard/services/recording_upload_queue.dart';
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
        if (fetchLoginUserProfileModel != null &&
            fetchLoginUserProfileModel?.status == true) {
          Database.setLoginUserProfile(fetchLoginUserProfileModel!);
        }
      }
      Database.fetchLoginUserProfileModel =
          fetchLoginUserProfileModel ?? Database.fetchLoginUserProfileModel;

      if (Database.loginUserFirebaseId.isEmpty &&
          (Database.fetchLoginUserProfileModel?.user?.firebaseId ?? '')
              .isNotEmpty) {
        Database.onSetLoginUserFirebaseId(
            Database.fetchLoginUserProfileModel?.user?.firebaseId ?? '');
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

      if (Database.fetchLoginUserProfileModel?.user?.isListener == true ||
          Database.isListener == true) {
        final listenerId =
            (Database.fetchLoginUserProfileModel?.user?.listenerId ??
                    Database.loginListenerId)
                .toString()
                .trim();
        if (listenerId.isNotEmpty) {
          fetchListenerProfileModel =
              await _guardedSplashTask<FetchListenerProfileModel>(
            "Listener profile fetch",
            () => FetchListenerProfileAPi.callApi(
              loginListenerId: listenerId,
            ),
          );
          if (fetchListenerProfileModel != null &&
              fetchListenerProfileModel?.status == true) {
            Database.setListenerProfile(fetchListenerProfileModel!);
          }
        }
        Database.fetchListenerProfileModel =
            fetchListenerProfileModel ?? Database.fetchListenerProfileModel;
      }

      await syncInitialBalances();

      // Retry any pending recording uploads from previous session
      if (Database.isLogin) {
        RecordingUploadQueue.instance.retryPendingUploads();
      }

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

  Future<bool> checkAppUpdate() async {
    final packageInfo = await _guardedSplashTask<PackageInfo>(
      "Package info",
      () => PackageInfo.fromPlatform(),
      timeout: const Duration(seconds: 3),
    );
    if (packageInfo == null) {
      return false;
    }
    final currentVersion = packageInfo.version;
    Utils.showLog("Installed app version ==> $currentVersion");

    final settingData = Database.settingApiModel?.data;
    if (settingData == null) {
      Utils.showLog("⚠️ App settings missing, skipping update check");
      return false;
    }

    final isIos = GetPlatform.isIOS;
    final latestVersion = (isIos
            ? (settingData.iosLatestVersion ?? settingData.iosAppVersion)
            : (settingData.androidLatestVersion ??
                settingData.androidAppVersion)) ??
        "";
    final minVersion = (isIos
            ? settingData.iosMinVersion
            : settingData.androidMinVersion) ??
        "";

    final isForceUpdateEnabled = settingData.isForceUpdateEnabled ?? false;
    final isFlexibleUpdateEnabled =
        settingData.isFlexibleUpdateEnabled ?? false;

    Utils.showLog(
        "Update check (Installed: $currentVersion) -> Latest: $latestVersion, Min: $minVersion, ForceToggle: $isForceUpdateEnabled, FlexibleToggle: $isFlexibleUpdateEnabled");

    // 1. Check if Force Update is triggered
    // Triggered when installed version is strictly below minimum supported version,
    // OR when Force Update toggle is ON and installed version is below latest version.
    bool requiresForceUpdate = false;
    if (minVersion.trim().isNotEmpty &&
        VersionHelper.isVersionBelow(currentVersion, minVersion)) {
      requiresForceUpdate = true;
    } else if (isForceUpdateEnabled &&
        latestVersion.trim().isNotEmpty &&
        VersionHelper.isVersionBelow(currentVersion, latestVersion)) {
      requiresForceUpdate = true;
    }

    if (requiresForceUpdate) {
      Utils.showLog("🚨 Force update required. Presenting blocking update dialog.");
      Get.dialog(
        AppUpdateDialog(
          isForceUpdate: true,
          targetVersion: latestVersion.isNotEmpty ? latestVersion : minVersion,
        ),
        barrierDismissible: false,
      );
      return true; // Block splash navigation
    }

    // 2. Check if Flexible Update is triggered
    // Triggered when Flexible Update toggle is ON and installed version is below latest version.
    if (isFlexibleUpdateEnabled &&
        latestVersion.trim().isNotEmpty &&
        VersionHelper.isVersionBelow(currentVersion, latestVersion)) {
      Utils.showLog("✨ Flexible update available. Presenting skippable dialog.");
      Get.dialog(
        AppUpdateDialog(
          isForceUpdate: false,
          targetVersion: latestVersion,
          onSkip: () {
            _scheduleSplashNavigation();
          },
        ),
        barrierDismissible: true,
      );
      return true; // Wait for user to tap Update or Skip
    }

    // 3. App is up to date or no update rules matched
    return false;
  }

  /// Backward-compatible wrapper
  Future<bool> checkForceUpdate() => checkAppUpdate();

  bool isUpdateRequired(String current, String latest) {
    return VersionHelper.isVersionBelow(current, latest);
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
            (Database.fetchLoginUserProfileModel?.status == true &&
                Database.fetchLoginUserProfileModel?.user != null) ||
            (Database.isLogin &&
                (Database.loginUserName.isNotEmpty ||
                    Database.loginListenerName.isNotEmpty));

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
              final isVerifiedExpert =
                  Database.fetchLoginUserProfileModel?.user?.isListener == true ||
                      Database.loginListenerId.isNotEmpty;
              
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
              final isVerifiedExpert =
                  Database.fetchLoginUserProfileModel?.user?.isListener == true ||
                      Database.loginListenerId.isNotEmpty;
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
