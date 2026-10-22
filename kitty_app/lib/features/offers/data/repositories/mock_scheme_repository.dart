import '../../../../core/enums/app_enums.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/mock/mock_engine_config.dart';
import '../../../../core/mock/mock_fixtures.dart';
import '../../domain/entities/kitty_slot_entity.dart';
import '../../domain/entities/scheme_entity.dart';
import '../../domain/repositories/i_scheme_repository.dart';
import '../dtos/scheme_dto.dart';
import '../mappers/scheme_mapper.dart';

/// Mock implementation of [ISchemeRepository].
class MockSchemeRepository implements ISchemeRepository {
  MockSchemeRepository({MockEngineConfig? engineConfig})
      : _engineConfig = engineConfig ?? MockEngineConfig.instance;

  final MockEngineConfig _engineConfig;
  bool _shouldThrow = false;
  List<SchemeEntity>? _customSchemes;

  // Scenario controls for testing
  void setShouldThrow(bool shouldThrow) => _shouldThrow = shouldThrow;
  void setCustomSchemes(List<SchemeEntity>? schemes) => _customSchemes = schemes;

  /// Prototype schemes matching offers.html design for dedicated preview
  static const List<SchemeEntity> prototypeSchemes = <SchemeEntity>[
    SchemeEntity(
      id: 'sch_12month_wedding',
      name: 'Wedding Collection',
      targetAmount: 360000,
      durationMonths: 12,
      monthlyInstallment: 30000,
      maxCapacity: 100,
      currentMembers: 64,
      status: SchemeStatusEnum.open,
      benefits: <String>[
        '1 Month Free: 11 Paid + 12th Month 100% Jeweler Sponsored Bonus',
        '25% Flat Discount on Jewellery Making Charges upon maturity',
        'Accumulate 24K 999 Hallmark Purity gold every month',
      ],
      isPopular: true,
      bannerImageUrl: 'assets/images/kitty_banner_royal_gold.jpg',
    ),
    SchemeEntity(
      id: 'sch_12month_suvarna',
      name: 'Suvarna Varsha',
      targetAmount: 60000,
      durationMonths: 12,
      monthlyInstallment: 5000,
      maxCapacity: 100,
      currentMembers: 42,
      status: SchemeStatusEnum.open,
      benefits: <String>[
        'Classic Gold Scheme: 1 Month Free Bonus on Month 12',
        'Guaranteed conversion at lowest daily market price',
        'Flexible redemption for 24K gold bullion or hallmarked ornaments',
      ],
      isPopular: false,
      bannerImageUrl: 'assets/images/kitty_banner_gold_coins.jpg',
    ),
    SchemeEntity(
      id: 'sch_18month_bridal',
      name: 'Navratna Bridal Royal',
      targetAmount: 900000,
      durationMonths: 18,
      monthlyInstallment: 50000,
      maxCapacity: 50,
      currentMembers: 22,
      status: SchemeStatusEnum.open,
      benefits: <String>[
        '2 Months Free: 16 Paid + 2 Months Sponsored + ₹25,000 Diamond Gift',
        'Dedicated personal Swastik Jewellery Concierge service',
        'Priority access to new heritage, bridal polki & uncut diamond collections',
      ],
      isPopular: false,
      bannerImageUrl: 'assets/images/kitty_banner_royal_gold.jpg',
    ),
    SchemeEntity(
      id: 'sch_6month_express',
      name: 'Dhanteras Labh Express',
      targetAmount: 60000,
      durationMonths: 6,
      monthlyInstallment: 10000,
      maxCapacity: 50,
      currentMembers: 31,
      status: SchemeStatusEnum.open,
      benefits: <String>[
        'Express Gold Scheme: 50% Sponsored Bonus on Month 6',
        'Fast-track festival accumulation for Diwali & Dhanteras celebrations',
        'Instant hallmarked coin or ornament redemption',
      ],
      isPopular: false,
      bannerImageUrl: 'assets/images/kitty_banner_diamond_solitaire.jpg',
    ),
  ];

  @override
  Future<List<SchemeEntity>> getActiveSchemes({int? durationFilter}) async {
    await _engineConfig.simulate();

    if (_shouldThrow) {
      throw const NetworkException('Failed to load active gold schemes.');
    }

    final List<SchemeEntity> schemes;
    if (_customSchemes != null) {
      schemes = _customSchemes!;
    } else {
      final List<dynamic> rawList =
          MockFixtures.activeSchemesJson['data']['schemes'] as List<dynamic>;

      schemes = rawList
          .map((dynamic json) =>
              SchemeMapper.toEntity(SchemeDto.fromJson(json as Map<String, dynamic>)))
          .toList();
    }

    if (durationFilter != null) {
      return schemes
          .where((SchemeEntity s) => s.durationMonths == durationFilter)
          .toList();
    }

    return schemes;
  }

  @override
  Future<SchemeEntity> getSchemeById(String id) async {
    await _engineConfig.simulate();

    if (_shouldThrow) {
      throw const NetworkException('Failed to load scheme details.');
    }

    final List<SchemeEntity> schemes = await getActiveSchemes();
    return schemes.firstWhere(
      (SchemeEntity s) => s.id == id,
      orElse: () => throw const NotFoundException(
        'Scheme not found with the requested ID.',
      ),
    );
  }

  List<KittySlotEntity>? _customSlots;
  void setCustomSlots(List<KittySlotEntity>? slots) => _customSlots = slots;

  @override
  Future<List<KittySlotEntity>> getAvailableNumbers(
    String schemeId, {
    int totalCapacity = 50,
  }) async {
    await _engineConfig.simulate();

    if (_shouldThrow) {
      throw const NetworkException('Failed to load Kitty numbers.');
    }

    if (_customSlots != null) {
      return _customSlots!;
    }

    // Deterministic realistic slot matrix (1 to 50)
    // Booked slots: 2, 5, 8, 13, 17, 21, 28, 33, 42, 49
    // Locked slot: 7 (held in active checkout)
    const Set<int> bookedNumbers = <int>{2, 5, 8, 13, 17, 21, 28, 33, 42, 49};
    const Set<int> lockedNumbers = <int>{7};

    return List<KittySlotEntity>.generate(totalCapacity, (int index) {
      final int number = index + 1;
      final String token = '#SW-${number.toString().padLeft(3, '0')}';

      if (bookedNumbers.contains(number)) {
        return KittySlotEntity(
          number: number,
          status: KittySlotStatus.booked,
          tokenString: token,
        );
      } else if (lockedNumbers.contains(number)) {
        return KittySlotEntity(
          number: number,
          status: KittySlotStatus.locked,
          tokenString: token,
          lockedUntil: DateTime.now().add(const Duration(minutes: 12)),
        );
      } else {
        return KittySlotEntity(
          number: number,
          status: KittySlotStatus.available,
          tokenString: token,
        );
      }
    });
  }

  @override
  Future<Map<String, dynamic>> enrollScheme({
    required String schemeId,
    required int monthlyAmount,
    required int slotNumber,
  }) async {
    await _engineConfig.simulate();

    final String token = '#SW-${slotNumber.toString().padLeft(3, '0')}';
    final String membershipId =
        'MEM-2026-${slotNumber.toString().padLeft(3, '0')}';

    return <String, dynamic>{
      'success': true,
      'membershipId': membershipId,
      'schemeId': schemeId,
      'monthlyAmount': monthlyAmount,
      'slotNumber': slotNumber,
      'tokenString': token,
      'status': 'ENROLLED',
      'message': 'Successfully enrolled in Kitty Scheme with Number $slotNumber',
    };
  }
}
