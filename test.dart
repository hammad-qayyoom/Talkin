import 'dart:convert';
class HostListenerProfileUpdateModel {
  bool? status;
  String? message;

  HostListenerProfileUpdateModel({
    this.status,
    this.message,
  });

  factory HostListenerProfileUpdateModel.fromJson(Map<String, dynamic> json) =>
      HostListenerProfileUpdateModel(
        status: json["status"],
        message: json["message"],
      );
}

void main() {
  String jsonString = '{"status":true,"message":"Expert profile updated successfully."}';
  final jsonResult = jsonDecode(jsonString);
  final model = HostListenerProfileUpdateModel.fromJson(jsonResult);
  if (model.status == true) {
      print("SUCCESS");
  } else {
      print("FAILED");
  }
}
