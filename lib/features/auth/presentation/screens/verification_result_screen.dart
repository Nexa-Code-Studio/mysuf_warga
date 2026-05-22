import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/verification_result.dart';
import '../../../../shared/widgets/status_badge.dart';

class VerificationResultScreen extends StatelessWidget {
  final VerificationResult result;

  const VerificationResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = result.status == VerificationStatus.success;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Hasil Verifikasi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.warning_rounded,
              color: isSuccess ? Colors.green : Colors.orange,
              size: 100,
            ),
            const SizedBox(height: 24),
            Text(
              result.message ?? (isSuccess ? 'Verifikasi Berhasil' : 'Perlu Tinjauan'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildResultRow(
                    'Tingkat Kecocokan',
                    '${result.confidenceScore.toStringAsFixed(1)}%',
                    valueColor: isSuccess ? Colors.green : Colors.orange,
                  ),
                  const Divider(height: 32),
                  _buildResultRow(
                    'Risiko Fraud',
                    '',
                    customValue: StatusBadge(
                      text: _getFraudRiskText(result.fraudRisk),
                      backgroundColor: _getFraudRiskColor(result.fraudRisk).withOpacity(0.1),
                      textColor: _getFraudRiskColor(result.fraudRisk),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Return to home or next flow
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31837), // Pertamina Red
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Selesai',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (!isSuccess) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Retry verification
                  context.pushReplacement('/auth/selfie-capture');
                },
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(color: Color(0xFFE31837)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {Color? valueColor, Widget? customValue}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        if (customValue != null)
          customValue
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
          ),
      ],
    );
  }

  String _getFraudRiskText(FraudRisk risk) {
    switch (risk) {
      case FraudRisk.low:
        return 'Rendah (Low Risk)';
      case FraudRisk.medium:
        return 'Sedang (Medium Risk)';
      case FraudRisk.high:
        return 'Tinggi (High Risk)';
    }
  }

  Color _getFraudRiskColor(FraudRisk risk) {
    switch (risk) {
      case FraudRisk.low:
        return Colors.green;
      case FraudRisk.medium:
        return Colors.orange;
      case FraudRisk.high:
        return Colors.red;
    }
  }
}
