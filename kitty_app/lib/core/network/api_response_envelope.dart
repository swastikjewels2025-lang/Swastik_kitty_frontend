/// Standard API Response Envelope defined in Section 2.1 & 2.2 of API_CONTRACT.md.
class ApiResponseEnvelope<T> {
  const ApiResponseEnvelope({
    required this.success,
    this.message,
    this.data,
    this.meta,
    this.error,
  });

  factory ApiResponseEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    return ApiResponseEnvelope<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      meta: json['meta'] != null
          ? ApiPaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      error: json['error'] != null
          ? ApiErrorDetails.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Whether the operation completed successfully on backend.
  final bool success;

  /// Human-readable server message.
  final String? message;

  /// Generic payload data.
  final T? data;

  /// Optional pagination metadata.
  final ApiPaginationMeta? meta;

  /// Optional error payload on failure.
  final ApiErrorDetails? error;
}

/// Optional pagination metadata attached to paginated endpoints.
class ApiPaginationMeta {
  const ApiPaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.hasNext,
  });

  factory ApiPaginationMeta.fromJson(Map<String, dynamic> json) {
    return ApiPaginationMeta(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      hasNext: json['hasNext'] as bool? ?? false,
    );
  }

  final int page;
  final int limit;
  final int total;
  final bool hasNext;
}

/// Structured error details attached to error envelope.
class ApiErrorDetails {
  const ApiErrorDetails({
    required this.code,
    this.details,
  });

  factory ApiErrorDetails.fromJson(Map<String, dynamic> json) {
    return ApiErrorDetails(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  final String code;
  final Map<String, dynamic>? details;
}
