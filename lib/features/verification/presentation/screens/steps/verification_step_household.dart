import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../../../../shared/widgets/status_pill.dart';
import 'package:flutter/services.dart';
import 'verification_form_state.dart';
import 'verification_form_widgets.dart';

class VerificationHouseholdStep extends StatelessWidget {
  final String householdVehicles;
  final ValueChanged<String?> onHouseholdChanged;
  final bool sharedVehicle;
  final ValueChanged<bool> onSharedChanged;
  final List<FamilyMember> members;
  final VerificationFormControllers controllers;

  const VerificationHouseholdStep({
    super.key,
    required this.householdVehicles,
    required this.onHouseholdChanged,
    required this.sharedVehicle,
    required this.onSharedChanged,
    required this.members,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Kondisi Rumah Tangga'),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              DropdownField(
                label: 'Jumlah kendaraan dalam 1 KK',
                value: householdVehicles,
                items: const ['1-2 Kendaraan', '3-4 Kendaraan', '>4 Kendaraan'],
                onChanged: onHouseholdChanged,
              ),
              const SizedBox(height: 12),
              InputField(
                label: 'Jumlah anggota aktif berkendara',
                hintText: '3',
                controller: controllers.householdActiveCount,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Kendaraan digunakan bersama?'),
                value: sharedVehicle,
                onChanged: onSharedChanged,
              ),
              if (sharedVehicle) ...[
                const SizedBox(height: 8),
                InputField(
                  label: 'Nama',
                  hintText: 'Nama anggota',
                  controller: controllers.sharedName,
                ),
                InputField(
                  label: 'NIK',
                  hintText: '16 digit NIK',
                  controller: controllers.sharedNik,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                InputField(
                  label: 'Relasi keluarga',
                  hintText: 'Istri/Anak/Ayah',
                  controller: controllers.sharedRelation,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionTitle('Anggota Keluarga'),
        const SizedBox(height: 8),
        ...members.map(
          (member) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFFFF1F3),
                    child: Text(
                      member.name.substring(0, 1),
                      style: const TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w700,
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
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          member.relation,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  StatusPill(
                    label: member.isRegistered
                        ? 'Sudah registrasi KTP'
                        : 'Belum registrasi KTP',
                    color: member.isRegistered
                        ? AppColors.success
                        : AppColors.warning,
                    backgroundColor: member.isRegistered
                        ? const Color(0xFFE9F9EF)
                        : const Color(0xFFFFF5E5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FamilyMember {
  final String name;
  final String relation;
  final bool isRegistered;

  const FamilyMember(this.name, this.relation, this.isRegistered);
}
