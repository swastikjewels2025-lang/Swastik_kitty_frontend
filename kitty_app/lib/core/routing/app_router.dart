import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../features/auth/presentation/screens/auth_success_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_choice_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/phone_screen.dart';
import '../../features/auth/presentation/screens/register_profile_screen.dart';
import '../../features/checkout/domain/entities/payment_order_entity.dart';
import '../../features/calculator/presentation/screens/calculator_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/coin_rates/presentation/screens/coin_rates_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/jewellery/presentation/screens/jewellery_screen.dart';
import '../../features/kyc/presentation/screens/kyc_screen.dart';
import '../../features/live_rates/presentation/screens/live_rates_screen.dart';
import '../../features/menu/presentation/screens/menu_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/offers/presentation/screens/offers_screen.dart';
import '../../features/offers/presentation/screens/booking_screen.dart';
import '../../features/offers/presentation/screens/review_plan_screen.dart';
import '../../features/offers/domain/entities/scheme_entity.dart';
import '../../features/checkout/presentation/screens/cash_pickup_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/passbook/presentation/screens/passbook_screen.dart';
import '../../features/passbook/domain/entities/passbook_entry_entity.dart';
import '../../features/payment_gateway/presentation/screens/gokwik_gateway_screen.dart';
import '../../features/receipt/domain/entities/receipt_entity.dart';
import '../../features/receipt/presentation/screens/receipt_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../shared/screens/not_found_screen.dart';
import '../../shared/widgets/navigation/app_shell_scaffold.dart';
import '../providers/auth_state_provider.dart';
import 'route_names.dart';
import 'route_paths.dart';
import 'route_transitions.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _offersNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'offers');
final GlobalKey<NavigatorState> _dashboardNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final GlobalKey<NavigatorState> _jewelleryNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'jewellery');

/// Provider exposing the configured GoRouter instance with reactive auth guards.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final AuthRouterListenable authListenable = ref.watch(authRouterListenableProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    refreshListenable: authListenable,
    debugLogDiagnostics: false,
    redirect: (BuildContext context, GoRouterState state) {
      final AppAuthState auth = ref.read(appAuthStateProvider);
      final String location = state.uri.path;

      final bool isAuthRoute = location.startsWith('/auth');
      final bool isSplashRoute = location == RoutePaths.splash || location == '/';

      // 1. Splash Screen & Root Entry: Allow luxury animation to complete
      if (isSplashRoute) {
        return null;
      }

      // 2. App Booting: Default to splash while initial state initializes
      if (auth.isInitial) {
        return RoutePaths.splash;
      }

      // 3. Unauthenticated User: Redirect protected routes to login
      if (auth.isUnauthenticated) {
        if (isAuthRoute) {
          return null; // Allow public auth routes
        }
        return RoutePaths.login;
      }

      // 4. Authenticated User: Route according to statutory KYC status
      if (auth.isAuthenticated) {
        if (location == RoutePaths.authSuccess ||
            location == RoutePaths.profile ||
            location == RoutePaths.postKycChoice ||
            (!auth.isOnboarded && location == RoutePaths.login)) {
          return null; // Allow welcome / biometric post-auth step, profile registration, choice screen, or login step 4 profile completion
        }

        // Statutory KYC Guard: If KYC is not completed and user has not chosen to skip for now, redirect to KYC screen
        if (!auth.isKycVerified && !auth.hasSkippedKyc) {
          if (location == RoutePaths.kyc) {
            return null; // Allow KYC screen
          }
          return RoutePaths.kyc; // Enforce KYC verification
        }

        // Verified User: Redirect auth routes to Gold Plans (new landing page)
        if (isAuthRoute) {
          return RoutePaths.offers;
        }

        return null; // Allow protected destinations
      }

      return null;
    },
    routes: <RouteBase>[
      // =======================================================================
      // 1. PUBLIC & AUTHENTICATION STACK ROUTES
      // =======================================================================
      GoRoute(
        path: '/',
        name: AppRoute.splash.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return RouteTransitions.fadeTransitionPage(
            key: state.pageKey,
            child: const SplashScreen(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.splash,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return RouteTransitions.fadeTransitionPage(
            key: state.pageKey,
            child: const SplashScreen(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.login,
        name: AppRoute.login.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return RouteTransitions.fadeTransitionPage(
            key: state.pageKey,
            duration: const Duration(milliseconds: 150),
            child: const LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.phone,
        name: AppRoute.phone.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return RouteTransitions.slideFromRightPage(
            key: state.pageKey,
            child: const PhoneScreen(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.otp,
        name: AppRoute.otp.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return RouteTransitions.slideFromRightPage(
            key: state.pageKey,
            child: const OtpScreen(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: AppRoute.profile.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return RouteTransitions.slideFromRightPage(
            key: state.pageKey,
            child: const RegisterProfileScreen(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.authSuccess,
        name: AppRoute.authSuccess.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final Map<String, dynamic>? extra = state.extra as Map<String, dynamic>?;
          final String planTitle = extra?['planTitle'] as String? ?? 'Gold Kitty Plan';
          final String amount = extra?['amount'] as String? ?? '₹5,000';
          final String nextDueDate = extra?['nextDueDate'] as String? ??
              DateFormat('d MMM yyyy').format(DateTime.now().add(const Duration(days: 30)));

          return RouteTransitions.fadeTransitionPage(
            key: state.pageKey,
            child: AuthSuccessScreen(
              planTitle: planTitle,
              amount: amount,
              nextDueDate: nextDueDate,
            ),
          );
        },
      ),

      // Redirect legacy /home path directly to Gold Plans (/offers)
      GoRoute(
        path: RoutePaths.home,
        redirect: (BuildContext context, GoRouterState state) => RoutePaths.offers,
      ),

      // =======================================================================
      // 2. PROTECTED APPLICATION SHELL (4 CANONICAL TABS)
      //    1. Gold Plans
      //    2. My Plan
      //    3. Live Rate
      //    4. Calculator
      // =======================================================================
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return AppShellScaffold(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          // Branch 0: Gold Plans (Primary Landing Page)
          StatefulShellBranch(
            navigatorKey: _offersNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.offers,
                name: AppRoute.offers.name,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return RouteTransitions.fadeTransitionPage(
                    key: state.pageKey,
                    child: const OffersScreen(),
                  );
                },
              ),
            ],
          ),

          // Branch 1: My Plan (Dashboard)
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.dashboard,
                name: AppRoute.dashboard.name,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return RouteTransitions.fadeTransitionPage(
                    key: state.pageKey,
                    child: const DashboardScreen(),
                  );
                },
              ),
            ],
          ),

          // Branch 2: Jewellery (Showroom fine jewellery web bridge)
          StatefulShellBranch(
            navigatorKey: _jewelleryNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.jewellery,
                name: AppRoute.jewellery.name,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return RouteTransitions.fadeTransitionPage(
                    key: state.pageKey,
                    child: const JewelleryScreen(),
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // =======================================================================
      // 3. PROTECTED TOP-LEVEL STACK & SECONDARY ROUTES
      // =======================================================================
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.liveRates,
        name: AppRoute.liveRates.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return RouteTransitions.fadeTransitionPage(
            key: state.pageKey,
            child: const LiveRatesScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.calculator,
        name: AppRoute.calculator.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return RouteTransitions.fadeTransitionPage(
            key: state.pageKey,
            child: const CalculatorScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.coinRates,
        name: AppRoute.coinRates.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final CoinMetal? initialMetal = state.extra is CoinMetal
              ? state.extra as CoinMetal
              : (state.uri.queryParameters['metal'] == 'silver' ? CoinMetal.silver : null);
          return RouteTransitions.slideFromRightPage(
            key: state.pageKey,
            child: CoinRatesScreen(initialMetal: initialMetal ?? CoinMetal.gold),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.passbook,
        name: AppRoute.passbook.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return RouteTransitions.slideFromRightPage(
            key: state.pageKey,
            child: const PassbookScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.settings,
        name: AppRoute.settings.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return RouteTransitions.slideFromRightPage(
            key: state.pageKey,
            child: const SettingsScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.menu,
        name: AppRoute.menu.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return RouteTransitions.fadeTransitionPage(
            key: state.pageKey,
            child: const MenuScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.orders,
        name: AppRoute.orders.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return RouteTransitions.slideFromRightPage(
            key: state.pageKey,
            child: const OrdersScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.notifications,
        name: AppRoute.notifications.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return RouteTransitions.slideFromRightPage(
            key: state.pageKey,
            child: const NotificationsScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.kyc,
        name: AppRoute.kyc.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return RouteTransitions.slideFromRightPage(
            key: state.pageKey,
            child: const KycScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.postKycChoice,
        name: AppRoute.postKycChoice.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return RouteTransitions.fadeTransitionPage(
            key: state.pageKey,
            child: const OnboardingChoiceScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.checkout,
        name: AppRoute.checkout.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final CheckoutArgs? args = state.extra as CheckoutArgs?;
          return RouteTransitions.slideFromBottomPage(
            key: state.pageKey,
            child: CheckoutScreen(args: args),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.book,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final SchemeEntity? scheme = state.extra as SchemeEntity?;
          return RouteTransitions.slideFromRightPage(
            key: state.pageKey,
            child: BookingScreen(scheme: scheme),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.review,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final Map<String, dynamic>? args = state.extra as Map<String, dynamic>?;
          return RouteTransitions.slideFromRightPage(
            key: state.pageKey,
            child: ReviewPlanScreen(args: args),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.cashPickup,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          int? amount;
          String planTitle = 'Gold Savings Plan';
          String? membershipId;
          int? monthFor;

          if (extra is CheckoutArgs) {
            amount = extra.amount;
            membershipId = extra.membershipId;
            monthFor = extra.monthFor;
          } else if (extra is Map<String, dynamic>) {
            amount = extra['amount'] as int?;
            planTitle = extra['planTitle'] as String? ?? 'Gold Savings Plan';
            membershipId = extra['membershipId'] as String?;
            monthFor = extra['monthFor'] as int?;
          }

          return RouteTransitions.slideFromRightPage(
            key: state.pageKey,
            child: CashPickupScreen(
              amount: amount,
              planTitle: planTitle,
              membershipId: membershipId,
              monthFor: monthFor,
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.receipt,
        name: AppRoute.receipt.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final String receiptId = state.pathParameters['id'] ?? 'REC-UNKNOWN';
          final Object? extra = state.extra;
          final PassbookEntryEntity? passbookEntry =
              extra is PassbookEntryEntity ? extra : null;
          final ReceiptEntity? receipt = extra is ReceiptEntity ? extra : null;

          return RouteTransitions.slideFromBottomPage(
            key: state.pageKey,
            child: ReceiptScreen(
              receiptId: receiptId,
              passbookEntry: passbookEntry,
              receipt: receipt,
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.gokwikGateway,
        name: AppRoute.gokwikGateway.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final PaymentOrderEntity? order = state.extra as PaymentOrderEntity?;
          return RouteTransitions.fadeTransitionPage(
            key: state.pageKey,
            child: GokwikGatewayScreen(order: order),
          );
        },
      ),
    ],
    errorPageBuilder: (BuildContext context, GoRouterState state) {
      return RouteTransitions.fadeTransitionPage(
        key: state.pageKey,
        child: NotFoundScreen(requestedPath: state.uri.path),
      );
    },
  );
});
