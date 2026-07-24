import 'package:get/get.dart';
import 'package:notisboard/ui/host_flow/host_boost_screen/api/boost_api.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/api/host_coin_api.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

class HostBoostScreenController extends GetxController {
  List<BoostPlanModel> boostPlans = [];
  BoostActiveModel? activeBoost;
  BoostAnalyticsModel? analytics;
  num walletBalance = 0;
  bool isLoading = true;
  bool isActivating = false;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading = true;
    update();

    try {
      final plansFuture = BoostApi.fetchPlans();
      final activeBoostFuture = BoostApi.fetchActiveBoost();
      final analyticsFuture = BoostApi.fetchAnalytics();
      final coinFuture = HostCoinApi.callApi();

      final results = await Future.wait([
        plansFuture,
        activeBoostFuture,
        analyticsFuture,
        coinFuture,
      ]);

      boostPlans = (results[0] as List<BoostPlanModel>?) ?? [];
      activeBoost = results[1] as BoostActiveModel?;
      analytics = results[2] as BoostAnalyticsModel?;

      final coinResult = results[3] as dynamic;
      if (coinResult != null && coinResult.status == true && coinResult.coin != null) {
        walletBalance = double.parse((coinResult.coin as num).toStringAsFixed(2));
        Database.onSetListenerCoin(walletBalance.toStringAsFixed(2));
      } else {
        walletBalance = num.tryParse(Database.listenerCoin) ?? 0;
      }
    } catch (e) {
      Utils.showLog("Boost data load error: ${e.toString()}");
      walletBalance = num.tryParse(Database.listenerCoin) ?? 0;
    }

    isLoading = false;
    update();
  }

  Future<void> refreshData() async {
    await _loadData();
  }

  Future<bool> activateBoost(String boostPlanId) async {
    isActivating = true;
    update();

    try {
      final result = await BoostApi.activateBoost(boostPlanId);

      if (result != null && result["status"] == true) {
        final data = result["data"];
        if (data != null && data["walletBalance"] != null) {
          walletBalance = double.parse((data["walletBalance"] as num).toStringAsFixed(2));
          Database.onSetListenerCoin(walletBalance.toStringAsFixed(2));
        }

        activeBoost = data != null && data["boost"] != null
            ? BoostActiveModel.fromJson(data["boost"])
            : null;

        Get.snackbar("Success", result["message"] ?? "Boost activated!",
            snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        Get.snackbar("Error", result?["message"] ?? "Failed to activate boost",
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Utils.showLog("Activate boost error: ${e.toString()}");
      Get.snackbar("Error", "Something went wrong",
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isActivating = false;
      update();
    }
  }

  Future<bool> extendBoost(String boostPlanId) async {
    isActivating = true;
    update();

    try {
      final result = await BoostApi.extendBoost(boostPlanId);

      if (result != null && result["status"] == true) {
        final data = result["data"];
        if (data != null && data["walletBalance"] != null) {
          walletBalance = double.parse((data["walletBalance"] as num).toStringAsFixed(2));
          Database.onSetListenerCoin(walletBalance.toStringAsFixed(2));
        }

        activeBoost = data != null && data["boost"] != null
            ? BoostActiveModel.fromJson(data["boost"])
            : null;

        Get.snackbar("Success", result["message"] ?? "Boost extended!",
            snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        Get.snackbar("Error", result?["message"] ?? "Failed to extend boost",
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Utils.showLog("Extend boost error: ${e.toString()}");
      Get.snackbar("Error", "Something went wrong",
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isActivating = false;
      update();
    }
  }
}
