import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/family_member.dart';
import '../../../../shared/providers/mock_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';

class FamilyListScreen extends ConsumerWidget {
  const FamilyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(familyProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggota Keluarga'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primaryRed),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Maksimal 2 kendaraan per KK. Kuota dihitung berdasarkan kendaraan terdaftar.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            family.when(
              data: (members) {
                if (members.isEmpty) {
                  return const EmptyState(
                    title: 'Belum ada anggota',
                    message: 'Tambahkan anggota keluarga untuk akses bersama.',
                    icon: Icons.group_outlined,
                  );
                }
                return Column(
                  children: members
                      .map((member) => _FamilyTile(member: member))
                      .toList(),
                );
              },
              loading: () => const LoadingSkeleton(height: 150),
              error: (_, __) => ErrorState(
                title: 'Gagal memuat keluarga',
                message: 'Tarik untuk memuat ulang daftar keluarga.',
                onRetry: () => ref.invalidate(familyProvider),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Tambah Anggota Keluarga'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyTile extends StatelessWidget {
  final FamilyMember member;

  const _FamilyTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFFFF1F3),
              child: Text(
                member.name.substring(0, 1),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryRed,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${member.role} - ${member.nikMasked}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: member.isEligible
                    ? const Color(0xFFE9F9EF)
                    : const Color(0xFFFFF5E5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                member.isEligible ? 'Eligible' : 'Review',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: member.isEligible
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
