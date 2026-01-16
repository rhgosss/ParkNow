import 'package:go_router/go_router.dart';

import '../core/state/app_state.dart';
import '../features/search/garage_map_screen.dart';

import '../features/auth/login/login_screen.dart';
import '../features/auth/register/register_screen.dart';
import '../features/onboarding/role_select_screen.dart';
import '../features/shell/main_gate.dart';

import '../features/host/spaces/new_space_step1_screen.dart';
import '../features/host/spaces/access_method_screen.dart';
import '../features/host/spaces/new_space_success_screen.dart';
import '../features/host/messages/host_messages_screen.dart';

import '../features/chat/chat_screen.dart';
import '../features/chat/user_messages_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/payments/payments_screen.dart';
import '../features/filters/filters_screen.dart';
import '../features/reviews/reviews_screen.dart';

import '../features/search/search_overlay_screen.dart';
import '../features/search/results_list_screen.dart';
import '../features/spot/spot_details_screen.dart';

import '../features/booking/date_picker_screen.dart';
import '../features/booking/booking_confirm_screen.dart';
import '../features/booking/my_bookings_screen.dart';
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
        return (isAuthRoute || isRoleRoute) ? null : '/login';
      }

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
      GoRoute(
        path: '/role', 
        builder: (context, state) => RoleSelectScreen(params: state.uri.queryParameters),
      ),

      GoRoute(path: '/main', builder: (_, __) => const MainGate()),

      GoRoute(path: '/search', builder: (_, __) => const SearchOverlayScreen()),
      GoRoute(
        path: '/results',
        builder: (context, state) {
          final q = state.uri.queryParameters['q'];
          return ResultsListScreen(showBack: true, query: q);
        },
      ),
      GoRoute(
        path: '/spot/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return SpotDetailsScreen(spotId: id!);
        },
      ),
      GoRoute(
        path: '/date', 
        builder: (context, state) => DatePickerScreen(params: state.uri.queryParameters),
      ),
      GoRoute(
        path: '/booking-confirm', 
        builder: (context, state) => BookingConfirmScreen(params: state.uri.queryParameters),
      ),
      GoRoute(
        path: '/payment', 
        builder: (context, state) => PaymentScreen(params: state.uri.queryParameters),
      ),
      GoRoute(path: '/payment-card', builder: (_, __) => const CardPaymentScreen()),
      GoRoute(path: '/active-booking', builder: (_, __) => const ActiveBookingScreen()),
      GoRoute(
        path: '/booking/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return ActiveBookingScreen(bookingId: id);
        },
      ),
      GoRoute(path: '/my-bookings', builder: (_, __) => const MyBookingsScreen()),

      GoRoute(path: '/host/new-space', builder: (_, __) => const NewSpaceStep1Screen()),
      GoRoute(
        path: '/host/access', 
        builder: (context, state) => AccessMethodScreen(params: state.uri.queryParameters),
      ),
      GoRoute(
        path: '/host/success', 
        builder: (context, state) => NewSpaceSuccessScreen(params: state.uri.queryParameters),
      ),
GoRoute(
  path: '/search/map',
  builder: (_, __) => const GarageMapScreen(),
),

      GoRoute(path: '/filters', builder: (_, __) => const FiltersScreen()),
      GoRoute(path: '/reviews', builder: (_, __) => const ReviewsScreen()),
      GoRoute(
        path: '/chat', 
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? 'default';
          final name = state.uri.queryParameters['name'] ?? 'Chat';
          return ChatScreen(conversationId: id, otherUserName: name);
        },
      ),
      GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
      GoRoute(path: '/edit-profile', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/payments', builder: (_, __) => const PaymentsScreen()),
      GoRoute(path: '/messages', builder: (_, __) => const HostMessagesScreen()),
      GoRoute(path: '/user-messages', builder: (_, __) => const UserMessagesScreen()),
    ],
  );
}
