enum VerificationStatus {
  success,
  reviewRequired,
  failed,
}

enum FraudRisk {
  low,
  medium,
  high,
}

class VerificationResult {
  final VerificationStatus status;
  final double confidenceScore;
  final FraudRisk fraudRisk;
  final String? message;

  VerificationResult({
    required this.status,
    required this.confidenceScore,
    required this.fraudRisk,
    this.message,
  });
}
