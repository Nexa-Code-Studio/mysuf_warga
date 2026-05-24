import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/family_member.dart';
import 'family_api_repository.dart';

final familyApiRepositoryProvider = Provider<FamilyApiRepository>((ref) {
  return FamilyApiRepository();
});

final familyOverviewProvider = FutureProvider<FamilyOverview>((ref) async {
  return ref.read(familyApiRepositoryProvider).fetchMyFamilyOverview();
});
