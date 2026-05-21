import 'dart:developer';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:notisboard/custom/custom_web_view/web_view_screen.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class HostProfileScreenController extends GetxController {
  Future<void> onClickPrivacyPolicy() async {
    final String privacyPolicyUrl =
        Database.settingApiModel?.data?.expertPrivacyPolicyUrl.toString() ?? "";

    if (privacyPolicyUrl.isNotEmpty) {
      Get.to(
          () => WebViewScreen(url: privacyPolicyUrl, screen: "Privacy Policy"));
    } else {
      log('Invalid privacy policy URL');
    }
  }

  Future<void> onClickAboutUs() async {
    final String aboutUsUrl =
        Database.settingApiModel?.data?.aboutUsUrl.toString() ?? "";

    if (aboutUsUrl.isNotEmpty) {
      Get.to(() => WebViewScreen(
            url: aboutUsUrl,
            screen: "About Us",
          ));
    } else {
      log('Invalid privacy policy URL');
    }
  }

  // Future<void> onClickShare() async {
  //   var url = Uri.parse("https://play.google.com/store/apps/details?id=com.notisboard.mobile");
  //   if (await canLaunchUrl(url)) {
  //     launchUrl(url, mode: LaunchMode.externalApplication);
  //     throw "Cannot load the page";
  //   }
  // }

  // Future<void> onClickShare() async {
  //   Uri url;
  //
  //   if (GetPlatform.isAndroid) {
  //     url = Uri.parse("https://play.google.com/store/apps/details?id=${Utils.playStoreId}");
  //   } else if (GetPlatform.isIOS) {
  //     url = Uri.parse("https://apps.apple.com/app/${Utils.appStoreId}");
  //   } else {
  //     // Other platforms (optional fallback)
  //     throw 'Unsupported platform';
  //   }
  //
  //   if (await canLaunchUrl(url)) {
  //     await launchUrl(url, mode: LaunchMode.externalApplication);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  Future<void> onClickShare() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final String packageName = packageInfo.packageName; // Android

    Uri url;

    if (GetPlatform.isAndroid) {
      url = Uri.parse(
        "https://play.google.com/store/apps/details?id=$packageName",
      );
    } else if (GetPlatform.isIOS) {
      url = Uri.parse(
        "https://apps.apple.com/app/id${Utils.appStoreId}",
      );
    } else {
      throw 'Unsupported platform';
    }

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
