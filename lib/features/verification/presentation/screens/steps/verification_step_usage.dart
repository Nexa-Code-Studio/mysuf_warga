import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_card.dart';
import 'verification_form_widgets.dart';

class VerificationUsageStep extends StatelessWidget {
  final String usageType;
  final ValueChanged<String?> onUsageTypeChanged;
  final String? productiveBusinessDocName;
  final VoidCallback onProductiveBusinessCamera;
  final VoidCallback onProductiveBusinessPick;

  const VerificationUsageStep({
    super.key,
    required this.usageType,
    required this.onUsageTypeChanged,
    required this.productiveBusinessDocName,
    required this.onProductiveBusinessCamera,
    required this.onProductiveBusinessPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Tujuan Penggunaan'),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              DropdownField(
                label: 'Tujuan Penggunaan',
                value: usageType,
                items: const ['PERSONAL', 'OJOL', 'UMKM'],
                onChanged: onUsageTypeChanged,
              ),
            ],
          ),
        ),
        if (usageType == 'OJOL' || usageType == 'UMKM') ...[
          const SizedBox(height: 16),
          const SectionTitle('Bukti Usaha Produktif'),
          const SizedBox(height: 12),
          UploadTile(
            title: 'Bukti Usaha Produktif',
            subtitle: 'Lampiran bukti usaha dan aktivitas kerja.',
            fileName: productiveBusinessDocName,
            onCamera: onProductiveBusinessCamera,
            onPick: onProductiveBusinessPick,
          ),
        ],
      ],
    );
  }
}
