const fs = require('fs');
let code = fs.readFileSync('routes/app_pages.dart', 'utf8');

const importStr = "import 'package:notisboard/ui/user_flow/delete_account_otp_screen/view/delete_account_otp_screen.dart';\nimport 'package:notisboard/ui/user_flow/delete_account_otp_screen/binding/delete_account_otp_binding.dart';\n";
const routeStr = "    GetPage(\n      name: AppRoutes.deleteAccountOtpScreen,\n      page: () => DeleteAccountOtpScreen(),\n      binding: DeleteAccountOtpBinding(),\n    ),\n";

if(!code.includes('DeleteAccountOtpScreen')) {
  code = importStr + code;
  code = code.replace("  static List<GetPage> list = [", "  static List<GetPage> list = [\n" + routeStr);
  fs.writeFileSync('routes/app_pages.dart', code);
}
