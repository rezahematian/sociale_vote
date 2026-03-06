class RateLimitRule {
  final int maxActions;
  final Duration window;

  const RateLimitRule({
    required this.maxActions,
    required this.window,
  });
}
