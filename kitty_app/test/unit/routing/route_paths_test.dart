import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/routing/route_names.dart';
import 'package:kitty_app/core/routing/route_paths.dart';

void main() {
  group('RoutePaths & AppRoute Constants Test Suite', () {
    test('RoutePaths match canonical specifications', () {
      expect(RoutePaths.splash, equals('/splash'));
      expect(RoutePaths.login, equals('/auth/login'));
      expect(RoutePaths.phone, equals('/auth/phone'));
      expect(RoutePaths.otp, equals('/auth/otp'));
      expect(RoutePaths.authSuccess, equals('/auth/success'));
      expect(RoutePaths.home, equals('/home'));
      expect(RoutePaths.coinRates, equals('/coin-rates'));
      expect(RoutePaths.jewellery, equals('/jewellery'));
      expect(RoutePaths.menu, equals('/menu'));
      expect(RoutePaths.dashboard, equals('/dashboard'));
      expect(RoutePaths.passbook, equals('/passbook'));
      expect(RoutePaths.offers, equals('/offers'));
      expect(RoutePaths.settings, equals('/settings'));
      expect(RoutePaths.notifications, equals('/notifications'));
      expect(RoutePaths.kyc, equals('/kyc'));
      expect(RoutePaths.checkout, equals('/checkout'));
      expect(RoutePaths.receipt, equals('/receipt/:id'));
      expect(RoutePaths.gokwikGateway, equals('/gokwik-gateway'));
    });

    test('receiptWithId generates correct parameterized URI', () {
      expect(RoutePaths.receiptWithId('REC-10821'), equals('/receipt/REC-10821'));
      expect(RoutePaths.receiptWithId('REC-9944'), equals('/receipt/REC-9944'));
    });

    test('AppRoute enum has valid name identifiers', () {
      expect(AppRoute.splash.name, equals('splash'));
      expect(AppRoute.login.name, equals('login'));
      expect(AppRoute.home.name, equals('home'));
      expect(AppRoute.coinRates.name, equals('coinRates'));
      expect(AppRoute.jewellery.name, equals('jewellery'));
      expect(AppRoute.menu.name, equals('menu'));
      expect(AppRoute.dashboard.name, equals('dashboard'));
      expect(AppRoute.passbook.name, equals('passbook'));
      expect(AppRoute.offers.name, equals('offers'));
      expect(AppRoute.settings.name, equals('settings'));
      expect(AppRoute.notFound.name, equals('notFound'));
    });
  });
}
