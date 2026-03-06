import '../http/http_client.dart';

abstract class BaseRepository {
  final HttpClient client;

  BaseRepository(this.client);
}
