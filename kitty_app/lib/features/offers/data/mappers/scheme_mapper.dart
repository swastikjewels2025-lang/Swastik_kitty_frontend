import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/scheme_entity.dart';
import '../dtos/scheme_dto.dart';

/// Mapper between Scheme DTO and Domain Entity.
abstract final class SchemeMapper {
  static SchemeEntity toEntity(SchemeDto dto) {
    return SchemeEntity(
      id: dto.id,
      name: dto.name,
      targetAmount: dto.targetAmount,
      durationMonths: dto.durationMonths,
      monthlyInstallment: dto.monthlyInstallment,
      maxCapacity: dto.maxCapacity,
      currentMembers: dto.currentMembers,
      status: SchemeStatusEnum.fromString(dto.status),
      benefits: dto.benefits,
      bannerImageUrl: dto.bannerImageUrl,
      isPopular: dto.isPopular,
    );
  }
}
