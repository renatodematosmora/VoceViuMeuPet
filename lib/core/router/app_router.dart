import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voce_viu_meu_pet/features/auth/presentation/screens/login_screen.dart';
import 'package:voce_viu_meu_pet/features/auth/presentation/screens/register_screen.dart';
import 'package:voce_viu_meu_pet/features/auth/presentation/screens/splash_screen.dart';
import 'package:voce_viu_meu_pet/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:voce_viu_meu_pet/features/feed/presentation/screens/feed_screen.dart';
import 'package:voce_viu_meu_pet/features/pets/presentation/screens/pet_detail_screen.dart';
import 'package:voce_viu_meu_pet/features/pets/presentation/screens/add_pet_screen.dart';
import 'package:voce_viu_meu_pet/features/sightings/presentation/screens/add_sighting_screen.dart';
import 'package:voce_viu_meu_pet/features/profile/presentation/screens/profile_screen.dart';
import 'package:voce_viu_meu_pet/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:voce_viu_meu_pet/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:voce_viu_meu_pet/features/map/presentation/screens/map_screen.dart';
import 'package:voce_viu_meu_pet/core/widgets/main_scaffold.dart';

// ── Route names ──────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();
  static const splash        = '/';
  static const onboarding    = '/onboarding';
  static const login         = '/login';
  static const register      = '/register';
  static const feed          = '/feed';
  static const map           = '/map';
  static const notifications = '/notifications';
  static const profile       = '/profile';
  static const editProfile   = '/profile/edit';
  static const addPet        = '/pets/add';
  static const petDetail     = '/pets/:petId';
  static const addSighting   = '/pets/:petId/sighting';
}

// ── Router Provider ──────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuth = session != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.splash ||
          state.matchedLocation == AppRoutes.onboarding;

      if (!isAuth && !isAuthRoute) return AppRoutes.login;
      if (isAuth && (state.matchedLocation == AppRoutes.login || state.matchedLocation == AppRoutes.onboarding)) return AppRoutes.feed;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Shell com Bottom Navigation ──────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.feed,
            builder: (context, state) => const FeedScreen(),
          ),
          GoRoute(
            path: AppRoutes.map,
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Rotas standalone (sem bottom nav) ────────────────────
      GoRoute(
        path: AppRoutes.addPet,
        builder: (context, state) => const AddPetScreen(),
      ),
      GoRoute(
        path: AppRoutes.petDetail,
        builder: (context, state) {
          final petId = state.pathParameters['petId']!;
          return PetDetailScreen(petId: petId);
        },
      ),
      GoRoute(
        path: AppRoutes.addSighting,
        builder: (context, state) {
          final petId = state.pathParameters['petId']!;
          return AddSightingScreen(petId: petId);
        },
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página não encontrada: ${state.error}'),
      ),
    ),
  );
});
