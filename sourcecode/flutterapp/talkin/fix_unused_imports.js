const fs = require('fs');

let hsc = fs.readFileSync('lib/ui/host_flow/host_setting_screen/controller/host_setting_controller.dart', 'utf8');
hsc = hsc.replace(/import 'package:notisboard\/ui\/host_flow\/host_setting_screen\/api\/delete_listener_api\.dart';\n/, "");
fs.writeFileSync('lib/ui/host_flow/host_setting_screen/controller/host_setting_controller.dart', hsc);

let sc = fs.readFileSync('lib/ui/user_flow/setting_screen/controller/setting_controller.dart', 'utf8');
sc = sc.replace(/import 'package:notisboard\/ui\/user_flow\/setting_screen\/api\/delete_user_api\.dart';\n/, "");
fs.writeFileSync('lib/ui/user_flow/setting_screen/controller/setting_controller.dart', sc);

