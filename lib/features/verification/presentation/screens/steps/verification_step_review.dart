import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import 'verification_form_widgets.dart';

class VerificationReviewStep extends StatelessWidget {
  final bool agreeData;
  final bool agreeRisk;
  final bool agreeAi;
  final ValueChanged<bool?> onAgreeData;
  final ValueChanged<bool?> onAgreeRisk;
  final ValueChanged<bool?> onAgreeAi;

  const VerificationReviewStep({
    super.key,
    required this.agreeData,
    required this.agreeRisk,
    required this.agreeAi,
    required this.onAgreeData,
    required this.onAgreeRisk,
    required this.onAgreeAi,
  });

  @override
  Widget build(BuildContext context) {
    final showError = !(agreeData && agreeRisk && agreeAi);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Persetujuan'),
        const SizedBox(height: 8),
        AgreementTile(
          value: agreeData,
          label: 'Saya menyatakan seluruh data benar dan valid.',
          onChanged: onAgreeData,
        ),
        AgreementTile(
          value: agreeRisk,
          label: 'Saya siap menerima pembekuan akun jika terdeteksi fraud.',
          onChanged: onAgreeRisk,
        ),
        AgreementTile(
          value: agreeAi,
          label: 'Saya menyetujui verifikasi dan analisis AI atas data saya.',
          onChanged: onAgreeAi,
        ),
        if (showError) ...[
          const SizedBox(height: 8),
          Text(
            'Semua persetujuan wajib dicentang.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}
