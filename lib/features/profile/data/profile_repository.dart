import '../../../core/services/mock_api.dart';
import '../domain/profile_state.dart';

class ProfileRepository {
  final MockApi api;

  ProfileRepository(this.api);

  Future<ProfileState> fetchProfile() async {
    final profile = await api.fetchProfile();
    return ProfileState(profile: profile);
  }
}
