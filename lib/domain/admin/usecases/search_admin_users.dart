import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';

class SearchAdminUsers {
  static const int maximumQueryLength = 320;
  static const int maximumPage = 100000;
  static const int maximumPerPage = 50;

  final AdminRepository _repository;

  const SearchAdminUsers(this._repository);

  Future<AdminUserSearchPage> call({
    String? query,
    int page = 1,
    int perPage = 25,
  }) {
    if (page < 1 || page > maximumPage) {
      throw RangeError.range(
        page,
        1,
        maximumPage,
        'page',
      );
    }

    if (perPage < 1 || perPage > maximumPerPage) {
      throw RangeError.range(
        perPage,
        1,
        maximumPerPage,
        'perPage',
      );
    }

    final normalizedQuery = query?.trim();

    if (normalizedQuery != null &&
        normalizedQuery.length > maximumQueryLength) {
      throw ArgumentError.value(
        query,
        'query',
        'La ricerca non può superare $maximumQueryLength caratteri.',
      );
    }

    return _repository.searchUsers(
      query: normalizedQuery == null || normalizedQuery.isEmpty
          ? null
          : normalizedQuery,
      page: page,
      perPage: perPage,
    );
  }
}
