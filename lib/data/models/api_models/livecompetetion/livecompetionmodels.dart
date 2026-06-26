// lib/data/models/api_models/livecompetetion/livecompetetion_models.dart
//
// Additions vs the original:
//   • MegaAuditionData and GrandFinaleData model classes
//   • LiveCompetition.megaAudition / .grandFinale fields
//   • LiveCompetition.fromJson now parses those two nested objects

class LiveCompetetionModels {
  final bool? success;
  final String? message;
  final List<LiveCompetition>? data;
  final LiveCompetitionMeta? meta;

  LiveCompetetionModels({this.success, this.message, this.data, this.meta});

  factory LiveCompetetionModels.fromJson(Map<String, dynamic> json) {
    return LiveCompetetionModels(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => LiveCompetition.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] != null
          ? LiveCompetitionMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ─── Meta ────────────────────────────────────────────────────────────────────

class LiveCompetitionMeta {
  final int? page;
  final int? limit;
  final int? total;
  final int? pages;

  LiveCompetitionMeta({this.page, this.limit, this.total, this.pages});

  factory LiveCompetitionMeta.fromJson(Map<String, dynamic> json) {
    return LiveCompetitionMeta(
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      total: json['total'] as int?,
      pages: json['pages'] as int?,
    );
  }
}

// ─── Mega Audition (Round 1) ──────────────────────────────────────────────────

class MegaAuditionData {
  final LiveCompetitionRegistration? registration;
  final LiveCompetitionEventWindow? eventWindow;
  final int? totalParticipants;
  final int? totalSubmissions;
  final String? title;
  final DateTime? resultDeclarationDate;
  final int? maxQualifiers;
  final LiveCompetitionSubmission? submission;
  final LiveCompetitionFee? fee;
  final String? status;
  final bool? isRegistrationOpen;
  final bool? isEventLive;
  final LiveCompetitionOffer? appliedOffer;
  final double? discountedPrice;
  final List<dynamic>? winners;
  final String? googleMeetLink;
  final String? googleMeetPassword;

  MegaAuditionData({
    this.registration,
    this.eventWindow,
    this.totalParticipants,
    this.totalSubmissions,
    this.title,
    this.resultDeclarationDate,
    this.maxQualifiers,
    this.submission,
    this.fee,
    this.status,
    this.isRegistrationOpen,
    this.isEventLive,
    this.appliedOffer,
    this.discountedPrice,
    this.winners,
    this.googleMeetLink,
    this.googleMeetPassword,
  });

  factory MegaAuditionData.fromJson(Map<String, dynamic> json) {
    return MegaAuditionData(
      registration: json['registration'] != null
          ? LiveCompetitionRegistration.fromJson(
              json['registration'] as Map<String, dynamic>,
            )
          : null,
      eventWindow: json['eventWindow'] != null
          ? LiveCompetitionEventWindow.fromJson(
              json['eventWindow'] as Map<String, dynamic>,
            )
          : null,
      totalParticipants: json['totalParticipants'] as int?,
      totalSubmissions: json['totalSubmissions'] as int?,
      title: json['title'] as String?,
      resultDeclarationDate: json['resultDeclarationDate'] != null
          ? DateTime.tryParse(json['resultDeclarationDate'] as String)
          : null,
      maxQualifiers: json['maxQualifiers'] as int?,
      submission: json['submission'] != null
          ? LiveCompetitionSubmission.fromJson(
              json['submission'] as Map<String, dynamic>,
            )
          : null,
      fee: json['fee'] != null
          ? LiveCompetitionFee.fromJson(json['fee'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String?,
      isRegistrationOpen: json['isRegistrationOpen'] as bool?,
      isEventLive: json['isEventLive'] as bool?,
      appliedOffer: json['appliedOffer'] != null
          ? LiveCompetitionOffer.fromJson(
              json['appliedOffer'] as Map<String, dynamic>,
            )
          : null,
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
      winners: json['winners'] as List<dynamic>?,
      googleMeetLink: json['googleMeetLink'] as String?,
      googleMeetPassword: json['googleMeetPassword'] as String?,
    );
  }
}

// ─── Grand Finale (Round 2) ───────────────────────────────────────────────────

class GrandFinaleData {
  /// Payment window acts as the "registration" window for Round 2
  final LiveCompetitionRegistration? paymentWindow;
  final LiveCompetitionEventWindow? eventWindow;
  final int? totalParticipants;
  final int? totalSubmissions;
  final String? title;
  final DateTime? resultDeclarationDate;
  final LiveCompetitionSubmission? submission;
  final LiveCompetitionFee? fee;
  final String? status;
  final bool? isVisible;
  final bool? isPaymentOpen;
  final bool? isEventLive;
  final LiveCompetitionOffer? appliedOffer;
  final double? discountedPrice;
  final List<dynamic>? winners;
  final String? googleMeetLink;
  final String? googleMeetPassword;

  GrandFinaleData({
    this.paymentWindow,
    this.eventWindow,
    this.totalParticipants,
    this.totalSubmissions,
    this.title,
    this.resultDeclarationDate,
    this.submission,
    this.fee,
    this.status,
    this.isVisible,
    this.isPaymentOpen,
    this.isEventLive,
    this.appliedOffer,
    this.discountedPrice,
    this.winners,
    this.googleMeetLink,
    this.googleMeetPassword,
  });

  factory GrandFinaleData.fromJson(Map<String, dynamic> json) {
    return GrandFinaleData(
      paymentWindow: json['paymentWindow'] != null
          ? LiveCompetitionRegistration.fromJson(
              json['paymentWindow'] as Map<String, dynamic>,
            )
          : null,
      eventWindow: json['eventWindow'] != null
          ? LiveCompetitionEventWindow.fromJson(
              json['eventWindow'] as Map<String, dynamic>,
            )
          : null,
      totalParticipants: json['totalParticipants'] as int?,
      totalSubmissions: json['totalSubmissions'] as int?,
      title: json['title'] as String?,
      resultDeclarationDate: json['resultDeclarationDate'] != null
          ? DateTime.tryParse(json['resultDeclarationDate'] as String)
          : null,
      submission: json['submission'] != null
          ? LiveCompetitionSubmission.fromJson(
              json['submission'] as Map<String, dynamic>,
            )
          : null,
      fee: json['fee'] != null
          ? LiveCompetitionFee.fromJson(json['fee'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String?,
      isVisible: json['isVisible'] as bool?,
      isPaymentOpen: json['isPaymentOpen'] as bool?,
      isEventLive: json['isEventLive'] as bool?,
      appliedOffer: json['appliedOffer'] != null
          ? LiveCompetitionOffer.fromJson(
              json['appliedOffer'] as Map<String, dynamic>,
            )
          : null,
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
      winners: json['winners'] as List<dynamic>?,
      googleMeetLink: json['googleMeetLink'] as String?,
      googleMeetPassword: json['googleMeetPassword'] as String?,
    );
  }
}

// ─── Live Competition ─────────────────────────────────────────────────────────

class LiveCompetition {
  final String? id;
  final String? title;
  final String? description;
  final String? bannerUrl;
  final bool? isPublished;
  final String? status;
  final int? totalParticipants;
  final int? totalSubmissions;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isRegistrationOpen;
  final bool? isEventLive;
  final bool? hasRegistered;
  final bool? hasSubmitted;
  final double? walletBalance;
  final double? discountedPrice;
  final LiveCompetitionFee? fee;
  final LiveCompetitionRegistration? registration;
  final LiveCompetitionEventWindow? eventWindow;
  final LiveCompetitionSubmission? submission;
  final LiveCompetitionCategory? category;
  final LiveCompetitionOffer? appliedOffer;
  final StudentStatus? studentStatus;
  final List<CompetitionPrize>? prizes;
  final dynamic winner;

  // ✅ NEW: typed round data parsed from the top-level JSON keys
  final MegaAuditionData? megaAudition;
  final GrandFinaleData? grandFinale;

  LiveCompetition({
    this.id,
    this.title,
    this.description,
    this.bannerUrl,
    this.isPublished,
    this.status,
    this.totalParticipants,
    this.totalSubmissions,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.isRegistrationOpen,
    this.isEventLive,
    this.hasRegistered,
    this.hasSubmitted,
    this.walletBalance,
    this.discountedPrice,
    this.fee,
    this.registration,
    this.eventWindow,
    this.submission,
    this.category,
    this.appliedOffer,
    this.winner,
    this.megaAudition,
    this.grandFinale,
    this.prizes,
    this.studentStatus,
  });

  factory LiveCompetition.fromJson(Map<String, dynamic> json) {
    return LiveCompetition(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      isPublished: json['isPublished'] as bool?,
      status: json['status'] as String?,
      totalParticipants: json['totalParticipants'] as int?,
      totalSubmissions: json['totalSubmissions'] as int?,
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      isRegistrationOpen: json['isRegistrationOpen'] as bool?,
      isEventLive: json['isEventLive'] as bool?,
      hasRegistered: json['hasRegistered'] as bool?,
      hasSubmitted: json['hasSubmitted'] as bool?,
      walletBalance: (json['walletBalance'] as num?)?.toDouble(),
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
      fee: json['fee'] != null
          ? LiveCompetitionFee.fromJson(json['fee'] as Map<String, dynamic>)
          : null,
      registration: json['registration'] != null
          ? LiveCompetitionRegistration.fromJson(
              json['registration'] as Map<String, dynamic>,
            )
          : null,
      eventWindow: json['eventWindow'] != null
          ? LiveCompetitionEventWindow.fromJson(
              json['eventWindow'] as Map<String, dynamic>,
            )
          : null,
      submission: json['submission'] != null
          ? LiveCompetitionSubmission.fromJson(
              json['submission'] as Map<String, dynamic>,
            )
          : null,
      category: json['category'] != null
          ? LiveCompetitionCategory.fromJson(
              json['category'] as Map<String, dynamic>,
            )
          : null,
      appliedOffer: json['appliedOffer'] != null
          ? LiveCompetitionOffer.fromJson(
              json['appliedOffer'] as Map<String, dynamic>,
            )
          : null,
      winner: json['winner'],
      // ✅ Parse the round data — the JSON keys are camelCase
      megaAudition: json['megaAudition'] != null
          ? MegaAuditionData.fromJson(
              json['megaAudition'] as Map<String, dynamic>,
            )
          : null,
      grandFinale: json['grandFinale'] != null
          ? GrandFinaleData.fromJson(
              json['grandFinale'] as Map<String, dynamic>,
            )
          : null,
      studentStatus: json['studentStatus'] != null
          ? StudentStatus.fromJson(
              json['studentStatus'] as Map<String, dynamic>,
            )
          : null,
      prizes: (json['prizes'] as List<dynamic>?)
          ?.map((e) => CompetitionPrize.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  double get effectivePrice => discountedPrice ?? fee?.amount?.toDouble() ?? 0;
  double get originalPrice => fee?.amount?.toDouble() ?? 0;
  double get discountAmount {
    final orig = originalPrice;
    final eff = effectivePrice;
    return orig > eff ? orig - eff : 0;
  }

  bool get isFree => fee?.isPaid == false || originalPrice == 0;
  bool get isLive => status == 'LIVE';
  bool get isUpcoming => status == 'UPCOMING';
}

// ─── Fee ─────────────────────────────────────────────────────────────────────

class LiveCompetitionFee {
  final num? amount;
  final String? currency;
  final bool? isPaid;

  LiveCompetitionFee({this.amount, this.currency, this.isPaid});

  factory LiveCompetitionFee.fromJson(Map<String, dynamic> json) {
    return LiveCompetitionFee(
      amount: json['amount'] as num?,
      currency: json['currency'] as String?,
      isPaid: json['isPaid'] as bool?,
    );
  }
}

// ─── Registration Window ──────────────────────────────────────────────────────
// Reused for both registration and paymentWindow (same shape)

class LiveCompetitionRegistration {
  final DateTime? start;
  final DateTime? end;

  LiveCompetitionRegistration({this.start, this.end});

  factory LiveCompetitionRegistration.fromJson(Map<String, dynamic> json) {
    return LiveCompetitionRegistration(
      start: json['start'] != null
          ? DateTime.tryParse(json['start'] as String)
          : null,
      end: json['end'] != null
          ? DateTime.tryParse(json['end'] as String)
          : null,
    );
  }
}

// ─── Event Window ─────────────────────────────────────────────────────────────

class LiveCompetitionEventWindow {
  final DateTime? start;
  final DateTime? end;

  LiveCompetitionEventWindow({this.start, this.end});

  factory LiveCompetitionEventWindow.fromJson(Map<String, dynamic> json) {
    return LiveCompetitionEventWindow(
      start: json['start'] != null
          ? DateTime.tryParse(json['start'] as String)
          : null,
      end: json['end'] != null
          ? DateTime.tryParse(json['end'] as String)
          : null,
    );
  }
}

// ─── Submission Config ────────────────────────────────────────────────────────

class LiveCompetitionSubmission {
  final LiveSubmissionText? text;
  final LiveSubmissionFile? file;
  final bool? autoGeneratePdf;
  final String? mode;
  final int? duration;
  final String? type;
  final LiveExternalLink? externalLink; // ← add this

  LiveCompetitionSubmission({
    this.text,
    this.file,
    this.autoGeneratePdf,
    this.mode,
    this.duration,
    this.type,
    this.externalLink, // ← add this
  });

  factory LiveCompetitionSubmission.fromJson(Map<String, dynamic> json) {
    return LiveCompetitionSubmission(
      text: json['text'] != null
          ? LiveSubmissionText.fromJson(json['text'] as Map<String, dynamic>)
          : null,
      file: json['file'] != null
          ? LiveSubmissionFile.fromJson(json['file'] as Map<String, dynamic>)
          : null,
      autoGeneratePdf: json['autoGeneratePdf'] as bool?,
      mode: json['mode'] as String?,
      duration: json['duration'] as int?,
      type: json['type'] as String?,
      externalLink: json['externalLink'] != null          // ← add this
          ? LiveExternalLink.fromJson(
              json['externalLink'] as Map<String, dynamic>)
          : null,
    );
  }
}
class LiveSubmissionText {
  final int? limit;
  final String? limitType;
  final String? topic;
  final int? walletPoints;
  final List<String>? rules;

  LiveSubmissionText({
    this.limit,
    this.limitType,
    this.topic,
    this.walletPoints,
    this.rules,
  });

  factory LiveSubmissionText.fromJson(Map<String, dynamic> json) {
    return LiveSubmissionText(
      limit: json['limit'] as int?,
      limitType: json['limitType'] as String?,
      topic: json['topic'] as String?,
      walletPoints: json['walletPoints'] as int?,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}

class LiveSubmissionFile {
  final List<String>? allowedTypes;
  final int? maxFiles;
  final List<String>? instructions;
  final int? walletPoints;

  LiveSubmissionFile({
    this.allowedTypes,
    this.maxFiles,
    this.instructions,
    this.walletPoints,
  });

  factory LiveSubmissionFile.fromJson(Map<String, dynamic> json) {
    return LiveSubmissionFile(
      allowedTypes: (json['allowedTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      maxFiles: json['maxFiles'] as int?,
      instructions: (json['instructions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      walletPoints: json['walletPoints'] as int?,
    );
  }
}

// ─── Category ────────────────────────────────────────────────────────────────

class LiveCompetitionCategory {
  final String? id;
  final String? name;
  final String? description;
  final String? submissionType;
  final List<String>? allowedFileTypes;

  LiveCompetitionCategory({
    this.id,
    this.name,
    this.description,
    this.submissionType,
    this.allowedFileTypes,
  });

  factory LiveCompetitionCategory.fromJson(Map<String, dynamic> json) {
    return LiveCompetitionCategory(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      submissionType: json['submissionType'] as String?,
      allowedFileTypes: (json['allowedFileTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

// ─── Applied Offer ────────────────────────────────────────────────────────────

class LiveCompetitionOffer {
  final String? id;
  final String? offerName;
  final String? applicableOn;
  final String? discountType;
  final double? discountValue;
  final String? description;
  final DateTime? validTill;

  LiveCompetitionOffer({
    this.id,
    this.offerName,
    this.applicableOn,
    this.discountType,
    this.discountValue,
    this.description,
    this.validTill,
  });

  factory LiveCompetitionOffer.fromJson(Map<String, dynamic> json) {
    return LiveCompetitionOffer(
      id: json['_id'] as String?,
      offerName: json['offerName'] as String?,
      applicableOn: json['applicableOn'] as String?,
      discountType: json['discountType'] as String?,
      discountValue: (json['discountValue'] as num?)?.toDouble(),
      description: json['description'] as String?,
      validTill: json['validTill'] != null
          ? DateTime.tryParse(json['validTill'] as String)
          : null,
    );
  }
}

// ─── Single Live Competition Response ─────────────────────────────────────────

class SingleLiveCompetitionResponse {
  final bool? success;
  final String? message;
  final LiveCompetition? data;

  SingleLiveCompetitionResponse({this.success, this.message, this.data});

  factory SingleLiveCompetitionResponse.fromJson(Map<String, dynamic> json) {
    return SingleLiveCompetitionResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? LiveCompetition.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ─── Initiate Payment Response ────────────────────────────────────────────────

class LivePaymentInitiateResponse {
  final bool? success;
  final String? message;
  final LivePaymentOrder? data;

  LivePaymentInitiateResponse({this.success, this.message, this.data});

  factory LivePaymentInitiateResponse.fromJson(Map<String, dynamic> json) {
    return LivePaymentInitiateResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? LivePaymentOrder.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LivePaymentOrder {
  final bool? completed;
  final String? orderId;
  final int? amount;
  final String? currency;
  final String? key;
  final String? eventTitle;

  LivePaymentOrder({
    this.completed,
    this.orderId,
    this.amount,
    this.currency,
    this.key,
    this.eventTitle,
  });

  factory LivePaymentOrder.fromJson(Map<String, dynamic> json) {
    return LivePaymentOrder(
      completed: json['completed'] as bool?,
      orderId: json['orderId'] as String?,
      amount: json['amount'] as int?,
      currency: json['currency'] as String?,
      key: json['key'] as String?,
      eventTitle: json['eventTitle'] as String?,
    );
  }
}

// ─── Start / Submit Response ──────────────────────────────────────────────────

class LiveCompetitionParticipation {
  final bool? success;
  final String? message;
  final LiveParticipationData? data;

  LiveCompetitionParticipation({this.success, this.message, this.data});

  factory LiveCompetitionParticipation.fromJson(Map<String, dynamic> json) {
    return LiveCompetitionParticipation(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? LiveParticipationData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LiveParticipationData {
  final String? id;
  final String? event;
  final String? participant;
  final bool? attemptLocked;
  final String? paymentStatus;
  final String? evaluationStatus;
  final bool? isWinner;
  final bool? isLate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? startedAt;
  final DateTime? submittedAt;

  LiveParticipationData({
    this.id,
    this.event,
    this.participant,
    this.attemptLocked,
    this.paymentStatus,
    this.evaluationStatus,
    this.isWinner,
    this.isLate,
    this.createdAt,
    this.updatedAt,
    this.startedAt,
    this.submittedAt,
  });

  factory LiveParticipationData.fromJson(Map<String, dynamic> json) {
    return LiveParticipationData(
      id: json['_id'] as String?,
      event: json['event'] as String?,
      participant: json['participant'] as String?,
      attemptLocked: json['attemptLocked'] as bool?,
      paymentStatus: json['paymentStatus'] as String?,
      evaluationStatus: json['evaluationStatus'] as String?,
      isWinner: json['isWinner'] as bool?,
      isLate: json['isLate'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String)
          : null,
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'] as String)
          : null,
    );
  }
}
// ─── Student Status ───────────────────────────────────────────────────────────

class RoundStudentStatus {
  final bool hasRegistered;
  final bool hasSubmitted;
  final bool? isQualified;
  final String? resultStatus;

  RoundStudentStatus({
    required this.hasRegistered,
    required this.hasSubmitted,
    this.isQualified,
    this.resultStatus,
  });

  factory RoundStudentStatus.fromJson(Map<String, dynamic> json) {
    return RoundStudentStatus(
      hasRegistered: json['hasRegistered'] as bool? ?? false,
      hasSubmitted: json['hasSubmitted'] as bool? ?? false,
      isQualified: json['isQualified'] as bool?,
      resultStatus: json['resultStatus'] as String?,
    );
  }
}

class StudentStatus {
  final double? walletBalance;
  final RoundStudentStatus? megaAudition;
  final RoundStudentStatus? grandFinale;

  StudentStatus({this.walletBalance, this.megaAudition, this.grandFinale});

  factory StudentStatus.fromJson(Map<String, dynamic> json) {
    return StudentStatus(
      walletBalance: (json['walletBalance'] as num?)?.toDouble(),
      megaAudition: json['megaAudition'] != null
          ? RoundStudentStatus.fromJson(
              json['megaAudition'] as Map<String, dynamic>,
            )
          : null,
      grandFinale: json['grandFinale'] != null
          ? RoundStudentStatus.fromJson(
              json['grandFinale'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

// ─── Prize ────────────────────────────────────────────────────────────────────

class CompetitionPrize {
  final int? rank;
  final int? walletPoints;
  final String? description;

  CompetitionPrize({this.rank, this.walletPoints, this.description});

  factory CompetitionPrize.fromJson(Map<String, dynamic> json) {
    return CompetitionPrize(
      rank: json['rank'] as int?,
      walletPoints: json['walletPoints'] as int?,
      description: json['description'] as String?,
    );
  }
}
// ─── External Link ────────────────────────────────────────────────────────────

class LiveExternalLink {
  final String? url;
  final String? title;
  final String? platform; // e.g. "ZOOM", "GOOGLE_MEET"

  LiveExternalLink({this.url, this.title, this.platform});

  factory LiveExternalLink.fromJson(Map<String, dynamic> json) {
    return LiveExternalLink(
      url: json['url'] as String?,
      title: json['title'] as String?,
      platform: json['platform'] as String?,
    );
  }
}