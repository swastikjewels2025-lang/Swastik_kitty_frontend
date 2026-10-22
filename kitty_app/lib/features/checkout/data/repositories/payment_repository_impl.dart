import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/payment_order_entity.dart';
import '../../domain/repositories/i_payment_repository.dart';
import '../dtos/payment_dto.dart';
import '../mappers/payment_mapper.dart';

/// Remote implementation of [IPaymentRepository] (Ready for Phase 16 integration).
class PaymentRepositoryImpl implements IPaymentRepository {
  PaymentRepositoryImpl({required DioClient apiClient}) : _dio = apiClient;

  final DioClient _dio;

  @override
  Future<PaymentOrderEntity> initiatePayment({
    required String membershipId,
    required int monthFor,
    int monthsCount = 1,
    PaymentMethodEnum paymentMethod = PaymentMethodEnum.online,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/payments/initiate',
      data: <String, dynamic>{
        'membershipId': membershipId,
        'monthFor': monthFor,
        'monthsCount': monthsCount,
        'paymentMethod': paymentMethod.toJson(),
      },
    );

    final Map<String, dynamic> data =
        response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return PaymentMapper.toOrderEntity(
        PaymentInitiateResponseDto.fromJson(data));
  }

  @override
  Future<PaymentStatusEntity> getPaymentStatus(String orderId) async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/payments/status/$orderId');
    final Map<String, dynamic> data =
        response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return PaymentMapper.toStatusEntity(
        PaymentStatusResponseDto.fromJson(data));
  }
}
