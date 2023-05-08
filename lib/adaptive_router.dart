import 'dart:async';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

part 'adaptive_router.g.dart';

final rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: '_rootNavigatorKey');

final shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: '_shellNavigatorKey');

@riverpod
GoRouter goRoute(GoRouteRef ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: $appRoutes,
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(),
      body: const Text('404 - Page not found!'),
    ),
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (!state.matchedLocation.startsWith('/forgot-password')) {
        if (currentUser == null) {
          return SignInPageRoute.path;
        }

        if (!currentUser.emailVerified && currentUser.email != null) {
          return VerifyEmailPageRoute.path;
        }
      }
      return null;
    },
  );
}

@TypedShellRoute<RootPageRoute>(
  routes: [
    TypedGoRoute<SignInPageRoute>(
      path: SignInPageRoute.path,
    ),
    TypedGoRoute<ProfilePageRoute>(
      path: ProfilePageRoute.path,
    ),
    TypedGoRoute<ErrorPageRoute>(
      path: ErrorPageRoute.path,
    ),
    TypedGoRoute<ForgotPasswordPageRoute>(
      path: ForgotPasswordPageRoute.path,
    ),
    TypedGoRoute<VerifyEmailPageRoute>(
      path: VerifyEmailPageRoute.path,
    ),
  ],
)
class RootPageRoute extends ShellRouteData {
  const RootPageRoute();

  static final GlobalKey<NavigatorState> $navigatorKey = shellNavigatorKey;

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    final child = (((navigator as HeroControllerScope).child as Navigator)
            .pages
            .last as MaterialPage)
        .child;

    return AdaptiveScaffold(
      key: const GlobalObjectKey('AdaptiveScaffold'),
      selectedIndex: locationToIndex(state.location),
      useDrawer: false,
      internalAnimations: false,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.account_circle_outlined),
          selectedIcon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
        NavigationDestination(
          icon: Icon(Icons.login_outlined),
          selectedIcon: Icon(Icons.login),
          label: 'SignIn',
        ),
      ],
      onSelectedIndexChange: (p0) {
        indexToGo(p0, context);
      },
      body: (context) {
        return child;
      },
      smallBody: (context) {
        return child;
      },
    );
  }

  int locationToIndex(String location) {
    if (location.startsWith(ProfilePageRoute.path)) {
      return 0;
    }

    if (location.startsWith(SignInPageRoute.path)) {
      return 1;
    }

    return 0;
  }

  void indexToGo(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.push(ProfilePageRoute.path);
        break;
      case 1:
        context.push(SignInPageRoute.path);
        break;
    }
  }
}

class SignInPageRoute extends GoRouteData {
  const SignInPageRoute();

  static const path = '/signIn';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CustomSignInScreen();
}

class VerifyEmailPageRoute extends GoRouteData {
  const VerifyEmailPageRoute();

  static const path = '/verify-email';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      EmailVerificationScreen(
        actions: [
          EmailVerifiedAction(
            () => context.pushReplacement(ProfilePageRoute.path),
          ),
          AuthCancelledAction(
            (context) {
              FirebaseUIAuth.signOut(context: context);
              context.pushReplacement(SignInPageRoute.path);
            },
          ),
        ],
      );
}

class ForgotPasswordPageRoute extends GoRouteData {
  final String email;

  const ForgotPasswordPageRoute({
    required this.email,
  });

  static const path = '/forgot-password/:email';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ForgotPasswordScreen(
        email: email.toString(),
      );
}

class ProfilePageRoute extends GoRouteData {
  const ProfilePageRoute();

  static const path = '/profile';

  @override
  Widget build(BuildContext context, GoRouterState state) => ProfileScreen(
        providers: [EmailAuthProvider()],
        actions: [
          SignedOutAction((context) {
            context.pushReplacement(SignInPageRoute.path);
          }),
        ],
      );
}

class ErrorPageRoute extends GoRouteData {
  const ErrorPageRoute();

  static const path = '/error';

  @override
  Widget build(BuildContext context, GoRouterState state) => Scaffold(
        appBar: AppBar(),
        body: const Text('404 - Page not found!'),
      );
}

class CustomSignInScreen extends ConsumerWidget {
  const CustomSignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: const Text('Sign in'),
        ),
        body: SignInScreen(
          providers: [EmailAuthProvider()],
          actions: [
            ForgotPasswordAction(
              (context, email) => ForgotPasswordPageRoute(
                      email: email == null
                          ? ''
                          : email == ''
                              ? 'email@email.com'
                              : email)
                  .push(context),
            ),
            AuthStateChangeAction<SignedIn>((context, state) =>
                state.user!.emailVerified
                    ? context.push(ProfilePageRoute.path)
                    : context.pushReplacement(VerifyEmailPageRoute.path)),
            AuthStateChangeAction<UserCreated>((context, state) =>
                state.credential.user!.emailVerified
                    ? context.push(ProfilePageRoute.path)
                    : context.pushReplacement(VerifyEmailPageRoute.path)),
            AuthStateChangeAction<CredentialLinked>((context, state) =>
                state.user.emailVerified
                    ? context.push(ProfilePageRoute.path)
                    : context.pushReplacement(VerifyEmailPageRoute.path)),
          ],
        ),
      );
}
