import '../../../core/services/mock_api.dart';
import '../domain/family_state.dart';

class FamilyRepository {
  final MockApi api;

  FamilyRepository(this.api);

  Future<FamilyState> fetchFamily() async {
    final members = await api.fetchFamilyMembers();
    return FamilyState(members: members);
  }
}
