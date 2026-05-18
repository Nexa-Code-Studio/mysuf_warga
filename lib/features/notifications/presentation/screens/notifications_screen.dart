import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: const [
            _NotificationTile(
              title: 'Verifikasi subsidi diproses',
              message:
                  'Data Anda sedang diproses. Hasil akan muncul setelah verifikasi selesai.',
              time: 'Hari ini, 09:24',
              isUnread: true,
            ),
            SizedBox(height: 12),
            _NotificationTile(
              title: 'Top up berhasil',
              message: 'Saldo E-KTP bertambah Rp 200.000.',
              time: 'Kemarin, 21:11',
            ),
            SizedBox(height: 12),
            _NotificationTile(
              title: 'Kuota subsidi aktif',
              message: 'Kuota Pertalite bulan ini sudah aktif.',
              time: 'Kemarin, 08:02',
            ),
            SizedBox(height: 12),
            _NotificationTile(
              title: 'Reminder data keluarga',
              message: 'Pastikan data anggota keluarga sesuai KK.',
              time: '17 Mei, 14:30',
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final bool isUnread;

  const _NotificationTile({
    required this.title,
    required this.message,
    required this.time,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = isUnread ? const Color(0xFFFFF1F3) : Colors.white;
    return AppCard(
      color: highlight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: isUnread ? AppColors.primaryRed : AppColors.softGray,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
