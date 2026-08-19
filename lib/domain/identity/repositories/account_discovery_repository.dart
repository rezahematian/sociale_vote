import 'package:sociale_vote/domain/identity/entities/account_discovery_item.dart';

abstract class AccountDiscoveryRepository {
  Future<List<AccountDiscoveryItem>> searchAccounts({
    required String query,
    int limit = 20,
    int offset = 0,
  });
}
