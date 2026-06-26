import 'dart:convert';

CertificateDownloadModels certificateDownloadModelsFromJson(String str) =>
    CertificateDownloadModels.fromJson(json.decode(str));

String certificateDownloadModelsToJson(CertificateDownloadModels data) =>
    json.encode(data.toJson());

class CertificateDownloadModels {
  bool? success;
  String? message;
  List<Certificate>? data;
  Meta? meta;

  CertificateDownloadModels({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory CertificateDownloadModels.fromJson(Map<String, dynamic> json) =>
      CertificateDownloadModels(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null
            ? List<Certificate>.from(
                json["data"].map((x) => Certificate.fromJson(x)),
              )
            : [],
        meta: json["meta"] != null ? Meta.fromJson(json["meta"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data != null
            ? List<dynamic>.from(data!.map((x) => x.toJson()))
            : [],
        "meta": meta?.toJson(),
      };
}

// ─────────────────────────────────────────────
// Certificate (renamed from Datum)
// ─────────────────────────────────────────────

class Certificate {
  String? id;
  UserInfo? student;
  String? pdfUrl;
  UserInfo? issuedBy;
  String? title;
  DateTime? issuedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Certificate({
    this.id,
    this.student,
    this.pdfUrl,
    this.issuedBy,
    this.title,
    this.issuedAt,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
        id: json["_id"],
        student: json["student"] != null
            ? UserInfo.fromJson(json["student"])
            : null,
        pdfUrl: json["pdfUrl"],
        issuedBy: json["issuedBy"] != null
            ? UserInfo.fromJson(json["issuedBy"])
            : null,
        title: json["title"],
        issuedAt: json["issuedAt"] != null
            ? DateTime.tryParse(json["issuedAt"])
            : null,
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "student": student?.toJson(),
        "pdfUrl": pdfUrl,
        "issuedBy": issuedBy?.toJson(),
        "title": title,
        "issuedAt": issuedAt?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

// ─────────────────────────────────────────────
// UserInfo (renamed from IssuedBy)
// ─────────────────────────────────────────────

class UserInfo {
  String? id;
  String? name;
  String? email;

  UserInfo({
    this.id,
    this.name,
    this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
      };
}

// ─────────────────────────────────────────────
// Meta
// ─────────────────────────────────────────────

class Meta {
  int? page;
  int? limit;
  int? total;
  int? pages;

  Meta({
    this.page,
    this.limit,
    this.total,
    this.pages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        page: json["page"],
        limit: json["limit"],
        total: json["total"],
        pages: json["pages"],
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "limit": limit,
        "total": total,
        "pages": pages,
      };
}