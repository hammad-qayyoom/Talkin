const fs = require('fs');
let code = fs.readFileSync('host_setting_screen/controller/host_setting_controller.dart', 'utf8');

code = "import 'package:notisboard/ui/user_flow/setting_screen/api/request_delete_otp_api.dart';\nimport 'package:notisboard/routes/app_routes.dart';\n" + code;

code = code.replace(
  /deleteListenerResponseModel = await DeleteListenerApi\.callApi\(\);\s*Get\.back\(\);\s*\/\/ Stop Loading\.\.\.\s*if \(deleteListenerResponseModel\?\.status \?\? false\) \{\s*Database\.onLogOut\(\);\s*Utils\.showLog\(deleteListenerResponseModel\?\.message \?\?\s*"User account deleted successfully\."\);\s*\}/g,
  `final response = await RequestDeleteOtpApi.callApi();\n\n    Get.back(); // Stop Loading...\n\n    if (response != null && response.status == true) {\n      Utils.showToast(Get.context!, response.message ?? "OTP sent to your email");\n      Get.toNamed(AppRoutes.deleteAccountOtpScreen);\n    } else {\n      Utils.showToast(Get.context!, response?.message ?? "Failed to request OTP");\n    }`
);

fs.writeFileSync('host_setting_screen/controller/host_setting_controller.dart', code);
