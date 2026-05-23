enum RegistrationAttemptStatus {
  pending,
  processing,
  failed,
  verified,
  completed,
  reviewRequired,
  unknown,
}

class RegistrationAttempt {
  final String id;
  final RegistrationAttemptStatus status;
  final String? nikOcr;
  final bool? isNikMatch;
  final double? faceMatchScore;
  final bool? isFaceMatch;
  final String? failureReason;
  final String? failureDetail;
  final String? createdUserId;
  final String? createdBuyerProfileId;

  const RegistrationAttempt({
    required this.id,
    required this.status,
    this.nikOcr,
    this.isNikMatch,
    this.faceMatchScore,
    this.isFaceMatch,
    this.failureReason,
    this.failureDetail,
    this.createdUserId,
    this.createdBuyerProfileId,
  });

  bool get isTerminal =>
      status == RegistrationAttemptStatus.failed ||
      status == RegistrationAttemptStatus.completed;

  bool get isProcessing =>
      status == RegistrationAttemptStatus.pending ||
      status == RegistrationAttemptStatus.processing ||
      status == RegistrationAttemptStatus.verified ||
      status == RegistrationAttemptStatus.reviewRequired;

  factory RegistrationAttempt.fromJson(Map<String, dynamic> json) {
    return RegistrationAttempt(
      id: json['id'] as String,
      status: _parseStatus(json['status'] as String?),
      nikOcr: json['nik_ocr'] as String?,
      isNikMatch: json['is_nik_match'] as bool?,
      faceMatchScore: _toDouble(json['face_match_score']),
      isFaceMatch: json['is_face_match'] as bool?,
      failureReason: json['failure_reason'] as String?,
      failureDetail: json['failure_detail'] as String?,
      createdUserId: json['created_user_id'] as String?,
      createdBuyerProfileId: json['created_buyer_profile_id'] as String?,
    );
  }

  static RegistrationAttemptStatus _parseStatus(String? value) {
    switch (value) {
      case 'PENDING':
        return RegistrationAttemptStatus.pending;
      case 'PROCESSING':
        return RegistrationAttemptStatus.processing;
      case 'FAILED':
        return RegistrationAttemptStatus.failed;
      case 'VERIFIED':
        return RegistrationAttemptStatus.verified;
      case 'COMPLETED':
        return RegistrationAttemptStatus.completed;
      case 'REVIEW_REQUIRED':
        return RegistrationAttemptStatus.reviewRequired;
      default:
        return RegistrationAttemptStatus.unknown;
    }
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }
}
