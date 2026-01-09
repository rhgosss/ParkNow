import 'package:go_router/go_router.dart';
import '../screens/users_db_view_screen.dart';
import '../screens/parking_spots_db_view_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';


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
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/role', builder: (context, state) => const RoleSelectScreen()),
      GoRoute(path: '/search', builder: (context, state) => const SearchOverlayScreen()),
GoRoute(path: '/results', builder: (context, state) => const ResultsListScreen(showBack: true)),
GoRoute(path: '/spot', builder: (context, state) => const SpotDetailsScreen()),
GoRoute(path: '/date', builder: (context, state) => const DatePickerScreen()),
GoRoute(path: '/payment', builder: (context, state) => const PaymentScreen()),
GoRoute(path: '/payment-card', builder: (context, state) => const CardPaymentScreen()),
GoRoute(path: '/active-booking', builder: (context, state) => const ActiveBookingScreen()),
      GoRoute(path: '/main', builder: (context, state) => const MainGate()),
      GoRoute(
  path: '/debug/users',
  builder: (context, state) => const UsersDbViewScreen(),
),

      // Admin
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/users', builder: (context, state) => const UsersDbViewScreen()),
      GoRoute(path: '/admin/spots', builder: (context, state) => const ParkingSpotsDbViewScreen()),

      // Host new space flow
      GoRoute(path: '/host/new-space', builder: (context, state) => const NewSpaceStep1Screen()),
      GoRoute(path: '/host/access', builder: (context, state) => const AccessMethodScreen()),
      GoRoute(path: '/host/success', builder: (context, state) => const NewSpaceSuccessScreen()),

      // Utilities
      GoRoute(path: '/filters', builder: (context, state) => const FiltersScreen()),
      GoRoute(path: '/reviews', builder: (context, state) => const ReviewsScreen()),
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
    ],
  );
}
