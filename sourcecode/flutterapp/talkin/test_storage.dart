import 'package:get_storage/get_storage.dart';
void main() async {
  await GetStorage.init();
  var s = GetStorage();
  s.write('isLogin', true);
}
