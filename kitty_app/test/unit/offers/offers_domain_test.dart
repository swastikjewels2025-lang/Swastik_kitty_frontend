import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/errors/app_exception.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/features/home/data/repositories/mock_product_repository.dart';
import 'package:kitty_app/features/home/domain/entities/product_entity.dart';
import 'package:kitty_app/features/offers/data/dtos/offer_dto.dart';
import 'package:kitty_app/features/offers/data/dtos/scheme_dto.dart';
import 'package:kitty_app/features/offers/data/mappers/offer_mapper.dart';
import 'package:kitty_app/features/offers/data/mappers/scheme_mapper.dart';
import 'package:kitty_app/features/offers/data/repositories/mock_scheme_repository.dart';
import 'package:kitty_app/features/offers/domain/entities/offer_entity.dart';
import 'package:kitty_app/features/offers/domain/entities/scheme_entity.dart';

void main() {
  group('Offers & Schemes Domain & Data Layer Unit Tests', () {
    final MockEngineConfig instantConfig =
        MockEngineConfig(latency: MockLatency.instant);

    test('1. SchemeDto fromJson & toJson preserves all fields and whole rupees', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'sch_12month_wedding',
        'name': 'Wedding Collection',
        'targetAmount': 360000,
        'durationMonths': 12,
        'monthlyInstallment': 30000,
        'maxCapacity': 100,
        'currentMembers': 64,
        'status': 'OPEN',
        'benefits': <String>['1 Month Free Bonus'],
        'bannerImageUrl': 'assets/images/banner_clean_bonus.jpg',
        'isPopular': true,
      };

      final SchemeDto dto = SchemeDto.fromJson(json);
      expect(dto.id, 'sch_12month_wedding');
      expect(dto.name, 'Wedding Collection');
      expect(dto.targetAmount, 360000);
      expect(dto.durationMonths, 12);
      expect(dto.monthlyInstallment, 30000); // Whole integer rupees
      expect(dto.status, 'OPEN');
      expect(dto.isPopular, isTrue);

      final Map<String, dynamic> serialized = dto.toJson();
      expect(serialized['id'], 'sch_12month_wedding');
      expect(serialized['monthlyInstallment'], 30000);
      expect(serialized['targetAmount'], 360000);
    });

    test('2. SchemeMapper maps SchemeDto accurately to SchemeEntity with slot math', () {
      const SchemeDto dto = SchemeDto(
        id: 'sch_12month_test',
        name: 'Suvarna Varsha Test',
        targetAmount: 60000,
        durationMonths: 12,
        monthlyInstallment: 5000,
        maxCapacity: 100,
        currentMembers: 80,
        status: 'OPEN',
        benefits: <String>['Perk 1', 'Perk 2'],
        isPopular: false,
      );

      final SchemeEntity entity = SchemeMapper.toEntity(dto);
      expect(entity.id, 'sch_12month_test');
      expect(entity.status, SchemeStatusEnum.open);
      expect(entity.isFull, isFalse);
      expect(entity.slotsRemaining, 20);
    });

    test('3. OfferDto and OfferMapper preserve promotional details', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'off_test_01',
        'title': 'Diwali Gift Voucher',
        'description': 'Flat waiver on diamond making charges.',
        'code': 'DIWALI25',
        'discountPct': 25.0,
      };

      final OfferDto dto = OfferDto.fromJson(json);
      expect(dto.id, 'off_test_01');
      expect(dto.code, 'DIWALI25');
      expect(dto.discountPct, 25.0);

      final OfferEntity entity = OfferMapper.toEntity(dto);
      expect(entity.title, 'Diwali Gift Voucher');
      expect(entity.code, 'DIWALI25');
    });

    test('4. ProductEntity strictly maintains whole integer rupees and 3-decimal weight', () {
      const ProductEntity product = ProductEntity(
        id: 'prod_necklace_01',
        title: 'Royal Mayura Gold Choker',
        category: 'Gold Necklaces',
        purity: '22K Hallmarked',
        weightGrams: 28.450,
        estimatedPrice: 218500, // Whole integer rupees
        makingDiscountPct: 25.0,
        imageUrl: 'assets/images/cat_necklace.jpg',
        isNew: true,
      );

      expect(product.estimatedPrice, isA<int>());
      expect(product.estimatedPrice, 218500);
      expect(product.weightGrams, 28.450);
      expect(product.isNew, isTrue);
    });

    test('5. MockSchemeRepository retrieves schemes, filters by duration, and handles error controls', () async {
      final MockSchemeRepository repository =
          MockSchemeRepository(engineConfig: instantConfig);

      // Default active schemes
      final List<SchemeEntity> allSchemes = await repository.getActiveSchemes();
      expect(allSchemes, isNotEmpty);

      // Filter by 12 months
      final List<SchemeEntity> schemes12 =
          await repository.getActiveSchemes(durationFilter: 12);
      for (final SchemeEntity s in schemes12) {
        expect(s.durationMonths, 12);
      }

      // Lookup by ID
      final SchemeEntity found =
          await repository.getSchemeById('sch_12month_suvarna');
      expect(found.id, 'sch_12month_suvarna');

      // Error control
      repository.setShouldThrow(true);
      await expectLater(
        repository.getActiveSchemes(),
        throwsA(isA<AppException>()),
      );

      // Reset and custom schemes
      repository.setShouldThrow(false);
      repository.setCustomSchemes(MockSchemeRepository.prototypeSchemes);
      final List<SchemeEntity> prototypeList = await repository.getActiveSchemes();
      expect(prototypeList.length, 4);
      expect(prototypeList.first.name, 'Wedding Collection');
    });

    test('6. MockProductRepository retrieves products, categories, getProductById, and handles error controls', () async {
      final MockProductRepository repository =
          MockProductRepository(engineConfig: instantConfig);

      final List<ProductEntity> products = await repository.getCuratedProducts();
      expect(products, isNotEmpty);

      final List<String> categories = await repository.getCategories();
      expect(categories, isNotEmpty);

      final ProductEntity product = await repository.getProductById(products.first.id);
      expect(product.id, products.first.id);

      // Filter by category
      final List<ProductEntity> rings =
          await repository.getCuratedProducts(category: 'Diamond Rings');
      for (final ProductEntity p in rings) {
        expect(p.category.toLowerCase(), 'diamond rings');
      }

      // Error control
      repository.setShouldThrow(true);
      await expectLater(
        repository.getCuratedProducts(),
        throwsA(isA<AppException>()),
      );
    });
  });
}
