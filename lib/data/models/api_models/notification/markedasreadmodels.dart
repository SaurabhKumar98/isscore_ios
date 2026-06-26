// To parse this JSON data, do
//
//     final markedasReadModels = markedasReadModelsFromJson(jsonString);

import 'dart:convert';

MarkedasReadModels markedasReadModelsFromJson(String str) => MarkedasReadModels.fromJson(json.decode(str));

String markedasReadModelsToJson(MarkedasReadModels data) => json.encode(data.toJson());

class MarkedasReadModels {
    bool success;
    String message;
    Data data;
    dynamic meta;

    MarkedasReadModels({
        required this.success,
        required this.message,
        required this.data,
        required this.meta,
    });

    factory MarkedasReadModels.fromJson(Map<String, dynamic> json) => MarkedasReadModels(
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
        meta: json["meta"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
        "meta": meta,
    };
}

class Data {
    int modifiedCount;

    Data({
        required this.modifiedCount,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        modifiedCount: json["modifiedCount"],
    );

    Map<String, dynamic> toJson() => {
        "modifiedCount": modifiedCount,
    };
}
