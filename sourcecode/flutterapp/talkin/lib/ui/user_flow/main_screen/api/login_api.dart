import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:notisboard/ui/user_flow/main_screen/model/login_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class LoginApi {
  static Future<LoginModel?> callApi({
    required int loginType,
    String? email,
    required String identity,
    required String fcmToken,
    required String countryCode,
    String? userName,
    String? profilePic,
    String? mobileNumber,
    String? birthDate,
    int? age,
    bool? acceptTerms,
    String? acceptanceSource,
    String? password,
    String? confirmPassword,
    String? authToken,
    String? authUid,
    String? referralCode,
  }) async {
    Utils.showLog("Login Api Calling...");

    String? token = authToken?.trim();
    if (token?.startsWith(ApiParams.tokenStartPoint) == true) {
      token = token!.substring(ApiParams.tokenStartPoint.length).trim();
    }
    if ((token ?? '').isEmpty) {
      token = await FirebaseAccessToken.onGet();
    }

    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    final uid = (authUid ?? '').trim().isNotEmpty
        ? authUid!.trim()
        : (currentUserUid ?? '').trim().isNotEmpty
            ? currentUserUid!.trim()
            : Database.loginUserFirebaseId;

    Utils.showLog("Login Api Token :: $token");
    Utils.showLog("Login Api UID :: $uid");

    final uri = Uri.parse(Api.login);
    Utils.showLog("Login Api URL :: $uri");

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer ${token ?? ''}",
      if (uid.isNotEmpty) ApiParams.authUid: uid,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("Login Api Headers :: $headers");

    final resolvedFcmToken = fcmToken.trim();
    Utils.showLog("Login Api Effective FCM Token :: $resolvedFcmToken");
    final resolvedReferralCode = (referralCode ?? '').trim().toUpperCase();

    final compliancePayload = {
      if ((birthDate ?? '').trim().isNotEmpty) ApiParams.birthDate: birthDate,
      if (age != null) 'age': age,
      if (acceptTerms != null) 'acceptTerms': acceptTerms,
      if ((acceptanceSource ?? '').trim().isNotEmpty)
        'acceptanceSource': acceptanceSource,
    };

    final body = loginType == 4
        ? json.encode(
            Database.userExist == false
                ? {
                    ApiParams.loginType: loginType,
                    ApiParams.email: email,
                    ApiParams.identity: identity,
                    ApiParams.fcmToken: resolvedFcmToken,
                    ApiParams.fullName: userName,
                    ApiParams.birthDate: birthDate,
                    'age': age,
                    'acceptTerms': acceptTerms ?? false,
                    'acceptanceSource': acceptanceSource ?? 'signup',
                    if ((password ?? '').trim().isNotEmpty)
                      ApiParams.password: password?.trim(),
                    ApiParams.confirmPassword: confirmPassword,
                    ApiParams.countryCode: countryCode,
                    if (resolvedReferralCode.isNotEmpty)
                      ApiParams.referralCode: resolvedReferralCode,
                  }
                : {
                    ApiParams.loginType: loginType,
                    ApiParams.email: email,
                    ApiParams.identity: identity,
                    ApiParams.fcmToken: resolvedFcmToken,
                    if ((password ?? '').trim().isNotEmpty)
                      ApiParams.password: password?.trim(),
                    ApiParams.countryCode: countryCode,
                    if (resolvedReferralCode.isNotEmpty)
                      ApiParams.referralCode: resolvedReferralCode,
                  },
          )
        : loginType == 3
            ? json.encode(
                {
                  ApiParams.loginType: loginType,
                  ApiParams.phoneNumber: mobileNumber,
                  ApiParams.identity: identity,
                  ApiParams.fcmToken: resolvedFcmToken,
                  ApiParams.countryCode: countryCode,
                  if (resolvedReferralCode.isNotEmpty)
                    ApiParams.referralCode: resolvedReferralCode,
                  ...compliancePayload,
                },
              )
            : json.encode(
                {
                  ApiParams.loginType: loginType,
                  ApiParams.email: email,
                  ApiParams.identity: identity,
                  ApiParams.fcmToken: resolvedFcmToken,
                  ApiParams.profilePic: profilePic,
                  ApiParams.fullName: userName,
                  ApiParams.countryCode: countryCode,
                  if (resolvedReferralCode.isNotEmpty)
                    ApiParams.referralCode: resolvedReferralCode,
                  ...compliancePayload,
                },
              );
    Utils.showLog("Login Api Body :: $body");

    try {
      final response = await http.post(uri, headers: headers, body: body);

      Utils.showLog("Login Api StatusCode :: ${response.statusCode}");
      Utils.showLog("Login Api Response :: ${response.body}");

      final jsonResponse = json.decode(response.body);
      return LoginModel.fromJson(jsonResponse);
    } catch (error) {
      Utils.showLog("Login Api Error => $error");
    }
    return null;
  }
}
