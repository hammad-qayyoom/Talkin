const fs = require('fs');

// 1. host_setting_controller.dart
let hsc = fs.readFileSync('lib/ui/host_flow/host_setting_screen/controller/host_setting_controller.dart', 'utf8');
hsc = hsc.replace("import 'package:notisboard/ui/host_flow/host_setting_screen/api/delete_listener_api.dart';\n", "");
fs.writeFileSync('lib/ui/host_flow/host_setting_screen/controller/host_setting_controller.dart', hsc);

// 2 & 3. delete_account_otp_controller.dart
let dac = fs.readFileSync('lib/ui/user_flow/delete_account_otp_screen/controller/delete_account_otp_controller.dart', 'utf8');
dac = dac.replace(
  /Database\.onSetIsLogin\(false\);\s*Database\.onSetToken\(""\);\s*Database\.onSetRole\(""\);\s*Database\.onSetIdentity\(""\);\s*Database\.onSetLoginType\(0\);\s*Database\.onSetLoginUserId\(""\);/,
  "Database.onLogOut();"
);
dac = dac.replace(/AppRoutes\.splashScreen/g, "AppRoutes.splashScreenPage");
fs.writeFileSync('lib/ui/user_flow/delete_account_otp_screen/controller/delete_account_otp_controller.dart', dac);

// 4. delete_account_otp_widget.dart
let daw = fs.readFileSync('lib/ui/user_flow/delete_account_otp_screen/widget/delete_account_otp_widget.dart', 'utf8');
daw = daw.replace(/return const CustomAppBar\(/g, "return CustomAppBar(");
fs.writeFileSync('lib/ui/user_flow/delete_account_otp_screen/widget/delete_account_otp_widget.dart', daw);

// 5. setting_controller.dart
let sc = fs.readFileSync('lib/ui/user_flow/setting_screen/controller/setting_controller.dart', 'utf8');
if (!sc.includes("app_routes.dart")) {
  sc = "import 'package:notisboard/routes/app_routes.dart';\n" + sc;
}
fs.writeFileSync('lib/ui/user_flow/setting_screen/controller/setting_controller.dart', sc);

