enum VehicleSubmissionType { created, pendingReview }

class VehicleSubmissionResult {
  final VehicleSubmissionType submissionType;
  final String message;
  final String? ownershipId;
  final String? requestId;
  final String? requestStatus;

  const VehicleSubmissionResult({
    required this.submissionType,
    required this.message,
    this.ownershipId,
    this.requestId,
    this.requestStatus,
  });

  factory VehicleSubmissionResult.fromJson(Map<String, dynamic> json) {
    final submissionTypeRaw = json['submission_type'] as String? ?? 'created';
    final request = json['request'] as Map<String, dynamic>?;
    final ownership = json['ownership'] as Map<String, dynamic>?;

    return VehicleSubmissionResult(
      submissionType: submissionTypeRaw == 'pending_review'
          ? VehicleSubmissionType.pendingReview
          : VehicleSubmissionType.created,
      message: json['message'] as String? ?? 'Pengajuan kendaraan berhasil diproses.',
      ownershipId: ownership?['id'] as String?,
      requestId: request?['id'] as String?,
      requestStatus: request?['status'] as String?,
    );
  }
}
