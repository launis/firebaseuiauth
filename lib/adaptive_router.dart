import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

final GoRouter router = GoRouter(
  initialLocation: '/signIn',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    print('state.matchedLocation${state.matchedLocation}');
    print('state.location${state.location}');
    print('currentUser.emailVerified${currentUser?.emailVerified}');
    print('currentUser.email${currentUser?.email}');

    if (!state.matchedLocation.startsWith('/forgot-password')) {
      if (currentUser == null) {
        print('/signIn');
        return '/signIn';
      }

      if (!currentUser.emailVerified && currentUser.email != null) {
        print('/verify-email');
        return '/verify-email';
      }
    }
    return null;
  },
  routes: <RouteBase>[
    /// Application shell
    GoRoute(
      path: '/verify-email',
      pageBuilder: (context, state) => NoTransitionPage(
        child: EmailVerificationScreen(
          actions: [
            EmailVerifiedAction(
              () => context.pushReplacement('/profile'),
            ),
            AuthCancelledAction(
              (context) async {
                print('AuthCancelledAction');
                await FirebaseUIAuth.signOut();
                if (!context.mounted) return;
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
