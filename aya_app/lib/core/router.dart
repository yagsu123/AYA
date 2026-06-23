import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/auth_provider.dart';
import '../features/auth/login/login_screen.dart';
import '../features/auth/splash/splash_screen.dart';
import '../features/auth/totp/totp_setup_screen.dart';
import '../features/birthdays/view/birthdays_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/events/view/event_detail_screen.dart';
import '../features/events/view/events_screen.dart';
import '../features/aes/view/aes_screen.dart';
import '../features/gallery/view/album_detail_screen.dart';
import '../features/gallery/view/gallery_screen.dart';
import '../features/settings/view/settings_screen.dart';
import '../features/members/admin/admin_panel_screen.dart';
import '../features/profile/edit/profile_edit_screen.dart';
import '../features/profile/view/profile_screen.dart';
import '../features/vibhags/view/vibhag_detail_screen.dart';
import '../features/vibhags/view/vibhags_hub_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/totp-setup',
        builder: (_, state) => TotpSetupScreen(args: state.extra as TotpSetupArgs),
      ),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminPanelScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/profile/complete', builder: (_, __) => const ProfileEditScreen()),
      GoRoute(
        path: '/birthdays',
        builder: (_, state) => BirthdaysScreen(
            initialKind: state.uri.queryParameters['kind'] ?? 'birthdays'),
      ),
      GoRoute(path: '/events', builder: (_, __) => const EventsScreen()),
      GoRoute(
        path: '/events/:id',
        builder: (_, state) => EventDetailScreen(
            eventId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0),
      ),
      GoRoute(path: '/vibhags', builder: (_, __) => const VibhagsHubScreen()),
      GoRoute(
        path: '/vibhags/:type',
        builder: (_, state) =>
            VibhagDetailScreen(type: state.pathParameters['type'] ?? ''),
      ),
      GoRoute(path: '/gallery', builder: (_, __) => const GalleryScreen()),
      GoRoute(
        path: '/gallery/:id',
        builder: (_, state) => AlbumDetailScreen(
            albumId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0),
      ),
      GoRoute(path: '/aes', builder: (_, __) => const AesScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;

      // Splash decides for itself when to leave (2.5 s minimum).
      if (loc == '/splash') return null;

      final authed = auth.status == AuthStatus.authenticated;
      final isAdmin = auth.member?.role == 'president' || auth.member?.role == 'secretary';
      const protectedPrefixes = [
        '/dashboard', '/admin', '/profile', '/birthdays', '/events', '/vibhags',
        '/gallery', '/aes', '/settings',
      ];
      final isProtected = protectedPrefixes.any((p) => loc == p || loc.startsWith('$p/'));

      if (!authed && isProtected) return '/login';
      if (authed && loc == '/login') return isAdmin ? '/admin' : '/dashboard';
      if (loc == '/admin' && !isAdmin) return '/dashboard';
      // Admins go straight to the Admin Panel — no member dashboard for them.
      if (authed && isAdmin && loc == '/dashboard') return '/admin';

      // First login → forced into the completion flow.
      // Admins (president/secretary) are exempt — they can complete their
      // profile any time via My Profile.
      if (authed && auth.needsProfileCompletion && !isAdmin && loc != '/profile/complete') {
        return '/profile/complete';
      }
      return null;
    },
  );
});

/// Re-evaluates router redirect whenever auth state changes.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
}
