const fs = require('fs');
let code = fs.readFileSync('setting_screen/controller/setting_controller.dart', 'utf8');

code = "import 'package:notisboard/ui/user_flow/setting_screen/api/request_delete_otp_api.dart';\n" + code;

code = code.replace(
  /deleteUserModel = await DeleteUserApi\.callApi\(\);\s*Get\.back\(\);\s*\/\/ Stop Loading\.\.\.\s*if \(deleteUserModel\?\.status \?\? false\) \{\s*Database\.onLogOut\(\);\s*Utils\.showLog\(\s*deleteUserModel\?\.message \?\? "User account deleted successfully\."\);\s*\}/g,
  `final response = await RequestDeleteOtpApi.callApi();\n\n    Get.back(); // Stop Loading...\n\n    if (response != null && response.status == true) {\n      Utils.showToast(Get.context!, response.message ?? "OTP sent to your email");\n      Get.toNamed(AppRoutes.deleteAccountOtpScreen);\n    } else {\n      Utils.showToast(Get.context!, response?.message ?? "Failed to request OTP");\n    }`
);

fs.writeFileSync('setting_screen/controller/setting_controller.dart', code);
