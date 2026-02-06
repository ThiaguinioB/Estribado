import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/comisiones/presentation/screens/comision_screen.dart';
import '../../features/comisiones/presentation/screens/comision_list_screen.dart';
import '../../features/recetario/presentation/screens/receta_screen.dart';
import '../../features/recetario/presentation/screens/receta_list_screen.dart';
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
      // COMISIONES
      GoRoute(
        path: '/comisiones',
        name: 'comisiones',
        builder: (context, state) => const ComisionListScreen(),
      ),
      GoRoute(
        path: '/comisiones/nueva',
        name: 'nueva-comision',
        builder: (context, state) => const ComisionScreen(),
      ),
      GoRoute(
        path: '/comisiones/editar/:id',
        name: 'editar-comision',
        builder: (context, state) {
          // El provider ya tiene la comisión cargada
          return const ComisionScreen();
        },
      ),
      // RECETARIO
      GoRoute(
        path: '/recetario',
        name: 'recetario',
        builder: (context, state) => const RecetaListScreen(),
      ),
      GoRoute(
        path: '/recetario/nueva',
        name: 'nueva-receta',
        builder: (context, state) => const RecetaScreen(),
      ),
      GoRoute(
        path: '/recetario/editar/:numeroReceta',
        name: 'editar-receta',
        builder: (context, state) {
          final numeroReceta = int.tryParse(state.pathParameters['numeroReceta'] ?? '');
          return RecetaScreen(numeroRecetaEditar: numeroReceta);
        },
      ),
    ],
  );
}
