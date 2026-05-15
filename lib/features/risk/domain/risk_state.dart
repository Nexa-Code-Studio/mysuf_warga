enum RiskLevel { safe, review, freeze }

class RiskState {
  final int score;
  final String statusLabel;
  final RiskLevel statusLevel;
  final List<String> notes;

  const RiskState({
    required this.score,
    required this.statusLabel,
    required this.statusLevel,
    required this.notes,
  });
}
