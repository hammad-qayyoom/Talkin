import 'dart:convert';

GrowthSpotlightModel growthSpotlightModelFromJson(String str) =>
    GrowthSpotlightModel.fromJson(json.decode(str));

String growthSpotlightModelToJson(GrowthSpotlightModel data) =>
    json.encode(data.toJson());

class GrowthSpotlightModel {
  bool? status;
  String? message;
  List<GrowthSpotlightData>? data;

  GrowthSpotlightModel({
    this.status,
    this.message,
    this.data,
  });

  factory GrowthSpotlightModel.fromJson(Map<String, dynamic> json) =>
      GrowthSpotlightModel(
        status: json["status"] as bool?,
        message: json["message"]?.toString(),
        data: json["data"] is List
            ? (json["data"] as List)
                .map((item) =>
                    GrowthSpotlightData.fromJson(item as Map<String, dynamic>))
                .toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.map((item) => item.toJson()).toList() ?? [],
      };
}

class GrowthSpotlightData {
  String? id;
  String? image;
  String? title;
  String? description;
  int? sortOrder;
  bool? isActive;

  GrowthSpotlightData({
    this.id,
    this.image,
    this.title,
    this.description,
    this.sortOrder,
    this.isActive,
  });

  factory GrowthSpotlightData.fromJson(Map<String, dynamic> json) =>
      GrowthSpotlightData(
        id: (json["_id"] ?? json["id"])?.toString(),
        image: json["image"]?.toString(),
        title: json["title"]?.toString(),
        description: json["description"]?.toString(),
        sortOrder: int.tryParse((json["sortOrder"] ?? 0).toString()) ?? 0,
        isActive: json["isActive"] == null
            ? true
            : json["isActive"] == true ||
                json["isActive"].toString().toLowerCase() == "true",
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "image": image,
        "title": title,
        "description": description,
        "sortOrder": sortOrder,
        "isActive": isActive,
      };
}
