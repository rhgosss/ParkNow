import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/state/app_state.dart';
import '../features/auth/login/login_screen.dart';
import '../features/auth/register/register_screen.dart';
import '../features/onboarding/role_select_screen.dart';
import '../features/shell/main_gate.dart';

import '../features/host/spaces/new_space_step1_screen.dart';
import '../features/host/spaces/access_method_screen.dart';
import '../features/host/spaces/new_space_success_screen.dart';

import '../features/chat/chat_screen.dart';
import '../features/filters/filters_screen.dart';
import '../features/reviews/reviews_screen.dart';
import '../features/search/search_overlay_screen.dart';
import '../features/search/results_list_screen.dart';
import '../features/spot/spot_details_screen.dart';
import '../features/booking/date_picker_screen.dart';
import '../features/payment/payment_screen.dart';
import '../features/payment/card_payment_screen.dart';
import '../features/booking/active_booking_screen.dart';

GoRouter createRouter(AppState appState) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: appState,
    redirect: (context, state) {
      final loc = state.matchedLocation;

      final isAuthRoute = loc == '/login' || loc == '/register';
      final isRoleRoute = loc == '/role';

      if (!appState.loggedIn) {
        return isAuthRoute ? null : '/login';
      }

      // logged in
      if (appState.needsRoleSelection) {
        return isRoleRoute ? null : '/role';
      }

      if (isAuthRoute || isRoleRoute) {
        return '/main';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/role', builder: (_, __) => const RoleSelectScreen()),
      GoRoute(path: '/search', builder: (_, __) => const SearchOverlayScreen()),
GoRoute(path: '/results', builder: (_, __) => const ResultsListScreen(showBack: true)),
GoRoute(path: '/spot', builder: (_, __) => const SpotDetailsScreen()),
GoRoute(path: '/date', builder: (_, __) => const DatePickerScreen()),
GoRoute(path: '/payment', builder: (_, __) => const PaymentScreen()),
GoRoute(path: '/payment-card', builder: (_, __) => const CardPaymentScreen()),
GoRoute(path: '/active-booking', builder: (_, __) => const ActiveBookingScreen()),
      GoRoute(path: '/main', builder: (_, __) => const MainGate()),

      // Host new space flow
      GoRoute(path: '/host/new-space', builder: (_, __) => const NewSpaceStep1Screen()),
      GoRoute(path: '/host/access', builder: (_, __) => const AccessMethodScreen()),
      GoRoute(path: '/host/success', builder: (_, __) => const NewSpaceSuccessScreen()),

      // Utilities
      GoRoute(path: '/filters', builder: (_, __) => const FiltersScreen()),
      GoRoute(path: '/reviews', builder: (_, __) => const ReviewsScreen()),
      GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
    ],
  );
}
