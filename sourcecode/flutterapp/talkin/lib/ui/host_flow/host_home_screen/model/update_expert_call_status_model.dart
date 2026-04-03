import 'dart:convert';

UpdateExpertCallStatusModel updateExpertCallStatusModelFromJson(String str) => UpdateExpertCallStatusModel.fromJson(json.decode(str));

String updateExpertCallStatusModelToJson(UpdateExpertCallStatusModel data) => json.encode(data.toJson());

class UpdateExpertCallStatusModel {
  bool? status;
  String? message;

  UpdateExpertCallStatusModel({
    this.status,
    this.message,
  });

  factory UpdateExpertCallStatusModel.fromJson(Map<String, dynamic> json) => UpdateExpertCallStatusModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
