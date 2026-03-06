class ApiEndpoints {
  static const String login = '/auth/login';
  static const String me = '/me';

  static const String polls = '/polls';
  static String pollById(String id) => '/polls/$id';
  static String vote(String pollId) => '/polls/$pollId/vote';
  static String pollResults(String pollId) => '/polls/$pollId/results';

  static const String comments = '/comments';
  static const String news = '/news';
  static const String posts = '/posts';
  static const String videos = '/videos';
}
