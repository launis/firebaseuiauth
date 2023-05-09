import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

// import 'go_router_refresh_stream.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter router = GoRouter(
  initialLocation: '/signIn',
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
//      refreshListenable:
//          GoRouterRefreshStream(authRepository.authStateChanges()),
  redirect: (context, state) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (!state.matchedLocation.startsWith('/forgot-password')) {
      if (currentUser == null) {
        return '/signIn';
      }

      if (!currentUser.emailVerified && currentUser.email != null) {
        return '/verify-email';
      }
    }
    return null;
  },
  routes: <RouteBase>[
    /// Application shell
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/verify-email',
          pageBuilder: (context, state) => NoTransitionPage(
            child: EmailVerificationScreen(
              actions: [
                EmailVerifiedAction(
                  () => context.pushReplacement('/profile'),
                ),
                AuthCancelledAction(
                  (context) {
                    FirebaseUIAuth.signOut();
                    context.go('/signIn');
                  },
                ),
              ],
            ),
          ),
        ),
        GoRoute(
          path: '/forgot-password',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ForgotPasswordScreen(),
          ),
        ),
        GoRoute(
          path: '/signIn',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CustomSignInScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => NoTransitionPage(
            child: ProfileScreen(
              providers: [EmailAuthProvider()],
              actions: [
                SignedOutAction(
                  (context) {
                    context.pushReplacement('/signIn');
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ],
);

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
              (context, email) => context.push('/forgot-password'),
            ),
            AuthStateChangeAction<SignedIn>((context, state) =>
                state.user!.emailVerified
                    ? context.push('/profile')
                    : context.pushReplacement('/verify-email')),
            AuthStateChangeAction<UserCreated>((context, state) =>
                state.credential.user!.emailVerified
                    ? context.push('/profile')
                    : context.pushReplacement('/verify-email')),
            AuthStateChangeAction<CredentialLinked>((context, state) =>
                state.user.emailVerified
                    ? context.push('/profile')
                    : context.pushReplacement('/verify-email')),
          ],
        ),
      );
}

class ScaffoldWithNavBar extends StatelessWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    required this.child,
    Key? key,
  }) : super(key: key);

  /// The widget to display in the body of the Scaffold.
  /// In this sample, it is a Navigator.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
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
      selectedIndex: _calculateSelectedIndex(context),
      onSelectedIndexChange: (idx) => _onItemTapped(idx, context),
      body: (_) => child,
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).location;
    if (location.startsWith('/profile')) {
      return 0;
    }
    if (location.startsWith('/sigIn')) {
      return 1;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).push('/profile');
        break;
      case 1:
        GoRouter.of(context).push('/signIn');
        break;
    }
  }
}
