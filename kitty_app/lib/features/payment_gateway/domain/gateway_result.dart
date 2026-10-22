/// Result types returned when payment gateway UI finishes or dismisses.
enum GatewayResultType {
  /// Payment completed by user in gateway interface.
  completed,

  /// Payment cancelled or dismissed by user.
  cancelled,

  /// Gateway reported an immediate processing/bank failure.
  failed,

  /// Gateway closed while transaction remains in pending state.
  pending,
}

/// Domain entity representing the result of gateway UI execution.
class GatewayResult {
  const GatewayResult({
    required this.type,
    this.message,
    this.rawResponse,
  });

  const GatewayResult.completed({this.message, this.rawResponse})
      : type = GatewayResultType.completed;

  const GatewayResult.cancelled({this.message, this.rawResponse})
      : type = GatewayResultType.cancelled;

  const GatewayResult.failed({this.message, this.rawResponse})
      : type = GatewayResultType.failed;

  const GatewayResult.pending({this.message, this.rawResponse})
      : type = GatewayResultType.pending;

  final GatewayResultType type;
  final String? message;
  final Map<String, dynamic>? rawResponse;

  bool get isCompleted => type == GatewayResultType.completed;
  bool get isCancelled => type == GatewayResultType.cancelled;
  bool get isFailed => type == GatewayResultType.failed;
  bool get isPending => type == GatewayResultType.pending;
}
