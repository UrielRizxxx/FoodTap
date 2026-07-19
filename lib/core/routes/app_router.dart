import 'package:go_router/go_router.dart';

import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/chat/screens/chat_room_screen.dart';
import '../../features/chat/screens/chats_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/orders/screens/my_orders_screen.dart';
import '../../features/profile/screens/profile_menu_screen.dart';
import '../../features/products/screens/my_publications_screen.dart';
import '../../features/products/screens/product_detail_screen.dart';
import '../../features/products/screens/publish_product_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../models/product_model.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) =>
            const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) =>
            const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            const HomeScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) =>
            const MyOrdersScreen(),
      ),
      GoRoute(
        path: '/publish-product',
        builder: (context, state) =>
            const PublishProductScreen(),
      ),
      GoRoute(
        path: '/product-detail',
        builder: (context, state) {
          final product =
              state.extra as ProductModel?;

          if (product == null) {
            return const HomeScreen();
          }

          return ProductDetailScreen(
            product: product,
          );
        },
      ),
      GoRoute(
        path: '/my-publications',
        builder: (context, state) =>
            const MyPublicationsScreen(),
      ),
      GoRoute(
        path: '/chats',
        builder: (context, state) =>
            const ChatsScreen(),
      ),
      GoRoute(
        path: '/chat-room/:chatId',
        builder: (context, state) {
          final chatId =
              state.pathParameters['chatId'];

          if (chatId == null ||
              chatId.trim().isEmpty) {
            return const ChatsScreen();
          }

          return ChatRoomScreen(
            chatId: chatId,
          );
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) =>
            const ProfileMenuScreen(),
      ),
    ],
  );
}