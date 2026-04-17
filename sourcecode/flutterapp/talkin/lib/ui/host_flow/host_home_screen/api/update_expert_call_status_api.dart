import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notisboard/ui/host_flow/host_home_screen/model/update_expert_call_status_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/utils.dart';

class UpdateExpertCallStatusApi {
  static UpdateExpertCallStatusModel? updateExpertCallStatusModel;

  static Future<UpdateExpertCallStatusModel?> callApi({
    required String expertId,
    required String status,
  }) async {
    Utils.showLog("Updating Expert Availability...");

    final uri = Uri.parse("${Api.updateExpertCallStatus}${ApiParams.expertId}=$expertId&${ApiParams.field}=$status");
    Utils.showLog("Update Expert Availability Api URL :: $uri");

    var headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.contentType: 'application/json',
    };
    Utils.showLog("Update Expert Availability Api Headers => $headers");

    try {
      final response = await http.patch(uri, headers: headers);

      Utils.showLog("Update Expert Availability Api StatusCode :: ${response.statusCode}");
      Utils.showLog("Update Expert Availability Api Response :: ${response.body}");

      final jsonResponse = json.decode(response.body);
      return UpdateExpertCallStatusModel.fromJson(jsonResponse);
    } catch (error) {
      Utils.showLog("Update Expert Availability Api Error => $error");
    }

    return updateExpertCallStatusModel;
  }
}
