import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _trxPush = true;
  bool _trxEmail = false;
  bool _quotaReminder = true;
  bool _verificationUpdate = true;
  bool _promo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Notifikasi')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaksi',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Notifikasi transaksi masuk'),
                    subtitle: const Text('Push untuk top up dan pembelian BBM.'),
                    value: _trxPush,
                    onChanged: (value) => setState(() => _trxPush = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ringkasan transaksi via email'),
                    subtitle: const Text('Dikirim mingguan ke email Anda.'),
                    value: _trxEmail,
                    onChanged: (value) => setState(() => _trxEmail = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kuota & Verifikasi',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Pengingat kuota hampir habis'),
                    subtitle: const Text('Peringatan saat kuota tersisa < 20%.'),
                    value: _quotaReminder,
                    onChanged: (value) => setState(() => _quotaReminder = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Update verifikasi'),
                    subtitle:
                        const Text('Status verifikasi dan dokumen tambahan.'),
                    value: _verificationUpdate,
                    onChanged: (value) =>
                        setState(() => _verificationUpdate = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Info & Promo',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Info promo dan tips'),
                    subtitle: const Text('Rekomendasi dan info terbaru.'),
                    value: _promo,
                    onChanged: (value) => setState(() => _promo = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.softGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primaryRed),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Anda dapat mengubah pengaturan kapan saja.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
