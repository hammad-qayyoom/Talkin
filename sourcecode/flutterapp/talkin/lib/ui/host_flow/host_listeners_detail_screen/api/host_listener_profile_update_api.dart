import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:notisboard/ui/host_flow/host_listeners_detail_screen/model/host_listener_profile_update_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/utils.dart';

class HostListenerProfileUpdateApi {
  static Future<HostListenerProfileUpdateModel?> callApi({
    required String? listenerId,
    required String? selfIntro,
    required String? name,
    required String? nickName,
    required String? image,
    required String? ratePrivateVideoCall,
    required String? ratePrivateAudioCall,
    required String? rateInPersonSession,
    required String? language,
    required String? talkTopics,
    required String? categoryIds,
    String? consultationModes,
    String? inPersonPricing,
    String? clinicDetails,
  }) async {
    Utils.showLog("Listener Edit Profile Api Calling...");

    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse(
            "${Api.listenerEditProfile}${ApiParams.expertId}=$listenerId"),
      );
      Utils.showLog("Listener Edit Profile Api URL => ${request.url}");

      var headers = {
        ApiParams.key: Api.secretKey,
        // ApiParams.authToken: 'Bearer $token',
        ApiParams.contentType: 'application/json',
        // ApiParams.authUid: uid
      };
      Utils.showLog("Listener Edit Profile Api Headers => $headers");

      if ((selfIntro ?? '').isNotEmpty) request.fields[ApiParams.selfIntro] = selfIntro!;
      if ((name ?? '').isNotEmpty) request.fields[ApiParams.name] = name!;
      if ((nickName ?? '').isNotEmpty) request.fields[ApiParams.nickName] = nickName!;
      if ((language ?? '').isNotEmpty) request.fields[ApiParams.language] = language!;
      if ((talkTopics ?? '').isNotEmpty) request.fields[ApiParams.talkTopics] = talkTopics!;
      if ((categoryIds ?? '').isNotEmpty) request.fields['categoryIds'] = categoryIds!;
      if ((ratePrivateAudioCall ?? '').isNotEmpty) request.fields[ApiParams.ratePrivateAudioCall] = ratePrivateAudioCall!;
      if ((ratePrivateVideoCall ?? '').isNotEmpty) request.fields[ApiParams.ratePrivateVideoCall] = ratePrivateVideoCall!;
      if ((rateInPersonSession ?? '').isNotEmpty) request.fields['rateInPersonSession'] = rateInPersonSession!;
      if ((consultationModes ?? '').isNotEmpty) request.fields['consultationModes'] = consultationModes!;
      if ((inPersonPricing ?? '').isNotEmpty) request.fields['inPersonPricing'] = inPersonPricing!;
      if ((clinicDetails ?? '').isNotEmpty) request.fields['clinicDetails'] = clinicDetails!;
      if ((image ?? '').isNotEmpty) request.fields[ApiParams.image] = image!;

      if (image != null) {
        request.files
            .add(await http.MultipartFile.fromPath(ApiParams.image, image));
      }

      request.headers.addAll(headers);
      log("Listener Edit Profile Api Request => ${request.fields}");

      final response = await request.send();
      log("Listener Edit Profile Api Response => ${response.statusCode}");
      log("Listener Edit Profile Api Status => ${response.statusCode}");

      final responseBody = await response.stream.bytesToString();
      final jsonResult = jsonDecode(responseBody);
      Utils.showLog("Listener Edit Profile Api Response => $jsonResult");

      return HostListenerProfileUpdateModel.fromJson(jsonResult);
    } catch (e) {
      Utils.showLog("Listener Edit Profile Api Error => $e");
      return null;
    }
  }
}
