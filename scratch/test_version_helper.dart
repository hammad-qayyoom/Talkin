import '../sourcecode/flutterapp/talkin/lib/utils/version_helper.dart';

void main() {
  assert(VersionHelper.compare("1.0.0", "1.5.0") < 0, "1.0.0 < 1.5.0");
  assert(VersionHelper.compare("1.5.0", "2.0.0") < 0, "1.5.0 < 2.0.0");
  assert(VersionHelper.compare("2.0.0", "1.5.0") > 0, "2.0.0 > 1.5.0");
  assert(VersionHelper.compare("1.0.0", "1.0.0") == 0, "1.0.0 == 1.0.0");
  assert(VersionHelper.compare("1.0.10", "1.0.2") > 0, "1.0.10 > 1.0.2");
  assert(VersionHelper.compare("1.3.1+44", "1.3.1") == 0, "1.3.1+44 == 1.3.1");
  assert(VersionHelper.compare("1.3.1+44", "1.3.2") < 0, "1.3.1+44 < 1.3.2");
  assert(VersionHelper.compare("v2.1.0", "2.0.9") > 0, "v2.1.0 > 2.0.9");
  assert(VersionHelper.compare("1.0", "1.0.0") == 0, "1.0 == 1.0.0");

  assert(VersionHelper.isVersionBelow("1.0.0", "1.0.1") == true, "1.0.0 is below 1.0.1");
  assert(VersionHelper.isVersionBelow("1.5.0", "1.5.0") == false, "1.5.0 is not below 1.5.0");
  assert(VersionHelper.isVersionBelow("2.0.0", "1.9.9") == false, "2.0.0 is not below 1.9.9");
  assert(VersionHelper.isVersionBelow("1.3.1+44", "1.4.0") == true, "1.3.1+44 is below 1.4.0");

  print("ALL VERSION HELPER TESTS PASSED ✅");
}
