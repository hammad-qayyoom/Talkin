import 'package:firebase_auth/firebase_auth.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class GuestAuth {
  static Future<Map<String, String>> headers({
    bool contentType = true,
    bool allowGuest = false,
  }) async {
    final headers = <String, String>{
      ApiParams.key: Api.secretKey,
      if (contentType) ApiParams.contentType: 'application/json',
    };

    final credentials = await _credentials(allowGuest: allowGuest);
    if (credentials == null) {
      return headers;
    }

    headers[ApiParams.authToken] =
        '${ApiParams.tokenStartPoint}${credentials.token}';
    headers[ApiParams.authUid] = credentials.uid;
    return headers;
  }

  static Future<_AuthCredentials?> _credentials({
    required bool allowGuest,
  }) async {
    try {
      var user = FirebaseAuth.instance.currentUser;

      if (allowGuest && !Database.isLogin) {
        return null;
      }

      if (user == null) {
        return null;
      }

      final token = Database.isLogin
          ? await FirebaseAccessToken.onGet()
          : await user.getIdToken();
      final uid = Database.loginUserFirebaseId.isNotEmpty
          ? Database.loginUserFirebaseId
          : user.uid;

      if ((token ?? '').trim().isEmpty || uid.trim().isEmpty) {
        return null;
      }

      return _AuthCredentials(token: token!, uid: uid);
    } catch (error) {
      Utils.showLog('Guest auth headers failed => $error');
      return null;
    }
  }
}

class _AuthCredentials {
  final String token;
  final String uid;

  const _AuthCredentials({
    required this.token,
    required this.uid,
  });
}
