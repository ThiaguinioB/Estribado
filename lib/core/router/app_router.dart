import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/comisiones/presentation/screens/comision_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/comisiones',
        name: 'comisiones',
        builder: (context, state) => const ComisionScreen(),
      ),
      GoRoute(
        path: '/comisiones/nueva',
        name: 'nueva-comision',
        builder: (context, state) => const ComisionScreen(),
      ),
    ],
  );
}
