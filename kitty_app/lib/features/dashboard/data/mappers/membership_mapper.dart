import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/membership_entity.dart';
import '../dtos/membership_dto.dart';

/// Mapper between Membership DTO and Domain Entity.
abstract final class MembershipMapper {
  static MembershipEntity toEntity(MembershipDto dto) {
    final String fallbackToken =
        '#SW-${dto.tokenNumber.toString().padLeft(3, '0')}';

    return MembershipEntity(
      id: dto.id,
      userId: dto.userId,
      schemeId: dto.schemeId,
      schemeName: dto.schemeName,
      tokenNumber: dto.tokenNumber,
      tokenString: dto.tokenString ?? fallbackToken,
      customMonthlyEmi: dto.customMonthlyEmi,
      targetAmount: dto.targetAmount,
      totalPaidAmount: dto.totalPaidAmount,
      status: MembershipStatusEnum.fromString(dto.status),
      joinedAtMonth: dto.joinedAtMonth,
      winMonth: dto.winMonth,
    );
  }
}
