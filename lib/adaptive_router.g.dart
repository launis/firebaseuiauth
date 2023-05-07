// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adaptive_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $rootPageRoute,
    ];

RouteBase get $rootPageRoute => ShellRouteData.$route(
      factory: $RootPageRouteExtension._fromState,
      navigatorKey: RootPageRoute.$navigatorKey,
      routes: [
        GoRouteData.$route(
          path: '/signIn',
          factory: $SignInPageRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/profile',
          factory: $ProfilePageRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/error',
          factory: $ErrorPageRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/forgot-password/:email',
          factory: $ForgotPasswordPageRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/verify-email',
          factory: $VerifyEmailPageRouteExtension._fromState,
        ),
      ],
    );

extension $RootPageRouteExtension on RootPageRoute {
  static RootPageRoute _fromState(GoRouterState state) => const RootPageRoute();
}

extension $SignInPageRouteExtension on SignInPageRoute {
  static SignInPageRoute _fromState(GoRouterState state) =>
      const SignInPageRoute();

  String get location => GoRouteData.$location(
        '/signIn',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);
}

extension $ProfilePageRouteExtension on ProfilePageRoute {
  static ProfilePageRoute _fromState(GoRouterState state) =>
      const ProfilePageRoute();

  String get location => GoRouteData.$location(
        '/profile',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);
}

extension $ErrorPageRouteExtension on ErrorPageRoute {
  static ErrorPageRoute _fromState(GoRouterState state) =>
      const ErrorPageRoute();

  String get location => GoRouteData.$location(
        '/error',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);
}

extension $ForgotPasswordPageRouteExtension on ForgotPasswordPageRoute {
  static ForgotPasswordPageRoute _fromState(GoRouterState state) =>
      ForgotPasswordPageRoute(
        email: state.pathParameters['email']!,
      );

  String get location => GoRouteData.$location(
        '/forgot-password/${Uri.encodeComponent(email)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);
}

extension $VerifyEmailPageRouteExtension on VerifyEmailPageRoute {
  static VerifyEmailPageRoute _fromState(GoRouterState state) =>
      const VerifyEmailPageRoute();

  String get location => GoRouteData.$location(
        '/verify-email',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$goRouteHash() => r'2aaf27a0e11b5b6c54367d2fa45074deb85cdac7';

/// See also [goRoute].
@ProviderFor(goRoute)
final goRouteProvider = AutoDisposeProvider<GoRouter>.internal(
  goRoute,
  name: r'goRouteProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$goRouteHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GoRouteRef = AutoDisposeProviderRef<GoRouter>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
