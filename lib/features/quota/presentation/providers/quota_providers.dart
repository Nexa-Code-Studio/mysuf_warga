import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/quota_api_repository.dart';
import '../../domain/buyer_quota.dart';

final quotaApiRepositoryProvider = Provider<QuotaApiRepository>((ref) {
  return QuotaApiRepository();
});

final quotaDetailProvider = FutureProvider<BuyerQuotaResponse>((ref) async {
  final repository = ref.read(quotaApiRepositoryProvider);
  return repository.fetchQuotaDetail();
});
